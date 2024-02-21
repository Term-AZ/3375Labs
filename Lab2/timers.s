.equ MPCORE_PRIV_TIMER, 0xFFFEC600
.equ TIMER_CONTROL_SWITCHES, 0xFF200050
.equ TIMER_LAP_BUTTON, 0xFF200040
.equ HEX_DISPLAY_ONE, 0xFF200020
.equ HEX_DISPLAY_TWO, 0xFF200030

.global _start
_start:
	LDR R0, =MPCORE_PRIV_TIMER
	LDR R1, =HEX_DISPLAY_ONE
	LDR R2, =HEX_DISPLAY_TWO
	LDR R3, =TIMER_CONTROL_SWITCHES
	LDR R4, =TIMER_LAP_BUTTON
	LDR R5, =2000000
	mov R6, #0
	STR R5, [R0]
	b control_loop
	
read_buttons:
	ldrb R6, [R3, #0]
	ldr R8, [R0, #0x8]
	
	cmp R6, #1
		beq start_timer
	cmp R6, #2
		beq stop_timer
	cmp R6, #3
		beq lap
	cmp R6, #4
		beq clear
	bx lr	
	
timer:
	ldr R8, [R0, #0xC]
	cmp R8,#0
	beq timer
	add R7, #1
	
	
	
	
control_loop:
	b read_buttons
	
	B control_loop
	
start_timer:
	MOV R5, #0b011
	STR R5, [R0, #0x8]
	b control_loop

stop_timer:
	MOV R5, #0b010
	STR R5, [R0, #0x8]
	bx lr

lap:
	
	bx lr

clear:

	bx lr

	


