//
//  GameBoard.h
//  Minesweeper
//
//  Created by Benjamin Lee on 11/25/15.
//  Copyright © 2015 Benjamin Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameBoard : NSObject

@property (nonatomic, strong) NSMutableArray * gameBoard;

- (void) setupGameBoard;
- (void) resetGameBoard;
- (void) printGameBoard;
- (int)  userTappedTileAtIndex:(int)index;
- (void) userLongPressedTileAtIndex:(int)index;
- (void) userCheated;
- (BOOL) checkWinCondition;


@end
