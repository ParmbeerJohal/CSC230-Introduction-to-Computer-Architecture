/*
 * A3.asm
 *	 November 19/2018
 *	 V00787710
 *   Author: parmj
 */ 

;initialize the lcd
;clear the lcd
;copy the strings from program to data memory
;set l1ptr and l2ptr to point at the start of the display strings
;do forever:
;clear line1 and line2
;display line1 and line2
;copy from the pointers in msg1 and msg2 to line1 and line2
;display line1 and line2
;move the pointers forward (wrap around when appropriate)
;delay


; *****FOR THE COMMENTED OUT FUNCTIONS, I TRIED CREATING
; THE BUTTON FUNCTION TO SLOW DOWN THE SCROLL, BUT
; GOT A RELATIVE BRANCH OUT OF REACH ERROR, PREVENTING
; ME FROM FINISHING ADJUSTING THE SCROLLING SPEED FOR THE
; SLOW BUTTON.*****

#define LCD_LIBONLY
.include "lcd.asm"

.cseg

; initialize the Analog to Digital conversion
ldi r16, 0x87
sts ADCSRA, r16
ldi r16, 0x40
sts ADMUX, r16

start:
call lcd_init
call lcd_clr
call copy_strings
call set_pointers
do_forever:
	call lcd_clr
	call display_lines
	call copy_lines
	call display_lines
	call shift_pointers
	call delay
	jmp do_forever

;do_forever_SLOW:
	;call lcd_clr
	;call display_lines
	;call copy_lines
	;call display_lines
	;call shift_pointers
	;call delay_SLOW
	;jmp do_forever_SLOW

do_forever_FAST:
	call lcd_clr
	call display_lines
	call copy_lines
	call display_lines
	call shift_pointers
	call delay_FAST
	jmp do_forever_FAST
do_forever_if_up_button_pressed:
	call display_lines
	call check_button
	cpi r24, 0x04 ; Checks if 'DOWN' button is pressed
	breq start
	jmp do_forever_if_up_button_pressed

delay_FAST:
	call check_button
	cpi r24, 0x02
	breq do_forever_if_up_button_pressed
	call check_button
	cpi r24, 0x08 ; Checks if the 'LEFT' button is pressed
	;breq do_forever_SLOW
	ldi  r18, 30
    ldi  r19, 50
    ldi  r20, 50

L1_FAST:
	dec r20
    brne L1_FAST
    dec  r19
    brne L1_FAST
    dec  r18
    brne L1_FAST
	ret

delay:
	call check_button
	cpi r24, 0x02 ; Checks if the 'UP' button is pressed
	breq do_forever_if_up_button_pressed
	;call check_button
	;cpi r24, 0x08 ; Checks if the 'LEFT' button is pressed
	;breq do_forever_SLOW
	cpi r24, 0x01
	breq do_forever_FAST
	ldi  r18, 41
    ldi  r19, 150
    ldi  r20, 128
L1:	dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
	ret

;delay_SLOW:
	;call check_button
	;cpi r24, 0x02
	;breq do_forever_if_up_button_pressed
	;call check_button
	;cpi r24, 0x01 ; Checks if the 'LEFT' button is pressed
	;breq do_forever_FAST
	;ldi  r18, 150
    ;ldi  r19, 100
    ;ldi  r20, 100

;L1_SLOW:
	;dec r20
    ;brne L1_SLOW
    ;dec  r19
    ;brne L1_SLOW
    ;dec  r18
    ;brne L1_SLOW
	;ret

