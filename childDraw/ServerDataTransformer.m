//
//  ServerDataTransformer.m
//  childDraw
//
//  Created by meng qian on 13-4-9.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "ServerDataTransformer.h"

#define DATETIME_FORMATE @"yyyy-MM-dd hh:mm:ss"
#define DATE_FORMATE @"yyyy-MM-dd"

@interface ServerDataTransformer()


@end

@implementation ServerDataTransformer

+(NSString *)getStringObjFromServerJSON:(id)jsonData byName:(id)name
{
    id obj = [jsonData valueForKey:name];
    if (obj == nil) return @"";
    
    return [self convertNumberToStringIfNumber:obj];
}

+ (NSNumber *)getNumberObjFromServerJSON:(id)jsonData byName:(NSString *)name
{
    id obj = [jsonData valueForKey:name];
    if (obj == nil) return [NSNumber numberWithInt:0];
    
    return [self convertStringToNumberIfString:obj];
}

+ (NSString *)convertNumberToStringIfNumber:(id)obj
{
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj stringValue];
    }
    return obj;
}

+ (NSNumber *)convertStringToNumberIfString:(id)obj
{
    if ([obj isKindOfClass:[NSString class]]) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * myNumber = [f numberFromString:obj];
        return myNumber;
    }
    return obj;
}


@end
