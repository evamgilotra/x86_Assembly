#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0200h#
#SP=0FFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

; These Are The Threshold Values For Alerting The Central System In Case Of Fire
fire_alert equ 7Fh
smoke_alert equ 7Fh
;identity number for this floor
floor_no equ 7eh

; Macros for 8255-1 (temperature) Programmable peripheral interface. 
ppi1_base equ 00h
ppi1_porta equ 00h
ppi1_portb equ 02h
ppi1_portc equ 04h
ppi1_creg equ 06h

;Macros for 8255-2 (smoke) Programmable peripheral interface
ppi2_base equ 18h
ppi2_porta equ 18h
ppi2_portb equ 1ah
ppi2_portc equ 1ch
ppi2_creg equ 1eh

;Macros for 8253-1- Programmable Interval timer
pit1_base equ 20h
pit1_counter0 equ 20h
pit1_counter1 equ 22h
pit1_counter2 equ 24h
pit1_creg equ 26h

; Macros for 8253-2- Programmable Interval Timer
pit2_base equ 30h
pit2_counter0 equ 30h
pit2_counter1 equ 32h
pit2_counter2 equ 34h
pit2_creg equ 36h

; Macros Of 8259 - Priority Interrupt Controller
pic_base equ 38h
pic_icw1 equ 38h
pic_icw2 equ 3ah
pic_icw4 equ 3ah
pic_ocw1 equ 3ah 

; Macros  Of 8250 - UART
uart_base equ 28h
uart_lsb equ 28h
uart_msb equ 29h
uart_fifo equ 2ah
uart_line equ 2bh
uart_lstat equ 2dh

         jmp     start
         db 509 dup(0) 
; 3 Bytes For The jmp start And 509 Bytes Reserved By The Memory

; IVT entry for 80H
; We Have Total Of 4 Interrupts

	dw isr0
	dw 0000

	dw isr1
	dw 0000

	dw isr2
	dw 0000
	
	dw isr3
	dw 0000
	
	; After The 4 Interrupts The Vector Table Is Empty And Hence Fill It Up With Zeros
        db 496 dup(0) 

; Main Program Starts Here

start:
	cli
	; Clear The Interrupts While Setting Up The Stack And Other Registers
	
	; Initialize ds, es,ss To Start Of RAM
	
          mov       ax,0200h
          mov       ds,ax
          mov       es,ax
          mov       ss,ax
          mov       sp,0FFEh

	;  Initialisation of the Devices
	
	call ppi1_iomode
	call ppi2_iomode
	call pic_init
	; Initialisation of the Interrupts	
	sti
	call pit1_init
	call pit2_init  
	call uart_init

	; This Is an infinite Loop
	st1:
		jmp st1

; Below Are The Function Definitions Of The ISR's related To Each Vector Number

; This Interrupt Will Be Generated Every 10 Seconds And Is Used To Take All The Values From The Sensors
isr0:
	; We Have To Program The Port C of 8255-1
	mov al,100100000b
	mov ah,08h

	;the following is the code to read from temperature and smoke sensors
read_again:


	out ppi1_portc,al
	mov cl, al

read_adc1:

	in al,ppi1_porta
	and al,2 
	jz read_adc1;

	in al,ppi1_port;
	mov bl, al;
	mov al, cl;

	
	mov cl, 04h
	ror ax, cl
	out ppi1_portc,al
	ror ax, cl

	mov cl, al

read_adc2:

	in al,ppi1_porta;
	and al,1
	jz read_adc2
	mov dl, al
    
	
	in al,ppi1_porta
	mov bh, al
	mov al, dl

	push bx

	add ah,00000001b
	add al,00010000b
	
	cmp al,00h
	jne read_again
	mov al, cl;

	mov bx, sp 
	mov si, 0  
	mov cx, 8

