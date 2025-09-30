section .data
    ; Structure sockaddr_in correctement alignée
    server_addr:
        dw 2                    ; sin_family = AF_INET
        dw 0x3905              ; Port 1337 en network byte order (htons(1337))
        dd 0x0100007f          ; IP 127.0.0.1 en network byte order
        dq 0                    ; Padding pour atteindre 16 bytes

    ; Messages et erreurs
    msg_request    db "Hello, client!", 0
    msg_len        equ $ - msg_request
    msg_response   db 256 dup(0)      ; Buffer pour la réponse
    
    ; Messages d'erreur avec leurs longueurs
    sockfd_error   db "Error: socket creation failed", 10
    sockfd_len     equ $ - sockfd_error
    connect_error  db "Error: connection failed", 10
    connect_len    equ $ - connect_error
    timeout_msg    db "Timeout: no response from server", 10
    timeout_len    equ $ - timeout_msg

    ; Structure timeval pour le timeout
    timeval:
        dq 1                    ; tv_sec = 1
        dq 0                    ; tv_usec = 0

section .bss
    sockfd         resq 1              ; Descripteur de socket
    addr_len       resq 1              ; Longueur de sockaddr

section .text
    global _start

_start:
    ; Création du socket UDP
    mov rax, 41                  ; sys_socket
    mov rdi, 2                   ; AF_INET
    mov rsi, 2                   ; SOCK_DGRAM
    xor rdx, rdx                 ; IPPROTO_UDP
    syscall
    
    test rax, rax
    js error_socket             ; Jump si erreur (SF=1)
    mov [sockfd], rax          ; Sauvegarder le file descriptor
    
    ; Configurer le timeout sur le socket
    mov rax, 54                 ; sys_setsockopt
    mov rdi, [sockfd]          ; socket fd
    mov rsi, 1                 ; SOL_SOCKET
    mov rdx, 20                ; SO_RCVTIMEO
    lea r10, [timeval]         ; &timeval
    mov r8, 16                 ; sizeof(timeval)
    syscall
    
    test rax, rax
    js error_socket
    
    ; Envoyer le message
    mov rax, 44                ; sys_sendto
    mov rdi, [sockfd]          ; socket fd
    lea rsi, [msg_request]     ; buffer
    mov rdx, msg_len           ; length
    xor r10, r10              ; flags = 0
    lea r8, [server_addr]      ; dest_addr
    mov r9, 16                 ; addrlen
    syscall
    
    test rax, rax
    js error_connect
    
    ; Recevoir la réponse
    mov rax, 45                ; sys_recvfrom
    mov rdi, [sockfd]          ; socket fd
    lea rsi, [msg_response]    ; buffer
    mov rdx, 256               ; length
    xor r10, r10              ; flags = 0
    lea r8, [server_addr]      ; src_addr
    lea r9, [addr_len]         ; addrlen
    syscall
    
    test rax, rax
    jle error_timeout          ; Si ≤ 0, timeout ou erreur
    
    ; Afficher la réponse reçue
    mov rdx, rax               ; Longueur reçue
    mov rax, 1                 ; sys_write
    mov rdi, 1                 ; stdout
    lea rsi, [msg_response]    ; buffer
    syscall
    
    ; Fermer le socket et sortir avec succès
    mov rax, 3                 ; sys_close
    mov rdi, [sockfd]
    syscall
    
    mov rax, 60                ; sys_exit
    xor rdi, rdi              ; return 0
    syscall

error_socket:
    mov rdx, sockfd_len        ; length
    lea rsi, [sockfd_error]    ; message
    jmp print_error

error_connect:
    mov rdx, connect_len       ; length
    lea rsi, [connect_error]   ; message
    jmp print_error

error_timeout:
    mov rdx, timeout_len       ; length
    lea rsi, [timeout_msg]     ; message
    jmp print_error

print_error:
    mov rax, 1                 ; sys_write
    mov rdi, 2                 ; stderr
    syscall
    
    mov rax, 60                ; sys_exit
    mov rdi, 1                 ; return 1
    syscall
