.MODEL Tiny
.CODE

.STARTUP
.386

org 100h

jmp main
    ;nachalnoe soobshenie
puts macro message
	local __puts_string__, __puts_nxt__
	push ax
	push dx
	mov dx, offset __puts_string__
	mov ah, 09h
	int 21h
	pop dx
	pop ax
	jmp __puts_nxt__
	__puts_string__ db 'Lab2 ', message, '$'
	__puts_nxt__:
endm
   ;perehod stroki
next_line macro
	push ax
	push dx
	mov ah, 02h
	mov dl, 13
	int 21h
	mov dl, 10
	int 21h
	pop dx
	pop ax
endm

	resident_secret_key dw 09988h


	reboot_resident proc
		pusha
		pushf 
		push bx
		push ds
		push es



		in al, 60h           ;vigruzka sostoyaniya klaviaturi
		mov dl, al
		cmp dl, 56                                   ;proverka nazhant li alt
		jne return_to_old

		

		mov bx, word ptr es:[interrupt_vector]      ;  vernut stariy vector 
		mov dx, bx
		mov bx, word ptr es:[interrupt_vector + 2]   ; peredat upravlenie staromu vectoru
		mov ds, bx


    mov ah, 02h
    mov dl, 'R'
    int 21h
    mov dl, 'e'
    int 21h
    mov dl, 't'
    int 21h
    mov dl, 'u'
    int 21h
    mov dl, 'r'
    int 21h
    mov dl, 'n'
    int 21h
next_line; vivodim soobshenie o vigruzki

		 
		
		mov ah, 25h   ; peredaem prerivanie 09h
		mov al, 09h
		int 21h



		
		int 21h  
		pop es
		pop ds 
		pop bx   
		mov ah, 49h     ; ochistka segmenta pamyati
		popf
		popa
          

		mov ax, 4c00h ;vixod
		int 21h 
     

	reboot_resident endp

return_to_old:
	pop es
	pop ds 
	pop bx 
	popf
	popa
	sti
	db 0eah

interrupt_vector dd ?

	main:
		mov ah, 35h
		mov al, 09h
		int 21h

		mov dl, byte ptr ds:[80h]
		cmp dl, 0
		je compare_with_secret_key
		
		cmp byte ptr ds:[82h], 'u'
		je uninstall_resident


		compare_with_secret_key:
			cmp word ptr es:[resident_secret_key], 09988h  ;proverka esli resident uzhe zagruzhen
			je resident_already_exist

		push es
		mov ax, ds:[2ch]
		mov es, ax                                                  ;proverka dostatochno li pamyati
		mov ah, 49h
		int 21h
		pop es
		jc memory_error

		mov word ptr interrupt_vector, bx               ;zagruzhaem vector prerivaniya
		mov word ptr interrupt_vector + 2, es

		mov ah, 25h
		mov al, 09h                               ;ustanovka 09h klaviaturnogo prerivaniya
		lea dx, reboot_resident
		int 21h

		puts 'Program installed successfully'  ;vse ok
		lea dx, main
		int 27h

	resident_already_exist:                     ;programma uzhe sushestvuet    
		puts 'Program already exist'
		next_line
		jmp exit

	memory_error:
		puts 'There is something wrong with your memory'       ;problemi s pamyatyu
		next_line
		jmp exit

	resident_does_not_exist:                           ;programma otsutsvuet v pamyati
		puts 'Program does not exist'               
		next_line
		jmp exit    
		
		
		
		uninstall_resident:
		cmp word ptr es:[resident_secret_key], 09988h
		jne resident_does_not_exist
		push bx
		push ds
		push es

		mov bx, word ptr es:[interrupt_vector]
		mov dx, bx
		mov bx, word ptr es:[interrupt_vector + 2]
		mov ds, bx

		mov ah, 25h
		mov al, 09h
		int 21h

		pop es
		pop ds
		pop bx
		mov ah, 49h
		int 21h
		jc memory_error

		puts 'Program uninstaled'
		next_line
		mov ax, 4c00h
		int 21h
                  
    exit:
		puts 'Cancelling program'                                 ;vixod
		next_line
		mov ax, 4c00h
		int 21h


END
