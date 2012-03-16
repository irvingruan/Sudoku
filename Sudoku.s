# Author: Irving Ruan
# Contact: irvingruan@gmail.com

# Sudoku solver implemented in MIPS assembly

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in 
# the Software without restriction, including without limitation the rights to 
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	

.data
#.align      4

# Here is where you put the data for your board game.  
# 0 means empty.  
# The first element is row 1, column 1.  Second element is row 1, column 2, etc.

space: .asciiz " "		# to hold a space string
nline: .asciiz "\n"		# to hold a newline string
bitmap: .space 2916 	# to hold the bitmap array (729 * 4)

.Align	4				# Aligns the memory offset
board:      .word     7, 9, 0, 0, 0, 0, 3, 0, 0
            .word     0, 0, 0, 0, 0, 6, 9, 0, 0
            .word     8, 0, 0, 0, 3, 0, 0, 7, 6
            .word     0, 0, 0, 0, 0, 5, 0, 0, 2
            .word     0, 0, 5, 4, 1, 8, 7, 0, 0
            .word     4, 0, 0, 7, 0, 0, 0, 0, 0
            .word     6, 1, 0, 0, 9, 0, 0, 0, 8
            .word     0, 0, 2, 3, 0, 0, 0, 0, 0
            .word     0, 0, 9, 0, 0, 0, 0, 5, 4


.globl      main
.text

###################################################################
# Function: main
# Runs the entirety of the program
# a0 = convention for index of i passed in
###################################################################
main:
	# Initiliaze bitmap array
	la		$t0, bitmap			# Load address of bitmap array to t0
	addi 	$t3, $t3, 0			# t3 = counter for counting until 729
	addi 	$t2, $t2, 729		# t2 = to store the number of bitmaps we need to load		
	addi 	$t1, $t1, 1			# Initialize 1 int to store into bitmap

# Load bits onto board
bitload:
	sw		$t1, 0($t0)			# Store 1 into each index on the array
	addi 	$t0, $t0, 4			# Increment bitmap pointer by 4 bytes
	addi 	$t3, $t3, 1			# Increment counter until 729
	bne		$t3, $t2, bitload   # Keep on looping until t3 is 729

	

    # Load the preset elements onto the board and print
	addi	$s1, $s1, 81	# s1 = number of elements in board
	addi    $s2, $s2, 8		# s2 = counter for determining whether to go next row for print
	addi	$s3, $s3, 0		# s3 = counter for incrementing to number of board elements	
	la 		$s0, board		# load the address of the board
	jal		printboard

	# Call check domain by looping thorugh index
	#addi	$a0, $0, 0			# index = 0
	#addi	$t8, $0, 81		    # t8 = 81

# for (i = 0; i < 81; i++)
#mainForLoop:	
	#slt		$t0, $a0, $t8		# (if index < 81), t0 = 1, else = 0
#	beq		$t0, $0, mainForEnd # if t0 = 0, get out of loop
#	jal		checkDomain			# call checkDomain(index)
#	addi	$a0, $a0, 1			# index++
#	j 		mainForLoop			# go back to beginning of loop

#mainForEnd:
	#la		$a1, bitmap
	#li		$a2, 729
	#jal	printBitmap
	j 		end
	

	
