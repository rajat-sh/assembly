		; A program to clear the screen, it calls the subroutine clrscr which does not take any parameter and does not return anything only clears the screen

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


start:          call clrscr

		; terminate program
		mov ax, 0x4c00
		int 0x21
		
