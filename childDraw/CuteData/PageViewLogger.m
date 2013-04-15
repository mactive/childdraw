//
//  PageViewLogger.m
//  jiemo
//
//  Created by Xiaosi Li on 12/14/12.
//  Copyright (c) 2012 oyeah. All rights reserved.
//

#import "PageViewLogger.h"
#import "CuteData.h"

@interface PageViewLogger ()

@property (nonatomic, strong) id <UINavigationControllerDelegate> navDelegate;
@property (nonatomic, strong) id <UITabBarControllerDelegate> tabDelegate;

@end

@implementation PageViewLogger

@synthesize navDelegate;
@synthesize tabDelegate;

- (id)initWithNavDelegate:(id<UINavigationControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.navDelegate = delegate;
        self.tabDelegate = nil;
    }
    return self;
}
- (id)initWithTabDelegate:(id<UITabBarControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.navDelegate = nil;
        self.tabDelegate = delegate;
    }
    return self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.navDelegate) {
        [self.navDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
    [XFox logEvent:[NSString stringWithFormat:@"P_%@", [[viewController class] description]]];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (self.tabDelegate) {
        [self.tabDelegate tabBarController:tabBarController didSelectViewController:viewController];
    }
    [XFox logEvent:[NSString stringWithFormat:@"P_%@", [[viewController class] description]]];
}

@end
