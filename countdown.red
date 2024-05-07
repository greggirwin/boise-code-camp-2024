Red [
    Title:  'Countdown
    File:    %countdown.red
    Purpose: "Show the number of days until events occur."
    Author:  "Gregg Irwin"
]

; Enter your events here.
events: [
    ; One-time Events
    ; Description             date        time
    Appt with Nenad           30-Apr-2024
    Blog Post #06             01-Jun-2024
    ;Code Camp 2024            04-May-2024 15:00
    
    weekly [
        ; Description   [weekday and optional time]
        staff meeting   [monday 10:00 AM]
        build & release [tuesday]
        ;garbage out     [21:30 Wednesday]
        ;get mail        [thursday]
        doc friday      [14:00 friday]
        ;party           [friday 11:00 PM]
        ;recover         [saturday]
        ;confess         [sunday]
    ]

    monthly [
        ; Description   day of the month
        mortgage due    1   ; First of the month
    ]

    annual [
        ; Description   Date the first event occurred
        REBOL DevCon     29-Sep-2004
        Mom's Birthday   15-Oct-1929
        Dad's Birthday   19-Dec-1926
        Mom and Dad's Anniversary 22-nov-1950
        taxes due        15-apr-2005
    ]

]

; How many days do you want to look forward?
number-of-days: 30



;-----------------------------------------------------------------------
;!! Below this point is the program code. You probably don't want to 
;   change it if you're an end user.
;-----------------------------------------------------------------------

stop-date: now + number-of-days
upcoming-events: copy []

edit: does [
	call/show rejoin ["notepad.exe " to-local-file what-dir "countdown.red"]
]

this-zone?: func [date] [date/zone = now/zone]

=desc: =date: =time: none

emit-event: func [desc date] [
	;print reduce [mold desc date]
    ;if none? date/time [date/time: now/time - 12:00]
    repend/only upcoming-events [desc date]
]
; emit-events: func [desc date "start date" step] [
;     step: join [] step
;     while [date <= stop-date] [
;         print [date stop-date]
;         emit-event desc date
;         do step
;         wait 1
;     ]
; ]

emit-non-recurring-event: does [emit-event =desc =date =time]

context [
	date: none
	
    set 'emit-annual-event func [desc date "date of first event" /local first-year count] [
        first-year: date/year
        if this-zone? date [date/zone: 0:0:0]
        date/year: now/year
        if date < now [date/year: date/year + 1]
        while [date <= stop-date] [
            count: date/year - first-year
            emit-event rejoin [desc " (" either count > 0 [count] ["First"] ")"] date
            date/year: date/year + 1
        ]
    ]
    set 'emit-monthly-event func [desc day "day of month"] [
        date: now/date
        if this-zone? date [date/zone: 0:0:0]
        date/day: day
        if date < now [date/month: date/month + 1]
        while [date <= stop-date] [
            emit-event desc date 
            date/month: date/month + 1
        ]
    ]
    set 'emit-weekly-event func [desc weekday time] [
        date: now
        if this-zone? date [date/zone: 0:0:0]
        date/time: time
        if not integer? weekday [
            weekday: index? find system/locale/days form weekday
        ]
        ; get the date on the right weekday to start
        date: date + weekday - now/weekday
        if date < now [date: date + 7]
        while [date <= stop-date] [
            emit-event desc date
            date: date + 7
        ]
;        emit-events desc date func [date] [date + 7]
    ]
]

;-------------------------------------------------------------------------------
; Dialect parse rules
;-------------------------------------------------------------------------------

desc=: [
	copy =desc [
		some [all-word! | any-string!]
		| string!
	]
	(=desc: mold/only =desc)
]
date=: [set =date date!]
day=:  [set =day integer!]
weekday=: [
    opt 'on
    set =weekday ['monday | 'tuesday | 'wednesday | 'thursday | 'friday | 'saturday | 'sunday]
]
time=: [
    opt 'at
    set =time time!
    opt [
    	  ; Dual case words are a workaround for a regression bug in parse.
          ['am | 'AM] (if =time > 12:00 [=time: =time - 12:00])
        | ['pm | 'PM] (if =time < 12:00 [=time: =time + 12:00])
    ]
]
weekly-event-time=: [weekday= time= | time= weekday= | weekday= (=time: none)]

non-recurring-event=: [
    (=time: none)
    desc= date= opt time= (
        if =time [=date/time: =time]
        emit-non-recurring-event
    )
]
annual-event=:  [desc= date= (emit-annual-event =desc =date)]
monthly-event=: [desc= day=  (emit-monthly-event =desc =day)]
weekly-event=:  [desc= into weekly-event-time= (emit-weekly-event =desc =weekday =time)]

annual-events=:  [any [annual-event= ]]
monthly-events=: [any [monthly-event=]]
weekly-events=:  [any [weekly-event= ]]

rules: [
    some [
		;mark: (print mold mark)
        'annual into annual-events=
        | 'monthly into monthly-events=
        | 'weekly into weekly-events=
        | non-recurring-event=
    ]
]

;-------------------------------------------------------------------------------

show-countdown: does [
    clear upcoming-events 

    print "^/-----------------------------------------------------------"
    print ["Upcoming events for the next" number-of-days "days^/"]
    if not parse events rules [
    	print {
    	It looks like the event data is malformed. This is entirely Gregg's
    	fault for not handling the situation better. He'll try to do better.
    	}
    ]

	; What if the event has a time zone on it?
    remove-each event upcoming-events [
        any [event/2 > stop-date  event/2/date < now/date]
    ]

    pad: func [str len] [append copy str head insert/dup copy "" #" " len - length? str]
    days-until: func [event] [event/2/date - now/date]
    format-days-until: func [event][
        switch/default days-until event [
            0 ["Today!"]
            1 ["Tomorrow"]
        ][form reduce [event/2/date - now/date  "days"]]	; [form reduce [event/2 - (now + now/zone)  "days"]]
    ]

    ; This doesn't quite work when it comes to time zones if they've
    ; provided dates without times for some events, so we have to
    ; clear the zone for local-timezone events when we generate them.
    sort/compare upcoming-events function [a b][a/2 < b/2]
    ;sort/reverse/compare upcoming-events 2

    foreach event upcoming-events [
        print [
            pad event/1 20 tab event/2/date tab
            ; Red always includes seconds in formed time, even if they are zero.
            ; Need to format the time without them in this contex.
            either event/2/time [event/2/time] ["^-"] tab
            either event/2/date < now/date ["(PASSED)"] [format-days-until event]
        ]
    ]

    print {-----------------------------------------------------------
    
    Type EDIT if you want to add or remove items.
    
    Type Q or QUIT to exit the program.
    }
]

show-countdown


halt
