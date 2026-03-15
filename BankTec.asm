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

msgCuenta db 13,10,'Ingrese numero de cuenta: $'
msgMonto db 13,10,'Ingrese monto: $'
msgSaldo db 13,10,'Ingrese saldo inicial: $'
msgCuentaConsulta db 13,10,'Ingrese numero de cuenta a consultar: $'
msgCuentaCreada db 13,10,'Cuenta creada correctamente',13,10,'$'
msgDepositoOK db 13,10,'Deposito realizado correctamente',13,10,'$'
msgRetiroOK db 13,10,'Retiro realizado correctamente',13,10,'$'

; buffer para lectura
buffer db 10
len db ?
texto db 10 dup(?)

numero dw ?


; estructura  cuentas

MAX_CUENTAS equ 10

cuentaNumero dw MAX_CUENTAS dup(0)

cuentaNombre db MAX_CUENTAS*20 dup(0)

cuentaSaldo dw MAX_CUENTAS dup(0)

cuentaEstado db MAX_CUENTAS dup(0) 

totalCuentas dw 0


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

mov si,offset buffer+2

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


BuscarCuenta proc

mov cx,totalCuentas
cmp cx,0
je no_encontrada

mov bx,0

buscar_loop:

cmp cuentaNumero[bx],ax
je encontrada

add bx,2
loop buscar_loop

no_encontrada:
mov ax,-1
ret

encontrada:
mov ax,bx
ret

BuscarCuenta endp 


CrearCuenta proc

; verificar si ya hay 10 cuentas

mov ax,totalCuentas
cmp ax,MAX_CUENTAS
je max_cuentas

; pedir numero de cuenta

mov dx,offset msgCuenta
call PrintString
call ReadNumber
mov bx,ax

; verificar que no exista

mov ax,bx
call BuscarCuenta

cmp ax,-1
jne cuenta_repetida

; guardar numero de cuenta

mov ax,totalCuentas
mov dx,2
mul dx

mov si,ax

mov ax,bx
mov cuentaNumero[si],ax

; pedir saldo inicial

mov dx,offset msgSaldo
call PrintString
call ReadNumber
call ValidarNumero

mov dx,ax

mov ax,totalCuentas
mov bx,2
mul bx

mov si,ax
mov cuentaSaldo[si],dx

; activar cuenta

mov bx,totalCuentas
mov cuentaEstado[bx],1

inc totalCuentas  
mov dx,offset msgCuentaCreada
call PrintString

ret

cuenta_repetida:
call MostrarError
ret

max_cuentas:
call MostrarError
ret

CrearCuenta endp


Depositar proc

; pedir numero de cuenta

mov dx,offset msgCuenta
call PrintString
call ReadNumber
mov bx,ax

mov ax,bx
call BuscarCuenta

cmp ax,-1
je errorDeposito

mov si,ax

; verificar estado

mov bx,si
shr bx,1
mov al,cuentaEstado[bx]

cmp al,1
jne errorDeposito

; pedir monto

mov dx,offset msgMonto
call PrintString
call ReadNumber
call ValidarNumero

mov dx,ax

mov ax,si
mov bx,2
mul bx
mov di,ax

mov ax,cuentaSaldo[di]
add ax,dx
mov cuentaSaldo[di],ax

mov dx,offset msgDepositoOK
call PrintString

ret

errorDeposito:
call MostrarError
ret

Depositar endp


Retirar proc

mov dx,offset msgCuenta
call PrintString
call ReadNumber
mov bx,ax

mov ax,bx
call BuscarCuenta

cmp ax,-1
je errorRetiro

mov si,ax

mov bx,si
shr bx,1
mov al,cuentaEstado[bx]

cmp al,1
jne errorRetiro

mov dx,offset msgMonto
call PrintString
call ReadNumber
call ValidarNumero

mov dx,ax

mov ax,si
mov bx,2
mul bx
mov di,ax

mov ax,cuentaSaldo[di]

cmp ax,dx
jl errorRetiro

sub ax,dx
mov cuentaSaldo[di],ax

mov dx,offset msgRetiroOK
call PrintString

ret

errorRetiro:
call MostrarError
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