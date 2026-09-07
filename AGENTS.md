# pit-stop — agent instructions

This repo IS a skill under construction. Rules for working in it:

- SKILL.md core stays under 500 words. Details go to `references/`, never inline bloat.
- Frontmatter: `name` + `description` (triggers only, never workflow summary) +
  `argument-hint` + `allowed-tools`. SDO: description answers "should I load this now?".
- Prose constrains; hooks enforce. Anything mechanical gets a script, not a paragraph.
- No narrative logs in docs. Lessons, not stories. One rule per bullet.
- Test before claiming: every behavior claim about this skill needs a real run behind it.
- English-first in skill + README; zh-CN mirrors meaning, not words.
- Commit messages: conventional prefix + English body. No Chinese, no attribution/credit wording.
