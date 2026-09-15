# CHANGELOG

## v0.3.2

CI installs and loads the plugin for real; the consistency gate checks manifest version sync
and Hermes registration, and stops passing on an empty scan. A per-phase pass bounds what a
run reports (noise classes out, an undowngradable floor, a unique evidence anchor), states
the trust boundary for untrusted input, separates the review from the fix lane, and opens
Remaining with one `Next:` action. `SECURITY.md` added.
Full notes: `docs/release-notes/v0.3.2.md` ([中文](docs/release-notes/v0.3.2-zh-CN.md))

## v0.3.1

Hermes plugin registration fixed (`hermes plugins doctor` now exits 0), hub installs
unblocked (scanner caution → safe), and the plugin installer downgraded from a hard
block to a confirmation prompt.
Full notes: `docs/release-notes/v0.3.1.md` ([中文](docs/release-notes/v0.3.1-zh-CN.md))

## v0.3.0

Ideas leaves Report and becomes phase 5 — six phases now: load → find → propose → fix →
ideas → report. The run-loop diagram is regenerated with archify for both locales and its
specs are committed, and CI gains a consistency gate that fails on five-phase drift.
Full notes: `docs/release-notes/v0.3.0.md` ([中文](docs/release-notes/v0.3.0-zh-CN.md))

## v0.2.0

Guardrail hardening (security checklist, attempts ledger, behavior-preservation 4 questions)
+ per-phase references split (audit/fix/review/report).
Full notes: `docs/release-notes/v0.2.0.md` ([中文](docs/release-notes/v0.2.0-zh-CN.md))

## v0.1.2

Self-bootstrap run: hook rewritten (no jq/grep, fail-closed, command-position rm +
git rm + find -delete), fake install claims removed, GEMINI.md upgraded, SPEC/README synced.
Full notes: `docs/release-notes/v0.1.2.md` ([中文](docs/release-notes/v0.1.2-zh-CN.md))

## v0.1.1

README and install experience. Skill body unchanged.
Full notes: `docs/release-notes/v0.1.1.md` ([中文](docs/release-notes/v0.1.1-zh-CN.md))

## v0.1.0

First usable release: cross-runtime skill, five phases, three-layer guardrails,
six-harness adapters, run-loop diagram.
Full notes: `docs/release-notes/v0.1.0.md` ([中文](docs/release-notes/v0.1.0-zh-CN.md))
