.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    # open file with write permission
    li a1, 1
    jal fopen
    li t0, -1
    beq a0, t0, fopen_error
    mv s4, a0  # s4 for the file descriptor

    # write row and column numbers
    sw s2, 4(sp)
    sw s3, 0(sp)
    mv a0, s4
    addi a1, sp, 4
    li a2, 1
    li a3, 4
    jal fwrite
    li t0, 1
    bne a0, t0, fwrite_error
    mv a0, s4
    mv a1, sp
    li a2, 1
    li a3, 4
    jal fwrite
    li t0, 1
    bne a0, t0, fwrite_error

    # write matrix data to file
    mv a0, s4
    mv a1, s1
    mul a2, s2, s3
    li a3, 4
    jal fwrite
    mul t0, s2, s3
    bne a0, t0, fwrite_error

    # close file
    mv a0, s4
    jal fclose
    bne a0, x0, fclose_error

    # Epilogue
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    addi sp, sp, 32

    jr ra

fopen_error:
    li a0, 27
    j exit

fclose_error:
    li a0, 28
    j exit

fwrite_error:
    li a0, 30
    j exit