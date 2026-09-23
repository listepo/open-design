# План: плагин OpenDesign `slint-design`

**Репозиторий-форк:** `listepo/open-design` (upstream `nexu-io/open-design`)  
**Ветка:** `feature/slint-plugin`  
**Связанный issue:** https://github.com/nexu-io/open-design/issues/8405  
**Статус:** scaffold варианта A (skill + MCP + PNG-превью). Код ядра OpenDesign не меняем.

---

## 1. Цели

1. Дать агенту в OpenDesign воспроизводимый цикл: бриф → `.slint` → `slint-viewer --check` → `--screenshot` → PNG в workspace.
2. Объявить MCP Slint (inspect/click/screenshot) через `open-design.json`, чтобы агент мог уточнять состояние UI без DOM-мостов HTML.
3. Положить portable skill, совместимый с Claude Code / Cursor / opencode вне OpenDesign.
4. Не требовать `ArtifactKind: 'slint'` и не форкать canvas (non-goals v1).

### Non-goals v1

- Нативный рендерер / новый `ArtifactKind` в ядре.
- Полный паритет с HTML srcDoc-мостами (инспектор DOM, tweak, комментарии по элементу).
- Экспорт PDF/PPTX/MP4 из `.slint`.
- Обязательный WASM interactive preview (это этап S3).

---

## 2. Как вписывается в архитектуру OpenDesign

| Слой | Роль плагина |
|------|----------------|
| Plugin folder (`SKILL.md` + `open-design.json`) | Инструкции агенту + marketplace sidecar |
| `od.preview.type: image` | Показ PNG-скриншота в галерее/workspace |
| `od.context.mcp` | `slint-viewer` (feature mcp) и/или docs MCP |
| `od.capabilities` | `mcp`, `subprocess`, `fs:write`, `prompt:inject` |
| Daemon / runtime agent | Не меняем; агент получает MCP через apply/trust |

Плагин **не** монтируется в canvas (спека plugins). Превью — артефакт-изображение, сгенерированное агентом.

---

## 3. Этапы S0–S4

### S0 — согласование
- Подтвердить UX: **A = PNG** (этот scaffold) vs **B = WASM** позже.
- Зафиксировать non-goals v1 (см. выше).

### S1 — MVP (этот PR-готовность ветки)
- `SKILL.md`, `open-design.json`, `README.md`
- `examples/hello-window.slint` (+ опционально `hello-window.png`)
- `templates/desktop-window`, `templates/settings-form`
- Документировать зависимости: `slint-viewer` ≥ 1.17 (лучше 1.18+), опционально `slint-lsp`

### S2 — DX
- Docs MCP `https://docs.slint.dev/mcp`
- CI smoke: `--check` на examples/templates
- Вторые размеры скриншота (desktop/mobile) в workflow

### S3 — optional WASM
- HTML shell + `slint-wasm-interpreter` в sandboxed iframe
- Без DOM-мостов OD

### S4 — RFC ядра
- Только при доказанном спросе: `ArtifactKind: 'slint'` / first-class preview

---

## 4. Структура файлов

```
plugins/slint-design/
├── PLAN.md                 # этот документ (RU)
├── README.md               # install + usage (EN для OD/agents; кратко)
├── SKILL.md                # agent workflow
├── open-design.json        # OD sidecar
├── examples/
│   └── hello-window.slint
├── templates/
│   ├── desktop-window/
│   │   ├── README.md
│   │   └── ui.slint
│   └── settings-form/
│       ├── README.md
│       └── ui.slint
└── references/
    └── workflow.md         # детальный чеклист для агента
```

---

## 5. Зависимости

| Инструмент | Зачем | Минимум |
|------------|-------|---------|
| `slint-viewer` | `--check`, `--screenshot`, `--size`, MCP feature | 1.17 (MCP/screenshot), 1.18 (`--size`, viewer mcp) |
| `slint-lsp` (опц.) | диагностика в редакторе агента | любая актуальная |
| Docs MCP (S2) | справочник языка | URL docs.slint.dev/mcp |

Установка viewer: см. https://slint.dev (cargo/`slint-viewer`, пакеты дистрибутива, mise).  
Плагин предполагает, что `slint-viewer` есть в `PATH` на машине пользователя OpenDesign.

---

## 6. Открытые вопросы

1. Публикация: `plugins/community/slint-design`, registry, или внешний `github:listepo/...`?
2. Primary runtime для приёмки: opencode / Claude Code / Cursor?
3. Нужен ли WASM preview в первом user-facing релизе?
4. Как pin'ить версию `slint-viewer` (`plugin doctor`, mise tool)?
5. Figma→Slint — тот же плагин или отдельный skill?
6. Позиция maintainers upstream по будущему `ArtifactKind`?

---

## 7. Acceptance criteria (S1)

- [ ] Папка `plugins/slint-design/` содержит манифест + SKILL + example + ≥1 template.
- [ ] `open-design.json` валиден относительно schema v1 (`preview.type: image`, `context.mcp`, elevated caps перечислены).
- [ ] По `SKILL.md` агент может без уточнений пройти цикл check → screenshot.
- [ ] `slint-viewer --check` на `examples/hello-window.slint` и templates проходит локально (если viewer установлен).
- [ ] README описывает install/trust capabilities и ограничения vs HTML.
- [ ] Ядро OpenDesign не изменено; ветка только добавляет плагин.

---

## 8. Доверие / capabilities

Для apply в restricted-режиме оператор должен выдать минимум:

```text
od plugin trust slint-design --capabilities prompt:inject,fs:write,mcp,subprocess
```

`subprocess` нужен, потому что MCP-команда — внешний `slint-viewer`, не built-in OD tool.
