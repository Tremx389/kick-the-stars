//
//  UIColor+HEX.m
//  Kick the Stars
//
//  Created by Szabó Bendegúz on 03/05/14.
//  Copyright (c) 2014 User. All rights reserved.
//

@implementation UIColor(MBCategory)

+ (UIColor *)colorWithHexString:(NSString *)str {
    if ([str characterAtIndex:0] != '#') {
        str = [NSString stringWithFormat:@"#%@", str];
    }
    const char * cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr + 1, NULL, 16);
    return [UIColor colorWithHex:x];
}

+ (UIColor *)colorWithHex:(long)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r / 255.0f green:(float)g / 255.0f blue:(float)b / 255.0f alpha:1];
}

@end