//
//  ServerDataTransformer.h
//  childDraw
//
//  Created by meng qian on 13-4-9.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerDataTransformer : NSObject

+ (NSString *)getStringObjFromServerJSON:(id)jsonData byName:(NSString *)name;
+ (NSNumber *)getNumberObjFromServerJSON:(id)jsonData byName:(NSString *)name;

+ (NSString *)convertNumberToStringIfNumber:(id)obj;
+ (NSNumber *)convertStringToNumberIfString:(id)obj;

@end
