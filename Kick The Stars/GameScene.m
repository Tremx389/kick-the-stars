//
//  KTSGameScene.m
//  Kick The Stars
//
//  Created by Szabó Bendegúz on 30/04/14.
//  Copyright (c) 2014 User. All rights reserved.
//

#import "GameScene.h"
#import "ViewController.h"

#import "Unit.h"
#import "Robot.h"

#import "NSArray+RandomObject.h"

#import "UIColor+HEX.h"

const float STAR_DISTANCE = 0.1;

const int DEFAULT_POINTS = 801;

const int INDEPENDENT_PLANETS = 5;

const float BUILD_DURATION = 2.65;
const float BUILD_WAIT = 0.01;

const float MAX_STAR_SIZE = 50;

const float SCROLL_SMOOTH = 150;

@implementation GameScene {
    SKShapeNode /**inner_border, */*outer_border, *pauseCircle;
    SKNode *pauseLine1, *pauseLine2;
    SKLabelNode *scoreLabel;
    
    NSMutableArray *stars, *units;
    NSArray *planetSkins;
    
    float scrollSunX, scrollSunY, scrollFirstX, scrollFirstY;
    
    Robot *eR;
    
    CIFilter *bumpDistortion;
}

- (id)initWithSize:(CGSize)size {
    _points = DEFAULT_POINTS;
    
    _planets = [NSMutableArray new];
    stars = [NSMutableArray new];
    units = [NSMutableArray new];
    
    planetSkins  = [NSArray arrayWithObjects:@"planet_bg_2",
                                             @"planet_bg_3",
                                             @"planet_bg_4",
                                             @"planet_bg_5", nil];
    
//    root = [[SKNode alloc] init];
    if (self = [super initWithSize:size]) {
        SKEffectNode *node = [SKEffectNode node];
        bumpDistortion = [CIFilter filterWithName:@"CIHoleDistortion"];
        [bumpDistortion setValue:@65.0f forKey:kCIInputRadiusKey];
//        [bumpDistortion setValue:@60.0f forKey:kCIInputAngleKey];
//        bumpDistortion = [CIFilter filterWithName:@"CIHoleDistortion"];
//        [bumpDistortion setValue:@75.0f forKey:kCIInputRadiusKey];
        [node setFilter:bumpDistortion];
        [self setRoot:node];
        [node setShouldCenterFilter:NO];
//        [node setShouldEnableEffects:YES];
        [self addChild:_root];
        
//        float duration = 10;
//        [_root runAction:[SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime){
//            NSNumber *radius = [NSNumber numberWithFloat:(elapsedTime/duration) * 100.0];
//            [bumpDistortion setValue:radius forKey:kCIInputRadiusKey];
//            [bumpDistortion setValue:radius forKey:kCIInputScaleKey];
//            [bumpDistortion setValue: [CIVector vectorWithX:300 Y:150] forKey: kCIInputCenterKey];
//        }]];
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background.jpg"];
        [background setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
        [background setScale:0.36];
        [background setZPosition:-999];
        [_root addChild:background];
        
//        for (int i = 0; i < 70; i++) {
//            [self drawStarMin:2 max:7 flashing:0.7];
//        }
        for (int i = 0; i < 25; i++) {
            [self drawStarMin:5 max:10 flashing:0.6];
        }
        for (int i = 0; i < 5; i++) {
            [self drawStarMin:11 max:17 flashing:0.4];
        }
        for (int i = 0; i < 3; i++) {
            [self drawStarMin:18 max:22 flashing:0.2];
        }
        
        outer_border = [SKShapeNode node];
        outer_border.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-OUTER_MAP_SIZE, -OUTER_MAP_SIZE, OUTER_MAP_SIZE * 2, OUTER_MAP_SIZE * 2)].CGPath;
        outer_border.lineWidth = 0.1;
        outer_border.strokeColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
        [self addChild:outer_border];
        
//        inner_border = [SKShapeNode node];
//        inner_border.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-INNER_MAP_SIZE, -INNER_MAP_SIZE, INNER_MAP_SIZE * 2, INNER_MAP_SIZE * 2)].CGPath;
//        inner_border.lineWidth = 0.1;
//        inner_border.strokeColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
//        inner_border.alpha = 0.1;
//        [self addChild:inner_border];
  
        _sun = [[SKNode alloc] init];
//        _sun = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"sun" ofType:@"sks"]];
//        SKSpriteNode *sunLight = [SKSpriteNode spriteNodeWithImageNamed:@"sun_light.png"];
//        [sunLight setAlpha:0.5];
//        [_sun addChild:sunLight];
        [_root addChild:_sun];

        [self initPauseButton];
//        [self initMenu];
        
//        [self runAction:[SKAction repeatActionForever:[SKAction customActionWithDuration:10 actionBlock:^(SKNode *node, CGFloat elapsedTime){
//            for (SKSpriteNode *star in stars) {
//                float distance = distanceBetween(_sun.position, star.position);
//                
//                if (distance > SUN_CATCHMENT_AREA) {
//                    float boost = (1 - EaseOutCubic(distance / self.size.height)) * 5;
//                    star.position = pointInCircle(star.position, (star.size.width / MAX_STAR_SIZE * STAR_DISTANCE) * boost, radiansBetween(star.position, _sun.position));
//                } else {
//                    [star runAction:[SKAction scaleTo:0 duration:1] completion:^{
//                        
//                    }];
//                }
//            }
//        }]]];
        
        scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Oranienbaum-Regular"];
        scoreLabel.fontSize = 25;
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        scoreLabel.position = CGPointMake(30, 20);
        scoreLabel.zPosition = 3;
        [self addChild:scoreLabel];
        
        // FIRST MENU SCENE
        [self.pauseButton setHidden:YES];
        [scoreLabel setHidden:YES];
        _stage = FIRST_MENU;
        _menu = [[MenuScreen node] initFirstMenuIn:self];
        [self moveElementsBy:CGPointMake(self.size.width - 100, 100) withDuration:0];
        [self buildIndependentPlanets];
    }
    return self;
}

