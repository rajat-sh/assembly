; A program to print a null terminate string on screen, this program will use the clrscr and strlen subroutines.

		[org 0x0100]
		jmp start


message:       db 'Hello World',  0

clrscr:         push ax
                push es
                push di

                xor ax, 0xb800  ; initilize the ax register with video memory base address
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


strlen:         push bp
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





printstr:       push bp
		mov bp, sp
                push ax
                push cx
		push di
		push si
                push bx
                push es

		; We will calculate the lenth of the string using the strlen subrouting which will take the segment and offset of string as argument and return the length in ax register

		push ds
		mov ax, [bp+4]
		push ax

		call strlen

		; at this point ax register will contain the value of string

	        cmp ax, 0 ; if the string length is 0, we dont need to print anything and we can exit the subrouting and return
                je exit

                mov cx, ax
		
		
                ; point es to video memory base address
		mov ax, 0xb800
		mov es, ax

                
                ; calulate the screen location where the string needs to be printed

		mov ax, [bp+8]
		mov bl, 80
		mul bl
		add ax, [bp+10]
		shl ax, 1 ; convert to byte count
		mov di, ax  ; now di has the screen location where the string neeeds to be printed
  
               ; move the video attribute in ah register
                mov ah, [bp+6]

		; point si to the string offset in memory
		mov si, [bp+4]
		
		cld

loopchar:       lodsb
		stosw
		loop loopchar

		 

		
		
                



exit:          pop es
               pop bx
               pop si
	       pop di
	       pop cx
               pop ax
	       pop bp
		
	       ret 8


	
               









start:         ; call the clrscreen subroutine to clear the screen
                call clrscr

               ; push the x position, which is column location where the string needs to be printed
		mov ax, 30
		push ax

	       ; push the y position which is row location where the string needs to be printed
		mov ax, 10
		push ax

	       ; push the video attribute byte

		mov ax, 0x07
		push ax

	       ; push the offset of the null terminated string

		mov ax, message
		push ax


		call printstr

		; teriminate the program

		mov ax, 0x4c00
		int 0x21








