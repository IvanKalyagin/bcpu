        .section .text
        .globl _start;

        # Тест для проверки addi

_start:
        addi x1, x1, 3
        addi x2, x2, 2040
        addi x3, x3, -6
        addi x3, x3, 10
        addi x4, x4, 0
        addi x5, x5, 50
        addi x5, x5, -50
        addi x6, x6, 5
        addi x6, x6, -50
        addi x6, x6, 100
        addi x10, x10, 2047 # 0x7FFFFFFF
        addi x11, x10, 1
        addi x12, x10, -1
        addi x15, x15, 208 # 0x80000000
        addi x16, x15, 1
        addi x17, x15, -1
lp2: j lp2

        .section .data
