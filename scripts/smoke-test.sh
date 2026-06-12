#!/usr/bin/env bash
#
# Clean-room render check in BOTH install layouts:
#   * local      — `quarto add <repo>` (exactly as a user would from a local
#                  checkout), which installs to _extensions/caltech-letter/
#   * namespaced — the GitHub layout `quarto add jnkatz/caltech-letter`
#                  produces, _extensions/jnkatz/caltech-letter/
# Every sample letter renders to BOTH the XeLaTeX and Typst formats, and the
# Typst PDFs are checked with pdffonts: Typst substitutes missing fonts
# SILENTLY, so a font-paths regression cannot be caught by render success or
# text checks alone.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

assert_font() {
  local pdf="$1"
  local face="$2"

  if ! pdffonts "$pdf" | grep -q "$face"; then
    printf 'Font %s not embedded in %s (silent fallback?)\n' "$face" "$pdf" >&2
    exit 1
  fi
}

write_inputs() {
  local project="$1"

  cat > "$project"/_quarto.yml <<'YAML'
project:
  type: default
YAML

  cp "$repo_root"/example.qmd "$project"/
  cp "$repo_root"/template.qmd "$project"/
  cp "$repo_root"/tenure-example.qmd "$project"/
  cp "$repo_root"/footer-example.qmd "$project"/

  cat > "$project"/no-date.qmd <<'QMD'
---
format: caltech-letter-pdf
re: "No Date Smoke Test"
---

This letter omits the date field so both engines must use their default
date behavior.
QMD

  cat > "$project"/long-closing.qmd <<'QMD'
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

  mkdir -p "$project"/letters
  cat > "$project"/letters/subdir.qmd <<'QMD'
---
format: caltech-letter-pdf
re: "Subdirectory Smoke Test"
date: "June 8, 2026"
---

This letter lives in a subdirectory so the Typst font and logo paths are
resolved through the project root.
QMD
}

install_extension() {
  local project="$1"
  local layout="$2"

  case "$layout" in
    local)
      (cd "$project" && quarto add "$repo_root" --no-prompt --quiet --log-level error)
      ;;
    namespaced)
      mkdir -p "$project/_extensions/jnkatz"
      cp -R "$repo_root/_extensions/caltech-letter" \
        "$project/_extensions/jnkatz/caltech-letter"
      ;;
    *)
      printf 'Unknown extension layout: %s\n' "$layout" >&2
      exit 1
      ;;
  esac
}

run_layout() {
  local layout="$1"
  local project="$tmp_root/$layout"

  mkdir -p "$project"
  install_extension "$project" "$layout"
  write_inputs "$project"

  printf '==> Testing %s install layout\n' "$layout"
  (
    cd "$project"

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

    # In project mode, --output lands at the project root.
    assert_font template-typst.pdf "TeXGyreHeros"
    assert_font example-typst.pdf "TeXGyreHeros"
    assert_font subdir-typst.pdf "TeXGyreHeros"

    echo "All letters rendered to PDF (XeLaTeX) and PDF (Typst)."
    ls -la ./*-latex.pdf ./*-typst.pdf
  )
}

need quarto
need pdffonts

run_layout local
run_layout namespaced

echo "Smoke tests passed."
