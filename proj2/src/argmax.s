.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    addi t1, a1, -1  # t1 = a1 - 1
    # if (t1 < 0) exit(36);
    bge t1, x0, loop_init
    li a0, 36
    j exit

    # t3 = 0;
    # t4 = a0[0];
    # for (int t0 = 1; t0 < a1; t0++) {
    #   t1 = a0[t0];
    #   if (t1 > t4) {
    #     t3 = t0;
    #     t4 = t1;
    #   }
    # }
    # return t3;
loop_init:
    li t3, 0      # t3 for index of the largest element
    lw t4, 0(a0)  # t4 for the largest value so far
    li t0, 1      # t0 for index

loop_start:
    bge t0, a1, loop_end
    slli t2, t0, 2  # t2 for byte offset
    add t2, t2, a0  # t2 for element address
    lw t1, 0(t2)    # t1 = a0[t0]
    bge t4, t1, loop_continue
    mv t3, t0
    mv t4, t1

loop_continue:
    addi t0, t0, 1
    j loop_start

loop_end:
    # Epilogue
    mv a0, t3
    jr ra
