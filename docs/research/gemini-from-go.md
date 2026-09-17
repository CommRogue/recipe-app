# Gemini on Vertex AI from Go

**Research Date:** 2026-09-16 (audited and corrected 2026-09-17 against the model cards, pricing page, locations table and Standard PayGo page; see Audit notes at the end)  
**Question:** How should a Go service on Cloud Run call Gemini on Vertex AI to produce a Recipe as structured JSON?

## Recommended Default Models

**For Generation:** `gemini-3.8-flash` (GA, September 2, 2026)
- Reasoning: Most capable Flash model (approaching Pro-level performance), 1M token context, structured output + streaming support, served only from the `global` endpoint and the `us` / `eu` multi-region endpoints (no single-region endpoints), 45-minute video limit, supports thinking_level LOW/MEDIUM/HIGH (default MEDIUM, no MINIMAL).
- Pricing on the `global` endpoint: $0.75/$3.75 per 1M input/output tokens through Dec 31 2026; $1.50/$7.50 starting Jan 1 2027 (introductory pricing). Non-global endpoints (`us`, `eu`) cost 10% more ($0.825/$4.125 intro).

**For Refinement:** `gemini-3.5-flash-lite` (GA, July 21, 2026)  
- Reasoning: Cost-efficient ($0.30/$2.50 per 1M tokens, stable pricing), optimized for latency and high-volume tasks, thinking_level defaults to MINIMAL (fast, no reasoning for simple refinement requests), structured output support, 1M token context.
- Retirement: July 21, 2027 or later (12+ months guaranteed).

## Go SDK and Authentication

**Module:** `google.golang.org/genai` (v1.71.0 as of Aug 31, 2026)  
**Vertex AI Backend:** Explicitly set `Backend: genai.BackendVertexAI` in `ClientConfig`, or use env var `GOOGLE_GENAI_USE_VERTEXAI=true` (v1.71 also accepts `GOOGLE_GENAI_USE_ENTERPRISE=true`, which is aliased to `BackendVertexAI` internally).

**Authentication on Cloud Run:** Application Default Credentials (ADC) are automatic:
1. Cloud Run assigns a service account (default or user-managed via `gcloud run deploy --service-account <SA>`).
2. Google Cloud client libraries (including genai) automatically request OAuth 2.0 tokens from the metadata server.
3. **No `GOOGLE_APPLICATION_CREDENTIALS` env var needed on Cloud Run.** Recommendation: use a dedicated, least-privilege service account with `roles/aiplatform.user` IAM role for Vertex AI model calls.

**ADC Search Order** (for local dev or manual setup):
1. `GOOGLE_APPLICATION_CREDENTIALS` env var → JSON key file
2. Well-known location for `gcloud auth application-default login` credentials
3. Metadata server (Compute Engine, Cloud Run, GKE, Cloud Functions)

**Go Version Requirement:** go 1.24 (from go.mod)

## Structured Output (JSON Schema)

**Supported Models:** Gemini 3.8 Flash, 3.7 Flash, 3.6 Flash, 3.5 Flash-Lite, 3.5 Flash, 3.1 Pro preview, 3.1 Flash-Lite, 3 Flash preview, 2.5 Pro, 2.5 Flash-Lite, 2.5 Flash.

**SDK Fields in `GenerateContentConfig`:**
- `ResponseMIMEType: "application/json"` (required for JSON output)
- `ResponseSchema: *Schema` (OpenAPI 3.0 subset, uses genai.Schema type with Type, Properties, Required, Items, Enum, Format, AnyOf, PropertyOrdering, Nullable, MinItems, MaxItems, Minimum, Maximum, additionalProperties, $ref/$defs fields)
- `ResponseJsonSchema: any` (full JSON Schema, not type-checked by Go SDK; passed as-is to Vertex AI)

**Supported JSON Schema Features** (from `ResponseJsonSchema` doc comments and REST reference):
- Supported: `$id`, `$defs`, `$ref`, `$anchor`, `type`, `format`, `title`, `description`, `enum` (strings/numbers only), `items`, `prefixItems`, `minItems`, `maxItems`, `minimum`, `maximum`, `anyOf`, `oneOf` (treated as `anyOf`), `properties`, `additionalProperties`, `required`, **`propertyOrdering`** (non-standard, defines generation order—properties listed first, then others alphabetically/required-first)
- **Not supported:** `$id` at sub-schema, `allOf`, `not`, `dependentSchemas`, pattern properties, conditional schemas
- Unsupported features are silently ignored by Vertex AI; specifying them does not error.