###################################################################
# Function: void checkDomain
# Calls all three check functions of checkRow, checkColumn, and checkBox
# t0 = board[Index]
# t1 = rowOffset
# t2 = byte address on bitmap
# t3 = bitmapOffset
# t4 = 4
# t5 = 9
# t6 = i
# t7 = rowOffset + 9
# s2 = 1
# s3 = board + boardOffset
# s4 = index * 4 (byte offset)
###################################################################
checkDomain:
	addi		$sp, $sp, -8	# Allocate space for function
	sw			$ra, 0($sp)		# Store the return address of $ra
	sw			$a0, 4($sp)		# Store the index passed in to the stack for later
	addi		$s4, $0, 0		# s4 = index * 4 (SAVE)
	addi		$t1, $0, 0		# t1 = rowOffset
	addi		$t2, $0, 0		# t2 = byte address on bitmap
	addi		$t3, $0, 0		# t3 = bitmapOffset
	addi		$t6, $0, 0		# t6 = i
	addi		$t7, $0, 0		# t7 = rowOffset + 9

	# Instantiate variables
	la			$s0, board		# load address of the board
	addi		$t4, $0, 4		# t4 = 4 (for byte offset)
	addi		$t5, $0, 9		# t5 = 9 (for bitmap offset)
	# Load board[index]
	mul			$s4, $a0, $t4	# index = index * 4 (byte offset)
	add			$s3, $s0, $s4	# Get the index byte offset of board
	lw			$t0, 0($s3)		# t0 = board[index]
	
	# (if board[index] != 0)
	beq			$t0, $0, checkDomainElse	# if (board[index] == 0), go to ELSE
	mul			$t1, $a0, $t5	# rowOffset = index * 9
	add			$t3, $t1, $t0	# bitmapOffset = (rowOffset + board[index])
	addi		$t3, $t3, -1		# bitmapOffset = bitmapOffset - 1
	
	# for (i = rowOffset; i < (rowOffset + 9); i++)
	add			$t6, $0, $t1	# i = rowOffset
	add			$t7, $t1, $t5	# (rowOffset + 9)

	la			$s1, bitmap		# s1 = starting address of bitmap	

# (for i = rowOffset; i < (rowOffset + 9); i++)
checkDomainFor:
	bge			$t6, $t7, checkDomainForEnd	# (while i < (rowOffset + 9))
	mul			$t2, $t6, $t4	# t2 = i * 4 (byte address of bitmap)
	add			$t5, $s1, $t2   # t5 = increment bitmap address to i * 4
	sw			$0, 0($t5)		# bitmap[i] = 0
	addi		$t6, $t6, 1		# i++
	j			checkDomainFor	# Leep on doing for loop

checkDomainForEnd:
	mul			$t3, $t3, $t4	# bitmapOffset = bitmapOffset * 4 (byte offset)
	la			$s1, bitmap		# LOAD starting address of bitmap again
	add			$t5, $s1, $t3	# t5 = Increment bitmap byte address by bitmapOffset
	addi		$t1, $0, 1		# t1 = 1
	sw			$t1, 0($t5)		# bitmap[bitmapOffset] = 1
	j			checkDomainEnd  # Go to end of function
# else after if (board[index] != 0)
checkDomainElse:
	jal			checkRow		# Go to checkRow function and return here
	jal	    	checkCol		# Go to checkCol function and return here
	#jal			checkBox		# Go to checkBox function and return here

# Return to the original function call (main)
checkDomainEnd:
	addi	$s3, $0, 0			# Deallocate s3 register use for global
	addi	$s4, $0, 0			# Deallocate s4 register use for global
	lw		$ra, 0($sp)
	lw		$a0, 4($sp)
	addi	$sp, $sp, 8
	jr		$ra	
	

###################################################################
# Function: void checkRow
# Sets the bitmap of the bitmap array accordingly to 0 by checking
# filled constants - this does NOT assign solutions
# t0 = i
# t1 = rowOffset
# t2 = found
# t3 = 9
# t4 = 4
# t5 = byte offset (x 4)
# t6 = bitmapOffset
# t7 = memory offset of bitmap + bitmapOffset
###################################################################
checkRow:
	# Allocate the stack for the function
	addi	$sp, $sp, -8		# Allocate space for function
	sw		$ra, 0($sp)			# Store the return address of $ra
	sw		$a0, 4($sp)			# Store the 1st argument into sp (int index)

	addi	$t0, $t0, 0			# t0 = i = index to loop through
	addi	$t1, $0, 0			# t1 = rowOffset = offset for beginning of row
	addi	$t2, $0, 0			# t2 = found, stores number from index i to there
	addi	$t3, $0, 9			# t3 = defined constant 9
	addi 	$t4, $0, 4			# t4 = defined constant 4
	addi 	$t5, $0, 0			# t5 = store byte index memory offset of board (x4 bytes)
	addi	$t6, $0, 0			# t6 = bitmap offset (bitmapOffset)
	addi	$t7, $0, 0			# t7 = bitmap + bitmapOffset	

	# rowOffset = (position / 9) * 9
	div		$a0, $t3			# index / 9
	mflo	$t1					# row = index / 9
	mul		$t1, $t1, $t3		# row = (index / 9) * 9
	
	add		$t0, $0, $t1		# i = rowOffset
	addi	$t1, $t1, 9			# rowOffset = rowOffset + 9
	la		$s0, board			# load address of the board for the following loop
	la		$s1, bitmap			# load the address of the bitmap for the following loop

