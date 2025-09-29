section .data
    msg db "1337", 10      ; "1337" + newline
    len equ $ - msg        ; longueur du message

section .text
    global _start

_start:
    ; Vérifier qu'il y a exactement 1 argument
    pop rdi                ; rdi = argc
    cmp rdi, 2
    jne exit_bad_input     ; si argc != 2, mauvaise entrée
    
    ; Sauter argv[0]
    pop rdi
    
    ; Récupérer argv[1]
    pop rdi                ; rdi = pointeur vers argv[1]
    
    ; Convertir la chaîne en nombre
    xor rax, rax           ; rax = 0 (résultat)
    xor rcx, rcx           ; rcx = 0 (caractère temporaire)
    
convert_loop:
    mov cl, [rdi]          ; lire un caractère
    cmp cl, 0              ; fin de chaîne?
    je check_even
    cmp cl, 10             ; newline?
    je check_even
    cmp cl, '0'            ; vérifier si c'est un chiffre
    jl exit_bad_input
    cmp cl, '9'
    jg exit_bad_input
    
    sub cl, '0'            ; convertir ASCII en nombre
    imul rax, 10           ; rax = rax * 10
    add rax, rcx           ; rax = rax + chiffre
    inc rdi                ; caractère suivant
    jmp convert_loop

check_even:
    ; Tester si le nombre est pair (bit 0 = 0)
    test rax, 1            ; tester le bit de poids faible
    jnz exit_error         ; si bit = 1, nombre impair -> erreur

print_1337:
    ; Afficher "1337"
    mov rax, 1             ; syscall write
    mov rdi, 1             ; stdout
    mov rsi, msg           ; adresse du message
    mov rdx, len           ; longueur
    syscall
    
    ; Sortir avec succès (code 0)
    mov rax, 60            ; syscall exit
    mov rdi, 0             ; code de sortie 0
    syscall

exit_error:
    ; Sortir avec erreur (code 1)
    mov rax, 60            ; syscall exit
    mov rdi, 1             ; code de sortie 1
    syscall

exit_bad_input:
    ; Sortir avec erreur pour mauvaise entrée (code 2)
    mov rax, 60            ; syscall exit
    mov rdi, 2             ; code de sortie 2
    syscall
