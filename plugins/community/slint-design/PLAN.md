# План: плагин OpenDesign `slint-design`

**Репозиторий-форк:** `listepo/open-design` (upstream `nexu-io/open-design`)  
**Ветка:** `feature/slint-plugin`  
**Путь:** `plugins/community/slint-design` (stub redirect: `plugins/slint-design/README.md`)  
**Связанный issue:** https://github.com/nexu-io/open-design/issues/8405  
**Статус:** S0–S1 done; S2 implemented (docs MCP + smoke); S3 scaffold/docs (WASM binary deferred); S4 RFC draft ready (not submitted). Код ядра OpenDesign не меняем. Upstream PR **не** открываем.

---

## 1. Цели

1. Дать агенту в OpenDesign воспроизводимый цикл: бриф → `.slint` → `slint-viewer --check` → `--screenshot` → PNG в workspace.
2. Объявить MCP Slint (docs + optional viewer) через `open-design.json`, чтобы агент мог уточнять справочник и (опционально) состояние UI.
3. Положить portable skill; **primary acceptance runtime = OpenCode**; Claude Code / Cursor — portable secondary.
4. Не требовать `ArtifactKind: 'slint'` и не форкать canvas (non-goals v1).

### Non-goals v1

- Нативный рендерер / новый `ArtifactKind` в ядре.
- Полный паритет с HTML srcDoc-мостами.
- Экспорт PDF/PPTX/MP4 из `.slint`.
- Обязательный WASM interactive preview (S3 scaffold only).
- Обязательный embedded Slint viewer MCP как runtime dependency (opt-in only).

---

## 2. Как вписывается в архитектуру OpenDesign

| Слой | Роль плагина |
|------|----------------|
| Plugin folder (`SKILL.md` + `open-design.json`) | Инструкции агенту + marketplace sidecar |
| `od.preview.type: image` | Показ PNG-скриншота в галерее/workspace |
| `od.context.mcp` | Docs MCP `https://docs.slint.dev/mcp`; viewer MCP — opt-in |
| `od.capabilities` | `mcp`, `subprocess`, `fs:write`, `prompt:inject` |
| Daemon / OpenCode adapter | MCP → `.mcp.json` / `OPENCODE_CONFIG_CONTENT` (`externalMcpInjection: 'opencode-env-content'`) |

Плагин **не** монтируется в canvas. Превью v1 — PNG, сгенерированный агентом/`slint-viewer`.

---

## 3. Decisions (2026-09-23)

