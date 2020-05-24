;A keyboard interrupt handler that disables the timer interrupt (no timer interrupt should come) while Q is pressed. 
;It will be reenabled as soon as Q is released



[org 0x0100]



			jmp start

			flag: db 0
			oldtimer: dd 0 ; space for saving old isr
			oldkb: dd 0

			timer:  mov al, 0x20
			out 0x20, al ; send EOI to PIC

			iret





			kbisr: pusha
			push cs
			pop ds



			in al, 0x60 ; read char from keyboard port
			cmp al, 0x10 ; has the letter Q key pressed
				
			jne nextcmp

                                
                    	cmp byte [flag], 1
		    	je exit

			xor ax, ax
			mov es, ax ; point es to IVT base

			mov ax, [es:0x08*4]
			mov [oldtimer], ax ; save offset of old routine
			mov ax, [es:0x08*4+2]
			mov [oldtimer+2], ax ; save segment of old routine

			mov word [es:0x08*4], timer ; store offset at n*4
			mov [es:0x08*4+2], cs ; store segment at n*4+2


			mov byte [flag], 1
		
			jmp exit








			nextcmp: cmp al, 0x90 ; has the Q key released
			jne nomatch ; no, chain to old ISR


			
			mov ax, [oldtimer] ; read old timer ISR offset
			mov [es:0x08*4], ax ; restore old timer ISR offset
			mov ax, [oldtimer+2] ; read old timer ISR segment
			mov [es:0x08*4+2], ax ; restore old timer ISR segment


                        mov byte [flag], 0
		       	jmp exit


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




































			
