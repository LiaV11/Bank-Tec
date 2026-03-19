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

; mensajes de error
msgError db 13,10,'[ERROR] Entrada invalida',13,10,'$'
msgNoCuenta db 13,10, '[ERROR] Cuenta no existe',13,10,'$'
msgNoFondos db 13,10, '[ERROR] Fondos insuficientes',13,10,'$'
msgInactiva db 13,10, '[ERROR] Cuenta inactiva',13,10,'$'
msgYaInactiva db 13,10, '[ERROR] Cuenta ya inactiva',13,10,'$' 
msgCuentaExist db 13,10, '[ERROR] Cuenta ya existe',13,10,'$'
msgErrorMax db 13,10, '[ERROR] Maximo de cuentas alcanzado',13,10,'$'  
msgOverflow db 13,10,'[ERROR] El monto excede el saldo maximo permitido (65535)',13,10,'$'

; mensajes interacciones
msgCuenta db 13,10,'Ingrese numero de cuenta: $'
msgMonto db 13,10,'Ingrese monto: $'
msgSaldo db 13,10,'Ingrese saldo inicial: $'
msgCuentaConsulta db 13,10,'Ingrese numero de cuenta a consultar: $'
msgCuentaCreada db 13,10,'Cuenta creada correctamente',13,10,'$'
msgDepositoOK db 13,10,'Deposito realizado correctamente',13,10,'$'
msgRetiroOK db 13,10,'Retiro realizado correctamente',13,10,'$' 
msgSaldoActual db 13,10,'Saldo actual: $' 
msgCuentaDesactivada db 13,10,'Cuenta desactivada correctamente',13,10,'$' 
msgNombre db 13,10,'Ingrese nombre (max 20 chars): $' 

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
buffer db 21
len db ?
texto db 21 dup(?)

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


ReadString proc

mov dx,offset buffer
mov ah,0Ah
int 21h

ret

ReadString endp


; ASCII a numero


AsciiToInt proc

    push si         
    push bx  
    
    ; limpiar flag de entrada invalida
    mov byte ptr entradaInvalida,0        

    xor ax,ax
    xor bh,bh        ; limpiar BH antes del loop
    mov cl,buffer+1 
    cmp cl,5
    ja entrada_vacia   ; si tiene mas de 5 digitos es invalido
    mov si,offset buffer+2   
    
    ; verificar que haya al menos un caracter
    cmp cl,0
    je entrada_vacia

convert_loop:
    cmp cl,0
    je fin_convert

    mov bl,[si] 
    
    ; validar que sea digito entre '0' y '9'
    cmp bl,'0'
    jb caracter_invalido
    cmp bl,'9'
    ja caracter_invalido
    
    sub bl,30h       

    push bx          ; guardar digito

    mov bx,10
    mul bx
    jc overflow_error
    
    pop bx           ; recuperar digito
    
    add ax,bx
    jc overflow_error        

    inc si
    dec cl
    jmp convert_loop
  
caracter_invalido:
entrada_vacia:
    mov byte ptr entradaInvalida,1
    xor ax,ax

overflow_error:
    mov byte ptr entradaInvalida,1
    xor ax,ax
    jmp fin_convert  
  
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



; validacion para saldo inicial
ValidarNumero proc

    ; verificar si hubo error en la conversion
    cmp byte ptr entradaInvalida,1
    je validar_error

    ; Si todo esta bien
    clc        ; Limpiar carry
    ret

validar_error:
    call MostrarError
    mov byte ptr entradaInvalida,0
    stc        ; error
    ret

ValidarNumero endp   


; valida montos de deposito y retiro
ValidarMonto proc

    ; verificar entrada invalida
    cmp byte ptr entradaInvalida,1
    je monto_error

    ; verificar que sea mayor a 0
    cmp ax,0
    je monto_error

    clc                               ; carry flag = sin error
    ret

monto_error:
    call MostrarError
    mov byte ptr entradaInvalida,0
    stc                               ; carry flag = hubo error
    ret

ValidarMonto endp


; error entrada invalida
MostrarError proc

mov dx,offset msgError
mov ah,09h
int 21h

ret

MostrarError endp 

; error desbordamiento en el saldo (max 65535)
MostrarErrorOverflow proc

