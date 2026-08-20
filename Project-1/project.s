# ===========================================================
# Identificacao do grupo:  A50
#
# Membros [istID, primeiro + ultimo nome]
# 1. 113749 Manuel Raquel
# 2. 113820 Afonso Bernardo
# 3. 114047 Pedro Carrola
#
# ===========================================================
# Requisitos do enunciado que *nao* estao corretamente implementados:
# (indicar um por linha, ou responder "nenhum")
# - nenhum
#
# ===========================================================
# Top-5 das otimizacoes que a vossa solucao incorpora:
# (maximo 140 caracteres por cada otimizacao)
#
# 1. Utilização de matmuls distintos
#
# 2. Dois ficheiros .bin são corrigidos simultaneamente para poupar loops
#
# 3. Não utilização de função auxiliar para pular o cabeçalho de forma a poupar tempo de execução
#
# 4. Reutilização máxima de registradores
#
# 5. Substituir mul por slli
#
# ===========================================================

.data

# ===========================================================

#Main data structures. These definitions cannot be changed.
h_m0: .word 128
w_m0: .word 784
m0: .zero 401408                #h_m0 * w_m0 * 4 bytes

h_m1: .word 10
w_m1: .word 128
m1: .zero 5120                  #h_m1 * w_m1 * 4 bytes

h_input: .word 784
w_input: .word 1
input: .zero 3136               #h_input * w_input * 4 bytes

h_h: .word 128
w_h: .word 1
h: .zero 512                    #h_h * w_h * 4 bytes

h_o: .word 10
w_o: .word 1
o: .zero 40                     #h_o * w_o * 4 bytes

# ===========================================================
# Here you can define any additional data structures that your program might need

file_m0:    .string "m0.bin"
file_m1:    .string "m1.bin"
file_input: .string "output.pgm"

# ===========================================================
.text

main:
    # Set up arguments for *classify* function
    la a0,file_m0
    la a1,file_m1
    la a2,file_input
    
    # Call *classify* function
    jal ra, classify

    
    j exit
    

# ===========================================================
# FUNCTION: abs
#   Computes absolute value of the int stored at a0
# Arguments:
#   a0, a pointer to int
# Returns:
#   Nothing (modifies value in memory)
# ===========================================================
abs:
   
    lw t0, 0(a0)         # Load int value
    bge t0, zero, done_abs   # If value >= 0, skip negation
    sub t0, x0, t0       # t0 = -t0
    sw t0, 0(a0)         # Store back to memory

done_abs:
    jr ra                    # Return to the caller



# ============================================================
# FUNCTION: relu
#   Applies ReLU on each element of the array (in-place)
# Arguments:
#   a0 = pointer to int array
#   a1 = array length
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ============================================================
relu:
    li t4,1
    blt a1,t4,erro_relu

    add t0, x0, x0             # t0 = current index in loop
    add t1,a0,x0               # t1 = current element address


loop_relu:
    bge t0,a1,loop_end_relu    # Exit loop when index = length

    lw t2,0(t1)                # t2 = current value

    bge t2,x0,ok_relu          # If value >= jump to ok_relu

    li t2,0
    sw t2,0(t1)                # Change negative value to 0


ok_relu:
    addi t1,t1, 4              # Increment adress (to the next element)
    addi t0,t0,1               # Increment index

    j loop_relu


erro_relu:
    li a0,36                   # Load error code 36 into a0
    j exit_with_error


loop_end_relu:
    jr ra                      # Return to the caller



# =================================================================
# FUNCTION: Given an int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the number of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 37
# =================================================================
argmax:
    blez a1,erro_argmax

    addi t0, x0, 1               # t0 = current index
    add t1,a0,x0                 # t1 = adress of the first member

    lw t6,0(t1)                  # t6 = value of the first member (initial max)
    li t5,0                      # t5 = index of the first member (initial max)


loop_argmax:
    bge t0,a1,done_argmax        

    addi t1,t1, 4                # Increment adress

    lw t2,0(t1)                  # t2 = current value in loop

    ble t2,t6,ok_argmax          # Check if current value <= max
    
    add t6,t2,x0                 # New max = t2
    add t5,t0,x0                 # New max index = t0


ok_argmax:
    addi t0,t0,1                 # Increment index

    j loop_argmax                # Repeat loop


erro_argmax:
    li a0,37                     # Load error code 37 into a0
    j exit_with_error


done_argmax:
    add a0,t5,x0                 # Return index of max to a0
    
    
loop_end_argmax:
    jr ra                        # Return to the caller




# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) - Pointer to the start of arr0
#   a1 (int*) - Pointer to the start of arr1
#   a2 (int)  - Number of elements to use   
# Returns:
#   a0 (int)  - The dot product of arr0 and arr1
# Exceptions:
#   - If a2 < 1, exit with error code 38
# =======================================================
dotproduct:
    addi t6,x0,1                # t6 = 1 (comparison value)
    blt a2,t6,erro38

    add t3,x0,x0                # t3 = 0 (accumulator)


loop_dotproduct:
    lw t0,0(a0)                 # Load word from arr0
    lw t1,0(a1)                 # Load word from arr1

    mul t2,t0,t1                # t2 = t0 * t1
    add t3,t3,t2                # Accumulate result

    addi a2,a2,-1               # Decrement vector size counter
    addi a0,a0,4                # Move to next element in arr0
    addi a1,a1,4                # Move to next element in arr1

    bgtz a2,loop_dotproduct

    add a0,t3,x0                # Move the final result into the return value

    jr ra                       # Return to the caller

# Exceptions dotproduct

erro38:
    li a0,38
    j exit_with_error                



# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
#
# Arguments:
#   a0 (int*)  - pointer to the start of m0     (Matrix A)
#   a1 (int*)  - pointer to the start of m1     (Matrix B)
#   a2 (int)   - number of rows in m0 (A)             [rows_A]
#   a3 (int)   - number of columns in m0 (A)          [cols_A]
#   a4 (int)   - number of rows in m1 (B)             [rows_B]
#   a5 (int)   - number of columns in m1 (B)          [cols_B]
#   a6 (int*)  - pointer to the start of d            (Matrix C = A x B)
#
# Returns:
#   None (void); result is stored in memory pointed to by a6 (d)
#
# Exceptions:
#  - If the height or width of any of the matrices is less than 1, 
#    this function terminates the program with error core 39
#  - If the number of columns in matrix A is not equal to the number 
#    of rows in matrix B, it terminates with error code 40
# =======================================================
matmul_bb:
   addi t0,x0,1
   blt a2,t0,erro39		 # Verify possible errors on the received arguments
   blt a3,t0,erro39
   blt a4,t0,erro39
   blt a5,t0,erro39
   bne a3,a4,erro40
     
   add t0,x0,a0			 # t0 is a pointer to the beginning of m0
   
   add t5,x0,a2			 # t5 is number of rows in m0 (A)
   add t6,x0,a6			 # t6 is a pointer to the start of d
   
   
loop2_matmul_bb:
    addi sp,sp,-4
    sw t5,0(sp)			 # Save t5 on the stack that will be used as a iterator
    
    add t1,x0,a1		    # t0 is a pointer to the start of m1     
    add t5,x0,x0		    # Now t5 is the result from the multiplication between a line from m0 and a from m1
    
    add t4,x0,a4		    # t4 is the number of rows in m1 (B)             
    
    add a7,x0,a5		    # a7 is the number of columns in m1 (B)          
    
    
loop1_matmul_bb: 
    lb t2,0(t0)		    # Read the values in byte t0 and t1 and puts it in t2 and t2
    lb t3,0(t1)
    
    mul t2,t2,t3		    # Multiply the values and add it to the sum
    add t5,t2,t5		
    
    addi t0,t0,1		    # Move the pointer to the next value in the line
 
    add t1,t1,a5		    # Move the pointer to the next value in the column
    
    addi t4,t4,-1		
    bgtz t4, loop1_matmul_bb		# If theres more values to multiply goes back to the loop
    
    sw t5,0(t6)
    addi t6,t6,4		    # Brings back from the stack the number of rows in m0 
    
    addi a7,a7,-1
    blez a7, salto_matmul_bb	  # If there's more rows to multiply
    
    add t3,x0,a3                # t3 = number of columns in m0
    sub t0,t0,t3                # Reset t0 to the beginning of the same row in m0
 
    add t3,x0,a5
    mul t3,a4,t3                # t3 = number of elements already traversed in m1
    sub t1,t1,t3                # Reset t1 to the top of the current column
    addi t1,t1,1                # Advance t1 to point to the next column in m1
    
    add t4,x0,a4                # Reset the counter for the shared dimension
    add t5,x0,x0                # Reset the accumulator
    
    j loop1_matmul_bb           # Jump back to multiply the next column
    
    
salto_matmul_bb:
            
    lw t5,0(sp)                 # Restore the number of rows in m0
    addi sp,sp,4                # Restore the stack pointer
    
    addi t5,t5,-1               # Decrease the row counter
    
    bgtz t5, loop2_matmul_bb    # If there are more rows in m0, repeat the outer loop

    jr ra                       # Return to the caller
    
    
