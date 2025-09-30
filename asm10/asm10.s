section .data
    err_msg db "Usage: ./asm10 <num1> <num2> <num3>", 10, 0
    err_len equ $ - err_msg
    newline db 10

section .bss
    buffer resb 16   ; Buffer pour stocker le nombre affiché

section .text
    global _start

_start:
    pop rdi             ; Nombre d'arguments
    cmp rdi, 4          ; Programme + 3 nombres attendus
    jne error

    pop rsi             ; Ignorer le nom du programme

    pop rsi             ; Lire le premier nombre
    call atoi
    mov r8, rax         ; num1 = rax

    pop rsi             ; Lire le deuxième nombre
    call atoi
    mov r9, rax         ; num2 = rax

    pop rsi             ; Lire le troisième nombre
    call atoi
    mov r10, rax        ; num3 = rax

    ; Trouver le maximum
    mov rax, r8         ; max = num1
    cmp r9, rax
    cmovg rax, r9       ; max = num2 si num2 > max

    cmp r10, rax
    cmovg rax, r10      ; max = num3 si num3 > max

print_max:
    mov rsi, buffer
    call itoa           ; Convertir en chaîne

    mov rdx, rsi        ; Correction : calcul de la longueur
    sub rdx, buffer

    ; Affichage du résultat
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, buffer
    syscall

    ; Ajouter un retour à la ligne
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    jmp exit_success

error:
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, err_msg
    mov rdx, err_len
    syscall
    mov rax, 60
    mov rdi, 1
    syscall

exit_success:
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; Code de retour 0
    syscall

; ------------------------
; Convertir une chaîne en nombre entier (supporte négatif)
; Entrée : RSI = adresse de la chaîne
; Sortie : RAX = entier converti
; ------------------------
atoi:
    xor rax, rax        ; Init résultat
    xor rcx, rcx        ; Init compteur
    mov rbx, 1          ; Signe (1 = positif, -1 = négatif)

    movzx rdx, byte [rsi]
    cmp dl, '-'
    jne atoi_loop
    mov rbx, -1         ; Mettre le signe négatif
    inc rsi             ; Passer au chiffre suivant

atoi_loop:
    movzx rdx, byte [rsi]
    test dl, dl
    jz atoi_done

    cmp dl, '0'
    jb error
    cmp dl, '9'
    ja error

    sub dl, '0'
    imul rax, rax, 10
    add rax, rdx

    inc rsi
    jmp atoi_loop

atoi_done:
    imul rax, rbx       ; Appliquer le signe
    ret

; ------------------------
; Convertir un entier en chaîne (supporte négatif)
; Entrée : RAX = entier à convertir, RSI = buffer de sortie
; Sortie : Buffer rempli avec la chaîne
; ------------------------
itoa:
    mov rbx, 0          ; Longueur
    test rax, rax
    jns itoa_loop

    ; Nombre négatif -> stocker '-' et prendre valeur absolue
    mov byte [rsi], '-'
    inc rsi
    neg rax

itoa_loop:
    mov rdx, 0
    mov rcx, 10
    div rcx             ; RAX = quotient, RDX = reste

    add dl, '0'
    push rdx
    inc rbx

    test rax, rax
    jnz itoa_loop

itoa_pop:
    pop rax
    mov [rsi], al
    inc rsi
    dec rbx
    jnz itoa_pop

    ret
