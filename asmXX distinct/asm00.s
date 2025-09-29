section .text
    global _start

_start:
    ; Appel système exit
    mov rax, 60        ; numéro syscall pour exit (64 bits)
    mov rdi, 0         ; code de sortie 0
    syscall            ; appel sys
