#include <stdio.h>

void printBoard();
void checkRow(int);
void checkCol(int);
void checkBox(int);
void checkAll(int);
void clear(int, int);
int bitCheckRow(int, int);
int bitCheckCol(int, int);
void assignBoard(int);

int boardNotSolved();

//Sample Sudoku layout
int board[81] = {7, 9, 0, 0, 0, 0, 3, 0, 0,
		   0, 0, 0, 0, 0, 6, 9, 0, 0,
		   8, 0, 0, 0, 3, 0, 0, 7, 6,
		   0, 0, 0, 0, 0, 5, 0, 0, 2,
		   0, 0, 5, 4, 1, 8, 7, 0, 0,
		   4, 0, 0, 7, 0, 0, 0, 0, 0,
		   6, 1, 0, 0, 9, 0, 0, 0, 8,
		   0, 0, 2, 3, 0, 0, 0, 0, 0,
		   0, 0, 9, 0, 0, 0, 0, 5, 4};

int bitmap[729];

int main (int argc, char **argv) 
{

    int i;
    for (i = 0; i < 729; i++) 
	{
		bitmap[i] = 1;
    }

    int k;
    for(i = 0; i < 81; i++)
		checkAll(i);
    
    i = 0;
    k = 0;
    
    while (boardNotSolved()) 
	{
		i = i % 80;
		if (board[i] != 0) 
		{
	    	i++;
	    	continue;
		}
		else {
	    	for (k = 0; k < 9; k++) 
			{
				if (bitmap[(i * 9) + k] == 1)
				{
		    		if (bitCheckCol(i, k + 1) == 1 || bitCheckRow(i, k + 1) == 1)
					{
						clear(i, k + 1);
						assignBoard(i);
						break;
		    		}
				}
	    	}
	    	i++;
		}
    }

    printBoard(); 

	return 0;
    
}


void printBoard() 
{
	int i;

	for (i = 0; i < 81; i++) 
	{
		printf("%d ", board[i]);
		if ((i + 1) % 9 == 0) 
			printf("\n");
	}
}

void checkRow (int boardIndex)
{
    int rowOffset;
    int found;
    int bitmapOffset;

    rowOffset = (boardIndex / 9) * 9;
    int i;
    for (i = rowOffset; i < (rowOffset + 9); i++)
	{
		if (board[i] != 0)
		{
	    	found = board[i];
	    	bitmapOffset = (boardIndex * 9) + found - 1;
	    	bitmap[bitmapOffset] = 0;
		}
    }
}

void checkColumn (int boardIndex) 
{
    int colOffset;
    int found;
    int bitmapOffset;

    colOffset = boardIndex % 9;
    int i;
    for (i = colOffset; i < 81; i += 9) 
	{
		if(board[i] != 0)
		{
	    	found = board[i];
	    	bitmapOffset = (boardIndex * 9) + found - 1;
	    	bitmap[bitmapOffset] = 0;
		}
    }
}

/* Performs a bitmap check and update on the boxes */
void checkBox (int boardIndex) 
{
    int topLeft;
    int rowOffset;
    int topLeftRow;
    int colOffset;
    int topLeftCol;
    
    rowOffset = (boardIndex / 9);
    colOffset = boardIndex % 9;

    topLeftRow = rowOffset / 3;
    topLeftRow = topLeftRow * 3;
    topLeftCol = colOffset / 3;
    topLeftCol = topLeftCol * 3;
    topLeft = topLeftRow * 9;
    topLeft = topLeft + topLeftCol;
    
    int i;
    int found;
    int bitmapOffset;
    
    for (i = topLeft; i < topLeft + 3; i++)
	{
		if (board[i] != 0)
		{
	    	found = board[i];
	    	bitmapOffset = (boardIndex * 9) + found - 1;
	    	bitmap[bitmapOffset] = 0;
		}
    }
    for (i = topLeft + 9; i < topLeft + 12; i++)
	{
		if (board[i] != 0) 
		{
	    	found = board[i];
	    	bitmapOffset = (boardIndex * 9) + found - 1;
	    	bitmap[bitmapOffset] = 0;
		}
    }
    for (i = topLeft + 18; i < topLeft + 21; i++) 
	{
		if(board[i] != 0)
		{
	    	found = board[i];
	    	bitmapOffset = (boardIndex * 9) + found - 1;
	    	bitmap[bitmapOffset] = 0;
		}
    }
}

