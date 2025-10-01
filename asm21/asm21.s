section .text
    global _start

_start:
    pop     rdi         ; argc
    cmp     rdi, 2
    jne     invalid

    add     rsp, 8
    mov     rsi, [rsp]  ; argv[1]

    ; Vérifier si le shellcode commence par \x
    mov     al, [rsi]
    cmp     al, '\'
    jne     invalid
    mov     al, [rsi + 1]
    cmp     al, 'x'
    jne     invalid

    ; mmap executable memory
    mov     rax, 9
    xor     rdi, rdi
    mov     rsi, 4096
    mov     rdx, 7
    mov     r10, 34
    mov     r8, -1
    xor     r9, r9
    syscall

    test    rax, rax
    js      invalid

    mov     r12, rax
    mov     rdi, rax
    mov     rsi, [rsp]

    call    parse_shellcode
    test    rax, rax
    jz      invalid

    jmp     r12

invalid:
    mov     rdi, 1
    mov     rax, 60
    syscall

parse_shellcode:
    push    rbx
    xor     rax, rax
    xor     rcx, rcx
    xor     rbx, rbx
.loop:
    mov     al, [rsi + rcx]
    test    al, al
    jz      .done
    cmp     al, '\'
    je      .escape
    mov     [rdi + rbx], al
    inc     rbx
    inc     rcx
    jmp     .loop
.escape:
    inc     rcx
    mov     al, [rsi + rcx]
    cmp     al, 'x'
    jne     invalid
    add     rcx, 3
    mov     al, [rsi + rcx - 2]
    mov     ah, [rsi + rcx - 1]
    call    hex2bin
    mov     [rdi + rbx], al
    inc     rbx
    jmp     .loop
.done:
    mov     rax, 1
    pop     rbx
    ret

hex2bin:
    push    rcx
    mov     cl, ah
    call    hex2val
    mov     cl, 4
    shl     al, cl
    mov     cl, al
    mov     al, ah
    call    hex2val
    or      al, cl
    pop     rcx
    ret

hex2val:
    sub     al, '0'
    cmp     al, 9
    jle     .done
    sub     al, 'A' - '0' - 10
    cmp     al, 15
    jle     .done
    sub     al, 'a' - 'A'
.done:
    ret
