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

Panwise is the working name. Typography leads; emoji Covers are the visual anchor. The developer selected Index (variant A) on 21 September 2026; DESIGN.md records the direction. Issue #16's artifact contains no recipe photography. Whether its wording removes user-supplied photo Covers from v1 is unresolved against the existing domain decisions.

## Evidence on Hand

Issue #1 contains accepted scope decisions; issue #16 requests a rough artifact, one feedback iteration, then a chosen direction. The Flutter theme and home are explicitly placeholders. Prototype content is synthetic.

## Product Principles

- Saved Recipes lead at launch; Generate and Profile stay directly reachable.
- Minimise navigation depth and preserve task state on return.
- Keep saved Recipes usable when a Plan lapses.
- Distinguish Drafts, saved Recipes, and the state of a Cooking Session.
