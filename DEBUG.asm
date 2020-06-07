                                                        [org 0x0100]

                                                        jmp start
                                        opcode:         db 0
                                        names:          db 'FG =CS =IP =BP =AX =BX =CX =DX =DI =SI =DS =ES ='
                                        opcodepos:      dw 0
					flag:           db 0
							




					


			clrscr: 		push ax
											push es
											push di
					
											mov ax, 0xb800  ; initilize the ax register with video memory base address
											mov es, ax ; point es to video memory base address loaded from ax
					
											; point di to the first video memory location 0
					
											xor di, di
					
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
						







						mytrapisr:    		push bp 
									mov bp, sp
									pusha

									mov ax, [bp+4] 
								mov es, ax ; load the es with interrupted routine segment address
								mov di, [opcodepos]
								mov byte [es:di], 0xcc ; change the opcode of breakpint back to 0xcc

								; set the trap flag to 0
								and word [bp+6], 0xfeff

								popa
								pop bp
								iret




					mykbisr:       		push ax
								in al, 0x60 ; read the value from KB I/O port
								test al, 0x80
								jnz exitkbisr
								mov byte [cs:flag], 1
					exitkbisr:      	mov al, 0x20
								out 0x20, al

								pop ax
								iret
								  


	

					mydebugisr:		push bp
								mov bp, sp
								push ax
								push bx
								push cx
								push dx
								push di
								push si
								push ds
								push es
								
								push cs
								pop ds
								
								; Enable the interrupts
								sti
								
								; set the keypress flag to 0
								mov byte [flag], 0
								
								; Decrement the IP of interrupted routine by 1
								dec word [bp+2]

								; Replace the opcode of 0xcc with original opcode and save the offset where the original code was restored
								mov ax, [bp+4] ; load the segment of the interrupted routine in es
								mov es, ax 

								; Save the offset where original code needs to be replaced 
								mov di, [bp+2]
								mov [opcodepos], di
								
								; replace the 0xcc with original opcode
								
								mov al, [opcode]
								mov [es:di], al

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



								; set the trap flag to 1 in the interrupted routine
								or word [bp+6], 0x100
								

								pop es
								pop ds
								pop si
								pop di
								pop dx
								pop cx
								pop bx
								pop ax
								
								pop bp
								iret






					start:		xor ax, ax
							mov es, ax ; initialize the es with 0
							
							; hook INT3, Debug ISR
							mov word [es:3*4], mydebugisr
							mov [es:3*4+2], cs
							
							; hook INT1, Trap ISR
							mov word [es:1*4], mytrapisr
							mov [es:1*4+2], cs

							; hook INT9, Keyboard ISR
							cli
							mov word [es:9*4], mykbisr
							mov [es:9*4+2], cs
							sti
							
							; Set a breakpoint
							mov si, breakpoint
							mov al, [cs:si]
							mov [opcode], al ; save the original opcode in memory
							mov byte [cs:si], 0xcc ; replace the opcode with 0xcc

							; code which has the breakpoint
							mov ax, 0
							mov bx, 0
							mov cx, 0
							mov dx, 0
					breakpoint:     inc ax
							inc bx
							inc cx
							inc dx
							jmp breakpoint
