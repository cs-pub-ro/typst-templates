# typst-templates

[Typst](https://typst.app/) templates for academic work at the **Faculty of
Automatic Control and Computer Science**, NUST POLITEHNICA Bucharest: bachelor
thesis, master's dissertation, PhD thesis, and the defense presentation.

The thesis document supports two languages (`ro` / `en`) and three departments
(`cti`, `acse`, `aii`), all configured from a single file: `thesis/config.typ`.

## Quick start

```bash
git clone https://github.com/cs-pub-ro/typst-templates
cd typst-templates
make install      # install Typst + fonts (apt/brew)
make thesis       # -> build/thesis.pdf
make presentation # -> build/presentation.pdf
```

## Commands (Makefile)

`make` orchestrates everything; run `make help` for the full list.

| Command              | Effect                                                  |
| -------------------- | ------------------------------------------------------- |
| `make install`       | Install Typst + Liberation fonts (auto-detects the OS)  |
| `make thesis`        | Compile the thesis → `build/thesis.pdf`                 |
| `make presentation`  | Compile the presentation → `build/presentation.pdf`     |
| `make pdf`           | Compile both PDFs                                        |
| `make check`         | Verification suite: thesis + presentation               |
| `make clean`         | Remove `build/`                                          |

You can override the configuration straight from the command line, without
editing `config.typ`:

```bash
make thesis THESIS_LANG=ro TYPE=master DEPT=acse
```

## Requirements

- **Typst** `>= 0.13` (`make install` installs it; otherwise see
  [installation](https://github.com/typst/typst#installation)).
- **Fonts**: the template requests `Times New Roman` and `Courier New`. As these
  are proprietary, we recommend the free **Liberation** family
  (metric-compatible), also installed by `make install`. See
  [Troubleshooting](#troubleshooting).
- **VS Code** + the **Tinymist** extension (`myriad-dreamin.tinymist`) —
  recommended for live preview.
- **Docker / Dev Containers** — optional, for a reproducible environment.

## Configuration — `thesis/config.typ`

| Variable        | Values / example                       |
| --------------- | -------------------------------------- |
| `thesis_type`   | `"bachelor"` \| `"master"` \| `"phd"`  |
| `department`    | `"cti"` \| `"acse"` \| `"aii"`         |
| `language`      | `"ro"` \| `"en"`                       |
| `thesis_title`  | thesis title                           |
| `supervisor`    | scientific supervisor                  |
| `student`       | author                                 |
| `year`          | year of defense                        |

Each variable can also be overridden at compile time with `--input key=value`
(the mechanism used by `make ... THESIS_LANG=...`).

## Folder structure

```text
typst-templates/
├── Makefile                # commands: install / build / check / clean
├── .devcontainer/          # reproducible Docker + Nix environment
├── logos/                  # university / faculty / department logos
├── scripts/                # scripts invoked by the Makefile
└── thesis/
    ├── config.typ          # configuration + localization (i18n)
    ├── prelude.typ         # central import point
    ├── main.typ            # the thesis document
    ├── presentation.typ    # the presentation (Touying)
    ├── refs.bib            # bibliography (BibTeX)
    └── chapters/           # thesis chapters (+ appendices/)
```

## Writing the chapters

Each chapter is a file under `thesis/chapters/`, included from `main.typ`. At the
top it has a **writing guide** that is rendered in the PDF so you can read it
while you draft. Each guide opens with a reminder to delete it before submission
— replace the guide text with your own content.

Chapters and sections are **numbered automatically** — do not add `1.`, `1.1`
manually. Use `==` for sections (→ 1.1) and `===` for subsections (→ 1.1.1).

## Figures, tables, code, and references

```typ
// Figure (caption below the image)
#figure(image("../logos/nustpb/PB_logo_ro.svg", width: 6cm), caption: [Description])

// Table (caption above)
#figure(table(columns: 2, table.header([*A*], [*B*]), [1], [2]), caption: [Description])
```

For code, use ` ```language ` fenced blocks. For references, add the entry to
`thesis/refs.bib` and cite it in the text with `@key`; the bibliography (IEEE
style) is generated automatically at the end.

## Devcontainer

The repository includes a Dev Container that installs Typst (via Nix) and the
fonts, for a reproducible build. In VS Code: *Reopen in Container*, then
`make check`. From the CLI: `devcontainer up --workspace-folder .`.

For a fully deterministic build, the pinned dependency versions are captured in
`.devcontainer/flake.lock` (generated with `cd .devcontainer && nix flake lock`
and committed to the repository).

## Troubleshooting

- **`unknown font family: times new roman / courier new`** — run `make install`,
  install `fonts-liberation` manually, or use
  `typst compile --font-path /path/to/fonts ...`.
- **`failed to load file (access denied)`** — missing `--root .` (the Makefile
  adds it automatically).
- **`failed to download package (...touying...)`** — the first presentation
  build needs network; packages are then kept in the cache
  (`~/.cache/typst/packages/`).
- **`image contains foreign object`** — harmless warning from the SVG logos.

## Contributing

Create a branch (`git checkout -b fix/...`), run `make check` before committing,
and open a Pull Request describing *what* and *why*. For bugs, open an *issue*
with reproduction steps, the Typst version, and your OS.

## License

See [`LICENSE`](LICENSE).
