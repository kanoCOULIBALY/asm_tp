section .data
    server_addr:
        dw 2                    ; AF_INET
        dw 0x9210              ; Port 4242 (big endian)
        dd 0                    ; INADDR_ANY
        dd 0, 0                 ; Padding

    msg_listen db "Listening on port 4242", 10
    msg_listen_len equ $ - msg_listen
    
    msg_ping db "PONG", 13, 10
    msg_ping_len equ $ - msg_ping
    
    msg_goodbye db "Goodbye!", 13, 10
    msg_goodbye_len equ $ - msg_goodbye
    
    msg_unknown db "Unknown command", 13, 10
    msg_unknown_len equ $ - msg_unknown

    msg_prompt db "Type a command: "
    msg_prompt_len equ $ - msg_prompt

section .bss
    sockfd resq 1
    clientfd resq 1
    buffer resb 1024
    client_addr resb 16
    client_len resd 1

section .text
    global _start

_start:
    ; Socket
    mov rax, 41
    mov rdi, 2                 ; AF_INET
    mov rsi, 1                 ; SOCK_STREAM
    xor rdx, rdx
    syscall
    mov [sockfd], rax

    ; Enable SO_REUSEADDR
    mov rax, 54                ; setsockopt
    mov rdi, [sockfd]
    mov rsi, 1                 ; SOL_SOCKET
    mov rdx, 2                 ; SO_REUSEADDR
    push 1
    mov r10, rsp
    mov r8, 4
    syscall
    add rsp, 8

    ; Bind
    mov rax, 49
    mov rdi, [sockfd]
    mov rsi, server_addr
    mov rdx, 16
    syscall

    ; Listen
    mov rax, 50
    mov rdi, [sockfd]
    mov rsi, 5
    syscall

    ; Print listening message
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_listen
    mov rdx, msg_listen_len
    syscall

accept_loop:
    mov dword [client_len], 16
    mov rax, 43
    mov rdi, [sockfd]
    mov rsi, client_addr
    mov rdx, client_len
    syscall
    mov [clientfd], rax

    mov rax, 57                ; fork
    syscall
    test rax, rax
    jz handle_client
    
    ; Parent: close client socket and continue
    mov rax, 3
    mov rdi, [clientfd]
    syscall
    jmp accept_loop

handle_client:
    ; Close parent socket in child
    mov rax, 3
    mov rdi, [sockfd]
    syscall

send_prompt:
    mov rax, 1
    mov rdi, [clientfd]
    mov rsi, msg_prompt
    mov rdx, msg_prompt_len
    syscall

read_loop:
    mov rax, 0
    mov rdi, [clientfd]
    mov rsi, buffer
    mov rdx, 1024
    syscall
    test rax, rax
    jle client_close

    ; Strip newline
    mov rcx, rax
    dec rcx
    mov byte [buffer + rcx], 0
    
process_command:
    ; Check PING
    cmp dword [buffer], 0x474E4950  ; "PING"
    jne check_echo
    
    mov rax, 1
    mov rdi, [clientfd]
    mov rsi, msg_ping
    mov rdx, msg_ping_len
    syscall
    jmp send_prompt

check_echo:
    ; Check ECHO
    cmp dword [buffer], 0x4F484345  ; "ECHO"
    jne check_reverse
    cmp byte [buffer + 4], ' '
    jne check_reverse

    ; Echo back message
    lea rsi, [buffer + 5]
    mov rcx, -1
find_end:
    inc rcx
    cmp byte [rsi + rcx], 0
    jne find_end
    
    mov byte [rsi + rcx], 13
    mov byte [rsi + rcx + 1], 10
    add rcx, 2
    
    mov rax, 1
    mov rdi, [clientfd]
    mov rdx, rcx
    syscall
    jmp send_prompt

check_reverse:
    ; Check REVERSE
    cmp dword [buffer], 0x45564552  ; "REVE"
    jne check_exit
    cmp dword [buffer + 4], 0x20455352  ; "RSE "
    jne check_exit

    ; Get string length and prepare for reverse
    lea rsi, [buffer + 8]    ; Start of input string
    mov rdi, rsi            ; Save start position
    mov rcx, -1
    
count_len:
    inc rcx
    cmp byte [rsi + rcx], 0
    jne count_len
    
    dec rcx                 ; Last valid character
    mov rdx, rcx           ; Save length for later
    
    ; Perform reverse
    mov rsi, rdi           ; Reset to start
    add rdi, rcx           ; Point to last char
    
reverse_loop:
    cmp rsi, rdi
    jae reverse_done
    mov al, [rsi]
    mov bl, [rdi]
    mov [rsi], bl
    mov [rdi], al
    inc rsi
    dec rdi
    jmp reverse_loop

reverse_done:
    lea rsi, [buffer + 8]
    mov byte [rsi + rdx + 1], 13
    mov byte [rsi + rdx + 2], 10
    add rdx, 3
    
    mov rax, 1
    mov rdi, [clientfd]
    syscall
    jmp send_prompt

check_exit:
    ; Check EXIT
    cmp dword [buffer], 0x54495845  ; "EXIT"
    jne unknown_command

    mov rax, 1
    mov rdi, [clientfd]
    mov rsi, msg_goodbye
    mov rdx, msg_goodbye_len
    syscall
    jmp client_close

unknown_command:
    mov rax, 1
    mov rdi, [clientfd]
    mov rsi, msg_unknown
    mov rdx, msg_unknown_len
    syscall
    jmp send_prompt

client_close:
    mov rax, 3
    mov rdi, [clientfd]
    syscall
    xor rdi, rdi
    mov rax, 60
    syscall

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall
