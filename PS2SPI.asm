
; SPI using assembly by James 
#include <p16f690.inc>
__config _HS_OSC & _WDT_OFF & _PWRTE_ON

 

org 0x05		; start at main flash memory location of PIC16f690 (0x0004 is the interrupt vector)

movlw 0x12       ; load binary 0b00010010 to wreg
movwf SSPCON     ; set SSPCON for Fosc/64 (Setting SPI clock to 312.5 kHz) ;idle high for clock; and keeps SSPEN low for initialization
bsf STATUS, RP0  ; set to register bank 1
movlw 0x00       ; load binary 0b00000000 to wreg
movwf SSPSTAT    ; set the SPI status to transmit data on rising edge and and sample data at middle of data output time
movlw 0x10       ; load binary 0b00010000 to wreg
movwf TRISB      ; set bit 6 (SCL) as output and bit 4 (SDI) as input for PORT B
movlw 0x00       ; clear the wreg
movwf TRISC      ; in order to set7 (SDO) as output bit 6 will be used as slave select line if slave mode is desired
bsf STATUS, RP1 
bcf STATUS, RP0  ; set register bank to bank 2
movwf ANSEL		 ; set all pins with analog capability to digital
bcf STATUS, RP1  ; set to register bank 0
bsf PORTC , 0     ; make bit 0 or port C high since it will be the slave select pin
movlw 0x32       ; load binary 0b00110010 to wreg
movwf SSPCON     ; sets SSPEN high and enables SPI and sets SDI, SDO, SCL as serial port pins

main_loop:


; SEND BYTE 1xxxxxxxxxxxxxxxxxxxxx
    bcf PORTC, 0 ; clear the slave select line so PS2 controller knows to be ready for data
    movlw 0x80   ; move binary 0b10000000 to wreg
    movwf SSPBUF ; set the SPI buffer to 0x80 so uC will start to send data and clock should automatically start
    bsf STATUS,RP0 ;Bank 1
whileloop1:
    btfss SSPSTAT, BF ; check to see if BF bit is set in SSPSTAT
    goto  whileloop1   ; stay in while loop if it isn't set
    bcf STATUS,RP0 ;Bank 0
	call delay

 ; SEND BYTE 2  xxxxxxxxxxxxxxxxxxxxxxxx 
	movlw 0x42
	movwf SSPBUF
    bsf STATUS,RP0 ;Bank 1
whileloop2:
    btfss SSPSTAT, BF ; check to see if BF bit is set in SSPSTAT
    goto  whileloop2   ; stay in while loop if it isn't set 
	bcf STATUS,RP0 ;Bank 0
	call delay


; SEND BYTE 3 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	movlw 0x00
	movwf SSPBUF
    bsf STATUS,RP0 ;Bank 1
whileloop3:
    btfss SSPSTAT, BF ; check to see if BF bit is set in SSPSTAT
    goto  whileloop3   ; stay in while loop if it isn't set
	bcf STATUS,RP0 ;Bank 0
	call delay

; SEND BYTE 4 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	movlw 0x00
	movwf SSPBUF
    bsf STATUS,RP0 ;Bank 1
whileloop4:
    btfss SSPSTAT, BF ; check to see if BF bit is set in SSPSTAT
    goto  whileloop4   ; stay in while loop if it isn't set
	bcf STATUS,RP0 ;Bank 0
	call delay

 ; SEND BYTE 5 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	movlw 0x00
	movwf SSPBUF
    bsf STATUS,RP0 ;Bank 1
whileloop5:
    btfss SSPSTAT, BF ; check to see if BF bit is set in SSPSTAT
    goto  whileloop5   ; stay in while loop if it isn't set
	bcf STATUS,RP0 ;Bank 0
	call delay


	bcf STATUS,RP0 ;Bank 0
    bsf PORTC, 0  ; set slave select line
    call delay
    call delay
    call delay


    goto main_loop


  


	
delay 
    movlw 0x03       ; once in delay clear the wreg
    movwf 0x40		 ; save to RAM address
    movwf 0x41       ; save to another RAM address
delay_loop
    decfsz 0x40,1
    goto delay_loop
    decfsz 0x41,1
    goto delay_loop
return 

end	
