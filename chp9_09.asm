;A keyboard interrupt handler that disables the disk interrupt (no disk interrupt should come) while Q is pressed. 
;It will be reenabled as soon as Q is released



[org 0x0100]



			jmp start

			flag: db 0
			olddisk: dd 0 ; space for saving old isr
			oldkb: dd 0

			disk:
			
			cmp ah, 0x03
			jne chaindiskisr 
			 mov al, 0x20
			out 0x20, al ; send EOI to PIC

			iret

			chaindiskisr:    jmp far [cs:olddisk]
			




			kbisr: pusha
			push cs
			pop ds



			in al, 0x60 ; read char from keyboard port
			cmp al, 0x44 ; has F10 key pressed
				
			jne nextcmp

                                
                    	cmp byte [flag], 1
		    	je exit

			xor ax, ax
			mov es, ax ; point es to IVT base

			mov ax, [es:0x15*4]
			mov [olddisk], ax ; save offset of old routine
			mov ax, [es:0x15*4+2]
			mov [olddisk+2], ax ; save segment of old routine

			mov word [es:0x15*4], disk ; store offset at n*4
			mov [es:0x15*4+2], cs ; store segment at n*4+2


			mov byte [flag], 1
		
			jmp exit








			nextcmp: cmp al, 0xE8 ; has the F10 key released
			jne nomatch ; no, chain to old ISR


			
			mov ax, [olddisk] ; read old disk ISR offset
			mov [es:0x15*4], ax ; restore old disk ISR offset
			mov ax, [olddisk+2] ; read old disk ISR segment
			mov [es:0x15*4+2], ax ; restore old disk ISR segment


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


