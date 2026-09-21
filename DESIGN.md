---
name: Panwise Index
description: Index accepted on 2026-09-21; prototype reference for future native implementation.
colors:
  text: "#202824"
  study-background: "#e9edea"
  on-accent: "#fff"
  index-accent: "#185b40"
  index-soft: "#e8f1eb"
  index-muted: "#526158"
  index-line: "#d4ded7"
  index-surface: "#fff"
typography:
  body:
    fontFamily: 'system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif'
    fontSize: "16px"
  paragraph:
    lineHeight: 1.5
  index-display:
    fontFamily: "system-ui,sans-serif"
    fontSize: "36px"
    fontWeight: 750
    lineHeight: 1.12
    letterSpacing: "-.035em"
  headline:
    fontSize: "21px"
    lineHeight: 1.25
  recipe-title:
    fontSize: "18px"
    lineHeight: 1.3
  recipe-meta:
    fontSize: "13px"
  navigation-label:
    fontSize: "12px"
  cooking-copy:
    fontSize: "20px"
    lineHeight: 1.6
rounded:
  row: "0"
  progress: "4px"
  field: "10px"
  control: "12px"
  study-phone: "28px"
spacing:
  compact: "4px"
  small: "8px"
  control-gap: "12px"
  row-gap: "16px"
  content: "24px"
components:
  button-primary-index:
    backgroundColor: "{colors.index-accent}"
    textColor: "{colors.on-accent}"
    rounded: "{rounded.control}"
    padding: "12px 16px"
  button-secondary-index:
    backgroundColor: "{colors.index-soft}"
    textColor: "{colors.index-accent}"
    rounded: "{rounded.control}"
    padding: "12px 16px"
  field-index:
    backgroundColor: "{colors.index-surface}"
    textColor: "{colors.text}"
    rounded: "{rounded.field}"
    padding: "14px"
---

# Design direction: Panwise Index

## Overview

**Accepted direction: A — Index, chosen by the developer on 2026-09-21 ("Take variant A").** Saved Recipes lead the app, with separated rows, strong sans headings, green actions, and emoji Covers. Native implementation and production validation remain future work.

Values are extracted from [the archived issue #16 prototype](https://github.com/CommRogue/recipe-app/blob/prototype/issue-16-index/docs/design/issue-16-prototype.html), scoped by [its direction notes](docs/design/issue-16-direction-notes.md). They guide the selected direction but are not production-tested Flutter tokens. The throwaway HTML uses synthetic data. Index is the default presentation; `?compare=1` retains the earlier alternatives for reference.

## Colors

Index uses green for actions and selected states, a soft green selection/note surface, muted metadata, fine separators, and a white page surface. Text stays dark. The study background belongs to the HTML presentation, not the native app.

## Typography

System body text and strong sans headings establish the hierarchy. Emoji Covers explicitly prefer Apple Color Emoji, Segoe UI Emoji, then Noto Color Emoji. Library Covers use 36px; detail Covers use 64px. Ingredient quantities use tabular numerals.

## Layout

The default Index view hides the comparison harness. Optional comparison mode uses a desktop guide beside the phone, stacking below it at 760px and below. Its frame and switcher dimensions are HTML study details, not native device specifications.

Phone content uses 24px 24px 20px padding on desktop and 22px 20px on narrow screens. Recipe rows use 18px vertical padding. The three labelled navigation destinations are sticky within the phone. Cooking omits that navigation and supplies an explicit leave action.

## Elevation & Depth

Recipe rows are separated with lines, without card shadows. The selected library segment has a small shadow. The desktop phone frame and fixed candidate switcher have shadows as comparison-harness elements. Exact values are in the sidecar; none is an accepted native elevation token.

## Shapes

Shared controls use the control radius; fields use the slightly smaller field radius. Recipe and Collection rows have square corners and bottom separators. The desktop phone frame is rounded; the final narrow-screen override makes it square. Buttons have a 48px minimum height, and navigation buttons have an 88px minimum width.

## Components

Primary buttons pair the Index accent with white text and weight 700; hover reduces brightness to .9. Secondary buttons pair the soft surface with accent text and weight 650. Other buttons gain the soft surface on hover. Disabled buttons use .55 opacity.

Focus-visible uses a 3px accent outline offset by 3px. Search instead outlines its containing surface at 2px on focus-within. Text and number fields, textareas, and selects share a border and page surface; placeholders use muted text. Textareas have a 115px minimum height.

Library segments use a soft track with 4px padding and gap; the selected button uses the page surface and weight 700. Navigation uses muted labels until selected, then soft background, accent text, and weight 750. Resume controls and notes share soft surfaces. Cooking progress animates width for .2s ease-out; reduced-motion preference disables transitions.

The selection refinement restores library scroll on return, starts newly opened screens at the top, and resumes the existing Cooking Session when opening the same Recipe to cook again. These are prototype interaction behaviors to carry into native implementation.

## Do's and Don'ts

- Do use the accepted Index direction as the reference for future native implementation.
- Do treat the HTML prototype as the source for these extracted values.
- Do preserve labelled navigation, readable Recipe titles, visible keyboard focus, and return-to-task state.
- Don't promote this throwaway HTML or its study-harness dimensions into production Flutter code.
- Don't infer a settled photo-Cover policy from this photography-free artifact; PRODUCT.md records that open question.
