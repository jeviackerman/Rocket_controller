;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Student Name : Justin Sewpershad
; Student Number : 219031465
; Date : 18 / 11 / 2022
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include "p16f690.inc"
; CONFIG
; __config 0x3CD5
__CONFIG _FOSC_INTRCCLK & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_ON & _FCMEN_ON
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Register definitions
counter EQU 0X20 ;Used as varaiable to display cookbook values
UNITS EQU 0X23 ; Used to display the units digit when multiplexing
TENS EQU 0X24 ; Used to display the Tens digit when multiplexing
;Delay
d1 equ 0x25 ;Used in Delay
d2 equ 0x26 ;Used in Delay
d3 equ 0x27 ;Used in Delay
CASE1 EQU 0X30 ; Switch case statement 1
CASE2 EQU 0X31 ; Switch case statement 2
CASE3 EQU 0X32 ; Switch case statement 3
counter2 EQU 0X33 ; Used to store the current direction
DIRECTION1 EQU 0X34 ; Direction 1 value
DIRECTION2 EQU 0X35 ; Direction 2 value
DIRECTION3 EQU 0X36 ; direction 3 value
CASE4 EQU 0X37 ; Switch case statement 4
CounterA EQU 0X38 ; Used in 1s delay
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset vector
ORG 0X00
;PIC16F690 INITIALISATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BANKSEL TRISB
BCF TRISA,0 ; MOTOR PINB
BSF TRISA,1 ; BUTTON INPUT2
BCF TRISA,2 ; BUZZER OUTPUT
BSF TRISA,3 ; BUTTON INPUT3
BCF TRISA,5 ; MOTOR PINA
BCF TRISB,4 ; LED GREEN
BCF TRISB,5 ; LED RED
BCF TRISB,6 ; MIUTIPLEXING UNITS
BCF TRISB,7 ; MIUTIPLEXING TENS
MOVLW b'00100000' ; Makes portC an output and port cpin5 input
MOVWF TRISC
BANKSEL ANSEL
CLRF ANSEL ; Clear ANSEL
CLRF ANSELH ; Clear ANSELH
BANKSEL PORTC
CLRF PORTC ; Clear PORTC
CLRF PORTB ; Clear PORTB
CLRF PORTA ; Clear PORTA
;TIMER1 SETUP
MOVLW b'00110000' ; PRESCALAR 1:8 CLOCK SOURCE INTERNAL TIMER1 OSC OFF
MOVWF T1CON
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GLOBAL VARIABLES AND SETUP
START
CLRF PORTC ;Clear PORTC
MOVLW 0X01
MOVWF CASE1 ;CASE1=1
MOVLW 0X02
MOVWF CASE2 ;CASE2=2
MOVLW 0X03
MOVWF CASE3 ;CASE3=3
CLRF DIRECTION1 ; 1ST PHASE DIRECTION
CLRF DIRECTION2 ; 2ND PHASE DIRECTION
CLRF DIRECTION3 ; 3RD PHASE DIRECTION
CLRF counter ; clearing counter
CLRF counter2 ; clearing counter2
BSF PORTB,7 ; Setting PortB pin 7 for SSD display
BCF PORTB,6 ; Clearing PortB pin 6 for disabling SSD display
GOTO MAIN ; Goto main program
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAIN PROGRAM
MAIN
;BUTTONS SETUP
BUTTON_MAIN
;BUTTON1
;Creates cookbook to scroll through
;Displays the codebook and increments value on each press and restes back to 1 after 4
BUTTON1
BTFSS PORTC,5;check if Up button is pressed
GOTO BUTTON2;if not go to button2
CALL DELAY10ms; Call dealy for switch debouncing
BTFSS PORTC,5 ;check if button is pressed again
GOTO BUTTON2;if not go to main
CALL COOKBOOK ; Sets up cookbook from 1 to 4
CALL DISPLAY ; Displays cookbook varaibles for selection
BUTTON1CheckRelease; Check if the switch is released
BTFSS PORTC,5 ;Check if button is still pressed
GOTO BUTTON2;if not go to main
GOTO BUTTON1CheckRelease; Go back to Check if the switch is not released
;BUTTON2
; Stores the current direction displayed on the SSD
BUTTON2
BTFSS PORTC,1;check if Up button is pressed
GOTO BUTTON3;if not go to main
CALL DELAY10ms; Call dealy for switch debouncing
BTFSS PORTA,1 ;check if Up button is pressed again
GOTO BUTTON3;if not go to main
INCF counter2,F; increments counter to store value
CALL STORE ; Functions that stores the current value on SSD
PUN; Point to GOTO
BUTTON2CheckRelease; Check if the switch is released
BTFSS PORTA,1 ;Check if button is still pressed
GOTO BUTTON3;if not go to main
GOTO BUTTON2CheckRelease; Go back to Check if the switch is not released
;Starts the rocket system and displays the directions values airtime and distance
BUTTON3
BTFSS PORTA,3;check if Up button is pressed
GOTO BUTTON_MAIN;if not go to main
CALL DELAY10ms; Call dealy for switch debouncing
BTFSS PORTA,3 ;check if Up button is pressed again
GOTO BUTTON_MAIN;if not go to main
CALL RED_LED; Turns red led on
CALL NORTH; Checks if north is the first direction and starts the north logic
CALL SOUTH22; Checks if south is the first direction and starts the south logic
CALL EAST223; Checks if east is the first direction and starts the east logic
CALL WEST_F; Checks if west is the first direction and starts the west logic
CALL GREEN_LED; The green led is turned on
CALL FINAL; Calls the final function to display distance and airtime
BUTTON3CheckRelease; Check if the switch is released
BTFSS PORTA,3 ;Check if button is still pressed
GOTO BUTTON_MAIN;if not go to main
GOTO BUTTON3CheckRelease; Go back to Check if the switch is not released
GOTO MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;final function to display distance and airtime
FINAL
MOVLW 0X2 ; moves 2 into unit
MOVWF UNITS
MOVLW 0X1 ;moves 1 into tens
MOVWF TENS
CALL MULTIPLEXING; displays on ssd consecutively
CALL TIMDELAY ; 1 sec time delay is clled
MOVLW 0X8 ;; moves 8 into unit
MOVWF UNITS
MOVLW 0X4 ; moves 4 into tens
MOVWF TENS
CALL MULTIPLEXING ; displays on ssd consecutively
CALL TIMDELAY
GOTO FINAL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY
MOVF counter,W ;Displays the direction value
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTC
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cycles through digits 1 to 4
COOKBOOK
INCF counter,F ; counter is infremneted
MOVF counter,W ; Moving to W reg
SUBLW 0X05 ; subtract 5
BTFSS STATUS,Z; if 0 skip
RETURN; else return
MOVLW 0X01 ; move 1 to counter
MOVWF counter
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Switch case to store the correct direction
STORE
MOVF counter2,W ; [W] = [B]
SUBWF CASE1,W ; [W] = [A] ? [B]
BTFSC STATUS, Z ; If equal
GOTO LABEL1 ; goto label1
MOVF counter2,W ; [W] = [B]
SUBWF CASE2,W ; [W] = [A] ? [B]
BTFSC STATUS, Z; If equal
GOTO LABEL2 ; goto label2
MOVF counter2,W ; [W] = [B]
SUBWF CASE3,W ; [W] = [A] ? [B]
BTFSC STATUS, Z; If equal
GOTO LABEL3 ; goto label2
GOTO PUN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Stores the direction for direction 1
LABEL1
MOVF counter,W ; Stores the direction for direction 1
MOVWF DIRECTION1l moving it into register direction1
GOTO PUN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Stores the direction for direction 2
LABEL2
MOVF counter,W ; moves direction in direction 2 register
MOVWF DIRECTION2
CALL LOGIC; Checks if direction1 is N and direction 2 is south
CALL LOGIC15; Checks if direction1 is S and direction 2 is N
CALL LOGIC2; Checks if direction1 is E and direction 2 is W
CALL LOGIC25; Checks if direction1 is W and direction 2 is E
GOTO PUN; Goto pun to end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Stores the direction for direction 2
LABEL3
MOVF counter,W
MOVWF DIRECTION3 ; moves direction in direction32 register
CALL LOGIC3 ;Checks if direction 2 is N and direction 3 is south
CALL LOGIC35 ;Checks if direction 2 is S and direction 3 is N
CALL LOGIC4; ;Checks if direction 2 is E and direction 3 is W
CALL LOGIC45 ;Checks if direction 2 is W and direction 3 is E
GOTO PUN ; Goto pun to end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GREEN_LED
BCF PORTB,5 ; Turns off red led
BSF PORTB,4 ; Turns on green led
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RED_LED
BCF PORTB,4 ; Turns off green led
BSF PORTB,5 ; Turns on red led
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks if direction1 is N and direction 2 is south
LOGIC
MOVF DIRECTION1,W
SUBWF CASE1,W ; Checks if direction 1 is equal to N
BTFSC STATUS,Z; if true goto d12
GOTO DI2
RETURN; else return
DI2
MOVF DIRECTION2,W; checks if direction 2 is equal to South
SUBWF CASE2,W
BTFSC STATUS,Z; if true call sound
GOTO SOUND
RETURN; false return
; Checks if direction1 is S and direction 2 is N
LOGIC15
MOVF DIRECTION1,W ; Checks if direction 1 is equal to S
SUBWF CASE2,W
BTFSC STATUS,Z ;if true goto d11
GOTO DI1
RETURN; else return
DI1
MOVF DIRECTION2,W ; checks if direction 2 is equal to N
SUBWF CASE1,W
BTFSC STATUS,Z ; if true call sound
GOTO SOUND
RETURN; false return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks if direction1 is E and direction 2 is W
LOGIC2
MOVF DIRECTION1,W ; checks if direction 1 is equal to E
SUBWF CASE3,W
BTFSC STATUS,Z;if true goto d11
GOTO DI4
RETURN; else return
DI4
MOVF DIRECTION2,W ; checks if direction 2 is equal to W
SUBWF CASE4,W
BTFSC STATUS,Z
GOTO SOUND ; if true call sound
RETURN ; else return
; Checks if direction1 is W and direction 2 is E
LOGIC25
MOVF DIRECTION1,W ; checks if direction 1 is equal to W
SUBWF CASE4,W
BTFSC STATUS,Z ;if true goto d13
GOTO DI3
RETURN ; else return
DI3
MOVF DIRECTION2,W ; checks if direction 2 is equal to E
SUBWF CASE3,W
BTFSC STATUS,Z
GOTO SOUND ; if true call sound
RETURN ; else return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAY10ms
MOVLW 0xE7
MOVWF d1
MOVLW 0x04
MOVWF d2
DELAY
DECFSZ d1, f
GOTO DELAY
DECFSZ d2, f
GOTO DELAY
GOTO $+1
NOP
RETURN
;1000 cycles to achieve 10ms delay
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Lookup table for Seven segment display bitmap
LOOKUP ADDWF PCL,F
RETLW 0X5F;0
RETLW 0X06;1
RETLW 0X9B;2
RETLW 0X8F;3
RETLW 0XC6;4
RETLW 0XCD;5
RETLW 0XDD;6
RETLW 0X07;7
RETLW 0XDF;8
RETLW 0XC7;9
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TIMDELAY ;
; 1 Sec delay routine using Timer1
; --------------------------------
MOVLW .2 ;
MOVWF CounterA ; CounterA = 2
DO_DELAY ;Uses Timer1 for a 1 second Delay
BCF T1CON,0 ; Stop Timer1
BCF PIR1,0 ; Clear Timer1 overflow flag
MOVLW B'11011000' ; Load
MOVWF TMR1L ; Timer1
MOVLW B'00001011'; with
MOVWF TMR1H ; Reload Value
BSF T1CON,0 ; Start Timer1
One_Second_Loop
CALL MULTIPLEXING ;Displays Temperature while waiting for overflow flag
BTFSS PIR1,0 ;If flag not set, loop again
GOTO One_Second_Loop
DECFSZ CounterA,F ; Decrement CounterA and see if = 0
GOTO DO_DELAY ; CounterA<>0, so, do it again
RETURN ; done, getout of here
; Multiplexes seven segment displays
MULTIPLEXING
MOVF TENS,W ; moves tens value to W
CALL LOOKUP ; calls lookup
MOVWF PORTC ; displays it on port c
BCF PORTB,6; clears bit 6
CALL DELAY1MS ; calls 1ms delay
BSF PORTB,6 ; sets bit 6
MOVF UNITS,W ; moves units value to W
CALL LOOKUP ; calls lookup
MOVWF PORTC ; displays it on port c
BCF PORTB,7 ; clears bit 7
CALL DELAY1MS ; calls 1ms delay
BSF PORTB,7 ; sets bit 7
RETURN ;returns
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOGIC3
MOVF DIRECTION2,W
SUBWF CASE1,W
BTFSC STATUS,Z
GOTO DIT2
RETURN
DIT2
MOVF DIRECTION3,W
SUBWF CASE2,W
BTFSC STATUS,Z
GOTO SOUND
RETURN
LOGIC35
MOVF DIRECTION2,W
SUBWF CASE2,W
BTFSC STATUS,Z
GOTO DIT1
RETURN

