//
//  GameScene.h
//  Kick The Stars
//

//  Copyright (c) 2014 User. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "CGVector+TC.h"

#import "MathLibrary.h"

#import "Planet.h"
#import "MenuScreen.h"

@interface GameScene : SKScene

typedef enum {
    PAUSED,
    FIRST_MENU,
    IN_GAME
} GameStage;

@property (nonatomic) SKNode *sun;
@property (nonatomic) SKNode *pauseButton;
@property (nonatomic) NSMutableArray *planets;
@property (nonatomic) float points;

@property (nonatomic) Planet *target;
@property (nonatomic) MenuScreen *menu;
@property (nonatomic) GameStage stage;

- (Planet *)buildFriendlyPlanetIn:(CGPoint)location;
- (Planet *)getNearestPlanet:(CGPoint)location;
- (void)selectPlanet:(Planet *)planet;
- (void)deselectAllPlanets;
- (int)numOf:(PlanetType)planetType;

- (void)moveGalaxyBy:(CGPoint)center diff:(CGPoint)diff initPoint:(CGPoint)initPoint;

- (void)deployUnits;
- (void)scroll:(CGPoint)diff;
- (void)stageAlert;
- (void)solarFlare;

- (void)pause;
- (void)start;
- (void)restart;

@end