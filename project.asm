[org 0x0100]
jmp start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Old_Timer:dd 0
Old_Isr:dd 0
P1_Score:dw 0
P2_Score:dw 0
Msg_After_P1:db 'Win The Game!!!!'
Msg_After_P2:db 'Win The Game!!!!'
prompt1: db 'Enter name for player 1: ',0
prompt2: db 'Enter name for player 2: ',0
player1:times 32 db 0,0  
player2:times 32 db 0,0  
sizeP1:dw 0
sizeP2:dw 0
Top_Left_Paddle:dw 35
Top_Right_Paddle:dw 45
Bottom_Left_Paddle:dw 35
Bottom_Right_Paddle:dw 45
currRow:dw 23   ;for ball
currCol:dw 40   ;for ball
space:dw ' ',0 ;for setup ->moving cursor at end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


point_X:dw 1    ;for ball movement
point_Y:dw 1    ;for ball movement
;(1,1)->topRight ->l1
;(0,1)->topLeft  ->l2
;(1,0)->bottomRight ->l4
;(0,0)->bottomLeft ->l3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(0,1)                                (1,1);
;                                          ;
;                                          ;
;(0,0)              *                 (1,0);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
currX:dw 0    ;helper var to store location of paddle (return var of screenLocation)->help in clearing the screen  
printcount:dw 1    ;1 for creation and 2 for movement
Compare_Position:dw 0 ;helper var to indicate that have we compare the points
;->when its 0 means just print donot have to compare and when 1 have to compare
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HOOKING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hooking:
;;;;;;;;;;;;;;;;;;;;;;;;;;;; STROING INT 8 ;;;;;;;;;;;;;;;;;;;;;;;;
xor ax,ax
mov es,ax
mov ax,[es:8*4]
mov [Old_Timer],ax
mov ax,[es:8*4 + 2]
mov [Old_Timer+2],ax
;;;;;;;;;;;;;;;;;;;;;;;;;;; STORING INT 9 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov ax,[es:9*4]
mov [Old_Isr],ax
mov ax,[es:9*4+2]
mov [Old_Isr+2],ax
xor ax, ax
mov es, ax 

;;;;;;;;;;;;;;;;;;;;;;;;;;;HOOKING INT 8 AND 9;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cli 
mov word [es:8*4], Ball_Movement 
mov [es:8*4+2], cs 
mov word [es:9*4],Moving_Paddle
mov [es:9*4+2],cs
sti 
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setUp:
mov ah,13h
mov al,1
mov bh,0
mov bl,0x07
mov cx,1
mov dh,25
mov dl,79
push cs
pop es
mov bp,space
int 10h
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; UNHOOKING INT 8 AND 9 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Unhooking:
xor ax,ax
mov es,ax
mov ax,[Old_Timer]
mov [es:8*4],ax
mov ax,[Old_Timer+2]
mov [es:8*4+2],ax
mov ax,[Old_Isr]
mov [es:9*4],ax
mov ax,[Old_Isr+2]
mov [es:9*4+2],ax
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; GETTING USER NAMES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getData:
push cs
pop ds
;;;;;;;;;;;;;;;;;;;;;;; PROMPT 1 ;;;;;;;;;;;;;;;;;;;;;;;;;

mov ah,0x13
mov al,0x01
mov bl,0x07
mov bh,0x00
mov cx,25
mov dh,11
mov dl,23
push cs
pop es  
mov bp,prompt1
int 10h


;;;;;;;;;;;;;;;Taking input
mov si,player1
mov word [sizeP1], 0
mov cx, 32
input1:
mov ah,0x00
int 16h
cmp al,13
je endInput

mov [cs:si],al
inc si
inc word [sizeP1]

mov ah,0x0e
int 10h
jmp input1

endInput:
mov word [cs:si],0x20
inc si
inc word [sizeP1]

mov ah,0x13
mov al,0x01
mov bl,0x07
mov bh,0x00
mov cx,25
mov dh,12
mov dl,23
push cs
pop es  

mov bp,prompt2
int 10h