- (void)drawStarMin:(float)min max:(float)max flashing:(float)flashing {
    float duration = 2;
    float size = min + (1 - EaseOutCirc(randomFloat(0, 1))) * (max - min);
    float fAlpha = randomFloat(0, 1);
    
    SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"star.png"];
    [star setSize:CGSizeMake(size * 2, size * 2)];
    [star setPosition:CGPointMake(randomFloat(0, self.frame.size.width), randomFloat(0, self.frame.size.height))];
    [star setAlpha:fAlpha];
    [star runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:1 duration:duration * fAlpha],
                                         [SKAction repeatActionForever:[SKAction group:@[[SKAction sequence:@[[SKAction fadeAlphaTo:1 - flashing duration:duration / 2], [SKAction fadeAlphaTo:1 duration:duration / 2]]],
                                                                                         [SKAction sequence:@[[SKAction scaleTo:1 * ((size / max) / (size / max)) duration:duration / 2], [SKAction scaleTo:1 duration:duration / 2]]]]]]]]];
    [stars addObject:star];
    [_root addChild:star];
}

- (Planet *)buildFriendlyPlanetIn:(CGPoint)location {
    Planet *planet = [Planet node];
    [planet createIn:location as:FRIENDLY skin:[planetSkins randomString]];
    [planet setLightDistance:distanceBetween(_sun.position, planet.position) radians:radiansBetween(_sun.position, planet.position)];
    [_planets addObject:planet];
    [_root addChild:planet];
    
    [planet runAction:[SKAction group:@[[SKAction customActionWithDuration:BUILD_DURATION - BUILD_WAIT actionBlock:^(SKNode *node, CGFloat elapsedTime){
        float p1 = (elapsedTime + BUILD_WAIT) / BUILD_DURATION;
        float percent = EaseOutCirc(p1);
        
        [planet setScaleTo:percent];
        [planet setLoadingTo:percent];
        [planet setPointsTo:percent * 100];
        [self managePointsBy:-2];
        if (self.points <= 0 || percent == 1) {
            [planet finishLoading:_sun];
        }
    }], [SKAction repeatActionForever:[SKAction playSoundFileNamed:@"build_planet.wav" waitForCompletion:YES]]]] withKey:@"planetCreating"];
    return planet;
}

