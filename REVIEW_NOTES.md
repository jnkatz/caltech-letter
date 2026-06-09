# Review Notes

Pre-GitHub review handoff for the Caltech letterhead Quarto extension.
This file records the issues found in the Codex review, the fixes applied,
and the remaining checks worth asking Claude to scrutinize.

## Issues Found And Fixed

- Typst could orphan the closing phrase from the typed signature across a
  page break.
- LaTeX had the same potential closing/signature pagination risk.
- Omitted dates were not fully engine-parity: Typst omitted the date, and
  LaTeX continuation headers omitted the default date.
- Typst subdirectory renders could fall back from bundled TeX Gyre Heros
  because `font-paths` was document-relative.
- The first-page letterhead spacing did not closely match `Estes-2025.pdf`:
  the header block started too high, the body started too low, and the
  default sender title wrapped in LaTeX.
- README listed the old Caltech orange value `#FF6A14`; the extension uses
  the current `#FF6C0C`.
- The smoke test did not cover no-date letters, subdirectory renders, or
  closing/signature pagination.

## Fixes Applied

- Changed Typst `font-paths` to the project-root-relative
  `/_extensions/caltech-letter/fonts`.
- Added Typst's default date using `datetime.today()` with non-padded day
  formatting to match Quarto/LaTeX output.
- Added the default date to LaTeX continuation headers when `date` is
  omitted.
- Wrapped the closing/signature block as nonbreaking content in both engines.
- Tuned first-page top margin and vertical spacing in both engines.
- Rebalanced the LaTeX sender block and let the division line keep its
  natural width so the default sender title and division line do not wrap.
- Expanded `scripts/smoke-test.sh` with no-date, long-closing, and
  subdirectory cases.
- Documented the changes in `CHANGELOG.md`.

## Verified

- `bash scripts/smoke-test.sh` passes.
- No-date temp letters render `June 8, 2026` in both LaTeX and Typst on the
  current system date.
- A no-date multipage temp letter shows the default date in the LaTeX and
  Typst continuation headers.
- A subdirectory Typst render completes without an `unknown font family`
  warning for TeX Gyre Heros.
- Rendered PNGs from `example.qmd` were visually inspected against the local
  `Estes-2025.pdf` reference.

## Claude Review Focus

- Re-check the visual match against `Estes-2025.pdf`, especially first-page
  header alignment, date placement, `RE:` placement, and body start.
- Check cross-engine parity after the spacing changes. Typst and LaTeX are
  close, but line breaks and pagination still differ because their font
  metrics differ.
- Re-check the `footer-contact: true` layout after the global top-margin and
  spacing changes.
- Look for Quarto-version fragility around Typst `font-paths` beginning with
  `/`, template partials, and `datetime.today()`.
- Confirm whether `quarto add jnkatz/caltech-letter` should be updated before
  publication, since this local checkout currently has no configured remote.

