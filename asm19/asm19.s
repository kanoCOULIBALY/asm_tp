section .data
    ; Structure sockaddr_in pour le serveur..
    server_addr:
        dw 2                    ; sin_family = AF_INET
        dw 0x3905              ; Port 1337 en network byte order (htons(1337))
        dd 0                    ; INADDR_ANY (0.0.0.0)
        dq 0                    ; Padding

    ; Messages et constantes
    listening_msg db "⏳ Listening on port 1337", 10
    listening_len equ $ - listening_msg
    
    filename db "messages", 0   ; Nom du fichier de log
    newline db 10              ; Caractère nouvelle ligne

    ; Messages d'erreur
    bind_error    db "Error: Failed to bind to port", 10
    bind_err_len  equ $ - bind_error
    socket_error  db "Error: Failed to create socket", 10
    socket_err_len equ $ - socket_error
    file_error    db "Error: Failed to open log file", 10
    file_err_len  equ $ - file_error

section .bss
    sockfd        resq 1        ; Descripteur de socket
    filefd        resq 1        ; Descripteur de fichier
    buffer        resb 2048     ; Buffer pour les messages reçus
    client_addr   resb 16       ; Structure pour l'adresse client
    client_len    resq 1        ; Longueur de l'adresse client

section .text
    global _start

_start:
    ; Créer le socket UDP
    mov rax, 41                 ; sys_socket
    mov rdi, 2                  ; AF_INET
    mov rsi, 2                  ; SOCK_DGRAM
    xor rdx, rdx               ; IPPROTO_UDP
    syscall
    
    test rax, rax
    js socket_err              ; Si erreur
    mov [sockfd], rax          ; Sauvegarder le descripteur
    
    ; Bind sur le port 1337
    mov rax, 49                ; sys_bind
    mov rdi, [sockfd]          ; socket fd
    lea rsi, [server_addr]     ; struct sockaddr
    mov rdx, 16                ; taille de sockaddr
    syscall
    
    test rax, rax
    js bind_err
    
    ; Ouvrir/créer le fichier messages
    mov rax, 2                 ; sys_open
    lea rdi, [filename]        ; nom du fichier
    mov rsi, 66h              ; O_CREAT | O_RDWR | O_APPEND
    mov rdx, 0644o            ; permissions rw-r--r--
    syscall
    
    test rax, rax
    js file_err
    mov [filefd], rax         ; Sauvegarder le descripteur de fichier
    
    ; Afficher message d'écoute
    mov rax, 1                ; sys_write
    mov rdi, 1                ; stdout
    lea rsi, [listening_msg]  ; message
    mov rdx, listening_len    ; longueur
    syscall

listen_loop:
    ; Recevoir données UDP
    mov rax, 45                ; sys_recvfrom
    mov rdi, [sockfd]          ; socket fd
    lea rsi, [buffer]          ; buffer
    mov rdx, 2048              ; taille max
    xor r10, r10              ; flags = 0
    lea r8, [client_addr]      ; addr client
    lea r9, [client_len]       ; longueur addr
    syscall
    
    test rax, rax
    js listen_loop            ; Si erreur, continuer
    mov r12, rax              ; Sauvegarder longueur reçue
    
    ; Écrire le message dans le fichier
    mov rax, 1                ; sys_write
    mov rdi, [filefd]         ; descripteur fichier
    lea rsi, [buffer]         ; message
    mov rdx, r12              ; longueur
    syscall
    
    ; Ajouter nouvelle ligne
    mov rax, 1
    mov rdi, [filefd]
    lea rsi, [newline]
    mov rdx, 1
    syscall
    
    jmp listen_loop           ; Continuer à écouter

socket_err:
    mov rdi, 2                ; stderr
    lea rsi, [socket_error]
    mov rdx, socket_err_len
    jmp print_error

bind_err:
    mov rdi, 2                ; stderr
    lea rsi, [bind_error]
    mov rdx, bind_err_len
    jmp print_error

file_err:
    mov rdi, 2                ; stderr
    lea rsi, [file_error]
    mov rdx, file_err_len

print_error:
    mov rax, 1                ; sys_write
    syscall
    
    mov rax, 60               ; sys_exit
    mov rdi, 1                ; code erreur 1
    syscall
