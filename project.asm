[org 100h]
jmp start

;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Size_Of_Paddle:dw 9 
Attribute_Of_Paddle:dw 0x7720
start_of_Paddle1:dw 0
start_of_Paddle2:dw 0
Paddle:dw 0               ;1 refers that CreatePaddle call is for Paddle 1 and vice versa ;used in clearing Paddle
oldISR: dd 0
ball: dw 0
old_timer: dd 0
ball_move_counter: dw 0

resident:                                              ;;;;;;;;;;; SAVE BLOCK IN MEMORY ;;;;;;;;;;;;;;;;;;
Setting_Paddle:
push bp
mov bp,sp
push ax
mov ax,[bp+4]
mov [Paddle],ax
pop ax
pop bp
ret 2


Clearing_Paddle:
push bp
mov bp,sp
mov di,[bp+4]
mov word es,[bp+6]
mov cx,[Size_Of_Paddle]
mov ax,0x0720
rep stosw
pop bp
ret 4


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HELPING FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LEFT_P:
mov di,[start_of_Paddle2]
cmp di,3840
je endISR

push 0xb800
push di
call Clearing_Paddle

mov di,[start_of_Paddle2]
sub di,2
push 0xb800
push di
push word 2


call Creating_Paddle

jmp endISR

RIGHT_P1:
mov di,[start_of_Paddle1]
cmp di,0
je endISR

push 0xb800
push di
call Clearing_Paddle

mov di,[start_of_Paddle1]
sub di,2
push 0xb800
push di
push word 1
call Creating_Paddle
jmp endISR

RIGHT_P:
mov di,[start_of_Paddle2]
cmp di,3982
je endISR


push 0xb800
push di
call Clearing_Paddle

mov di,[start_of_Paddle2]
add di,2
push 0xb800
push di
push word 2

call Creating_Paddle
jmp endISR

LEFT_P1:
mov di,[start_of_Paddle1]
cmp di,142
je endISR

push 0xb800
push di
call Clearing_Paddle

mov di,[start_of_Paddle1]
add di,2
push 0xb800
push di
push word 1

call Creating_Paddle
jmp endISR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF HELPING FUNCTIONS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PADDLE MOVEMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Moving_Paddle:
push ax
push bx
push cx
push dx
push es
push ds

mov ax, 0xb800              
mov es, ax
mov ax, cs
mov ds, ax	

in al,0x60

;LEFT PRESSED 0x4B
;RIGHT PRESSED 0x4D
;A PRESSED 0x1E ->RIGHT
;DS PRESSED 0x1F ->LEFT

cmp al,0x4B
je LEFT_P

cmp al,0x4D
je RIGHT_P

cmp al ,0X1E
je RIGHT_P1

cmp al,0x1F
je LEFT_P1

endISR:
pop ds
pop es
pop dx
pop cx
pop bx
pop ax

mov al,0x20
out 0x20,al
;jmp far [cs:oldISR]
iret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HOOKING  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hooking:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INT 8 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
push ds
mov ax,cs
mov ds,ax

push es
xor ax,ax
mov es,ax
mov ax,[es:8*4]
mov [old_timer],ax

mov ax,[es:8*4+2]
mov [old_timer+2],ax
pop es

push ds
cli
xor ax,ax
mov ds,ax
mov word [ds:8*4],Ball_Movement
mov word [ds:8*4+2],cs
pop ds
sti
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INT 9 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

xor ax ,ax
mov es,ax
mov ax , [es:9*4]
mov [oldISR],ax

mov ax , [es:9*4+2]
mov [oldISR+2],ax
cli
mov word [es:9*4],Moving_Paddle
mov word [es:9*4+2],cs
sti
pop ds
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PADDLE CREATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Memory
;di
Creating_Paddle:
push bp
mov bp,sp
mov ax,[bp+4]
mov di,[bp+6]

;updating start index of paddle
mov [Paddle],ax
cmp ax ,1
je Its_Paddle1

;Paddle 2
mov [start_of_Paddle2],di
jmp working

Its_Paddle1:
mov [start_of_Paddle1],di

working:
mov word es,[bp+8]
mov cx,[Size_Of_Paddle]
mov ax,[Attribute_Of_Paddle]
rep stosw
pop bp
ret 6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BALL CREATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Memory
;location
Creating_Ball:
push bp
mov bp,sp
mov word es,[bp+6]
mov di,[bp+4]
mov word [es:di],0x072A
mov [ball],di
pop bp
ret 4

clearScreen:
pusha
    mov ax, 0xb800          
    mov es, ax
    mov di, 0
    mov ax, 0x0720          
    mov cx, 2000            
    rep stosw
popa
    ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            InitialScreen   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InitialScreen:
pusha
call clearScreen
;Intial Position | Center
mov di,160   ;total screen
shr di,1     ;divide ;80
sub di,12    ;sub half of size of paddle to make it at center

;;;;;;;;Function Call with Parameters
push 0xb800
push di
push word 1
call Creating_Paddle

mov di,160   ;total screen
shr di,1     ;divide ;80
sub di,12    ;sub half of size of paddle to make it at center
add di,3840  ;for last row

;;;;;;;;Function Call with Parameters
push 0xb800
push di
push word 2
call Creating_Paddle

mov di,[start_of_Paddle2]  ;getting Position of paddle 2
add di,8                   ;setting ball at Center
sub di,160  			   ;setting ball above the paddle 2

;;;;;;;;Function Call with Parameters
push es
push di
call Creating_Ball

popa
ret

start:
call InitialScreen
call Hooking

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ENDING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 mov dx , resident
 add dx,15
 shr dx,4
 mov ax,0x3100
 int 21h
 
 
 Ball_Movement:
    pushf                 
    pusha                 
    push ds
    push es
    
    ; Setup data segment
    mov ax, cs
    mov ds, ax

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DELAY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov ax, [ball_move_counter]  ; Load counter value
    cmp ax, 2                 ;;;;;;;;;;;;;;;;;;; BALL MOVEMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    je move_ball

    jmp chain_interrupt

move_ball:
push word 0xb800
pop es

;;;;;;;;;;;;;;;; Loading ball location ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov di, [ball]
    mov cx, 24

backing:
    mov ax, 0x0720
    stosw
    sub di, 2
    sub di, 158
    mov ax, 0x072A
    stosw
    sub di, 2
	
	;;;;;;;;;;;; Updating location OF BALL i.e Ball has to print ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov [ball],di

    ; Reset counter
    mov ax, 0
    mov [ball_move_counter], ax  

chain_interrupt:
inc word [ball_move_counter]
    pop es
    pop ds
    popa
    popf

    jmp far [cs:old_timer]

