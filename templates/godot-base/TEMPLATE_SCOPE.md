# Template Scope

`templates/godot-base/` is an infrastructure skeleton for new headless Godot projects.
It should provide the minimum project shape needed for scene startup, automated tests,
Web export, and agent-friendly replacement.

## Allowed

- Minimal project settings and export defaults
- A replaceable `main.tscn` / `main.gd` root
- Generic test-hook interfaces in `main.gd`
- Generic metric helpers that do not require a particular game objective
- Low-level audio primitives (`sine/square/triangle/noise`, envelope)
- Headless/test/export infrastructure

## Avoid

- Default game mechanics, objectives, scoring, win/loss rules, or entity behavior
- Art direction, HUD copy, animation language, or effect style
- Gameplay-specific sound names or event SFX
- Pre-bundled font assets or font license payloads
- Domain-specific control names or entity names in base interfaces
- Game-specific simulation policies, exploratory input patterns, or quality thresholds

## Implementation Note

When creating a game from this template, replace the stub root with game-specific
mechanics, visuals, audio, metrics, and tests. Keep reusable infrastructure generic.
