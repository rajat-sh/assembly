						[org 0x0100]
						
						jmp start
						
						
				taskstates:	dw 0, 0, 0, 0, 0 ; Process Control Block for task zero
						dw 0, 0, 0, 0, 0 ; Process Control Block for task one
						dw 0, 0, 0, 0, 0 ; Process Control Block for task two


				curtask:	db 0
				
				char:		db '|/-\'


				taskone:	mov al, [bx+char]
						mov [es:0], al
						inc bx
						and bx, 3 ; if BX gets to 4 reset to zero
						jmp taskone

				tasktwo:	mov al, [bx+char]
						mov [es:158], al
						inc bx
						and bx, 3 ; if BX gets tp 4 reset to zero
						jmp tasktwo

				 mytimerisr:     push ax
                                                        push bx

                                                        ; save the PCB of the task whcih was interrupted by timerisr
                                                        mov ax, 10
                                                        mov bl, [cs:curtask]
                                                        mul bl
                                                        mov bx, ax ; save the offset of interrupted task PCB in bx

                                                        pop ax
                                                        mov [cs:taskstates+bx+2], ax ; save the value of interrupted task bx in PCB
                                                        pop ax
                                                        mov [cs:taskstates+bx+0], ax ; save the value of interrupted task ax in PCB
                                                        pop ax
                                                        mov [cs:taskstates+bx+4], ax ; save the value of interrupted task IP in PCB
                                                        pop ax
                                                        mov [cs:taskstates+bx+6], ax ; save the value of interrupted task CS in PCB
                                                        pop ax
                                                        mov [cs:taskstates+bx+8], ax ; save the value of interrupted task flags in PCB

                                                        ; calculate the value of PCB of task which needs to be passed control next and load that value in bx
                                                        mov ax, 10
                                                        inc byte [cs:curtask]
                                                        cmp byte [cs:curtask], 3
                                                        jne noreset
                                                        mov byte [cs:curtask], 0

                                        noreset:        mov ax, 10
                                                        mov bl, [cs:curtask]
                                                        mul bl
                                                        mov bx, ax ; bx contain the offset of taskstate of the task which will run next

                                                        ; send EOI to PIC
                                                        mov al, 0x20
                                                        out 0x20,al

                                                        ; Initalize the registers of the pask which will run next
                                                        push word [cs:taskstates+bx+8]  ; push the flags register value on stack of task which will run next
                                                        push word  [cs:taskstates+bx+6] ; push the CS register value on stack of task which will run next
                                                        push word  [cs:taskstates+bx+4] ; push the IP register value on stack of task which will run next
                                                        mov ax, [cs:taskstates+bx+0]
                                                        mov bx, [cs:taskstates+bx+2]

                                                        iret




				start:		; Initialize the PCB for taskone
						mov word [taskstates+10+4], taskone ; initialize the IP of taskone
						mov word [taskstates+10+6], cs    ; initialize the CS of taskone
						mov word [taskstates+10+8], 0x0200 ; initilize the flag of taskone
				
						; Initialize the PCB for tasktwo
						mov word [taskstates+20+4], tasktwo ; Initialize the IP of tasktwo
						mov word [taskstates+20+6], cs ; Initialize the CS of tasktwo
						mov word [taskstates+20+8], 0x0200 ; initialize the flag of tasktwo


						
						; hook INT8
						xor ax, ax
						mov es, ax
						cli
						mov word [es:8*4], mytimerisr
						mov [es:8*4+2], cs
						
						; change the ES to video memory base address
						mov ax, 0xb800
						mov es, ax
						
						; Initiliaze BX to zero
						xor bx, bx
						
						; initialize curstask to zero
						mov byte [curtask], 0
						
						sti
					
				infloop:	jmp infloop ; infinite loop
