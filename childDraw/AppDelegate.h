//
//  AppDelegate.h
//  childDraw
//
//  Created by meng qian on 13-3-22.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "WXApi.h"

@class ListViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) NSString *LIBRARYPATH;
@property (strong, nonatomic) ListViewController *listViewContorller;

@end
