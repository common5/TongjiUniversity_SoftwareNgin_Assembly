#include <stdio.h>
int main()
{
    int n;
    printf("请输入n的值, 1 <= n <= 10000\n");
    scanf("%d", &n);
    int sum = 0;
    asm volatile(
        ".intel_syntax noprefix\n\t"
        "MOV EAX, %0\n\t"
        "MOV EBX, %1\n\t"
        "MOV ECX, 1\n\t"
        "L0:\n\t"
        "CMP ECX, EBX\n\t"
        "JL L1\n\t"
        "JMP L2\n\t"
        "L1:\n\t"
        "ADD EAX, ECX\n\t"
        "INC ECX\n\t"
        "JMP L0\n\t"
        "L2:\n\t"
        "MOV %0, EAX\n\t"
        ".att_syntax\n\t"
        : "=r"(sum)
        : "r"(n)
        : "%ecx", "%eax");
    // for (int i = 1; i <= n; i++)
    // {
    //     sum += i;
    // }
    printf("从1到n的和为: %d", sum);
    return 0;
}