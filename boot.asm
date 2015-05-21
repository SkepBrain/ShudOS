BITS	16
jmp	Main

Print:
lodsb
cmp	al, 0
je	ReturnPrint
mov	ah, 0eh
int	10h
jmp	Print

ReturnPrint:
ret

Main:
cli             ; initialization
mov	ax, 0x0000
mov	ss, ax
mov	sp, 0xFFFF
sti

mov	ax, 07C0h
mov	ds, ax
mov es, ax      ; initialization end

ResetFloppy:
mov ah, 0h
mov dl, 0h
int 13h

LoadRoot:
mov ah, 2
mov al, 14
mov ch, 0
mov cl, 2
mov dh, 1
mov dl, 0
mov bx, rootBuffer
int 13h         ; BIOS call to retrieve root dir
jnc SuccessLoadRoot
mov si, rootLoadErr
call Print
jmp ResetFloppy  ; error occured, retry loading

SuccessLoadRoot:
mov si, rootBuffer  ; prepare for kernel search
mov cx, 224         ; max # of possible entries

CheckBuffer:
mov di, kernelFile
CheckFilename:
mov ax, cx
mov dx, si
mov cx, 11
repe cmpsb
mov si, dx
add si, 32
cmp cx, 0
je KernelFound             ; kernel found if all chars in filename match
mov cx, ax
loop CheckBuffer           ; else check other entry
mov si, kernelNotFoundErr
call Print
int 18h                    ; crash bootloader

KernelFound:
mov	si, msg
call Print
cli
hlt

bootdrive	db	0
msg	db	"Do you like fishsticks?", 0
rootLoadErr db "Error while loading root directory. Retrying...", 0
kernelNotFoundErr db "Kernel.sys not found. Boot cancelled.", 0dh, 0ah, 0
kernelFile db "KERNEL  SYS"
filenameBuffer times 11 db 0

times	510 - ($-$$)	db	0
dw	0xAA55
rootBuffer: