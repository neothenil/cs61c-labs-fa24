addi t0, x0, 1
addi t0, x0, 2047
addi t1, t0, -2048
addi t1, t1, 1
addi x0, x0, 5

addi t2, x0, -1
andi t2, t2, -2
andi t2, t2, 0

addi s0, x0, -2
ori  s0, s0, 1
ori  s0, s0, 0
addi s0, s0, 0

addi s1, x0, -1
xori s1, s1, 0x555
addi s1, x0, 0

addi t0, x0, -1
slli t1, t0, 5
slli t2, t0, 31

addi t0, x0, -1
srli t1, t0, 5
srli t2, t0, 31

addi t0, x0, -1
srai t1, t0, 5
srai t2, t0, 31

addi t0, x0, 1
slti t1, t0, 2
slti t1, t0, 0

addi t0, x0, -1
slti t1, t0, 0
slti t1, t0, -2048
