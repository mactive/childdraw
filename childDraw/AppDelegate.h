//
//  AppDelegate.h
//  childDraw
//
//  Created by meng qian on 13-3-22.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "SlideListViewController.h"
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) SlideListViewController *listViewController;
@property (strong, nonatomic) NSString *ASSETPATH;
@property (strong, nonatomic) NSString *THUMBNAILPATH;
@property (strong, nonatomic) NSString *CACHEILPATH;
@property (assign, nonatomic) NSUInteger scrollIndex;
@property (assign, nonatomic) UIImage *photoImage;

- (void)downloadLastFiles:(NSInteger)count;

- (void)startMainSession;
@end
