.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Error checks
    addi t1, a1, -1
    blt t1, x0, exit_error
    addi t1, a2, -1
    blt t1, x0, exit_error
    addi t1, a4, -1
    blt t1, x0, exit_error
    addi t1, a5, -1
    blt t1, x0, exit_error
    bne a2, a4, exit_error

# s3 = a0;
# s4 = a1;
# s5 = a2;
# s6 = a3;
# s7 = a4;
# s8 = a5;
# s9 = a6;
# for (int s0 = 0; s0 < s4; s0++) {
#   for (int s1 = 0; s1 < s8; s1++) {
#     s2 = s0 * s5;
#     a0 = &s3[s2];
#     a1 = &s6[s1];
#     a2 = s5;
#     a3 = 1;
#     a4 = s8;
#     a0 = dot(a0, a1, a2, a3, a4);
#     t0 = s0 * s8 + s1;
#     s9[t0] = a0;
#   }
# }

    # Prologue
    addi sp, sp, -44
    sw ra, 40(sp)
    sw s0, 36(sp)
    sw s1, 32(sp)
    sw s2, 28(sp)
    sw s3, 24(sp)
    sw s4, 20(sp)
    sw s5, 16(sp)
    sw s6, 12(sp)
    sw s7, 8(sp)
    sw s8, 4(sp)
    sw s9, 0(sp)

    mv s3, a0
    mv s4, a1
    mv s5, a2
    mv s6, a3
    mv s7, a4
    mv s8, a5
    mv s9, a6

    li s0, 0

outer_loop_start:
    bge s0, s4, outer_loop_end
    li s1, 0

inner_loop_start:
    bge s1, s8, inner_loop_end
    mul s2, s0, s5
    slli t1, s2, 2
    add a0, t1, s3
    slli t1, s1, 2
    add a1, t1, s6
    mv a2, s5
    li a3, 1
    mv a4, s8
    jal dot
    mul t0, s0, s8
    add t0, t0, s1
    slli t0, t0, 2
    add t0, t0, s9
    sw a0, 0(t0)

    addi s1, s1, 1
    j inner_loop_start

inner_loop_end:
    addi s0, s0, 1
    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw ra, 40(sp)
    lw s0, 36(sp)
    lw s1, 32(sp)
    lw s2, 28(sp)
    lw s3, 24(sp)
    lw s4, 20(sp)
    lw s5, 16(sp)
    lw s6, 12(sp)
    lw s7, 8(sp)
    lw s8, 4(sp)
    lw s9, 0(sp)
    addi sp, sp, 44

    jr ra
    
exit_error:
    li a0, 38
    j exit
