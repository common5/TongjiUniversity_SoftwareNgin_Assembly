DATA segment
      str  db 13 dup(?), '$'
      endl db 0dh,0ah,'$'
DATA ends
CODE segment
      start:
            ASSUME CS:CODE,DS:DATA
            MOV    AX,DATA              ;将data首地址赋值给AX
            MOV    DS,AX                ;将AX赋值给DS,使DS指向data
            MOV    SI, 00H
            MOV    CX,13
            MOV    BL,'a'
      La:   
            MOV    str[SI], BL
            ADD    BL,1
            ADD    SI,1
            LOOP   La
      ;输出str
            LEA    DX, str
            MOV    AH,09H
            INT    21H
      ;输出换行
            LEA    DX, endl
            MOV    AH,09H
            INT    21H
      ;还原数据
            MOV    CX, 13
            MOV    SI, 0
      Lb:   
            MOV    str[SI],BL
            ADD    BL,1
            ADD    SI,1
            LOOP   Lb
      ;输出str
            LEA    DX,str
            MOV    AH,09H
            INT    21H
      ;程序终止
            MOV    AH,4Ch               ;给AH设置参数4C00h
            int    21h                  ;调用4C00h号功能，结束程序
CODE ends
END start