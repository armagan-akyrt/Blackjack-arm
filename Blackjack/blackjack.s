.global _start
_start:
	// Reset 7-segment in reload
	LDR R0, =0xff200020
	MOV R1, #0
	STR R1, [R0]
	STR R1, [R0, #16]
	// Timer is configured below. This timer will run nonstop through program.
	LDR R0, =0xFFFEC600
	LDR R1, =20000000
	STR R1, [R0]
    
	MOV R1, #3 // A=1, E=1
	STR R1, [R0, #8] // Start & loop the timer.
	MOV R3, #0 // player's value
	MOV R4, #0 // dealer's value
	MOV R7, #0 // turn indicator
			
	LOOP:
	LDR R0, =0xFF200050 // Pushbutton key address.
	LDR R1, [R0, #12]
	
	// if anything other than key0 is pressed, resets edge capture
	CMP R1, #2
	STRGE R1, [R0, #12]
	
	// Player draws a card
	MOV R7, #0
	CMP R1, #1 // Edgecapture check for 1 (draw a card)
	STREQ R1, [R0, #12]
	MOV R2, R3
	BLEQ ADDCARD
	MOV R3, R2 // move the card sum calculated in 'ADDCARD'
	MOV R2, #0
	
	//Delay
	CMP R1, #1
	MOVEQ R1, #0
	BLEQ DO_DELAY
	
	//Dealer (machine) draws a card
	MOV R7, #1
	MOV R2, R4
	BLEQ ADDCARD
	MOV R4, R2 // move the card sum calculated in 'ADDCARD'
	MOV R2, #0
	
	// check whether both player and dealer have the card sum greater than 17
	// to determine the result
	CMP R3, #17
	CMPGE R4, #17
	BGE WINLOSE
	
	B LOOP
	
	// A subroutine that adds a random card to players roster on demand.
	// Takes card value to r2, returns drawn card to r3, 
	ADDCARD: PUSH {R0, R1, R3-R8, lr}
		
		DRAWCARD:
		CMP R2, #17
		POPGE {R0, R1, R3-R8, PC}
		LDR R0, =0xFFFEC600
		LDR R1, [R0, #4] // Get the random value
		
		AND R1, R1, #0b1111 // mask last 4 bits
		SUBS R1, #12 // Division by 13 
		BGT DRAWCARD // If number is greater than 12, draw again
		ADDLE R1, #12 // if number is less than 12, continue
		
		
		ROSTERCHECK:
		LDR R3, =CARDSLEFT
		LDR R4, [R3, R1, LSL #2] // number of cards left of that type
		
		SUBS R4, #1
			STRPL R4, [R3, R1, LSL #2]
			BPL DISPLAYDRAWNCARD // if drawn card is negative, branch to display
			BMI DRAWCARD  // if negative draw again.
		
		DISPLAYDRAWNCARD:
		LDR R3, =0xff200020 // address of 7-segment display
		LDR R4, =HEXDISPLAYCARDS
		LDR R5, =CARDVALUES
		LDR R4, [R4, R1, LSL #2] // load the memory address of cards' hex values
		LDR R8, [R3] // load rightmost four seven-segment displays
		LDR R12, =0b1111111111111111 // temp for masking card display
		BIC R8, R8, R12 // delete card display 
		ADD R4, R4, R8 // insert new card
		STR R4, [R3] // display the drawn card
		BL DO_DELAY
		
		//Exception, when card sum is less than 10, value of ACE is automatically 11
		CMP R1, #0
		CMPEQ R2, #11
		MOVLT R1, #13 
		
		LDR R4, [R5, R1, LSL #2] // get the value of drawn card
		ADD R2, R2, R4 // calculate the card sum
		LDR R6, =HEXTABLE
		
		LDR R4, [R6, R2, LSL #2]   // load the hex value of the card to show on seven-segment displays
		CMP R7, #0  // check whether it is the player's turn to draw
		
		STREQ R4, [R3, #16] // write the card sum to 7-segment
		BGT WRITE // dealer's turn
						
		POP {R0, R1, R3-R8, PC}
		
	// this writes the values of dealer to the 7-segment	
	WRITE: 
		LDR R5, [R3]
		LSL R4, #16 // shift 16 bits to the left 
		
		// show the card sum of dealer on 7-segment displays
		AND R5, R12
		ADD R5, R5, R4
		STR R5, [R3]
		POP {R0, R1, R3-R8, PC}
		
	// A subroutine that performs the necessary operations to show the result on the seven-segment displays.
	WINLOSE:
		CMP R3, R4 // Compare the card sum of the player(R3), and the dealer(R4)
		MOVEQ R0, #2 // tie
		BEQ SHOWRESULT // Shows the results in seven-segment displays
	
		CMP R3, #21
		BLE WIN //  card sum < 21 condition
		BGT LOSE // card sum > 21 condition
	
	// A subroutine that is used in WINLOSE subroutine to consider the cases which 
	// the player has the card sum equal to or less than 21.
	WIN:
		CMP R3, R4
		MOVGT R0, #0 // win
		MOVLT R0, #1 // lose
		CMP R0, #0
		BEQ SHOWRESULT // Shows the results in seven-segment displays
		CMPNE R4, #21
		MOVLE R0, #1 // lose
		MOVGT R0, #0 // win
		B SHOWRESULT // Shows the results in seven-segment displays
	
	// A subroutine that is used in WINLOSE subroutine to consider the cases which 
	// the player has the card sum above 21.
	LOSE:
		CMP R4, #21
		MOVGT R0, #2 // both are above 21 -> TIE
		MOVLE R0, #1 // dealer has card sum between 17-21 -> LOSE
		B SHOWRESULT // Shows the results in seven-segment displays
	
	// This subroutine takes the indexes (0, 1, 2) representing
	// win, lose, and tie in order. Then shows the result on the
	// seven-segment display.
	SHOWRESULT:
		LDR R10, =CONDITIONS  // win, lose, tie
		LDR R11, [R10, R0, LSL #2] // index is multiplied by 4 due to use of words in allocation
		
		LDR R12, =0xff200020 // address of seven-segment displays
		STR R11, [R12] // necessary result is shown in seven-segment displays
		B RESETDECK
	
	// reset the deck ( write every memory slot corresponding a card: 4)
	RESETDECK:
		LDR R0, =CARDSLEFT
		MOV R1, #0 // initial index of the deck
		MOV R2, #4 // four cards of each type
	
	TAG: // to return until index is last
		CMP R1, #12
		STRLE R2, [R0, R1, LSL #2] 
		ADDLE R1, #1
		BLE TAG
	
		B end
	
	// A subroutine that is used to put a time delay in wanted conditions
	DO_DELAY: 
		PUSH {R8, lr}
		LDR R8, =3548654 // delay counter
		SUB_LOOP: SUBS R8, R8, #1
		BNE SUB_LOOP
		POP {R8, PC}
		
	end: 
		LDR R0, =0xFF200050 // Pushbutton key address.
		LDR R1, [R0, #12]
		
		CMP R1,#8 // if key3 is pressed, restarts the game.
		STRGE R1, [R0, #12]
		BGE _start
		B end

// number of cards are stored in the memory (4*13)
CARDSLEFT: .word 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4, 0x4
// Corresponding hex values to display all cards (13)
HEXDISPLAYCARDS: .word 0x77, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07,0x7F,0x6F, 0x063F, 0xE, 0xE7 , 0x75
// HEX VAlUES of numbers 0-26 to display
HEXTABLE: .word 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x063F, 0x0606, 0x065B, 0x064F, 0x0666, 0x066D, 0x067D, 0x0607, 0x067F, 0x066F, 0x5B3F, 0x5B06, 0x5B5B, 0x5B4F, 0x5B66, 0x5B6D, 0x5B7D
// Values of each different cards(total of 13)  A's value should be 11 if the current value is below 10
CARDVALUES: .word 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xA, 0xA, 0xA, 0xA, 0xB
// Results' hex values (win, lose, tie)
CONDITIONS: .word 0x3C1E5C54, 0x385C6D78, 0x00783079