**Best Practices:**
- Ensure 100% valid JSON: include **both** `ResponseMIMEType: "application/json"` **and** `ResponseSchema` or `ResponseJsonSchema`. JSON-only mode (without schema) is a hint only; complex payloads can malform.
- Schema size counts toward input token limit.
- Avoid overly complex schemas (long property names, huge enums, deeply nested optional properties, complex format constraints)—Vertex AI returns `InvalidArgument: 400` if schema is too complex.
- Model respects `propertyOrdering` if specified; otherwise generates alphabetically with required-first.

**Minimal Structured-Output Code Shape (Go):**
```go
import "google.golang.org/genai"

config := &genai.GenerateContentConfig{
    ResponseMIMEType: "application/json",
    ResponseSchema: &genai.Schema{
        Type: "object",
        Properties: map[string]*genai.Schema{
            "name": {Type: "string"},
            "ingredients": {
                Type: "array",
                Items: &genai.Schema{Type: "string"},
            },
        },
        Required: []string{"name", "ingredients"},
    },
}
result, err := client.Models.GenerateContent(ctx, "gemini-3.8-flash",
    genai.Text("List a cookie recipe as JSON."), config)
if err != nil {
    return fmt.Errorf("failed: %w", err)
}
fmt.Println(result.Text())
```

## Streaming

**SDK Method:** `client.Models.GenerateContentStream(ctx, model, contents, config)` returns `iter.Seq2[*GenerateContentResponse, error]`.

**Streaming Usage (Go):**
```go
for resp, err := range client.Models.GenerateContentStream(ctx, "gemini-3.8-flash",
    genai.Text("Tell a story"), config) {
    if err != nil {
        return fmt.Errorf("stream error: %w", err)
    }
    fmt.Print(resp.Text())
}
```

**REST:** Uses HTTP Server-Sent Events (SSE). Endpoint: `POST https://LOCATION-aiplatform.googleapis.com/v1/projects/PROJECT_ID/locations/LOCATION/publishers/google/models/MODEL_ID:streamGenerateContent`. Response body is a stream of `GenerateContentResponse` instances.

**Streaming Notes:**
- Streaming works with structured output (`ResponseSchema` + `ResponseMIMEType: "application/json"`).
- `usage_metadata` may arrive in the final chunk only; monitor all chunks until `finish_reason`.
- SDK automatically concatenates text parts via `resp.Text()`.

## Multimodal Input

**Images:**
- **Supported by all Gemini 3/2.5 models** (text input). Max 3,000 images per prompt.
- **Formats:** image/png, image/jpeg, image/webp, image/heic, image/heif.
- **Tokenization (Gemini 3 models):**
  - `MEDIA_RESOLUTION_HIGH` (default): 1,120 tokens per image
  - `MEDIA_RESOLUTION_MEDIUM`: 560 tokens per image
  - `MEDIA_RESOLUTION_LOW`: 280 tokens per image
  - `MEDIA_RESOLUTION_ULTRA_HIGH`: 2,240 tokens (individual media parts only)
- **Passing:** Cloud Storage URI (`gs://`), inline base64 bytes, public HTTP URL. Inline max 7 MB; Cloud Storage max 30 MB.
- **SDK Constructor:** `genai.NewPartFromURI(fileURI, "image/jpeg")` or `NewPartFromBytes(bytes, "image/jpeg")`.

**Video:**
- **Supported by:** Gemini 3.8 Flash, 3.7 Flash, 3.6 Flash, 3.5 Flash-Lite, 3.5 Flash, 3.1 Flash-Lite, 3.1 Pro preview, 3 Flash preview, 2.5 Pro, 2.5 Flash-Lite, 2.5 Flash.
- **Max length:** ~45 minutes (with audio) or ~1 hour (without audio); supports up to 10 videos per prompt.
- **Formats:** video/x-flv, video/quicktime, video/mpeg, video/mp4, video/webm, video/wmv, video/3gpp.
- **Tokenization (Gemini 3 models, default 1 FPS sampled):**
  - `MEDIA_RESOLUTION_HIGH`: 280 tokens per frame
  - `MEDIA_RESOLUTION_MEDIUM` and `MEDIA_RESOLUTION_LOW`: 70 tokens per frame as recorded by the original pass; not re-verified in the audit, check the video understanding page before budgeting tokens for imports