copy_strings:
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(MESSAGE1)		; this the destination
	push r16
	ldi r16, low(MESSAGE1)
	push r16
	ldi r16, high(string1 << 1) ; this is the source
	push r16
	ldi r16, low(string1 << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

	ldi r16, high(MESSAGE2)
	push r16
	ldi r16, low(MESSAGE2)
	push r16
	ldi r16, high(string2 << 1)
	push r16
	ldi r16, low(string2 << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	pop r16
	ret

; This function sets LPOINTER_1 and
; LPOINTER_2 to point to the start
; of each message msg1_p and msg2_p,
; respectively.
set_pointers:
	push ZL
	push ZH
	push r16
	push r17

	; Set first pointer to the start of first message
	ldi ZL, low(LPOINTER_1)
	ldi ZH, high(LPOINTER_1)
	ldi r16, low(MESSAGE1)
	st Z+, r16
	ldi r17, high(MESSAGE1)
	st Z+, r17

	; Set second pointer to the start of second message
	ldi ZL, low(LPOINTER_2)
	ldi ZH, high(LPOINTER_2)
	ldi r16, low(MESSAGE2)
	st Z+, r16
	ldi r17, high(MESSAGE2)
	st Z, r17

	pop r17
	pop r16
	pop ZH
	pop ZL

	ret


; This code displays the first line
; and second line onto the LCD display
; BORROWED AND SLIGHTLY MODIFIED FROM
; LCD_example.asm
display_lines:
	; This call moves the cursor to the start
	; of the first line (ie. 0,0)
	push r17

	call lcd_clr

	ldi r17, 0x00
	push r17
	ldi r17, 0x00
	push r17
	call lcd_gotoxy
	pop r17
	pop r17

	; Display first message on the first line
	ldi r17, high(FIRSTLINE)
	push r17
	ldi r17, low(FIRSTLINE)
	push r17

	call lcd_puts
	pop r17
	pop r17

	; Move the cursor to the second line (ie. 0,1)
	ldi r17, 0x01
	push r17
	ldi r17, 0x00
	push r17
	call lcd_gotoxy
	pop r17
	pop r17

	; Display second message on the second line
	ldi r17, high(SECONDLINE)
	push r17
	ldi r17, low(SECONDLINE)
	push r17

	call lcd_puts
	pop r17
	pop r17

	pop r17
	ret

	
	
	
	
; Copy from the pointers in msg1 and msg2 to line1 and line2
copy_lines:

	; Copy the first 16 characters of the first
	; message into display line 1.
	copy_first_message:
		push r18
		push r19
		push ZH
		push ZL
		push XH
		push XL
	
	
		ldi ZL, low(LPOINTER_1)
		ldi ZH, high(LPOINTER_1)
		ld r18, Z+ ;Contains the low address of the pointer
		ld r19, Z+ ;Contains the high address of the pointer
	
		mov ZH, r19
		mov ZL, r18
		;Now the address of the current index in MESSAGE1 pointed
		;to by LPOINTER_1 is pointed to by Z
	
		clr r18
		clr r19
	
		; Makes X point to the start of
		; the first LCD display line
		ldi XL, low(FIRSTLINE)
		ldi XH, high(FIRSTLINE)
	
	
		ldi r18, 0
		; This loop copies 16 characters starting from
		; the first pointer of MESSAGE1 array and increments 
		; the Z pointer. If the pointer reaches the null character
		; it then wraps around to point to the first character in
		; the array and continues to fill in the characters.
		looper_1:
			inc r18
			cpi r18, 17
			breq pop_it_1
			ld r19, Z+
			tst r19
			breq copy_from_start_1
		continue_1:
			st X+, r19
			jmp looper_1
	
	
		copy_from_start_1:
			ldi ZH, high(MESSAGE1)
			ldi ZL, low(MESSAGE1)
			ld r19, Z+
			jmp continue_1
	
	
		pop_it_1:
			pop XL
			pop XH
			pop ZL
			pop ZH
			pop r19
			pop r18

	; Copy the first 16 characters of the second
	; message into display line 2.
	copy_second_message:
		push r18
		push r19
		push ZH
		push ZL
		push XH
		push XL
	
	
		ldi ZL, low(LPOINTER_2)
		ldi ZH, high(LPOINTER_2)
		ld r18, Z+ ;Contains the low address of the pointer
		ld r19, Z+ ;Contains the high address of the pointer
	
		mov ZH, r19
		mov ZL, r18
		;Now the address of the current index in MESSAGE1 pointed
		;to by LPOINTER_1 is pointed to by Z
	
		clr r18
		clr r19
	
		; Makes X point to the start of
		; the first LCD display line
		ldi XL, low(SECONDLINE)
		ldi XH, high(SECONDLINE)
	
	
		ldi r18, 0
		; This loop copies 16 characters starting from
		; the first pointer of MESSAGE2 array and increments 
		; the Z pointer. If the pointer reaches the null character
		; it then wraps around to point to the first character in
		; the array and continues to fill in the characters.
		looper_2:
			inc r18
			cpi r18, 17
			breq pop_it_2
			ld r19, Z+
			tst r19
			breq copy_from_start_2
		continue_2:
			st X+, r19
			jmp looper_2
	
	
	
		copy_from_start_2:
			ldi ZH, high(MESSAGE2)
			ldi ZL, low(MESSAGE2)
			ld r19, Z+
			jmp continue_2
	
	
		pop_it_2:
			pop XL
			pop XH
			pop ZL
			pop ZH
			pop r19
			pop r18
		
			ret
		
		
		


; THIS FUNCTION MOVES THE POINTERS
; FORWARD BY ONE. IF THE POINTER
; REACHES THE NULL TERMINATOR, IT
; RESTARTS THE POINTERS TO THE BEGINNING.
shift_pointers:
	
	ptr1:
		push r16
		push ZH
		push ZL
		push XH
		push XL

		; Z will contain the address of LPOINTER_1
		ldi ZH, high(LPOINTER_1)
		ldi ZL, low(LPOINTER_1)
		; X will contain the address of the memory location where LPOINTER_1 IS POINTING
		ld XL, Z+
		ld XH, Z+
		; Now X points to where LPOINTER_1 is pointing (which is pointing at an index of MESSAGE1)
		
		; Next part moves the pointer forward by one,
		; pointing to the next char in MESSAGE1 array
		; If it points to the null character, the
		; zero flag will be set. If it's set,
		; restart the pointer to the start of the array.
		adiw XL:XH, 1
		ld r16, X ; Loads the value from where X points.
		tst r16
		; If X points to null terminator, restart the 
		; location of pointer 1.
		breq restart_ptr1
		
		; Else store the new address X points to
		; into pointer 1
		st -Z, XH
		st -Z, XL
	
	ptr2:
		; Z will contain the address of LPOINTER_2
		ldi ZH, high(LPOINTER_2)
		ldi ZL, low(LPOINTER_2)
		
		; X will contain the address of the memory location where LPOINTER_2 IS POINTING
		ld XL, Z+
		ld XH, Z+
		
		; Now X points to where LPOINTER_2 is pointing (which is pointing at an index of MESSAGE2)
		
		; Next part moves the pointer forward by one,
		; pointing to the next char in MESSAGE2 array
		; If it points to the null character, the
		; zero flag will be set. If it's set,
		; restart the pointer to the start of the array.
		adiw XL:XH, 1
		ld r16, X ; Loads the value from where X points.
		tst r16
		
		; If X points to null terminator, restart the 
		; location of pointer 2.
		breq restart_ptr2
		
		; Else store the new address X points to
		; into pointer 2
		st -Z, XH
		st -Z, XL
	
	finish_pop:
		pop XL
		pop XH
		pop ZL
		pop ZH
		pop r16
		ret
	
	; This restarts the pointer
	restart_ptr1:
		push ZL
		push ZH
		push r16
		push r17

		; Set first pointer to first message
		ldi ZL, low(LPOINTER_1)
		ldi ZH, high(LPOINTER_1)
		ldi r16, low(MESSAGE1)
		st Z+, r16
		ldi r17, high(MESSAGE1)
		st Z+, r17

		pop r17
		pop r16
		pop ZH
		pop ZL
		
		jmp ptr2
		
	restart_ptr2:
		push ZL
		push ZH
		push r16
		push r17

		; Set second pointer to second message
		ldi ZL, low(LPOINTER_2)
		ldi ZH, high(LPOINTER_2)
		ldi r16, low(MESSAGE2)
		st Z+, r16
		ldi r17, high(MESSAGE2)
		st Z+, r17

		pop r17
		pop r16
		pop ZH
		pop ZL
		
		jmp finish_pop

	;
; An improved version of the button test subroutine
;
; Returns in r24:
;	0 - no button pressed
;	1 - right button pressed
;	2 - up button pressed
;	4 - down button pressed
;	8 - left button pressed
;	16- select button pressed
;
; this function uses registers:
;	r16
;	r17
;	r24
;
; if you consider the word:
;	 value = (ADCH << 8) +  ADCL
; then:
;
; value > 0x3E8 - no button pressed
;
; Otherwise:
; value < 0x032 - right button pressed
; value < 0x0C3 - up button pressed
; value < 0x17C - down button pressed
; value < 0x22B - left button pressed
; value < 0x316 - select button pressed
; 
; BORROWED FROM THE GIVEN 'button.asm' FILE***
check_button:
		push r16
		push r17
		
		; start a2d
		lds	r16, ADCSRA	
		ori r16, 0x40
		sts	ADCSRA, r16

		; wait for it to complete
wait:	lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value
		lds r16, ADCL
		lds r17, ADCH

		clr r24
		cpi r17, 3			;  if > 0x3E8, no button pressed 
		brne bsk1		    ;  
		cpi r16, 0xE8		; 
		brsh bsk_done		; 
bsk1:	tst r17				; if ADCH is 0, might be right or up  
		brne bsk2			; 
		cpi r16, 0x32		; < 0x32 is right
		brsh bsk3
		ldi r24, 0x01		; right button
		rjmp bsk_done
bsk3:	cpi r16, 0xC3		
		brsh bsk4	
		ldi r24, 0x02		; up			
		rjmp bsk_done
bsk4:	ldi r24, 0x04		; down (can happen in two tests)
		rjmp bsk_done
bsk2:	cpi r17, 0x01		; could be up,down, left or select
		brne bsk5
		cpi r16, 0x7c		; 
		brsh bsk7
		ldi r24, 0x04		; other possiblity for down
		rjmp bsk_done
bsk7:	ldi r24, 0x08		; left
		rjmp bsk_done
bsk5:	cpi r17, 0x02
		brne bsk6
		cpi r16, 0x2b
		brsh bsk6
		ldi r24, 0x08
		rjmp bsk_done
bsk6:	ldi r24, 0x10
bsk_done:
		pop r17
		pop r16
		ret


string1:	.db "IYERN BABE HERE!", 0	
string2: .db "BOUNCE BOUNCE BOUNCE!", 0

; DATA SEGMENT BORROWED AND SLIGHTLY MODIFIED FROM ASSIGNMENT 3 PDF FILE.
.dseg
; The program copies the strings from program memory
; into data memory.  These are the strings
; that are actually displayed on the lcd
;
MESSAGE1:	.byte 200
MESSAGE2:	.byte 200

FIRSTLINE:	.byte 17
SECONDLINE:	.byte 17


LPOINTER_1:	.byte 2
LPOINTER_2:	.byte 2