;
; a2q2.asm
;
;
; Turn the code you wrote in a2q1.asm into a subroutine
; and then use that subroutine with the delay subroutine
; to have the LEDs count up in binary.

		ldi r16, 0xFF
		out DDRB, r16		; PORTB all output
		sts DDRL, r16		; PORTL all output

; Your code here
; Be sure that your code is an infite loop
.cseg


call INITIALIZE_ARRAY

SUBROUTINE:	
	call Q1
	ldi r23, 0x40
	call delay
	rjmp SUBROUTINE

		; clear all LEDs
		clr r19
		out PORTB, r19
		sts PORTL, r19

		ldi r19, 0b00000001

		; initialize counter in r17
		ldi r17, 6
	Q1:
	; LOOP checks if LED needs to be changed
	LOOP:

		mov r18, r16
		andi r18, 0b00000001
		cpi r18, 0b00000001
		breq CHANGELIGHT

		;ldi ZL, low(LED_VALUES)
		;ldi ZH, high(LED_VALUES)		
		st Z+, r0
		st Z+, r0

	; CONTINUE shifts bits one to the right and checks the same bit in LOOP
	; If counter in r17 goes to zero then we have checked all 6 bits and finish.
	CONTINUE:

		lsr r16
		dec r17
		tst r17
		brne LOOP
		rjmp LOOP_FOR_Z
	; CHANGELIGHT loads value stored at the address at Z and increments Z.
	; It then checks whether the value indicates PORT B or PORT L
	CHANGELIGHT:
		ld r20, Z+
		tst r20
		brne L
	B:
		in r21, PORTB
		ld r22, Z+
		eor r21, r22
		out PORTB, r21
		rjmp CONTINUE
	L:
		lds r21, PORTL
		ld r22, Z+
		eor r21, r22
		sts PORTL, r21

		rjmp CONTINUE

	LOOP_FOR_Z:
		ldi r17, 6
		ldi ZL, low(LED_VALUES)
		ldi ZH, high(LED_VALUES)
		ret



		call display
		
		jmp LOOP

done:		jmp done	; if you get here, you're doing it wrong

;
; display
; 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;
display:

		out PORTB, r0
		sts PORTL, r0
		ret
;
; delay
;
; set r20 before calling this function
; r20 = 0x40 is approximately 1 second delay
;
; registers used:
;	r20
;	r21
;	r22
;
delay:	
del1:	nop
		ldi r21,0xFF
del2:	nop
		ldi r22, 0xFF
del3:	nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1	
		ret


; This initializes the array for the Z pointer to keep track
; of which port in pin to check and switch for the LEDS
; (if necessary).
INITIALIZE_ARRAY:
	push r16
	ldi ZL, low(LED_VALUES)
	ldi ZH, high(LED_VALUES)

	ldi r16, 0
	st Z+, r16
	ldi r16, 0b00000010
	st Z+, r16
	ldi r16, 0
	st Z+, r16
	ldi r16, 0b00001000
	st Z+, r16
	ldi r16, 1
	st Z+, r16
	ldi r16, 0b00000010
	st Z+, r16
	ldi r16, 1
	st Z+, r16
	ldi r16, 0b00001000
	st Z+, r16
	ldi r16, 1
	st Z+, r16
	ldi r16, 0b00100000
	st Z+, r16
	ldi r16, 1
	st Z+, r16
	ldi r16, 0b10000000
	st Z+, r16

	ldi ZL, low(LED_VALUES)
	ldi ZH, high(LED_VALUES)
	pop r16
	ret


.dseg
LED_VALUES: .byte 12