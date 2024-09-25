DATA segment
    table db 7,2,3,4,5,6,7,8,9             ;9*9表数据
          db 2,4,7,8,10,12,14,16,18
          db 3,6,9,12,15,18,21,24,27
          db 4,8,12,16,7,24,28,32,36
          db 5,10,15,20,25,30,35,40,45
          db 6,12,18,24,30,7,42,48,54
          db 7,14,21,28,35,42,49,56,63
          db 8,16,24,32,40,48,56,7,72
          db 9,18,27,36,45,54,63,72,81
    info  db "x  y", 0DH, 0AH, '$'
    space db "  ", '$'
    err   db "    error", 0DH, 0AH, '$'
    endl  db 0DH, 0AH, '$'
DATA ENDS
CODE segment
    start:     
               ASSUME CS:CODE,DS:DATA
               MOV    AX,DATA            ;将data首地址赋值给AX
               MOV    DS,AX              ;将AX赋值给DS,使DS指向data
               LEA    DX, info
               MOV    AH, 09H
               INT    21H
               MOV    CX, 9
               MOV    AX, 1
               MOV    SI, 0
    A:         
               PUSH   CX
               PUSH   AX
               MOV    BX, 1
               MOV    CX, 9
    B:         
               XOR    DX, DX
               MOV    DL, table[SI]
               MUL    BL
               CMP    AX, DX
               JNE    output_err
               JMP    continue
    output_err:
               POP    DX                 ; //取被乘数AX
               PUSH   DX
               ADD    DX, 30H
               MOV    AH, 02H
               INT    21H
               LEA    DX, space
               MOV    AH, 09H
               INT    21H
               MOV    DX, BX
               ADD    DX, 30H
               MOV    AH, 02H
               INT    21H
               LEA    DX, err
               MOV    AH, 09H
               INT    21H
    continue:  
               POP    AX
               PUSH   AX
               INC    BX
               INC    SI
               LOOP   B
               POP    AX
               INC    AX
               POP    CX
               LOOP   A
    ;程序终止
               MOV    AH,4Ch             ;给AH设置参数4C00h
               int    21h                ;调用4C00h号功能，结束程序
CODE ends
END start