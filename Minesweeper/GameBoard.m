//
//  GameBoard.m
//  Minesweeper
//
//  Created by Benjamin Lee on 11/25/15.
//  Copyright © 2015 Benjamin Lee. All rights reserved.
//

#import "GameBoard.h"
#import "GameTile.h"
#import <UIKit/UIKit.h>
#import "Constants.h"


// ********************************************************
// ******************** GameBoard Class *******************
// ********************************************************
@implementation GameBoard

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // gameBoard is an array of rows
        _gameBoard = [[NSMutableArray alloc] init];
        
        for (int i=0; i<8; i++) {  // i is rows
            NSMutableArray *rowArray = [[NSMutableArray alloc] init];
            
            for (int j=0; j<8; j++) {   // go though each col in row i
                GameTile *tile = [[GameTile alloc] initWithRow:i andCol:j];
                [rowArray addObject:tile];
            }
            
            [_gameBoard addObject:rowArray];
        }
        
    }
    return self;
}

- (void)setupGameBoard {
    
    for (int i=0; i<10; i++) {
        
        BOOL done = false;
        while (!done) {
            
            int index = arc4random_uniform(64);
            CGPoint rowCol = [self getPointFromIndex:index];
            NSMutableArray *rowArray = [_gameBoard objectAtIndex:rowCol.y];
            GameTile *tile = [rowArray objectAtIndex:rowCol.x];
            if (tile.mineState == empty) {
                tile.mineState = mine;
                done = true;
            }
        }
    }
}

- (void) resetGameBoard {
    
    // Reset all tiles to empty and not visible
    for (int i=0; i<8; i++) {
        NSArray *rowArray = [_gameBoard objectAtIndex:i];
        for (int j=0; j<8; j++) {
            GameTile *tile = [rowArray objectAtIndex:j];
            tile.mineState = empty;
            tile.userState = none;
            tile.visible = false;
            tile.numSurroundingMines = 0;
        }
    }
    
    // Call setupGameBoard to add mines randomly
    [self setupGameBoard];
}

- (void) printGameBoard  {
    for (int i=0; i<8; i++) {
        NSArray *rowArray = [_gameBoard objectAtIndex:i];
        
        for (int j=0; j<8; j++) {
            GameTile *tile = [rowArray objectAtIndex:j];
            NSLog(@"Row=%d, Col=%d, visible=%d, state=%d", i, j, tile.visible, tile.mineState);
        }
        
    }
}

// A valid long press is for not visible tiles only.
// Each time the user long presses a tile, the state is changed from none to checked to question to none, etc.
- (void) userLongPressedTileAtIndex:(int)index {
    CGPoint colRow = [self getPointFromIndex:index];
    int row = colRow.y;
    int col = colRow.x;
    NSLog(@"user long pressed row=%d, col=%d", row, col);
    
    NSArray *rowArray = [_gameBoard objectAtIndex:row];
    GameTile *tile = [rowArray objectAtIndex:col];
    
    if (!tile.visible) {
        if (tile.userState == none) {
            tile.userState = checked;
        } else if (tile.userState == checked) {
            tile.userState = question;
        } else if (tile.userState == question) {
            tile.userState = none;
        }
    }
    

}

// This function takes in the tile number the user taps and returns the number of mines surrounding it
- (int) userTappedTileAtIndex:(int)index {
    
    CGPoint colRow = [self getPointFromIndex:index];
    int row = colRow.y;
    int col = colRow.x;
    NSLog(@"user tapped row=%d, col=%d", row, col);
    
    NSArray *rowArray = [_gameBoard objectAtIndex:row];
    GameTile *tile = [rowArray objectAtIndex:col];
    
    if (tile.visible) {
        return 100;   // let 100 be code for tile is already visible so view should not do anything
    } else {
        if (tile.mineState == mine) {
            tile.visible = true;
            tile.numSurroundingMines = 200;
            return MINE_TILE;  // let -1 be code for mine
        } else {
            
            int numMines = [self numberOfMinesSurroundingRow:row andCol:col];
            NSLog(@"Tile is surrounded by %d mines", numMines);
            if (numMines > 0) {  // if there are mines next to selected square, then return number of mines
                tile.visible = true;
                tile.numSurroundingMines = numMines;
                return numMines;
            } else {
            
                // since there are no adjacent to square, then search squares to immediate left, rigth, up, and down for mines.
                [self searchSquareAtRow:row   atCol:col-1];     // Search left
                [self searchSquareAtRow:row   atCol:col+1];     // Search right
                [self searchSquareAtRow:row-1 atCol:col];       // Search up
                [self searchSquareAtRow:row+1 atCol:col];       // Search down
                
                tile.visible = true;
                tile.numSurroundingMines = 0;
            }
            
        }
    }
    
    return 0;
}

