.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    # Prologue
    addi sp, sp, -40
    sw ra, 36(sp)
    sw s0, 32(sp)
    sw s1, 28(sp)
    sw s2, 24(sp)
    sw s3, 20(sp)
    sw s4, 16(sp)
    sw s5, 12(sp)
    sw s6, 8(sp)
    sw s7, 4(sp)
    sw s8, 0(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    li t0, 5
    bne s0, t0, argc_error

    # Read pretrained m0
    addi sp, sp, -24
    addi a0, s1, 4
    lw a0, 0(a0)
    addi a1, sp, 20  # 20(sp) for row number of m0
    addi a2, sp, 16  # 16(sp) for col number of m0
    jal read_matrix
    mv s3, a0        # s3 for matrix m0

    # Read pretrained m1
    addi a0, s1, 8
    lw a0, 0(a0)
    addi a1, sp, 12  # 12(sp) for row number of m1
    addi a2, sp, 8   # 8(sp)  for col number of m1
    jal read_matrix
    mv s4, a0        # s4 for matrix m1

    # Read input matrix
    addi a0, s1, 12
    lw a0, 0(a0)
    addi a1, sp, 4   # 4(sp) for row number of input
    addi a2, sp, 0   # 0(sp) for col number of input
    jal read_matrix
    mv s5, a0        # s5 for input matrix

    # Compute h = matmul(m0, input)
    lw t0, 20(sp)    # row number of h
    lw t1, 0(sp)     # col number of h
    mul a0, t0, t1
    slli a0, a0, 2   # number of bytes for h
    jal malloc
    beq a0, x0, malloc_error
    mv s6, a0        # s6 for h
    mv a0, s3
    lw a1, 20(sp)
    lw a2, 16(sp)
    mv a3, s5
    lw a4, 4(sp)
    lw a5, 0(sp)
    mv a6, s6
    jal matmul

    # Compute h = relu(h)
    mv a0, s6
    lw t0, 20(sp)
    lw t1, 0(sp)
    mul a1, t0, t1
    jal relu

    # Compute o = matmul(m1, h)
    lw t0, 12(sp)    # row number of o
    lw t1, 0(sp)     # col number of o
    mul a0, t0, t1
    slli a0, a0, 2   # number of bytes for o
    jal malloc
    beq a0, x0, malloc_error
    mv s7, a0        # s7 for o
    mv a0, s4
    lw a1, 12(sp)
    lw a2, 8(sp)
    mv a3, s6
    lw a4, 20(sp)
    lw a5, 0(sp)
    mv a6, s7
    jal matmul

    # Write output matrix o
    addi a0, s1, 16
    lw a0, 0(a0)
    mv a1, s7
    lw a2, 12(sp)
    lw a3, 0(sp)
    jal write_matrix

    # Compute and return argmax(o)
    mv a0, s7
    lw t0, 12(sp)
    lw t1, 0(sp)
    mul a1, t0, t1
    jal argmax
    mv s8, a0  # s8 for argmax(o)

    # If enabled, print argmax(o) and newline
    bne s2, x0, finish
    jal print_int
    li a0, '\n'
    jal print_char

finish:
    # free m0
    mv a0, s3
    jal free
    # free m1
    mv a0, s4
    jal free
    # free input
    mv a0, s5
    jal free
    # free h
    mv a0, s6
    jal free
    # free o
    mv a0, s7
    jal free
    # free local vars on stack
    addi sp, sp, 24

    mv a0, s8

    # Epilogue
    lw ra, 36(sp)
    lw s0, 32(sp)
    lw s1, 28(sp)
    lw s2, 24(sp)
    lw s3, 20(sp)
    lw s4, 16(sp)
    lw s5, 12(sp)
    lw s6, 8(sp)
    lw s7, 4(sp)
    lw s8, 0(sp)
    addi sp, sp, 40

    jr ra

malloc_error:
    li a0, 26
    j exit

argc_error:
    li a0, 31
    j exit
