;
; CSc 230 Assignment 1
; Question 4
;
.include "m2560def.inc"
; This program should calculate the sum of the integers from 1 to (value)
; inclusive.
;
; The result should be stored in (result).
;
; Where:
;
;   (value) refers to the byte stored at memory location value in data memory
;   (result) refers to the byte stored at memory location result in data memory
;
; The sample code you've been given already contains labels named value and result
;
; In the AVR there is no way to automatically initialize data memory
; with constant values.  This is why I have supplied code that initializes data
; memory from program memory.
;

;--*1 Do not change anything between here and the line starting with *--
;
; You don't need to understand this code, we will get to it later
;
; But, if you are keen -- I am using the Z register as a pointer into
; program memory
;
.cseg
	ldi ZH,high(init<<1)		; initialize Z to point to init
	ldi ZL,low(init<<1)
	lpm r0,Z				; get the first byte and increment Z
	sts value,r0				; store into A
;*--1 Do not change anything above this line to the --*

;***
; Your code goes here:
;
	ldi r16, 1
	lds r17, value
	mov r18, r17

loop:
	cp r17, r16
	breq store
	add r18, r16
	inc r16
	jmp loop

store:
	sts result, r18


;****

;--*2 Do not change anything between here and the line starting with *--
done:	jmp done
;*--2

;--*3 Do not change anything between here and the line starting with *--
; This is the constant to initialize value to
; Program memory must be specified in words (2 bytes) which
; is why there is a 2nd byte (0x00) at the end.
init:	.db 0x05, 0x00
;*--3
;--*4 Do not change anything between here and the line starting with *--
; This is in the data segment (ie. SRAM)
; The first real memory location in SRAM starts at location 0x200 on
; the ATMega 2560 processor.  Locations less than 0x200 are special
; and will be discussed much more later
;
.dseg
.org 0x200
value:	.byte 1
result:	.byte 1
;*--4
