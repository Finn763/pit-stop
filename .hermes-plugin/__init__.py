"""Register the pit-stop skill with Hermes' native skill loader.

Without this module Hermes discovers `.hermes-plugin/plugin.yaml` but fails to
load the plugin ("No __init__.py"), so the skill never registers. Verified with
`hermes plugins doctor . --ci`.
"""
import os
from pathlib import Path


def _skill_md() -> Path:
    """Locate skills/pit-stop/SKILL.md for both supported install layouts.

    - git-clone install (`hermes plugins install Finn763/pit-stop`): the plugin
      dir is the repo root, so `.hermes-plugin/` and `skills/` are siblings.
    - flattened install (plugin files copied to the plugin dir root): `skills/`
      sits next to this module.
    """
    here = os.path.dirname(os.path.realpath(__file__))
    for cand in (os.path.join(here, "..", "skills", "pit-stop"),
                 os.path.join(here, "skills", "pit-stop")):
        skill_md = os.path.join(cand, "SKILL.md")
        if os.path.isfile(skill_md):
            return Path(skill_md)
    raise RuntimeError(
        "pit-stop plugin: cannot find skills/pit-stop/SKILL.md. Reinstall so "
        "that .hermes-plugin/ and skills/ sit in the same plugin directory."
    )


def register(ctx):
    ctx.register_skill("pit-stop", _skill_md())
