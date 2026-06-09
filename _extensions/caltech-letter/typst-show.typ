// caltech-letter: forward Pandoc metadata into the `letter` function defined
// in typst-template.typ. Any field omitted falls back to the function default.
#show: doc => letter(
$if(re)$
  re: [$re$],
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(salutation)$
  salutation: [$salutation$],
$endif$
$if(recipient)$
  recipient: [$recipient$],
$endif$
$if(recipient-address)$
  recipient-address: ($for(recipient-address)$[$recipient-address$], $endfor$),
$endif$
$if(closing)$
  closing: [$closing$],
$endif$
$if(sender-name)$
  sender-name: [$sender-name$],
$endif$
$if(sender-title)$
  sender-title: [$sender-title$],
$endif$
$if(sender-address)$
  sender-address: ($for(sender-address)$[$sender-address$], $endfor$),
$endif$
$if(sender-phone)$
  sender-phone: [$sender-phone$],
$endif$
$if(sender-email)$
  sender-email: [$sender-email$],
$endif$
$if(department)$
  department: [$department$],
$endif$
$if(signature-name)$
  signature-name: [$signature-name$],
$endif$
$if(signature-title)$
  signature-title: [$signature-title$],
$endif$
$if(footer-contact)$
  footer-contact: true,
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
  doc,
)
