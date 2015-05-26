; Pong
; Rubén Cuadra    
 
;-----Macros-----  

Print MACRO row, column, color    
   mov Ah, 02h
   mov Bh, 0h
   mov Dh, row
   mov Dl, column
   INT 10h 
   mov Ah, 09
   mov Al, ' '
   mov Bl, color
   mov Cx, 1h
   INT 10h 
Print endm 

PrintChar MACRO row, column, char
   mov Ah, 02h
   mov Bh, 0h
   mov Dh, row
   mov Dl, column
   INT 10h
   mov Al, char
   add Al, 30h   
   mov bl, 0Fh
   mov ah, 09h
   mov Cx, 1h
   int 10h      
PrintChar endm

Delete Macro row, column
   mov Ah, 02h
   mov Bh, 0h
   mov Dh, row
   mov Dl, column
   int 10h 
   mov Ah, 09
   mov Al, ' '
   mov Bl, 0h
   mov Cx, 1h
   int 10h 
Delete ENDM

VIDEO MACRO MSG, COL, REN, COLOR
    LOCAL AB
    MOV BH, 00h
    MOV BL, 0FH   ;COLOR FONDO BLANCO LETRA NEGRA
    MOV SI, 00h      ;APUNTADOR DE MENSAJE (25 CARACTERES)
    MOV DI, 01h      ;CONTADOR DE RENGLONES
    MOV DH, REN
    MOV DL, COL
AB: MOV AH, 02h     ;UBICO MI CURSOR EN LA POSICION (COL, REN)
    INT 10H
    MOV AH, 09h
    MOV CX, 01h
    MOV AL, MSG[SI]
    INT 10H     ;IMPRIMO LA LETRA QUE SE DEBE
    INC SI   ;MUEVO LA NUEVA LETRA
    INC DL   ;LA COLUMNA A LA DERECHA
    MOV AX, DI  ;MUEVE EL CONTADOR DE RENGLONES
    MOV AH, 05h
    MUL AH
    CMP SI, AX   ;CADA CINCO CARACTERES VA A MODIFICARSE
    JNZ AB
    INC DH      ;INCREMENTO RENGLON
    INC DI      ;INCREMENTO CONTADOR
    CMP DI, 06h
    MOV DL, COL
    JNZ AB
VIDEO ENDM 

;-----Programa principal-----  

org 100h
jmp INICIO
       
;-----Datos-----
   
   LBTop       equ 0900h
   LBCenterU   equ 0901h
   LBCenter    equ 0902h
   LBCenterD   equ 0903h
   LBBottom    equ 0904h
   RBTop       equ 0905h
   RBCenterU   equ 0906h
   RBCenter    equ 0907h
   RBCenterD   equ 0908h
   RBBottom    equ 0909h
   
   renglon     equ 090Ah
   columna     equ 090Bh
   
   tiempo      equ 090Ch 
   
   ;MENSAJES DE NUMERITOS (0-7)
   CERO DB ' 000 0   00   00   0 000 ',0
   UNO DB ' 11    1    1    1  11111',0
   DOS DB '22222    2222222    22222',0
   TRES DB '33333    3  333    333333',0
   CUAT DB '4   44   444444    4    4',0
   CINC DB '555555    55555    555555',0
   SEIS DB '6    6    666666   666666',0
   SIET DB '77777    7    7    7    7',0  
   CLEAR db '                         ',0
   
   x db 1
   y db ?
   delayC dw ?
   delayD dw ?
   
   scoreP1 db 0
   scoreP2 db 0
                             
 
INICIO:
   mov Ah,03h
   int 10h    
   mov Bh, 00
   mov Cx, 01  

;Esconde el cursor
   mov ah,1
   mov cx,2b0bh
   int 10h 
        
        
RESTART: 
;Revisar si algun jugador ha ganado
   call CheckEnd

;Imprimir en pantalla los numeros grandes y quitarlos
   call PARscore  

;Tiempo es 0
   mov [tiempo], 0h
      
;Posiciones de inicio de la barra izquierda
   mov [LBTop],10
   mov [LBCenterU],11
   mov [LBCenter],12  
   mov [LBCenterD],13
   mov [LBBottom],14
   
;Posiciones de inicio de la barra derecha    
   mov [RBTop],10
   mov [RBCenterU],11
   mov [RBCenter],12  
   mov [RBCenterD],13
   mov [RBBottom],14
   
;Posicion y valores de inicio de la pelota
   mov [renglon],12
   mov [columna],39
   mov y,2
   mov delayC, 03h  ;0Fh
   mov delayD, 01h  ;0A150h   

