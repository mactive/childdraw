//
//  PageViewLogger.h
//  jiemo
//
//  Created by Xiaosi Li on 12/14/12.
//  Copyright (c) 2012 oyeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PageViewLogger : NSObject <UINavigationControllerDelegate, UITabBarControllerDelegate>


- (id)initWithNavDelegate:(id<UINavigationControllerDelegate>)delegate;
- (id)initWithTabDelegate:(id<UITabBarControllerDelegate>)delegate;

@end
