Red [
	purpose: "A simple DSL, done with string splitting."
]

;-------------------------------------------------------------------------------
; Commands

say-hello:   func [name][print ["Hello" any [name "...anybody there?"]]]
say-goodbye: func [name][print ["Goodbye" any [name "Whoever you are"]]]
say-something-random: does [
	print random/only [
		"I wish I were taller"
		"There is no spoon"
		"Avast ye scurvy dogs!"
	]
]
ask-a-question: does [
	print random/only [
		"Do you like Javascript as much as I do?"
		"How many people are in this room right now?"
		"Is the voltage low in here, or is it just me?"
	]
]
ask-for-help: does [
	print random/only [
		"Can I get some assistance?"
		"Little help here?"
		"Help!"
	]
]
blah-blah-blah: does [
	print "I see you typing, but I have no idea what you're saying."
]

;-------------------------------------------------------------------------------
; Input Processing

run-dsl: does [
	done?: no
	repeat i 5 [
		cmd: ask "Enter a command: "
		words: split cmd " "
		switch/default first words [
			"say" [
				switch second words [
					"hello"    [say-hello third words]
					"goodbye"  [say-goodbye third words  done?: yes]
					"anything" [say-something-random]
				]
			]
			"ask" [
				case [
					all [words/2 = "a"   words/3 = "question"][ask-a-question]
					all [words/2 = "for" words/3 = "help"]    [ask-for-help]
				]
			]
		][
			blah-blah-blah
		]
		if done? [break]
	]
	print either done? [
		"^/^-There, I said goodbye. What more do you want? Over and out.^/"
	][
		"^/^-Game Over. Deposit another quarter to play again.^/"
	]
]

run-dsl
