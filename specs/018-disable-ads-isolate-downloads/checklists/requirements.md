# Specification Quality Checklist: Disable Ads (Traceable) & Isolate-Backed Downloads

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-07-24
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

### Post-clarification update (2026-07-24)

`/speckit.clarify` asked and resolved 5 questions. Spec grew from 16 to 22 functional requirements and from 8 to 10 success criteria. Re-validated against every checklist item above — all still pass. Resolved:

1. Marker tag fixed at `// TODO(ads-disabled-018):` — FR-010, SC-006.
2. Ad tests commented out with the same marker, download tests rewritten for the no-ad path — FR-013, FR-017.
3. Downloads survive screen exit and still save — FR-018, US3 scenario 4, edge cases.
4. Media streamed to disk, peak memory independent of file size, partial writes cleaned up — FR-019, FR-020, SC-009.
5. Premium purchase entry point hidden while ads are paused; entitlements and restore untouched — FR-014, FR-021, FR-022, SC-010, US2 scenario 6.

Answer 5 was the user's own call (they chose option C over the recommended option A). It carries a revenue consequence — no new subscriptions are sold for the duration of the pause — recorded explicitly in Assumptions rather than left implicit.

### Delivery outcome (2026-07-24)

`/speckit.implement` ran all 68 tasks across Setup, Foundational, and all four user stories. Final gate:
`flutter analyze` 0 issues, `flutter test` 81/81 passing, `flutter build apk --debug` succeeds.

- **US1/US2/US3/US4**: all complete and independently verifiable per their stated test criteria (device-dependent
  checks excepted — see below).
- **T053–T059** (Pattern A on the 7 ad test files) were pulled forward into Phase 4 rather than done in Phase 6 as
  originally sequenced — commenting the production ad files broke those tests' compilation immediately, and
  `quickstart.md`'s own stage grouping already anticipated doing production + test Pattern-A together. Tasks.md's
  phase split was coarser than the actual dependency; noted at T034/T053–T059, not a scope change.
- **Restore rehearsal (T062) found and fixed a real defect**: several Pattern B sites had replaced original
  explanatory comments with the marker's own reason instead of preserving both, one comment header was dropped
  entirely with no replacement, and `download_cubit.dart`'s original rewarded-gate integration code had been lost
  outright (not just re-commented) because the file was rewritten twice — once for US1, again for US3's
  event-driven redesign. All fixed; re-verified byte-identical (Pattern A) / content-identical (Pattern B) restore
  against pre-feature `HEAD`. This is the kind of gap the rehearsal exists to catch — worth treating as a
  standard step whenever a disabled site's surrounding code gets touched again later.
- **Deviations from the task list, both judgment calls made during implementation**:
  - No git commits were created per-task (session policy: commits only on explicit user request). The rehearsal
    for SC-008 was done via direct file backup/restore instead of a scratch commit — same claim, no git history
    risk.
  - `download_cubit.dart`'s rewarded-gate marker carries an explicit note that restoring it needs re-wiring into
    the new event-driven flow, not pure uncommenting — an honest exception to "restore = uncomment" caused by the
    isolate/event-stream architecture change, not a shortcut.
- **Not run — no physical/emulator device attached in this environment**: T035, T051, T052, T066 (manual device
  passes) and the SC-009 memory-flat verification. All are structural/code-level guarantees only; deferred to the
  user for on-device confirmation before shipping. SC-005 (tap-to-saved time improvement) is likewise unmeasured
  live, but structurally the rewarded gate's `loadTimeout = Duration(seconds: 5)` bound plus real ad watch time is
  gone entirely from the download path — replaced by an immediate call into the engine.

### Original validation (2026-07-24)

- Validation pass 1 flagged three leaks, all fixed before sign-off:
  - "isolate", "AdMob", and SDK/manager class names appeared in requirements → reworded to "off the interface thread", "ad surfaces", "ad managers". Isolate/AdMob wording now survives only in the branch name, the verbatim Input line, and the Assumptions/Out-of-Scope sections where the user's own terms are being interpreted.
  - `//TODO:` retained verbatim in FR-010 — it is the user's literal, contractual marker requirement, not an implementation choice.
- No [NEEDS CLARIFICATION] markers were needed. Three judgment calls were resolved as documented assumptions instead:
  - Scope of "all ads" → all four formats (banner, interstitial, app-open, rewarded).
  - Fate of the ad SDK dependency and platform ad identifiers → kept in place, usage disabled only (removing them risks build/runtime breakage and blocks quick restore).
  - Isolate boundary → gallery/OS-level save steps stay where they must; responsiveness is the acceptance bar, not a prescribed split.
- Reversibility (FR-009, FR-010, SC-008) is the load-bearing constraint of this feature. Ads are paused, not removed — planning must not treat the ad code as deletable.
- Ready for `/speckit.plan`.
