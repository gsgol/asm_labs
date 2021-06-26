;+--------------------------------------------------------------------------
; �� TSR �ணࠬ�� �뢮��� ���� �।�⢠�� BIOS �� ������ F12
; ���㧪�:
; >���ண /off (���ਬ��: lab2 /off)
;+--------------------------------------------------------------------------
code_seg segment
        ASSUME  CS:CODE_SEG,DS:code_seg,ES:code_seg
	org 100h
start:
    jmp begin
;----------------------------------------------------------------------------
int_2Fh_vector  DD  ?
old_09h         DD  ?

;----------------------------------------------------------------------------
flag        DB  0
high_Y      DB  07	; ���न���� ����
left_X      DB  50	; ���न���� ����
low_Y       DB  15	; ���न���� ����
right_X     DB  69	; ���न���� ����
;
page_num    DB  0
coord_Y     DB  11	; Y ���न��� ᮮ�饭�� � ����
coord_X     DB  55	; X ���न��� ᮮ�饭�� � ����
SIZE		DW	10
BUFFER			DB	'1234567890'	; ᮮ�饭�� �뢮����� � ����
;============================================================================
new_09h proc far
;
    pushf
	push    AX
    in      AL,60h      ; ������ scan-code
    cmp     AL,58h      ; �� ᪥�-��� <F12>
    je      hotkey      ; Yes
    pop     AX          ; No. ����⠭���� AX
	popf
    jmp     dword ptr CS:[old_09h]  ; � ��⥬�� ��ࠡ��稪 ��� ������
hotkey:
    sti                 ; �� �㤥� ����� ⠩����
    in      AL,61h      ; ������ ᮤ�ন��� ���� B
    or      AL,80h      ; ��⠭���� ���訩 ���
    out     61h,AL      ; � ��୥� � ���� B.
    and     AL,7Fh      ; ����� ࠧ�訬 ࠡ��� ����������,
    out     61h,AL      ; ��ᨢ ���訩 ��� ���� B.
;
;-------------------- �뢮� ���� �।�⢠�� BIOS ---------------------------
;
            push    BX	; ��࠭���� �ᯮ��㥬�� ॣ���஢ � �⥪�
            push    CX	; ��࠭���� �ᯮ��㥬�� ॣ���஢ � �⥪�
            push    DX	; ��࠭���� �ᯮ��㥬�� ॣ���஢ � �⥪�
			push	DS	; ��࠭���� �ᯮ��㥬�� ॣ���஢ � �⥪�
			;
			push	CS	;	����ன�� DS
			pop		DS	;				�� ��� ᥣ����, �.� DS=CS
;----------------------------------------------------------------------------
        mov     AX, 0600h      ; ������� ����
        mov     BH, 70h        ; ��ਡ�� ��� �� �஬�
        mov     CH, CS:high_Y     ; ��-
        mov     CL, CS:left_X     ;    ��-
        mov     DH, CS:low_Y      ;       ��-
        mov     DL, CS:right_X    ;          ���� ����
        int 10h
;----------------------------------------------------------------------------
; ------------------------ ����樮���㥬 ����� -----------------------------
        mov     AH,02h          ; �㭪�� ����樮��஢����
        mov     BH,CS:page_num  ; �������࠭��
        mov     DH,CS:coord_Y   ; ��ப�
        mov     DL,CS:coord_X   ; �⮫���
        int 10h
		mov     CX,	CS:SIZE
		mov     BX, offset CS:BUFFER
		mov     AH,0Eh              ; �㭪�� �뢮�� ������ ᨬ����
next_sym:
        mov     AL,CS:[BX]          ; ������ � AL
        inc     BX                  ; ����� �� ��ப�
        int     10h                 ;
        loop    next_sym            ; ���� �� ��ப�
;

			pop		DS	; ����⠭������� ॣ���஢ �� �⥪� � ���浪� LIFO
            pop     DX
            pop     CX
            pop     BX
;---------------------------------------------------------------------------
    cli
    mov     AL, 20h      ; ��諥�
    out     20h,AL       ; �ਪ�� EOI