# for (i = rowOffset; i < (rowOffset + 9); i++)
checkRowLoop:
	bge		$t0, $t1, checkRowEnd	# while i < (rowOffset + 9)
	mul		$t5, $t0, $t4			# i = i * 4 (4 = byte offset of memory)
	add		$t7, $s0, $t5			# load the address of board[i] (4-byte memory)
	lw		$t5, 0($t7)				# t5 = board[i]
	beq		$t5, $0, rowIncrIndex	# if (board[i] != 0)
	add		$t2, $0, $t5			# found = board[i]
	
	# bitmapOffset = (index * 9) + found - 1
	mul		$t6, $a0, $t3			# bitmapOffset = index * 9
	add		$t6, $t6, $t2			# bitmapOffset = (index * 9) + found
	addi	$t6, $t6, -1			# bitmapOffset = (index * 9) + found - 1
	mul		$t6, $t6, $t4			# bitmapOffset * 4 (memory offset)
	add		$t7, $s1, $t6			# t7 = Increase the memory offset on bitmap by 4 * i bytes
	sw		$0, 0($t7)				# bitmap[bitmapOffset] = 0 (assign zero)
# increment index for check row loop
rowIncrIndex:
	addi	$t0, $t0, 1				# index++
	j 		checkRowLoop
	
# Returns to the original caller of void checkRow and returns the index and RA
checkRowEnd:
	lw		$ra, 0($sp)
	lw		$a0, 4($sp)
	addi	$sp, $sp, 8
	jr		$ra
	
###################################################################
# Function: void checkCol
# Sets the bitmap of the bitmap array accordingly to 0 by checking
# filled constants - this does NOT assign solutions
# t0 = i
# t1 = colOffset
# t2 = found
# t3 = 9
# t4 = 4
# t5 = byte offset (x 4)
# t6 = bitmapOffset
# t7 = bitmap memory address of bitmap + bitmapOffset
###################################################################
checkCol:
	addi	$sp, $sp, -8			# Allocate 8 bytes for this func's stack
	sw		$ra, 0($sp)				# Store and save the return address
	sw		$a0, 4($sp)				# Store and save the index passed in

	# Instantiate local variables
	addi	$t0, $0, 0				# t0 = i = index to loop through
	addi	$t1, $0, 0				# t1 = colOffset = offset for beginning of col
	addi	$t2, $0, 0				# t2 = found, stores number from index i to there
	addi	$t3, $0, 9				# t3 = defined constant 9
	addi 	$t4, $0, 4				# t4 = defined constant 4
	addi 	$t5, $0, 0				# t5 = store byte index memory offset of board (x4 bytes)
	addi	$t6, $0, 0				# t6 = bitmap offset (bitmapOffset)
	addi	$t7, $0, 0				# t7 = bitmap memory offset of bitmap + bitmapOffset
	addi	$s3, $0, 0				# s3 = store board address (SAVE)

	# colOffset = index % 9
	div		$a0, $t3				# index % 9
	mfhi	$t1						# colOffset = index % 9
	
	add		$t0, $t0, $t1			# i = colOffset
	addi	$t1, $0, 81				# colOffset = colOffset + 81
	la		$s0, board				# load address of the board for the following loop
	la		$s1, bitmap				# load the address of the bitmap for the following loop

# for (i = colOffset; i < (colOffset + 81); i++)
checkColLoop:
	bge		$t0, $t1, checkColEnd	# while i < (colOffset + 81)
	mul		$t5, $t0, $t4			# i = i * 4 (4 = byte offset of memory)
	add		$s3, $s0, $t5			# load the address of board[i] (4-byte memory)
	lw		$t5, 0($s3)				# t5 = board[i]
	
	# (if board[index] != 0)
	beq		$t5, $0, colIndexIncr		# if (board[i] != 0)
	add		$t2, $t5, $0			# found = board[i]
	
	# bitmapOffset = (index * 9) + found - 1
	mul		$t6, $a0, $t3			# bitmapOffset = index * 9
	add		$t6, $t6, $t2			# bitmapOffset = (index * 9) + found
	addi	$t6, $t6, -1			# bitmapOffset = (index * 9) + found - 1
	mul		$t6, $t6, $t4			# bitmapOffset * 4 (memory offset)
	add		$t7, $s1, $t6			# Increase the memory offset on bitmap by 4 * i bytes
	sw		$0, 0($t7)				# bitmap[bitmapOffset] = 0 (assign zero)
