# Detailed agent checklist

1. Confirm `slint-viewer` is available (`slint-viewer --version`).
2. Copy a template if useful (`templates/desktop-window/ui.slint` or `settings-form`).
3. Implement the brief in `.slint` with named components and clear properties.
4. `slint-viewer --check <file>` until exit 0.
5. `slint-viewer --screenshot <out.png> --size <WxH> <file>`.
6. If MCP connected: `get_element_tree` / `click_element` / `take_screenshot` for states.
7. Hand paths of `.slint` + PNG back to the user; note gaps vs HTML preview bridges.

## MCP notes

Manifest declares a `slint-viewer` MCP entry. Exact CLI flags for MCP mode depend on
the installed Slint version (1.18+ viewer `mcp` feature). If the server fails to
start, continue with check/screenshot CLI only and report the MCP error.
