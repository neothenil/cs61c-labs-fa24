         addi s1, x0, 1
         addi s0, x0, -1
label5:  beq  x0, x0, label1
label6:  bgeu s0, x0, label8
label4:  bge  x0, s1, label5
         beq  x0, x0, label6
label3:  beq  s1, s1, label4
label10: beq  s0, s0, end
label2:  bge  s1, x0, label3
label9:  bge  s1, s0, label10
label1:  beq  x0, x0, label2
label8:  bgeu s1, s1, label9
         beq  s1, s1, label9
end:     addi s0, x0, 2
