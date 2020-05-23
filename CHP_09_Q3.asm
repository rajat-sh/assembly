;Write a program to make an asterisk travel the border of the screen, 
;from upper left to upper right to lower right to lower left and back to upper left indefinitely.


[org 0x0100]

jmp start


start:		call clrscr

			call borderAsterisk
	
			mov ax, 0x4c00
			int 21h


;Clear Screen

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



;Delay, Using OS services we can specify delay http://vitaly_filatov.tripod.com/ng/asm/asm_026.13.html
delay:				        pusha
					MOV     CX, 0FH
					MOV     DX, 4240H
					MOV     AH, 86H
					INT     15H

	
					popa
					ret



borderAsterisk:		                push bp
					mov bp, sp
					pusha


					;Loading the video memory
					mov ax, 0xb800
					mov es, ax

					mov di, 0

					mov ah, 01110000b
					mov al, '*'

					mov bh, 0x07
					mov bl, 0x20

LefttoRight:		                mov cx, 80

l1:					mov [es:di], ax

					call delay

					mov [es:di], bx

					

					add di, 2

					loop l1

					sub di, 2


RightToBottom:		               mov cx, 24
		
l2:					mov [es:di+160], ax

					call delay

					mov [es:di+160], bx

					

					add di, 160

					loop l2

					


BottomToLeft:		                mov cx, 79

l3:					mov [es:di-2], ax

					call delay

					mov [es:di-2], bx

					

					sub di, 2

					loop l3

					


LefttoTop:			       mov cx, 24
		
l4:					mov [es:di+160], ax

					call delay

					mov [es:di+160], bx

					

					sub di, 160

					loop l4

					

					;Then repeat the whole process again resulting in an infinite loop
					jmp LefttoRight


return:				        popa
					pop bp
					ret

