---
name: slint-design
description: >-
  Use this plugin when the user wants native or embedded UI in Slint (.slint):
  desktop windows, forms, settings panels, tool UIs, or agent-driven Slint
  iteration with check + PNG screenshot preview inside OpenDesign.
license: MIT
metadata:
  author: listepo
  version: "0.1.0"
od:
  mode: prototype
  platform: desktop
  scenario: native-ui
---

# Slint Design

Design and iterate **Slint** UIs for OpenDesign. Preview is a **PNG screenshot**
(variant A), not an HTML canvas mount.

## Prerequisites

- `slint-viewer` on `PATH` (1.17+; 1.18+ preferred for `--size` and viewer MCP).
- Optional: `slint-lsp` for editor diagnostics.

## Workflow

1. **Brief** — clarify platform (desktop/embedded), window size, primary actions,
   light/dark, copy language, and constraints (no web-only widgets).
2. **Write** — create or update `ui.slint` (or the path the user named). Prefer
   templates under `templates/desktop-window` or `templates/settings-form`.
3. **Check** — run diagnostics without a window:

   ```bash
   slint-viewer --check path/to/ui.slint
   ```

   Fix compile/diagnostics errors before screenshotting.
4. **Screenshot** — render PNG for OpenDesign image preview:

   ```bash
   slint-viewer --screenshot ui.png --size 1280x800 path/to/ui.slint
   ```

   Optional second size for compact layouts: `--size 390x844`.
5. **Report** — summarize structure, states covered, file paths (`ui.slint`,
   `ui.png`), and remaining risks. If MCP is available, use inspect/click +
   `take_screenshot` for interactive states instead of guessing.
6. **Iterate** — on feedback, edit `.slint`, re-check, re-screenshot, overwrite
   or version PNGs clearly (`ui-v2.png`).

## Output contract

- Source: one or more `.slint` files in the project workspace.
- Preview artifact: PNG (and optional JPG) produced by `slint-viewer --screenshot`.
- Short `notes.md` only if the user asked for a written handoff.

## Do not

- Do not invent a new OpenDesign `ArtifactKind`.
- Do not promise HTML srcDoc bridges (element inspector, tweak, per-node comments).
- Do not skip `--check` when the viewer is installed.
- Do not block on WASM interactive preview (optional later stage).

## References

Load `references/workflow.md` for the detailed checklist and MCP notes.
