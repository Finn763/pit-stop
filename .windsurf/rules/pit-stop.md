# Pit-stop

One instruction runs load → find → propose → fix → report on a codebase, no mid-run questions.

Before acting: load README/AGENTS.md + git status + hot spots; write MODE (what counts as a finding).
Findings need `path:line` evidence, tagged `delete/stdlib/native/yagni/shrink/perf/security/obs`, strength `Strong/Worth/Speculative` (Speculative = report only).
Fix in review→fix loop (max 3 rounds), tests must pass.
Banned: delete files, push --force, secrets, CI keys, prod data, any publish. Push/commit never automatic.
Report: changed / verified (tool output) / unverified / remaining. No claim without a fresh verification run.
