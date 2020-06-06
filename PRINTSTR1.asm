; A Program to print a string on screen. It takes row number, column number, address of string and length of string as parameters in same order.


				[org 0x0100]

				jmp start

				 string:         db 'Hello World'


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




		

		printstr: 	push bp
				mov bp, sp
				pusha

				; initialize es to video memory base address
				mov ax, 0xb800
				mov es, ax
				
				; calculate the video memory location where string needs to be printed

				mov ax, [bp+10] ; move the row number in ax
				mov bl, 80
				mul bl
				add ax, [bp+8] ; add the colium number
				shl ax, 1 ; convert to byte offset
				mov di, ax ; save the offset in di

				mov cx, [bp+4] ; load the cx with length of string
				mov si, [bp+6] ; load si with address of the string

				mov ah, 0x07 ; load the video attribute in ah
		strloop: 	mov al, [si]
				mov [es:di], ax
				add si, 1
				add di, 2
				loop strloop

				popa
				pop bp
				ret 10
				


		start: 		call clrscr
				mov ax, 10 ; move row number in ax register
				push ax
				mov ax, 0 ; move column number in ax register
				push ax
				mov ax, string ; move the address of string in ax register
				push ax
				mov ax, 11 ; move the length of string in ax register
				push ax
				call printstr

				mov ax, 0x4c00
				int 0x21
