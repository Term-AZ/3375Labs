//DISPLAYS HEX
.global _start
.data
.text
_start:
	ldr r3, HEX3_HEX0_BASE @lower order four seven segment displays
	ldr r4, SW_BASE @slide switches
	ldr r2, DELAY_LENGTH
	mov r6, #1

_main_loop:
	bl _read_switches
	cmp r1, #0	
		bgt on
	cmp r1, #0	
		beq off
		

_delay_loop:
	mov r0, #0b0000000
	str r0, [r3]
	
	cmp r7, #0
		beq on
	sub r7,#1
	b _delay_loop
	
on:
	eor r6, #1
	bl _find_number
	bl _display_hex
	
	mov r7, r2
	cmp r6, #1
		beq _delay_loop
	b _main_loop

_display_hex:
	str r0, [r3]@load byte into ssd
	bx lr
	
_read_switches:
	ldr r1, [r4]@read what switches are on
	bx lr

_find_number:
    cmp r1, #1      
        beq zero      
    cmp r1, #2
        beq one
    cmp r1, #4
        beq two
    cmp r1, #8
        beq three
    cmp r1, #16
        beq four
    cmp r1, #32
        beq five
    cmp r1, #64
        beq six
    cmp r1, #128
        beq seven
    cmp r1, #256
        beq eight
	cmp r1, #512
		beq nine
    bx lr

////////////////////////DEFINITIONS////////////////////////
off:
	mov r0, #0b0000000
	str r0, [r3]
	b _main_loop
zero:
	mov r0, #0b0111111
    bx lr
one:
	mov r0, #0b0000110
    bx lr
two:
    mov r0, #0b1011011
    bx lr
three:
    mov r0, #0b1001111
    bx lr
four:
    mov r0, #0b1100110
    bx lr
five:
    mov r0, #0b1101101
    bx lr
six:
    mov r0, #0b1111101
    bx lr
seven:
    mov r0, #0b0000111
    bx lr
eight:
    mov r0, #0b1111111
    bx lr
nine:
    mov r0, #0b1100111
    bx lr

@ labels for constants and addresses
LED_BASE:		.word	0xFF200000
HEX3_HEX0_BASE:	.word	0xFF200020
SW_BASE:		.word	0xFF200040
DELAY_LENGTH:	.word	2
