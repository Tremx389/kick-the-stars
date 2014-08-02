//
//  NSArray+RandomObject.m
//  Kick the Stars
//
//  Created by Szabó Bendegúz on 20/06/14.
//  Copyright (c) 2014 User. All rights reserved.
//

#import "NSArray+RandomObject.h"
#import "MathLibrary.h"

@implementation NSArray (RandomObject)

- (NSString *)randomString {
    return [self objectAtIndex:arc4random() % self.count];
}

@end