# Increment index for the column for loop
colIndexIncr:	
	addi	$t0, $t0, 9				# index = index + 9
	j 		checkColLoop

# Returns to the original caller of void checkCol and returns the index and RA
checkColEnd:
	addi	$s3, $0, 0				# Deallocate s3 SAVE
	lw		$ra, 0($sp)
	lw		$a0, 4($sp)
	addi	$sp, $sp, 8
	jr		$ra


###################################################################
# Function: void checkBox
# Sets the bitmap of the bitmap array accordingly to 0 by checking
# filled constants - this does NOT assign solutions
# t0 = i
# t1 = rowOffset
# t2 = colOffset
# t3 = leftRow
# t4 = leftCol
# t5 = memory offset (i * 4) and board[index]
# t6 = memory offset (x 4)
# t7 = bitmapOffset
# s2 = topLeft 
########################################################################
##
#        Function: checkBox
#        Function sets up initial bitmap based on box
#        CANNOT USE: t0, t1.
#        t0 = position;
##
########################################################################
checkBox:
	addi	$sp, $sp, -8			# Allocate space on the stack
	sw		$ra, 0($sp)				# Allocate return address on stack
	sw		$a0, 4($sp)				# Allocate index address on stack
	addi	$s5, $0, 3
	addi	$s6, $0, 4
	addi	$s7, $0, 9
	
	addi	$t2, $0, 0
	addi	$t3, $0, 0
	addi	$t4, $0, 0
	addi	$t5, $0, 0
	addi    $t6, $0, 0
	addi	$t7, $0, 0
	addi	$t8, $0, 0
	addi	$t9, $0, 0


	div		$t2, $a0, $s7           #t2 (rowBegin) = t0(position)/9
    div     $a0, $s7
   	mfhi    $t3                     #t3 (colBegin) = t0 (position) % 9

    div     $t8, $t2, 3             #rowBegin/3;
    mul     $t8, $t8, $s5           #upLeftRow = (rowBegin/3)*3
    div     $t9, $t3, 3             #colBegin/3
    mul     $t9, $t9, $s5           #upLeftCol = (colBegin/3)*3
    mul     $t4, $t8, $s7           #upLeft = upLeftRow * 9
    add     $t4, $t4, $t9           #upLeft = upLeft + upLeftCol
    addi    $t8, $t4, 0         	#t8 = upLeft

   	addi    $t2, $t8, 0         	#t2 (i) = upLeft
    addi    $t3, $t8, 3         	#t3 = upLeft + 3

	la		$s0, board
	la		$s1, bitmap	

checkBoxLoop1:
    bge      $t2, $t3, checkBox1End  #while (i < upLeft + 3)
    mul      $t5, $t2, $s6          #i*4
    add      $t5, $t5, $s0          #t5 = &board[i]
    lw       $t4, 0($t5)            #t4 = board[i]
    beq      $t4, $0, checkBox1Inc  #if(board[i] == 0) loop again
	addi     $t6, $t4, 0            #found = board[i]
    mul      $t9, $a0, $s7          #t9 = position * 9
    add      $t7, $t9, $t6          #bmOffset = (position *9) + found
    addi     $t7, $t7, -1           #bmOffset = bmOffset -1
    mul      $t7, $t7, $s6          #Get the correct offset for bmOffset
    add      $t7, $t7, $s1          #add it to bitmap[] to get the correct position
    sw       $0, 0($t7)                        #set bitmap[bmOffset] = 0

checkBox1Inc:
       addi        $t2, $t2, 1                        #i++
       j           checkBoxLoop1                #loop again

checkBox1End:
       addi        $t2, $t8, 9                        #t2(i) = upLeft + 9
       addi        $t3, $t8, 12                #t3 = upLeft + 12

