addi t0, x0, 1
add  t0, t0, t0
addi t1, x0, 2
add  t2, t0, t1
addi t0, x0, -4
add  t2, t2, t0
add  x0, t0, t0

addi t0, x0, 8
addi t1, x0, 1
addi t2, x0, -7
sub  s0, t0, t1
sub  s0, t0, t2

addi t0, x0, -1
addi t1, x0, -2
and  t2, t0, t1
and  t2, x0, t1

addi t0, x0, -1
or   t1, x0, x0
or   t1, t0, x0
or   t1, t0, t0

addi t0, x0, -1
addi t1, x0, 0xff
xor  t2, t0, t1
xor  t0, t0, t0

addi t0, x0, -1
addi t1, x0, 5
sll  t2, t0, t1
addi t1, x0, -1
sll  t2, t0, t1

addi t0, x0, -1
addi t1, x0, 5
srl  t2, t0, t1
addi t1, x0, -1
srl  t2, t0, t1

addi t0, x0, -1
addi t1, x0, 5
sra  t2, t0, t1
addi t1, x0, -1
sra  t2, t0, t1

addi t0, x0, -1
addi t1, x0, 1
slt  t2, t0, t1
slt  t2, t1, t0

addi t0, x0, 16
addi t1, x0, 16
mul  t2, t0, t1
mulh s0, t0, t1
mulhu s1, t0, t1
addi t0, x0, -1
addi t1, x0, 8
mul  t2, t0, t1
mulh s0, t0, t1
mulhu s1, t0, t1
