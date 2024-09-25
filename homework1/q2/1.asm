;结果存在寄存器
CODE segment
    start: 
           MOV  AX, 0
           MOV  BX, 1
           MOV  CX, 100
    L:     
           ADD  AX, BX
           INC  BX         ;BX自增
           LOOP L
           
           XOR  CX, CX     ;CX清零
           MOV  BX, 10
    ;此部分从低到高诸位获取结果诸位上的值, CX用于记录位数
    string:
           XOR  DX, DX     ;清空DX
           DIV  BX         ;(DX:AX)除以10
           INC  CX         ;CX自增
           ADD  DX, 30H    ;取ASCII码
           PUSH DX         ;余数入栈
           CMP  AX,0       ;商为0则结束循环
           JNE  string
    ;从栈中逐个取出字符并输出
    output:
           pop  DX
           MOV  AH, 02H    ;输出单字符
           INT  21H
           LOOP output
    ;程序终止
           MOV  AH,4Ch     ;给AH设置参数4C00h
           int  21h        ;调用4C00h号功能，结束程序
CODE ENDS
END start