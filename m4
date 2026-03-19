section .data
    msg_title db "=== Number Memory Game ===", 10
    len_title equ $ - msg_title

    msg_start db "Memorize the sequence:", 10
    len_start equ $ - msg_start

    msg_input db 10, "Enter the sequence: "
    len_input equ $ - msg_input

    msg_score db 10, "Your score: "
    len_score equ $ - msg_score

    msg_next  db 10, "Press Enter for the next round...", 10
    len_next  equ $ - msg_next

    clear_screen db 27, "[2J", 27, "[H"
    len_clear    equ $ - clear_screen

    newline db 10

    delay_sec  dq 3
    delay_nano dq 0

section .bss
    sequence resb 5
    input    resb 10
    score    resb 1
    time_buf resq 2    ; Buffer for gettimeofday (seconds, microseconds)

section .text
    global _start

_start:
    ; --- 1. Initial Clear and Title ---
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_screen
    mov rdx, len_clear
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_title
    mov rdx, len_title
    syscall

game_loop:
    ; --- 2. Seed Randomness using System Time ---
    mov rax, 96         ; sys_gettimeofday
    mov rdi, time_buf
    xor rsi, rsi
    syscall
    mov rbx, [time_buf + 8] ; Use microseconds as the seed

    ; --- 3. Generate 5 New Digits ---
    mov rcx, 5
gen_digits:
    imul rbx, 1103515245 ; Standard LCG Multiplier
    add rbx, 12345
    mov rax, rbx
    xor rdx, rdx
    mov rdi, 10
    div rdi              ; rdx = 0-9
    add dl, '0'
    mov [sequence + rcx - 1], dl
    loop gen_digits

    ; --- 4. Show Sequence ---
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_start
    mov rdx, len_start
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, sequence
    mov rdx, 5
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; --- 5. Wait 3 Seconds ---
    mov rax, 35
    mov rdi, delay_sec
    xor rsi, rsi
    syscall

    ; --- 6. Clear Screen ---
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_screen
    mov rdx, len_clear
    syscall

    ; --- 7. Get User Input ---
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_input
    mov rdx, len_input
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 10
    syscall

    ; --- 8. Compare and Score ---
    mov rcx, 5
    mov rsi, sequence
    mov rdi, input
    mov byte [score], 0
compare:
    mov al, [rsi]
    mov bl, [rdi]
    cmp al, bl
    jne no_match
    inc byte [score]
no_match:
    inc rsi
    inc rdi
    loop compare

    ; --- 9. Display Score ---
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

    ; --- 10. Pause before Next Round ---
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_next
    mov rdx, len_next
    syscall

    mov rax, 0          ; sys_read (waiting for Enter)
    mov rdi, 0
    mov rsi, input
    mov rdx, 10
    syscall

    ; --- 11. Repeat! ---
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_screen
    mov rdx, len_clear
    syscall
    jmp game_loop
