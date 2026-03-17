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

;mensajes de error
msgError db 13,10,'[ERROR] Entrada invalida',13,10,'$'
msgNoCuenta db 13,10, '[ERROR] Cuenta no existe',13,10,'$'
msgNoFondos db 13,10, '[ERROR] Fondos insuficientes',13,10,'$'
msgInactiva db 13,10, '[ERROR] Cuenta inactiva',13,10,'$'
msgYaInactiva db 13,10, '[ERROR] Cuenta ya inactiva',13,10,'$' 
msgCuentaExist db 13,10, '[ERROR] Cuenta ya existe',13,10,'$'
msgErrorMax db 13,10, '[ERROR] Maximo de cuentas alcanzado',13,10,'$'

;mensajes interacciones
msgCuenta db 13,10,'Ingrese numero de cuenta: $'
msgMonto db 13,10,'Ingrese monto: $'
msgSaldo db 13,10,'Ingrese saldo inicial: $'
msgCuentaConsulta db 13,10,'Ingrese numero de cuenta a consultar: $'
msgCuentaCreada db 13,10,'Cuenta creada correctamente',13,10,'$'
msgDepositoOK db 13,10,'Deposito realizado correctamente',13,10,'$'
msgRetiroOK db 13,10,'Retiro realizado correctamente',13,10,'$' 
msgSaldoActual db 13,10,'Saldo actual: $' 
msgCuentaDesactivada db 13,10,'Cuenta desactivada correctamente',13,10,'$'  

; mensajes para el reporte 
msgReporte       db 13,10,'----------------------------------',13,10
                 db '         REPORTE GENERAL          ',13,10
                 db '----------------------------------',13,10,'$'
msgActivas       db 13,10,'Cuentas activas:   $'
msgInactivas     db 13,10,'Cuentas inactivas: $'
msgSaldoTotal    db 13,10,'Saldo total:       $'
msgMayorSaldo    db 13,10,'Cuenta mayor saldo: $'
msgMenorSaldo    db 13,10,'Cuenta menor saldo: $'
msgNoCuentas     db 13,10,'No hay cuentas registradas',13,10,'$'
msgSeparador     db 13,10,'----------------------------------',13,10,'$'
msgEspacio       db ' ','$'

; contadores temporales para el reporte 
cntActivas   dw 0
cntInactivas dw 0
saldoTotal   dw 0
idxMayor     dw 0
idxMenor     dw 0  

entradaInvalida db 0    ; 0 = entrada ok, 1 = entrada invalida 

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

    push si         
    push bx          

    xor ax,ax
    xor bh,bh        ; limpiar BH antes del loop
    mov cl,buffer+1
    mov si,offset buffer+2

convert_loop:
    cmp cl,0
    je fin_convert

    mov bl,[si]
    sub bl,30h       

    push bx          
    mov bx,10
    mul bx           
    pop bx           

    add ax,bx        

    inc si
    dec cl
    jmp convert_loop

fin_convert:

    pop bx
    pop si
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


; error entrada invalida
MostrarError proc

mov dx,offset msgError
mov ah,09h
int 21h

ret

MostrarError endp 
        
; error maximo de cuentas alcanzado        
MostrarErrorMax proc

mov dx,offset msgErrorMax
mov ah,09h
int 21h

ret

MostrarErrorMax endp

; error cuenta no existe o no encontrada
MostrarErrorCuenta proc

mov dx,offset msgNoCuenta
mov ah,09h
int 21h

ret

MostrarErrorCuenta endp
                 
; error fondos insuficientes                 
MostrarErrorFondos proc

mov dx,offset msgNoFondos
mov ah,09h
int 21h

ret

MostrarErrorFondos endp  

; error cuenta inactiva
MostrarErrorInactiva proc

mov dx,offset msgInactiva
mov ah,09h
int 21h

ret

MostrarErrorInactiva endp

; error cuenta ya inactiva anteriormente
MostrarErrorYaInac proc

mov dx,offset msgYaInactiva
mov ah,09h
int 21h

ret

MostrarErrorYaInac endp

; error cuenta existente
MostrarErrorCuentaEx proc

mov dx,offset msgCuentaExist
mov ah,09h
int 21h

ret

MostrarErrorCuentaEx endp


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

    mov ax,totalCuentas
    cmp ax,MAX_CUENTAS
    je max_cuentas

    mov dx,offset msgCuenta
    call PrintString
    call ReadNumber
    mov di,ax            

    mov ax,di
    call BuscarCuenta    
    cmp ax,-1
    jne cuenta_repetida

    ; guardar numero de cuenta
    mov ax,totalCuentas
    shl ax,1
    mov si,ax
    mov ax,di            
    mov cuentaNumero[si],ax

    ; pedir saldo inicial
    mov dx,offset msgSaldo
    call PrintString

    push di              
    call ReadNumber
    call ValidarNumero
    pop di

    mov cx,ax            ; saldo en CX

    mov ax,totalCuentas
    shl ax,1
    mov si,ax
    mov cuentaSaldo[si],cx

    ; activar cuenta
    mov bx,totalCuentas
    mov cuentaEstado[bx],1

    inc totalCuentas
    mov dx,offset msgCuentaCreada
    call PrintString
    ret

cuenta_repetida:
    call MostrarErrorCuentaEx
    ret

max_cuentas:
    call MostrarErrorMax
    ret

CrearCuenta endp