matmul_bw:
    addi t0,x0,1
    blt a2,t0,erro39                      # Verify possible errors on the received arguments
    blt a3,t0,erro39
    blt a4,t0,erro39
    blt a5,t0,erro39
    bne a3,a4,erro40                     # Check if the number of columns in m0 is equal to rows in m1
     
    add t0,x0,a0                         # t0 is a pointer to the beginning of m0
    
    add t5,x0,a2                         # t5 is the number of rows in m0
    add t6,x0,a6                         # t6 is a pointer to the start of d

    
loop2_matmul_bw:
    addi sp,sp,-4
    sw t5,0(sp)                          # Save t5 on the stack that will be used as an iterator
    
    add t1,x0,a1                         # t1 is a pointer to the start of m1
    add t5,x0,x0                         # Now t5 will store the result of the dot product between a row from m0 and a column from m1
    
    add t4,x0,a4                         # t4 is the number of rows in m1 (shared dimension)
    
    add a7,x0,a5                         # a7 is the number of columns in m1
    
    
loop1_matmul_bw: 
    lb t2,0(t0)                          # Read byte from m0
    lw t3,0(t1)                          # Read word from m1
    
    mul t2,t2,t3                         # Multiply values and accumulate the result
    add t5,t2,t5
    
    addi t0,t0,1                         # Move the pointer to the next value in the row (m0)
    

    slli t2,a5,2                        # Calculate the offset to go down one element in the column (m1)
    add t1,t1,t2                         # Advance the pointer in m1's column
    
    addi t4,t4,-1
    bgtz t4, loop1_matmul_bw            # If there are more elements to multiply, repeat
    
    sw t5,0(t6)                          # Store the result in the output matrix
    addi t6,t6,4                         # Advance the output pointer
    
    addi a7,a7,-1
    blez a7, salto_matmul_bw            # If there are no more columns in m1, exit inner loop
    
    add t3,x0,a3
    sub t0,t0,t3                         # Reset m0 pointer to the beginning of the same row
    

    mul t3,t3,a5
    slli t3,a4,2                         # Calculate total size of m1 to adjust the pointer
    sub t1,t1,t3
    addi t1,t1,4                         # Advance to the next column in m1
    
    add t4,x0,a4                         # Reset the shared dimension counter
    add t5,x0,x0                         # Reset accumulator
    
    j loop1_matmul_bw
 
    
salto_matmul_bw:          
    lw t5,0(sp)                          # Restore the number of rows in m0
    addi sp,sp,4
    
    addi t5,t5,-1
    bgtz t5, loop2_matmul_bw            # If there are more rows in m0, repeat outer loop

    jr ra                                # Return to the caller
    

erro39:
    li a0,39
    j exit_with_error
    
erro40:
    li a0,40
    j exit_with_error     


######################################################################
# Function: read_file(char* filename, byte* buffer, int length)
# Input:
#   a0: pointer to null-terminated filename string
#   a1: destination buffer
#   a2: number of bytes to read
# Output:
#   a0: number of bytes read (return value from syscall)
# Exceptions:
#   - Error code 41 if error in the file descriptor
#   - Error code 42 If the length of the bytes to read is less than 1
######################################################################

read_file:
    addi t1,x0,1              # t1 = 1 (comparison value)    
    blt a2,t1,erro42          
    add t0,a1,x0              # Save buffer in t0
    add a1,x0,x0              # a1 = 0

    li a7 1024                # syscall: open
    ecall

    addi t2,x0,-1             # t2 = -1 (comparison value)
    beq a0,t2, erro41

    add a1,x0,t0              # Restore buffer in a1
    
    add t6,a0,x0              # Save the file descriptor

    li a7 63                  # syscall: read                  
    ecall
    
    blt a0,t1,erro41
    
    add t5,a0,x0              # Save the number of bytes
    add a0,t6,x0              # Restore buffer in a1
    
    li a7 57                  # syscall: close 
    ecall
    
    add a0,x0,t5              # Return number of bytes read    
    
    
    jr ra                     # Return to the caller

# Exceptions read_file

erro41:
    li a0,41
    j exit_with_error


erro42:
    li a0,42
    j exit_with_error



# =======================================================
# FUNCTION: Classify decimal digit from input image
#   d = classify(A, B, input)
#
# Arguments:
#   a0 (string*)  - pathname of file with the weight matrix m0
#   a1 (string*)  - pathname of file with the weight matrix m1
#   a2 (string*)  - pathname of file with the input image in Raw PGM format
#
# Returns:
#   a0 (int) - value of the classified decimal digit
#
# =======================================================

