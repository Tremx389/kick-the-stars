//
//  UIColor+HEX.h
//  Kick the Stars
//
//  Created by Szabó Bendegúz on 03/05/14.
//  Copyright (c) 2014 User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor(MBCategory)

+ (UIColor *)colorWithHexString:(NSString *)str;
+ (UIColor *)colorWithHex:(long)col;

@end