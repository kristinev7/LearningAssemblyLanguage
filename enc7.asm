;Lab 4 Encryption
;Program to encrypt strings w user input using encryption key via toggling using 
;  XOR technique
; Encryption key is stored in x3100
;The message is restricted to a maximum of 32 characters stored in x3110 to x311F
;The last ASCII code of the text string must be EOT (x04)
;The task: the lower 4 bits of the code is toggled using XOR 
;Add the key to the result of the toggled
;The result is stored at location x3120 to x312F
; 			SUBMITTED

	.ORIG x3000
	AND R0, R0, #0
	AND R1, R1, #0
	AND R2, R2, #0
	AND R3, R3, #0
	AND R4, R4, #0
	AND R5, R5, #0
	AND R6, R6, #0
	AND R7, R7, #0
	LD R3, MSG			; R3 HAS M[X310F]
	ADD R3, R3, #1			; INCREMENT M[X310F] TO GO TO NEXT LOCATION
	LEA R0, INP1			; ASK FOR MESSAGE
	PUTS				; PRINT TO CONSOLE
READ	IN				; RETRIEVE MESSAGE
	ADD R2, R0, #-10		; TEST FOR END OF LINE
	BRz WARN1
	BRnp STORE
READ2 	IN
	ADD R1, R0, #-10
	BRz LOAD
	BRnp STORE			; IF 0 ERROR

STORE 	STR R0, R3, #0
	ADD R3, R3, #1
	BRnzp READ2
	
LOAD	LD R3, MSG			; R3 HAS M[X310F]
	LD R4, RES			; R4 HAS M[X311F]

GET	ADD R6, R6, #4			; COUNTER
	LD R1, MSK			; MASK FOR TOGGLE
	ADD R3, R3, #1			; INCREMENT TO REACH APPROPRIATE MEM LOCATION
	ADD R4, R4, #1			; INCREMEN TO REACH APPROPRIATE MEM LOCATION
	LDR R2, R3, #0			; GET THE CHARACTER
	ADD R5, R2, #0			; TEST FOR ENDING
	BRz END
	
TOGGLE	NOT R5, R2
	AND R5, R5, R1
	NOT R7, R1			; XOR TECHNIQUEFOR TOGGLE
	AND R2, R2, R7
	ADD R2, R2, R5
	ADD R1, R1, R1
	ADD R6, R6, #-1
	BRz ENCRYPT
	BRp TOGGLE

ENCRYPT	LD R1, KEY
	ADD R2, R1, R2			; KEY + CHAR = ENCRYPT
	STR R2, R4, #0
	BRnzp GET

END	LEA R0, INP2
	PUTS
	LD R1, RES

LOOP	ADD R1, R1, #1
	LDR R0, R1, #0
	ADD R0, R0, #0
	BRz FINISH
	OUT
	BRnzp LOOP

WARN1	LEA R0, ERROR
	PUTS
	BRnzp READ2

FINISH	LEA R0, SPACE
	PUTS
;
;DECRYPT MESSAGE
;Decryption algorithm is as follows. Each ASCII code in the message will be transformed as follows: 
;	Subtract the encryption key from the ASCII code.
;	Toggle the low order bit of the result of step 1. 
;	The result should be stored back to location x3110 to x311F.
;
	AND R0, R0, #0
	AND R1, R1, #0
	AND R2, R2, #0
	AND R3, R3, #0
	AND R4, R4, #0
	AND R5, R5, #0
	AND R6, R6, #0
	AND R7, R7, #0
	
	LEA R0, INP3		;ASK USER IF THEY WANT MESSAGE DECRYPTED
	PUTS
	
CHECK  	IN			;TAKE INPUT
	ADD R1, R0 #0		;PUT INPUT IN R1		
	LD R3, CHRNY		; NEG OF Y
	ADD R2, R1, R3 		;CHECK IF Y MATCHES, IF ZERO IT DOES GO TO LOAD2, ELSE ERROR 	
	BRz LOAD2		;
	LD R4, CHRNN		; NEG OF N
	ADD R5, R1, R4		;
	BRz FIN			
	BRnp WARN2

LOAD2	LD R6, RES		; R6 HAS M[X311F]
	LD R7, MSG		; R7 HAS M[X310F]	

GET2	AND R1, R1, #0		;CLEAR REGISTERS
	AND R2, R2, #0
	AND R3, R3, #0
	AND R4, R4, #0
	AND R5, R5, #0
	ADD R2, R2, #4			;COUNTER FOR TOGGLE
	LD R1, MSK			;MASK FOR TOGGLE
	ADD R6, R6, #1			;INCREMENT TO M[X3120]
	ADD R7, R7, #1			;INCREMENT TO M[X3110]
	LDR R3, R6, #0			; R3 HAS FIRST CHAR FROM ENCRYPTED M[X3120]
	ADD R5, R3, #0			;CHECK END OF LINE
	BRz GOODBYE			; DONE MESSAGE END

SUBKEY	LD R5, KEY 			; R5 HAS X0006
	NOT R5, R5
	ADD R5, R5, #1			;NEG OF KEY : -6
	ADD R3, R3, R5			; SUBTRACT KEY FROM CHAR

;XOR TECHNIQUE FOR TOGGLE

TOGGLE1 NOT R5, R3			;NOT THE FIRST CHAR
	AND R5, R5, R1			; ADD MASK TO R5
	NOT R4, R1			; NOT MASK
	AND R3, R3, R4			; ADD CHAR AND NOT MASK
	ADD R3, R3, R5			; NOT CHAR + NOT MASK = PUT IN R3
	ADD R1, R1, R1			; SHIFT MASK
	ADD R2, R2, #-1			; DECREMENT COUNTER
	BRz STORE2
	BRp TOGGLE1

STORE2	STR R3, R7, #0			; STORE RES IN M[X3110]
	BRnzp GET2

GOODBYE LEA R0, INP4			; OUTPUT THE DECRYPTED MSG FROM M[X3110]
	PUTS
	LD R1, MSG

LOOP2	ADD R1, R1, #1			; INCREMENT M[X3110]
	LDR R0, R1, #0			; PUT CHAR IN R0
	ADD R0, R0, #0			; TEST FOR END OF LINE
	BRz FIN				; DONE
	OUT
	BRnzp LOOP2			;KEEP LOOPING UNTIL FINISH

WARN2	LEA R0, ERROR			;INPUT MUST BE Y OR N, NOT y or n
	PUTS
	BRnzp CHECK			;RETURN TO CHECK

FIN	LEA R0, SPACE			;PROGRAM IS DONE
	PUTS
	HALT
CHRNN	.FILL XFFB2			;NEG OF N
CHRNY	.FILL XFFA7			;NEG OF Y		
KEY	.FILL X0006
MSK	.FILL x0001
EOL	.FILL x0010
MSG 	.FILL x310F
RES	.FILL x311F
ERROR	.STRINGZ "TRY AGAIN.\n"
SPACE 	.STRINGZ "\nDONE\n"
INP1	.STRINGZ "ENTER MESSAGE(32 CHAR LIMIT): "
INP2	.STRINGZ "ENCRYPTED MESSAGE IS: "
INP3	.STRINGZ "\nDECRYPT MESSAGE? TYPE Y OR N.\n"
INP4	.STRINGZ "DECRYPTED MSG IS: "
		.END