;       	28-5-2011
;
	processor	16f877a					;Sets processor
	#include 	p16f877a.inc
		
;   Set configuration bits using definitions from the include file, p16f877A.inc
	__config	_HS_OSC & _PWRTE_OFF & _WDT_OFF & _CP_OFF & _CPD_OFF & _LVP_OFF

			#include	SDUboard.var		;Variable som bruges af SDUborad (0x7C - 0x7F)

									; < INDSaeT DINE VARIABLE HER (start med 0x20)
			errorlevel	-302
#define 		switch   	portb
#define 		led		portc

org		0x0000
			GOTO	init				;Gaa til opsaetning
org		0x0004
			GOTO	ISR
org		0x0005						;Feorste position efter interrupt-vektor
			#Include 	SDUboard.LIB		;SDU PICborad subroutine bibliotek med LCD- og A/D-routiner
			#include	var.asm
			#Include 	osc.asm 

init			CALL   	LED_init			;Initialiser lysdionerne
			CALL	LCD_init			; Initaliser display


			;MOVWF	add16+4					
main

			CLRF		add16
			CLRF		add16+1


; Opsaetning af interrupt paa 
			CLRF		led				; Sluk alle lysdioderne
			
			; Opsaetning og start  af timer 2
			CLRF		TMR2   			; Nulstil Timer 2 registeret
			BSF		STATUS,5			; Skift til Bank 1
			MOVLW	D'250'			; Saet Period registeret 
			MOVWF	PR2				;
			BCF		STATUS,5			; Skift til Bank 0
			MOVLW	B'00000100'   		; Indstil post- og pre-scaler 
			MOVWF	T2CON			; og start timer 2
			BCF		PIR1,1			; nulstil timeout flaget7

			; Enable timer2 interrupt.
			BSF		STATUS,5			; Skift til Bank 1
			BSF		PIE1,1			; Enable timer 2 interrrupt.
			BCF		STATUS,5			; Skift til Bank 0
			BSF		INTCON,6			; Enable timer 2 interrupt.
			BSF		INTCON,7			; Enable Global interrupt.	

			;MOVLW	b'01000000'
			;MOVWF	LED	

			CLRF		timerOscByte1_1 ; timerOscByte1_1 = 0
			CLRF		timerOscByte2_1 ; timerOscByte2_1 = 0	
			CLRF		timerOscByte1_2 ; timerOscByte1_2 = 0	
			CLRF		timerOscByte2_2 ; timerOscByte2_2 = 0
			CLRF		timerOscByte1_3 ; timerOscByte1_3 = 0	
			CLRF		timerOscByte2_3 ; timerOscByte2_3 = 0				

loop			
			GOTO	Loop				; uendelig loop

handleTone	macro	jumpInt
			MOVLW	jumpInt
			MOVWF	arg
			BTFSC	NPressedKeys,0
			 CALL	jumpOsc1
			BTFSC	NPressedKeys,1
			 CALL	jumpOsc2
			BTFSC	NPressedKeys,2
			CALL	jumpOsc3
			BCF		STATUS,C
			RLF		NPressedKeys,1
			BTFSC	NPressedKeys,4
			GOTO	noKeys
EndM

ISR			BCF		PIR1,1			; nulstil timeout flaget

			CLRF		NPressedKeys
			BSF		NPressedKeys,0

			BTFSS	switch,0
			GOTO	key1
			handleTone d'11'
key1			BTFSS	switch,1
			GOTO	key2
			handleTone d'12'
key2			BTFSS	switch,2
			GOTO	key3
			handleTone d'13'
key3			BTFSS	switch,3
			GOTO	key4
			handleTone d'15'
key4			BTFSS	switch,4
			GOTO	key5
			handleTone d'17'
key5			BTFSS	switch,5
			GOTO	key6
			handleTone d'18'
key6			BTFSS	switch,6
			GOTO	key7
			handleTone d'20'
