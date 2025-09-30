section .bss
    buffer resb 128   ; Buffer pour stocker l'entrée

section .data
    vowels db "aeiouyAEIOUY", 0  ; Ajout de 'y' et 'Y' comme voyelles
    newline db 10

section .text
    global _start

_start:
    ; Lire l'entrée depuis stdin
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buffer     ; Stocker dans buffer
    mov rdx, 128        ; Nombre max de caractères
    syscall

    ; RAX contient le nombre de caractères lus
    cmp rax, 1
    jle print_zero     ; Si entrée vide ou juste un retour à la ligne, afficher 0

    ; Initialiser le compteur de voyelles
    xor rcx, rcx        ; Compteur = 0
    mov rsi, buffer     ; Pointeur sur la chaîne

count_vowels:
    movzx rax, byte [rsi]
    test al, al
    jz print_result     ; Vérifie fin de chaîne

    push rsi            ; Sauvegarde RSI
    mov rdi, vowels     ; Liste des voyelles

check_vowel:
    movzx rdx, byte [rdi]
    test dl, dl
    jz no_match

    cmp al, dl
    je is_vowel

    inc rdi
    jmp check_vowel

is_vowel:
    inc rcx             ; Incrémenter le compteur

no_match:
    pop rsi             ; Restaurer RSI
    inc rsi             ; Passer au caractère suivant
    jmp count_vowels

print_zero:
    mov rcx, 0          ; Si entrée vide, compteur = 0

print_result:
    mov rax, rcx        ; Mettre le nombre de voyelles dans RAX
    mov rsi, buffer     ; Réutiliser le buffer
    call itoa           ; Convertir en chaîne

    mov rdx, rsi
    sub rdx, buffer     ; Calculer la longueur

    ; Afficher le nombre de voyelles
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    syscall

    ; Ajouter un retour à la ligne
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    jmp exit_success

exit_success:
    mov rax, 60
    xor rdi, rdi
    syscall

; ------------------------
; Convertir un entier en chaîne
; Entrée : RAX = entier à convertir, RSI = buffer de sortie
; Sortie : Buffer rempli avec la chaîne
; ------------------------
itoa:
    mov rbx, 0          ; Longueur
    test rax, rax
    jns itoa_loop

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