| # | Вопрос | Решение |
|---|--------|---------|
| 1 | Plugin location | **`plugins/community/slint-design`**. Старый путь `plugins/slint-design` — stub README redirect. |
| 2 | Primary runtime | **OpenCode** (primary for acceptance, examples, smoke notes, `OPENCODE_CONFIG_CONTENT`). Claude Code / Cursor — portable secondary via same `SKILL.md`. |
| 3 | WASM in v1? | **No.** PNG is v1 default. S3 = HTML scaffold + docs only; full `slint-wasm-interpreter` binary deferred (heavy build, `publish=false` upstream). |
| 4 | slint-viewer versioning | See §5.1. **Min:** 1.17 (`--check`, `--screenshot`). **Recommended pin:** **1.18.1** (`--size`, viewer `mcp` feature). Local Mac had 1.17.1 (no `--size`). |
| 5 | Figma→Slint | **Separate skill later**; out of scope here. |
| 6 | ArtifactKind stance | Maintainer (lefarcen on #8405): needs direction before core work; community path OK; screenshot + `--check` lower-risk; embedded MCP opt-in. **S4 = RFC draft only, not filed/submitted.** |

**S0:** done (this section).

---

## 4. Этапы S0–S4

### S0 — согласование — **DONE**
- Decisions выше; UX A = PNG; WASM deferred.

### S1 — MVP — **DONE** (on branch)
- `SKILL.md`, `open-design.json`, `README.md`, examples, templates.

### S2 — DX — **DONE** (this pass)
- Docs MCP `https://docs.slint.dev/mcp` in manifest (verified: HTTP 405 Allow POST/OPTIONS — MCP endpoint alive).
- Local + CI smoke: `scripts/smoke.sh` + `.github/workflows/slint-design-smoke.yml`.
- Multi-size screenshots documented in `references/workflow.md` (graceful if `--size` missing).

### S3 — optional WASM — **scaffold/docs DONE; binary DEFERRED**
- `preview/` HTML shell + README explaining sandboxed iframe approach.
- Full wasm-pack build of `slint-wasm-interpreter` deferred (cost/license/CI weight).

### S4 — RFC ядра — **draft READY, NOT submitted**
- `docs/RFC-artifact-kind-slint.md` (English DRAFT). Do not open upstream PR / do not file as official RFC yet.

---

## 5. Структура файлов

```
plugins/community/slint-design/
├── PLAN.md
├── README.md
├── SKILL.md
├── open-design.json
├── examples/
├── templates/
├── references/workflow.md
├── scripts/smoke.sh
├── preview/                 # S3 scaffold (experimental)
│   ├── index.html
│   └── README.md
└── docs/
    └── RFC-artifact-kind-slint.md
```

Stub: `plugins/slint-design/README.md` → points here.

---

## 5.1 slint-viewer versioning (tested / documented 2026-09-23)

| Version | Source | `--check` | `--screenshot` | `--size` | viewer MCP feature |
|---------|--------|-----------|----------------|----------|--------------------|
| **1.17.0** | changelog | yes (added) | yes (added) | no | runtime MCP elsewhere; not viewer feature |
| **1.17.1** | installed on Mac (`~/.local/bin`) | **OK** (tested) | **OK** (tested; default window size e.g. 480×320 for hello) | **missing** (CLI error) | not in viewer Cargo feature |
| **1.18.0** | changelog | yes | yes | **added** | **added** (`mcp` Cargo feature) |
| **1.18.1** | GitHub latest stable; tested via `cargo install --root /tmp/slint-viewer-1181` (2026-09-23) | **OK** | **OK** | **OK** (1280×800 + 390×844) | crates.io default binary: MCP feature may need `--features mcp` at install; treat as opt-in |

**Recommendation**

- **Minimum supported:** `slint-viewer` **≥ 1.17.0** (enough for check + PNG smoke).
- **Recommended pin:** **1.18.1** (or latest 1.18.x) for `--size` multi-viewport screenshots and optional viewer MCP.
- **Install / pin:**
  - `cargo install slint-viewer --version 1.18.1 --locked`
  - or isolated: `cargo install slint-viewer --version 1.18.1 --locked --root /tmp/slint-viewer-1.18.1`
  - or `mise` tool pin if/when a mise backend is configured for the binary.
- **Doctor note:** agents should run `slint-viewer --version` and, if `< 1.18`, skip `--size` / document default window size; do not fail the whole run.
- **CI:** workflow installs a pinned 1.18.x (or uses `cargo install`) and runs `scripts/smoke.sh`.

Embedded Slint MCP remains **opt-in** (not required for apply/smoke).

---

## 6. OpenCode notes (primary runtime)

- OD daemon injects plugin MCP into OpenCode via `OPENCODE_CONFIG_CONTENT` (`externalMcpInjection: 'opencode-env-content'`).
- Acceptance / examples assume agent = **OpenCode** under OpenDesign.
- Same `SKILL.md` remains usable in Claude Code / Cursor as a portable skill without OD sidecar.

---

## 7. Acceptance criteria

### S1
- [x] Manifest + SKILL + example + ≥1 template under `plugins/community/slint-design/`.
- [x] `preview.type: image`, elevated caps listed.
- [x] Check → screenshot cycle documented.
- [x] Core OpenDesign untouched (plugin + workflow + stub only).

### S2
- [x] Docs MCP URL in `open-design.json`.
- [x] `scripts/smoke.sh` + GHA workflow.
- [x] Multi-size screenshot docs + graceful fallback.

### S3 / S4
- [x] Preview scaffold marked experimental/deferred.
- [x] RFC draft present; **not** submitted upstream.

---

## 8. Доверие / capabilities

```text
od plugin trust slint-design --capabilities prompt:inject,fs:write,mcp,subprocess
```

`subprocess` нужен для внешнего `slint-viewer` (и optional viewer MCP), не built-in OD tool.
