			[org 0x0100]



			jmp start

			array: times 2000 dw 0
			oldkb: dd 0
			flag: db 0



 
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





			kbisr: pusha
			       push cs
				pop ds



				in al, 0x60 ; read char from keyboard port
				cmp al, 0x1d ; has the left control key pressed
				
				jne nextcmp

                                
                    cmp byte [flag], 1
		    je exit
		    
		    mov ax, 0xb800
                        mov es, ax
                        mov si, 0
                        mov di, array
                        mov cx, 2000


                loop1:  mov ax, [es:si]
                        mov [ds:di], ax
                        add si, 2
                        add di, 2
                        loop loop1

                call     clrscr
		
		mov byte [flag], 1
		
		jmp exit



    			nextcmp: cmp al, 0x9d ; has the left control key released
			jne nomatch ; no, chain to old ISR
			

			 mov cx, 2000
                mov si, array
                mov di, 0

                loop2:  mov ax, [ds:si]
                        mov [es:di], ax
                        add si, 2
                        add di, 2
                        loop loop2

                mov byte [flag], 0


			nomatch: popa
			jmp far [cs:oldkb]


			exit: mov al, 0x20
			out 0x20, al ; send EOI to PIC
			popa
			iret ; return from interrupt	
				









			start: xor ax, ax
			mov es, ax ; point es to IVT base
			mov ax, [es:9*4]
			mov [oldkb], ax ; save offset of old routine
			mov ax, [es:9*4+2]
			mov [oldkb+2], ax ; save segment of old routine
			
			cli ; disable interrupts
			mov word [es:9*4], kbisr ; store offset at n*4
			mov [es:9*4+2], cs ; store segment at n*4+2
			sti ; enable interrupts




			mov dx, start ; end of resident portion
			add dx, 15 ; round up to next para
			mov cl, 4
			shr dx, cl ; number of paras
			mov ax, 0x3100 ; terminate and stay resident
			int 0x21