;Imprime las barras y la pelota
   Print [LBTop],0,0c0h
   Print [LBCenterU],0,0c0h   
   Print [LBCenter],0,0c0h
   Print [LBCenterD],0,0c0h   
   Print [LBBottom],0,0c0h
   Print [RBTop],79,90h   
   Print [RBCenterU],79,90h   
   Print [RBCenter],79,90h   
   Print [RBCenterD],79,90h   
   Print [RBBottom],79,90h
   Print [renglon],[columna],0FFh
        
   CICLO:  
    ;Imprimir puntajes
        PrintChar 2, 4, [scoreP1]
        PrintChar 2, 75, [scoreP2]
      
    ;Espera alguna tecla del jugador
        mov ah, 01h
        int 16h
        jz Continuar
        mov Ah,00
        int 16h
        CALL Move   ;Mueve la barra correspondiente arriba o abajo

    Continuar:
      ;Revisa y disminuye delay
         call delayTime
      
      ;Espera determinado tiempo para mover la pelota
         mov ah, 86h
         mov cx, delayC
         mov dx, delayD
         int 15h            
      
      Bola:
         ;Mueve la pelota
         Delete [renglon],[columna]
         call SlopeX
         call SlopeY
         Print [renglon],[columna],0FFh           

   JMP CICLO          
  
RET
          
;-----Procedimientos-----  

Move PROC
    CMP Al,'q'
      JNZ LeftD    
      Call LeftUp
    LeftD:    
    CMP Al,'a'
      JNZ RightU     
      CALL LeftDown
    RightU:
    CMP Ah,48h
      JNZ RightD    
      Call RightUp
    RightD:    
    CMP Ah,50h
      JNZ ENDD       
      CALL RightDown
    ENDD:ret
Move ENDP    

LeftUp PROC
    cmp [LBTop],0
      jz ENDLU
    DEC [LBTop]
    Print [LBTop],0,0c0h
    Delete [LBBottom],0
    DEC [LBCenterU]
    DEC [LBCenter]
    DEC [LBCenterD]
    DEC [LBBottom]
    ENDLU:ret
LeftUp ENDP

LeftDown PROC
    cmp [LBBottom],24
      jz ENDLD
    INC [LBBottom]
    Print [LBBottom],0,0c0h
    Delete [LBTop],0
    INC [LBCenterD]
    INC [LBCenter]
    INC [LBCenterU]
    INC [LBTop]
    ENDLD:ret
LeftDown ENDP

RightUp PROC
    cmp [RBTop],0
      jz ENDRU
    DEC [RBTop]
    Print [RBTop],79,90h
    Delete [RBBottom],79
    DEC [RBCenterU]
    DEC [RBCenter]
    DEC [RBCenterD]
    DEC [RBBottom]
    ENDRU:ret
RightUp ENDP

RightDown PROC
    cmp [RBBottom],24
      jz ENDRD
    INC [RBBottom]
    Print [RBBottom],79,90h
    Delete [RBTop],79
    INC [RBCenterD]
    INC [RBCenter]
    INC [RBCenterU]
    INC [RBTop]
    ENDRD:ret
RightDown ENDP

SlopeX PROC
    mov bl,[renglon]
    cmp x,0          ;Compara si la pelota va a la izquierda(0) o a la derecha(1)
      jnz x1:        
      cmp [columna],1  ;Compara si ya va a chocar con las barras
         jnz c1
         dec [columna]
         
         ;Compara con cuál barra chocará
         cmp bl,[LBTop]
            jnz e1
            mov y,0  
            jmp rd
         e1:
         cmp bl,[LBCenterU]
            jnz e2
            mov y,1
            jmp rd
         e2:
         cmp bl,[LBCenter]
            jnz e3
            mov y,2
            jmp rd
         e3:
         cmp bl,[LBCenterD]
            jnz e4
            mov y,3
            jmp rd
         e4:
         cmp bl,[LBBottom]
            jnz c1
            mov y,4
         
         ;Rebota la pelota a la derecha   
         rd:
            inc [columna]
            inc x     
            jmp ENDX
      
      ;Continua moviendo la pelota a la izquierda
      c1:
         cmp [columna],0  ;Compara si está hasta la izquierda de la ventana
            jnz c2      
            inc scoreP2   ;Punto a favor del Jugador2
            mov x,0       ;Saca Jugador2 en la siguiente ronda
            call clr
         c2:
         dec [columna]
         jmp ENDX
         
    x1:
      cmp [columna],78  ;Compara si ya va a chocar con las barras
         jnz c3
         ;inc [columna]
         
         ;Compara con cuál barra chocará
         cmp bl,[RBTop]
            jnz e5
            mov y,0  
            jmp ri
         e5:
         cmp bl,[RBCenterU]
            jnz e6
            mov y,1
            jmp ri
         e6:
         cmp bl,[RBCenter]
            jnz e7
            mov y,2
            jmp ri
         e7:
         cmp bl,[RBCenterD]
            jnz e8
            mov y,3
            jmp ri
         e8:
         cmp bl,[RBBottom]
            jnz c3
            mov y,4
         
         ;Rebota la pelota a la izquierda   
         ri:
            dec [columna]
            dec x
            add [tiempo], 2
            jmp ENDX
      
      ;Continua moviendo la pelota a la derecha
      c3:
         cmp [columna],79  ;Compara si está hasta la derecha de la ventana
            jnz c4
            inc scoreP1    ;Punto a favor del Jugador1
            mov x,1        ;Saca Jugador1 en la siguiente ronda
            call clr
         c4:
         inc [columna]
         
    ENDX:ret