loop0:
	
	dec cx
	jz exit

	mov ax, [bx+si]
	inc si 
	inc si 


	cmp al, fire_alert	
	jl loop0 

	cmp ah, smoke_alert
	jl loop0 

    mov al, 00000010b
	out ppi1_portb, al

exit:
	iret

;Interrupt every 2 minutes
isr1:
	; We are collecting data every 10 seconds, storing it and sending it after 120 seconds. So units of data is 120/10=12
	; We are collecting 16 bytes of date every time and popping out 2 Bytes from the stack
	; And Hence The Value for count is (12*16)/2=96 
	 mov dx, 96;
	; we acknowledge Dr.K.R.Anupama Mam's code given in the slides which was taken and modified here according to our needs
	
send:
	in al,uart_lstat
	and al,20h
	jz send
	          
	pop ax
	out uart_lsb, al

	mov cl, 4
	ror ax, cl
	out uart_lsb, al

	ror ax, cl

	dec dx
	jnz send
	
	
	iret

; The following Interrupt Will Come From The Central Sub-System That There Is A Fire And The Sprinklers Have To Be Activated
isr2:
	; The 4 Sprinklers Are Connected To The Port-B-B0,B1,B2 and B3
	; So When This Interrupt Comes The B0 Has To Be Made-1
	
	mov al,00001111b;
	out ppi1_portb,al

	iret

;The following interrupt is used when EOC signal from ADC is sent
isr3:
	

ppi1_iomode:
	;setting PortA as input,PortB as output and Port C as output	
	mov al,10010000b
	;giving this value to the control register of 8255-1
	out ppi1_creg,al

	ret

ppi2_iomode:
	;setting PortA as input,PortB as output and Port C as output	
	mov al,10010000b
	;giving this value to the control register of 8255-2
	out ppi2_creg,al
	ret
	
; Writing The Code To Initialise The Device 8250
uart_init:
	; Initialising The Line
	mov al,10000111b
	out uart_line,al

	; Initialising The LSB With 20, So BAUD Rate Becomes 57600
	mov al,20
	out uart_lsb,al
	
	mov al,0
	out uart_msb,al

	; Re-initialising The Line After Setting The Baud Rate
	mov al,00000111b
	out uart_line,al
	
	; Setting The FIFO To Appropriate Value
	mov al,00000111b
	out uart_fifo,al

	ret

pic_init:
	; Configuring The ICW1

	mov al,00010011b
	out pic_icw1,al

	; Configuring The ICW2
	
	mov al,80h
	out pic_icw2,al

	; Configuring The ICW4
	mov al,00000001b
	out pic_icw4,al

	; Configuring The OCW1
	mov al,11001100b
	out pic_ocw1,al

	ret

pit1_init:
	
	; All Counter Are To Be Used In Mode 3
	
	; Counter - 0
	mov al,00010110b
	out pit1_creg,al

	; Counter - 1
	mov al,01110110b
	out pit1_creg,al
                                                
        ; Counter - 2
	mov al,10110110b
	out pit1_creg,al
                                       
	; Sending To Counter - 0
	; The Freq. That We Want From Counter-0 Is 1Mhz so we divide by 5

	mov al,05; 
	out pit1_counter0,al

	; Sending To Counter - 1
	; The Freq. That We Want From Counter-1 Is 100Hz so we divide by 50,000d(c350h)

	mov al,50h;
	out pit1_counter1,al
	
	mov al,0c3h;
	out pit1_counter1,al

	; Sending To Counter - 2
	;The Freq. That We Want From Counter-1 Is 10s(0.1 Hz) so we divide by 1000d(03e8)
	mov al,0e8h
	out pit1_counter2,al
	
	mov al,03h	
	out pit1_counter2,al

	ret

pit2_init:	
	; All Counter Are To Be Used In Mode 3

	; Counter - 0
	mov al,00010110b
	out pit2_creg,al

	; Sending To Counter - 0
	; The Freq. That We Want From Counter-0 Is 120s so we divide by 5
	
	mov al,12d
	out pit2_counter0,al

	ret;