- (void)buildIndependentPlanets {
    float step = OUTER_MAP_SIZE / (INDEPENDENT_PLANETS + 1);
    for (int i = 0; i < INDEPENDENT_PLANETS; i++) {
        float scale = powf(randomFloat(0.25, 1), 2.5);
        scale = scale < 0.25 ? 0.25 : scale;
        
        Planet *independentPlanet = [Planet node];
        [independentPlanet createIn:_sun.position as:INDEPENDENT skin:[planetSkins randomString]];
        [independentPlanet setLightDistance:distanceBetween(_sun.position, independentPlanet.position) radians:radiansBetween(_sun.position, independentPlanet.position)];
        [independentPlanet setScaleTo:scale];
        [independentPlanet setPointsTo:150 * scale];
        [_planets addObject:independentPlanet];
        [_root addChild:independentPlanet];
        
        float startAngle = randomFloat(0, 180 / M_PI);
        float distance_r = (step) * (i + 1);
        float duration = 210 * distance_r / OUTER_MAP_SIZE;
        CGPathRef path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0) radius:distance_r startAngle:startAngle endAngle:M_PI * 2 + startAngle clockwise:1].CGPath;
        [independentPlanet runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction followPath:path asOffset:YES orientToPath:NO duration:duration], [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime){
            independentPlanet.position = _sun.position;
        }]]]]];
    }
}

- (Planet *)getNearestPlanet:(CGPoint)location {
    float distance = MAX_RADIUS;
    Planet *nearestPlanet;
    for (Planet *planet in _planets) {
        float d = distanceBetween(location, planet.position);
        if (d < distance) {
            distance = d;
            nearestPlanet = planet;
        }
    }
    return nearestPlanet;
}

- (int)numOf:(PlanetType)planetType {
    int n = 0;
    for (Planet *p in _planets) {
        if (p.planetType == planetType) {
            n++;
        }
    }
    return n;
}

- (void)moveStarsBy:(CGPoint)diff withDuration:(float)duration {
    if (duration > 0) {
        for (SKSpriteNode *star in stars) {
            CGPoint from = star.position;
            CGPoint relativeDiff = CGPointMake((diff.x * star.size.width / MAX_STAR_SIZE) * STAR_DISTANCE, (diff.y * star.size.width / MAX_STAR_SIZE) * STAR_DISTANCE);

            SKAction *starAction = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime){
                float t = EaseInOut(elapsedTime / duration);
                
                CGPoint nextPos = CGPointMake(from.x + relativeDiff.x * t, from.y + relativeDiff.y * t);
                if (nextPos.x > self.size.width) {
                    nextPos = CGPointMake(nextPos.x - self.size.width, nextPos.y);
                } else if (nextPos.x < 0) {
                    nextPos = CGPointMake(nextPos.x + self.size.width, nextPos.y);
                }
                if (nextPos.y > self.size.height) {
                    nextPos = CGPointMake(nextPos.x, nextPos.y - self.size.height);
                } else if (nextPos.y < 0) {
                    nextPos = CGPointMake(nextPos.x, nextPos.y + self.size.height);
                }
                
                star.position = nextPos;
            }];
            [star runAction:starAction];
        }
    } else {
        for (SKSpriteNode *star in stars) {
            CGPoint nextPos = CGPointMake(star.position.x + diff.x * star.size.width / MAX_STAR_SIZE * STAR_DISTANCE, star.position.y + diff.y * star.size.width / MAX_STAR_SIZE * STAR_DISTANCE);
            if (nextPos.x > self.size.width) {
                nextPos = CGPointMake(nextPos.x - self.size.width, nextPos.y);
            } else if (nextPos.x < 0) {
                nextPos = CGPointMake(nextPos.x + self.size.width, nextPos.y);
            }
            if (nextPos.y > self.size.height) {
                nextPos = CGPointMake(nextPos.x, nextPos.y - self.size.height);
            } else if (nextPos.y < 0) {
                nextPos = CGPointMake(nextPos.x, nextPos.y + self.size.height);
            }
            
            star.position = nextPos;
        }
    }
}

