# Panwise design exploration — issue #16

Open [the clickable prototype](issue-16-prototype.html) directly in a browser, or from the repository root run:

```sh
python3 -m http.server 8016 --bind 127.0.0.1 --directory docs/design
```

Visit <http://localhost:8016/issue-16-prototype.html>. There are no app dependencies, network calls, or persistent writes. The server exposes only this design directory.

**A · Index is the chosen direction.** The default preview shows it without comparison controls. Open `?compare=1&variant=A` to inspect the archived alternatives with the floating switcher. In comparison mode, `variant=B` and `variant=C` show Shelf and Tempo; arrow keys switch when a form field is not focused. The prototype state remains available alongside the phone.

Try opening a Recipe, cooking a Step, leaving and resuming; then generate a sample Draft, refine it and save it. Search for the new saved Recipe. Profile toggles, per-request Overrides, Ratings and Collection changes work in memory.

This is an interaction sketch, not production Flutter code. Synthetic samples are not generated from form input. Timers and reports are previews. Collection membership is simplified to one Collection; production supports many. It does not implement account/purchase operations, authentication, native navigation gestures, all catalogue entries, offline persistence, quota enforcement, expiry, previous Draft history, or final macro calculations. Do not use it to validate actual recipes.

See the [screen map](issue-16-screen-map.md) for the complete navigation proposal, including states not built in this sketch, and [direction notes](issue-16-direction-notes.md) for the provisional design reasoning.

## Feedback round

On 21 September 2026 the developer chose “Take variant A.” The single iteration keeps Index's visuals, dedicates the default preview to it, restores library scroll on return, and resumes the same Recipe's Cooking Session when Cook is tapped again. The selected direction is recorded in DESIGN.md and the navigation handoff in the screen map. This prototype is archived on `prototype/issue-16-index`; production Flutter implementation is a separate task.

## Verification

Chromium captures at 1440 × 1000 and 390 × 844 cover all three library variants; an additional 320 px interaction pass found no horizontal overflow. Browser checks passed: leave/resume at Step 2; first-use consent; sample generation, Refinement, save and search; Rating and note; confirmation before overriding a peanut Constraint. No JavaScript errors were observed in the main interaction pass. The design detector returned no findings.

An independent screenshot/source review judged the artifact ready for human review, not production. It identified the intended density tradeoff: Index exposes roughly three entries, Shelf two, and Tempo one complete entry above navigation at phone size. Final typography, motion and native platform verification remain outside this rough artifact. Screenshots are local review evidence under `.impeccable/review/`.

After selection, new captures cover Index at 390 × 844 and 1440 × 1000 without the comparison controls. Browser checks confirmed the hidden default switcher, opt-in archive comparison, library scroll restoration, resuming Step 2 via Cook, and generation/consent/save. No JavaScript errors were observed. This verifies the sketch, not production native navigation.
