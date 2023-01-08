ORG 0x7C00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start
    nop

times 33 db 0
start:
    jmp 0:step2



step2:
    cli             ; clear interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti             ; enables interrupts

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    ; TODO
    ; jmp CODE_SEG:load32
    jmp $

; GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code:           ; CS should point to this
    dw 0xffff       ; Segment limit first 0-15 bits
    dw 0            ; Base 0-15 bits
    db 0            ; Base 16-23 bits
    db 0x9a         ; access bytes
    db 11001111b    ; high 4 bit flags and low 4 bit flags
    db 0            ; base 24-31 bits

; offset 0x10
gdt_data:           ; DS, SS, ES, FS, GS 
    dw 0xffff       ; Segment limit first 0-15 bits
    dw 0            ; Base 0-15 bits
    db 0            ; Base 16-23 bits
    db 0x92         ; access bytes
    db 11001111b    ; high 4 bit flags and low 4 bit flags
    db 0            ; base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start



times 510-($ - $$) db 0
dw 0xAA55