SlopeX ENDP

SlopeY PROC

    ;Sube la pelota dos renglones
    y0:
    cmp y,0
      jnz y1
      cmp [renglon],0
         jnz r0
         mov y,4
         jmp y4
      r0:
         dec [renglon]
         cmp [renglon],0
            jnz r1
            mov y,4
            jmp y4
         r1:
            dec [renglon]
            jmp ENDY
            
    ;Sube la pelota un renglón  
    y1:
    cmp y,1
      jnz y2
      cmp [renglon],0
         jnz r2
         mov y,3
         jmp y3
      r2:
         dec [renglon]
         jmp ENDY
    
    ;Mueve la pelota en linea horizontal     
    y2:
    cmp y,2
      jnz y3
      jmp ENDY
    
    ;Baja la pelota un renglón
    y3:
    cmp y,3
      jnz y4
      cmp [renglon],24
         jnz r3
         mov y,1
         jmp y1
      r3:
         inc [renglon]
         jmp ENDY
    
    ;Baja la pelota dos renglones
    y4:
    cmp [renglon],24
      jnz r4
      mov y,0
      jmp y0
    r4:
      inc [renglon]
      cmp [renglon],24
         jnz r5
         mov y,0
         jmp y0
      r5:
         inc [renglon]
         jmp ENDY
   
    ENDY:ret
SlopeY ENDP

;Limpia la ventana
clr PROC
   Delete [LBTop],0
   Delete [LBCenterU],0
   Delete [LBCenter],0
   Delete [LBCenterD],0
   Delete [LBBottom],0
   Delete [RBTop],79
   Delete [RBCenterU],79
   Delete [RBCenter],79
   Delete [RBCenterD],79
   Delete [RBBottom],79
   jmp RESTART
   ret
clr ENDP             

delayTime PROC
   cmp [tiempo], 4h
   jz disminuirDelay
   cmp [tiempo], 9h
   jz disminuirDelay
   jmp salir
   
   disminuirDelay:
       dec delayC
       inc [tiempo]
   salir:    
       ret
delayTime endp        

PARscore PROC
    CMP scoreP1, 0
    JNZ U
    VIDEO CERO, 30, 7
    JMP NEXT
U:  CMP scoreP1, 1
    JNZ D
    VIDEO UNO, 30, 7
    JMP NEXT
D:  CMP scoreP1, 2
    JNZ T
    VIDEO DOS, 30, 7
    JMP NEXT
T:  CMP scoreP1, 3
    JNZ C
    VIDEO TRES, 30, 7
    JMP NEXT
C:  CMP scoreP1, 4
    JNZ CI
    VIDEO CUAT, 30, 7
    JMP NEXT
CI:  CMP scoreP1, 5
    JNZ S
    VIDEO CINC, 30, 7
    JMP NEXT
S:  CMP scoreP1, 6
    JNZ SIE
    VIDEO SEIS, 30, 7
    JMP NEXT
SIE:  CMP scoreP1, 7
    VIDEO SIET, 30, 7

NEXT:  
    CMP scoreP2, 0
    JNZ U2
    VIDEO CERO, 43, 7
    JMP SIGUE
U2:  CMP scoreP2, 1
    JNZ D2
    VIDEO UNO, 43, 7
    JMP SIGUE
D2:  CMP scoreP2, 2
    JNZ T2
    VIDEO DOS, 43, 7
    JMP SIGUE
T2:  CMP scoreP2, 3
    JNZ CUA2
    VIDEO TRES, 43, 7
    JMP SIGUE
CUA2:  CMP scoreP2, 4
    JNZ CI2
    VIDEO CUAT, 43, 7
    JMP SIGUE
CI2:  CMP scoreP2, 5
    JNZ S2
    VIDEO CINC, 43, 7
    JMP SIGUE
S2:  CMP scoreP2, 6
    JNZ SIE2
    VIDEO SEIS, 43, 7
    JMP SIGUE
SIE2:  CMP scoreP2, 7
    VIDEO SIET, 43, 7

SIGUE:
    mov ah, 86h
    mov cx, 20h
    int 15h

    VIDEO CLEAR, 30, 7
    VIDEO CLEAR, 43, 7

 
    RET
PARscore ENDP            

CheckEnd PROC
    cmp scoreP1, 7
    jnz check2
    jmp checkEqusTru
    check2:
        cmp scoreP2, 7
        jnz finalProc
    
    cmp scoreP2, 7
    jnz check1
    jmp checkEqusTru
    check1:
        cmp scoreP1, 7
        jnz finalProc
    
checkEqusTru:
    ;reempezar juego
    mov scoreP1, 0
    mov scoreP2, 0       
    
finalProc:    
    ret
CheckEnd ENDP