Depositar proc

    mov dx,offset msgCuenta
    call PrintString
    call ReadNumber
    mov bx,ax

    mov ax,bx
    call BuscarCuenta
    cmp ax,-1
    je errorDeposito

    mov si,ax

    mov bx,si
    shr bx,1
    mov al,cuentaEstado[bx]
    cmp al,1
    jne errorDeposito

    mov dx,offset msgMonto
    call PrintString

    push si              ; guardar offset antes de ReadNumber
    call ReadNumber
    call ValidarNumero
    pop si               ; restaurar offset correcto

    mov cx,ax

    mov ax,cuentaSaldo[si]
    add ax,cx
    mov cuentaSaldo[si],ax

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

    push si              ; guardar offset antes de ReadNumber
    call ReadNumber
    call ValidarNumero
    pop si               ; restaurar offset correcto

    mov cx,ax

    mov ax,cuentaSaldo[si]
    cmp ax,cx
    jb errorRetiro

    sub ax,cx
    mov cuentaSaldo[si],ax

    mov dx,offset msgRetiroOK
    call PrintString
    ret

errorRetiro:
    call MostrarErrorFondos
    ret

Retirar endp


ConsultarSaldo proc

    mov dx,offset msgCuentaConsulta
    call PrintString
    call ReadNumber
    mov bx,ax

    mov ax,bx
    call BuscarCuenta

    cmp ax,-1
    je errorConsulta

    mov si,ax

    
    mov dx,offset msgSaldoActual
    call PrintString

    ; cargar saldo 
    mov ax,cuentaSaldo[si]
    call IntToAscii

    ret

errorConsulta:
    call MostrarErrorCuenta
    ret

ConsultarSaldo endp


ReporteGeneral proc

    ; verificar que haya cuentas
    mov ax,totalCuentas
    cmp ax,0
    je reporte_vacio

    ; encabezado
    mov dx,offset msgReporte
    call PrintString

    ; resetear contadores
    mov word ptr cntActivas,0
    mov word ptr cntInactivas,0
    mov word ptr saldoTotal,0

    ; inicializar mayor y menor con la primera cuenta
    mov word ptr idxMayor,0
    mov word ptr idxMenor,0

    ; recorrer todas las cuentas
    mov cx,totalCuentas
    mov bx,0             ; bx = indice (para cuentaEstado)
    mov si,0             ; si = offset word (bx*2, para cuentaSaldo/cuentaNumero)

reporte_loop:

    ; revisar estado
    mov al,cuentaEstado[bx]
    cmp al,1
    je es_activa

    inc word ptr cntInactivas
    jmp siguiente_cuenta

es_activa:
    inc word ptr cntActivas

    ; acumular saldo total
    mov ax,cuentaSaldo[si]
    add saldoTotal,ax

    ; comparar con mayor
    mov di,idxMayor
    shl di,1             ; di = idxMayor * 2
    mov ax,cuentaSaldo[si]
    cmp ax,cuentaSaldo[di]
    jbe no_es_mayor
    mov ax,bx
    mov idxMayor,ax

no_es_mayor:
    ; comparar con menor
    mov di,idxMenor
    shl di,1
    mov ax,cuentaSaldo[si]
    cmp ax,cuentaSaldo[di]
    jae no_es_menor
    mov ax,bx
    mov idxMenor,ax

no_es_menor:

siguiente_cuenta:
    inc bx
    add si,2
    loop reporte_loop

    ; imprimir cuentas activas
    mov dx,offset msgActivas
    call PrintString
    mov ax,cntActivas
    call IntToAscii

    ; imprimir cuentas inactivas
    mov dx,offset msgInactivas
    call PrintString
    mov ax,cntInactivas
    call IntToAscii

    ; imprimir saldo total
    mov dx,offset msgSaldoTotal
    call PrintString
    mov ax,saldoTotal
    call IntToAscii

    ; imprimir cuenta con mayor saldo
    mov dx,offset msgMayorSaldo
    call PrintString
    mov si,idxMayor
    shl si,1
    mov ax,cuentaNumero[si]
    call IntToAscii
    mov dx,offset msgEspacio
    call PrintString
    mov ax,cuentaSaldo[si]
    call IntToAscii

    ; imprimir cuenta con menor saldo
    mov dx,offset msgMenorSaldo
    call PrintString
    mov si,idxMenor
    shl si,1
    mov ax,cuentaNumero[si]
    call IntToAscii
    mov dx,offset msgEspacio
    call PrintString
    mov ax,cuentaSaldo[si]
    call IntToAscii

    mov dx,offset msgSeparador
    call PrintString

    ret

reporte_vacio:
    mov dx,offset msgNoCuentas
    call PrintString
    ret

ReporteGeneral endp                      


DesactivarCuenta proc

; pedir numero de cuenta

mov dx,offset msgCuenta
call PrintString
call ReadNumber
mov bx,ax

; buscar cuenta

mov ax,bx
call BuscarCuenta

cmp ax,-1
je errorCuentaNoEx

mov si,ax

; obtener indice de cuenta

mov bx,si
shr bx,1

; verificar estado

mov al,cuentaEstado[bx]

cmp al,0
je errorDesactivar

; cambiar estado a inactiva

mov cuentaEstado[bx],0

; mensaje de exito

mov dx,offset msgCuentaDesactivada
call PrintString

ret

errorCuentaNoEx:
call MostrarErrorCuenta
ret

errorDesactivar:

call MostrarErrorYaInac
ret

DesactivarCuenta endp