section .data
    err_msg db "Usage: ./asm09 [-b] <nombre>", 10, 0
    err_len equ $ - err_msg
    newline db 10

section .bss
    bin_out resb 64    ; Buffer pour le binaire (64 bits max)
    hex_out resb 16    ; Buffer pour l'hexadécimal
    bin_len resb 1     ; Longueur du résultat binaire
    hex_len resb 1     ; Longueur du résultat hexadécimal

section .text
    global _start

_start:
    pop rdi             ; Nombre d'arguments
    cmp rdi, 2
    jb error            ; Moins de 2 arguments, erreur

    pop rsi             ; Ignorer le nom du programme
    pop rsi             ; Premier argument
    
    mov rbx, 16         ; Par défaut, conversion en hexadécimal

    cmp byte [rsi], '-' ; Vérifier si option "-b"
    jne convert_number

    cmp byte [rsi+1], 'b'
    jne error           ; Mauvais argument, erreur

    cmp byte [rsi+2], 0
    jne error           ; Mauvais argument, erreur

    pop rsi             ; Prendre le deuxième argument
    mov rbx, 2          ; Mode binaire

convert_number:
    xor rax, rax        ; Initialiser le nombre
    mov rdi, rsi        ; Sauvegarder pointeur

convert_to_int:
    movzx rcx, byte [rdi]  ; Lire caractère
    test cl, cl            ; Fin de chaîne ?
    jz convert_to_base

    cmp cl, '0'
    jb error
    cmp cl, '9'
    ja error

    sub cl, '0'
    imul rax, rax, 10      ; Multiplier par 10
    add rax, rcx           ; Ajouter chiffre
    inc rdi
    jmp convert_to_int

convert_to_base:
    cmp rbx, 16
    je convert_to_hex
    jmp convert_to_bin

convert_to_hex:
    mov rdi, hex_out
    mov byte [hex_len], 0

hex_loop:
    mov rdx, 0
    mov rcx, 16
    div rcx

    cmp dl, 10
    jb hex_digit
    add dl, 'A' - 10
    jmp store_hex

hex_digit:
    add dl, '0'

store_hex:
    mov [rdi], dl
    inc rdi
    inc byte [hex_len]

    test rax, rax
    jnz hex_loop

    jmp reverse_and_print_hex

convert_to_bin:
    mov rdi, bin_out
    mov byte [bin_len], 0

bin_loop:
    mov rdx, 0
    mov rcx, 2
    div rcx

    add dl, '0'
    mov [rdi], dl
    inc rdi
    inc byte [bin_len]

    test rax, rax
    jnz bin_loop

    jmp reverse_and_print_bin

reverse_and_print_hex:
    movzx rcx, byte [hex_len]
    mov rsi, hex_out
    lea rdi, [rsi + rcx - 1]

reverse_hex_loop:
    cmp rsi, rdi
    jge print_hex

    mov al, [rsi]
    mov bl, [rdi]
    mov [rsi], bl
    mov [rdi], al
    inc rsi
    dec rdi
    jmp reverse_hex_loop

print_hex:
    mov rax, 1
    mov rdi, 1
    movzx rdx, byte [hex_len]
    mov rsi, hex_out
    syscall
    jmp exit_success

reverse_and_print_bin:
    movzx rcx, byte [bin_len]
    mov rsi, bin_out
    lea rdi, [rsi + rcx - 1]

reverse_bin_loop:
    cmp rsi, rdi
    jge print_bin

    mov al, [rsi]
    mov bl, [rdi]
    mov [rsi], bl
    mov [rdi], al
    inc rsi
    dec rdi
    jmp reverse_bin_loop

print_bin:
    mov rax, 1
    mov rdi, 1
    movzx rdx, byte [bin_len]
    mov rsi, bin_out
    syscall
    jmp exit_success

error:
    mov rax, 1
    mov rdi, 1
    mov rsi, err_msg
    mov rdx, err_len
    syscall
    mov rax, 60
    mov rdi, 1
    syscall

exit_success:
    ; Retourner code 0
    mov rax, 60
    xor rdi, rdi
    syscall