checkBoxLoop2:
       bge                $t2, $t3, checkBox2End        #while (i = upLeft + 9 < upLeft + 12)
       mul                $t5, $t2, $s6                        #i*4
       add                $t5, $t5, $s0                #t5 = &board[i]
       lw                 $t4, 0($t5)                        #t4 = board[i]
       beq                $t4, $0, checkBox2Inc        #if(board[i] == 0) loop again
       addi       		  $t6, $t4, 0                        #found = board[i]
       mul                $t9, $a0, $s7                #t9 = position * 9
       add                $t7, $t9, $t6                #bmOffset = (position *9) + found
       addi        		  $t7, $t7, -1                #bmOffset = bmOffset -1
       mul                $t7, $t7, $s6                        #Get the correct offset for bmOffset
       add                $t7, $t7, $s1                #add it to bitmap[] to get the correct position
       sw                 $0, 0($t7)                        #setbitmap[bmOffset] = 0

checkBox2Inc:
       addi        $t2, $t2, 1                        #i++
       j                checkBoxLoop2                #loop again

checkBox2End:
       addi        $t2, $t8, 18                #t2 (i) = upLeft + 18
       addi        $t3, $t8, 21                #t3 = upLeft + 21

checkBoxLoop3:
       bge                $t2, $t3, checkBox3End        #while (upLeft + 18 < upLeft + 21)
       mul                $t5, $t2, $s6                        #i*4
       add                $t5, $t5, $s0                #t5 = &board[i]
       lw                $t4, 0($t5)                        #t4 = board[i]
       beq                $t4, $0, checkBox3Inc        #if(board[i] == 0) loop again
       addi            $t6, $t4, 0                        #found = board[i]
       mul                $t9, $a0, $s7                #t9 = position * 9
       add                $t7, $t9, $t6                #bmOffset = (position *9) + found
       addi        $t7, $t7, -1                #bmOffset = bmOffset -1
       mul                $t7, $t7, $s6                        #Get the correct offset for bmOffset
       add                $t7, $t7, $s1                #add it to bitmap[] to get the correct position
       sw                $0, 0($t7)                        #set bitmap[bmOffset] = 0

checkBox3Inc:
       addi        $t2, $t2, 1                        #i++
       j                checkBoxLoop3                #loop again

checkBox3End:
       	lw		$ra, 0($sp)
		lw		$a0, 4($sp)
		addi	$sp, $sp, 8
		jr      $ra




###################################################################
# Function: clearView
# Eradicates the bitmap arrays of eliminated possibilities and then
# assigns the only possibility of a cell to 1
# t0 = index
# t1 = rowOffset
# t2 = colOffset
# t3 = topLeft
# 
# t5 = bitmapOffset
# t7 = temporary bitmap address
# s4 = 4 (SAVE constant)
###################################################################
#clearValue:
#	add		$sp, $sp, -12			# Allocate space on the stack for clearValue function
#	sw		$ra, 0($sp)				# Store the return address of clearValue on stack
#	sw		$a0, 4($sp)				# Store the index being passed in on stack (save)
#	sw		$a1, 8($sp)				# Store the value of num passed in on stack (save)

	# rowOffset = index / 9
#	add		$t4, $0, 9				# t4 = 9 (temporary)
#	div		$a0, $t4				# index / 9
#	mflo	$t1						# t1 = index / 9

	# colOffset = index % 9
#	div		$a0, $t4					# index / 9
#	mfhi	$t2						# t2 = index % 9

###### topLeft = (((rowOffset/3)*3)*9) + ((colOffset/3)*3)
	
	# (((rowOffset/3)*3)*9)
#	addi	$t4, $0, 3				# t4 = 3 (temporary)
#	div		$t1, $t4				# rowOffset / 3
#	mflo	$t1						# t1 = rowOffset / 3
#	mul		$t1, $t1, $t4			# t1 = t1 * 3
#	addi	$t4, $0, 9				# t4 = 9 (temporary)
#	mul		$t1, $t1, $t4			# t1 = rowOffset = (t1 * 3) * 9

	# ((colOffset/3)*3)
#	addi	$t4, $0, 3				# t4 = 3 (temporary)
#	div		$t2, $t4				# colOffset / 3
#	mflo	$t2						# t2 = colOffset / 3
#	mul		$t2, $t2, $t4			# t2 = t2 * 3

	# (((rowOffset/3)*3)*9) + ((colOffset/3)*3)
