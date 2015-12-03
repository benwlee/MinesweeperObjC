//
//  GameTile.h
//  Minesweeper
//
//  Created by Benjamin Lee on 11/25/15.
//  Copyright © 2015 Benjamin Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

enum TileMineState {empty, mine};
enum TileUserState {none, checked, question};

// ********************************************************
// ******************** GameTile Class ********************
// ********************************************************

@interface GameTile : NSObject

@property (nonatomic) int row;
@property (nonatomic) int col;
@property (nonatomic) BOOL visible;
@property (nonatomic) int  numSurroundingMines;
@property (nonatomic) enum TileMineState mineState;
@property (nonatomic) enum TileUserState userState;

- (instancetype)initWithRow:(int)row andCol:(int)col;

@end
