.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    # Prologue
    # if (a2 < 1) exit(36);
    addi t1, a2, -1
    bge t1, x0, check_a3
    li a0, 36
    j exit
check_a3:
    # if (a3 < 1) exit(37);
    addi t1, a3, -1
    bge t1, x0, check_a4
    li a0, 37
    j exit
check_a4:
    # if (a4 < 1) exit(37);
    addi t1, a4, -1
    bge t1, x0, loop_init
    li a0, 37
    j exit

# t4 = 0;
# for (int t0 = 0; t0 < a2; t0++) {
#   t1 = t0 * a3;
#   t2 = t0 * a4;
#   t1 = a0[t1];
#   t2 = a1[t2];
#   t3 = t1 * t2;
#   t4 += t3;
# }
loop_init:
    li t0, 0  # index of elements to use
    li t4, 0  # dot product result

loop_start:
    bge t0, a2, loop_end
    mul t1, t0, a3  # t1 for index of a0
    mul t2, t0, a4  # t2 for index of a1
    slli t1, t1, 2  # t1 for byte offset of a0
    slli t2, t2, 2  # t2 for byte offset of a1
    add t1, t1, a0  # t1 for element address in a0
    add t2, t2, a1  # t2 for element address in a1
    lw t1, 0(t1)    # t1 for element value in a0
    lw t2, 0(t2)    # t2 for element value in a1
    mul t3, t1, t2  # t3 = t1 * t2
    add t4, t4, t3  # t4 += t3
    addi t0, t0, 1  # add index
    j loop_start

loop_end:
    # Epilogue
    mv a0, t4
    jr ra