key7			BTFSS	switch,7
			GOTO	noKeys
			handleTone d'22'
nokeys

			;MOVF	timerOscByte1_2,W
			BTFSC	NPressedKeys,3
			call		play3Tones
			BTFSC	NPressedKeys,2
			call		play2Tones
			BTFSC	NPressedKeys,1
			call		play1Tone
			RETFIE

play1Tone		MOVF	timerOscByte1_1,W ; W=timerOscByte1_1
			MOVWF	arg
			CALL	sin
			MOVWF	LED
			RETURN

play2Tones	; hent 1. sinusvaerdi
			MOVF	timerOscByte1_1,W ; W=timerOscByte1_1
			MOVWF	arg
			CALL	sin
			MOVWF	tmp
			
			; hent 2. sinusvaerdi
			MOVF	timerOscByte1_2,W ; W=timerOscByte1_2
			MOVWF	arg
			CALL	sin
			MOVWF	tmp+1

			; del 1. sinusvaerdi med 2
			BCF		STATUS,C; clear carry
			RRF		tmp,F
			
			; del 2. sinusvaerdi med 2
			BCF		STATUS,C; clear carry
			RRF		tmp+1,F

			; laeg dem sammen
			MOVF	tmp,W
			ADDWF	tmp+1,W ; W=tmp+1+W
			MOVWF	led
			
			RETURN

play3Tones
			; hent 1. sinusvaerdi
			MOVF	timerOscByte1_3,W ; 
			MOVWF	arg ; arg=w
			CALL	sin ; w=sin
			MOVWF	arg ; W=arg
			MOVF	PCLATH,W
			MOVWF	tmp ; W=tmp
			pagesel	divideBy3
			CALL	divideBy3
			MOVWF	tmp+1
			MOVF	tmp,W
			MOVWF	PCLATH

			; hent 2. sinusvaerdi
			MOVF	timerOscByte1_2,W ; 
			MOVWF	arg ; arg=w
			CALL	sin ; w=sin
			MOVWF	arg ; W=arg
			MOVF	PCLATH,W
			MOVWF	tmp ; W=tmp
			pagesel	divideBy3
			CALL	divideBy3
			MOVWF	tmp+2
			MOVF	tmp,W
			MOVWF	PCLATH

			; hent 3 sinusvaerdi
			MOVF	timerOscByte1_1,W ; 
			MOVWF	arg ; arg=w
			CALL	sin ; w=sin
			MOVWF	arg ; W=arg
			MOVF	PCLATH,W
			MOVWF	tmp ; W=tmp
			pagesel	divideBy3
			CALL	divideBy3
			MOVWF	tmp+3
			MOVF	tmp,W
			MOVWF	PCLATH


			; laeg dem sammen
			MOVF	tmp+1,W
			ADDWF	tmp+2,W ; W=tmp+2+W
			ADDWF	tmp+3,W ; W= tmp+3+W
			MOVWF	led

			RETURN

jumpOsc1
			MOVF	timerOscByte1_1,W ; W =  timerOscByte1_1
			MOVWF	tmp;  tmp = W = timerOscByte1_1
			MOVF	arg,W ; W=arg
			MOVWF	tmp+1; tmp+1 = W = 11
			ADDWF	timerOscByte1_1,1; timerOscByte1_1=timerOscByte1_1+1
			BTFSS	STATUS,C; opstod der overflow?
			RETURN
			; timerOscByte1_1  = 255-((255-timerOscByte1_1)+(255-tmp+1))
			MOVLW	d'255' ; W=255
			MOVWF	tmp+2; tmp+2 = 	W = 255
			MOVF	tmp,W ; W=tmp= timerOscByte1_1
			SUBWF	tmp+2,1; tmp+2=tmp+2-W = 255- timerOscByte1_1
			MOVLW	d'255' ; W=255
			MOVWF	tmp+3 ; tmp+3 = 255
			MOVF	tmp+1,W ; W=tmp+1= 11
			SUBWF	tmp+3,F ; tmp+3 = tmp+3-W = 255-tmp+1 = 255-11
			MOVF	tmp+3,W ; W= tmp+3
			ADDWF	tmp+2,F ; tmp+2 = tmp+2+W
			MOVLW	d'255' ; W=255
			MOVWF	tmp+1;  tmp+1 = W = 255
			MOVF	tmp+2,W; W=tmp+2
			SUBWF	tmp+1, W ; W = tmp+1-W = 255-tmp+2
			MOVWF	timerOscByte1_1 ; timerOscByte1_1 = W
			RETURN

