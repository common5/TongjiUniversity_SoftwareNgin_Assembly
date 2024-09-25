ASSUME	 CS:CODE,DS:DATA
;数据段的定义
;--------------------------------------------------
DATA SEGMENT
    INFO  DB 'Input Height of Hanoi(1-6): $'
    MESS  DB 5 DUP (0AH,0DH)
          DB 14 DUP ('              |                       |                       |                ',0AH,0DH)
          DB '   -----------|----------- -----------|----------- -----------|-----------     ',0AH,0DH
          DB '          Tower A                 Tower B                 Tower C              ','$'                 ;
    BIN   DW 6                                                                                                     ;将BIN初始化
    ONE   DW 28                                                                                                    ;,15    	;三个塔
    TWO   DW 76                                                                                                    ;,19
    THREE DW 124                                                                                                   ;,19
DATA ENDS
;-----------------------------------------------------
;代码段的定义
CODE SEGMENT
    START:      
                MOV  AX,DATA                        ;将数据段送到DX
                MOV  DS,AX
                MOV  AX, 0900H
                LEA  DX, INFO
                INT  21H
                MOV  AX, 0100H
                INT  21H
                XOR  AH, AH
                SUB  AL, 30H
                MOV  BIN, AX
    ; CALL DELAY
    ;清屏
                MOV  AX,0600H
                MOV  BH,07H                         ;设置文本颜色为白色
                XOR  CX,CX
                MOV  DX,184FH
                INT  10H
    ;设置光标位置到(0,0)
                MOV  AH,02H
                MOV  BH,0
                MOV  DX,0
                INT  10H

                LEA  DX, MESS                       ;输出MESS
                MOV  AH,09H
                INT  21H

                MOV  AX,0B800H                      ;B800H是显存的起始地址，直接在显存写入，0是因为B800直接输入会被认为是一个标签而非数值
                MOV  ES,AX
    ;显示本身是25行80列，在显存当中，每一个字符都需要一个额外字节来记录它的前景色，背景色，所以对于一行在显存中的偏移量是160
                MOV  DI,160*17+28                   ;偏移量每160是一行，160*7+28实际是第8行，右第15列
                MOV  AX, BIN
                PUSH CX
                MOV  CX, 04H
                INC  AL
    S:          
                MOV  AH, AL
                DEC  AH
                SHL  AH, CL                         ;AH需要左移四位，用来显示为背景色
                CALL RECT
                SUB  DI, 320
                DEC  AL
                CMP  AL,1
                JNE  S
                POP  CX

                PUSH BIN                            ;压栈操作
                PUSH ONE
                PUSH TWO
                PUSH THREE
                CALL HANOI                          ;调用HANOI
		  
                MOV  AH,4CH
                INT  21H

    ;汉诺塔
    HANOI:      
                PUSH AX
                PUSH DX
                PUSH BP
                MOV  BP,SP
                MOV  AX,1
                CMP  AX,WORD PTR [BP+14]
                JE   EQUAL
                JMP  UNEQUAL
    EQUAL:                                          ;若相等执行
                MOV  AX,WORD PTR[BP+12]
                MOV  BX,WORD PTR [BP+8]
                CALL MOVEPLATE
                JMP  EXIT
    UNEQUAL:                                        ;若不相等执行
                MOV  AX,[BP+14]
                SUB  AX,1
                PUSH AX
                PUSH [BP+12]
                PUSH [BP+8]
                PUSH [BP+10]
                CALL HANOI

                MOV  AX,WORD PTR [BP+12]
                MOV  BX,WORD PTR [BP+8]
                CALL MOVEPLATE

                MOV  AX,[BP+14]
                SUB  AX,1
                PUSH AX

                PUSH [BP+10]
                PUSH [BP+12]
                PUSH [BP+8]
                CALL HANOI
    EXIT:       
                POP  BP
                POP  DX
                POP  AX
                RET  8
	  
    ;子程序：绘制矩形
    ;参数：	ES:[DI]矩形中心位置
    ;       AH:颜色
    ;       AL:宽度
    RECT:                                           ;子程序
                PUSH AX
                PUSH BX
                PUSH CX
                PUSH DI
		
                MOV  BL,AH                          ;设置颜色
                MOV  AH,0

                SUB  DI,AX                          ;一个字符是偏移量为2，所以DI需要-两倍盘子宽度
                SUB  DI,AX
                MOV  CX,AX                          ;盘子实际的宽度是两倍AX + 1
                ADD  CX,AX
                ADD  CX,1
    RECT_1:     
                MOV  BYTE PTR ES:[DI+1],BL          ;只需要修改这里的颜色，不需要修改字符，所以是偏移量要+1
                MOV  BYTE PTR ES:[DI+160+1],BL      ;一次性修改两行，盘子的高度为两行
                ADD  DI,2
                LOOP RECT_1
		
    RECT_OVER:  
                POP  DI
                POP  CX
                POP  BX
                POP  AX
                RET
	  
    ;子程序：移动矩形
    ;参数
    ;       AL=[BP+12]
    ;       BL=[BP+8]
    ;       无论什么时候总是[BP+12]移动到[BP+8]
    MOVEPLATE:  
                CALL DELAY
                PUSH AX
                PUSH BX
                PUSH CX
                PUSH DX
					
                MOV  DL,AL                          ;AL的值是[BP+12],是柱子的中心位置
                MOV  DH,0
                MOV  SI,DX
                MOV  CX,0
    MOVEPLATE_3:
    ;    CALL DELAY
                MOV  DL,ES:[SI+1]
                CMP  DL,07H                         ;根据前景色判断是不是到达盘子了，借此找到最上层的位置
                JNE  MOVEPLATE_2
                CMP  CX,19                          ;如果等于19，说明这个柱子已经空了
                JE   MOVEPLATE_2
                ADD  SI,160
                ADD  CX,1
                JMP  MOVEPLATE_3
    MOVEPLATE_2:
                SUB  SI,22                          ;移动到柱子的最左侧
	
                MOV  DL,BL                          ;
                MOV  DH,0
                MOV  DI,DX
                MOV  CX,0
    MOVEPLATE_4:
                MOV  DL,ES:[DI+1]
                CMP  DL,07H                         ;根据前景色判断是不是到达盘子了，借此找到最上层的位置
                JNE  MOVEPLATE_5
                CMP  CX,19
                JE   MOVEPLATE_5
                ADD  DI,160
                ADD  CX,1
                JMP  MOVEPLATE_4
    MOVEPLATE_5:
                SUB  DI,22
                SUB  DI,320
		
                MOV  CX,23
    MOVEPLATE_1:
    ;把源柱上的颜色字节写入到目标柱上的颜色字节位置去
                MOV  AL,ES:[SI+1]
                MOV  ES:[DI+1],AL
                MOV  AL,ES:[SI+160+1]
                MOV  ES:[DI+160+1],AL
    ;因为源柱上的盘子已经移过去了，需要将前景色替换成DOSBOX的缺省值，也就是7
                MOV  BYTE PTR ES:[SI+1],111B
                MOV  BYTE PTR ES:[SI+160+1],111B
                ADD  DI,2
                ADD  SI,2
                LOOP MOVEPLATE_1
				
                POP  DX
                POP  CX
                POP  BX
                POP  AX
                RET

    ;子程序：调用INT21H，AH=07H进行无回显的单字符读入，达到暂停的目的
    DELAY:      
                PUSH AX
                PUSH BX
                PUSH CX
                PUSH DX
                XOR  BX,BX
                XOR  CX,CX
                XOR  DX,DX
                MOV  AH, 07H
                INT  21H
                POP  DX
                POP  CX
                POP  BX
                POP  AX
                RET
		
CODE ENDS
;---------------------------------------
END   START