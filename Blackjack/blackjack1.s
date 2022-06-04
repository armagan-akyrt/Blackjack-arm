.global _start
_start:

	LDR R1, =HEXTABLE //hex table, contains 7-segment values of 0-9
	LDR R2, =0xff200020 // address of 7-segment display
	//LDRB R4, [R1] // load number of elements in the table to r4
	LDR R3, =HEXDISPLAYCARDS
	LDR R6, =CARDVALUES
	
	LDR R5, [R1] // Write hex equivalent of index
	STR R5, [R2] // write to 7-segment
	
	
	// Try 1
	// start with value 0
	MOV R10, #0
	// assume J and 4 are drawn
	MOV R8, #10   // J is drawn
	// timer 
	LDR R5, [R3, R8, LSL #2]   // 4 * 10   J
	STR R5, [R2] // display the drawn card
	LDR R7, [R6, R8, LSL #2] // get the value of J
	ADD R10, R10, R7
	
	MOV R8, #3
	
	LDR R5, [R3, R8, LSL #2]   // 3 * 4   4
	STR R5, [R2] // display the drawn card
	LDR R7, [R6, R8, LSL #2] // get the value of 4
	ADD R10, R10, R7
	
	
	// show the current value
	LDR R5, [R1, R10, LSL #2]   // J + 4 = 14   ((14)*4)++
	STR R5, [R2, #16] // write to 7-segment
	
		 
	end: B end		

		
// Corresponding hex values to display all cards (13)
HEXDISPLAYCARDS: .word 0x77, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07,0x7F,0x6F, 0x063F, 0xE, 0xE7 , 0x75
// HEX VAlUES of numbers 0-26 to display
HEXTABLE: .word 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x063F, 0x0606, 0x065B, 0x064F, 0x0666, 0x066D, 0x067D, 0x0607, 0x067F, 0x066F, 0x5B3F, 0x5B06, 0x5B5B, 0x5B4F, 0x5B66, 0x5B6D, 0x5B7D
// Values of each different cards(total of 13)  A's value should be 11 if the current value is below 10
CARDVALUES: .word 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xA, 0xA, 0xA, 0xA, 0xB 

	
	