-- caltech-letter: resolve the official Caltech wordmark (vector) to a path
-- each engine can find, regardless of the consuming project's working dir
-- or the install layout (_extensions/caltech-letter vs the GitHub-namespaced
-- _extensions/jnkatz/caltech-letter).
--   * LaTeX: a PDF via resolve_path (XeLaTeX embeds vector PDF natively).
--   * Typst: an SVG via resolve_path, truncated to its root-relative
--     /_extensions/... suffix (Typst resolves a leading / against the
--     project root) and inserted into the Typst partial as a raw string so
--     Pandoc does not escape underscores in _extensions paths.
function Meta(meta)
  if quarto.doc.is_format("typst") then
    if meta["typst-logo-path"] == nil then
      local svg_path = quarto.utils.resolve_path("caltech-logo-orange.svg")
      svg_path = svg_path:match("(/_extensions/.+)$") or svg_path
      meta["typst-logo-path"] = pandoc.MetaInlines({
        pandoc.RawInline("typst", '"' .. svg_path .. '"')
      })
    end
    return meta
  end
  if meta["logo-path"] ~= nil then
    return meta
  end
  meta["logo-path"] = pandoc.MetaString(
    quarto.utils.resolve_path("caltech-logo-orange.pdf"))
  return meta
end
