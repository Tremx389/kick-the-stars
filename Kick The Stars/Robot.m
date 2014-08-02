//
//  Robot.m
//  Kick the Stars
//
//  Created by Szabó Bendegúz on 17/06/14.
//  Copyright (c) 2014 User. All rights reserved.
//

#import "Robot.h"
#import "MathLibrary.h"

const float MIN_WAIT = 1;
const float MAX_WAIT = 3;

typedef enum {
    FIRST,
    SECOND,
    DEFENSE
} Wave;

@implementation Robot {
    GameScene *gS;
}

- (Robot *)init:(GameScene *)s {
    gS = s;
    [self runThread];
    return self;
}

- (void)runThread {
    [gS runAction:[SKAction waitForDuration:randomFloat(MIN_WAIT, MAX_WAIT)] completion:^{
        switch ([self detectWave]) {
            case FIRST:
                [self firstWave];
                break;
            case SECOND:
                [self secondWave];
                break;
            case DEFENSE:
                [self firstWave];
                break;
        }
        
        [self runThread];
    }];
}

- (void)firstWave {
    NSLog(@"first Wave");
}

- (void)secondWave {
    NSLog(@"second Wave");
}

- (Wave)detectWave {
    Wave result;
    if ([gS numOf:INDEPENDENT] > 0) {
        result = FIRST;
    } else {
        result = SECOND;
    }
    return result;
}

@end