- (void)moveElementsBy:(CGPoint)diff withDuration:(float)duration {
    if (duration > 0) {
        SKAction *action = [SKAction moveBy:*((CGVector *)&diff) duration:duration];
        action.timingMode = SKActionTimingEaseInEaseOut;
        
        
        CGPoint lastGalaxyCenter = _sun.position;
        [_sun runAction:[SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime){
            float percent = EaseInOut(elapsedTime / duration);
            _sun.position = CGPointMake(lastGalaxyCenter.x + diff.x * percent, lastGalaxyCenter.y + diff.y * percent);
            [bumpDistortion setValue:[CIVector vectorWithX:_sun.position.x * 2 + 30 Y:_sun.position.y * 2 + 170] forKey:kCIInputCenterKey];
            
        }]];
        [outer_border runAction:action];
//        [inner_border runAction:action];
        
//        CGPoint distortionStartPos = _sun.position;
//        [self runAction:[SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime){
//            [bumpDistortion setValue:[CIVector vectorWithX:_sun.position.x * 2 + 30 Y:_sun.position.y * 2 + 170] forKey:kCIInputCenterKey];
//        }]];
        
        for (Unit *unit in units) {
            [unit runAction:action];
        }
        for (Planet *planet in _planets) {
            [planet runAction:action];
        }
    } else {
        _sun.position = CGPointMake(outer_border.position.x + diff.x, outer_border.position.y + diff.y);
        outer_border.position = CGPointMake(outer_border.position.x + diff.x, outer_border.position.y + diff.y);
//        inner_border.position = CGPointMake(inner_border.position.x + diff.x, inner_border.position.y + diff.y);
        for (Unit *unit in units) {
            unit.position = CGPointMake(unit.position.x + diff.x, unit.position.y + diff.y);
        }
        for (Planet *planet in _planets) {
            planet.position = CGPointMake(planet.position.x + diff.x, planet.position.y + diff.y);
        }
        
        [bumpDistortion setValue:[CIVector vectorWithX:_sun.position.x * 2 + 30 Y:_sun.position.y * 2 + 170] forKey:kCIInputCenterKey];
    }
}

- (void)moveGalaxyBy:(CGPoint)center diff:(CGPoint)diff initPoint:(CGPoint)initPoint {
//    _sun.position = CGPointMake(<#CGFloat x#>, <#CGFloat y#>)
//    _sun.position = CGPointMake(inner_border.position.x + diff.x, inner_border.position.y + diff.y);
//    outer_border.position = CGPointMake(outer_border.position.x + diff.x, outer_border.position.y + diff.y);
//    inner_border.position = CGPointMake(inner_border.position.x + diff.x, inner_border.position.y + diff.y);
//    for (Unit *unit in units) {
//        unit.position = CGPointMake(unit.position.x + diff.x, unit.position.y + diff.y);
//    }
//    for (Planet *planet in _planets) {
//        planet.position = CGPointMake(planet.position.x + diff.x, planet.position.y + diff.y);
//    }
//    for (SKSpriteNode *star in stars) {
//        CGPoint nextPos = CGPointMake(star.position.x + diff.x * star.size.width / MAX_STAR_SIZE * STAR_DISTANCE, star.position.y + diff.y * star.size.width / MAX_STAR_SIZE * STAR_DISTANCE);
//        if (nextPos.x > self.size.width) {
//            nextPos = CGPointMake(nextPos.x - self.size.width, nextPos.y);
//        } else if (nextPos.x < 0) {
//            nextPos = CGPointMake(nextPos.x + self.size.width, nextPos.y);
//        }
//        if (nextPos.y > self.size.height) {
//            nextPos = CGPointMake(nextPos.x, nextPos.y - self.size.height);
//        } else if (nextPos.y < 0) {
//            nextPos = CGPointMake(nextPos.x, nextPos.y + self.size.height);
//        }
//        
//        star.position = nextPos;
//    }
}

- (void)startScroll:(CGPoint)location {
    scrollSunX = self.sun.position.x;
    scrollSunY = self.sun.position.y;
    scrollFirstX = location.x;
    scrollFirstY = location.y;
}