DIT1
MOVF DIRECTION3,W
SUBWF CASE1,W
BTFSC STATUS,Z
GOTO SOUND
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOGIC4
MOVF DIRECTION2,W
SUBWF CASE3,W
BTFSC STATUS,Z
GOTO DIT4
RETURN
DIT4
MOVF DIRECTION3,W
SUBWF CASE4,W
BTFSC STATUS,Z
GOTO SOUND
RETURN
LOGIC45
MOVF DIRECTION2,W
SUBWF CASE4,W
BTFSC STATUS,Z
GOTO DIT3
RETURN
DIT3
MOVF DIRECTION3,W
SUBWF CASE3,W
BTFSC STATUS,Z
GOTO SOUND
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SOUND
CALL RED_LED ; turns red led on
BSF PORTA,2 ; buzzer starts
CALL TIMDELAY ;1 sec delay
BCF PORTA,2 ; buzzer stops
BCF PORTB,5 ; led off
GOTO START
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;north direction logic
NORTH
MOVF DIRECTION1,W
SUBWF CASE1,W
BTFSC STATUS,Z
GOTO NIP
RETURN
NIP
CALL TIME4
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X01
MOVWF UNITS
MOVLW 0X01
MOVWF TENS
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO EIP
EIP
MOVF DIRECTION2,W
SUBWF CASE3,W
BTFSC STATUS,Z
GOTO EASTY
MOVF DIRECTION2,W
SUBWF CASE4,W
BTFSC STATUS,Z
GOTO WESTY
GOTO NORTHY
NORTHY
CALL MOTOR_OFF
CALL TIME42
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X1
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO TRISTATE3
EASTY
CALL MOTOR_FORWARD
CALL TIME42
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X03
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO SIP
WESTY
CALL MOTOR_BACKWARD
CALL TIME42
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X04
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO SIP
SIP
MOVF DIRECTION3,W
SUBWF CASE3,W
BTFSC STATUS,Z
GOTO EASTY_REP
MOVF DIRECTION3,W
SUBWF CASE4,W
BTFSC STATUS,Z
GOTO WESTY_REP
GOTO TRISTATE
EASTY_REP
CALL MOTOR_OFF
CALL TIME423
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X03
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
CALL TIMDELAY
BCF PORTA,2
RETURN
WESTY_REP
CALL MOTOR_OFF
CALL TIME423
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X04
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
CALL TIMDELAY
BCF PORTA,2
RETURN
TRISTATE
MOVF DIRECTION3,W
SUBWF CASE1,W
BTFSC STATUS,Z
GOTO NOUTHY2
MOVF DIRECTION3,W
SUBWF CASE2,W
BTFSC STATUS,Z
GOTO SOUTHY2
GOTO EASTY_REP
NOUTHY2
CALL MOTOR_FORWARD
CALL TIME423
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X01
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
CALL TIMDELAY
BCF PORTA,2
RETURN
SOUTHY2
CALL MOTOR_BACKWARD
CALL TIME423
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X02
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
CALL TIMDELAY
BCF PORTA,2
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SOUTH22
MOVF DIRECTION1,W
SUBWF CASE2,W
BTFSC STATUS,Z
GOTO NIP2
RETURN
NIP2
CALL TIME4
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X02
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO EIP2
EIP2
MOVF DIRECTION2,W
SUBWF CASE3,W
BTFSC STATUS,Z
GOTO EASTY2
MOVF DIRECTION2,W
SUBWF CASE4,W
BTFSC STATUS,Z
GOTO WESTY2
GOTO SOUTHY
SOUTHY
CALL MOTOR_OFF
CALL TIME42
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X2
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO TRISTATE3
EASTY2
CALL MOTOR_BACKWARD
CALL TIME42
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X03
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO SIP2
WESTY2
CALL MOTOR_FORWARD
CALL TIME42
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X04
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO SIP2
SIP2
MOVF DIRECTION3,W
SUBWF CASE3,W
BTFSC STATUS,Z
GOTO EASTY_REP
MOVF DIRECTION3,W
SUBWF CASE4,W
BTFSC STATUS,Z
GOTO WESTY_REP
GOTO TRISTATE2
TRISTATE2
MOVF DIRECTION3,W
SUBWF CASE1,W
BTFSC STATUS,Z
GOTO NOUTHY22
MOVF DIRECTION3,W
SUBWF CASE2,W
BTFSC STATUS,Z
GOTO SOUTHY22
GOTO WESTY_REP
NOUTHY22
CALL MOTOR_BACKWARD
CALL TIME423
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X01
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
CALL TIMDELAY
BCF PORTA,2
RETURN
SOUTHY22
CALL MOTOR_FORWARD
CALL TIME423
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X02
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
CALL TIMDELAY
BCF PORTA,2
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EAST223
MOVF DIRECTION1,W
SUBWF CASE3,W
BTFSC STATUS,Z
GOTO NIP3
RETURN
NIP3
CALL TIME4
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X03
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO EIP23
EIP23
MOVF DIRECTION2,W
SUBWF CASE1,W
BTFSC STATUS,Z
GOTO NORTHY23
MOVF DIRECTION2,W
SUBWF CASE2,W
BTFSC STATUS,Z
GOTO SOUTHY23
GOTO EASTY_RET
EASTY_RET
CALL MOTOR_OFF
CALL TIME42
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X3
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO TRISTATE
NORTHY23
CALL MOTOR_FORWARD
CALL TIME42
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X01
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO SIP23
SOUTHY23
CALL MOTOR_BACKWARD
CALL TIME42
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X02
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO SIP23
SIP23
MOVF DIRECTION3,W
SUBWF CASE1,W
BTFSC STATUS,Z
GOTO NORTHY_REP
MOVF DIRECTION3,W
SUBWF CASE2,W
BTFSC STATUS,Z
GOTO SOUTHY_REP
GOTO TRISTATE3
TRISTATE3
MOVF DIRECTION3,W
SUBWF CASE3,W
BTFSC STATUS,Z
GOTO EASTY223
SUBWF CASE4,W
BTFSC STATUS,Z
GOTO WESTY223
GOTO NORTHY_REP
NORTHY_REP
CALL MOTOR_OFF
CALL TIME423
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X1
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
RETURN
EASTY223
CALL MOTOR_FORWARD
CALL TIME423
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X03
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
CALL TIMDELAY
BCF PORTA,2
RETURN
WESTY223
CALL MOTOR_BACKWARD
CALL TIME423
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X04
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
CALL TIMDELAY
BCF PORTA,2
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WEST_F
MOVF DIRECTION1,W
SUBWF CASE4,W
BTFSC STATUS,Z
GOTO NIP34
RETURN
NIP34
CALL TIME4
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X04
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO EIP234
EIP234
MOVF DIRECTION2,W
SUBWF CASE1,W
BTFSC STATUS,Z
GOTO NORTHY234
MOVF DIRECTION2,W
SUBWF CASE2,W
BTFSC STATUS,Z
GOTO SOUTHY234
GOTO WESTY2_RET
WESTY2_RET
CALL MOTOR_OFF
CALL TIME42
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X4
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO TRISTATE2
NORTHY234
CALL MOTOR_FORWARD
CALL TIME42
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X01
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO SIP234
SOUTHY234
CALL MOTOR_BACKWARD
CALL TIME42
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X02
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
GOTO SIP234
SIP234
MOVF DIRECTION3,W
SUBWF CASE1,W
BTFSC STATUS,Z
GOTO NORTHY_REP
MOVF DIRECTION3,W
SUBWF CASE2,W
BTFSC STATUS,Z
GOTO SOUTHY_REP
TRISTATE4
MOVF DIRECTION3,W
SUBWF CASE3,W
BTFSC STATUS,Z
GOTO EASTY2234
MOVF DIRECTION3,W
SUBWF CASE4,W
BTFSC STATUS,Z
GOTO WESTY2234
GOTO SOUTHY_REP
SOUTHY_REP
CALL MOTOR_OFF
CALL TIME423
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X2
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
BCF PORTA,2
RETURN
EASTY2234
CALL MOTOR_BACKWARD
CALL TIME423
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X03
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
CALL TIMDELAY
BCF PORTA,2
RETURN
WESTY2234
CALL MOTOR_FORWARD
CALL TIME423
CALL MOTOR_OFF
BSF PORTA,2 ; Enable TENS SSD in PORTB
CALL TIMDELAY
MOVLW 0X04
CALL LOOKUP ;Call the lookup table to display value
MOVWF PORTC ; Display value of counter on seven segment display through PORTB
CALL TIMDELAY
CALL TIMDELAY
BCF PORTA,2
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TIME4
MOVFW DIRECTION1
MOVWF TENS
MOVLW 0X00
MOVWF UNITS
CALL MULTIPLEXING
CALL TIMDELAY
MOVLW 0X01
MOVWF UNITS
CALL MULTIPLEXING
CALL TIMDELAY
MOVLW 0X02
MOVWF UNITS
CALL MULTIPLEXING
CALL TIMDELAY
MOVLW 0X03
MOVWF UNITS
CALL TIMDELAY
CALL MULTIPLEXING
MOVLW 0X04
MOVWF UNITS
CALL MULTIPLEXING
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TIME42
MOVFW DIRECTION2
MOVWF TENS
MOVLW 0X00
MOVWF UNITS
CALL MULTIPLEXING
CALL TIMDELAY
MOVLW 0X01
MOVWF UNITS
CALL MULTIPLEXING
CALL TIMDELAY
MOVLW 0X02
MOVWF UNITS
CALL MULTIPLEXING
CALL TIMDELAY
MOVLW 0X03
MOVWF UNITS
CALL TIMDELAY
CALL MULTIPLEXING
MOVLW 0X04
MOVWF UNITS
CALL MULTIPLEXING
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TIME423
MOVFW DIRECTION3
MOVWF TENS
MOVLW 0X00
MOVWF UNITS
CALL MULTIPLEXING
CALL TIMDELAY
MOVLW 0X01
MOVWF UNITS
CALL MULTIPLEXING
CALL TIMDELAY
MOVLW 0X02
MOVWF UNITS
CALL MULTIPLEXING
CALL TIMDELAY
MOVLW 0X03
MOVWF UNITS
CALL TIMDELAY
CALL MULTIPLEXING
MOVLW 0X04
MOVWF UNITS
CALL MULTIPLEXING
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAY1MS movlw d'250' ; Initial value
loop1ms addlw d'255' ; Dec WREG
btfss STATUS,Z ; Zero flag set?
goto loop1ms ; No, keep looping
return ; Yes, 1ms done
;Moves the motor forward which simulates the Right motion of the rudder
MOTOR_FORWARD
BSF PORTA,5 ; PortA 5 is a 1
BCF PORTA,0 ; PortA 0 is a 0
RETURN
;Moves the motor forward which simulates the left motion of the rudder
MOTOR_BACKWARD
BCF PORTA,5 ; PortA 5 is a 0
BSF PORTA,0 ; PortA 0 is a 1
RETURN
;The motor is turned off
MOTOR_OFF
BCF PORTA,5 ; PortA 5 is a 0
BCF PORTA,0 ; PortA 0 is a 0
RETURN
END