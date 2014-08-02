//
//  MenuScreen.h
//  Kick the Stars
//
//  Created by Szabó Bendegúz on 18/06/14.
//  Copyright (c) 2014 User. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    NONE,
    LOGO,
    START,
    RESTART
} Button;

@interface MenuScreen : SKNode

- (MenuScreen *)initFirstMenuIn:(SKScene *)scene;
- (MenuScreen *)initPauseMenuIn:(SKScene *)scene;

- (Button)buttonIn:(CGPoint)location;

@end
