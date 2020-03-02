CBLOCK 0x20
	comp
	counter
	timerOscByte1_1
	timerOscByte2_1
	timerOscByte1_2
	timerOscByte2_2
	timerOscByte1_3
	timerOscByte2_3
	NPressedKeys
	add16 :  d'4' ; 2 bit register
	sin_minus ; reigter som resultat fratrækkes i sin proceduren
	arg	:	d'10' ; registre som bruges som argumenter til rutiner
	tmp	:	d'10' ; registor som bruges til kort midltidige lagringer
	Delay1
	Delay2
	Delay3
ENDC
