section .text
    global _start

_start:
    ; Vérifier argc == 2
    pop     rdi         
    cmp     rdi, 2
    jne     exit_error
    
    add     rsp, 8      ; Skip argv[0]
    pop     rsi         ; rsi = argv[1] (le shellcode string)
    
    ; mmap pour créer une zone mémoire exécutable
    mov     rax, 9              ; sys_mmap
    xor     rdi, rdi            ; addr = NULL
    mov     rsi, 4096           ; length = 4096
    mov     rdx, 7              ; prot = PROT_READ | PROT_WRITE | PROT_EXEC
    mov     r10, 34             ; flags = MAP_PRIVATE | MAP_ANONYMOUS (0x22)
    mov     r8, -1              ; fd = -1
    xor     r9, r9              ; offset = 0
    syscall
    
    ; Vérifier si mmap a réussi
    cmp     rax, 0
    jl      exit_error
    
    ; Sauvegarder l'adresse mmap
    mov     r12, rax            ; r12 = adresse de la zone exécutable
    
    ; Parser le shellcode de argv[1] vers la zone mmap
    mov     rdi, r12            ; destination
    mov     rsi, [rsp - 8]      ; source = argv[1]
    call    parse_shellcode
    
    ; Vérifier si le parsing a réussi
    test    rax, rax
    jz      exit_error
    
    ; Exécuter le shellcode
    call    r12

exit_error:
    mov     rax, 60             ; sys_exit
    mov     rdi, 1              ; status = 1
    syscall

parse_shellcode:
    push    rbx
    push    r13
    push    r14
    
    xor     rbx, rbx            ; index destination
    xor     rcx, rcx            ; index source
    
.loop:
    movzx   eax, byte [rsi + rcx]
    test    al, al              ; fin de chaîne ?
    jz      .done
    
    cmp     al, '\'             ; début d'escape ?
    je      .parse_hex
    
    ; Caractère normal (ne devrait pas arriver avec un vrai shellcode)
    mov     [rdi + rbx], al
    inc     rbx
    inc     rcx
    jmp     .loop
    
.parse_hex:
    inc     rcx
    movzx   eax, byte [rsi + rcx]
    cmp     al, 'x'             ; vérifier \x
    jne     .error
    
    ; Lire les 2 caractères hexa
    inc     rcx
    movzx   eax, byte [rsi + rcx]
    test    al, al
    jz      .error
    
    call    hex_char_to_value
    cmp     al, 0xFF            ; erreur de conversion ?
    je      .error
    
    shl     al, 4               ; décaler de 4 bits
    mov     r13b, al            ; sauvegarder
    
    inc     rcx
    movzx   eax, byte [rsi + rcx]
    test    al, al
    jz      .error
    
    call    hex_char_to_value
    cmp     al, 0xFF
    je      .error
    
    or      al, r13b            ; combiner les 2 nibbles
    mov     [rdi + rbx], al     ; écrire le byte
    inc     rbx
    inc     rcx
    jmp     .loop
    
.error:
    xor     rax, rax            ; retourner 0 (échec)
    pop     r14
    pop     r13
    pop     rbx
    ret
    
.done:
    mov     rax, 1              ; retourner 1 (succès)
    pop     r14
    pop     r13
    pop     rbx
    ret

hex_char_to_value:
    ; Convertir un caractère hexa en valeur 0-15
    ; Entrée: al = caractère
    ; Sortie: al = valeur (ou 0xFF si erreur)
    
    cmp     al, '0'
    jb      .error
    cmp     al, '9'
    jbe     .is_digit
    
    cmp     al, 'A'
    jb      .error
    cmp     al, 'F'
    jbe     .is_upper
    
    cmp     al, 'a'
    jb      .error
    cmp     al, 'f'
    jbe     .is_lower
    
.error:
    mov     al, 0xFF
    ret
    
.is_digit:
    sub     al, '0'
    ret
    
.is_upper:
    sub     al, 'A'
    add     al, 10
    ret
    
.is_lower:
    sub     al, 'a'
    add     al, 10
    ret