- (int) searchSquareAtRow:(int)row atCol:(int)col {
    
    // If tile is located out of the grid, return -1 to indicate end
    if ([self isTileOutOfBoundsAtRow:row andCol:col]) {
        return -1;
    }
    
    NSArray *rowArray = [_gameBoard objectAtIndex:row];
    GameTile *tile = [rowArray objectAtIndex:col];
    
    if (tile.visible) { // tile is already visible so ignore
        return -1;
    }
    
    // Get number of mines surrounding tile
    int numMines = [self numberOfMinesSurroundingRow:row andCol:col];
    if (numMines == 0) {  // if number of mines is 0, then search surrounding tiles again
        tile.visible = true;
        
        [self searchSquareAtRow:row   atCol:col-1];     // Search left
        [self searchSquareAtRow:row   atCol:col+1];     // Search right
        [self searchSquareAtRow:row-1 atCol:col];       // Search up
        [self searchSquareAtRow:row+1 atCol:col];       // Search down
    } else {
        tile.visible = true;
        tile.numSurroundingMines = numMines;
        return numMines;
    }
    
    return 0;
}

- (BOOL) isTileOutOfBoundsAtRow:(int)row andCol:(int)col {
    if (row < 0) {
        return true;
    }
    if (row > 7) {
        return true;
    }
    if (col < 0) {
        return true;
    }
    if (col > 7) {
        return true;
    }
    return false;
}

// This function returns the number of mines surrounding a tile. It can be 0 to 8.
- (int) numberOfMinesSurroundingRow:(int)row andCol:(int)col {
    
    int numMines = 0;
    
    // Start seeing if mine above it
    int tmpRow = row-1;
    if (tmpRow >= 0) {
        NSArray *upRowArray = [_gameBoard objectAtIndex:tmpRow];
        numMines += [self numberOfMinesToLeftAndRightOfCol:col inRow:upRowArray];
    }
    // Next search row below
    tmpRow = row+1;
    if (tmpRow < 8) {
        NSArray *downRowArray = [_gameBoard objectAtIndex:tmpRow];
        numMines += [self numberOfMinesToLeftAndRightOfCol:col inRow:downRowArray];
    }
    // Finally search left and right of current row
    NSArray *myRow = [_gameBoard objectAtIndex:row];
    if (col-1 >= 0) {
        GameTile *leftTile = [myRow objectAtIndex:col-1];
        if (leftTile.mineState == mine) {
            numMines++;
        }
    }
    if (col+1 < 8) {
        GameTile *rightTile = [myRow objectAtIndex:col+1];
        if (rightTile.mineState == mine) {
            numMines++;
        }
    }
    
    return numMines;
}

// This function returns the number of mines in the row at col +/-1
- (int) numberOfMinesToLeftAndRightOfCol:(int)col inRow: (NSArray*)row {
    int count = 0;
    
    for (int i=col-1; i<col+2; i++) {
        if (i>=0 && i<8) {
            GameTile *tile = [row objectAtIndex:i];
            if (tile.mineState == mine) {
                count++;
            }
        }
    }
    return count;
}

// If user decides to cheat, turn over an empty tile for him
- (void) userCheated {
    // Get all empty tiles
    NSMutableArray *emptyTiles = [[NSMutableArray alloc] init];
    
    for (int i=0; i<8; i++) {
        NSArray *rowArray = [_gameBoard objectAtIndex:i];
        for (int j=0; j<8; j++) {
            GameTile *tile = [rowArray objectAtIndex:j];
            if (!tile.visible && tile.mineState == empty && tile.userState == none) {
                [emptyTiles addObject:tile];
            }
        }
    }
    
    // Get random number from 0 to number of emptyTiles
    int emptyTileIndex = arc4random_uniform((int)[emptyTiles count]);
    NSLog(@"randomly selected emptyTileIndex %d", emptyTileIndex);
    
    GameTile *tile = [emptyTiles objectAtIndex:emptyTileIndex];
    int tileIndex = tile.row * 8 + tile.col;
    [self userTappedTileAtIndex:tileIndex];
}

- (BOOL) checkWinCondition {
    int count = 0;
    
    for (int i=0; i<8; i++) {
        NSArray *rowArray = [_gameBoard objectAtIndex:i];
        
        for (int j=0; j<8; j++) {
            GameTile *tile = [rowArray objectAtIndex:j];
            if (tile.visible && tile.mineState == empty) {  // only count tiles that are visible and have no mine
                count++;
            }
        }
        
    }
    
    // player wins if all tiles with no mine are visible (which is 54 since there are 10 mines)
    if (count == 54) {
        return true;
    }
    
    return false;
}

// MARK: - Helper functions

// This function takes an index (0 to 63) and return  the row and column on the gameBoard.
// The returned value is a CGPoint (x, y) mapped to (col, row)
- (CGPoint) getPointFromIndex:(int)index {
    int row = index/8;
    int col = index%8;
    return CGPointMake(col, row);
}

@end