mov dx,offset msgOverflow
mov ah,09h
int 21h

ret

MostrarErrorOverflow endp
        
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

    ; CX = cantidad total de cuentas registradas
    mov cx,totalCuentas
    cmp cx,0
    je no_encontrada
    
    ; BX se usara como indice (cada cuenta ocupa 2 bytes)
    mov bx,0
    
    buscar_loop:
    
    ; Compara el numero de cuenta actual con el buscado (AX)
    cmp cuentaNumero[bx],ax
    je encontrada
    
    ; Avanza al siguiente elemento del arreglo (2 bytes)
    add bx,2
    loop buscar_loop
    
    no_encontrada:  
    
    ; Retorna -1 si no se encontró la cuenta
    mov ax,-1
    ret
    
    encontrada: 
    
    ; Retorna el offset donde se encontró la cuenta
    mov ax,bx
    ret

BuscarCuenta endp 


CrearCuenta proc 
    
    ; Verifica si ya se alcanzo el maximo de cuentas
    mov ax,totalCuentas
    cmp ax,MAX_CUENTAS
    je max_cuentas
    
    ; Solicita el numero de cuenta al usuario
    mov dx,offset msgCuenta
    call PrintString
    call ReadNumber
    mov di,ax            
    
    ; Verifica si la cuenta ya existe
    mov ax,di
    call BuscarCuenta    
    cmp ax,-1
    jne cuenta_repetida

    ; Guarda el numero de cuenta en el arreglo (cada cuenta ocupa 2 bytes)
    mov ax,totalCuentas
    shl ax,1
    mov si,ax
    mov ax,di            
    mov cuentaNumero[si],ax 
    
    ; Solicita el nombre del usuario
    mov dx,offset msgNombre
    call PrintString
    
    call ReadString
    
    ; Guardar nombre (maximo 20 caracteres)

    ; Calcula la posicion en el arreglo: totalCuentas * 20
    mov ax,totalCuentas
    mov bx,20
    mul bx
    mov si,ax
    
    ; Apunta al inicio real del string (buffer + 2)
    mov di,offset buffer+2
    
    ; Obtiene la longitud ingresada (real)
    mov cl,buffer+1
    cmp cl,20
    jbe longitud_ok
    mov cl,20
    
longitud_ok:
    mov ch,0
    
    ; Copia caracter por caracter al arreglo cuentaNombre
guardar_nombre:
    mov al,[di]
    mov cuentaNombre[si],al
    inc si
    inc di
    loop guardar_nombre
    
    ; Calcula cuantos espacios faltan para completar 20 caracteres
    mov ax,0
    mov al,buffer+1
    mov bx,20
    sub bx,ax
    
    cmp bx,0
    jbe fin_nombre
    
    mov cx,bx
    
    ; Rellena con ceros los espacios restantes
rellenar:
    mov byte ptr cuentaNombre[si],0
    inc si
    loop rellenar
    
fin_nombre:

    ; Solicita el saldo inicial
    mov dx,offset msgSaldo
    call PrintString

leer_saldo:
    call ReadNumber
    call ValidarNumero 
    jnc saldo_ok

    ; Si el numero es invalido, vuelve a pedir el saldo
    mov dx,offset msgSaldo
    call PrintString
    jmp leer_saldo

saldo_ok:
    
    ; Guarda el saldo en el arreglo (2 bytes por cuenta)
    mov cx,ax            ; saldo en CX

    mov ax,totalCuentas
    shl ax,1
    mov si,ax
    mov cuentaSaldo[si],cx

    ; Marca la cuenta como activa
    mov bx,totalCuentas
    mov cuentaEstado[bx],1
    
    ; Incrementa el total de cuentas registradas
    inc totalCuentas
    mov dx,offset msgCuentaCreada
    call PrintString
    ret

cuenta_repetida: 

    ; Maneja el error de cuenta ya existente
    call MostrarErrorCuentaEx
    ret

max_cuentas:
    call MostrarErrorMax
    ret

CrearCuenta endp