jumpOsc2
			MOVF	timerOscByte1_2,W ; W =  timerOscByte1_1
			MOVWF	tmp;  tmp = W = timerOscByte1_1
			MOVF	arg,W ; W=arg
			MOVWF	tmp+1; tmp+1 = W = 11
			ADDWF	timerOscByte1_2,1; timerOscByte1_1=timerOscByte1_1+1
			BTFSS	STATUS,C; opstod der overflow?
			RETURN
			; timerOscByte1_1  = 255-((255-timerOscByte1_1)+(255-tmp+1))
			MOVLW	d'255' ; W=255
			MOVWF	tmp+2; tmp+2 = 	W = 255
			MOVF	tmp,W ; W=tmp= timerOscByte1_1
			SUBWF	tmp+2,1; tmp+2=tmp+2-W = 255- timerOscByte1_1
			MOVLW	d'255' ; W=255
			MOVWF	tmp+3 ; tmp+3 = 255
			MOVF	tmp+1,W ; W=tmp+1= 11
			SUBWF	tmp+3,F ; tmp+3 = tmp+3-W = 255-tmp+1 = 255-11
			MOVF	tmp+3,W ; W= tmp+3
			ADDWF	tmp+2,F ; tmp+2 = tmp+2+W
			MOVLW	d'255' ; W=255
			MOVWF	tmp+1;  tmp+1 = W = 255
			MOVF	tmp+2,W; W=tmp+2
			SUBWF	tmp+1, W ; W = tmp+1-W = 255-tmp+2
			MOVWF	timerOscByte1_2 ; timerOscByte1_1 = W
			RETURN

jumpOsc3
			MOVF	timerOscByte1_3,W ; W =  timerOscByte1_1
			MOVWF	tmp;  tmp = W = timerOscByte1_1
			MOVF	arg,W ; W=arg
			MOVWF	tmp+1; tmp+1 = W = 11
			ADDWF	timerOscByte1_3,1; timerOscByte1_1=timerOscByte1_1+1
			BTFSS	STATUS,C; opstod der overflow?
			RETURN
			; timerOscByte1_1  = 255-((255-timerOscByte1_1)+(255-tmp+1))
			MOVLW	d'255' ; W=255
			MOVWF	tmp+2; tmp+2 = 	W = 255
			MOVF	tmp,W ; W=tmp= timerOscByte1_1
			SUBWF	tmp+2,1; tmp+2=tmp+2-W = 255- timerOscByte1_1
			MOVLW	d'255' ; W=255
			MOVWF	tmp+3 ; tmp+3 = 255
			MOVF	tmp+1,W ; W=tmp+1= 11
			SUBWF	tmp+3,F ; tmp+3 = tmp+3-W = 255-tmp+1 = 255-11
			MOVF	tmp+3,W ; W= tmp+3
			ADDWF	tmp+2,F ; tmp+2 = tmp+2+W
			MOVLW	d'255' ; W=255
			MOVWF	tmp+1;  tmp+1 = W = 255
			MOVF	tmp+2,W; W=tmp+2
			SUBWF	tmp+1, W ; W = tmp+1-W = 255-tmp+2
			MOVWF	timerOscByte1_3 ; timerOscByte1_1 = W
			RETURN


			#Include 	d3.ASM
			END						;her slutter programmet.
