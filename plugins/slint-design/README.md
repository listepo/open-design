# Slint Design (OpenDesign plugin)

Agent skill + OpenDesign sidecar for **Slint** UI design with **PNG preview**.

- Upstream issue: https://github.com/nexu-io/open-design/issues/8405
- Plan (Russian): [PLAN.md](./PLAN.md)

## Install

From a checkout of this fork/branch (or after the plugin is published to a registry):

```bash
# Example: install from GitHub path (adjust to your OD install command)
od skill install github:listepo/open-design/plugins/slint-design

# Trust elevated capabilities (required for external slint-viewer MCP)
od plugin trust slint-design --capabilities prompt:inject,fs:read,fs:write,mcp,subprocess
```

### Dependencies on the machine

1. Install [`slint-viewer`](https://slint.dev) **1.17+** (prefer **1.18+**).
2. Ensure `slint-viewer` is on `PATH`.
3. Optional: `slint-lsp` for editor diagnostics.

Verify:

```bash
slint-viewer --version
slint-viewer --check plugins/slint-design/examples/hello-window.slint
```

## Usage

1. Start a run with this plugin (or ask the agent to use **Slint Design**).
2. Provide a brief (goal, size, desktop vs embedded).
3. Agent writes `.slint`, runs `--check`, then `--screenshot`.
4. Open the PNG in the OpenDesign workspace as the preview artifact.

### Manual screenshot

```bash
cd path/to/project
slint-viewer --check ui.slint
slint-viewer --screenshot ui.png --size 1280x800 ui.slint
```

## Layout

| Path | Purpose |
|------|---------|
| `SKILL.md` | Agent workflow |
| `open-design.json` | Marketplace / preview / MCP / capabilities |
| `examples/` | Minimal demo |
| `templates/` | Starting points |
| `references/workflow.md` | Detailed checklist |
| `PLAN.md` | Design plan (RU), stages S0–S4 |

## Limits (honest)

- No native `ArtifactKind: slint` in OpenDesign core (v1).
- No HTML srcDoc bridges (DOM inspector, tweak, per-element comments).
- Interactive WASM preview is **not** in S1 (see PLAN S3).

## License

MIT (plugin content). Slint itself is under its own licenses — see https://slint.dev.
