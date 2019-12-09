;
; a2q1.asm
;
; Write a program that displays the binary value in r16
; on the LEDs.
;
; See the assignment PDF for details on the pin numbers and ports.
;

.cseg






		ldi r16, 0xFF
		out DDRB, r16		; PORTB all output
		sts DDRL, r16		; PORTL all output

		ldi r16, 0x33		; display the value
		mov r0, r16			; in r0 on the LEDs

; Your code here
		call INITIALIZE_ARRAY

		; clear all LEDs
		clr r19
		out PORTB, r19
		sts PORTL, r19

		ldi r19, 0b00000001

		; initialize counter in r17
		ldi r17, 6

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
		rjmp done

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
;
; Don't change anything below here
;
done:	jmp done


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