;结果存储在寄存器
DATA segment
       result DW 0
DATA ENDS
CODE segment
       start:     
                  ASSUME CS:CODE,DS:DATA
                  MOV    AX,DATA               ;将data首地址赋值给AX
                  MOV    DS,AX                 ;将AX赋值给DS,使DS指向data
                  MOV    CX, 100
       ;循环求和
       L:         
                  ADD    result, CX
                  LOOP   L
       ;数值转字符串准备工作
       output_num:
                  MOV    DX, 0
                  XOR    CX,CX                 ;CX清零
                  MOV    AX, result            ;result赋值给AX
                  MOV    BX, 10
                  CWD
       string:    
                  XOR    DX, DX                ;DX清零
                  DIV    BX
                  ADD    DX, 30H               ;取ASCII码
                  PUSH   DX                    ;DX结果入栈
                  INC    CX
                  CMP    AX, 0                 ;商为0结束循环
                  JNE    string
       output:    
                  pop    DX
                  MOV    AH, 02H               ;输出单字符
                  INT    21H
                  LOOP   output
       ;程序终止
                  MOV    AX,4C00H
                  INT    21H
CODE ENDS
END start