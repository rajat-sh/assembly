; Single Stepping using trap flag
  

                        [org 0x0100]
                        jmp start

                flag:   db 0
                names:  db 'FG =CS =IP =BP =AX =BX =CX =DX =SI =DI =ES =DS ='



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


printnum:             push bp
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
				ret 8
				






		




	
		mykbisr: push ax
			 in al, 0x60
			 test al, 0x80   ; test for the keypress code where the highest bit will be 0
			  jnz exit
			  mov byte [cs:flag], 1 ; set the keypress flag to 1
		 exit:   mov al, 0x20
			 out 0x20, al
			 pop ax
			 iret












		myisr:		push bp
				mov bp, sp
				push ax
				push bx
				push cx
				push dx
				push si
				push di
				push es
				push ds
			
				push cs
				pop ds
			
				; set the keyboard wait flag to 0
				mov byte[flag], 0
			
				; enable the real time interrrupt
				sti
			
				call clrscr
			
				; print the flag names on screen
				mov cx, 12 ; there are 12 flag values
				mov ax, 1 ; move the row number in ax
				mov bx, 0 ; move the column number in bx
				mov dx, 4 ; move the length of string in dx
				mov si, names ; push the address of the string in si

				; loop to print the flag names
	
		loop1:		push ax ; push the row number 
				push bx ; push the column number
				push si ; push the address of the string
				push dx ; push the length of the string
				call printstr
				add ax, 1
				add si, 4
				loop loop1


				; print the flag values on screen
				mov cx, 12 ; there are 12 flag values
				mov ax, 1 ; move the row number in ax
				mov bx, 5 ; move the column nuber in bx
				mov si, bp
				add si, 6

				; loop to print the flag values
		loop2: 		push ax ; push the row number
				push bx ; push the column number
				push word  [si]
				call printnum
				add ax, 1
				sub si, 2
				loop loop2


		keywait:	cmp byte [flag], 1
				jne keywait



				pop ds
				pop es
				pop di
				pop si
				pop dx
				pop cx
				pop bx
				pop ax
				pop bp
			
				iret
			

	       start:  ; initialize es to the IVT base address
                        xor ax, ax
                        mov es, ax

                        ; hook the INT1
                        mov word [es:1*4], myisr
                        mov [es:1*4+2], cs

                        ; hook the keyboard interrupt INT9
                        cli
                        mov word [es:9*4], mykbisr
                        mov [es:9*4+2], cs
                        sti

                        ; set the trap flag to 1
                        pushf
                        pop ax
                        or ax, 0x100
                        push ax
                        popf
          
                        ; inifinite loop to change the value of some registers, from now on after every instruction  INT1 will be generated
                        mov ax, 0
                        mov bx, 0xffff
                        mov cx, 0xffff
                        mov dx, 0

                infloop: add ax, 1 
                         sub bx, 1
                         sub cx, 1
                         add dx, 1
                         loop infloop