;
    pop     AX
	popf
    iret
new_09h     endp
;===========================================================================
;============================================================================
int_2Fh proc far
    cmp     AH,0C7h         ; ��� �����?
    jne     Pass_2Fh        ; ���, �� ��室
    cmp     AL,00h          ; ����㭪�� �஢�ન �� ������� ��⠭����?
    je      inst            ; �ணࠬ�� 㦥 ��⠭������
    cmp     AL,01h          ; ����㭪�� ���㧪�?
    je      unins           ; ��, �� ���㧪�
    jmp     short Pass_2Fh  ; �������⭠� ����㭪�� - �� ��室
inst:
    mov     AL,0FFh         ; ����騬 � ������������ ����୮� ��⠭����
    iret
Pass_2Fh:
    jmp dword PTR CS:[int_2Fh_vector]
;
; -------------- �஢�ઠ - �������� �� ���㧪� �ணࠬ�� �� ����� ? ------
unins:
    push    BX
    push    CX
    push    DX
    push    ES
;
    mov     CX,CS   ; �ਣ������ ��� �ࠢ�����, �.�. � CS �ࠢ������ �����
    mov     AX,3509h    ; �஢���� ����� 09h
    int     21h ; �㭪�� 35h � AL - ����� ���뢠���. ������-����� � ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove
;
    cmp     BX, offset CS:new_09h
    jne     Not_remove
;
    mov     AX,352Fh    ; �஢���� ����� 2Fh
    int     21h ; �㭪�� 35h � AL - ����� ���뢠���. ������-����� � ES:BX
;
    mov     DX,ES
    cmp     CX,DX
    jne     Not_remove
;
    cmp     BX, offset CS:int_2Fh
    jne     Not_remove
; ---------------------- ���㧪� �ணࠬ�� �� ����� ---------------------
;
    push    DS
;
    lds     DX, CS:old_09h   ; �� ������� �������⭠ ᫥���騬 ���
;    mov     DX, word ptr old_09h
;    mov     DS, word ptr old_09h+2
    mov     AX,2509h        ; ���������� ����� ���� ᮤ�ন��
    int     21h
;
    lds     DX, CS:int_2Fh_vector   ; �� ������� �������⭠ ᫥���騬 ���
;    mov     DX, word ptr int_2Fh_vector
;    mov     DS, word ptr int_2Fh_vector+2
    mov     AX,252Fh
    int     21h
;
    pop     DS
;
    mov     ES,CS:2Ch       ; ES -> ���㦥���
    mov     AH, 49h         ; �㭪�� �᢮�������� ����� �����
    int     21h
;
    mov     AX, CS
    mov     ES, AX          ; ES -> PSP ���㧨� ᠬ� �ணࠬ��
    mov     AH, 49h         ; �㭪�� �᢮�������� ����� �����
    int     21h
;
    mov     AL,0Fh          ; �ਧ��� �ᯥ譮� ���㧪�
    jmp     short pop_ret
Not_remove:
    mov     AL,0F0h          ; �ਧ��� - ���㦠�� �����
pop_ret:
    pop     ES
    pop     DX
    pop     CX
    pop     BX
;
    iret
int_2Fh endp
;============================================================================
begin:
        mov CL,ES:80h       ; ����� 墮�� � PSP
        cmp CL,0            ; ����� 墮��=0?
        je  check_install   ; ��, �ணࠬ�� ����饭� ��� ��ࠬ��஢,
                            ; ���஡㥬 ��⠭�����
        xor CH,CH       ; CX=CL= ����� 墮��
        cld             ; DF=0 - 䫠� ���ࠢ����� ���।
        mov DI, 81h     ; ES:DI-> ��砫� 墮�� � PSP
        mov SI,offset key   ; DS:SI-> ���� key
        mov AL,' '          ; ���६ �஡��� �� ��砫� 墮��
repe    scasb   ; ������㥬 墮�� ���� �஡���
                ; AL - (ES:DI) -> 䫠�� ������
                ; �������� ���� ������ ࠢ��
        dec DI          ; DI-> �� ���� ᨬ��� ��᫥ �஡����
        mov CX, 4       ; ��������� ����� �������
repe    cmpsb   ; �ࠢ������ �������� 墮�� � ��������
                ; (DS:DI)-(ES:DI) -> 䫠�� ������
        jne check_install ; �������⭠� ������� - ���஡㥬 ��⠭�����
        inc flag_off
; �஢�ਬ, �� ��⠭������ �� 㦥 �� �ணࠬ��
check_install:
        mov AX,0C700h   ; AH=0C7h ����� ����� C7h
                        ; AL=00h -���� ����� ��⠭���� �����
        int 2Fh         ; ���⨯���᭮� ���뢠���
        cmp AL,0FFh
        je  already_ins ; �����頥� AL=0FFh �᫨ ��⠭������
;----------------------------------------------------------------------------
    cmp flag_off,1
    je  xm_stranno
;----------------------------------------------------------------------------
    mov AX,352Fh                      ;   �������
                                      ;   �����
    int 21h                           ;   ���뢠���  2Fh
    mov word ptr int_2Fh_vector,BX    ;   ES:BX - �����
    mov word ptr int_2Fh_vector+2,ES  ;
;
    mov DX,offset int_2Fh           ;   ������� ᬥ饭�� �窨 �室� � ����
                                    ;   ��ࠡ��稪 �� DX
    mov AX,252Fh                    ;   �㭪�� ��⠭���� ���뢠���
                                    ;   �������� ����� 2Fh
    int 21h  ; AL - ����� ����. DS:DX - 㪠��⥫� �ணࠬ�� ��ࠡ�⪨ ���.
;============================================================================
    mov AX,3509h                        ;   �������
                                        ;   �����
    int 21h                             ;   ���뢠���  09h
    mov word ptr old_09h,BX    ;   ES:BX - �����
    mov word ptr old_09h+2,ES  ;
    mov DX,offset new_09h           ;   ������� ᬥ饭�� �窨 �室� � ����
;                                   ;   ��ࠡ��稪 �� DX
    mov AX,2509h                        ;   �㭪�� ��⠭���� ���뢠���
                                        ;   �������� ����� 09h
    int 21h ;   AL - ����� ����. DS:DX - 㪠��⥫� �ணࠬ�� ��ࠡ�⪨ ���.
;
        mov DX,offset msg1  ; ����饭�� �� ��⠭����
        call    print
;----------------------------------------------------------------------------
    mov DX,offset   begin           ;   ��⠢��� �ணࠬ�� ...
    int 27h                         ;   ... १����⭮� � ���
;============================================================================
already_ins:
        cmp flag_off,1      ; ����� �� ���㧪� ��⠭�����?
        je  uninstall       ; ��, �� ���㧪�
        lea DX,msg          ; �뢮� �� �࠭ ᮮ�饭��: already installed!
        call    print
        int 20h
; ------------------ ���㧪� -----------------------------------------------
 uninstall:
        mov AX,0C701h  ; AH=0C7h ����� ����� C7h, ����㭪�� 01h-���㧪�
        int 2Fh             ; ���⨯���᭮� ���뢠���
        cmp AL,0F0h
        je  not_sucsess
        cmp AL,0Fh
        jne not_sucsess
        mov DX,offset msg2  ; ����饭�� � ���㧪�
        call    print
        int 20h
not_sucsess:
        mov DX,offset msg3  ; ����饭��, �� ���㧪� ����������
        call    print
        int 20h
xm_stranno:
        mov DX,offset msg4  ; ����饭��, �ணࠬ�� ���, � ���짮��⥫�
        call    print       ; ���� ������� ���㧪�
        int 20h
;----------------------------------------------------------------------------
key         DB  '/off'
flag_off    DB  0
msg         DB  'already '
msg1        DB  'installed',13,10,'$'
msg4        DB  'just '
msg3        DB  'not '
msg2        DB  'uninstalled',13,10,'$'
;============================================================================
PRINT       PROC NEAR
    MOV AH,09H
    INT 21H
    RET
PRINT       ENDP
;;============================================================================
code_seg ends
         end start
