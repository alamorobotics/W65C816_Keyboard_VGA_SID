; File: Template.asm
; 12/26/2015

;############################# DESCIPTION ########################


;########################### PIN ASSIGNMENTS #####################


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

	TITLE  "Template Template.asm"
	STTL

;########################### I/O addreses #####################
	
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

VGA_BASE		EQU $00		; "base address" of VGA, this address is sent to the propeller
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

;########################### Main Program #####################

	CHIP 65C02
	LONGI OFF
	LONGA OFF

	.STTL "Template"
	.PAGE
				ORG $0200
START
				NOP


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
ECHO			JSR sendChar	; Print it...
				RTS

;-------------------------------------------------------------------------
; printString: Print a String 
;-------------------------------------------------------------------------				
				
printString
				LDY #0
nextChar		LDA (StringLo),Y	; Get character
				BEQ done_Printing	; Zero, we done...
				JSR sendChar
				INY					; Next, cannot print more than 254 bytes or we wrap around in an infinite loop.
				BRA nextChar		; Continue
done_Printing	RTS	
				
;-------------------------------------------------------------------------
; print_NewLine: Print a New Line 
;-------------------------------------------------------------------------				

print_NewLine
				LDA #$0C
				JSR sendChar
				LDA #$0D
				JSR sendChar
				RTS				
				
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

String1
				BYTE	"W65CSXB Example String...", $0C, $0D, $00 
				
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
