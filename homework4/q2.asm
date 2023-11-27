Extern  Disp:Far
Extern  space:Far
Extern  endl:Far
; Include Disp.asm

DATA SEGMENT
     ;以下是表示21年的21个字符串, 长84, 存储于0-83
          DB '1975', '1976', '1977', '1978', '1979', '1980', '1981', '1982', '1983'
          DB '1984', '1985', '1986', '1987', '1988', '1989', '1990', '1991', '1992'
          DB '1993', '1994', '1995'
        
     ;以下是表示21年公司总收的21个DWORD型数据, 长84, 存储于84-167
          DD 16, 22, 382, 1356, 2390, 8000, 16000, 24486, 50065, 97479, 140417, 197514
          DD 345980, 590827, 803530, 1183000, 1843000, 2759000, 3753000, 4649000, 5937000
        
     ;以下是表示21年公司雇员人数的21个WORD型数据， 长42, 存储于168-209
          DW 3, 7, 9, 13, 28, 38, 130, 220, 476, 778, 1001, 1442, 2258, 2793, 4037, 5635, 8226
          DW 11542, 14430, 15257, 17800

DATA ENDS

TABLE SEGMENT
           DB 21 DUP('year summ ne ?? ')
TABLE ENDS

CODE SEGMENT
     ;要输出的数存到DX:AX传入
     START:       
                  ASSUME CS:CODE, DS:DATA, ES:TABLE
                  MOV    AX, DATA                       ;将DATA首地址赋值给AX
                  MOV    DS, AX                         ;将AX赋值给DS, 使DS指向DATA
                  MOV    AX, TABLE
                  MOV    ES, AX
                  MOV    BX, 0
                  MOV    BP, 0
                  MOV    DI, 0
                  MOV    CX, 21
     WriteInTable:
     ;逐字节写入年份
                  MOV    AL, [BX]
                  MOV    ES:[BP], AL
                  MOV    AL, [BX + 1]
                  MOV    ES:[BP + 1], AL
                  MOV    AL, [BX + 2]
                  MOV    ES:[BP + 2], AL
                  MOV    AL, [BX + 3]
                  MOV    ES:[BP + 3], AL
                  MOV    ES:[BP + 4], 24H
     ;写入总收入
                  MOV    AX, [BX + 84]                  ;须注意, DD类型的数据低位在前, 高位在后
                  MOV    DX, [BX + 86]                  ;将DATA段中的收入提取作为被除数
                  MOV    ES:[BP + 5], AX                ; 总收入的存储开始于第6字节, 第五字节用于分隔, 存储于5:6, 与7:8
                  MOV    ES:[BP + 7], DX                ;存储仍然与原来一致, 低在前, 高在后
     ;写入员工数量
                  MOV    AX, [DI + 168]                 ;数据段中员工数量的记录开始于168, 偏移量为DI
                  MOV    ES:[BP + 10], AX               ;table段中, 员工数量存储开始于10(第11字节)
                  MOV    AX, [BX + 84]
     ;写入人均收入
                  DIV    WORD PTR DS:[DI + 168]         ; 16位除法, AX为商, DX为余数, 取整计算, 舍弃余数
                  MOV    ES:[BP + 13], AX               ;TABLE段中, 人均收入存储开始于13(第14字节)
     ;偏移量++
                  ADD    BX, 4                          ;年份与收入长度为4, 共用同一个偏移量寄存器是可行的, 只需要在读取收入时额外+84即可
                  ADD    DI, 2                          ;员工数量每个长度为2, 所以每次+2
                  ADD    BP, 16                         ;table段每行长度为16, 所以每次都+16
                  LOOP   WriteInTable
    
                  MOV    CX, 21                         ;循环次数
     ;8086的逻辑段开始地址必须是16的倍数, 已知Data段结束于209, 因而table段的地址应该是刚好大于209的16的倍数, 所以是224
                  MOV    BX, 224
     ;打印table
     printable:   
     ;输出年份
                  LEA    DX, [BX]
                  MOV    AX, 0900H
                  INT    21H
                  MOV    DX, 12
                  PUSH   CX
                  CALL   space
                  POP    CX
     ;输出总收入
                  XOR    DX, DX
                  MOV    AX, [BX + 5]
                  MOV    DX, [BX + 7]                   ;注意低在前, 高在后
                  PUSH   BX
                  PUSH   CX                             ;只有BX, CX两个寄存器中的值是会被用到的, 所以只要这两个进栈保存即可
     ;    call    display
                  call   Disp
                  POP    CX
                  POP    BX
     ;输出员工数量
                  MOV    AX, [BX + 10]
                  XOR    DX, DX
                  PUSH   BX
                  PUSH   CX
                  call   Disp
                  POP    CX
                  POP    BX
     ;输出人均收入
                  MOV    AX, [BX + 13]
                  XOR    DX, DX
                  PUSH   BX
                  PUSH   CX
                  call   Disp
                  POP    CX
                  POP    BX
     ;计算偏移量变化
                  ADD    BX, 16                         ;一行长度为16, 要访问下一行就该+16
     ;输出换行
                  CALL   endl                           ;endl只使用了AX, DX, 与此处过程中使用的寄存器不存在冲突, 无需保存任何寄存器中的值
                  LOOP   printable
     Terminal:    
                  MOV    AX, 4c00h
                  INT    21h

CODE ENDS
END START