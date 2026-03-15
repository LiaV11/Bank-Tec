;Bank Tec

org 100h
jmp start

; variables


menu db 13,10
     db '----------------------------------',13,10
     db '              BANKTEC             ',13,10
     db '----------------------------------',13,10
     db ' 1. Crear cuenta                  ',13,10
     db ' 2. Depositar dinero              ',13,10
     db ' 3. Retirar dinero                ',13,10
     db ' 4. Consultar saldo               ',13,10
     db ' 5. Reporte general               ',13,10
     db ' 6. Desactivar cuenta             ',13,10
     db ' 7. Salir                         ',13,10
     db '----------------------------------',13,10
     db ' Seleccione una opcion:           ',13,10
     db '----------------------------------',13,10
     db '$'

msgError db 13,10,'[ERROR] Entrada invalida',13,10,'$'

msgNumero db 13,10,'Ingrese numero: $'

; buffer para lectura
buffer db 10
len db ?
texto db 10 dup(?)

numero dw ?


; estructura  cuentas

MAX_CUENTAS equ 10

cuentaNumero dw MAX_CUENTAS dup(0)

cuentaNombre db MAX_CUENTAS*20 dup(0)

cuentaSaldo dd MAX_CUENTAS dup(0)

cuentaEstado db MAX_CUENTAS dup(0)


; programa principal

start:

call MainLoop

mov ah,4ch
int 21h



MainLoop proc

menu_loop:

call MenuPrincipal
call ReadNumber

cmp ax,1
je opcion1

cmp ax,2
je opcion2

cmp ax,3
je opcion3

cmp ax,4
je opcion4

cmp ax,5
je opcion5

cmp ax,6
je opcion6

cmp ax,7
je salir

call MostrarError
jmp menu_loop


opcion1:
call CrearCuenta
jmp menu_loop

opcion2:
call Depositar
jmp menu_loop

opcion3:
call Retirar
jmp menu_loop

opcion4:
call ConsultarSaldo
jmp menu_loop

opcion5:
call ReporteGeneral
jmp menu_loop

opcion6:
call DesactivarCuenta
jmp menu_loop


salir:
ret

MainLoop endp


; menu

MenuPrincipal proc

mov dx,offset menu
call PrintString

ret

MenuPrincipal endp



PrintString proc

mov ah,09h
int 21h

ret

PrintString endp


; lee los numeros del teclado

ReadNumber proc

mov dx,offset msgNumero
call PrintString

mov dx,offset buffer
mov ah,0Ah
int 21h

call AsciiToInt

ret

ReadNumber endp


; ASCII a numero


AsciiToInt proc

xor ax,ax
xor bx,bx

mov si,offset texto

convert_loop:

mov bl,[si]

cmp bl,13
je fin_convert

sub bl,30h

mov cx,10
mul cx

add ax,bx

inc si
jmp convert_loop

fin_convert:

ret

AsciiToInt endp


; numero a ASCII

IntToAscii proc

mov bx,10
xor cx,cx

convert:

xor dx,dx
div bx

push dx
inc cx

cmp ax,0
jne convert

print:

pop dx
add dl,30h

mov ah,02h
int 21h

loop print

ret

IntToAscii endp



ValidarNumero proc

cmp ax,0
jl invalido

ret

invalido:
call MostrarError
ret

ValidarNumero endp



MostrarError proc

mov dx,offset msgError
mov ah,09h
int 21h

ret

MostrarError endp


; otras

CrearCuenta proc
; ...
ret
CrearCuenta endp


Depositar proc
; ...
ret
Depositar endp


Retirar proc
; ...
ret
Retirar endp


ConsultarSaldo proc
; ...
ret
ConsultarSaldo endp


ReporteGeneral proc
; ...
ret
ReporteGeneral endp


DesactivarCuenta proc
; ...
ret
DesactivarCuenta endp