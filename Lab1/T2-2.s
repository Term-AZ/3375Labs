//DISPLAYS HEX
@ .text
@ .equ switches, 0xFF200040
@ .equ ssd, 0xFF200020  /* Address of seven-segment display. */

@ .global _start
@ _start:
@         LDR r2, =switches    
@         LDR r4, =ssd  
		
@ LOOP:   
@ 		LDR r3, [r2]         

@         bl findNumber

@         B CONTINUE         
@         MOV r3, #0           
@ CONTINUE:
@         STR r3, [r4]         
@         B LOOP

@ findNumber:
@     CMP r3, #1      
@         beq one      
@     cmp r3, #2
@         beq two
@     cmp r3, #3
@         beq three
@     cmp r3, #4
@         beq four
@     cmp r3, #5
@         beq five
@     cmp r3, #6
@         beq six
@     cmp r3, #7
@         beq seven
@     cmp r3, #8
@         beq eight
@     cmp r3, #9
@         beq nine
@     bx lr

@ ////////////////////////DEFINITIONS////////////////////////
@ zero:
@     mov r3, #0b0111111
@     bx lr
@ one:
@     mov r3, #0b0000110
@     bx lr
@ two:
@     mov r3, #0b1011011
@     bx lr
@ three:
@     mov r3, #0b1001111
@     bx lr
@ four:
@     mov r3, #0b1100110
@     bx lr
@ five:
@     mov r3, #0b1101101
@     bx lr
@ six:
@     mov r3, #0b1111101
@     bx lr
@ seven:
@     mov r3, #0b0000111
@     bx lr
@ eight:
@     mov r3, #0b1111111
@     bx lr
@ nine:
@     mov r3, #0b1100111
@     bx lr

@ .end