- (void)scroll:(CGPoint)location {
    CGPoint diff = CGPointMake(scrollSunX - _sun.position.x + location.x - scrollFirstX,
                               scrollSunY - _sun.position.y + location.y - scrollFirstY);
    float diffB = _sun.position.y - OUTER_MAP_SIZE + diff.y - MAP_MARGIN;
    float diffT = self.size.height - _sun.position.y - OUTER_MAP_SIZE - diff.y - MAP_MARGIN;
    float diffL = _sun.position.x - OUTER_MAP_SIZE + diff.x - MAP_MARGIN;
    float diffR = self.size.width - _sun.position.x - OUTER_MAP_SIZE - diff.x - MAP_MARGIN;
    if (diffB < 0) {
        diff.y -= diffB;
        if (ABS(diffB) < SCROLL_SMOOTH) {
            diff.y -= powf(EaseOutCubic((ABS(diffB) / SCROLL_SMOOTH)), 2) * SCROLL_SMOOTH;
        } else {
            diff.y -= SCROLL_SMOOTH;
        }
    } else if (diffT < 0) {
        diff.y += diffT;
        if (ABS(diffT) < SCROLL_SMOOTH) {
            diff.y += powf(EaseOutCubic((ABS(diffT) / SCROLL_SMOOTH)), 2) * SCROLL_SMOOTH;
        } else {
            diff.y += SCROLL_SMOOTH;
        }
    }
    if (diffL < 0) {
        diff.x -= diffL;
        if (ABS(diffL) < SCROLL_SMOOTH) {
            diff.x -= powf(EaseOutCubic((ABS(diffL) / SCROLL_SMOOTH)), 2) * SCROLL_SMOOTH;
        } else {
            diff.x -= SCROLL_SMOOTH;
        }
    } else if (diffR < 0) {
        diff.x += diffR;
        if (ABS(diffR) < SCROLL_SMOOTH) {
            diff.x += powf(EaseOutCubic((ABS(diffR) / SCROLL_SMOOTH)), 2) * SCROLL_SMOOTH;
        } else {
            diff.x += SCROLL_SMOOTH;
        }
    }
    
    [self moveElementsBy:diff withDuration:0];
    [self moveStarsBy:diff withDuration:0];
    
//    CIAttributeTypePosition
//    CGAffineTransform *moveTransform = CGAffineTransformMakeTranslation(diff.x, diff.y);
    
    
//    CIFilter *move = [CIFilter filterWithName:@"CIAffineTransform"];
//    [move setValue:[CIVector vectorWithX:_sun.position.x Y:_sun.position.y] forKey:kCIInputCenterKey];
//    [move setValue:clouds forKey:@"inputImage"];
//    [move setValue:moveTransform forKey:@"inputTransform"];
//    clouds = [move valueForKey:@"outputImage"];
}

- (void)endScroll {
    float diffB = _sun.position.y - OUTER_MAP_SIZE - MAP_MARGIN;
    float diffT = self.size.height - _sun.position.y - OUTER_MAP_SIZE - MAP_MARGIN;
    float diffL = _sun.position.x - OUTER_MAP_SIZE - MAP_MARGIN;
    float diffR = self.size.width - _sun.position.x - OUTER_MAP_SIZE - MAP_MARGIN;
    
    CGPoint diff = CGPointMake(diffL < 0 ? -diffL : diffR < 0 ? diffR : 0, diffT < 0 ? diffT : diffB < 0 ? -diffB : 0);

    [self moveElementsBy:diff withDuration:0.15];
    [self moveStarsBy:diff withDuration:0.15];
    
    scrollFirstX = 0;
    scrollFirstY = 0;
    scrollSunX = 0;
    scrollSunY = 0;
}
//- (void)scroll:(CGPoint)diff {
//    if (_sun.position.y - OUTER_MAP_SIZE + diff.y < MAP_MARGIN) {
//        NSLog(@"B");
//        diff.y -= _sun.position.y - OUTER_MAP_SIZE + diff.y - MAP_MARGIN;
//    }
//    if (self.size.height - _sun.position.y - OUTER_MAP_SIZE - diff.y < MAP_MARGIN) {
//        NSLog(@"T");
//        diff.y += self.size.height - _sun.position.y - OUTER_MAP_SIZE - diff.y - MAP_MARGIN;
//    }
//    if (_sun.position.x - OUTER_MAP_SIZE + diff.x < MAP_MARGIN) {
//        NSLog(@"L: %f", _sun.position.x + diff.x);
//        diff.x -= _sun.position.x - OUTER_MAP_SIZE + diff.x - MAP_MARGIN;
//    }
//    if (self.size.width - _sun.position.x - OUTER_MAP_SIZE - diff.x < MAP_MARGIN) {
//        NSLog(@"R");
//        diff.x += self.size.width - _sun.position.x - OUTER_MAP_SIZE - diff.x - MAP_MARGIN;
//    }
//    [self moveElementsBy:diff withDuration:0];
//    [self moveStarsBy:diff withDuration:0];
//}

