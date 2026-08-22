.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    li t0, 0  # t0 for index
    addi t1, a1, -1  # t1 = a1 - 1
    # if (t1 < 0) exit(36);
    bge t1, x0, loop_start
    li a0, 36
    j exit

loop_start:
    # for (int i = 0; i < a1; i++) {
    #   t1 = a0[i];
    #   if (t1 >= 0) continue;
    #   a0[i] = 0;
    # }
    bge t0, a1, loop_end
    slli t2, t0, 2  # t2 for byte offset
    add t2, t2, a0  # t2 for element address
    lw t1, 0(t2)    # t1 = a0[i]
    bge t1, x0, loop_continue
    sw x0, 0(t2)

loop_continue:
    addi t0, t0, 1
    j loop_start

loop_end:
    # Epilogue
    jr ra
