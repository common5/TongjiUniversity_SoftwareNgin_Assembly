public Disp, space, endl

CODE segment
space PROC far
              MOV    CX, DX
    pt:       
              MOV    DX, 20H
              MOV    AX, 0200H
              INT    21H
              LOOP   pt
              RET
space ENDP
endl PROC far
              MOV    DX, 0DH
              MOV    AX, 0200H
              INT    21H
              MOV    DX, 0AH
              MOV    AX, 0200H
              INT    21H
              RET
endl ENDP
Disp PROC far
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
              POP    AX           ;将原来的DX弹出到AX中
              MOV    BX, 6
              MUL    BX
              POP    BX           ;将原来的AX弹出到BX
              ADD    AX, BX       ;DX:AX + BX
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
              JNE    toString     ;SI不为0则继续
              CMP    DI, 0
              JNE    toString     ;SI为0但是DI不为0则继续
              JE     output_rd    ;都为0就输出
    output_rd:
              MOV    BP, CX       ;准备工作, CX移动到BP, (因为栈后续需要使用，入栈会出错)
    output:   
              pop    DX
              MOV    AH, 02H
              INT    21H
              LOOP   output
              MOV    DX, 16
              SUB    DX, BP
              CALL   space
              RET
DISP ENDP
    start:    
              ASSUME CS:CODE
              MOV    AX, 4c00h
              INT    21h
CODE ends
end start