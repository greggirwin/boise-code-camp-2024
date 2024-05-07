Red []

digit:  charset "0123456789"
alpha:  charset [#"a" - #"z" #"A" - #"Z"]
number: [copy n [some digit] (n: to-integer n)]
word:   [some alpha]

Input: "abc1DEF23"
print mold parse input [
	collect [some [number keep (n) | keep word]]
]

halt