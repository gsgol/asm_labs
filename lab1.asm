.MODEL Tiny
.CODE
.STARTUP
.386

org 100h

puts macro message
	local msg, nxt
	push AX
	push DX
	mov DX, offset msg
	mov AH, 09h
	int 21h
	pop DX
	pop AX
	jmp nxt
	msg db message, '$'
	nxt:
endm

next_line macro
	push AX
	push DX
	mov AH, 02h
	mov DL, 13
	int 21h
	mov DL, 10
	int 21h
	pop DX
	pop AX
endm

start:

	next_line
	mov cl, es:[80h]
	cmp cl, 0
		jne file_name_exist

	puts 'Enter the input file name'
	mov ah, 0ah
	mov dx, offset input_file_name
	int 21h
	next_line

	xor bh, bh
	mov bl, input_file_name[1]
	mov input_file_name[bx + 2], 0

	mov ax, 3d00h
	mov dx, offset input_file_name+2
	int 21h
	jnc open_input_file_success
	jmp open_error

	file_name_exist:
		xor bh, bh
		mov bl, es:[80h]
		mov byte ptr [bx + 81h], 0
		mov cl, es:80h
		xor ch, ch
		cld
		mov di, 81h
		mov al, ' '
		repe scasb
		dec di
		mov ax, 3d00h
		mov dx, di
		int 21h
		jnc open_input_file_success
		jmp open_error

	open_input_file_success:
		puts 'Input file sucessfully opened'
		next_line
		mov input_descriptor, ax

		puts 'Enter the disc name or 0 if disc name is given'
		next_line
		mov ah, 01h
		int 21h
		mov disc, al
		next_line

		push ax

		puts 'Enter the output file name'
		mov ah, 0ah
		mov dx, offset output_file_name
		int 21h
		next_line

		pop ax

		cmp disc, 0
		je our_disc

		with_disc:
			xor si, si

			mov output_file_name_disc[0], al
			xor bx, bx
			mov bl, output_file_name[1]
			mov output_file_name_disc[bx+5], 0

			mov cx, bx

			@copy:
				mov al, output_file_name[si+2]
				mov output_file_name_disc[si+3], al
				inc si
				loop @copy

			mov ah, 3ch
			mov dx, offset output_file_name_disc
			mov cx, 0
			int 21h
			jc create_error
			jmp new_file_create_success

		our_disc:
			xor bh, bh
			mov bl, output_file_name[1]
			mov output_file_name[bx+2], 0

			mov ah, 3ch
			mov dx, offset output_file_name+2
			mov cx, 0
			int 21h
			jc create_error
			jmp new_file_create_success

		new_file_create_success:
			mov output_descriptor, ax
			puts 'New file opened'
			next_line

		xor di, di

		mov ah, 3fh
		mov bx, input_descriptor
		mov cx, 19999
		mov dx, offset input_array
		int 21h
		jc read_error

		xor bp, bp

		cmp ax, 0
		je write_output

		@for_symbol_in_file:
			cmp input_array[bp], 0
			je write_output

			mov dl, input_array[bp]
			
			cmp dl, 13
			je add_lf

			cmp dl, 32
			je change_space_to_tab

			jmp common

			add_lf:
				mov output_array[di], dl
				inc di
				mov output_array[di], 10
				jmp next_iteration

			change_space_to_tab:
				mov output_array[di], 9
				jmp next_iteration

			common:
				mov output_array[di], dl

			next_iteration:
				inc bp
				inc di
				jmp @for_symbol_in_file

		write_output:
			mov ah, 40h
			mov bx, output_descriptor
			mov cx, di
			mov dx, offset output_array
			int 21h

		mov ah, 3eh

		mov bx, input_descriptor
		int 21h

		mov bx, output_descriptor
		int 21h

		mov output_array[di], '$'
		mov ah, 09h
		int 21h

		puts 'Program successfully worked'
		next_line

		jmp exit

	open_error:
		puts 'File opening error'
		next_line
		jmp exit

	create_error:
		puts 'Creating output file error'
		next_line
		jmp exit

	read_error:
		puts 'File reading error'
		next_line
		jmp exit

	exit:
		puts 'Program is cancelled '
		next_line
		int 20h

input_file_name db 14, 0, 14 dup (0)
output_file_name db 14, 0, 14 dup (0)
output_file_name_disc db 0, ':/', 14 dup (0)

input_array db 20000 dup (0)
output_array db 40000 dup (0)

input_descriptor dw ?
output_descriptor dw ?

disc db 0

END