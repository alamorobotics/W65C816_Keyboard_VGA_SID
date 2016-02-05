; File: W65C816_Keyboard_VGA_SID_01.asm
; 12/26/2015

;############################# DESCIPTION ########################

; This poject will add a couple of W65C22 VIAs to read a
; Commodore 64 keyboard and interface with a propeller for VGA and SID emulation.

; So far I have hooked up the first extra VIA and mapped it to $7F00.
;

;#################################################################

	PW 80          ;Page Width (# of char/line)
	PL 60          ;Page Length for HP Laser
	INCLIST ON     ;Add Include files in Listing

;*********************************************
;Test for Valid Processor defined in -D option
;*********************************************
	IF USING_816
	ELSE
		EXIT  "Not Valid Processor: Use -DUSING_02, etc."
	ENDIF

	TITLE  "W65C816_Keyboard_VGA_SID W65C816_Keyboard_VGA_SID_01.asm"
	STTL

;########################### I/O addreses #####################
	
VIA_KEY_BASE	EQU $7F00		; base address of extra VIA on SXB used for the Keyboard
VIA_KEY_ORB		EQU VIA_KEY_BASE
VIA_KEY_IRB		EQU VIA_KEY_BASE
VIA_KEY_ORA		EQU VIA_KEY_BASE+1
VIA_KEY_IRA		EQU VIA_KEY_BASE+1
VIA_KEY_DDRB	EQU VIA_KEY_BASE+2
VIA_KEY_DDRA	EQU VIA_KEY_BASE+3
VIA_KEY_T1CLO	EQU VIA_KEY_BASE+4
VIA_KEY_T1CHI	EQU VIA_KEY_BASE+5
VIA_KEY_T1LLO	EQU VIA_KEY_BASE+6
VIA_KEY_T1LHI	EQU VIA_KEY_BASE+7
VIA_KEY_T2CLO	EQU VIA_KEY_BASE+8
VIA_KEY_T2CHI	EQU VIA_KEY_BASE+9
VIA_KEY_SR		EQU VIA_KEY_BASE+10
VIA_KEY_ACR		EQU VIA_KEY_BASE+11
VIA_KEY_PCR		EQU VIA_KEY_BASE+12
VIA_KEY_IFR		EQU VIA_KEY_BASE+13
VIA_KEY_IER		EQU VIA_KEY_BASE+14
VIA_KEY_ORANH	EQU VIA_KEY_BASE+15
VIA_KEY_IRANH	EQU VIA_KEY_BASE+15

VIA_PROP_BASE	EQU $7F20		; base address of extra VIA on SXB used for the Propeller
VIA_PROP_ORB	EQU VIA_PROP_BASE
VIA_PROP_IRB	EQU VIA_PROP_BASE
VIA_PROP_ORA	EQU VIA_PROP_BASE+1
VIA_PROP_IRA	EQU VIA_PROP_BASE+1
VIA_PROP_DDRB	EQU VIA_PROP_BASE+2
VIA_PROP_DDRA	EQU VIA_PROP_BASE+3
VIA_PROP_T1CLO	EQU VIA_PROP_BASE+4
VIA_PROP_T1CHI	EQU VIA_PROP_BASE+5
VIA_PROP_T1LLO	EQU VIA_PROP_BASE+6
VIA_PROP_T1LHI	EQU VIA_PROP_BASE+7
VIA_PROP_T2CLO	EQU VIA_PROP_BASE+8
VIA_PROP_T2CHI	EQU VIA_PROP_BASE+9
VIA_PROP_SR		EQU VIA_PROP_BASE+10
VIA_PROP_ACR	EQU VIA_PROP_BASE+11
VIA_PROP_PCR	EQU VIA_PROP_BASE+12
VIA_PROP_IFR	EQU VIA_PROP_BASE+13
VIA_PROP_IER	EQU VIA_PROP_BASE+14
VIA_PROP_ORANH	EQU VIA_PROP_BASE+15
VIA_PROP_IRANH	EQU VIA_PROP_BASE+15

VIA_BASE		EQU $7FC0		; base address of VIA port on SXB
VIA_ORB			EQU VIA_BASE
VIA_IRB			EQU VIA_BASE
VIA_ORA			EQU VIA_BASE+1
VIA_IRA			EQU VIA_BASE+1
VIA_DDRB		EQU VIA_BASE+2
VIA_DDRA		EQU VIA_BASE+3
VIA_T1CLO		EQU VIA_BASE+4
VIA_T1CHI		EQU VIA_BASE+5
VIA_T1LLO		EQU VIA_BASE+6
VIA_T1LHI		EQU VIA_BASE+7
VIA_T2CLO		EQU VIA_BASE+8
VIA_T2CHI		EQU VIA_BASE+9
VIA_SR			EQU VIA_BASE+10
VIA_ACR			EQU VIA_BASE+11
VIA_PCR			EQU VIA_BASE+12
VIA_IFR			EQU VIA_BASE+13
VIA_IER			EQU VIA_BASE+14
VIA_ORANH		EQU VIA_BASE+15
VIA_IRANH		EQU VIA_BASE+15

PIA_BASE		EQU $7FA0		; base address of PIA port on SXB
PIA_ORA			EQU PIA_BASE
PIA_IRA			EQU PIA_BASE
PIA_DDRA		EQU PIA_BASE
PIA_CTRLA		EQU PIA_BASE+1
PIA_ORB			EQU PIA_BASE+2
PIA_IRB			EQU PIA_BASE+2
PIA_DDRB		EQU PIA_BASE+2
PIA_CTRLB		EQU PIA_BASE+3

ACIA_BASE		EQU $7F80		; base address of ACIA on SXB
ACIA_RXD		EQU ACIA_BASE
ACIA_TXD        EQU ACIA_BASE
ACIA_SR         EQU ACIA_BASE+1
ACIA_CMD        EQU ACIA_BASE+2
ACIA_CTL        EQU ACIA_BASE+3

;########################### Propeller addreses #####################

VGA_BASE		EQU $00			; "base address" of VGA, this address is sent to the propeller
VGA_PRINT		EQU VGA_BASE
VGA_COL			EQU VGA_BASE+$01
VGA_ROW			EQU VGA_BASE+$02
VGA_ROW_COLOR	EQU VGA_BASE+$03
VGA_ROW_BACK	EQU VGA_BASE+$04
VGA_AUTO_INC	EQU VGA_BASE+$05
VGA_FILL_CHAR	EQU VGA_BASE+$06
VGA_FILL_COL	EQU VGA_BASE+$07
VGA_FILL_BACK	EQU VGA_BASE+$08
VGA_SCROLL_UP	EQU VGA_BASE+$09
VGA_SCROLL_DN	EQU VGA_BASE+$0A

VGA_CUR1_X		EQU VGA_BASE+$10
VGA_CUR1_Y		EQU VGA_BASE+$11
VGA_CUR1_MODE	EQU VGA_BASE+$12
VGA_CUR2_X		EQU VGA_BASE+$13
VGA_CUR2_Y		EQU VGA_BASE+$14
VGA_CUR2_MODE	EQU VGA_BASE+$15

SID_BASE		EQU $20		; "base address" of SID emulation, this address is sent to the propeller
SID_FR1LO		EQU SID_BASE
SID_FR1HI		EQU SID_BASE+$01
SID_PW1LO		EQU SID_BASE+$02
SID_PW1HI		EQU SID_BASE+$03
SID_CR1			EQU SID_BASE+$04
SID_AD1			EQU SID_BASE+$05
SID_SR1			EQU SID_BASE+$06

SID_FR2LO		EQU SID_BASE+$07
SID_FR2HI		EQU SID_BASE+$08
SID_PW2LO		EQU SID_BASE+$09
SID_PW2HI		EQU SID_BASE+$0A
SID_CR2			EQU SID_BASE+$0B
SID_AD2			EQU SID_BASE+$0C
SID_SR2			EQU SID_BASE+$0D

SID_FR3LO		EQU SID_BASE+$0E
SID_FR3HI		EQU SID_BASE+$0F
SID_PW3LO		EQU SID_BASE+$10
SID_PW3HI		EQU SID_BASE+$11
SID_CR3			EQU SID_BASE+$12
SID_AD3			EQU SID_BASE+$13
SID_SR3			EQU SID_BASE+$14

SID_FCLO		EQU SID_BASE+$15
SID_FCHI		EQU SID_BASE+$16
SID_RESFIL		EQU SID_BASE+$17
SID_MODVOL		EQU SID_BASE+$18

;########################### Zero Page #####################

; String Pointers
StringLo		EQU $10 ; Low pointer
StringHi		EQU $11 ; High pointer

; Temp Storage
Temp			EQU $12 ; Temp storage
Temp1			EQU $13 ; Temp storage
Temp2			EQU $14 ; Temp storage
Temp3			EQU $15 ; Temp storage

KeyMapLo		EQU $20 ; Low pointer
KeyMapHi		EQU $21 ; High pointer
KeyRow00		EQU $22 ; Keyboard Matrix row 0
KeyRow01		EQU $23 ; Keyboard Matrix row 1
KeyRow02		EQU $24 ; Keyboard Matrix row 2
KeyRow03		EQU $25 ; Keyboard Matrix row 3
KeyRow04		EQU $26 ; Keyboard Matrix row 4
KeyRow05		EQU $27 ; Keyboard Matrix row 5
KeyRow06		EQU $28 ; Keyboard Matrix row 6
KeyRow07		EQU $29 ; Keyboard Matrix row 7
KeyBitpos		EQU $2A	; Current bit Position
KeyMatrixpos	EQU $2B	; Current Position in Matrix
KeyCTRLKeys		EQU $2C ; Conntrol keys: L Shift, CTRL, Run/Stop, R Shift, Commodore. L Shift is also Shift Lock.
KeyRaw			EQU $2D ; Raw value 0-63, , if no key pressed, 128...
KeyCoded		EQU $2E ; ASCII encoded Value
KeyPrevious		EQU $2F ; Raw previous value, if no key pressed, 128...

KeyX 			EQU $30 ; Cursor X
KeyY 			EQU $31 ; Cursor Y


;########################### Main Program #####################

	CHIP 65C02
	LONGI OFF
	LONGA OFF

	.STTL "W65C816_Keyboard_VGA_SID"
	.PAGE
				ORG $0200
START

				JSR init_ACIA			; Init ACIA
				JSR	init_Keyboard		; Setup Keyboard and VIA_KEY
				JSR init_Propeller		; Setup Propeller communication
				
				LDA #$20				; Blank Screen
				LDX #VGA_FILL_CHAR
				JSR writeToPropeller
				
				LDA #02					; Red
				LDX #03					; Green
				LDY #00					; Blue
				JSR calc_rgb
				LDX #VGA_FILL_COL		; Yello Text
				JSR writeToPropeller	

				LDA #00					; Red
				LDX #00					; Green
				LDY #00					; Blue
				JSR calc_rgb
				LDX #VGA_FILL_BACK		; Blue background
				JSR writeToPropeller					
				
				LDA #$1					; Print with one char at the time
				LDX #VGA_AUTO_INC
				JSR writeToPropeller

				LDX	#30					; Print String
				LDY #1
				LDA #<String1     		; Load String Pointers.
				STA StringLo
				LDA #>String1
				STA StringHi
				JSR printStringXY

				LDX	#30					; Print String
				LDY #0
				JSR setXY
				
				LDA #10
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller			
				LDA #14
				LDY #39
d1				JSR writeToPropeller			
				DEY
				BNE d1
				LDA #11
				JSR writeToPropeller			
				
				LDX	#30					; Print String
				LDY #2
				JSR setXY
				
				LDA #12
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller			
				LDA #14
				LDY #39
d2				JSR writeToPropeller			
				DEY
				BNE d2
				LDA #13
				JSR writeToPropeller			

; Green area

				LDY #4
				STY Temp3
				
				LDA #00					; Red
				LDX #03					; Green
				LDY #00					; Blue
				JSR calc_rgb
				STA Temp1

				LDA #00					; Red
				LDX #01 				; Green
				LDY #00					; Blue
				JSR calc_rgb
				STA Temp2

g1				LDX	#0
				LDY Temp3
				JSR setXY

				LDA Temp1
				LDX #VGA_ROW_BACK		; Blue background
				JSR writeToPropeller				

				LDA Temp2
				LDX #VGA_ROW_COLOR		; Blue background
				JSR writeToPropeller							

				INC Temp3
				LDY Temp3
				CPY #47
				BNE g1

				LDX	#0					; Print String
				LDY #4
				JSR setXY
				
				LDA #10
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller			
				LDA #14
				LDY #60
g2				JSR writeToPropeller			
				DEY
				BNE g2
				LDA #11
				JSR writeToPropeller			
				
				LDX	#0					; Print String
				LDY #46
				JSR setXY
				
				LDA #12
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller			
				LDA #14
				LDY #60
g3				JSR writeToPropeller			
				DEY
				BNE g3
				LDA #13
				JSR writeToPropeller			

				
				LDY #5
				STY Temp3
g4				LDX	#0					; Print String
				JSR setXY
				
				LDA #15
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller
				INC Temp3
				LDY Temp3
				CPY #46
				BNE g4				
				
				LDY #5
				STY Temp3
g5				LDX	#61					; Print String
				JSR setXY
				
				LDA #15
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller
				INC Temp3
				LDY Temp3
				CPY #46
				BNE g5
				

				LDX	#62					; Print String
				LDY #4
				JSR setXY
				
				LDA #10
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller			
				LDA #14
				LDY #36
g6				JSR writeToPropeller			
				DEY
				BNE g6
				LDA #11
				JSR writeToPropeller			
				
				LDX	#62					; Print String
				LDY #46
				JSR setXY
				
				LDA #12
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller			
				LDA #14
				LDY #36
g7				JSR writeToPropeller			
				DEY
				BNE g7
				LDA #13
				JSR writeToPropeller			


				LDY #5
				STY Temp3
g8				LDX	#62					; Print String
				JSR setXY
				
				LDA #15
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller
				INC Temp3
				LDY Temp3
				CPY #46
				BNE g8
				
				LDY #5
				STY Temp3
g9				LDX	#99					; Print String
				JSR setXY
				
				LDA #15
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller
				INC Temp3
				LDY Temp3
				CPY #46
				BNE g9
				

				LDX	#63					; Print String
				LDY #5
				LDA #<String3     		; Load String Pointers.
				STA StringLo
				LDA #>String3
				STA StringHi
				JSR printStringXY

				LDX	#63					; Print String
				LDY #6
				LDA #<String4     		; Load String Pointers.
				STA StringLo
				LDA #>String4
				STA StringHi
				JSR printStringXY				
				
; Blue area				
				LDX	#0
				LDY #47
				JSR setXY
				
				LDA #00					; Red
				LDX #00					; Green
				LDY #03					; Blue
				JSR calc_rgb
				STA Temp1
				LDX #VGA_ROW_BACK		; Blue background
				JSR writeToPropeller				

				LDA #02					; Red
				LDX #02					; Green
				LDY #02					; Blue
				JSR calc_rgb
				STA Temp2
				LDX #VGA_ROW_COLOR		; Blue background
				JSR writeToPropeller							

				LDA #10
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller			
				LDA #14
				LDY #98
d3				JSR writeToPropeller			
				DEY
				BNE d3
				LDA #11
				JSR writeToPropeller				
				
				LDX	#0
				LDY #48
				JSR setXY

				LDA Temp1
				LDX #VGA_ROW_BACK		; Blue background
				JSR writeToPropeller				

				LDA Temp2
				LDX #VGA_ROW_COLOR		; Blue background
				JSR writeToPropeller							

				LDA #15
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller			

				LDX	#99
				LDY #48
				JSR setXY

				LDA #15
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller			
				
				LDX	#0
				LDY #49
				JSR setXY

				LDA Temp1
				LDX #VGA_ROW_BACK		; Blue background
				JSR writeToPropeller				

				LDA Temp2
				LDX #VGA_ROW_COLOR		; Blue background
				JSR writeToPropeller							

				LDA #12
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller			
				LDA #14
				LDY #98
d4				JSR writeToPropeller			
				DEY
				BNE d4
				LDA #13
				JSR writeToPropeller				

				LDX	#1					; Print String
				LDY #48
				LDA #<String2     		; Load String Pointers.
				STA StringLo
				LDA #>String2
				STA StringHi
				JSR printStringXY
				
				LDX	#1
				STX KeyX
				LDY #5
				STY KeyY
				JSR setXY				
				
				
MAINLOOP
				
				JSR read_KeyMatrix

				LDX	#40
				LDY #48
				JSR setXY
				LDX #0
				STX Temp3
				
q1				LDA KeyRow00, X
				JSR printHex
				LDA #$20
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller
				INC Temp3
				LDX Temp3
				CPX #8
				BNE q1

				
				JSR encode_Keyboard

				LDX	#14
				LDY #48
				JSR setXY
				LDA KeyCTRLKeys
				JSR printHex
				
				LDA KeyRaw				; Load raw char
				BMI no_key_pressed		; Pressed ?
				CMP KeyPrevious			; Same as previous ?
				BEQ no_key_pressed		; Then don't print
				
				LDX KeyX
				LDY KeyY
				JSR setXY				
				
				LDA KeyCoded			; Get mapped key
				LDX #VGA_PRINT			; Print
				JSR writeToPropeller				
				
				INC KeyX
				
no_key_pressed				
				JSR delay
				JMP MAINLOOP
				
print_NewLine
				LDA #$0C
				JSR sendChar
				LDA #$0D
				JSR sendChar
				RTS
				
				
;-------------------------------------------------------------------------
; init_Key_VIA: init VIA for Keyboard
;-------------------------------------------------------------------------				
				
init_Key_VIA
				LDA #$FF
				STA VIA_KEY_DDRA	; Make Port A output.
				STZ VIA_KEY_DDRB	; Make Port B input.

				LDA VIA_KEY_ACR     ; Load ACR
				AND #$E3            ; Zero bit 4,3,2.
				ORA #$08            ; Shift in using Phi2 ($08).
				STA VIA_KEY_ACR
				RTS

;-------------------------------------------------------------------------
; init_ACIA: init ACIA
;-------------------------------------------------------------------------				
				
init_ACIA				
                STZ     ACIA_CMD                ; Configure ACIA
                STZ     ACIA_CTL
                STZ     ACIA_SR

                LDA     #%00010000              ; 8 bits, 1 stop bit, full baud ahead.
                STA     ACIA_CTL
                LDA     #%11001001              ; No parity, no interrupt
                STA     ACIA_CMD
                LDA     ACIA_RXD                ; Clear receive buffer				
				RTS

;-------------------------------------------------------------------------
; writeToPropeller, A is data, X is Address
;-------------------------------------------------------------------------

writeToPropeller
				PHA					; Save A
				PHA					; Save A Again
tstBusy			LDA	VIA_PROP_IRB	; Read Output.
				BMI	tstBusy			; Wait for Propeller to finish, high bit will be low when done.
				PLA					; Restore A
				STA	VIA_PROP_ORA
				TXA
				ORA #$40			; Set Write Flag.
				STA VIA_PROP_ORB	; Send data.
tstBusy2		LDA	VIA_PROP_ORB	; Read Output.
				BPL	tstBusy2		; Wait for Propeller to be busy, high bit will be high when busy
				TXA
				AND #$3F			; Clear Write Flag.
				STA VIA_PROP_ORB	; Flag it.
				
				PLA					; Restore A
				RTS				
				
;-------------------------------------------------------------------------
; calc_rgb: A = R, X = G, Y = B values between 0 and 3
; Resulting byte is RRGGBB00 each two bit values.
;-------------------------------------------------------------------------

calc_rgb		CLC
				ROL				; Shift Red 6 bits
				ROL
				ROL
				ROL
				ROL
				ROL
				STA Temp		; Store in Temp
				TXA				; X to A and shift Green 4 bits
				CLC
				ROL
				ROL
				ROL
				ROL
				CLC
				ADC Temp		; Add with Temp
				STA Temp		; Store in Temp
				TYA				; Y to A and shift Blue 2 bits
				CLC
				ROL
				ROL
				CLC
				ADC Temp		; Add with Temp
				RTS

;-------------------------------------------------------------------------
; printHex: Print a HEX value, the Woz way...
;-------------------------------------------------------------------------

printHex
				PHA				; Save A for LSD
				LSR
				LSR
				LSR				; MSD to LSD position
				LSR
				JSR PRHEX		; Output hex digit 
				PLA				; Restore A
PRHEX			AND #%00001111	; Mask LSD for hex print			  
				ORA #"0"		; Add "0"
				CMP #"9"+1		; Is it a decimal digit ?
				BCC ECHO		; Yes Output it
				ADC #6			; Add offset for letter A-F
ECHO			LDX #VGA_PRINT	; Print
				JSR writeToPropeller	; Print it...
				RTS

;-------------------------------------------------------------------------
; setXY: Set XY from X and Y register.
;-------------------------------------------------------------------------

setXY
				TXA
				LDX #VGA_COL
				JSR writeToPropeller
				TYA
				LDX #VGA_ROW
				JMP writeToPropeller
			  
;-------------------------------------------------------------------------
; printStringXY: Print a string preloaded in StringLo at XY from X and Y register.
;-------------------------------------------------------------------------

printStringXY
				TXA
				LDX #VGA_COL
				JSR writeToPropeller
				TYA
				LDX #VGA_ROW
				JSR writeToPropeller

;-------------------------------------------------------------------------
; printString: Print a string preloaded in StringLo
;-------------------------------------------------------------------------

printString
				LDY #0
nextChar		LDA (StringLo),Y	; Get character
				BEQ done_Printing	; Zero, we done...
				LDX #VGA_PRINT		; Print
				JSR writeToPropeller
				INY					; Next, cannot print more than 254 bytes or we wrap around in an infinite loop.
				BRA nextChar		; Continue
done_Printing	RTS				
				
;-------------------------------------------------------------------------
; init_Keyboard: Setup Keyboard to be read.
;-------------------------------------------------------------------------				

init_Keyboard				
				LDA #<keyMatrixMap     		; Load String Pointers.
				STA KeyMapLo
				LDA #>keyMatrixMap
				STA KeyMapHi
				JSR init_Key_VIA			; Init VIA
				RTS
				
;-------------------------------------------------------------------------
; init_Propeller: Setup Propeller communication
;-------------------------------------------------------------------------				

init_Propeller
				LDA #$FF				; Make all output
				STA VIA_PROP_DDRA
				LDA #$7F
				STA VIA_PROP_DDRB		; Bit 0-7 output, bit 8 input
				RTS
				
;-------------------------------------------------------------------------
; read_Keyboard: Read the C64 Keyboard
;-------------------------------------------------------------------------				
				
read_Keyboard	
				JSR read_KeyMatrix
				JSR encode_Keyboard
				RTS

;-------------------------------------------------------------------------
; read_KeyMatrix: Read the Key Matrix
;-------------------------------------------------------------------------				

read_KeyMatrix
				LDA #$01			; Start with bit 1
				STA KeyBitpos		; Save position
				LDX #00				; Zero X
bitLoop			LDA KeyBitpos		; First bits
				STA VIA_KEY_ORA		; Set Matrix
				NOP					; Wait for value to be stable
				NOP
				NOP					; Wait for it...
				NOP					; Should be stable by now...
				LDA VIA_KEY_IRB		; Read Matrix byte
				STA KeyRow00, X		; Save data in position relative to X
				INX					; Next save position
				CLC					; Clear Carry
				ROL KeyBitpos		; Roll position left, the bit is now pointing to the next row in the Keyboard matrix
				BCC bitLoop			; Are we done yet ? If Carry was shifted out, nothing more to read.
				RTS
				
;-------------------------------------------------------------------------
; encode_Keyboard: Read the C64 Keyboard
;-------------------------------------------------------------------------				
				
encode_Keyboard	

				LDA KeyRaw			; Exchange Previous key.
				STA KeyPrevious

				LDA VIA_KEY_SR		; Read Restore Key.
				; Reading the SR register starts a shift in, the restore key is hooked up to CB2
				
				LDA KeyRow00		; Top Matrix row.
				AND #%00101100		; Filter out CTRL, Stop and Commodore key, we only want these bits
				STA KeyCTRLKeys		; Save it
				LDA KeyRow00		; Top Matrix row.
				AND #%11010011		; Remove CTRL, Stop and Commodore key since we are done with them.
				STA KeyRow00		; Save it
				
				LDA KeyRow01		; Second Matrix row.
				AND #%00001000		; Filter out Left Shift
				CLC					; Clear carry for Rotate
				ROR					; Shift bit twice so it does not collide with other bits
				ROR
				ORA KeyCTRLKeys		; Ora with previous result
				STA KeyCTRLKeys		; Save
				LDA KeyRow01		; Second Matrix row.
				AND #%11110111		; Remove Left Shift since we are done with it.
				STA KeyRow01		; Save it

				LDA KeyRow06		; Sixth Matrix row.
				AND #%00010000		; Filter out Right Shift
				ORA KeyCTRLKeys		; Ora with previous result
				STA KeyCTRLKeys		; Save
				LDA KeyRow06		; Sixth Matrix row.
				AND #%11101111		; Remove Right Shift since we are done with it.
				STA KeyRow06		; Save it
				
				LDA VIA_KEY_SR		; Restore Key should be done by now. Get actual value.
				AND #%00000001		; Filter out one bit.
				ORA KeyCTRLKeys		; Ora with previous result
				STA KeyCTRLKeys		; Save
				
				; Control keys, 
				; Bit 1: Restore
				; Bit 2: Left Shift, Shift Lock
				; Bit 3: CTRL
				; Bit 4: Run Stop
				; BIT 5: Right Shift
				; Bit 6: Commodore key
				
				LDY #$00			; Zero Y, this is position 0-7 in bits.
				LDX #$00			; Zero X, this is the current Matrix byte
				STZ KeyMatrixpos	; Zero matrix position				
bitLoop2		ROR KeyRow00, X		; Shift Matrix data, test first bit.
				BCC	no_key_press    ; No key pressed
				LDY KeyMatrixpos	; Get position
				STY KeyRaw			; Save raw key value
				LDA (KeyMapLo), Y	; Look up actual character
				STA KeyCoded		; Save coded key.
				BRA done_encoding	; We are done.
no_key_press	INC KeyMatrixpos	; Next pos in matrix
				INY					; Next current bit pos.
				CPY #8				; Done yet ?
				BNE bitLoop2		; Continue on...
				LDY #$00			; Reset bit position
				INX					; Next Matrix  position
				CPX #8				; Done yet ?
				BNE bitLoop2		; Continue on
				
				LDA #$80			; Flag no key pressed.
				STA KeyRaw			; Save it
done_encoding
				RTS
				
;-------------------------------------------------------------------------
; printString: Print a String 
;-------------------------------------------------------------------------				
				
sendChar
				PHA
				PHP
				STA ACIA_TXD
				JSR TxDelay
				PLP
				PLA
				RTS

;-------------------------------------------------------------------------
; TxDelay: Send delay
;-------------------------------------------------------------------------				
				
TxDelay
				LDA #$60
				INC
				BNE $-1
				RTS
				
;-------------------------------------------------------------------------
; delay: Just a Delay
;-------------------------------------------------------------------------				

delay			LDA #$02
				LDY #$00            ; Loop 8*256*256 times...
				LDX #$00
dloop1			DEX
				BNE dloop1
				DEY
				BNE dloop1
				DEC
				BNE dloop1
				RTS
				
;-------------------------------------------------------------------------
; printHex: Print a HEX value, the Woz way...
;-------------------------------------------------------------------------

sendHex
				PHA				; Save A for LSD
				LSR
				LSR
				LSR				; MSD to LSD position
				LSR
				JSR PRHEX2		; Output hex digit 
				PLA				; Restore A
PRHEX2			AND #%00001111	; Mask LSD for hex print			  
				ORA #"0"		; Add "0"
				CMP #"9"+1		; Is it a decimal digit ?
				BCC ECHO2		; Yes Output it
				ADC #6			; Add offset for letter A-F
ECHO2			JSR sendChar	; Print it...
				RTS

;-------------------------------------------------------------------------
; printString: Print a String 
;-------------------------------------------------------------------------				
				
sendString
				LDY #0
nextChar2		LDA (StringLo),Y	; Get character
				BEQ done_Printing2	; Zero, we done...
				JSR sendChar
				INY					; Next, cannot print more than 254 bytes or we wrap around in an infinite loop.
				BRA nextChar2		; Continue
done_Printing2	RTS			
				
;-------------------------------------------------------------------------
; FUNCTION NAME	: Event Hander re-vectors
;-------------------------------------------------------------------------
IRQHandler:
				PHA
				PLA
				RTI

badVec			; $FFE0 - IRQRVD2(134)
				PHP
				PHA
				LDA #$FF
				;clear Irq
				PLA
				PLP
				RTI

;########################### Data segment #####################

	DATA

;-------------------------------------------------------------------------
; The Keyboard Matrix mapped to chars, for control chars, I'll use ?...
;-------------------------------------------------------------------------
keyMatrixMap
				BYTE "1" ; 00
				BYTE "L" ; 01 Left arrow
				BYTE "?" ; 02 CTRL
				BYTE "?" ; 03 Stop
				BYTE " " ; 04 Space
				BYTE "C" ; 05 Commodore key
				BYTE "Q" ; 06
				BYTE "2" ; 07
				
				BYTE "3" ; 08
				BYTE "W" ; 09 
				BYTE "A" ; 0A 
				BYTE "?" ; 0B Shift
				BYTE "Z" ; 0C 
				BYTE "S" ; 0D
				BYTE "E" ; 0E
				BYTE "4" ; 0F
	
				BYTE "5" ; 10
				BYTE "R" ; 11
				BYTE "D" ; 12
				BYTE "X" ; 13
				BYTE "C" ; 14
				BYTE "F" ; 15
				BYTE "T" ; 16
				BYTE "6" ; 17
				
				BYTE "7" ; 18
				BYTE "Y" ; 19 
				BYTE "G" ; 1A 
				BYTE "V" ; 1B
				BYTE "B" ; 1C
				BYTE "H" ; 1D
				BYTE "U" ; 1E
				BYTE "8" ; 1F
	
				BYTE "9" ; 20
				BYTE "I" ; 21
				BYTE "J" ; 22
				BYTE "N" ; 23
				BYTE "M" ; 24
				BYTE "K" ; 25
				BYTE "O" ; 26
				BYTE "0" ; 27
				
				BYTE "+" ; 28
				BYTE "P" ; 29 
				BYTE "L" ; 2A 
				BYTE "," ; 2B
				BYTE "." ; 2C
				BYTE ":" ; 2D
				BYTE "@" ; 2E
				BYTE "-" ; 2F
	
				BYTE "P" ; 30 Pound sign
				BYTE "*" ; 31
				BYTE $3B ; 32 Semicolon
				BYTE "/" ; 33
				BYTE "?" ; 34 Shift
				BYTE "=" ; 35
				BYTE "U" ; 36 Up arrow
				BYTE "?" ; 37 CLR
				
				BYTE "?" ; 38 DEL
				BYTE "?" ; 39 Return
				BYTE "?" ; 3A Left Right Arrow
				BYTE "?" ; 3B Up Down Arrow
				BYTE "1" ; 3C F1
				BYTE "3" ; 3D F3 
				BYTE "5" ; 3E F5
				BYTE "7" ; 3F F7
				
String1
				BYTE	15, "         ZEBERPUPIN W65C816SXB         ", 15, $00
				BYTE	15, "W65CSXB Keyboard, VGA and SID system...", 15, $00
				
String2
				BYTE	"Status Keys:          Keyboard Matrix:  ", $00
String3
				BYTE	4, " Testing selection 1", $00
String4
				BYTE	5, " Testing selection 2", $00
			
	ENDS

;-----------------------------
;
;		Reset and Interrupt Vectors (define for 265, 816/02 are subsets)
;
;-----------------------------

Shadow_VECTORS	SECTION OFFSET $7EE0
								;65C816 Interrupt Vectors
								;Status bit E = 0 (Native mode, 16 bit mode)
				DW badVec		; $FFE0 - IRQRVD4(816)
				DW badVec		; $FFE2 - IRQRVD5(816)
				DW badVec		; $FFE4 - COP(816)
				DW badVec		; $FFE6 - BRK(816)
				DW badVec		; $FFE8 - ABORT(816)
				DW badVec		; $FFEA - NMI(816)
				DW badVec		; $FFEC - IRQRVD(816)
				DW badVec		; $FFEE - IRQ(816)
								;Status bit E = 1 (Emulation mode, 8 bit mode)
				DW badVec		; $FFF0 - IRQRVD2(8 bit Emulation)(IRQRVD(265))
				DW badVec		; $FFF2 - IRQRVD1(8 bit Emulation)(IRQRVD(265))
				DW badVec		; $FFF4 - COP(8 bit Emulation)
				DW badVec   	; $FFF6 - IRQRVD0(8 bit Emulation)(IRQRVD(265))
				DW badVec		; $FFF8 - ABORT(8 bit Emulation)
								; Common 8 bit Vectors for all CPUs
				DW badVec		; $FFFA -  NMIRQ (ALL)
				DW START		; $FFFC -  RESET (ALL)
				DW IRQHandler	; $FFFE -  IRQBRK (ALL)
	ENDS

vectors	SECTION OFFSET $FFE0
								;65C816 Interrupt Vectors
								;Status bit E = 0 (Native mode, 16 bit mode)
				DW badVec		; $FFE0 - IRQRVD4(816)
				DW badVec		; $FFE2 - IRQRVD5(816)
				DW badVec		; $FFE4 - COP(816)
				DW badVec		; $FFE6 - BRK(816)
				DW badVec		; $FFE8 - ABORT(816)
				DW badVec		; $FFEA - NMI(816)
				DW badVec		; $FFEC - IRQRVD(816)
				DW badVec		; $FFEE - IRQ(816)
								;Status bit E = 1 (Emulation mode, 8 bit mode)
				DW badVec		; $FFF0 - IRQRVD2(8 bit Emulation)(IRQRVD(265))
				DW badVec		; $FFF2 - IRQRVD1(8 bit Emulation)(IRQRVD(265))
				DW badVec		; $FFF4 - COP(8 bit Emulation)
				DW badVec		; $FFF6 - IRQRVD0(8 bit Emulation)(IRQRVD(265))
				DW badVec		; $FFF8 - ABORT(8 bit Emulation)
								; Common 8 bit Vectors for all CPUs
				DW badVec		; $FFFA -  NMIRQ (ALL)
				DW START		; $FFFC -  RESET (ALL)
				DW IRQHandler	; $FFFE -  IRQBRK (ALL)
	ENDS
	END
