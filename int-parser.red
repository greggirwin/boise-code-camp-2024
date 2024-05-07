Red []

digit:   charset [#"0" - #"9"]	; this is a terminal, it doesn't refer to another rule
sign:    charset "+-"			; this is a terminal, it doesn't refer to another rule
integer: [opt sign some digit]	; this is a non-terminal, because it refers to `sign` and `digit`

is-int?: func [str [string!]][parse str integer]


halt