- (void)initPauseButton {
    self.pauseButton = [[SKNode alloc] init];
    CGSize pauseSize = CGSizeMake(25, 32);

    int diff = pauseSize.width / 3;
    
    self.pauseButton.zPosition = 3;

    UIColor *lineColor = [UIColor colorWithRed:0.666 green:0.666 blue:0.666 alpha:1];
    
    pauseLine1 = [[SKSpriteNode alloc] initWithColor:lineColor size:CGSizeMake(pauseSize.width / 3, pauseSize.height)];
    pauseLine1.position = CGPointMake(diff, 0);
    [self.pauseButton addChild:pauseLine1];
    
    pauseLine2 = [[SKSpriteNode alloc] initWithColor:lineColor size:CGSizeMake(pauseSize.width / 3, pauseSize.height)];
    pauseLine2.position = CGPointMake(-diff, 0);
    [self.pauseButton addChild:pauseLine2];
    
    [self.pauseButton setPosition: CGPointMake(self.size.width - 35, self.size.height - 40)];
    [self addChild:self.pauseButton];
}

- (void)update:(CFTimeInterval)currentTime {
    for (int i = 0; i < _planets.count; i++) {
        Planet *actualPlanet = [_planets objectAtIndex:i];
        [actualPlanet sync:(Planet *)_sun];
        if (actualPlanet.planetType != INDEPENDENT) {
            for (int j = 0; j < [_planets count]; j++) {
                Planet *otherPlanet = [_planets objectAtIndex:j];
                if (otherPlanet != actualPlanet) {
                    [actualPlanet sync:otherPlanet];
                }
            }
        }
        if (actualPlanet.planetType == FRIENDLY && actualPlanet.selected && self.target && self.target != actualPlanet) {
            [actualPlanet aim:_target];
        }

        float distance = distanceBetween(actualPlanet.position, _sun.position);
        if (distance < 0) {
            [actualPlanet runAction:[SKAction group:@[[SKAction moveTo:_sun.position duration:0.21], [SKAction scaleTo:0 duration:0.21]]] completion:^{
                [self managePointsBy:-actualPlanet.points];
                
                [actualPlanet removeFromParent];
            }];
            [_planets removeObject:actualPlanet];
        } else if (actualPlanet.planetType != INDEPENDENT && distance - actualPlanet.radius > OUTER_MAP_SIZE) {
            [actualPlanet changePriorityTo:INDEPENDENT];
        } else {
            [actualPlanet setLightDistance:distance radians:radiansBetween(_sun.position, actualPlanet.position)];
            if (actualPlanet.planetType != INDEPENDENT) {
                [actualPlanet setPointsBy:actualPlanet.scale * 0.03];
            }
        }
    }
    for (int i = 0; i < units.count; i++) {
        Unit *unit = [units objectAtIndex:i];
        float distance = distanceBetween(unit.position, unit.target.position) - unit.target.radius - unit.radius;
        float sunDistance = distanceBetween(unit.position, _sun.position);
        if (distance < 2) {
            [unit.target hitBy:unit];
            [unit removeAllChildren];
            [unit removeFromParent];
            [units removeObject:unit];
            i--;
        } else {
            if (sunDistance <= OUTER_MAP_SIZE) {
                [unit sync:distance];
            } else {
                [unit setGrey];
            }
        }
        if (sunDistance <= SUN_CATCHMENT_AREA || (sunDistance > OUTER_MAP_SIZE && (unit.position.x < 0 || unit.position.x > self.size.width || unit.position.y < 0 || unit.position.y > self.size.height))) {
            [self managePointsBy:unit.points];
            [unit removeAllChildren];
            [unit removeFromParent];
            [units removeObject:unit];
            i--;
        }
    }
    scoreLabel.text = [NSString stringWithFormat:@"%.f", _points > 0 ? round(_points) : 0];
}

- (BOOL)managePointsBy:(float)points {
    if (_points + points >= 0) {
        _points += points;
        [scoreLabel runAction:[SKAction sequence:@[[SKAction scaleBy:(ABS(points) > 5 ? 1.5 : 1.15) duration:0.15], [SKAction scaleTo:1 duration:0.15]]]];
        return YES;
    }
    return NO;
}

