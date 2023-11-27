DATA segment
    yearh  dw 0000H
    yearl  dw 0000H
    monthh dw 0000H
    monthl dw 0000H
    dayh   dw 0000H
    dayl   dw 0000H
    info   db 'What is the date?',0dH, 0aH, '$'
    haha   db 'hahaha', '$'
    endl   db 0dH, 0aH,'$'
DATA ends
CODE segment
    Enter MACRO 
        LEA DX, endl
        MOV AX, 0900H
        INT 21H
    ENDM
    fslash Macro
        MOV DX, 47
        MOV AX, 0200H
        INT 21H
    ENDM
    Disp Macro
    LOCAL toString
    LOCAL save
    LOCAL continue
    LOCAL output
                XOR    BX, BX
                XOR    CX, CX
    ;要输出的数放到SI:DI
                MOV    SI, DX
                MOV    DI, AX
                         
                XOR    CX, CX
    ;逐字符入栈
    toString:   
    ;取原数
                MOV    AX, DI
                MOV    DX, SI
    ;求余数, 由于商数会存在溢出, 只能通过计算的方式对商数求解. (DX:AX) / 10 = (6 * DX + AX) / 10 + DX * 6553, 余数则是(6 * DX + AX) / 10的余数
                INC    CX
    ;1.算DX*6553, 并将结果存入SI:DI
                PUSH   AX
                PUSH   DX
                MOV    AX, DX
                XOR    DX, DX
                MOV    BX, 6553
                MUL    BX
                MOV    SI, DX
                MOV    DI, AX
                POP    AX                 ;将原来的DX弹出到AX中
                MOV    BX, 6
                MUL    BX
                POP    BX                 ;将原来的AX弹出到BX
                ADD    AX, BX             ;DX:AX + BX
                ADC    DX, 0
                MOV    BX, 10
    ;因为DX, AX均小于等于65535, 所以6 * DX + AX <= 65535 * 7, 所以(6 * DX + AX) / 10必然小于65535, 不可能发生溢出
                DIV    BX
                ADD    DI, AX
                ADC    SI, 0
    ;余数在DX中，加30H后入栈
                ADD    DX, 30H
                PUSH   DX

                JMP    continue

    save:       
                MOV    SI, DX
                MOV    DI, AX
    continue:   
                CMP    SI, 0
                JNE    toString           ;SI不为0则继续
                CMP    DI, 0
                JNE    toString           ;SI为0但是DI不为0则继续
                JE     output             ;都为0就输出
    output:     
                pop    DX
                MOV    AH, 02H
                INT    21H
                LOOP   output
    ENDM
    GetNum Macro high, low
    LOCAL Input
    LOCAL return
                XOR    AX, AX
                XOR    BX, BX
                XOR    CX, CX
                XOR    DX, DX
                XOR    SI, SI
                XOR    DI, DI
                XOR    BP, BP
                MOV    BP, 10             ;BP为常量10
    ;结果存储于SI, BX中, BP用于存储乘数, CX存储读入的结果, DX:AX存储上一次结果低16位乘10后的结果, AX部分可以直接放回BX, DX部分需要存入DI
    ;然后进行高16位乘10, 此处不再考虑溢出, 因为如果还有溢出的话说明值超过了32位整数, 不予以考虑, 将AX部分与DI相加即可得到实际结果的高16位
    Input:
    ;读入单个字符
                MOV    AX, 0100H
                INT    21H
    ;判断是否为数字，不是数字则返回已经读入的数
                CMP    AL, 30H
                JB     return
                CMP    AL, 39H
                JA     return
    ;清空AX高8位，减'0'后将结果送到CX中
                XOR    AH, AH
                SUB    AX, 30H
                MOV    CX, AX             ;读入结果存入CX
    ;开始低16位的计算
                MOV    AX, BX             ;先考虑上一次结果的低16位部分
                MUL    BP                 ;此时乘过10后, 结果在DX:AX中,
             
                ADD    AX, CX             ;低16位乘过以后就可以直接把结果加到里面了
                ADC    DX, 0              ;此处使用进位加法是因为在AX足够大会进位，不进位会导致结果错误必须要考虑
                MOV    BX, AX             ;低16位的结果存到BX中
                MOV    DI, DX             ;此处DX的部分先放到DI中
    ;开始高16位的计算
                MOV    AX, SI
                MUL    BP
                ADD    AX, DI
                MOV    SI, AX
                JMP    Input
             
    return:     
                MOV    low, BX             ; 最终的结果为high:low
                MOV    high, SI
                ENDM
    



    start:   
             ASSUME CS:CODE,DS:DATA
             MOV    AX,DATA            ;将data首地址赋值给AX
             MOV    DS,AX              ;将AX赋值给DS,使DS指向data
    GetNum monthh, monthl
    GetNum dayh, dayl
    GetNum yearh, yearl
    Enter
    MOV DX, monthh
    MOV AX, monthl
    Disp         
    fslash    
    MOV DX, dayh
    MOV AX, dayl
    Disp           
    fslash    
    MOV DX, yearh
    MOV AX, yearl
    Disp           
    terminal:
             MOV    AX, 4C00H
             INT    21H
CODE ends
END start