- **YouTube URLs:** Supported; public or account-owned videos. Max 1 YouTube URL per prompt (distinct from other video files).
- **Agentic Video Processing** (Preview): Dynamically navigates long videos instead of static frame processing; uses fewer tokens, better for hour-long lectures/meetings; requires `media_processing="AGENTIC"` in request and model must support it (3.8/3.7/3.6 Flash, 3.5 Flash-Lite).
- **SDK:** `genai.NewPartFromURI("gs://bucket/video.mp4", "video/mp4")` + optional `genai.VideoMetadata{StartOffset, EndOffset, FPS}` to clip/resample.

**Audio:**
- **Supported models:** 3.8 Flash, 3.7 Flash, 3.6 Flash, 3.5 Flash-Lite, 3.5 Flash, 3.1 Flash-Lite, 3.1 Pro preview, 2.5 Pro, 2.5 Flash-Lite, 2.5 Flash.
- **Max length:** ~8.4 hours or up to 1M tokens per prompt; 1 audio file per prompt.
- **Formats:** audio/x-aac, audio/flac, audio/mp3, audio/m4a, audio/mpeg, audio/mpga, audio/ogg, audio/pcm, audio/wav, audio/webm.

**PDF/Documents:**
- **Supported:** application/pdf (up to 3,000 pages, 50 MB), text/plain (7 MB).
- **Tokenization (Gemini 3):** 560 tokens per page (default, MEDIUM resolution).

## Multimodal Content Construction (Go SDK)

**Content Parts:**
- `genai.Text(string)` → text part
- `genai.NewPartFromURI(fileURI, mimeType)` → Cloud Storage/HTTP file reference
- `genai.NewPartFromBytes(data []byte, mimeType)` → inline blob
- `FileData` struct for explicit file reference (e.g., via File API)
- `VideoMetadata{StartOffset, EndOffset, FPS *float64}` for video clipping/fps control

**Content Object:**
```go
contents := []*genai.Content{
    {
        Role: genai.RoleUser,
        Parts: []*genai.Part{
            {Text: "What's in this image?"},
            {FileData: &genai.FileData{FileURI: "gs://bucket/image.jpg", MIMEType: "image/jpeg"}},
        },
    },
}
resp, err := client.Models.GenerateContent(ctx, "gemini-3.8-flash", contents, config)
```

## URL Context Tool

**Purpose:** Retrieve and analyze content from URLs (live web fetching + cached index fallback).  
**Supported models:** Gemini 3.8/3.7/3.6 Flash, 3.5 Flash-Lite, 3.5 Flash, 3.1 Pro preview, 3.1 Flash-Lite, 3 Flash preview, 2.5 Pro, 2.5 Flash-Lite, 2.5 Flash.  
**Limits:** Up to 20 URLs per request; supports HTML, JSON, plain text, XML, CSS, JavaScript, CSV, RTF, images (PNG/JPEG/BMP/WebP), PDF. **Does not support:** YouTube videos (use video input instead), paywalled content, Google Workspace files.

**Go Usage:**
```go
config := &genai.GenerateContentConfig{
    Tools: []*genai.Tool{
        {URLContext: &genai.URLContext{}},
    },
}
resp, err := client.Models.GenerateContent(ctx, "gemini-3.8-flash",
    genai.Text("Summarize this page: https://example.com/recipe"), config)
// Response includes url_context_metadata with url retrieval status
```

**Pricing:** Included with URL context requests; retrieved URL content tokens are billed as input tokens (no separate charge), but the retrieval operation itself has no line-item cost on Standard PayGo.  
**Compatibility with Structured Output:** Yes, can combine with `ResponseSchema` or `ResponseJsonSchema`.

## Grounding with Google Search

**Purpose:** Supplement generation with live web search results.  
**Supported models:** Gemini 3.8/3.7/3.6 Flash, 3.5 Flash-Lite, 3.5 Flash, 3.1 Pro preview, 3.1 Flash-Lite, 3 Flash preview, 2.5 Pro, 2.5 Flash-Lite, 2.5 Flash.

**Pricing:**
- Free: 5,000 grounding queries/month per Gemini 3 project (aggregated across all 3.x models).
- Excess: $14 per 1,000 queries (Gemini 3); $35 per 1,000 (Gemini 2.5 Pro); $25 (Gemini 2.5 Flash/Flash-Lite).
- Input tokens from search results are **not billed separately**.

**Go Sample:**
```go
config := &genai.GenerateContentConfig{
    Tools: []*genai.Tool{
        {GoogleSearch: &genai.GoogleSearch{}},
    },
}
resp, err := client.Models.GenerateContent(ctx, "gemini-2.5-flash",
    genai.Text("When is the next solar eclipse?"), config)
// Response includes groundingMetadata.webSearchQueries (search suggestions to display)
```

