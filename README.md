# Caltech Letter

A [Quarto](https://quarto.org/) format extension for formal letters —
recommendations, external tenure-and-promotion reviews, and general
correspondence — on Caltech letterhead. It reproduces the Pages
letterhead in plain Markdown: the orange Caltech wordmark and
"Division of the Humanities and Social Sciences" line on the left, a
right-aligned sender block and date, a bold `RE:` line, and a
closing/signature block.

It renders to PDF through two engines:

| Format | Engine | Notes |
|---|---|---|
| `caltech-letter-pdf` | XeLaTeX | Default. Reproduces the original look exactly. |
| `caltech-letter-typst` | Typst | Fast, self-contained; near-identical output. |

This is the letter companion to
[`jnkatz/caltech-revealjs`](https://github.com/jnkatz/caltech-revealjs)
and shares its visual identity (orange `#FF6C0C`).

## Installation

```bash
quarto add jnkatz/caltech-letter
```

This installs the extension into `_extensions/jnkatz/caltech-letter/`
in your project. A local development checkout may instead use
`_extensions/caltech-letter/`; both layouts are supported.

## Usage

A complete recommendation letter is just front matter plus the body:

```yaml
---
format: caltech-letter-pdf
re: "Jordan A. Doe"
date: today
---

It is my pleasure to write this letter on behalf of Jordan Doe...
```

The salutation defaults to "Dear Members of the Search Committee:" and
the entire sender block defaults to Jonathan N. Katz's. Render it:

```bash
quarto render letter.qmd
```

To use the Typst engine instead, change the format to
`caltech-letter-typst` (or pass `--to caltech-letter-typst`).

### External tenure & promotion letters

These are usually addressed to a named recipient. Add the `recipient`
and `recipient-address` fields and override the salutation:

```yaml
---
format: caltech-letter-pdf
re: "Promotion of Dr. Alex Q. Researcher to Full Professor"
date: "June 8, 2026"
recipient: "Professor Dana Lee, Chair"
recipient-address:
  - "Department of Political Science"
  - "University of Somewhere"
  - "Somewhere, ST 00000"
salutation: "Dear Professor Lee:"
---

Thank you for inviting me to evaluate Dr. Researcher's case...
```

See `template.qmd` (search-committee form) and `tenure-example.qmd`
(addressed form) for starting points.

## Front-matter fields

Every field is optional; omitted fields fall back to the defaults shown.

| Field | Default | Purpose |
|---|---|---|
| `re` | *(none)* | Bold `RE:` subject line. Omit to skip it. |
| `date` | today | Letter date. Use `today` or a literal string. |
| `salutation` | Dear Members of the Search Committee: | Greeting line. |
| `recipient` | *(none)* | Addressed recipient (first line of the address block). |
| `recipient-address` | *(none)* | List of recipient address lines. |
| `closing` | Sincerely, | Closing word/phrase. |
| `signature-name` | = `sender-name` | Typed name under the signature space. |
| `signature-title` | = `sender-title` | Typed title under the name. |
| `sender-name` | Jonathan N. Katz | Top-right block, line 1. |
| `sender-title` | Kay Sugahara Professor… | Top-right block, line 2. |
| `sender-address` | 1200 East California Blvd. / MC 228-77 / Pasadena, CA 91125 | List of address lines. |
| `sender-phone` | (626) 395-4191 | |
| `sender-email` | jkatz@caltech.edu | |
| `department` | Division of the Humanities and Social Sciences | Serif line under the logo. |
| `footer-contact` | false | `true` switches to the official footer layout. |

The date is formatted as `MMMM D, YYYY` (e.g. "October 20, 2025").

### Two layouts

By default the full sender block sits in the **top-right** corner,
matching the established Pages letterhead. Setting `footer-contact: true`
switches to Caltech's **official letterhead layout**: the top of the page
shows only the logo paired with the division name, and the contact
details (address, phone, email) move to a centered block at the foot of
every page. See `footer-example.qmd`.

A continuation header ("RE: … / date / Page N") appears automatically
on page 2 and later; page 1 has none.

## Fonts and colors

These follow the [Caltech Identity Toolkit](https://identity.caltech.edu):

- **Body** — **TeX Gyre Heros**, a free Helvetica-metric face. Caltech's
  official primary sans-serif is Helvetica Neue; Heros reproduces it and
  is portable. XeLaTeX loads it from your TeX installation (the `tex-gyre`
  package); Typst uses the copies bundled in
  `_extensions/caltech-letter/fonts/`.
- **Division/department line** — **Georgia** (serif), the sanctioned free
  alternative to Adobe Caslon Pro, per Caltech's lockup standard. Georgia
  is a system font on macOS and Windows.
- **Colors** — Caltech orange `#FF6C0C` (PMS 1585c) and neutral gray
  `#76777B` (PMS Cool Gray 9).

To use a different body font under XeLaTeX, edit the `\setmainfont` block
in `_extensions/caltech-letter/header.tex`; under Typst, change the
`set text(font: …)` line in `typst-template.typ`.

## What's included

```
_extensions/caltech-letter/
├── _extension.yml              # contributes the pdf + typst formats
├── header.tex                  # XeLaTeX preamble (fonts, colors, fancyhdr)
├── partials/
│   ├── title.tex               # emptied → suppresses the default title block
│   ├── before-body.tex         # the letterhead (band, date, RE, salutation)
│   └── after-body.tex          # closing + signature block
├── typst-template.typ          # the Typst `letter` function (letterhead)
├── typst-show.typ              # forwards metadata into letter()
├── logo-path.lua               # resolves the logo per engine
├── caltech-logo-orange.pdf     # official vector wordmark (XeLaTeX)
├── caltech-logo-orange.svg     # official vector wordmark (Typst)
└── fonts/                      # TeX Gyre Heros (for Typst)
```

## Smoke tests

`scripts/smoke-test.sh` installs the extension into a temporary project
with `quarto add` and renders every sample letter to both formats —
verifying logo and font resolution from a clean install:

```bash
bash scripts/smoke-test.sh
```

The same check runs in GitHub Actions on pushes and pull requests.

## Requirements

- Quarto >= 1.4.0
- The **Georgia** font, for the division/department line (a system font
  on macOS and Windows; on Linux install `ttf-mscorefonts-installer`).
- For `caltech-letter-pdf`: a TeX installation with XeLaTeX and the
  `tex-gyre`, `fontspec`, `fancyhdr`, and `ragged2e` packages (all
  standard; Quarto's TinyTeX can install them).
- For `caltech-letter-typst`: nothing beyond Quarto and Georgia.

## License

MIT (see `LICENSE`). The Caltech wordmark is a trademark of the
California Institute of Technology.
