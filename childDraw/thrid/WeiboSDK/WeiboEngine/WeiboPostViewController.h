//
//  WeiboPostViewController.h
//  childDraw
//
//  Created by meng qian on 13-5-27.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"

@protocol WeiboPostDelegate

- (void)finishedPostWithStatus:(NSString *)auth andError:(NSError *)error;

@end

@interface WeiboPostViewController : UIViewController
@property (nonatomic, assign) id<WeiboPostDelegate> delegate;
@property(nonatomic, strong)NSString *textString;
@property(nonatomic, strong)UIImage *photoImage;

@end