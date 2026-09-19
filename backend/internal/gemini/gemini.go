// Package gemini is the Generator that calls Gemini on Vertex AI through
// google.golang.org/genai (#10). It runs on the global endpoint, because no
// Middle East endpoint serves Gemini, with the runtime service account's
// Application Default Credentials.
package gemini

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"google.golang.org/genai"

	"github.com/CommRogue/recipe-app/backend/internal/generate"
	"github.com/CommRogue/recipe-app/backend/internal/prompt"
)

// Defaults from the Gemini research (#10).
const (
	DefaultLocation = "global"
	DefaultModel    = "gemini-3.8-flash"
)

// Config selects project, endpoint and model.
type Config struct {
	Project  string
	Location string
	Model    string
	// ThinkingLevel is LOW, MEDIUM or HIGH for Gemini 3 models; empty keeps
	// the model's default (MEDIUM on 3.8 Flash).
	ThinkingLevel string
}

// Client implements generate.Generator.
type Client struct {
	client *genai.Client
	cfg    Config
	schema *genai.Schema
}

// New creates the Vertex AI client. Credentials come from ADC.
func New(ctx context.Context, cfg Config) (*Client, error) {
	if cfg.Project == "" {
		return nil, errors.New("gemini: project is required")
	}
	if cfg.Location == "" {
		cfg.Location = DefaultLocation
	}
	if cfg.Model == "" {
		cfg.Model = DefaultModel
	}
	c, err := genai.NewClient(ctx, &genai.ClientConfig{
		Project:  cfg.Project,
		Location: cfg.Location,
		Backend:  genai.BackendVertexAI,
	})
	if err != nil {
		return nil, fmt.Errorf("gemini: create client: %w", err)
	}
	return &Client{client: c, cfg: cfg, schema: BodySchema()}, nil
}

// Model returns the model id in use.
func (c *Client) Model() string { return c.cfg.Model }

// GenerateRecipe implements generate.Generator with one non-streaming call.
// Structured JSON is only usable once complete, so streaming buys nothing
// until #19 decides what the waiting state shows; GenerateContentStream is
// a drop-in replacement then.
func (c *Client) GenerateRecipe(ctx context.Context, p prompt.Prompt) (json.RawMessage, generate.Usage, error) {
	usage := generate.Usage{Model: c.cfg.Model}
	config := &genai.GenerateContentConfig{
		SystemInstruction: genai.NewContentFromText(p.System, genai.RoleUser),
		ResponseMIMEType:  "application/json",
		ResponseSchema:    c.schema,
		CandidateCount:    1,
	}
	if c.cfg.ThinkingLevel != "" {
		config.ThinkingConfig = &genai.ThinkingConfig{ThinkingLevel: genai.ThinkingLevel(c.cfg.ThinkingLevel)}
	}

	started := time.Now()
	resp, err := c.client.Models.GenerateContent(ctx, c.cfg.Model, genai.Text(p.User), config)
	usage.ModelLatency = time.Since(started)
	if err != nil {
		return nil, usage, fmt.Errorf("gemini: generate content: %w", err)
	}
	if resp.UsageMetadata != nil {
		usage.PromptTokens = int(resp.UsageMetadata.PromptTokenCount)
		usage.CandidateTokens = int(resp.UsageMetadata.CandidatesTokenCount)
		usage.ThoughtTokens = int(resp.UsageMetadata.ThoughtsTokenCount)
		usage.TotalTokens = int(resp.UsageMetadata.TotalTokenCount)
	}
	if len(resp.Candidates) == 0 {
		return nil, usage, errors.New("gemini: no candidates in response")
	}
	cand := resp.Candidates[0]
	usage.FinishReason = string(cand.FinishReason)
	if cand.FinishReason == genai.FinishReasonMaxTokens {
		usage.ResponseTruncated = true
	}
	text := strings.TrimSpace(resp.Text())
	if text == "" {
		return nil, usage, fmt.Errorf("gemini: empty response (finish reason %s)", cand.FinishReason)
	}
	return json.RawMessage(text), usage, nil
}

// Close releases the underlying client.
func (c *Client) Close() error {
	// The genai client holds no resources that need closing in v1.x beyond
	// the HTTP client, which the runtime reclaims.
	return nil
}