;;;;;;;;;;;;;;;;;;;;;Input 2
mov si,player2
mov word [sizeP2], 0
mov cx, 32
input2:
mov ah,0x00
int 16h
cmp al,13
je endInput2


mov [si],al
inc si
inc word [sizeP2]

mov ah,0x0e
int 10h
jmp input2

endInput2:
mov word [cs:si],0x20
inc si
inc word [sizeP2]

ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CLEAR SCREEN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clearscreen:
mov ax, 0xb800 
mov es, ax 
mov di, 0 
nextchar:
mov word [es:di], 0x0720 
add di, 2 
cmp di, 4000 
jne nextchar 
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;COL (X)
;ROW (Y)
;;;;;;;;;;;;;;;;;;;;;;; HELPER FUNCTION TO GET LOCATION BY PUSHING ROW AND COLUMN ;;;;;;;;;;;;;;;;;;;;
screenlocation:
push bp
mov bp, sp
push ax
xor ax,ax
mov al, 80 
mul byte[bp+6] ; multiply with y 
add ax, [bp+4] ; add x position 
shl ax, 1 
mov word[currX],ax
pop ax
pop bp
ret 4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PADDLE 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Creating_paddle1:
pusha
push cs
pop ds
push word 0
push word[Top_Left_Paddle]
call screenlocation
mov di,word[currX]
mov ax,0xb800
mov es,ax
mov cx,10
Creation_Paddle1:
mov word[es:di],0x7020
add di,2
loop Creation_Paddle1
popa
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HELPER DELAY FUNCTION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delay:
push cx
mov cx, 80 ;Delay Value!!!
delay_loop1:
push cx
mov cx, 0xFFFF
delay_loop2:
loop delay_loop2
pop cx
loop delay_loop1
pop cx
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PADDLE 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Creating_paddle2:
pusha
push cs
pop ds
push word 24
push word[Bottom_Left_Paddle]
call screenlocation
mov di,word[currX]
mov cx,10
mov ax,0xb800
mov es,ax
Creation_Paddle2:
mov word[es:di],0x7020
add di,2
loop Creation_Paddle2
popa
ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BALL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Creating_Ball:
push cs
pop ds
xor ax,ax
mov al, 80 
mul byte[currRow] 
add ax, [currCol] 
shl ax, 1 	
mov di,ax
mov ax,0xb800 
mov es,ax
mov word[es:di],0x072A 
ret
Ball_Movement:
pusha
push cs
pop ds
cmp word[printcount],2
jne exit11
call clearscreen   ;clearing (paddles , ball)
call setUp
mov word[printcount],0	
l1:
cmp word[point_Y], 1
jne L3
cmp word[point_X], 1
jne L2
dec word[currRow]       ;topRight case   
inc word[currCol]          
cmp word[currCol], 79      
jne l1case1   ;collision
mov word[Compare_Position],1
mov word[point_X], 0  
jmp l1case1
exit11:  
jmp Exit
L3:
jmp l3
L2:
jmp l2
l1case1:
cmp word[currRow], -1      
je l1case2           
cmp word[currRow], 0     
jne exit1
xor ax,ax
xor bx,bx
mov ax,word[Top_Left_Paddle]
mov bx,word[Top_Right_Paddle]
cmp word[currCol],bx
jg exit1
cmp word[currCol],ax
jl exit1
add word[currRow], 2       
mov word[point_Y], 0          
jmp Exit
below1:
cmp word[Compare_Position],1
jne exit1
mov word[point_X],1
jmp Exit
l1case2:
inc word[P2_Score]
call clearscreen
call Printing_Score
call delay
call setUp
mov word[Top_Left_Paddle],35
mov word[Top_Right_Paddle],45
mov word[Bottom_Left_Paddle],35
mov word[Bottom_Right_Paddle],45
xor ax, ax
mov ax, word[Bottom_Left_Paddle]
add ax, word[Bottom_Right_Paddle]
shr ax, 1
mov word[currRow], 23      
mov word[currCol], ax      
jmp Exit

