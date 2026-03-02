# Testing Headless

Scope (only this):
- Logic, resource loading, and minimal scene startup
- Rendering-dependent checks, render output validation, and input/window operations are out of scope

Minimal strategy:
- Keep `res://tools/tests/run_tests.gd` in the project and run it via `--script`
- Treat `res://tools/tests/run_tests.gd` as an agent-maintained project file (not bundled in this skill)
- You can bootstrap from `tools/templates/run_tests.gd` in this skill and copy it into the project
- `quit(1)` on failed `assert` / exceptions; `quit(0)` on success
- After applying patches, add a smoke run that actually starts `run/main_scene` (to catch `_ready` errors)

For known script warnings (RID/Object leak, etc.), see `headless_cli.md`.

Startup smoke (minimal):
```bash
mkdir -p logs && timeout 5s godot --headless --path <PROJECT_DIR> 2>&1 | tee logs/smoke_main.log
```
- Treat `Node not found` and script errors as failures
- After patches, add checks for important node counts (e.g., verify expected singleton nodes exist exactly once)

Required:
- Scripts run via `--script` must extend `SceneTree` or `MainLoop` (Godot 4)

Optional:
- You may use external test frameworks (GUT, etc.), but this skill does not document those workflows.
