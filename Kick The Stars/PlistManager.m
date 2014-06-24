//
//  PlistManager.m
//  Manna
//
//  Created by Szabó Bendegúz on 31/10/13.
//  Copyright (c) 2013 User. All rights reserved.
//

#import "PlistManager.h"

@implementation PlistManager

+ (NSDictionary *)read:(NSString *)name {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString     *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    NSData       *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    return temp;
}

//+ (void)write:(NSString *)name withData:(NSMutableDictionary *)dictionary {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", name]];
//    if (![[NSFileManager defaultManager] fileExistsAtPath: path]) {
//        path = [[paths objectAtIndex:0] stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.plist", name]];
//    }
//    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
//    if ([[NSFileManager defaultManager] fileExistsAtPath: path]) {
//        data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
//    } else {
//        data = [[NSMutableDictionary alloc] init];
//    }
//    
//    data = dictionary;
//    
//    [data writeToFile:path atomically:YES];
//}
@end