- (void)selectPlanet:(Planet *)planet {
    if (planet.selected != YES) {
        [planet setSelected];
        [self runAction:[SKAction playSoundFileNamed:@"select.wav" waitForCompletion:NO]];
    } else {
        int numOfSelected = 0;
        if ([self numOf:planet.planetType] > 1 && planet.selected) {
            for (Planet *p in _planets) {
                if (p.planetType == planet.planetType && p.selected) {
                    numOfSelected++;
                }
            }
        }
        if (numOfSelected == 1) {
            for (Planet *p in _planets) {
                if (p.planetType == planet.planetType) {
                    [p setSelected];
                }
            }
            [self runAction:[SKAction playSoundFileNamed:@"select.wav" waitForCompletion:NO]];
        } else {
            [self runAction:[SKAction playSoundFileNamed:@"deselect.wav" waitForCompletion:NO]];
            [planet setDeselected];
        }
    }
}

- (void)deselectAllPlanets {
    for (Planet *p in _planets) {
        [p setDeselected];
    }
}

- (void)deployUnits {
    NSArray *colorLevels = [NSArray arrayWithObjects:@[@"1",    @"#FAFAD2"],
                                                     @[@"10",   @"#D99058"],
                                                     @[@"50",   @"#C4302B"],
                                                     @[@"100",  @"#66023C"],
                                                     @[@"500",  @"#007BBB"],
                                                     @[@"1000", @"#EEEFBE"], nil];
    if (self.target) {
        float usage = 0.75;
        for (Planet *planet in _planets) {
            if (planet.selected == YES && planet.planetType == FRIENDLY && planet != self.target) {
                int points = planet.points * usage;
                for (NSInteger i = colorLevels.count - 1; i >= 0; i--) {
                    NSArray *a = [colorLevels objectAtIndex:i];
                    int value = [a[0] intValue];
                    
                    int numOfIt = floorf(points / value);
                    for (int j = 0; j < numOfIt; j++) {
                        Unit *unit = [Unit node];
                        [unit createFor:planet points:value target:self.target color:[UIColor colorWithHexString:a[1]] level:(i > 2) ? 2 : i];
                        [units addObject:unit];
                        [_root addChild:unit];
                    }
                    points -= numOfIt * value;
                }
                
                planet.hasSearch = NO;
                [planet removeAim];
                [planet setPointsTo:planet.points * (1 - usage)];
                [planet setDeselected];
            }
        }
        [self deselectAllPlanets];
        self.target = nil;
    }
}

- (void)pause {
    CGSize pauseSize = CGSizeMake(25, 32);
    int diff = pauseSize.width / 3;
    int correction = -8;
    float duration = 0.2;
    
    CGPoint line1Pos = CGPointMake(diff, 0), line2Pos = CGPointMake(-diff, 0);

    [self runAction:[SKAction playSoundFileNamed:@"pause.wav" waitForCompletion:NO]];
    [self.pauseButton runAction:[SKAction sequence:@[[SKAction scaleTo:2 duration:duration / 2], [SKAction scaleTo:1 duration:duration / 2]]]];
    if (!self.view.paused) {
        __block float minCompletions = 4, iCompletions = 0;
        
        pauseCircle = [SKShapeNode node];
        pauseCircle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-25, -25, 25 * 2, 25 * 2)].CGPath;
        pauseCircle.lineWidth = 2;
        pauseCircle.strokeColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
        pauseCircle.alpha = 0;
        [pauseCircle runAction:[SKAction sequence:@[[SKAction waitForDuration:duration / 2], [SKAction fadeAlphaBy:1 duration:duration / 2]]] completion:^{
            iCompletions++; if (iCompletions == minCompletions) { _stage = PAUSED; self.view.paused = YES;}
        }];
        [self.pauseButton addChild:pauseCircle];
        
        _menu = [[MenuScreen node] initPauseMenuIn:self];
        _menu.zPosition = 1;
        _menu.alpha = 0;
        [_menu runAction:[SKAction fadeAlphaTo:1 duration:duration] completion:^{
            iCompletions++; if (iCompletions == minCompletions) { _stage = PAUSED; self.view.paused = YES;}
        }];
        
        [pauseLine1 setPosition:line1Pos];
        [pauseLine1 runAction:[SKAction group:@[[SKAction rotateByAngle:M_PI / 180 * 45 duration:duration], [SKAction moveToX: line1Pos.x + correction duration:duration]]] completion:^{
            iCompletions++; if (iCompletions == minCompletions) { _stage = PAUSED; self.view.paused = YES;}
        }];
        [pauseLine2 setPosition:line2Pos];
        [pauseLine2 runAction:[SKAction group:@[[SKAction rotateByAngle:M_PI / 180 * -45 duration:duration], [SKAction moveToX:line2Pos.x - correction duration:duration]]] completion:^{
            iCompletions++; if (iCompletions == minCompletions) { _stage = PAUSED; self.view.paused = YES;}
        }];
    } else {
        self.view.paused = NO;
        
        [pauseCircle removeFromParent];
        
        [pauseLine1 runAction:[SKAction group:@[[SKAction rotateByAngle:M_PI / 180 * -45 duration:duration], [SKAction moveToX: line2Pos.x duration:duration]]]];
        [pauseLine2 runAction:[SKAction group:@[[SKAction rotateByAngle:M_PI / 180 * 45 duration:duration], [SKAction moveToX:line1Pos.x duration:duration]]]];
        
        [_menu runAction:[SKAction fadeAlphaTo:0 duration:duration] completion:^{
            [_menu removeFromParent];
            
            
        }];
        
        _stage = IN_GAME;
    }
}

