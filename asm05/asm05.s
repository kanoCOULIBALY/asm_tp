section .data
    userMessage db 'Result: '
    userMessageLen equ $ - userMessage
    newline db 0xA
    newlineLen equ 1

section .text
    global _start

_start:
    ; Sauvegarder le pointeur de pile original
    mov rbp, rsp
    
    ; Récupérer argc et argv
    pop rbx                 ; argc
    cmp rbx, 1             ; Vérifier si nous avons au moins 1 argument
    jle exit_failure       ; Si non, sortir avec erreur
    
    pop rbx                ; Ignorer le nom du programme (argv[0])
    pop rsi                ; Premier argument (argv[1]) - la chaîne à afficher

    ; Sauvegarder la chaîne à afficher
    push rsi

    ; Afficher "Result: "
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, userMessage
    mov rdx, userMessageLen
    syscall

    ; Récupérer la chaîne sauvegardée
    pop rsi

    ; Calculer la longueur de la chaîne d'entrée
    push rsi               ; Sauvegarder rsi
    mov rdi, rsi
    call strlen
    mov rdx, rax          ; Longueur dans rdx pour syscall
    pop rsi               ; Restaurer rsi

    ; Afficher la chaîne
    mov rax, 1            ; sys_write
    mov rdi, 1            ; stdout
    syscall

    ; Afficher le retour à la ligne
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, newlineLen
    syscall

exit_success:
    mov rax, 60            ; sys_exit
    xor rdi, rdi           ; status = 0
    syscall

exit_failure:
    mov rax, 60            ; sys_exit
    mov rdi, 1            ; status = 1
    syscall

; Fonction pour calculer la longueur d'une chaîne
; Input: RDI = pointeur vers la chaîne
; Output: RAX = longueur de la chaîne
strlen:
    xor rax, rax
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret
