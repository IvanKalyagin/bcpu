        .section .text
        .globl _start;

        # Тест для проверки addi

_start:
        addi x1, x1, 3
        slti x20, x1, 2040
        slti x21, x1, -8
        slti x22, x1, 1
        sltiu x20, x1, 2040
        sltiu x21, x1, -8
        sltiu x22, x1, 1

        addi x3, x3, -6
        slti x20, x3, 2040
        slti x21, x3, -8
        slti x22, x3, 1
        sltiu x20, x3, 2040
        sltiu x21, x3, -8
        sltiu x22, x3, 1

        addi x4, x4, 0
        slti x20, x4, 2040
        slti x21, x4, -8
        slti x22, x4, 1
        sltiu x20, x4, 2040
        sltiu x21, x4, -8
        sltiu x22, x4, 1

        addi x5, x5, 8
        xori x20, x5, 2040
        xori x21, x5, -8
        xori x22, x5, 1
        xori x20, x6, 0
        xori x21, x6, 2047
        xori x22, x6, -2047

        addi x6, x6, 16
        ori x20, x6, 2040
        ori x21, x6, -8
        ori x22, x6, 1
        ori x20, x6, 0
        ori x21, x6, 2047
        ori x22, x6, -2047

        addi x10, x10, 15
        andi x20, x10, 2040
        andi x21, x10, -8
        andi x22, x10, 1
        andi x20, x10, 0
        andi x21, x10, 2047
        andi x22, x10, -2047

        addi x11, x11, 1
        slli x20, x11, 8
        slli x21, x11, 2
        slli x22, x11, 1
        slli x20, x11, 0
        slli x21, x11, 20
        slli x22, x11, 31

        addi x12, x12, 1
        srli x20, x12, 8
        srli x21, x12, 3
        srli x22, x12, 1
        srli x20, x12, 0
        srli x21, x12, 20
        srli x22, x12, 31

        addi x13, x13, 1
        srai x20, x13, 8
        srai x21, x13, 2
        srai x22, x13, 1
        srai x20, x13, 0
        srai x21, x13, 20
        srai x22, x13, 31
        
lp2: j lp2

        .section .data
