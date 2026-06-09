// caltech-letter: Typst letterhead. Defines a `letter` function that draws
// the Caltech letterhead (logo + sender block, date, RE line, salutation),
// then the body, then the closing/signature block. Called from typst-show.typ.

// Official Caltech palette: orange PMS 1585c, neutral PMS Cool Gray 9.
#let caltech-orange = rgb("#FF6C0C")
#let caltech-gray = rgb("#76777B")

#let letter(
  sender-name: [Jonathan N. Katz],
  sender-title: [Kay Sugahara Professor of Social Sciences and Statistics],
  sender-address: ([1200 East California Blvd.], [MC 228-77], [Pasadena, CA 91125]),
  sender-phone: [(626) 395-4191],
  sender-email: [jkatz\@caltech.edu],
  department: [Division of the Humanities and Social Sciences],
  logo: "/_extensions/caltech-letter/caltech-logo-orange.svg",
  re: none,
  date: none,
  recipient: none,
  recipient-address: (),
  salutation: [Dear Members of the Search Committee:],
  closing: [Sincerely,],
  signature-name: none,
  signature-title: none,
  footer-contact: false,
  fontsize: 11pt,
  margin: (x: 1in, top: 0.9in, bottom: 1in),
  doc,
) = {
  set text(font: "TeX Gyre Heros", size: fontsize)
  set par(justify: false, leading: 0.65em, spacing: 0.9em, first-line-indent: 0pt)

  set page(
    paper: "us-letter",
    margin: margin,
    // Official footer layout: contact block centered at the foot of every page.
    footer: if footer-contact {
      let bits = sender-address + (sender-phone, sender-email)
      align(center)[
        #set text(size: 8pt, fill: caltech-gray)
        #text(font: "Georgia")[#department] \
        #bits.join([ #sym.dot.c ])
      ]
    } else { none },
    header: context {
      if counter(page).get().first() > 1 {
        set text(size: 9pt, fill: caltech-gray)
        let left-bits = if re != none { [RE: #re] } else if recipient != none { recipient } else { [] }
        grid(
          columns: (1fr, auto),
          align(left)[#left-bits #h(2em) #date],
          align(right)[Page #counter(page).display()],
        )
      }
    },
  )

  // --- Letterhead band ---
  // Division name in serif (Georgia) per Caltech's official lockup standard.
  let division-block = [
    #image(logo, height: 0.55in)
    #v(6pt)
    #text(font: "Georgia", size: 9pt, fill: caltech-gray)[#department]
  ]
  if footer-contact {
    // Official footer layout: logo + division lockup only (no right block).
    division-block
  } else {
    // Default layout: logo + division (left), full sender block (right).
    grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      division-block,
      align(right)[
        #set text(size: 9pt)
        #set par(leading: 0.5em, spacing: 0.5em)
        #sender-name \
        #sender-title \
        #sender-address.join(linebreak()) \
        #sender-phone \
        #sender-email
      ],
    )
  }

  v(2.2em)
  align(right)[#date]
  v(1.4em)

  if re != none {
    text(weight: "bold")[RE: #re]
    v(1.2em)
  }
  if recipient != none {
    recipient
    linebreak()
    for line in recipient-address { line; linebreak() }
    v(1.2em)
  }
  salutation
  v(0.6em)

  // --- Body ---
  doc

  // --- Closing / signature ---
  v(1.5em)
  closing
  v(3.2em)
  if signature-name != none { signature-name } else { sender-name }
  linebreak()
  if signature-title != none { signature-title } else { sender-title }
}
