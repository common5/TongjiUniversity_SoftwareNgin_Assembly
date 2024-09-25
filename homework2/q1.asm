DATA segment
    str   db "?*?=", '$'
    space db "  ", '$'
    endl  db 0dh, 0ah, '$'
DATA ends
CODE segment
    start:     
               ASSUME CS:CODE,DS:DATA
               MOV    AX,DATA            ;将data首地址赋值给AX
               MOV    DS,AX              ;将AX赋值给DS,使DS指向data
               MOV    CX, 9
          
    A:         
               PUSH   CX
               MOV    BL, 1
    B:         
    ;str存放被乘数
               POP    DX                 ;从栈顶取得当前被乘数
               PUSH   DX                 ;DX推回栈中
               ADD    DX, 30H
               MOV    str[0], DL
    ;str存放乘数
               MOV    DX, BX
               ADD    DX, 30H
               MOV    str[2], DL         ;被乘数
    ;输出式子
               LEA    DX,str
               MOV    AH,09H
               INT    21H
    ;做乘法
               POP    AX                 ;从栈顶取得当前被乘数
               PUSH   AX                 ;AX推回栈中
               MUL    BL
               PUSH   CX                 ;CX入栈
               PUSH   BX                 ; BX入栈
    ;输出结果
    output_num:
               XOR    DX, DX
               XOR    CX,CX              ;CX清零
               MOV    BX, 10
               CWD
    string:    
               XOR    DX, DX             ;DX清零
               DIV    BX
               ADD    DX, 30H            ;取ASCII码
               PUSH   DX                 ;DX结果入栈
               INC    CX
               CMP    AX, 0              ;商为0结束循环
               JNE    string
    output:    
               pop    DX
               MOV    AH, 02H            ;输出单字符
               INT    21H
               LOOP   output
               POP    BX                 ;后入先出
               POP    CX
               INC    BX
               LEA    DX, space
               MOV    AH, 09H
               INT    21H
               LOOP   B
               POP    CX
               LEA    DX, endl
               MOV    AH, 09H
               INT    21H
               LOOP   A
    ;程序终止
               MOV    AH,4Ch             ;给AH设置参数4C00h
               int    21h                ;调用4C00h号功能，结束程序
CODE ends
END start