//
//  PlistManager.h
//  Manna
//
//  Created by Szabó Bendegúz on 31/10/13.
//  Copyright (c) 2013 User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistManager : NSObject

+ (NSDictionary *)read:(NSString *)name;
//+ (void)write:(NSString *)name withData:(NSMutableDictionary *)dictionary;

@end
