//
//  UnitBlock.h
//  Kick the Stars
//
//  Created by Szabó Bendegúz on 03/06/14.
//  Copyright (c) 2014 User. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "Planet.h"

@class Planet;

@interface Unit : SKNode

@property (nonatomic) float points;
@property (nonatomic) float scale, radius;
@property (nonatomic) Planet *origin, *target;

- (void)createFor:(Planet *)planet points:(float)points target:(Planet *)target color:(UIColor *)c level:(NSInteger)level;
- (void)sync:(float)distance;
- (void)setGrey;

@end
