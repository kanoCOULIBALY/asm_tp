section .data
    msg db "1337", 10      ; "1337" + newline
    len equ $ - msg        ; length of the message

section .text
    global _start

_start:
    ; Check if there is exactly 1 argument (argc == 2)
    pop rdi                ; rdi = argc
    cmp rdi, 2
    jne exit_bad_input     ; if argc != 2, bad input

    ; Skip argv[0]
    pop rdi

    ; Get argv[1]
    pop rdi                ; rdi = pointer to argv[1]

    ; Check if the string is empty
    mov al, [rdi]          ; read first character
    cmp al, 0              ; is it null?
    je exit_bad_input      ; if empty string, bad input

    ; Convert string to number
    xor rax, rax           ; rax = 0 (result)
    xor rcx, rcx           ; rcx = 0 (temporary character)

convert_loop:
    mov cl, [rdi]          ; read a character
    cmp cl, 0              ; end of string?
    je check_even          ; if null, done with conversion
    cmp cl, '0'            ; check if it's a digit
    jl exit_bad_input      ; if < '0', bad input
    cmp cl, '9'
    jg exit_bad_input      ; if > '9', bad input

    sub cl, '0'            ; convert ASCII to number
    imul rax, 10           ; rax = rax * 10
    add rax, rcx           ; rax = rax + digit
    inc rdi                ; next character
    jmp convert_loop

check_even:
    ; Test if the number is even (least significant bit = 0)
    test rax, 1            ; test the least significant bit
    jnz exit_error         ; if bit = 1, odd number -> error

print_1337:
    ; Print "1337"
    mov rax, 1             ; syscall: write
    mov rdi, 1             ; file descriptor: stdout
    mov rsi, msg           ; address of message
    mov rdx, len           ; length of message
    syscall

    ; Exit with success (code 0)
    mov rax, 60            ; syscall: exit
    mov rdi, 0             ; exit code 0
    syscall

exit_error:
    ; Exit with error (code 1)
    mov rax, 60            ; syscall: exit
    mov rdi, 1             ; exit code 1
    syscall

exit_bad_input:
    ; Exit with error for bad input (code 2)
    mov rax, 60            ; syscall: exit
    mov rdi, 2             ; exit code 2
    syscall
