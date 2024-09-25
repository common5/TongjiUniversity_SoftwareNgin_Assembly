DATA segment
    info  db 'input a number, ranging from 1 to 100, your input should end with enter$'
    endl  db 0dH, 0aH,'$'
    einfo db 'not a number$'
    oinfo db 'your input is: $'
    XXX   db 'y$'
DATA ENDS
CODE segment
    start:          
                    ASSUME CS:CODE,DS:DATA
                    MOV    AX, DATA           ;将data首地址赋值给AX
                    MOV    DS, AX             ;将AX赋值给DS,使DS指向data

                    LEA    DX, info
                    MOV    AH, 09H
                    INT    21H
    ;输出换行
                    LEA    DX, endl
                    MOV    AH, 09H
                    INT    21H
    ;逐字符读取缓冲区
                    MOV    BX, 0              ;存储结果
                    MOV    CX, 0              ;存储中间值
                    MOV    DL, 10
    input:          
                    MOV    AH, 01H
                    INT    21H
                    CMP    AL, 0DH            ;回车则退出
                    JE     before_toString
                    CMP    AL, 30H
                    JB     error
                    CMP    AL,39H
                    JA     error
                    SUB    AX, 30H
                    XOR    AH, AH             ;清空AH
                    MOV    CX, AX             ;AX数暂存到CX
                    MOV    AX, BX             ;结果放入AX
                    MUL    DL                 ;AX乘10
                    ADD    AX, CX             ;
                    MOV    BX, AX
                    JMP    input
    error:          
                    LEA    DX, endl
                    MOV    AH, 09H
                    INT    21H
                    LEA    DX, einfo
                    MOV    AH, 09H
                    INT    21H
                    JMP    terminal
    before_toString:
                    MOV    AX, BX             ;BX中存储的结果移动到AX
                    XOR    BX, BX
                    MOV    BX, 10
                    XOR    CX, CX
    ;逐字符入栈
    toString:       
                    XOR    DX, DX             ;清零DX
                    DIV    BX
                    INC    CX
                    ADD    DX, 30H
                    push   DX
                    CMP    AX, 0
                    JNE    toString
    ;输出output提示
                    LEA    DX, oinfo
                    MOV    AH, 09H
                    INT    21H
                    XOR    DX, DX
    output:         
                    pop    DX
                    MOV    AH, 02H
                    INT    21H
                    LOOP   output
    ;终止
    terminal:       
                    MOV    AX, 4C00H
                    INT    21H
CODE ENDS
END start
