# Slint Design (OpenDesign community plugin)

Agent skill + OpenDesign sidecar for **Slint** UI design with **PNG preview**.

- Path: `plugins/community/slint-design`
- Upstream issue: https://github.com/nexu-io/open-design/issues/8405
- Plan (Russian): [PLAN.md](./PLAN.md)
- **Primary agent runtime for acceptance:** [OpenCode](https://opencode.ai) (via OpenDesign daemon). Claude Code / Cursor remain portable secondary hosts for the same `SKILL.md`.

## Install

```bash
# From this fork/branch (adjust to your OD install command)
od skill install github:listepo/open-design/plugins/community/slint-design

# Trust elevated capabilities (required for external slint-viewer / MCP)
od plugin trust slint-design --capabilities prompt:inject,fs:read,fs:write,mcp,subprocess
```

### Dependencies on the machine

1. Install [`slint-viewer`](https://slint.dev) **≥ 1.17** (prefer **1.18.1+** for `--size` and viewer MCP).
2. Ensure `slint-viewer` is on `PATH`.
3. Optional: `slint-lsp` for editor diagnostics.
4. Optional doctor: `slint-viewer --version` — if `< 1.18`, skip `--size` and use default window dimensions for screenshots.

Pin examples:

```bash
cargo install slint-viewer --version 1.18.1 --locked
# isolated (does not overwrite default PATH binary):
cargo install slint-viewer --version 1.18.1 --locked --root /tmp/slint-viewer-1.18.1
```

Verify:

```bash
slint-viewer --version
./scripts/smoke.sh
```

### OpenCode / OpenDesign

When applied inside OpenDesign, plugin MCP entries are injected for OpenCode via `OPENCODE_CONFIG_CONTENT`. Docs MCP (`https://docs.slint.dev/mcp`) is declared in `open-design.json`. Embedded `slint-viewer` MCP is **opt-in**, not a required runtime dependency.

## Usage

1. Start a run with this plugin (OpenCode under OpenDesign).
2. Provide a brief (goal, size, desktop vs embedded).
3. Agent writes `.slint`, runs `--check`, then `--screenshot` (add `--size WxH` on 1.18+).
4. Open the PNG in the OpenDesign workspace as the preview artifact.

### Manual screenshot

```bash
cd path/to/project
slint-viewer --check ui.slint
# 1.18+:
slint-viewer --screenshot ui.png --size 1280x800 ui.slint
# 1.17.x (no --size):
slint-viewer --screenshot ui.png ui.slint
```

## Layout

| Path | Purpose |
|------|---------|
| `SKILL.md` | Agent workflow |
| `open-design.json` | Marketplace / preview / MCP / capabilities |
| `examples/` | Minimal demo |
| `templates/` | Starting points |
| `references/workflow.md` | Detailed checklist |
| `scripts/smoke.sh` | Local / CI `--check` smoke |
| `preview/` | Experimental WASM HTML scaffold (S3 deferred) |
| `docs/RFC-artifact-kind-slint.md` | Draft RFC (not submitted) |
| `PLAN.md` | Design plan (RU), stages S0–S4 |

## Limits (honest)

- No native `ArtifactKind: slint` in OpenDesign core (v1).
- No HTML srcDoc bridges (DOM inspector, tweak, per-element comments).
- Interactive WASM preview is scaffold/docs only (see `preview/README.md`).

## License

MIT (plugin content). Slint itself is under its own licenses — see https://slint.dev.
