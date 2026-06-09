# AGENTS.md — caltech-letter

Context and working notes for AI agents (and humans) working on this
repository.

## What this is

`caltech-letter` is a [Quarto](https://quarto.org) **format extension**
for formal letters on Caltech letterhead — faculty recommendation
letters, external tenure-and-promotion reviews, and general
correspondence. It is the letter companion to the author's
`caltech-revealjs` slide extension and shares Caltech's visual identity.

**Goal.** Replace an Apple Pages letterhead workflow with a
Markdown/Quarto one, so letters are plain text that renders to a polished
PDF. Two design targets:

1. **Fidelity** to the author's existing Pages letterhead (logo top-left,
   "Division of the Humanities and Social Sciences" beneath it,
   right-aligned sender block, right-aligned date, bold `RE:` line). The
   original rendered letter is the visual spec. It is **not committed**
   (it names a real individual); the author keeps `Estes-2025.pdf` locally
   in the repo root as the reference.
2. **Brand compliance** with the Caltech Identity Toolkit
   (https://identity.caltech.edu): orange `#FF6C0C` (PMS 1585c), neutral
   gray `#76777B` (PMS Cool Gray 9), body in Helvetica Neue (reproduced
   with the free metric-clone TeX Gyre Heros), division name in a serif
   face (Georgia, the sanctioned free stand-in for Adobe Caslon Pro), and
   the orange wordmark — never the seal, which is reserved for
   presidential/legal use.

## How it works

A custom Quarto format extension that contributes **two** formats from a
single `_extension.yml`:

| Format | Engine | Notes |
|---|---|---|
| `caltech-letter-pdf` | XeLaTeX | The faithful reproduction. |
| `caltech-letter-typst` | Typst | Near-identical; faster, self-contained. |

Sender block, salutation, and closing default to the author's and are
overridable per letter via YAML front matter. All defaults are baked into
the templates with `$if(x)$$x$$else$default$endif$` (LaTeX) or function
defaults (Typst), so a document only needs `re:` and a body.

### XeLaTeX path

- `header.tex` — preamble loaded verbatim via `include-in-header` (fonts,
  colors, `fancyhdr` page styles, no-hyphenation). **No Pandoc template
  syntax here** (it is not templated).
- `partials/title.tex` — emptied, to suppress Quarto's default title
  block.
- `partials/before-body.tex` — draws the letterhead (header band, date,
  `RE:`, recipient, salutation) and fills the `\contheadleft` /
  `\contactfooter` macros from metadata.
- `partials/after-body.tex` — closing + signature block.

### Typst path

- `typst-template.typ` — defines the `letter()` function (the whole
  letterhead, body, closing).
- `typst-show.typ` — forwards Pandoc metadata into `letter()`.

### Logo and fonts (the fiddly bits)

- **Logo**: official vector wordmark, `caltech-logo-orange.pdf` (XeLaTeX
  embeds vector PDF) and `caltech-logo-orange.svg` (Typst can embed only
  SVG/raster, not EPS/PDF). `logo-path.lua` resolves the PDF for LaTeX via
  `quarto.utils.resolve_path`. For Typst the path is a literal in the
  function default, **not** routed through metadata, for two reasons
  (both verified): Pandoc's Typst writer escapes underscores
  (`\_extensions`) and corrupts the path, and Typst resolves a leading
  `/` against the project root, not the filesystem root.
- **Body font** TeX Gyre Heros: found by filename via kpathsea for
  XeLaTeX (the `tex-gyre` TeX Live package), and bundled in `fonts/` for
  Typst (which can't read the TeX tree). Set via `font-paths` in
  `_extension.yml`.
- **Division font** Georgia: a system font on macOS/Windows; CI installs
  `ttf-mscorefonts-installer`.

### Two layouts

`footer-contact: false` (default) puts the full sender block top-right.
`footer-contact: true` switches to Caltech's official layout: logo +
division lockup at top only, contact block centered in the page footer.
Implemented in LaTeX via the `\contactfooter` macro + `fancyhdr`, and in
Typst via a conditional `footer:` and header band.

## Build and test

```bash
# Render one sample to each engine
quarto render example.qmd --to caltech-letter-pdf
quarto render example.qmd --to caltech-letter-typst

# Clean-room check: `quarto add` into a temp project, render every sample
# to BOTH engines (8 renders). This is the authoritative test — it
# exercises logo/font path resolution from a fresh install.
bash scripts/smoke-test.sh
```

Samples: `template.qmd` (minimal), `example.qmd` (committee letter,
multipage → exercises the page-2 continuation header), `tenure-example.qmd`
(addressed recipient), `footer-example.qmd` (`footer-contact: true`).

**Visual verification**: render `example.qmd` and compare page 1 against
the author's `Estes-2025.pdf` (header band alignment, gray serif division
line, right-aligned date, bold `RE:`). Then confirm `caltech-letter-pdf`
and `caltech-letter-typst` outputs match each other.

Requirements: Quarto ≥ 1.4, XeLaTeX with `tex-gyre`/`fontspec`/`fancyhdr`/
`ragged2e`, and the Georgia font. Typst is bundled with Quarto.

## Known limitations / worth scrutinizing

- **Path assumptions**: the Typst `font-paths` and root-relative logo path
  assume rendering from the project root (the `.qmd` at the repo top
  level). Letters in subdirectories may not resolve the logo/fonts.
- **Georgia dependency**: XeLaTeX hard-errors if Georgia is absent; Typst
  falls back silently. No graceful fallback is configured.
- **`footer-contact` boolean**: relies on Pandoc/Quarto truthiness of the
  metadata flag; absent and `false` both read as off.
- **Continuation header** is always on (no toggle yet).
- **Template-partial robustness** across Quarto versions (the revealjs
  sibling hit cross-version partial issues; this uses the standard
  `before-body`/`after-body`/`title` partials, which are stable).
- **Cross-engine parity**: line breaks and vertical spacing differ
  slightly between XeLaTeX and Typst metrics.

## Conventions

This repo is Quarto/LaTeX/Typst/Lua, not R. Keep the two engines at
parity: a change to the letterhead in one engine should be mirrored in the
other. Update `CHANGELOG.md` when behavior changes; keep
`_extension.yml` versioned. Do not commit generated artifacts (PDF/TeX/
Typst output) or the reference `Estes-2025.*` files — see `.gitignore`.
