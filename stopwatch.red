Red [
	title: "Stopwatch"
]

;-------------------------------------------------------------------------------

incr: function [
	"Increments a value or series index"
	value [scalar! series! any-word! any-path!] "If value is a word, it will refer to the incremented value"
	/by "Change by this amount"
		amount [scalar!]
][
	amount: any [amount 1]
	
	if integer? value [return add value amount]			;-- This speeds up our most common case by 4.5x
														;	though we are still 5x slower than just adding 
														;	1 to an int directly and doing nothing else.

	; All this just to be smart about incrementing percents.
	; The question is whether we want to do this, so the default 'incr
	; call seems arguably nicer. But if we don't do this it is at 
	; least easy to explain.
	if all [
		integer? amount
		1 = absolute amount
		any [percent? value  percent? attempt [get value]]
	][amount: to percent! (1% * sign? amount)]			;-- % * int == float, so we cast.

	case [
		scalar? value [add value amount]
		any [
			any-word? value
			any-path? value								;!! Check any-path before series.
		][
			op: either series? get value [:skip][:add]
			set value op get value amount
			:value                                      ;-- Return the word for chaining calls.
		]
		series? value [skip value amount]				;!! Check series after any-path.
	]
]
decr: function [
	"Decrements a value or series index"
	value [scalar! series! any-word! any-path!] "If value is a word, it will refer to the decremented value"
	/by "Change by this amount"
		amount [scalar!]
][
	incr/by value negate any [amount 1]
]

;-------------------------------------------------------------------------------

start-time: now
ticks: 0

view [
    t-time: H2 125 rate 0:0:1 on-time [
        if tgl-switch/data [
        	incr 'ticks
            face/data: to time! ticks
        ]
    ]
    panel [ below
	    tgl-switch: toggle on "Pause" [
	    	face/text: pick ["Pause" "Resume"] face/data
	    	; This resets the timer every time we stop it;
	    	; without it we get pause/resume behavior.
	        ;if face/data [ticks: 0]
	    ]
	    button "Reset" [ticks: 0  t-time/data: 0:0:0]
	]
]
