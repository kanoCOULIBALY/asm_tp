; asm22 - Version simplifiée avec uniquement des syscalls
section .data
    err_msg      db "Usage: ./asm22 [binary_file]", 10, 0
    ok_msg       db "Fichier packagé créé", 10, 0
    suffix       db "_packed", 0
    
    stat_buf     times 144 db 0
    
section .bss
    filename     resb 256
    packname     resb 256
    file_buf     resb 1048576
    out_buf      resb 2097152

section .text
    global _start

_start:
    ; Récupérer les arguments
    pop rax                    ; argc
    cmp rax, 2
    jne error
    
    pop rax                    ; Ignorer argv[0]
    pop rax                    ; argv[1] - nom du fichier
    
    ; Copier le nom du fichier
    lea rdi, [filename]        ; destination
    mov rsi, rax               ; source (argv[1])
    call copy_str
    
    ; Créer le nom du fichier de sortie
    lea rdi, [packname]        ; destination
    lea rsi, [filename]        ; source
    call copy_str
    
    lea rdi, [packname]
    lea rsi, [suffix]
    call append_str
    
    ; Ouvrir le fichier source
    mov rax, 2                 ; open
    lea rdi, [filename]
    xor rsi, rsi               ; O_RDONLY
    xor rdx, rdx
    syscall
    
    test rax, rax
    js error
    
    mov rbx, rax               ; fd
    
    ; Lire le fichier
    mov rax, 0                 ; read
    mov rdi, rbx
    lea rsi, [file_buf]
    mov rdx, 1048576           ; max size
    syscall
    
    test rax, rax
    js close_exit
    
    mov r12, rax               ; taille lue
    
    ; Fermer le fichier
    mov rax, 3                 ; close
    mov rdi, rbx
    syscall
    
    ; Créer fichier de sortie (très simple)
    mov rax, 2                 ; open
    lea rdi, [packname]
    mov rsi, 577               ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 0755q             ; permissions
    syscall
    
    test rax, rax
    js error
    
    mov rbx, rax               ; fd
    
    ; Écrire le même contenu (sans packing pour test)
    mov rax, 1                 ; write
    mov rdi, rbx
    lea rsi, [file_buf]
    mov rdx, r12
    syscall
    
    ; Fermer
    mov rax, 3                 ; close
    mov rdi, rbx
    syscall
    
    ; Message de succès
    mov rax, 1                 ; write
    mov rdi, 1                 ; stdout
    lea rsi, [ok_msg]
    mov rdx, 21                ; longueur
    syscall
    
    ; Succès
    xor rdi, rdi               ; code 0
    jmp exit

error:
    mov rax, 1                 ; write
    mov rdi, 2                 ; stderr
    lea rsi, [err_msg]
    mov rdx, 35                ; longueur
    syscall
    
    mov rdi, 1                 ; code 1
    jmp exit

close_exit:
    mov rax, 3                 ; close
    mov rdi, rbx
    syscall
    mov rdi, 1                 ; code 1

exit:
    mov rax, 60                ; exit
    syscall

; Fonctions utilitaires
copy_str:
    xor rcx, rcx
.loop:
    mov al, [rsi + rcx]
    mov [rdi + rcx], al
    inc rcx
    test al, al
    jnz .loop
    ret

append_str:
    xor rcx, rcx
.find_end:
    mov al, [rdi + rcx]
    test al, al
    jz .append
    inc rcx
    jmp .find_end
.append:
    xor rdx, rdx
.loop:
    mov al, [rsi + rdx]
    mov [rdi + rcx], al
    inc rcx
    inc rdx
    test al, al
    jnz .loop
    ret
