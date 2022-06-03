.global _start
_start:

MOV R12, # 23
MOV R11, #13
AND R12, R11


	// Timer is configured below. This timer will run nonstop through program.
	LDR R0, =0xFFFEC600
	LDR R1, =200000 
	STR R1, [R0]
	
	MOV R1, #3
	STR R1, [R0, #8] // Start & loop the timer.

	LOOP:
	LDR R0, =0xFF200050 // Pushbutton key address.
	LDR R1, [R0, #12]
	
	CMP R1, #1 // Edgecapture check for 1 (draw a card)
	STREQ R1, [R0, #12]
	BLEQ ADDCARD
	
	
	B LOOP
	
	// A subroutine that adds a random card to players roster on demand.
	ADDCARD: PUSH {R0, R1, LR}
	
		LDR R0, =0xFFFEC600
		LDR R1, [R0, #4] // Get the random value
		
		SUBS R1, #13 // Division by 13
		
		
		//Exception, when card sum is less than 10, value of ACE is automatically 11
		CMP R1, #0
		CMPEQ R2, #10
		MOVLT R1, #13 
		
		
		
		
		POP {R0, R1, PC}
	


HEXCARDS: .byte 0x0, 0x0, 0x0, 0x0 // These values will be for the hexadecimal card values.
CARDS:.byte 0x1, 0x2, 0x2, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xa, 0xa, 0xa, 0xa, 0xb, 0x0, 0x0
CARDSLEFT: .byte 0x4, 0x4, 0x4, 0x4, 0x4, 0x4,0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x0, 0x0, 0x0

