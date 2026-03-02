# Headless Godot Skill Kit

English | [日本語](README_ja.md)

An agent skill kit for developing Godot games without opening the Godot editor. It combines an AI coding agent with headless Godot to automate scene editing, tests, and exports so you can validate builds (e.g. Web export) in a browser.

## Prerequisites

- Godot 4.2+ (check with `godot --version`)
- For Web export: install Godot Export Templates (see the official docs)

## Install

Copy `.agents/` into the root of your target Godot project.

```bash
cp -r /path/to/headless-godot-skill-kit/.agents /path/to/your-project/
```

After that, tell the agent what you want to build or change. It can run scene edits, tests, and exports end-to-end. You can validate the exported Web build by opening `build/web/index.html` in a browser.

**Note:** This skill provides rules and reference material, but does not automatically define the agent's workflow. To have the agent run the full pipeline (patch → test → Web export) without manual prompting each time, add workflow instructions to your project's `AGENTS.md`. For example:

```markdown
## Workflow

After every change, run the full pipeline:
1. Apply patch via `godot_apply_patch.gd`
2. Smoke run (headless, ~5 s)
3. Logic tests (`--script res://tools/tests/run_tests.gd`)
4. Web export (`--export-release "Web" build/web/index.html`)
```

You can also manually tweak the scene build scripts, test cases, and patch definitions the agent generates, then re-run the pipeline via `tools/rebuild_web.sh`.

## Troubleshooting

### XDG Environment Variables

If your environment (sandbox, CI, etc.) cannot use `~/.local` or `~/.cache`, set `XDG_DATA_HOME` and related variables to a path inside the project directory. Details are in the skill's `export_and_import.md`.

Recommended baseline for any headless command (not only export):

```bash
mkdir -p <PROJECT_DIR>/.tmp-godot-data <PROJECT_DIR>/.tmp-godot-config <PROJECT_DIR>/.tmp-godot-cache
XDG_DATA_HOME=<PROJECT_DIR>/.tmp-godot-data \
XDG_CONFIG_HOME=<PROJECT_DIR>/.tmp-godot-config \
XDG_CACHE_HOME=<PROJECT_DIR>/.tmp-godot-cache \
godot --headless --path <PROJECT_DIR> ...
```

### Export Templates Path

If you change `XDG_DATA_HOME`, the Export Templates lookup path changes as well. You can pin it by setting absolute paths in `export_presets.cfg` under `custom_template/debug` and `custom_template/release`.

### "TCP listen" Warnings

You may see TCP listen warnings when running headless. If export succeeds and `index.html` / `index.pck` / `index.wasm` are generated, these can safely be ignored.

### "RID/Object leak" Warnings (`--script`)

When building/saving scenes via `--script`, Godot may print RID/Object leak warnings on exit.
If the process exits with code `0` and expected outputs are present, treat this as a known warning.
If exit code is non-zero or outputs are missing, treat it as failure.

### "Patch applier script not found"

If `res://tools/godot_apply_patch.gd` cannot be found, restore it in the project and retry.

```bash
mkdir -p /path/to/your-project/tools
cp /path/to/your-project/.agents/skills/headless-godot/tools/godot_apply_patch.gd /path/to/your-project/tools/godot_apply_patch.gd
```

Patch commands assume `res://tools/godot_apply_patch.gd` and use an absolute path or `res://` for `<PATCH_JSON_PATH>`.

---

## Technical Notes

This section is for readers who want to understand how the skill works internally.

### Agent Workflow

The agent typically runs this loop:

```text
Create patch.json
  ↓
Pre-validate with --dry-run (NodePath resolution / type checks)
  ↓
Apply via godot_apply_patch.gd to update .tscn
  ↓
Smoke run (headless, ~5s) to catch broken references or script errors
  ↓
Logic tests (--script res://tools/tests/run_tests.gd)
  ↓
Web export
```

- Never edit `.tscn` as raw text; use JSON patches and apply them via Godot APIs.
- All command output is saved under `logs/` for debugging.

### Repository Layout

```text
.agents/skills/headless-godot/
  ├── SKILL.md                        # Skill definition (agent entry point)
  ├── skills/
  │   ├── headless_cli.md             # CLI conventions (--path, --headless, log capture)
  │   ├── scene_editing_via_godot.md  # Scene editing rules (patch flow, safety)
  │   ├── testing_headless.md         # Testing strategy (smoke + logic tests)
  │   └── export_and_import.md        # Export conventions
  └── tools/
      ├── godot_apply_patch.gd        # Patch applier script
      └── templates/
          └── run_tests.gd            # Test script template
```

## References

- [Godot CLI tutorial](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)
- [Godot export docs](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html)
