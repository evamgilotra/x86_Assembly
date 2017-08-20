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

; Macros for 8255 Programmable peripheral interface. 
ppi_base equ 00h
ppi_creg equ 06h
ppi_porta equ 00h
ppi_portb equ 02h
ppi_portc equ 04h

;Macros for 8250 connected to modem - UART
uartm_base equ 10h
uartm_lsb equ 10h
uartm_msb equ 11h
uartm_fifo equ 12h
uartm_line equ 13h
uartm_lstat equ 15h
uartm_mcr equ 14h

; Macros for 8254 - Programmable Interval Timer
pit_base equ 30h
pit_creg equ 36h
pit_counter0 equ 30h
pit_counter1 equ 32h
pit_counter2 equ 34h

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
uart_mcr equ 2ch

         jmp     start
         db 509 dup(0) 
; 3 Bytes For The jmp start And 509 Bytes Reserved By The Memory

; IVT entry for 80H
; We Have Total Of 4 Interrupts

	dw isr0
	dw 0000

	dw isr0
	dw 0000

	dw isr0
	dw 0000

	dw isr0
	dw 0000

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
	; Call The Initialisation Functions One By One To Initialise The Devices
	
	call ppi_iomode
	call pic_init
	sti
	call pit_init 
	call uart_init
	call uartm_init


	; This Is an infinite Loop
	st1:
		jmp st1

; Below Are The Function Definitions Of The ISR's related To Each Vector Number

isr0:
	mov al,00000010b;
	out uart_mcr,al;

	mov dx,96;

	; Code For REcieving Data From The UART

x1:
	in al,uart_lstat;
	mov ah,al;
	and al,01h;
	jz x1;

	mov al,ah;
	and al,80h;
	jz x2;
	mov al,0;
	jmp x3;
x2:
	in al,uart_lsb;
	ror al,8;
	in al,uart_lsb;
x3:
	push ax;

	dec dx;
	jnz x1;
	
	iret;


ppi_iomode:
	;Setting All The Ports of Port C in 8250 to output
	mov al,10000000b
	out ppi_creg,al
	ret

; writing the code to initialise the device 8250
uart_init:
	; initialising the line
	mov al,10000111b
	out uart_line,al

	; initialising the lsb with 20, so baud rate becomes 57600
	mov al,20
	out uart_lsb,al
	
	mov al,0
	out uart_msb,al

	; re-initialising the line after setting the baud rate
	mov al,00000111b
	out uart_line,al
	
	; setting the fifo to appropriate value
	mov al,00000111b
	out uart_fifo,al

	ret

uartm_init:
; initialising the line
	mov al,10000111b
	out uartm_line,al

	; initialising the lsb with 20, so baud rate becomes 57600
	mov al,20
	out uartm_lsb,al
	
	mov al,0
	out uartm_msb,al

	; re-initialising the line after setting the baud rate
	mov al,00000111b
	out uartm_line,al
	
	; setting the fifo to appropriate value
	mov al,00000111b
	out uartm_fifo,al

	ret



pic_init:
	; Configuring The ICW1
	; No Cascading,Edge Triggered Triggered And ICW4 Is Enable
	mov al,00010011b
	out pic_icw1,al

	; Configuring The ICW2
	; Base Number Is The Base Of The Interrupts From Which Our Software Interrupts Will Begin
	; Same As Given In The Sample Code
	mov al,80h
	out pic_icw2,al

	; Configuring The ICW4
	; Copied From The Sample Source For Connecting With 8086
	mov al,01h
	out pic_icw4,al

	; Configuring The OCW1
	; Copied From The Sample Source For Connecting With 8086
	mov al,11111110b
	out pic_ocw1,al

	ret

pit_init:
	; Initialise The Mode Of Each Counter To Be Used	
	; All Counter Are To Be Used In Mode 3

	; Counter - 1
	mov al,01110110b
	out pit_creg,al

	; Counter - 2
 	mov al,10110110b                                            
                                              
	; Sending To Counter - 1
	; The Freq. That We Want From Counter-1 Is 100hz so count is 50,000d(C350)

	mov al,50h;
	out pit_counter1,al;
	
	mov al,0c3h;
	out pit_counter1,al;


	; Sending To Counter - 2
	; The Frequency We Want From Counter-2 Is 150 seconds so the count value is 15,000d(3a98)

	mov al,98h;
	out pit_counter2,al;

	mov al,3ah;
	out pit_counter2,al;
	
	ret;
