section .data
    msg_title db "=== Number Memory Game ===", 10
    len_title equ $ - msg_title

    msg_start db "Memorize the sequence:", 10
    len_start equ $ - msg_start

    msg_input db 10, "Enter the sequence: "
    len_input equ $ - msg_input

    msg_score db 10, "Your score: "
    len_score equ $ - msg_score

    ; VT100 Escape sequence to clear screen and home cursor
    clear_screen db 27, "[2J", 27, "[H"
    len_clear    equ $ - clear_screen

    newline db 10

    ; Nanosleep structure (3 seconds, 0 nanoseconds)
    delay_sec  dq 3
    delay_nano dq 0

section .bss
    sequence resb 5
    input    resb 8  ; Buffer slightly larger to handle extra chars/newlines
    score    resb 1

section .text
    global _start

_start:
    ; --- 1. Print Title ---
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_title
    mov rdx, len_title
    syscall

    ; --- 2. Generate pseudo-random sequence ---
    mov rcx, 5
    mov rbx, 11         ; Different seed value

gen_loop:
    imul rbx, 13        ; Simple LCG multiplier
    add rbx, 7
    mov rax, rbx
    xor rdx, rdx
    mov rdi, 10
    div rdi             ; dl = remainder (0-9)
    add dl, '0'
    mov [sequence + rcx - 1], dl
    loop gen_loop

    ; --- 3. Show instruction ---
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_start
    mov rdx, len_start
    syscall

    ; --- 4. Display the whole sequence at once ---
    mov rax, 1
    mov rdi, 1
    mov rsi, sequence
    mov rdx, 5
    syscall

    ; Print a newline after sequence
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; --- 5. Sleep for 3 seconds ---
    mov rax, 35         ; sys_nanosleep
    mov rdi, delay_sec  ; Pointer to timespec {3, 0}
    xor rsi, rsi        ; NULL for rem
    syscall

    ; --- 6. Clear Screen ---
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_screen
    mov rdx, len_clear
    syscall

    ; --- 7. Ask for User Input ---
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_input
    mov rdx, len_input
    syscall

    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, input
    mov rdx, 5          ; Read only 5 chars
    syscall

    ; --- 8. Compare Characters ---
    mov rcx, 5
    mov rsi, sequence
    mov rdi, input
    mov byte [score], 0

compare_loop:
    mov al, [rsi]
    mov bl, [rdi]
    cmp al, bl
    jne next_char
    inc byte [score]

next_char:
    inc rsi
    inc rdi
    loop compare_loop

    ; --- 9. Print Final Score ---
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

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; --- 10. Exit ---
    mov rax, 60
    xor rdi, rdi
    syscall
