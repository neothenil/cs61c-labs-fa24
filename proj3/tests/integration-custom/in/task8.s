addi s0, x0, 200
addi s1, x0, 0x123
slli s1, s1, 20
addi s1, s1, 0x456  # 0x12300456
sw   s1, 0(s0)

lw   t0, 0(s0)

lb   t0, 0(s0)
lb   t1, 1(s0)
lb   t2, 2(s0)
lb   t3, 3(s0)

lh   t0, 0(s0)
lh   t1, 1(s0)
lh   t2, 2(s0)

addi s1, x0, -2040
slli s1, s1, 8
addi s1, s1, 0x8
slli s1, s1, 12
addi s1, s1, 0x80   # 0x80808080
sw   s1, 0(s0)

lw   t0, 0(s0)

lb   t0, 0(s0)
lb   t1, 1(s0)
lb   t2, 2(s0)
lb   t3, 3(s0)

lh   t0, 0(s0)
lh   t1, 1(s0)
lh   t2, 2(s0)

# s1 = 0x80808080, s0 = 200
sw   s1, 80(s0)
lw   a0, 80(s0)

sh   s1, 80(s0)
lw   a0, 80(s0)
sh   s1, 82(s0)
lw   a0, 80(s0)

sb   s1, 80(s0)
lw   a0, 80(s0)
sb   s1, 81(s0)
lw   a0, 80(s0)
sb   s1, 82(s0)
lw   a0, 80(s0)
sb   s1, 83(s0)
lw   a0, 80(s0)
