; A Program to print the value of register on screen. It uses printregister subroutine which takes row number, column number and value to printed as parameters

				[org 0x0100]
			
				jmp start

			

clrscr: 	push ax
		push es
		push di
               
                mov ax, 0xb800  ; initilize the ax register with video memory base address
		mov es, ax ; point es to video memory base address loaded from ax
		
		; point di to the first video memory location 0
		
		xor di, di
		
		; There are 2000 locations on screen, so we need to write 2000 memory locations for clear screen opeartion, we will inilialze the cx register with 2000
		mov cx, 2000


		; move into ax register the value of white space with normal video attribute byte
		
		mov ax, 0x0720

		; clear the direction flag as we need to increment the di register with every iteration


		rep stosw


		pop di
		pop es
		pop ax

		ret






   printregister:             push bp
                                mov bp, sp
                                pusha


                                ; initialize the video memory base address.

                                mov ax, 0xb800
                                mov es, ax

                                ; calculate the video memory location where number needs to be printed

                                mov ax, [bp+8] ; move the row number in ax
                                mov bl, 80
                                mul bl
                                add ax, [bp+6] ; add the column number to ax
                                shl ax, 1 ; move into byte offset
                                add ax, 6 ; we will start printing last hex digit first so increment the offset to the last digit offset
                                mov di, ax ; save the video memory location in di


                                ; Move the number to be printed in ax regsiter
                                mov ax, [bp+4]
                                ; move the divisor in bx, 16 for hex
                                mov bx, 16

       divloop:                 xor dx, dx ; change the dx to zero as the dividend will be in dx:ax

                                div bx
                                ; dx will contain the reminder now, we will convert that in ascii and print on screen
                                add dx, 0x30
                                cmp dx, 0x39
                                jbe printreg
                                add dx, 0x7
        printreg:               mov dh, 0x07  ; move the video attribute in dh
                                mov [es:di], dx
				sub di, 2
                                cmp ax, 0    ; check if the quotient is zero
                                jne divloop


                                popa
                                pop bp

				ret 6





		start: 		call clrscr
				mov ax, 10	
				push ax
				mov ax, 0
				push ax
				mov ax, 0x1234
				push ax
				
				
				call printregister


				mov ax, 0x4c00
				int 0x21
