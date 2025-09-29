section .data
    msg db "1337", 10      ; "1337" + newline
    len equ $ - msg        ; longueur du message

section .text
    global _start

_start:
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
