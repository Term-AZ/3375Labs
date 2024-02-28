//feb 26
.equ timer, 0xFFFEC600
.equ DISPLAY, 0xff200020
.equ DISPLAY2, 0xFF200030
.equ SWITCH, 0xFF200040
.equ MEM, 0x0000000
.equ MEM2, 0xF000000
.text
.global _start
_start:
	LDR r0, =MEM
    LDR R1, =timer     // MPCore private timer base address
    LDR R2, =0             // start counter at 0 
	LDR R3, =20000000 //timeout = 1/(200 MHz) x 200x10^6 = 1 sec
    ldr r4, =0xff200050 //buttons
    ldr r7, =DISPLAY
	ldr r6, =DISPLAY2
	ldr r8, =SWITCH
    mov r12, #0x0000000
	ldr r11,=MEM2
    
    STR R3, [R1]             // write to timer load register
	STR r12, [r12]
	
	

_readButton:    
    //button stuff
    ldr r5, [r4]// read button 
    cmp r5, #1 
    	beq beginTimer
    cmp r5, #2
    	beq pause
	cmp r5, #4
		beq lapStore
    cmp r5, #8
    	beq clear
    
	ldrb r5, [r8,#0]
	cmp r5, #1
		beq display_lap
	
    b _readButton

display_lap:
	ldr r3, [r11]
	
	b _readButton

clear:
    mov r2, #0 //clear counter register
    b _readButton
    
lapStore: //store lap
	str r2, [r11]
    b WAIT
pause:
    mov r3, #0b0000 //stop timer
    str r3, [r1, #0x8]
    b _readButton

beginTimer:
    MOV R3, #0b011             // set bits: mode = 1 (auto), enable = 1
    STR R3, [R1, #0x8]         // write to timer control register
LOOP:
    add r2, r2, #1
    mov r9, #4
    mul r9, r2, r9
WAIT:
    LDR R3, [R1, #0xC]         // read timer status
    CMP R3, #0
    BEQ WAIT                 // wait for timer to expire
    	
    ldr r5, [r4]
    cmp r5, #2
    	beq pause
    cmp r5, #4
    	beq lapStore
    cmp r5, #8
    	beq clear
		
    STR R3, [R1, #0xC]         // reset timer flag bit
	
checker:
	//same logic for every check here. Number gets bigger as we use more sig figs of the byte
	//put counter value in memory 
	str r2, [r0]
	ldrb r5, [r0,#0] //load first byte of memory
	mov r10, #10 //set r10 to value 10 (00001010)
	
	AND r5, r5, r10 //AND operation to only get the least significant bits
	
	cmp r5, #10 //if it is equal to 10, then we need to go to the next sig fig
		beq b1
		
		
	ldrb r5, [r0,#0] //load first byte in memory
	mov r10, #160 //set r10 to 160 (10100000)
	AND r5, r5, r10 //AND operation to get only the most significant bits
	
	cmp r5, #160
		beq b2
	
	ldrb r5, [r0,#1]//load second byte ...
	mov r10, #10
	AND r5, r5, r10
	
	cmp r5, #10
		beq b3
	
	ldrb r5, [r0,#1]
	mov r10, #160
	AND r5, r5, r10
	
	cmp r5, #160
		beq b4
	
	ldrb r5, [r0,#2]
	mov r10, #10
	AND r5, r5, r10
	
	cmp r5, #10
		beq b5
	
	ldrb r5, [r0,#2]
	mov r10, #160
	AND r5, r5, r10
	
	cmp r5, #160
		beq b6
		
	b displayNumber

//everything below manipulates the whole register (4 bytes) to display only 1-9. We store digit in 4 bits. 
//altogether we use a total of 3 bytes for the whole display.
b1:
	add r2, r2, #16
	sub r2, r2,#10
	b displayNumber
b2:
	add r2, r2, #256
	sub r2, r2,#160
	b displayNumber
b3:
	ldr r5, =#4096
	add r2, r2, r5
	ldr r5, =#2560
	sub r2, r2, r5
	b displayNumber
b4:
	ldr r5, =#65536
	add r2, r2, r5
	ldr r5, =#40960
	sub r2, r2, r5
	b displayNumber
	
b5:
	ldr r5, =#1048576
	add r2, r2, r5
	ldr r5, =#655360
	sub r2, r2, r5
	b displayNumber

b6:
	mov r2, #0

displayNumber:
	str r2, [r0] //restore r2 incase of any updates after
  	mov r12, #0x0000000 //reset display values
	
	ldrb r5, [r0,#2] //load most significant byte
	mov r10, #240 //set up AND mask (11110000)
	AND r5, r5, r10 //AND operation
	
	bl _find_number //set binary value
	
	lsl r12, #8 //shift register values left by 1 byte
	
	ldrb r5, [r0,#2] //relaod most significant byte
	mov r10, #15 //set up AND mask (00001111)
	AND r5, r5, r10 //AND operation
	
	bl _find_number //set binary value
	
	str r12, [r6] //upload to display
	mov r12, #0x0000000 //reset r12 to begin next four digits. 
	
	ldrb r5, [r0,#1]
	mov r10, #240
	AND r5, r5, r10
	
	bl _find_number
	
	lsl r12, #8

	ldrb r5, [r0,#1]
	mov r10, #15
	AND r5, r5, r10
	
	bl _find_number
	
	lsl r12, #8
	
	ldrb r5, [r0,#0]
	mov r10, #240
	AND r5, r5, r10
	
	bl _find_number
	
	lsl r12, #8

	ldrb r5, [r0,#0]
	mov r10, #15
	AND r5, r5, r10
	
	bl _find_number
	
	str r12, [r7]
	mov r12, #0x0000000

    bal LOOP

_find_number:
	cmp r5, #0
		beq zero
    cmp r5, #1      
        beq one      
    cmp r5, #2
        beq two
    cmp r5, #3
        beq three
    cmp r5, #4
        beq four
    cmp r5, #5
        beq five
    cmp r5, #6
        beq six
    cmp r5, #7
        beq seven
    cmp r5, #8
        beq eight
    cmp r5, #9
        beq nine
	cmp r5, #10
		beq zero
    bx lr

////////////////////////DEFINITIONS////////////////////////
zero:
	add r12, r12, #0b0111111
    bx lr
one:
	add r12, r12, #0b0000110
    bx lr
two:
    add r12, r12, #0b1011011
    bx lr
three:
    add r12, r12, #0b1001111
    bx lr
four:
    add r12, r12, #0b1100110
    bx lr
five:
    add r12, r12, #0b1101101
    bx lr
six:
    add r12, r12, #0b1111101
    bx lr
seven:
    add r12, r12, #0b0000111
    bx lr
eight:
    add r12, r12, #0b1111111
    bx lr
nine:
    add r12, r12, #0b1100111
    bx lr


.data

array: .word 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67

.end
