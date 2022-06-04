.global _start
_start:
	// Timer is configured below. This timer will run nonstop through program.
	LDR R0, =0xFFFEC600
	LDR R1, =200000 
	STR R1, [R0]
	
	
	MOV R1, #3
	STR R1, [R0, #8] // Start & loop the timer.
	MOV R3, #0 // player's value

	LOOP:
	LDR R0, =0xFF200050 // Pushbutton key address.
	LDR R1, [R0, #12]
	
	// Player draws a card
	CMP R1, #1 // Edgecapture check for 1 (draw a card)
	STREQ R1, [R0, #12]
	BLEQ ADDCARD
	
	//Dealer (machine) draws a card
	B LOOP
	// A subroutine that adds a random card to players roster on demand.
	// Takes card value to r2, returns drawn card to r3, 
	ADDCARD: PUSH {R0, R1, LR}
		
		DRAWCARD:
		LDR R0, =0xFFFEC600
		LDR R1, [R0, #4] // Get the random value
		
		
		AND R1, R1, #0b1111 // mask last 4 bits
		SUBS R1, #12 // Division by 13 
		BGT DRAWCARD // If number is greater than 12, draw again
		ADDLE R1, #12 // if number is less than 12, continue
		MOV R11, R1
		
		DISPLAYDRAWNCARD:
		LDR R3, =0xff200020 // address of 7-segment display
		LDR R4, =HEXDISPLAYCARDS
		LDR R5, =CARDVALUES
		LDR R4, [R4, R1, LSL #2]   // 4 * 10   J
		STR R4, [R3] // display the drawn card
		
		
		//Exception, when card sum is less than 10, value of ACE is automatically 11
		CMP R1, #0
		CMPEQ R2, #10
		MOVLT R1, #13 
		
		LDR R4, [R5, R1, LSL #2] // get the value of J
		ADD R2, R2, R4
						
		POP {R0, R1, PC}
	

CARDSLEFT: .word 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4
// Corresponding hex values to display all cards (13)
HEXDISPLAYCARDS: .word 0x77, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07,0x7F,0x6F, 0x063F, 0xE, 0xE7 , 0x75
// HEX VAlUES of numbers 0-26 to display
HEXTABLE: .word 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x063F, 0x0606, 0x065B, 0x064F, 0x0666, 0x066D, 0x067D, 0x0607, 0x067F, 0x066F, 0x5B3F, 0x5B06, 0x5B5B, 0x5B4F, 0x5B66, 0x5B6D, 0x5B7D
// Values of each different cards(total of 13)  A's value should be 11 if the current value is below 10
CARDVALUES: .word 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xA, 0xA, 0xA, 0xA, 0xB 
