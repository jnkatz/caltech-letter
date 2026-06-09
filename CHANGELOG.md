# Changelog

## Unreleased

- Fixed Typst font resolution for letters rendered from subdirectories by
  making the bundled TeX Gyre Heros font path project-root-relative.
- Made omitted dates behave consistently across engines: Typst now shows
  today's date by default, and LaTeX continuation headers include the
  default date when no `date` field is supplied.
- Kept closing/signature blocks together in both engines so the closing
  phrase is not orphaned from the typed signature across a page break.
- Tuned first-page spacing and the LaTeX sender block width to better
  match the Pages reference letterhead and avoid wrapping the default
  sender title.
- Corrected the README's Caltech orange value to `#FF6C0C`.
- Expanded the smoke test to cover no-date letters, subdirectory renders,
  and a long letter that exercises closing/signature pagination.

## 0.1.0

Initial release.

- Quarto format extension `caltech-letter` contributing two formats:
  - `caltech-letter-pdf` (XeLaTeX)
  - `caltech-letter-typst` (Typst)
- Caltech letterhead matching the Pages original: orange wordmark and
  "Division of the Humanities and Social Sciences" subtitle (left),
  right-aligned sender block, right-aligned date, bold `RE:` line, and a
  closing/signature block.
- Sender block, salutation, and closing default to Jonathan N. Katz's
  and are overridable per letter via front matter.
- Optional addressed-recipient block (`recipient`, `recipient-address`)
  for external tenure-and-promotion letters.
- Two layouts: the default top-right sender block (matching the
  established Pages letterhead), and `footer-contact: true` for Caltech's
  official footer layout (logo + division lockup at top, contact block at
  the foot of every page).
- Continuation header on page 2+ ("RE: … / date / Page N").
- Body font TeX Gyre Heros (Helvetica-metric): found via the TeX tree
  for XeLaTeX, bundled for Typst.
- Conforms to the Caltech Identity Toolkit: official vector wordmark
  (PDF for XeLaTeX, SVG for Typst), official orange `#FF6C0C` (PMS 1585c)
  and gray `#76777B` (PMS Cool Gray 9), and the division/department line
  in Georgia serif per the official lockup standard.

### Known limitations / ideas

- The division line requires the Georgia font (system font on
  macOS/Windows; CI installs `ttf-mscorefonts-installer`).
- The continuation header is always on. A `continuation-header: false`
  toggle could be added.
- For XeLaTeX, the bundled fonts are not used; the format relies on
  `tex-gyre` being present in the TeX installation (universal in full
  TeX Live; installed explicitly in CI).
