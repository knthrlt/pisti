section .data
    msg_title db "=== Number Memory Game ===", 10
    len_title equ $ - msg_title

    msg_start db "Memorize the sequence:", 10
    len_start equ $ - msg_start

    msg_input db 10, "Enter the sequence: "
    len_input equ $ - msg_input

    msg_score db 10, "Your score: "
    len_score equ $ - msg_score

    newline db 10

section .bss
    sequence resb 5
    input resb 5
    score resb 1

section .text
    global _start

_start:

; -----------------------
; Print title
; -----------------------
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_title
    mov rdx, len_title
    syscall

; -----------------------
; Generate pseudo-random sequence
; -----------------------
    mov rcx, 5
    mov rbx, 7          ; seed value

gen_loop:
    imul rbx, 3
    add rbx, 1
    mov rax, rbx
    xor rdx, rdx
    mov rdi, 10
    div rdi             ; rdx = remainder (0-9)
    add dl, '0'
    mov [sequence + rcx - 1], dl
    loop gen_loop

; -----------------------
; Show instruction
; -----------------------
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_start
    mov rdx, len_start
    syscall

; -----------------------
; Display numbers one by one
; -----------------------
    mov rcx, 5
    mov rsi, sequence

show_loop:
    ; print digit
    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    syscall

    ; newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; sleep 1 second
    mov rax, 35         ; sys_nanosleep
    sub rsp, 16
    mov qword [rsp], 1  ; seconds
    mov qword [rsp+8], 0
    mov rdi, rsp
    xor rsi, rsi
    syscall
    add rsp, 16

    inc rsi
    loop show_loop

; -----------------------
; Clear screen (simple)
; -----------------------
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

; -----------------------
; Ask input
; -----------------------
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_input
    mov rdx, len_input
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 5
    syscall

; -----------------------
; Compare
; -----------------------
    mov rcx, 5
    mov rsi, sequence
    mov rdi, input
    mov byte [score], 0

compare_loop:
    mov al, [rsi]
    mov bl, [rdi]
    cmp al, bl
    jne skip

    inc byte [score]

skip:
    inc rsi
    inc rdi
    loop compare_loop

; -----------------------
; Print score
; -----------------------
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_score
    mov rdx, len_score
    syscall

    mov al, [score]
    add al, '0'
    mov [score], al

    mov rax, 1
    mov rdi, 1
    mov rsi, score
    mov rdx, 1
    syscall

    ; newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

; -----------------------
; Exit
; -----------------------
    mov rax, 60
    xor rdi, rdi
    syscall
