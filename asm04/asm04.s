section .data
	msg db "1337", 10
	len equ $ -msg

section .text
	global _start

_start: 

	pop rdi
	cmp rdi, 2
	jne exit_error

	pop rdi

	pop rdi

	xor rax, rax
	xor rcx, rcx
convert_loop:
	mov cl, [rdi]
	cmp cl, 0
	je check_even
	cmp cl, 0
	jl exit_error
cmp cl, '9'
    jg exit_error
    sub cl, '0'            ; convertir ASCII en nombre
    imul rax, 10           ; rax = rax * 10
    add rax, rcx           ; rax = rax + chiffre
    inc rdi                ; caractère suivant
    jmp convert_loop

check_even:
    ; Tester si le nombre est pair (bit 0 = 0)
    test rax, 1            ; tester le bit de poids faible
    jnz exit_error         ; si bit = 1, nombre impair -> erreur

print_1337:
    ; Afficher "1337"
    mov rax, 1             ; syscall write
    mov rdi, 1             ; stdout
    mov rsi, msg           ; adresse du message
    mov rdx, len           ; longueur
    syscall
    
    ; Sortir avec succès (code 0)
    mov rax, 60            ; syscall exit
    mov rdi, 0             ; code de sortie 0
    syscall

exit_error:
    ; Sortir avec erreur (code 1)
    mov rax, 60            ; syscall exit
    mov rdi, 1             ; code de sortie 1
    syscall