- (void)start {
    float duration = 1.5;
    CGPoint center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    [self moveStarsBy:CGPointMake(-center.x, center.y) withDuration:duration];
    [self moveElementsBy:CGPointMake(-(_sun.position.x - center.x), center.y - _sun.position.y) withDuration:duration];
    [self runAction:[SKAction playSoundFileNamed:@"pause.wav" waitForCompletion:NO]];

    [_menu runAction:[SKAction customActionWithDuration:1.5 actionBlock:^(SKNode *node, CGFloat elapsedTime){
        [_menu setAlpha:1 - elapsedTime / duration];
    }] completion:^{
        _stage = IN_GAME;
        eR = [[Robot alloc] init:self];
        
        [self.pauseButton setHidden:NO];
        [self.pauseButton setAlpha:0];
        [self.pauseButton runAction:[SKAction fadeAlphaTo:1 duration:0.5]];
        [scoreLabel setHidden:NO];
        [scoreLabel setAlpha:0];
        [scoreLabel runAction:[SKAction fadeAlphaTo:1 duration:0.5]];
        
        [_menu removeFromParent];
    }];
}

- (void)solarFlare {
//    float duration = 2;
//    [root runAction:[SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime){
//        NSNumber *radius = [NSNumber numberWithFloat:(elapsedTime/duration) * OUTER_MAP_SIZE];
//        [bumpDIstortion setValue:radius forKey:kCIInputRadiusKey];
//    }] completion:^{
//        [root runAction:[SKAction customActionWithDuration:0.5 actionBlock:^(SKNode *node, CGFloat elapsedTime){
//            float percent = 0.5 / elapsedTime;
//            NSNumber *radius = [NSNumber numberWithFloat:-(0.5 - 0.5 / percent)];
//            [bumpDIstortion setValue:radius forKey:kCIInputScaleKey];
//            [bumpDIstortion setValue:@0.0 forKey:kCIInputRadiusKey];
//        }]];
//    }];
}

- (void)restart {
    [self removeAllActions];
    eR = [[Robot alloc] init:self];
    
    _points = DEFAULT_POINTS;
    for (int i = 0; i < units.count; i++) {
        Unit *unit = [units objectAtIndex:i];
        [unit removeFromParent];
        [units removeObject:unit];
        i--;
    }
    
    for (int i = 0; i < _planets.count; i++) {
        Planet *planet = [_planets objectAtIndex:i];
        [planet removeFromParent];
        [_planets removeObject:planet];
        i--;
    }
    _planets = [NSMutableArray new];
    
    [self buildIndependentPlanets];
    [self pause];
}

- (void)stageAlert {
//    float duration = 0.5;
//    inner_border.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.15];
//    [inner_border runAction:[SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime){
//        float percent = EaseOutCirc(elapsedTime / duration);
//        percent = (percent <= 0.5) ? percent * 2 : (1 - percent) * 2;
//        
//        inner_border.lineWidth = 3 * percent > 0.25 ? 3 * percent : 0.25;
//        inner_border.alpha = percent > 0.1 ? percent * 0.7 : 0.1;
//    }] completion:^{
//        inner_border.fillColor = nil;
//    }];
}

@end