**Limitations:** Cannot combine with non-search tools (function calling, RAG) in same request. Multiple tools allowed only if all are search tools.  
**Compatibility with Structured Output:** Unverified. The grounding page does not state this either way; test before relying on Search plus `ResponseSchema` in one request. Not needed for v1.

## Thinking / Reasoning

**Supported Models:**
- Gemini 3.8 Flash: `LOW`, `MEDIUM` (default), `HIGH` — **no MINIMAL**
- Gemini 3.7 Flash: `LOW`, `MEDIUM` (default), `HIGH` — no MINIMAL
- Gemini 3.6 Flash: `MINIMAL`, `LOW`, `MEDIUM` (default), `HIGH`
- Gemini 3.5 Flash-Lite: `MINIMAL`, `LOW`, `MEDIUM`, `HIGH` (default `MINIMAL`)
- Gemini 3.5 Flash: `MINIMAL`, `LOW`, `MEDIUM`, `HIGH` (default `MEDIUM`)
- Gemini 3.1 Pro preview: `LOW`, `MEDIUM`, `HIGH` (default `HIGH`) — no MINIMAL
- Gemini 3.1 Flash-Lite: `MINIMAL`, `LOW`, `MEDIUM`, `HIGH` (default `MINIMAL`)
- Gemini 2.5 Pro, Flash, Flash-Lite: Use legacy `thinking_budget` (integer tokens, default auto 8,192)

**SDK Usage (Gemini 3 models):**
```go
config := &genai.GenerateContentConfig{
    ThinkingConfig: &genai.ThinkingConfig{
        ThinkingLevel: "MEDIUM", // or LOW/HIGH; MINIMAL not on 3.8/3.7
    },
}
```

**Thought Signatures (Gemini 3 models for function calling):**
- Preserved automatically if using SDK chat history features.
- Manual mode: must return `thought_signature` (opaque bytes) from model response in next request for context continuity.
- **Gemini 3 strict validation:** If expected thought signature is missing on function-call responses, model returns 400 error. Omitting from non-function-call responses recommended but not required.

**Sampling parameters:** On Gemini 3.5 Flash-Lite, custom `temperature`, `top_k` and `top_p` values are ignored, and custom frequency or presence penalties throw an error (model card, "potentially breaking changes"). The 3.8 Flash model card lists tunable defaults (temperature 1.0, topP 0.95, topK 64) and does not carry that warning. Leave sampling at defaults for both.

**Billing:** Thought tokens (internal reasoning) are billed as output tokens. Visible in `usage_metadata.thoughts_token_count`.

## Response Output

**Text Extraction:**
```go
resp, err := client.Models.GenerateContent(ctx, "gemini-3.8-flash",
    genai.Text("Respond with a number."), config)
if err != nil {
    return err
}
text := resp.Text() // Concatenates all text parts, skips Thought parts
fmt.Println(text)
```

**Usage Metadata:**
```go
resp.UsageMetadata.PromptTokenCount    // Input tokens (incl. cached, tool use)
resp.UsageMetadata.CandidatesTokenCount // Output tokens
resp.UsageMetadata.ThoughtsTokenCount  // Thinking tokens (if enabled)
resp.UsageMetadata.CachedContentTokenCount // Cached input tokens (if cache hit)
resp.UsageMetadata.TotalTokenCount
```

**Thinking Summaries:** Returned in response `Part` with `Thought: true` and non-empty `Text` when `ThinkingConfig.IncludeThoughts: true`. The `Text()` helper excludes thought parts, so access via `resp.Candidates[0].Content.Parts` if you need raw thoughts.

## Pricing and Quotas

