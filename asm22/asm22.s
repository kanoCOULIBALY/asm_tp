section .data
    err_usage    db "Usage: ./asm22 [binary_file]", 10
    err_usage_len equ $ - err_usage
    err_open     db "Erreur ouverture fichier", 10
    err_open_len equ $ - err_open
    err_read     db "Erreur lecture fichier", 10
    err_read_len equ $ - err_read
    ok_msg       db "Fichier package cree", 10
    ok_msg_len   equ $ - ok_msg
    suffix       db "_packed", 0
    
section .bss
    filename     resb 256
    packname     resb 256
    file_buf     resb 1048576
    
section .text
    global _start

_start:
    pop rdi
    cmp rdi, 2
    jne error_usage
    
    pop rsi
    pop rsi
    
    mov r13, rsi
    lea rdi, [rel filename]
    call copy_str
    
    lea rdi, [rel packname]
    lea rsi, [rel filename]
    call copy_str
    
    lea rdi, [rel packname]
    lea rsi, [rel suffix]
    call append_str
    
    mov rax, 2
    lea rdi, [rel filename]
    xor rsi, rsi
    xor rdx, rdx
    syscall
    
    cmp rax, 0
    jl error_open
    
    mov r15, rax
    
    mov rax, 0
    mov rdi, r15
    lea rsi, [rel file_buf]
    mov rdx, 1048576
    syscall
    
    cmp rax, 0
    jle error_read
    
    mov r12, rax
    
    mov rax, 3
    mov rdi, r15
    syscall
    
    mov rax, 2
    lea rdi, [rel packname]
    mov rsi, 577
    mov rdx, 0755o
    syscall
    
    cmp rax, 0
    jl error_open
    
    mov r15, rax
    
    mov rax, 1
    mov rdi, r15
    lea rsi, [rel file_buf]
    mov rdx, r12
    syscall
    
    cmp rax, 0
    jl error_write
    
    mov rax, 3
    mov rdi, r15
    syscall
    
    mov rax, 90
    lea rdi, [rel packname]
    mov rsi, 0755o
    syscall
    
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel ok_msg]
    mov rdx, ok_msg_len
    syscall
    
    xor rdi, rdi
    jmp do_exit

error_usage:
    mov rax, 1
    mov rdi, 2
    lea rsi, [rel err_usage]
    mov rdx, err_usage_len
    syscall
    mov rdi, 1
    jmp do_exit

error_open:
    mov rax, 1
    mov rdi, 2
    lea rsi, [rel err_open]
    mov rdx, err_open_len
    syscall
    mov rdi, 1
    jmp do_exit

error_read:
    mov rax, 3
    mov rdi, r15
    syscall
    
    mov rax, 1
    mov rdi, 2
    lea rsi, [rel err_read]
    mov rdx, err_read_len
    syscall
    mov rdi, 1
    jmp do_exit

error_write:
    mov rax, 3
    mov rdi, r15
    syscall
    mov rdi, 1
    jmp do_exit

do_exit:
    mov rax, 60
    syscall

copy_str:
    push rax
    push rcx
    xor rcx, rcx
.loop:
    mov al, [rsi + rcx]
    mov [rdi + rcx], al
    test al, al
    jz .done
    inc rcx
    jmp .loop
.done:
    pop rcx
    pop rax
    ret

append_str:
    push rax
    push rbx
    mov rbx, rdi
.find_end:
    cmp byte [rdi], 0
    je .found_end
    inc rdi
    jmp .find_end
.found_end:
.copy:
    mov al, [rsi]
    mov [rdi], al
    test al, al
    jz .done
    inc rsi
    inc rdi
    jmp .copy
.done:
    mov rdi, rbx
    pop rbx
    pop rax
    ret
