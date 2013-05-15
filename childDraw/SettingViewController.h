//
//  SettingViewController.h
//  childDraw
//
//  Created by meng qian on 13-4-8.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBCustomBackButtonViewController.h"
#import "WeiboSDK.h"

@interface SettingViewController : BBCustomBackButtonViewController<WeiboSignInDelegate,WeiboRequestDelegate>
{
    WeiboSignIn *_weiboSignIn;
}

@end
