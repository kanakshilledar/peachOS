ORG 0x00
BITS 16
_start:
    jmp short start
    nop

times 33 db 0
start:
    jmp 0x7C0:step2



step2:
    cli             ; clear interrupts
    mov ax, 0x7C0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7C00
    sti             ; enables interrupts

    mov ah, 2       ; read sector command
    mov al, 1       ; one sector to read
    mov ch, 0       ; cylinder low 8 bits
    mov cl, 2       ; read sector 2
    mov dh, 0       ; head number
    mov bx, buffer
    int 0x13        ; interrupt to read from disk
    jc error        ; jump to error if CF set

    mov si, buffer  ; printing the message
    call print
    
    jmp $           ; infinite jump
error:
    mov si, error_message
    call print
    jmp $

print:
    mov bx, 0
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

error_message: db 'Failed to load sector', 0

times 510-($ - $$) db 0
dw 0xAA55

buffer:
