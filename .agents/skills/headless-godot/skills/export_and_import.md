# Export And Import

Minimal rules:
- Use `--export-release` / `--export-debug` / `--export-pack` based on your goal
- `--export-*` is only available in the **editor build** (not in export template binaries)
- Treat `--export-*` as implicitly including `--import`
- If the output path is relative, assume it resolves from **`project.godot` (= project root)**
- For `--export-pack`, the output format is determined by extension (`.pck` or `.zip`)

Prerequisites (minimal):
- `export_presets.cfg` exists
- Export templates are installed

## Web Export

Command:
```bash
godot --headless --path <PROJECT_DIR> \
  --export-release "Web" build/web/index.html
```

`export_presets.cfg` example:
```ini
[preset.0]
exclude_filter="build/web/*"

[preset.0.options]
custom_template/debug="/home/alice/.local/share/godot/export_templates/4.6.1.stable/web_nothreads_debug.zip"
custom_template/release="/home/alice/.local/share/godot/export_templates/4.6.1.stable/web_nothreads_release.zip"
```

- `exclude_filter`: prevents previously generated outputs from being re-included in the next export
- `custom_template/*`: pins absolute paths to Export Templates (required if you switch XDG directories)

### Switching XDG Environment Variables

For XDG wrapper setup, see `headless_cli.md`. Additional export-specific notes:

- If you change `XDG_DATA_HOME`, the Export Templates lookup path also changes to `XDG_DATA_HOME/godot/export_templates/...`
- To keep using an existing `~/.local/share/godot/export_templates/`, set absolute paths under `custom_template/*` in `export_presets.cfg`

### Known Warnings

You may see `TCP listen` warnings in headless runs. If `build/web/index.html` / `index.pck` / `index.wasm` are generated, it is usually fine.
