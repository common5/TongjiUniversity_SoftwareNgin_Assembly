#include <stdio.h>
extern int getSum(int n);
int main()
{
    int n;
    printf("请输入n的值, 1 <= n <= 10000\n");
    scanf("%d", &n);
    int sum = getSum(n);
    printf("%d", sum);
}