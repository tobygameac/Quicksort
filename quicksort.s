# Quick sort + find median by 410021044

  .data
array : .word 0:1000
inputmsg : .asciiz "Please input numbers (read until zero): "
outputmsg1 : .asciiz "Before quick sort : \n"
outputmsg2 : .asciiz "After quick sort : \n"
outputmsg3 : .asciiz "Median is : \n"
space : .asciiz " " 
nextLine : .asciiz "\n"

  .globl main
  .text
main :                      # main function
  la $s0, array             # put array address at $s0

  la $a0, inputmsg
  li $v0, 4
  syscall                   # print message

  li $t0, 0                 # initial i to 0
  li $t2, 0                 # initial N to 0

Input :                     # loop of input, $t0 = i
  li $v0, 5
  syscall                   # read integer

  sll $t4, $t0, 2           # $t4 = i * 4
  add $t4, $s0, $t4         # $t4 = &array[i]
  sw  $v0, 0($t4)           # array[i] = input;
  addi  $t0, $t0, 1         # i = i + 1
  addi  $t2, $t2, 1         # N = N + 1
  bne   $v0, $zero, Input   # while (i != n)

  addi  $t2, $t2, -1        # N = N - 1(don't need 0)

  la $a0, outputmsg1
  li $v0, 4
  syscall                   # print outputmsg
  
  jal PrintArray            # print array before sort

  li $a0, 0                 # left = 0
  addi $a1, $t2, -1         # right = N - 1
  jal Qsort                 # qsort(left, right)

  la $a0, outputmsg2
  li $v0, 4
  syscall                   # print outputmsg

  jal PrintArray            # print array after sort

  la $a0, outputmsg3
  li $v0, 4
  syscall                   # print outputmsg

  srl $t0, $t2, 1           # $t0 = N / 2
  sll $t0, $t0, 2           # $t0 = $t0 * 4
  add $t0, $s0, $t0         # $t0 = &array[N / 2]
  andi $t1, $t2, 1          # $t1 = N & 1 = N % 2
  beq $t1, $zero, Even      # if (N % 2 == 0) goto Even
Odd :
  j PrintMedian
Even :
  lw $t1, 0($t0)            # $t1 = array[N / 2]
  lw $t2, -4($t0)           # $t2 = array[N / 2 - 1]
  add $t1, $t1, $t2         # $t1 = $t1 + $t2
  srl $t1, $t1, 1           # $t1 = $t1 / 2
  sw $t1, 0($t0)            # *$t0 = $t1
PrintMedian :
  lw $a0, 0($t0)
  li $v0, 1
  syscall                   # print number

  li $v0, 10
  syscall                   # Exit

PrintArray :                # void printArray() function
    li $t0, 0               # i = 0
  Print :
    sll $t1, $t0, 2         # $t1 = i * 4
    add $t1, $s0, $t1       # $t1 = &array[i]

    lw $a0, 0($t1)
    li $v0, 1
    syscall                 # print number

    la $a0, space
    li $v0, 4
    syscall                 # print space

    addi $t0, $t0, 1        # i = i + 1
    bne $t0, $t2, Print      # while (i != n)

    la $a0, nextLine
    li $v0, 4
    syscall                 # print "\n"
  jr $ra                    # return

Qsort :                     # void qsort(int l, int r) function
  slt $t8, $a0, $a1         # $t8 = left < right
  beq $t8, $zero, Return    # if (left >= right) return
  j Keep
  Return :
    jr $ra                  # return
  Keep :

  addi $sp, $sp, -12        # stack of right, return address, and j
  sw $ra, 8($sp)            # push return address
  sw $a1, 4($sp)            # push right
  
  sll $t3, $a0, 2           # $t3 = left * 4
  add $t3, $t3, $s0         # $t3 = &array[left]
  lw $t3, 0($t3)            # $t3 = array[left] = pivot

  addi $t0, $a0, 1          # $t0 = i = left + 1
  addi $t1, $a1, 0          # $t1 = j = right
  Loop :
    LoopI :
      sll $t4, $t0, 2       # $t4 = i * 4
      add $t4, $s0, $t4     # $t4 = &array[i]
      lw $t5, 0($t4)        # $t5 = array[i]
      slt $t8, $t3, $t5     # $t8 = pivot < array[i]
      bne $t8, $zero, BreakI# if (array[i] > pivot) break
      addi $t0, $t0, 1      # i = i + 1
      slt $t8, $a1, $t0     # $t8 = right < i
      bne $t8, $zero, BreakI# i > right
    BreakI :

    LoopJ :
      sll $t6, $t1, 2       # $t6 = j * 4
      add $t6, $s0, $t6     # $t6 = &array[j]
      lw $t7, 0($t6)        # $t7 = array[j]
      slt $t8, $t7, $t3     # $t8 = array[j] < pivot
      bne $t8, $zero, BreakJ# if (array[j] < pivot) break
      addi $t1, $t1, -1     # j = j - 1
      slt $t8, $a0, $t1     # $t8 = left < j
      beq $t8, $zero, BreakJ# left >= j
    BreakJ :

    slt $t8, $t1, $t0       # $t8 = i > j
    bne $t8, $zero, EndLoop # if (i > j) break;

    sll $t4, $t0, 2         # $t4 = i * 4
    add $t4, $s0, $t4       # $t4 = &array[i]
    lw $t5, 0($t4)          # $t5 = array[i]
    sll $t6, $t1, 2         # $t6 = j * 4
    add $t6, $s0, $t6       # $t6 = &array[j]
    lw $t7, 0($t6)          # $t7 = array[j]
    sw $t7, 0($t4)
    sw $t5, 0($t6)          # swap(array[i], array[j])

    j Loop                  # while (i <= j)
  EndLoop :
  
  sll $t4, $a0, 2           # $t4 = left * 4
  add $t4, $s0, $t4         # $t4 = &array[left]
  sll $t6, $t1, 2           # $t6 = j * 4
  add $t6, $s0, $t6         # $t6 = &array[j]
  lw $t7, 0($t6)            # $t7 = array[j]
  sw $t7, 0($t4)
  sw $t3, 0($t6)            # swap(array[left], array[j])
  
  sw $t1, 0($sp)            # push j
  addi $a1, $t1, 0          # $a1 = j
  jal Qsort                 # Qsort(left, j)
  lw $t1, 0($sp)            # pop j, $t1 = j
  addi $a0, $t1, 1          # $a0 = j + 1
  lw $a1, 4($sp)            # pop right, $a1 = right
  jal Qsort                 # Qsort(j + 1, right)

  lw $ra, 8($sp)           # pop return address
  addi $sp, $sp, 12
  jr $ra                    # return