| Model | Input (/1M tokens) | Output (/1M tokens) | Caching Input (/1M) | Notes |
|-------|-------------------|-------------------|-------------------|-------|
| **Gemini 3.8 Flash** | $0.75 (intro) / $1.50 | $3.75 (intro) / $7.50 | $0.075 / $0.15 | Intro pricing through Dec 31 2026 |
| **Gemini 3.7 Flash** | $0.75 (intro) / $1.50 | $3.75 (intro) / $7.50 | $0.075 / $0.15 | Intro pricing through Dec 31 2026 |
| **Gemini 3.6 Flash** | $0.75 (intro) / $1.50 | $3.75 (intro) / $7.50 | $0.075 / $0.15 | Intro pricing through Dec 31 2026 |
| **Gemini 3.5 Flash-Lite** | $0.30 | $2.50 | $0.03 | Stable pricing |
| **Gemini 3.5 Flash** | $1.50 | $9.00 | $0.15 | Stable pricing; retiring May 19, 2027 |
| **Gemini 3.1 Flash-Lite** | $0.25 | $1.50 | $0.025 | Most cost-efficient; retiring May 7, 2027 |
| **Gemini 3.1 Pro preview** | $2.00 / $4.00 (>200K) | $12.00 / $18.00 (>200K) | $0.20 / $0.40 | Preview, 1M context |
| **Gemini 2.5 Pro** | $1.25 / $2.50 (>200K) | $10.00 / $15.00 (>200K) | $0.125 / $0.25 | GA; retiring Oct 20, 2026 |
| **Gemini 2.5 Flash** | $0.30 | $2.50 | $0.03 | GA; retiring Oct 20, 2026 |
| **Gemini 2.5 Flash-Lite** | $0.10 | $0.40 | $0.01 | GA; retiring Oct 20, 2026 |

**Context Caching:**
- **Implicit (90% discount):** Enabled by default; cached input is billed at the rate in the table above ($0.075 per 1M for 3.8 Flash during intro pricing, $0.03 for 3.5 Flash-Lite, global endpoint), no storage cost.
- **Explicit (90% discount + storage):** Up to 1 hour TTL; storage billed per million token-hours.
- **Minimum cached content:** 1,024 tokens.

**Rate Limits (Standard PayGo usage tiers, organisation-level baseline TPM by 30-day spend; no separate RPM limit; tiers do not apply to preview models):**
- **Tier 1** ($10–$250/30d): 2,000,000 TPM (Flash/Lite), 500,000 TPM (Pro)
- **Tier 2** ($250–$2k): 4,000,000 TPM (Flash/Lite), 1M TPM (Pro)
- **Tier 3** ($2k–$50k): 10,000,000 TPM (Flash/Lite), 2M TPM (Pro)
- **Tier 4** (>$50k): 50,000,000 TPM (Flash/Lite), 10M TPM (Pro)

**Burst & 429 Handling:** Traffic can burst beyond baseline on best-effort basis. High demand may return HTTP 429 (Resource exhausted). Recommended: exponential backoff retry + global endpoint (routes to region with most capacity).

**Batch Inference:** No predefined quota; dynamically allocated from shared pool. Requests may queue during high demand.

## Regional Availability

**Gemini 3.8 Flash and Gemini 3.5 Flash-Lite are served only from `global`, `us` and `eu`.** Both model cards list "Global: global; Multi-region: us, eu" for model availability, Standard PayGo and Provisioned Throughput. The locations table has empty cells for every Gemini generative model under Tel Aviv (`me-west1`), Doha (`me-central1`) and Dammam (`me-central2`). There is no Middle East endpoint for generation.

**For the recipe app:** call the `global` endpoint (`Location: "global"`) from the Go service, which runs in `me-west1` per the region research. `global` is also the cheapest endpoint. It gives no processing-location guarantee; `eu` is the fallback if EU-only processing is ever required, at a 10% premium.

## Minimal Implementation Scaffold

```go
package main

import (
    "context"
    "fmt"
    "log"
    "google.golang.org/genai"
)

func main() {
    ctx := context.Background()
    
    // Create client for Vertex AI backend (ADC automatic on Cloud Run)
    client, err := genai.NewClient(ctx, &genai.ClientConfig{
        Project:  "recipe-app-508817",     // Dev project
        Location: "global",                 // no Middle East endpoint exists; "eu" or "us" are the only alternatives
        Backend:  genai.BackendVertexAI,
    })
    if err != nil {
        log.Fatalf("Failed to create client: %v", err)
    }
    defer client.Close()
    
    // Define Recipe schema
    config := &genai.GenerateContentConfig{
        ResponseMIMEType: "application/json",
        ResponseSchema: &genai.Schema{
            Type: "object",
            Properties: map[string]*genai.Schema{
                "name": {Type: "string", Description: "Recipe name"},
                "ingredients": {
                    Type: "array",
                    Items: &genai.Schema{Type: "string"},
                    Description: "List of ingredients",
                },
                "steps": {
                    Type: "array",
                    Items: &genai.Schema{Type: "string"},
                    Description: "Cooking instructions",
                },
                "time_minutes": {Type: "integer", Description: "Total time in minutes"},
            },
            Required: []string{"name", "ingredients", "steps", "time_minutes"},
        },
        ThinkingConfig: &genai.ThinkingConfig{
            ThinkingLevel: "MEDIUM",
        },
    }
    
    // Request generation
    resp, err := client.Models.GenerateContent(ctx, "gemini-3.8-flash",
        genai.Text("Create a simple cookie recipe with constraints: vegan, nut-free, under 30 minutes."),
        config)
    if err != nil {
        log.Fatalf("Failed to generate: %v", err)
    }
    
    // Output JSON
    fmt.Println(resp.Text())
    fmt.Printf("Used %d input, %d output tokens\n",
        resp.UsageMetadata.PromptTokenCount,
        resp.UsageMetadata.CandidatesTokenCount)
}
```

