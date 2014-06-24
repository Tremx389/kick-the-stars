//
//  ViewController.m
//  Kick The Stars
//
//  Created by Szabó Bendegúz on 30/04/14.
//  Copyright (c) 2014 User. All rights reserved.
//

#import "ViewController.h"

#import "GameScene.h"
#import <CoreImage/CoreImage.h>
#import <CoreImage/CoreImageDefines.h>

#import <UIKit/UIGestureRecognizer.h>
#import <UIKit/UITapGestureRecognizer.h>
#import <UIKit/UIPanGestureRecognizer.h>
#import <UIKit/UILongPressGestureRecognizer.h>

#import "MenuScreen.h"

@implementation ViewController{
    GameScene *gS;

    // tap
    Planet *building;
    
    // pan
    Planet *initial, *temporarilySelected;
    CGFloat sX, sY;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SKView *skView = (SKView *)self.view;
    skView.showsFPS = YES;
//    skView.showsPhysics = YES;
//    skView.showsNodeCount = YES;
//    skView.showsDrawCount = YES;
    
    gS = [GameScene sceneWithSize:skView.bounds.size];
    [gS setScaleMode:SKSceneScaleModeAspectFill];
    [gS.physicsWorld setGravity:CGVectorMake(0, 0)];
    [gS.physicsWorld setSpeed:0.0389];
    [skView presentScene:gS];
    
    [gS.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];
    [gS.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)]];
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    longPress.minimumPressDuration = 0.25;
    [gS.view addGestureRecognizer:longPress];
}

- (void)tapGesture:(UITapGestureRecognizer *)recogziner {
//    if (building) {
//        [building finishLoading:gS.sun];
//        building = nil;
//    } else {
    CGPoint location = [recogziner locationInView:gS.view];
    location.y = gS.size.height - location.y;
    if (gS.stage == FIRST_MENU) {
        Button touchedBtn = [gS.menu buttonIn:location];
        if (touchedBtn == START) {
            [gS start];
        }
    } else if (gS.stage == PAUSED) {
        Button touchedBtn = [gS.menu buttonIn:location];
        if (touchedBtn == RESTART) {
            [gS restart];
        } else if (distanceBetween(location, gS.pauseButton.position) < 50) {
            [gS pause];
        } else {
            [gS pause];
        }
    } else if (gS.stage == IN_GAME) {
        if (distanceBetween(location, gS.pauseButton.position) < 50) {
            [gS pause];
        } else {
            Planet *p = [gS getNearestPlanet:location];
            if (p) {
                [gS selectPlanet:p];
            } else {
//                BOOL found = NO;
//                for (Planet *p in gS.planets) {
//                    if (p != gS.sun && p.selected && p.planetType == FRIENDLY) {
//                        found = YES;
//                        break;
//                    }
//                }
//                if (found) {
                [gS deselectAllPlanets];
//                } else {
//                    float d = distanceBetween(location, gS.sun.position);
//                    if (gS.points > 0 && d < OUTER_MAP_SIZE && d > SUN_CATCHMENT_AREA && ([gS numOf:INDEPENDENT] == 0 || d > INNER_MAP_SIZE)) {
//                        building = [gS buildFriendlyPlanetIn:location];
//                    }
//                }
            }
        }
    }
//    }
}

- (void)longPressGesture:(UITapGestureRecognizer *)recogziner {
    CGPoint location = [recogziner locationInView:gS.view];
    location.y = gS.size.height - location.y;
    if (gS.stage == IN_GAME) {
        if (recogziner.state == UIGestureRecognizerStateBegan) {
            float d = distanceBetween(location, gS.sun.position);
            if (gS.points > 0 && d > SUN_CATCHMENT_AREA) {
                if (d < OUTER_MAP_SIZE && ([gS numOf:INDEPENDENT] == 0 || d > INNER_MAP_SIZE)) {
                    building = [gS buildFriendlyPlanetIn:location];
                } else {
                    [gS stageAlert];
                }
            }
        } else if (recogziner.state == UIGestureRecognizerStateEnded && building) {
            [building finishLoading:gS.sun];
            building = nil;
        }
    }
}

- (void)panGesture:(UITapGestureRecognizer *)recogziner {
    if (gS.stage == IN_GAME) {
        CGPoint location = [recogziner locationInView:gS.view];
        location.y = gS.size.height - location.y;
        if (recogziner.state == UIGestureRecognizerStateBegan) {
            initial = [gS getNearestPlanet:location];
            if (initial) {
                [initial setSelected];
            } else {
                sX = location.x;
                sY = location.y;
            }
            if (initial.planetType != FRIENDLY) {
                initial = nil;
            }
        }
        if (initial) {
            if (recogziner.state == UIGestureRecognizerStateChanged) {
                Planet *p = [gS getNearestPlanet:location];
                if (p && p != gS.sun && p != initial) {
                    if (temporarilySelected && temporarilySelected != p) {
                        [temporarilySelected setDeselected];
                    }
                    if (!p.selected) {
                        temporarilySelected = p;
                    }
                    [p removeAim];
                    gS.target = p;
                    [p setSelected];
                } else {
                    [initial search:location];
                }
            } else if (recogziner.state == UIGestureRecognizerStateEnded) {
                if (gS.target) {
                    [gS deployUnits];
                }
                if (temporarilySelected) {
                    temporarilySelected = nil;
                }
                [initial endSearch];
                initial = nil;
            }
        } else if (sX > 0 || sY > 0) {
            if (recogziner.state == UIGestureRecognizerStateChanged) {
                [gS scroll:CGPointMake(location.x - sX, location.y - sY)];
                sX = location.x;
                sY = location.y;
            } else if (recogziner.state == UIGestureRecognizerStateEnded) {
                sX = 0;
                sY = 0;
            }
        }
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
