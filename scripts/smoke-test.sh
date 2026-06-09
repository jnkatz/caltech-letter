#!/usr/bin/env bash
#
# Clean-room render check: install the extension into a temp project with
# `quarto add` (exactly as a user would), then render every sample letter to
# BOTH the XeLaTeX and Typst formats. This exercises the bundled logo/font
# path resolution from a fresh install, not just the development copy.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cat > "$tmpdir"/_quarto.yml <<'YAML'
project:
  type: default
YAML

(cd "$tmpdir" && quarto add "$repo_root" --no-prompt --quiet --log-level error)

cp "$repo_root"/example.qmd "$tmpdir"/
cp "$repo_root"/template.qmd "$tmpdir"/
cp "$repo_root"/tenure-example.qmd "$tmpdir"/
cp "$repo_root"/footer-example.qmd "$tmpdir"/

cat > "$tmpdir"/no-date.qmd <<'QMD'
---
format: caltech-letter-pdf
re: "No Date Smoke Test"
---

This letter omits the date field so both engines must use their default
date behavior.
QMD

cat > "$tmpdir"/long-closing.qmd <<'QMD'
---
format: caltech-letter-pdf
re: "Closing Pagination Smoke Test"
date: "June 8, 2026"
---

This smoke-test letter is intentionally long enough to place the closing
near a page boundary. The closing phrase and typed signature should move
together rather than being split across pages.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum
commodo orci at lacus laoreet, sed ultricies justo suscipit. Integer
fermentum sem vitae augue sollicitudin, sed semper justo facilisis.

Praesent at mi ut erat ultrices vulputate. Donec dignissim, lectus sed
porta posuere, massa justo dapibus sapien, vitae facilisis tortor augue
quis arcu. Mauris sit amet interdum magna.

Curabitur sed nibh non lectus aliquet accumsan. Sed at ullamcorper
lectus. Donec nec mauris vitae arcu facilisis luctus. Vivamus euismod
ipsum vel neque condimentum, in vestibulum augue fermentum.

Aliquam erat volutpat. Suspendisse potenti. Integer pretium, risus at
vulputate cursus, mi purus consequat arcu, nec viverra eros sem ac erat.
Ut sagittis lorem id mauris dictum, vitae gravida ante luctus.

Donec eu luctus lectus. Cras vel posuere erat. Aenean consequat, lorem
non porttitor lacinia, lectus lorem semper orci, vitae facilisis justo
dolor at ipsum. Nullam sodales magna id lorem cursus, nec viverra odio
convallis.

Morbi feugiat turpis ac massa interdum, ac volutpat enim tempor. Integer
consequat quam a orci finibus, eget convallis massa posuere. Pellentesque
habitant morbi tristique senectus et netus et malesuada fames ac turpis
egestas.

Nam posuere semper augue, nec aliquet metus luctus non. Nunc dapibus
nunc vitae libero dictum, eget porta arcu volutpat. Sed interdum mi vitae
turpis faucibus, at tristique justo consequat.

Phasellus congue ullamcorper nisl, ac ultrices enim tincidunt non. Donec
laoreet tellus a turpis elementum, ac tincidunt nibh congue. Integer sit
amet eros faucibus, tempor lorem vitae, laoreet erat.

Vivamus luctus nibh sit amet purus rutrum, non vestibulum velit ornare.
Quisque consequat urna vitae metus ullamcorper, vitae volutpat urna
consectetur. Sed vitae sem tortor.
QMD

mkdir -p "$tmpdir"/letters
cat > "$tmpdir"/letters/subdir.qmd <<'QMD'
---
format: caltech-letter-pdf
re: "Subdirectory Smoke Test"
date: "June 8, 2026"
---

This letter lives in a subdirectory so the Typst font and logo paths are
resolved through the project root.
QMD

cd "$tmpdir"

for doc in example template tenure-example footer-example no-date long-closing; do
  echo "==> $doc (XeLaTeX)"
  quarto render "$doc.qmd" --to caltech-letter-pdf   --output "$doc-latex.pdf"
  echo "==> $doc (Typst)"
  quarto render "$doc.qmd" --to caltech-letter-typst --output "$doc-typst.pdf"
done

echo "==> letters/subdir (XeLaTeX)"
quarto render letters/subdir.qmd --to caltech-letter-pdf \
  --output subdir-latex.pdf
echo "==> letters/subdir (Typst)"
quarto render letters/subdir.qmd --to caltech-letter-typst \
  --output subdir-typst.pdf 2>&1 | tee subdir-typst.log
if grep -qi "unknown font family" subdir-typst.log; then
  echo "Typst did not find the bundled TeX Gyre Heros fonts." >&2
  exit 1
fi

echo "All letters rendered to PDF (XeLaTeX) and PDF (Typst)."
ls -la ./*-latex.pdf ./*-typst.pdf