#	add		$t3, $t1, $t2			# (t3) topLeft = t1 + t2
	
	# RESET t1 (rowOffset) & t2 (colOffset) for the 3 FOR LOOPS BELOW
	# rowOffset = index / 9
#	add		$t4, $0, 9				# t4 = 9 (temporary)
#	div		$a0, $t4				# index / 9
#	mflo	$t1						# t1 = index / 9

	# colOffset = index % 9
#	div		$a0, $t4				# index / 9
#	mfhi	$t2						# t2 = index % 9

	# for (i = 0; i < 9; i++)
#	la		$s1, bitmap				# s1 = address of bitmap array
#	addi	$t0, $0, 0				# t0 = i = 0
#	addi	$t4, $0, 9				# t4 = 9 (temporary)
#	mul		$t5, $a0, $t4			# t5 = index * 9 (temporary)
#	addi	$s4, $0, 4				# s4 = 4 (SAVE constant for byte)

#clearValueLoop0:
#	bge		$t0, $t4, clearValueLoop0End # while (i < 9)
#	mul		$t5, $a0, $t4			# t5 = index * 9 (temporary)
#	add		$t5, $t5, $t0			# t5 = (index * 9) + i
#	mul		$t5, $t5, $s4			# t5 = t5 * 4 (byte memory address offset)
#	add		$t7, $s1, $t5			# t7 = bitmap address + (t5 * 4)
#	sw		$0, 0($t7)				# t7 = bitmap[t7] = 0
#	addi	$t0, $t0, 1				# i++
#	j		clearValueLoop0			# Go back to for loop


# End of clearValue's first loop
#clearValueLoop0End:
#	mul		$t1, $t1, $t4			# rowOffset = rowOffet * 9
#	add		$t5, $t1, $a1			# t5 = rowOffset + value
#	addi	$t5, $t5, -1			# bitmapOffet = rowOffet + value - 1

	
	







##### DEALLOCATE S4



########################################################################
##
#       bitmap print function
##
########################################################################
#printBitmap:


 #      add $t0, $0, $0                         # i = 0
 #      addi $t9, $0, 9                         # t9 = 9


#PRINTprintLoop:
#       beq $t0, $a2, PRINTreturn       # if i == #ofiterations
 #      div $t0, $t9                            # hi = i%9
 #      mfhi $t2                                        # t2 = i%9
 #      beq $t2, $0, PRINTprintNL       # if i%9 == 0, print a \n

#PRINTNLPrinted:
 #      lw $a0, 0($a1)                          #
  #     li $v0, 1                                       #
   #    syscall                                         # print board[i]

    #   la $a0, space                           #
     #  li $v0, 4                                       #
	  # syscall                                         # print a space

    #   addi $a1, $a1, 4                        # set the next address  of board[]
      # addi $t0, $t0, 1                        # i++
     #  j PRINTprintLoop

#PRINTprintNL:
 #      la $a0, nline
  #     li $v0, 4
   #    syscall                                         # print a \n char
    #   j PRINTNLPrinted

#PRINTreturn:
 #       la              $a0, nline                              #print a new line
  #      li              $v0, 4
   #     syscall
    #    jr $ra




###################################################################
# Function: printboard
# Prints the array of the board and loop until
# all elements have been printed out
###################################################################
printboard:
	lw 		$a0, 0($s0)				#load the number to be printed
	li 		$v0, 1					#load 1 in $v0 to print int
	syscall
	
	# Print a space after an int	
	la 		$a0, space				#load string to be printed
	li 		$v0, 4					#load 4 in $v0 to print string
	syscall

	# Do counter and newline checks to see if we should jump rows	
	addi 	$s2, $s2, -1			#decrement counter for newline detection
	bltzal 	$s2, newline			#jump to new line on the 9th element		
	addi 	$s0, $s0, 4			#increment $s0 to next element
	addi 	$s3, $s3, 1			#increment counter for printboard function
	bne 	$s3, $s1, printboard	#branch back until all elements have been printed (while s3 != s1)
	j		end

newline:
	la 		$a0, nline				#load string to be printed
	li 		$v0, 4					#load 4 in $v0 to print string
	syscall
	li 		$s2, 8					#reset counter
	jr 		$ra

end:


			




