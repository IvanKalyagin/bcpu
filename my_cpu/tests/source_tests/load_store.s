        .section .text
        .globl _start;

        # Тест для проверки load store
    len = 8 #Размер массива
	enroll = 4 #Количество обрабатываемых элементов за одну итерацию
	elem_sz = 4 #Размер одного элемента массива
_start:
	addi x20, x0, len/enroll
	la x1, _x
loop:	
	lw x2, 0(x1)
	add x31, x31, x2
	lw x2, 4(x1)
	add x31, x31, x2
	lw x2, 8(x1)
	add x31, x31, x2
	lw x2, 12(x1)
	add x31, x31, x2
	addi x1, x1, elem_sz*enroll
	addi x20, x20, -1
	bne x20, x0, loop
	addi x31, x31, 1
    sw x2, 0(x31)
    sw x2, 64(x31)
    sw x1, 128(x31)
    sw x31, 16(x31)
    
lp2: j lp2

        .section .data
_x:	.4byte 0x1
	.4byte 0x2
	.4byte 0x3
	.4byte 0x4
	.4byte 0x5
	.4byte 0x6
	.4byte 0x7
	.4byte 0x8
    .4byte 0x9
	.4byte 0xA
	.4byte 0xB
	.4byte 0xC
	.4byte 0xD
	.4byte 0xE
    .4byte 0xF

_y:	.4byte 12
	.4byte 155
	.4byte 256
	.4byte 1024
	.4byte -76