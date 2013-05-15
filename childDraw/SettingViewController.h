//
//  SettingViewController.h
//  childDraw
//
//  Created by meng qian on 13-4-8.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBCustomBackButtonViewController.h"
#import "WeiboSignIn.h"

@interface SettingViewController : BBCustomBackButtonViewController<WeiboSignInDelegate>
{
    WeiboSignIn *_weiboSignIn;
}

@end
