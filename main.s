#include <xc.inc>

global	pulse_length1, pulse_length2
    
extrn	motor_Setup, move_motor1, move_motor2	    ; external motor subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_clear ; external LCD subroutines
extrn	ADC_Setup, ADC_Read			    ; exernal anolog to digital conveter subroutines
extrn	initial_setup, long_move1, long_move2,best_position1, best_position2, secondary_loop
extrn	LDR_compare_loop, best_high_word, best_low_word, change_marker
extrn	hextodec, sol

psect	udata_acs   ; reserve data space in access ram
delay_count:    ds 1 ; reserve one byte for counter in the delay routine
pulse_length1:  ds 1 ; reserve 1 byte for duty cycl of motor 1  
pulse_length2:  ds 1	; reserve 1 byte for duty cycle of motor 2    
motor_cnt_l:	ds 1	; reserve 1 byte for variable LCD_cnt_l
motor_cnt_h:	ds 1	; reserve 1 byte for variable LCD_cnt_h
motor_cnt_ms:	ds 1	; reserve 1 byte for ms counter
motor_tmp:	ds 1	; reserve 1 byte for temporary use
motor_counter:	ds 1	; reserve 1 byte for counting through nessage   
sleepcount:	ds 1	; reserve 1 byte for sleep counter
    
psect	code, abs
	
	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	
	call	motor_Setup	; setup motors
	call	LCD_Setup	; setup UART
	call	ADC_Setup
	movlw	0x00
	movwf	best_low_word, A
	movwf	best_high_word, A
	movwf	pulse_length1, A
	movwf	pulse_length2, A
	goto	start
	
	
; ******* Main programme ****************************************
start:
	call	ADC_Read
	call	initial_setup
	goto	day_loop
    day_loop:
	call	LCD_clear
	call	hextodec
	movf	sol, W, A
	call	LCD_Write_Hex
	call	sleep_setup
	call	ADC_Read
	call	LDR_compare_loop
	movwf	0x00
	cpfseq	change_marker
	call	secondary_loop
	goto	day_loop
	return
	


sleep_setup:
	movlw	0x05		; number of WDT timeouts 18ms
	movwf	sleepcount
	goto	sleeploop
	
sleeploop:
	sleep			; go to sleep until WDT wakeup (~2.3 seconds)
	decf	sleepcount	; decrement count, skip if 0
	movlw	0x00
	cpfseq	sleepcount
	goto	sleeploop	; goto sleep unitl count complete
	return
	
	end	 rst