exit1:
jmp Exit
l2:
dec word[currRow]
dec word[currCol]
cmp word[currCol],0
jne l2case1
mov word[Compare_Position],1
mov word[point_X],1
l2case1:
cmp word[currRow],-1
je l2case2
cmp word[currRow],0
jne exit2
xor ax,ax
xor bx,bx
mov ax,word[Top_Left_Paddle]
mov bx,word[Top_Right_Paddle]
cmp word[currCol],bx
jg below2
sub ax,2
cmp word[currCol],ax
jl below2
add word[currRow],2
mov word[point_Y],0
jmp Exit
below2:
cmp word[Compare_Position],1
jne exit2
mov word[point_X],0
jmp Exit
l2case2:
inc word[P2_Score]
call clearscreen
call Printing_Score
call delay
call setUp
mov word[Top_Left_Paddle],35
mov word[Top_Right_Paddle],45
mov word[Bottom_Left_Paddle],35
mov word[Bottom_Right_Paddle],45
xor ax,ax
mov ax,word[Bottom_Left_Paddle]
add ax,word[Bottom_Right_Paddle]
shr ax,1
mov word[currRow],23
mov word[currCol],ax
exit2:
jmp Exit
l3:
cmp word[point_X],0
je l3next
jmp l4
l3next:
inc word[currRow]
dec word[currCol]
cmp word[currCol],0
jne l3case1
mov word[Compare_Position],1
mov word[point_X],1
l3case1:
cmp word[currRow],25
je l3case2
cmp word[currRow],24
jne exit3
xor ax,ax
xor bx,bx
mov ax,word[Bottom_Left_Paddle]
mov bx,word[Bottom_Right_Paddle]
cmp word[currCol],bx
jg below3
sub ax,2
cmp word[currCol],ax
jl below3
sub word[currRow],2
mov word[point_Y],1
jmp Exit
below3:
cmp word[Compare_Position],1
jne exit3
mov word[point_X],0
jmp Exit
l3case2:
inc word[P1_Score]
call clearscreen
call Printing_Score
call delay
call setUp
mov word[Top_Left_Paddle],35
mov word[Top_Right_Paddle],45
mov word[Bottom_Left_Paddle],35
mov word[Bottom_Right_Paddle],45
xor ax,ax
mov ax,word[Top_Left_Paddle]
add ax,word[Top_Right_Paddle]
shr ax,1
mov word[currRow],1
mov word[currCol],ax
exit3:
jmp Exit
l4:
inc word[currRow]
inc word[currCol]
cmp word[currCol],79
jne l4case1
mov word[Compare_Position],1
mov word[point_X],0
l4case1:
cmp word[currRow],25
je l4case2
cmp word[currRow],24
jne Exit
xor ax,ax
xor bx,bx
mov ax,word[Bottom_Left_Paddle]
mov bx,word[Bottom_Right_Paddle]
cmp word[currCol],bx
jg below4
cmp word[currCol],ax
jl below4
sub word[currRow],2
mov word[point_Y],1
jmp Exit
below4:
cmp word[Compare_Position],1
jne Exit
mov word[point_X],1
jmp Exit
l4case2:
inc word[P1_Score]
call clearscreen
call Printing_Score
call delay
call setUp
mov word[Top_Left_Paddle],35
mov word[Top_Right_Paddle],45
mov word[Bottom_Left_Paddle],35
mov word[Bottom_Right_Paddle],45
xor ax,ax
mov ax,word[Top_Left_Paddle]
add ax,word[Top_Right_Paddle]
shr ax,1
mov word[currRow],1
mov word[currCol],ax
Exit:
inc word[printcount]
mov word[Compare_Position],0
call Creating_Ball
call Creating_paddle1
call Creating_paddle2
;call Printing_Score
mov al, 0x20
out 0x20, al 
popa
iret 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNCTION TO DISPLAY SCORES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Printing_Score:
push cs
pop ds

;P1 NAME
mov cx, word [sizeP1]  
mov si, player1
push di
mov di, 1820            
cld                     
print_loop1:
lodsb                   
mov ah, 0x07           
stosb                 
inc di
loop print_loop1       
pop di

