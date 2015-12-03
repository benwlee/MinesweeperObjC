//
//  ViewController.m
//  Minesweeper
//
//  Created by Benjamin Lee on 11/25/15.
//  Copyright © 2015 Benjamin Lee. All rights reserved.
//

#import "ViewController.h"
#import "GameBoard.h"
#import "GameTile.h"
#import "Constants.h"

@interface ViewController () {

    CGSize screensize;
    int winState;
}

@property (nonatomic, strong) UILabel *winLabel;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *validateButton;
@property (nonatomic, strong) UIButton *cheatButton;
@property (nonatomic, strong) NSMutableArray *squareLabels;
@property (nonatomic, strong) GameBoard *gameBoard;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    winState = WIN_STATE_TBD;
    
    CGRect screenbounds = [[UIScreen mainScreen] bounds];
    screensize = screenbounds.size;
    
    CGFloat width = screensize.width/8;
    CGFloat topPadding = 50;
    
    self.squareLabels = [[NSMutableArray alloc] init];
    
    // Setup 8x8 grid
    for (int i=0; i<8; i++) {
        for (int j=0; j<8; j++) {
            
            int tag = i*8+j;
            
            UILabel *squareLabel = [[UILabel alloc] initWithFrame:CGRectMake(j*width, i*width+topPadding, width, width)];
            squareLabel.layer.borderColor = [UIColor blackColor].CGColor;
            squareLabel.layer.borderWidth = 1.0;
            squareLabel.backgroundColor = [UIColor lightGrayColor];
            //squareLabel.text = [NSString stringWithFormat:@"%d", tag];
            squareLabel.textAlignment = NSTextAlignmentCenter;
            squareLabel.tag = tag;
            
            [self.view addSubview:squareLabel];
            [self.squareLabels addObject:squareLabel];
        }
    }
    
    // Setup reset button
    _resetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    [_resetButton sizeToFit];
    _resetButton.center = CGPointMake(screensize.width/4, screensize.height-50);
    [_resetButton addTarget:self action:@selector(resetButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resetButton];
    
    // Setup validate button
    _validateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_validateButton setTitle:@"Validate" forState:UIControlStateNormal];
    [_validateButton sizeToFit];
    _validateButton.center = CGPointMake(screensize.width/2, screensize.height-50);
    [_validateButton addTarget:self action:@selector(validateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_validateButton];
    
    // Setup validate button
    _cheatButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_cheatButton setTitle:@"Cheat" forState:UIControlStateNormal];
    [_cheatButton sizeToFit];
    _cheatButton.center = CGPointMake(screensize.width*3/4, screensize.height-50);
    [_cheatButton addTarget:self action:@selector(cheatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cheatButton];
    
    // Setup win label
    _winLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screensize.width, 50)];
    _winLabel.center = CGPointMake(screensize.width/2, screensize.height-100);
    [_winLabel setTextAlignment:NSTextAlignmentCenter];
    [_winLabel setText:@""];
    [self.view addSubview:_winLabel];
    
    
    // Setup tap gesture recognizer
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedView:)];
    [self.view addGestureRecognizer:tapGest];
    
    UILongPressGestureRecognizer *longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedView:)];
    //[longGest setMinimumPressDuration:2];
    [self.view addGestureRecognizer:longGest];
    
    [tapGest requireGestureRecognizerToFail:longGest];
    
    
    _gameBoard = [[GameBoard alloc] init];
    [_gameBoard setupGameBoard];
    [_gameBoard printGameBoard];
    
}

// MARK: - Update GameBoard from Model
- (void) updateGameBoard {
    
    for (int i=0; i<8; i++) {
        NSArray *rowArray = [self.gameBoard.gameBoard objectAtIndex:i];
        for (int j=0; j<8; j++) {
            GameTile *tile = [rowArray objectAtIndex:j];
            UILabel *label = [self.squareLabels objectAtIndex:(i*8+j)];
            
            if (tile.visible) {
                if (tile.mineState == empty) {
                    label.backgroundColor = [UIColor whiteColor];
                    int numMines = tile.numSurroundingMines;
                    if (numMines > 0) {
                        label.text = [NSString stringWithFormat:@"%d", tile.numSurroundingMines];
                    }
                }
                if (tile.mineState == mine) {
                    label.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:66.0/255.0 blue:66.0/255.0 alpha:1.0];  //0xFF4242
                    label.text = @"*";
                    
                }
            } else {
                if (tile.userState == none) {
                    label.backgroundColor = [UIColor lightGrayColor];
                    label.text = @"";
                }
                if (tile.userState == question) {
                    label.backgroundColor = [UIColor yellowColor];
                    label.text = @"?";
                }
                if (tile.userState == checked) {
                    label.backgroundColor = [UIColor colorWithRed:77/255.0 green:184/255.0 blue:255/255.0 alpha:1.0];  //0x4DB8FF
                    label.text = @"$";
                }
            }
        }
    }
}

// MARK: - Tap Gesture Recognizer Method

- (void) tappedView: (UITapGestureRecognizer*)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self.view];
    NSLog(@"User tapped at %f, %f", touchPoint.x, touchPoint.y);
    
    int index = [self userTouchedPoint:touchPoint];
    
    if (index >= 0 && winState == WIN_STATE_TBD) {
        NSLog(@"user tapped square %d", index);
        
        int state = [_gameBoard userTappedTileAtIndex:index];
        [self updateGameBoard];
        
        if (state == MINE_TILE) {
            NSLog(@"You lose!!");
            [_winLabel setText:@"You lose!"];
            winState = WIN_STATE_LOSE;
        }
        
        [self checkWinState];
        
    } else {
        NSLog(@"user did not touch a square");
    }
}

- (void) longPressedView: (UILongPressGestureRecognizer*)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint touchPoint = [recognizer locationInView:self.view];
        NSLog(@"User long pressed at %f, %f", touchPoint.x, touchPoint.y);
        int index = [self userTouchedPoint:touchPoint];
        
        if (index >= 0) {
            [_gameBoard userLongPressedTileAtIndex:index];
            [self updateGameBoard];
        }
    }
}

// MARK: - Button Pressed Methods

- (void) resetButtonPressed:(UIButton*)sender {
    NSLog(@"Resetig board");
    
    [_gameBoard resetGameBoard];
    
    for (UILabel *square in self.squareLabels) {
        square.text = @"";
        square.backgroundColor = [UIColor lightGrayColor];
    }
    
    [_winLabel setText:@""];
    
}


- (void) validateButtonPressed:(UIButton*)sender {
    NSLog(@"Checking if you win");
    
    BOOL win = [self checkWinState];
    
    if (!win) {
        [_winLabel setText:@"Not done yet."];
    }
}

- (void) cheatButtonPressed:(UIButton*)sender {
    NSLog(@"you cheater!");
    
    [_gameBoard userCheated];
    [self updateGameBoard];
    [self checkWinState];
    
}

- (BOOL) checkWinState {
    BOOL win = [_gameBoard checkWinCondition];
    if (win) {
        NSLog(@"Congratulations you won!!");
        [_winLabel setText:@"You win!"];
        winState = WIN_STATE_WIN;
    }
    
    return win;
}

// MARK: - Helper functions
- (int) userTouchedPoint:(CGPoint)touchPoint {
    for (UILabel *square in self.squareLabels) {
        
        if (CGRectContainsPoint(square.frame, touchPoint)) {
            return (int)square.tag;
        }
    }
    return -1;
}


@end
