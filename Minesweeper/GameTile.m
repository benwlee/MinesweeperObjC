//
//  GameTile.m
//  Minesweeper
//
//  Created by Benjamin Lee on 11/25/15.
//  Copyright © 2015 Benjamin Lee. All rights reserved.
//

#import "GameTile.h"
#import <UIKit/UIKit.h>

@implementation GameTile

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _visible = false;
        _numSurroundingMines = 0;
        _mineState = empty;
        _userState = none;
        
    }
    return self;
}

- (instancetype)initWithRow:(int)row andCol:(int)col {

    self = [super init];
    if (self) {
        
        _row = row;
        _col = col;
        _visible = false;
        _numSurroundingMines = 0;
        _mineState = empty;
        _userState = none;
        
    }
    return self;
}

@end
