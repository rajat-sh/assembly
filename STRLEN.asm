; A program to calculate string length, it passes a null terinate string segment and offset  as argument pushed on stack in that order  and call the strlen subroutine which returns the length of string in ax register to the caller

		[org 0x0100]
		
		jmp start

	message: db 'Hello World', 0
		
		

	strlen:	push bp
		mov bp, sp
		push es
		push di
		push cx

		; inilialize es to string segment and di to string offset in memory, we will use les instruction which will load di with address given in instrustion and es with address+2 which is the offset

		les di, [bp+4]  

		
		xor al, al  ; we will compare the value of null byte in ax with string in memory to locate the end of string

		mov cx, 0xffff  ; initialize the cx register with a large value

		cld

		repne scasb

		; now the cx will be decremented by length of string +1, as we had to comparision with null byte which is at end of string

		mov ax, 0xffff
		sub ax, cx
		dec ax  ; after this instruction is executed ax will contain the length of string


		pop cx
		pop di
		pop es
		pop bp

		ret 4

		

		




       start:   push ds ; push the segment of string on stack
		mov ax, message
		push ax ; push the offset of string on stack
		
		; call the strlen fucntion
		call strlen


		; terminate program

		mov ax, 0x4c00
		int 0x21