Depositar proc
    
    ; Solicita el numero de cuenta
    mov dx,offset msgCuenta
    call PrintString
    call ReadNumber
    mov bx,ax
    
    ; Busca la cuenta en el sistema
    mov ax,bx
    call BuscarCuenta
    cmp ax,-1
    je errorDeposito
    
    ; AX devuelve el offset de la cuenta encontrada
    mov si,ax
    
    ; Verifica si la cuenta esta activa
    mov bx,si
    shr bx,1
    mov al,cuentaEstado[bx]
    cmp al,1
    jne errorDepositoInactiva
    
    ; Solicita el monto a depositar
    mov dx,offset msgMonto
    call PrintString
    
    ; Guarda SI antes de leer el numero (ReadNumber puede modificar registros)
    push si              
    call ReadNumber
    call ValidarMonto  
    jc monto_deposito_invalido
    pop si               ; restaurar offset correcto
    
    ; Guarda el monto en CX
    mov cx,ax
    
    ; Suma el monto al saldo actual
    mov ax,cuentaSaldo[si]
    add ax,cx
    jc overflow_deposito   ; Detectar overflow (se pasa de 65535)
    
    mov cuentaSaldo[si],ax
    
    ; Muestra mensaje de exito
    mov dx,offset msgDepositoOK
    call PrintString
    ret
    
    overflow_deposito:
    ; Error: ocurrio un desbordamiento al intentar realizar el deposito
    call MostrarErrorOverflow
    ret

monto_deposito_invalido: 
    ; Restaura SI antes de salir si el monto es invalido
    pop si
    ret

errorDepositoInactiva: 
    ; Error: la cuenta esta inactiva
    call MostrarErrorInactiva
    ret

errorDeposito: 
    ; Error: la cuenta no existe
    call MostrarErrorCuenta
    ret

Depositar endp


Retirar proc
    
    ; Solicita el numero de cuenta
    mov dx,offset msgCuenta
    call PrintString
    call ReadNumber
    mov bx,ax
    
    ; Busca la cuenta en el sistema
    mov ax,bx
    call BuscarCuenta
    cmp ax,-1
    je errorRetiro
    
    ; AX devuelve el offset de la cuenta encontrada
    mov si,ax
    
    ; Verifica si la cuenta esta activa
    mov bx,si
    shr bx,1
    mov al,cuentaEstado[bx]
    cmp al,1
    jne errorRetiroInactiva
    
    ; Solicita el monto a retirar
    mov dx,offset msgMonto
    call PrintString
    
    ; Guarda SI antes de leer el numero (ReadNumber puede modificar registros)
    push si              
    call ReadNumber
    call ValidarMonto
    jc monto_retiro_invalido
    pop si               ; restaurar offset correcto
    
    ; Guarda el monto en CX
    mov cx,ax
    
    ; Obtiene el saldo actual
    mov ax,cuentaSaldo[si]  
    
    ; Verifica si hay fondos suficientes
    cmp ax,cx
    jb errorFondos
    
    ; Resta el monto del saldo
    sub ax,cx
    mov cuentaSaldo[si],ax
    
    ; Muestra mensaje de retiro exitoso
    mov dx,offset msgRetiroOK
    call PrintString
    ret

monto_retiro_invalido: 
    ; Restaura SI antes de salir si el monto es inválido
    pop si
    ret

errorFondos:
    ; Error: fondos insuficientes
    call MostrarErrorFondos
    ret

errorRetiroInactiva:
    ; Error: la cuenta está inactiva
    call MostrarErrorInactiva
    ret

errorRetiro: 
    ; Error: la cuenta no existe
    call MostrarErrorCuenta
    ret

Retirar endp

; busca cuenta por num e imprime el saldo en pantalla
ConsultarSaldo proc
    ; recibe numero de cuenta
    mov dx,offset msgCuentaConsulta
    call PrintString
    call ReadNumber
    mov bx,ax
    ; busca la cuenta
    mov ax,bx
    call BuscarCuenta
    ; si no existe
    cmp ax,-1
    je errorConsulta
    ; acomoda el offset en la posicion del saldo
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

; imprime en pantalla reporte completo(cuentas activas, inactivas, mayor y menor saldo)
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
    mov bx,0            
    mov si,0            

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
    shl di,1             
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

    ; imprimir menor saldo
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
; posibles errores
errorCuentaNoEx:
call MostrarErrorCuenta
ret

errorDesactivar:

call MostrarErrorYaInac
ret

DesactivarCuenta endp