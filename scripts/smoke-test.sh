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

(cd "$tmpdir" && quarto add "$repo_root" --no-prompt --quiet --log-level error)

cp "$repo_root"/example.qmd "$tmpdir"/
cp "$repo_root"/template.qmd "$tmpdir"/
cp "$repo_root"/tenure-example.qmd "$tmpdir"/
cp "$repo_root"/footer-example.qmd "$tmpdir"/

cd "$tmpdir"

for doc in example template tenure-example footer-example; do
  echo "==> $doc (XeLaTeX)"
  quarto render "$doc.qmd" --to caltech-letter-pdf   --output "$doc-latex.pdf"
  echo "==> $doc (Typst)"
  quarto render "$doc.qmd" --to caltech-letter-typst --output "$doc-typst.pdf"
done

echo "All letters rendered to PDF (XeLaTeX) and PDF (Typst)."
ls -la ./*-latex.pdf ./*-typst.pdf
