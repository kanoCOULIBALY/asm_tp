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
    mov     rax, 9          ; sys_mmap
    xor     rdi, rdi        ; addr = NULL
    mov     rsi, 4096       ; length
    mov     rdx, 7          ; prot = PROT_READ | PROT_WRITE | PROT_EXEC
    mov     r10, 34         ; flags = MAP_PRIVATE | MAP_ANONYMOUS
    mov     r8, -1          ; fd = -1
    xor     r9, r9          ; offset = 0
    syscall
    
    test    rax, rax
    js      invalid
    
    mov     r12, rax        ; Sauvegarder l'adresse mmap
    mov     rdi, rax        ; Destination
    mov     rsi, [rsp]      ; Source (argv[1])
    call    parse_shellcode
    
    test    rax, rax
    jz      invalid
    
    ; Exécuter le shellcode
    jmp     r12

invalid:
    mov     rax, 60         ; sys_exit
    mov     rdi, 1          ; status = 1
    syscall

parse_shellcode:
    push    rbx
    push    r13
    xor     rbx, rbx        ; Index destination
    xor     rcx, rcx        ; Index source
    
.loop:
    mov     al, [rsi + rcx]
    test    al, al
    jz      .done
    
    cmp     al, '\'
    je      .escape
    
    ; Caractère normal
    mov     [rdi + rbx], al
    inc     rbx
    inc     rcx
    jmp     .loop
    
.escape:
    inc     rcx
    mov     al, [rsi + rcx]
    cmp     al, 'x'
    jne     .invalid
    
    inc     rcx
    ; Lire premier digit hex
    mov     al, [rsi + rcx]
    test    al, al
    jz      .invalid
    call    hex2val
    shl     al, 4
    mov     r13b, al        ; Sauvegarder les 4 bits hauts
    
    inc     rcx
    ; Lire second digit hex
    mov     al, [rsi + rcx]
    test    al, al
    jz      .invalid
    call    hex2val
    or      al, r13b        ; Combiner avec les 4 bits hauts
    
    ; Écrire le byte
    mov     [rdi + rbx], al
    inc     rbx
    inc     rcx
    jmp     .loop
    
.invalid:
    xor     rax, rax
    pop     r13
    pop     rbx
    ret
    
.done:
    mov     rax, 1          ; Succès
    pop     r13
    pop     rbx
    ret

hex2val:
    ; Convertir caractère hex (dans al) en valeur 0-15
    cmp     al, '0'
    jb      .invalid
    cmp     al, '9'
    jbe     .digit
    
    cmp     al, 'A'
    jb      .invalid
    cmp     al, 'F'
    jbe     .upper
    
    cmp     al, 'a'
    jb      .invalid
    cmp     al, 'f'
    jbe     .lower
    
.invalid:
    xor     al, al
    ret
    
.digit:
    sub     al, '0'
    ret
    
.upper:
    sub     al, 'A' - 10
    ret
    
.lower:
    sub     al, 'a' - 10
    ret
