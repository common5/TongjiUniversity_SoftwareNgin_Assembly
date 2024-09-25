DATA segment
    str  db 13 dup(?), '$'
    endl db 0dh,0ah,'$'
DATA ends
CODE segment
    start:
          ASSUME CS:CODE,DS:DATA
          MOV    AX,DATA            ;将data首地址赋值给AX
          MOV    DS,AX              ;将AX赋值给DS,使DS指向data
          MOV    SI,00H
          MOV    CX, 00H
          MOV    BL,'a'
    ;第一行
    L:    
          MOV    str[SI],BL
          ADD    BL,1
          ADD    SI,1
          CMP    SI, 13
          JNE    L
          ADD    CX,1
    ;输出str
          LEA    DX,str
          MOV    AH, 09h
          INT    21H
    ;输出endl
          LEA    DX, endl
          MOV    AH,09H
          INT    21H
    ;第二行，直接复用第一行
          MOV    SI, 00H
          CMP    CX,1
          JE     L
    ;程序终止
          MOV    AX,4C00H
          INT    21H
CODE ends
END start