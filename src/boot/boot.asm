ORG 0x7C00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

jmp short start
nop

; FAT16 Header
OEMIdentifier           db 'PEACHOS '
BytesPerSector          dw 0x200
SectorsPerCluster       db 0x80
ReservedSectors         dw 200
FATCopies               db 0x02
RootDirEntries          dw 0x40
NumSectors              dw 0x00
MediaType               db 0xF8
SectorsPerFat           dw 0x100
SectorsPerTrack         dw 0x20
NumberOfHeads           dw 0x40
HiddenSectors           dd 0x00
SectorsBig              dd 0x773594

; Extended BPB (Dos 4.0)
DriveNumber             db 0x80
WinNTBit                db 0x00
Signature               db 0x29
VolumeID                dd 0xD105
VolumeIDString          db 'PEACHOS BOO'
SystemIDString          db 'FAT16   '

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
    jmp CODE_SEG:load32

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

[BITS 32]
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000          ; equivalent of 1M
    call ata_lba_read
    jmp CODE_SEG:0x0100000     ;

; implementing hdd driver
ata_lba_read:
    mov ebx, eax        ; backup the lba
    ; send the highest 8 bits of the lba to hdd controller
    shr eax, 24
    or eax, 0xe0        ; select the master drive
    mov dx, 0x1f6
    out dx, al
    ; finished sending the highest 8 bits of the lba to hdd controller
    ; send the total sectors to read
    mov eax, ecx
    mov dx, 0x1f2
    out dx, al
    ; finished sending the total sector sto read
    ; sending more bits of the lba
    mov eax, ebx        ; restore the backup
    mov dx, 0x1f3
    out dx, al
    ; finished sending more bits to the lba
    ; send more bits of the lba
    mov dx, 0x1f4
    mov eax, ebx        ; restore the backup lba
    shr eax, 8
    out dx, al
    ; finished sending more bits of the lba
    ; sending upper 16 bits of the lba
    mov dx, 0x1f5
    mov eax, ebx        ; restore the backup lba
    shr eax, 16
    out dx, al
    ; finished sending upper 16 bits of the lba
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; read all secotrs into memory
.next_sector:
    push ecx
; checking if we need to read
.try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .try_again

    ; we need to read 256 words at a time
    mov ecx,  256
    mov dx, 0x1f0
    rep insw
    pop ecx
    loop .next_sector
    ; end of reading sectors into memory
    ret

times 510-($ - $$) db 0
dw 0xAA55

