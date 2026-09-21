# Issue #16: prototype direction notes

Status: **Index (variant A) selected by the developer on 21 September 2026**, following the three-direction clickable prototype. Saved Recipes lead at launch. The feedback iteration keeps Index's visual language, makes it the dedicated default preview, preserves library scroll on return, and resumes an existing Cooking Session when Cook is tapped for that same Recipe. B and C remain archival comparisons only.

## Exploration

The mechanism is a saved personal recipe library fed by Profile-steered generation. The usage scene is a phone in a home kitchen, often under bright light, where legible ingredients and quick return to cooking matter. Seven grounded systems considered, ordered by resonance: a kitchen shelf organised by use; a cookbook contents page; a family recipe box; a weekly meal notebook; a market's produce labels; a kitchen appliance's clear controls; a reference index with compact entries and direct lookup. These span shelving, print, correspondence, retail and equipment. The default photography feed and its empty chatbot opposite do not meet the brief.

Impeccable seed `d31e252e` assigned grounded direction 7. It becomes **Index**, the leading prototype. **Shelf** is the top grounded alternative. The cassette tracklist challenger becomes **Tempo**, a competitive third option: title-led entries and right-aligned time make a plausible personal collection, but the reference is less immediately connected to cooking.

Other challengers declined on both audience identification and product clarity: teletext page-number navigation adds learning; exposure-sheet hatching adds decoding; tensegrity force diagrams invent relationships; drawcord transformations hide direct actions; dense web mosaics lose phone touch targets. Retained disciplines: teletext's stable wayfinding; exposure sheets' separation of state from content; tensegrity's visible relationships (Ingredients beside their Step); drawcord's explicit state transitions; dense web's efficient use of space. No literal motifs are imported.

## Direction contract

THESIS: A personal library that opens directly onto things worth cooking. Recipe titles and emoji Covers carry recognition; photography is unnecessary.

OWN-WORLD: Index uses white, deep green, cool green selection surfaces, strong sans headings and separated rows. Readable system body text and labelled navigation support the kitchen task. Shelf and Tempo are rejected alternatives, not parts of the accepted system.

STORY: Find a saved Recipe, inspect Ingredients, cook; or move directly to Generate, review a Draft, and save it into the same library.

FIRST VIEWPORT: Phone-width library, title and Generate action above search, Collections immediately below, emoji entries filling the body, persistent three-destination navigation below. Signature interaction: saving a Draft turns it into a Recipe and makes it discoverable in the library without losing its identity. Comparison controls are absent from the selected preview; `?compare=1` reveals the archive.

FORM: Reference index, candidate 7, seed `d31e252e`; developer selected variant A. The two alternatives remain evidence of the exploration only.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance

## Review boundary

This is a throwaway HTML interaction sketch, not a shipping web platform or a replacement Flutter app. No backend, purchases, authentication, or persistent data. The artifact labels its synthetic data and limits. Browser evidence verifies this artifact only, not iOS/Android behavior. Do not promote its code into production.

The accepted direction and screen map are the implementation handoff. The [archived artifact](https://github.com/CommRogue/recipe-app/blob/prototype/issue-16-index/docs/design/issue-16-prototype.html) preserves the selected preview and comparison alternatives on a dedicated branch. Download the HTML and open it in a browser, or serve its design directory as described in that branch's README.
