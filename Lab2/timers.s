.equ MPCORE_PRIV_TIMER, 0xFFFEC600
.equ TIMER_CONTROL_SWITCHES, 0xFF200050
.equ TIMER_LAP_BUTTON, 0xFF200040
.equ HEX_DISPLAY_ONE, 0xFF200020
.equ HEX_DISPLAY_TWO, 0xFF200030



//R 1,2,3,4,5,6,7,8 taken
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
	cmp R6, #2
		beq stop_timer
		
	cmp R9, #1
		beq timer
		
	cmp R6, #1
		beq start_timer
	cmp R6, #3
		beq lap
	cmp R6, #4
		beq clear
 	b control_loop	
	
timer:
	ldr R8, [R0, #0xC]
	cmp R8,#0
	beq timer
	add R7, #1
	
	b read_buttons
	
	
	
control_loop:
	b read_buttons
	
	B control_loop
	
start_timer:
	MOV R5, #0b011
	STR R5, [R0, #0x8]
	MOV R9, #1
	b read_buttons

stop_timer:
	MOV R5, #0b010
	MOV R9, #0
	STR R5, [R0, #0x8]
	b read_buttons

lap:
	ldr R10, R7
	bx lr

clear:
	mov R7, #0
	bx lr

	


