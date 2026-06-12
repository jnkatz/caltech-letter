# Changelog

## 0.1.1

Fixes the GitHub-namespaced install layout for the Typst format
(found in the sibling `caltech-memo` extension's review and ported
here).

- `quarto add jnkatz/caltech-letter` installs to
  `_extensions/jnkatz/caltech-letter/`, where the Typst format's
  hard-coded logo path failed the render outright and the bundled
  TeX Gyre Heros fonts silently fell back to a substitute. The logo
  is now resolved by `logo-path.lua` for both engines (injected as a
  raw Typst string so Pandoc does not escape `_extensions`), and
  `font-paths` covers both install layouts.
- The Typst template asserts the logo path was injected: a letter
  without the wordmark is a loud error, not a degraded render.
- The smoke test now runs in both install layouts and asserts with
  `pdffonts` that TeX Gyre Heros is actually embedded in the Typst
  PDFs (render success and text checks cannot catch silent font
  substitution). CI installs `poppler-utils` for this.

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
- Omitted dates fall back to the current date in both engines, including
  on continuation pages.
- Closing and signature stay together across page breaks in both engines.
- Body font TeX Gyre Heros (Helvetica-metric): found via the TeX tree for
  XeLaTeX, and bundled for Typst (resolved via a project-root-relative
  path so subdirectory renders work).
- Conforms to the Caltech Identity Toolkit: official vector wordmark
  (PDF for XeLaTeX, SVG for Typst), official orange `#FF6C0C` (PMS 1585c)
  and gray `#76777B` (PMS Cool Gray 9), and the division/department line
  in Georgia serif per the official lockup standard.
- Clean-room smoke test (`scripts/smoke-test.sh`) covering both engines
  across the samples plus no-date, subdirectory, and pagination cases.

### Known limitations / ideas

- The division line requires the Georgia font (system font on
  macOS/Windows; CI installs `ttf-mscorefonts-installer`).
- The continuation header is always on. A `continuation-header: false`
  toggle could be added.
- For XeLaTeX, the bundled fonts are not used; the format relies on
  `tex-gyre` being present in the TeX installation (universal in full
  TeX Live; installed explicitly in CI).