## Implementation Notes

1. **No Manual Credential Handling on Cloud Run:** Genai SDK automatically detects and uses the service account via metadata server.
2. **Structured Output is Reliable:** Always combine `ResponseMIMEType: "application/json"` + `ResponseSchema` for guaranteed valid JSON; test edge cases (very long recipes, special characters, unicode).
3. **Streaming for Long Responses:** For refinement loops or multi-turn conversations, use `GenerateContentStream` to reduce latency perception.
4. **Thought Signatures in Multi-Turn:** If building a refinement loop with function calls, preserve thought signatures between turns (SDK handles automatically if using built-in chat history).
5. **Model Lifecycle:** Gemini 3.8/3.7 Flash have no announced retirement; 3.5 Flash-Lite retires July 21, 2027. 2.5 models retire Oct 20, 2026 (plan migration).
6. **Cost Optimization:** 3.5 Flash-Lite ($0.30/$2.50) is ideal for Refinement (simpler rewrites); 3.8 Flash ($0.75/$3.75 intro) for initial Generation (higher quality, approaching 3.1 Pro).

## Citations

- [google.golang.org/genai v1.71.0 on pkg.go.dev](https://pkg.go.dev/google.golang.org/genai)
- [Gemini on Vertex AI: Structured output](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/capabilities/control-generated-output)
- [Google models on GEAP](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/google-models)
- [Vertex AI pricing](https://cloud.google.com/gemini-enterprise-agent-platform/generative-ai/pricing)
- [Gemini 3.8 Flash model card](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/gemini/3-8-flash)
- [Gemini 3.5 Flash-Lite model card](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/gemini/3-5-flash-lite)
- [Thinking with Gemini](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/thinking)
- [Thought signatures](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/thinking/thought-signatures)
- [Streaming Gemini](https://docs.cloud.google.com/gemini-enterprise-agent-platform/reference/rest/v1/projects.locations.publishers.models/streamGenerateContent)
- [Video understanding on GEAP](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/capabilities/video-understanding)
- [Image understanding on GEAP](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/capabilities/image-understanding)
- [URL context](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/url-context)
- [Grounding with Google Search](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/grounding/grounding-with-google-search)
- [Cloud Run service identity](https://docs.cloud.google.com/run/docs/configuring/services/service-identity)
- [ADC (Application Default Credentials)](https://docs.cloud.google.com/docs/authentication/application-default-credentials)
- [Quotas and limits](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/quotas)
- [Error code 429](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/deploy/error-code-429)
- [Retry strategy](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/retry-strategy)
- [Context caching](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/context-cache/context-cache-overview)
- [Model versions and lifecycle](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/model-versions)
- [Deployments and regional endpoints](https://docs.cloud.google.com/gemini-enterprise-agent-platform/resources/locations)
- [Data residency](https://docs.cloud.google.com/gemini-enterprise-agent-platform/resources/data-residency)

## Audit notes (2026-09-17)

The first pass of this document was completed by a smaller model after a rate-limit interruption. It was then audited line by line against the primary sources.

Verified as written: model IDs, GA dates and retirement date, context and output limits, thinking levels and defaults, image/video/audio/PDF limits, all prices in the pricing table, grounding prices, the Standard PayGo tier table, SDK module and streaming shape.

Corrected: the regional availability section (it wrongly listed `me-central1`, `me-west1` and other single regions, and mislabelled `me-central1` as Dammam; it is Doha), the implicit caching price line, the sampling-parameter claim (it over-generalised a 3.5 Flash-Lite note to all Gemini 3 models), and the missing 10% non-global price premium.

Still unverified: whether Google Search grounding can be combined with structured output, and the per-frame video token counts. The SDK version number (v1.71.0) and the exact `genai.Schema` field list were not re-checked; confirm against pkg.go.dev when scaffolding.