void checkAll (int boardIndex) 
{
    int i;
    int rowOffset;
    int bitmapOffset;

    if (board[boardIndex] != 0) 
	{
		rowOffset = boardIndex * 9;
		bitmapOffset = rowOffset + board[boardIndex] - 1;
		for (i = rowOffset; i < (rowOffset + 9); i++) 
		{
	    	bitmap[i] = 0;
		}   
		bitmap[bitmapOffset] = 1;
    }
    else
	{
		checkRow(boardIndex);
		checkColumn(boardIndex);
		checkBox(boardIndex);
    }
}

/* clears the values that are eliminated possibilities */
void clear (int boardIndex, int num) 
{
    int rowOffset;
    int bitmapOffset;
    int colOffset;
    int topLeft;
    int i;

    rowOffset = boardIndex / 9;
    colOffset = boardIndex % 9;
    topLeft = (((rowOffset / 3) * 3) * 9) + ((colOffset / 3) * 3);

    for (i = 0; i < 9; i++) 
		bitmap[(boardIndex * 9) + i] = 0;

    rowOffset = rowOffset * 9;
    bitmapOffset = (rowOffset * 9) + num - 1;
    for (i = rowOffset; i < (rowOffset + 9); i++) 
	{
		bitmap[bitmapOffset] = 0;
		bitmapOffset = bitmapOffset + 9;
    }
    
    bitmapOffset = (colOffset * 9) + num - 1;
    for (i = colOffset; i < 81; i += 9) 
	{
		bitmap[bitmapOffset] = 0;
		bitmapOffset = bitmapOffset + 81;	
    }
    
    bitmapOffset = (topLeft * 9) + num - 1;
    for (i = topLeft; i < topLeft + 3; i++) 
	{
		bitmap[bitmapOffset] = 0;
		bitmapOffset = bitmapOffset + 9;
    }
    
    bitmapOffset = (topLeft + 9) * 9 + num - 1;
    for (i = 0; i < 3; i++) 
	{
		bitmap[bitmapOffset] = 0;
		bitmapOffset = bitmapOffset + 9;
    }
    
    bitmapOffset = (topLeft + 18) * 9 + num-1;
    for (i = 0; i < 3; i ++) 
	{
		bitmap[bitmapOffset] = 0;
		bitmapOffset = bitmapOffset + 9;
    } 

    bitmap[boardIndex * 9 + num - 1] = 1;
}

/* Returns true or false on whether it can insert or not */
int bitCheckRow (int boardIndex, int num) 
{
    int rowOffset;
    int found = 0;
    int bitmapOffset;

    rowOffset = (boardIndex / 9) * 9;
    
    int i;
    
    bitmapOffset = (rowOffset * 9) + num -1;
    for (i = rowOffset; i < (rowOffset + 9); i++) 
	{
		if (bitmap[bitmapOffset] == 1)
	    	found++;
	
		bitmapOffset = bitmapOffset + 9;
    }

    if (found == 1)
		return 1;
    else
		return 0;

}

/* Returns true or false on whether it can insert possibility or not */
int bitCheckCol (int boardIndex, int num) 
{
    int colOffset;
    int found = 0;
    int bitmapOffset;
    
    colOffset = boardIndex % 9;

    int i;
    bitmapOffset = (colOffset * 9) + num - 1;
    for (i = 0; i < 9; i++) 
	{
		if (bitmap[bitmapOffset] == 1)
	    	found++;
	
		bitmapOffset = bitmapOffset + 81;
    }

    if (found == 1)
		return 1;
    else
		return 0;
}

/* Keeps on returning true as long as it finds a 0 cell */
int boardNotSolved() 
{
    int i;
    int zero = 0;
    
    for (i = 0; i < 81; i++) 
	{
		if (board[i] == 0) 
	    	zero++;
    }
    
	if (zero == 0)
		return 0;
    else
		return 1;

}

/* Assigns known possibilities to each cell */
void assignBoard (int boardIndex) 
{
    
    int i = 0;

    while (i < 9 ) 
	{
		if (bitmap[(boardIndex * 9) + i]) 
	    	break;
		i++;
    }
    board[boardIndex] = i + 1;
}
