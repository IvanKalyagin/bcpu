        .section .text
        .globl _start;

        # Тест для проверки АЛУ, используется только операция сложения, и сравнения

_start:
        addi x1, x1, 10
	add x2, x0, x0
lp:
        addi x2, x2, 1
        addi x15, x15, 5
        addi x3, x0, 2
        add x7, x15, x3
        bne x1, x2, lp
        addi x7, x7, 1
lp2: j lp2

        .section .data
