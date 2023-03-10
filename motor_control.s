#include <xc.inc>
    
global  motor_Setup, move_motor1, move_motor2, long_move1, long_move2
    
    
extrn	pulse_length1, pulse_length2
    
	
psect	udata_acs   ; reserve data space in access ram
motor_cnt_l:	ds 1	; reserve 1 byte for variable motor_cnt_l
motor_cnt_h:	ds 1	; reserve 1 byte for variable motor_cnt_h
motor_cnt_ms:	ds 1	; reserve 1 byte for ms counter
motor_tmp:	ds 1	; reserve 1 byte for temporary use
motor_counter:	ds 1	; reserve 1 byte for counting through message
c1:		ds 1	; reserve 1 byte for a counter for the repeated pwm signal of motor 1
c2:		ds 1	; reserve 1 byte for a counter for the repeated pwm signal of motor 2		


psect	motor_code, class=CODE
 	

	; ******* Programme FLASH read Setup Code ***********************
motor_Setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	movlw	0x00
	movwf	TRISE, A ;setup port E as output
	movlw	0x00
	movwf	TRISD, A  ;setup port D as output
	return
	
move_motor1:
	
	movlw   0xFF
	movwf   PORTE, A	;send duty cycle pulse
	movf    pulse_length1, W, A	; set the length of the duty cycle
	call    motor_delay_ms		; make a delay of that length
	movlw   0x00	; reset to 0 to complete PWM signal
	movwf   PORTE, A
	movlw   19
	call    motor_delay_ms
	return
	
    
move_motor2:

	movlw   0xFF
	movwf   PORTD, A	;send duty cycle pulse
	movf    pulse_length2, W, A	; set the length of the duty cycle
	call    motor_delay_ms		; make a delay of that length
	movlw   0x00	; reset to 0 to complete PWM signal
	movwf   PORTD, A
	movlw   19
	call    motor_delay_ms
	
	return
    
long_move1:	; code do reapeat the PWM signal for motor 1
    	movlw	0xFF
	movwf	c1
	goto	loop1
    loop1:
	call	move_motor1
	decf	c1
	movlw	0x00
	cpfseq	c1
	goto	loop1
	movlw	0xFF
	movwf	c1
	goto	loop3
    loop3:
	call	move_motor1
	decf	c1
	movlw	0x00
	cpfseq	c1
	goto	loop3
	return
	
	
long_move2:	; code do reapeat the PWM signal for motor 2
    	movlw	0xFF
	movwf	c2
	goto	loopm2
    loopm2:
	call	move_motor2
	decf	c2
	movlw	0x00
	cpfseq	c2
	goto	loopm2
	movlw	0xFF
	movwf	c2
	goto	loop2
    loop2:
	call	move_motor2
	decf	c2
	movlw	0x00
	cpfseq	c2
	goto	loop2
	return

    
    ;;delay routines to create the correct PWM cycle
    
motor_delay_ms:		    ; delay given in ms in W
	movwf	motor_cnt_ms, A
motorlp2:	
	movlw	25	    ;0.08 ms delay
	call	motor_delay_x4us	
	decfsz	motor_cnt_ms, A
	bra	motorlp2
	return
    
motor_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	motor_cnt_l, A	; now need to multiply by 16
	swapf   motor_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	motor_cnt_l, W, A ; move low nibble to W
	movwf	motor_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	motor_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	motor_delay
	return

motor_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
motorlp1:	decf 	motor_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	motor_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	motorlp1		; carry, then loop again
	return			; carry reset so return


	end	
