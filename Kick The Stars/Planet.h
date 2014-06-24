//
//  Planet.h
//  Kick the Stars
//
//  Created by Szabó Bendegúz on 02/06/14.
//  Copyright (c) 2014 User. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Unit.h"

const int MAX_RADIUS = 50;

const int MAP_MARGIN = 10;
const int INNER_MAP_SIZE = 768 / 3 - MAP_MARGIN;
const int OUTER_MAP_SIZE = 768 / 2 - MAP_MARGIN;

const int SUN_CATCHMENT_AREA = 21;

typedef enum {
    FRIENDLY,
    ENEMY,
    INDEPENDENT
} PlanetType;

@class Unit;

@interface Planet : SKNode

@property (nonatomic) PlanetType planetType;
@property (nonatomic) float scale, radius, points;
@property (nonatomic) BOOL selected, hasSearch;

//- (void)addLocation:(CGPoint)location;
//- (CGPoint)lastLocation;

- (void)createIn:(CGPoint)position as:(PlanetType)type skin:(NSString *)skin;
- (void)setLoadingTo:(float)percent;
- (void)finishLoading:(SKNode *)sun;
- (void)setLightDistance:(float)distance radians:(float)radians;
- (void)pushoutFromSun:(SKNode *)sun;

- (void)setSelected;
- (void)setDeselected;

- (void)setType:(PlanetType)planetType;
- (void)setScaleTo:(float)scale;

- (void)setPointsTo:(float)p;
- (void)setPointsBy:(float)p;

- (void)aim:(Planet *)p;
- (void)removeAim;
- (void)search:(CGPoint)p;
- (void)endSearch;

- (void)hitBy:(Unit *)unit;
- (void)changePriorityTo:(PlanetType)planetType;

- (void)sync:(Planet *)p;

@end