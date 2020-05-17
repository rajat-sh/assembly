; A Program to number number on screen		

		[org 0x0100]

		jmp start

clrscr:         push ax
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






     printnum:  push bp
		mov bp, sp
		push ax
		push bx
		push cx
		push dx
		push es
		push di


		; Move the number to be printed in ax regsiter

		mov ax, [bp+4]
		
		
		xor cx, cx
		
		; Move the base, 10 in case of decimal to the register which will hold the divisor

		mov bx, 10

     loop1:     ; This loop will push the ascii converted remainder digits into stack and increment the cx to contain tne number of pushes on stack
                xor dx, dx
		div bx
		add dx, 0x30 ; Convert the remainder into ascii form
		push dx
		add cx, 1
		cmp ax, 0
		jne loop1


		; Initialize the es register with the video memory base address
		mov ax, 0xb800
		mov es, ax
		
		xor di, di

    loop2:     ; This loop will print the ascii converted digits on stack

		pop dx
		mov dh, 0x07
		mov [es:di], dx
		add di, 2
		loop loop2


		pop di
		pop es
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp

		ret 2

    



      start:    call clrscr

		; Push the number to be printed on stack

		mov ax, 1234
		push ax

		; call the printnum subroutine

		call printnum

		; terminate program

		mov ax, 0x4c00
		int 0x21
