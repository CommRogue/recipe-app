# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

People finding and cooking saved Recipes, or generating a new Recipe from their Profile and an ask. The first screen leads with saved Recipes (developer choice on issue #16). More specific audience demographics are not established.

## Product Purpose

Panwise is an AI-centred recipe app. Success means easy, fast access with few taps to generate, save, organise, rate, and cook Recipes.

## Capabilities and Constraints

Flutter phone app for Android and iOS; web is deferred. `CONTEXT.md` is the vocabulary authority and `docs/adr/` records the accepted decisions. Profile Constraints and Preferences steer generation; per-request Generation Limits and Overrides remain distinct. Drafts become Recipes only on save. Single-Recipe Cooking Sessions in v1. Free and Paid Plans limit generations and saved Recipes, not features. Estimated Macros must be labelled as estimates. Never claim a Draft was checked against Constraints.

## Brand Commitments

Panwise is the working name. Typography leads; emoji Covers are the visual anchor and permanent fallback. The developer selected Index (variant A) on 21 September 2026; DESIGN.md records the direction. User-supplied photo Covers for saved Recipes remain in scope for v1 (resolved in issue #28, reconciling #1, #4, #5, and #46), while stock food photography and AI-generated covers remain deferred.

## Evidence on Hand

Issue #1 contains accepted scope decisions; issue #16 establishes the Index design direction; issue #28 resolves the generation limit, override, and cover scope gaps. The Flutter theme and home are placeholders. Prototype content is synthetic.

## Product Principles

- Saved Recipes lead at launch; Generate and Profile stay directly reachable.
- Minimise navigation depth and preserve task state on return.
- Keep saved Recipes usable when a Plan lapses.
- Distinguish Drafts, saved Recipes, and the state of a Cooking Session.
