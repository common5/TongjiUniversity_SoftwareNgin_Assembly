CODE segment
    start: 
           MOV  CX, 100
           MOV  DX, 0
           push DX
    ;循环求和
    L:     
           pop  DX
           ADD  DX,CX
           push DX
           LOOP L
    ;数值转字符串准备工作
           pop  DX
           MOV  AX, DX      ;DX赋值给AX
           XOR  DX, DX
           XOR  CX,CX       ;CX清零
           MOV  BX, 10
           CWD
    string:
           XOR  DX, DX      ;DX清零
           DIV  BX
           ADD  DX, 30H     ;取ASCII码
           PUSH DX          ;DX结果入栈
           INC  CX
           CMP  AX, 0       ;商为0结束循环
           JNE  string
    output:
           pop  DX
           MOV  AH, 02H     ;输出单字符
           INT  21H
           LOOP output
    ;程序终止
           MOV  AX,4C00H
           INT  21H
CODE ENDS
END start