classify:
    addi sp,sp,-4             # Save return address on the stack   
    sw ra,0(sp)

    
    mv s0, a0                 # Path for m0_file
    mv s1, a1                 # Path for m1_file
    mv s2, a2                 # Path for input_file

    # Set the arguments to call readfile and read m0_file
    
    mv a0, s0                 # a0 = path for the m0_file
    la a1, m0                 # a1 = buffer for m0
    lw t3, w_m0               # t3 = width of m0
    lw t4, h_m0               # t4 = height of m0
    mul a2, t3, t4            # Size of m0
    slli a2, a2, 2            # Number of bytes to read
    jal ra, read_file 
    mv s0,a1                  # s0 = address of m0 buffer
    
    # Set the arguments to call readfile and read m1_file
    
    mv a0, s1                 # a0 = path for the m1_file
    la a1, m1                 # a1 = buffer for m1
    lw t3, w_m1               # t3 = width of m1
    lw t4, h_m1               # t4 = height of m1
    mul a2, t3, t4            # Size of m1
    slli a2, a2, 2            # Number of bytes to read
    jal ra, read_file
    mv s1,a1                  # s1 = address of m1 buffer
   
    # Set the arguments to call readfile and read input_file   
   
    mv a0, s2                 # a0 = path for the input_file
    la a1, input              # a1 = buffer for input
    lw t3, w_input            # t3 = width of input
    lw t4, h_input            # t4 = height of input
    mul a2, t3, t4            # Size of input
    slli a2, a2, 2            # Number of bytes to read
    jal ra, read_file
    mv s2,a1                  # s2 = address of input buffer
    
    addi s2,s2,12             # Skip the header bytes
    
    # Fix integers (subtract 32)
    
    addi t0,x0,-1             # t0 = -1 (index)
    lw t2, w_m0
    lw t3, h_m0
    mul t5, t2, t3            # Number of elements of m0
    lw t2, w_m1
    lw t3, h_m1
    mul t6, t2, t3            # Number of elements of m1
    
    
loop_classify:
    addi t0,t0,1              # Increment index
    
    bge t0,t5,jump_classify   # If index >= size of m0, skip m0 part
    
    add t1,t0,s0              # Address of the current element in m0
    lb t2,0(t1)               # Load byte
    addi t2,t2,-32            # Subtract
    sb t2,0(t1)               # Store back

jump_classify:
    
    bgt t0,t6,jump2_classify  # if index > size of m1, skip 1 part
    
    add t1,t0,s1              # Address of the current element in m1
    lb t2,0(t1)               # Load byte
    addi t2,t2,-32            # Subtract
    sb t2,0(t1)               # Store back

    
    j loop_classify
    
jump2_classify:
    
    ble t0,t5,loop_classify    

    # Set the arguments to call matmull_bb(m0, input)
    
    mv a0,s0                   # m0 matrix
    mv a1,s2                   # input matrix
    lw a2, h_m0    
    lw a3, w_m0
    lw a4, h_input
    lw a5, w_input
    la a6, h                   # Pointer to h 
    mv s3,a6                   # Save pointer to h
    
    jal ra, matmul_bb
    
    # Set the arguments to call relu(h)
    
    mv a0,s3                   # Input: h
    lw t0, w_h
    lw t1, h_h
    mul a1, t0, t1             # Number of elements in h
     
    jal ra, relu
    
    # Set the arguments to call matmul_bw(m1, h)
    
    mv a0,s1                    # m1 matrix
    mv a1,s3                    # h matrix
    lw a2, h_m1
    lw a3, w_m1
    lw a4, h_h
    lw a5, w_h
    la a6, o                    # Pointer to o
    mv s4,a6                    # Save pointer to o  
    
    jal ra, matmul_bw
    
    # Set the arguments to call argmax(o)
    
    mv a0, s4                   # Input: o
    lw t0, w_o
    lw t1, h_o
    mul a1, t0, t1              # Number of elements in o
    
    jal ra, argmax
    
    li a7,1                     # syscall: PrintInt              
    ecall
    
    lw ra,0(sp)                 # Restore return address
    addi sp,sp,4
    
    jr ra                       # Return to the caller



# =======================================================
# Exit procedures
# =======================================================

# Exits the program (with code 0)
exit:
    li a7, 10     # Exit syscall code
    ecall         # Terminate the program

# Exits the program with an error 
# Arguments: 
# a0 (int) is the error code 
# You need to load a0 the error to a0 before to jump here
exit_with_error:
  li a7, 93            # Exit system call
  ecall                # Terminate program

