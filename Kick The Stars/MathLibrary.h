//
//  MathLibrary.h
//  Kick The Stars
//
//  Created by Szabó Bendegúz on 26/05/14.
//  Copyright (c) 2014 User. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>

static inline float randomFloat(float Min, float Max) {
    return ((arc4random() % RAND_MAX) / (float)RAND_MAX) * (Max - Min) + Min;
}

static inline float distanceBetween(CGPoint point1, CGPoint point2) {
    return sqrt(powf(point2.x - point1.x, 2) + powf(point2.y - point1.y, 2));
}

static inline float radiansBetween(CGPoint point1, CGPoint point2) {
    return atan2f(point1.y - point2.y, point1.x - point2.x);
}

static inline CGPoint pointInCircle(CGPoint here, float radius, float radians) {
    return CGPointMake(here.x - radius * cos(radians), here.y - radius * sin(radians));
}

static inline UIColor *colorBetween(UIColor *a, UIColor *b, float p) {
    const CGFloat * aC = CGColorGetComponents(a.CGColor);
    const CGFloat * bC = CGColorGetComponents(b.CGColor);
    return [UIColor colorWithRed:aC[0] * (1 - p) + bC[0] * p green:aC[1] * (1 - p) + bC[1] * p blue:aC[2] * (1 - p) + bC[2] * p alpha:aC[3] * (1 - p) + bC[3] * p];
}

static inline float EaseInOut(float t) {
    return (t < 0.5f) ? 2.0f * powf(t, 2) : 1.0f - 2.0f * powf(t - 1.0f, 2);
}

static inline float EaseOutCirc(float t) {
 	t /= 1;
	t--;
	return sqrtf(1 - powf(t, 2));
}

static inline float EaseOutCubic(float t) {
    t /= 1;
    t--;
    return powf(t, 3) + 1;
}