; Player 1 points
push 11      ; Row number
mov ax,[sizeP1]
add ax,30
push ax      ; Column number
push word [P1_Score]  ; Number to display
call printnum

; P2 NAME
mov cx, word [sizeP2]  
mov si, player2
push di
mov di, 1980            
cld                    
print_loop2:
lodsb                  
mov ah, 0x07            
stosb                 
inc di
loop print_loop2      
pop di

mov ax,[sizeP2]
add ax,30
push 12      ; Row number
push ax      ; Column number
push word[P2_Score]  ; Number to display
call printnum
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HELPER FUNCTION TO PRINT NUMBER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;NUMBER TO DISPLAY
;COL
;ROW
printnum:
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov di, 80 
mov ax, [bp+8] 
mul di
mov di, ax 
add di, [bp+6] 
shl di, 1 
add di, 8 
mov ax, 0xb800
mov es, ax
mov ax, [bp+4] 

mov bx, 16 
mov cx, 4 

nextdigit:
mov dx, 0 
div bx 
add dl, 0x30 
cmp dl, 0x39 
jbe skipalpha 
add dl, 7 

skipalpha:
mov dh, 0x07 
mov [es:di], dx
sub di, 2 
loop nextdigit 
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PADDLE MOVEMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Moving_Paddle: 
pusha
push cs
pop ds
push word 0xb800
pop es
xor ax,ax
in al,0x60
cmp word[point_Y],1
jne PaddleB ;0
UpperLeftMove:
;LEFT PRESSED 0x4B
;RIGHT PRESSED 0x4D
cmp al,0x4B
jne UpperRightMove
cmp word[Top_Left_Paddle],0
je End1
dec word [Top_Left_Paddle]
dec word [Top_Right_Paddle]
jmp End1

UpperRightMove:
;LEFT PRESSED 0x4B
;RIGHT PRESSED 0x4D
cmp al,0x4D
jne End1
cmp word[Top_Right_Paddle],80
je End1
inc word [Top_Right_Paddle]
inc word [Top_Left_Paddle]
End1:
jmp End
PaddleB:
;LEFT PRESSED 0x4B
;RIGHT PRESSED 0x4D
cmp al,0x4B
jne DownRightMove
DownLeftMove:
cmp word[Bottom_Left_Paddle],0
je End2
dec word [Bottom_Left_Paddle]
dec word [Bottom_Right_Paddle]
End2:
jmp End
DownRightMove:
;LEFT PRESSED 0x4B
;RIGHT PRESSED 0x4D
cmp al,0x4D
jne End1
cmp word[Bottom_Right_Paddle],80
je End1
inc word [Bottom_Right_Paddle]
inc word [Bottom_Left_Paddle]
End:
popa
mov al,0x20
out 0x20,al
iret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; START FUNCTION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start:
call clearscreen

call getData
call Creating_paddle1
call Creating_paddle2

call Hooking
Termination:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DISPLAYING SCORE WHOSE WIN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmp word[P1_Score],5
jne nextcheck
call clearscreen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P1 WINS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov cx, word [sizeP1]   
mov si, player1

mov di, 1820           
cld                     
print_loop11:
lodsb                  
mov ah, 0x07          
stosb                 
inc di
loop print_loop11       

mov cx, 16  
mov si, Msg_After_P1

cld                     
msg1:
lodsb                  
mov ah, 0x07            
stosb                 
inc di
loop msg1      

jmp ProperTermination
nextcheck:
cmp word[P2_Score],5
jne Termination

call clearscreen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; P2 WINS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov cx, word [sizeP2]   
mov si, player2
mov di, 1820            
cld                     
print_loop22:
lodsb                  
mov ah, 0x07           
stosb                 
inc di
loop print_loop22      
mov cx, 16 
mov si, Msg_After_P2
cld                   
msg2:
lodsb                  
mov ah, 0x07           
stosb                  
inc di
loop msg2      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TERMINATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProperTermination:
call Unhooking
mov ax,0x4c00
int 0x21