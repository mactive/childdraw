//
//  PassValueDelegate.h
//  childDraw
//
//  Created by meng qian on 13-4-3.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PassValueDelegate <NSObject>

@optional
-(void)passStringValue:(NSString *)value andIndex:(NSUInteger )index;
-(void)passNumberValue:(NSNumber *)value andIndex:(NSUInteger )index;
-(void)passNumberValue:(NSNumber *)value andTitle:(NSString *)title;
-(void)passNSDateValue:(NSDate *)value andIndex:(NSUInteger)index;

@end
