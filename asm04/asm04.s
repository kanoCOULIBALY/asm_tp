section .data
    msg db "1337", 10
    len equ $ - msg

section .text
    global _start

_start:
    ; Lire argc
    pop rbx                ; rbx = argc
    cmp rbx, 2
    jne exit_bad_input

    ; Sauter argv[0]
    pop rdi

    ; Récupérer argv[1]
    pop rdi                ; rdi = pointeur vers argv[1]

    ; Convertir la chaîne en nombre
    xor rax, rax
    xor rcx, rcx

convert_loop:
    mov cl, [rdi]
    cmp cl, 0
    je check_even
    cmp cl, 10
    je check_even
    cmp cl, '0'
    jl exit_bad_input
    cmp cl, '9'
    jg exit_bad_input

    sub cl, '0'
    imul rax, 10
    add rax, rcx
    inc rdi
    jmp convert_loop

check_even:
    test rax, 1
    jnz exit_error

print_1337:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, len
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

exit_bad_input:
    mov rax, 60
    mov rdi, 2
    syscall
