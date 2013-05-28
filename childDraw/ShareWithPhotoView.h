//
//  ShareWithPhotoView.h
//  childDraw
//
//  Created by meng qian on 13-4-9.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PassValueDelegate.h"

@interface ShareWithPhotoView : UIView

@property(nonatomic,assign) NSObject<PassValueDelegate> *delegate;
@property(strong, nonatomic)UILabel *noticeLabel;
@property(strong, nonatomic)UIButton *photoButton;
@property(strong, nonatomic)UIImageView *photoImage;

- (void)photoSuccess:(UIImage *)image;
- (void)removePhoto;
- (void)showTip:(NSString *)notification;
- (void)hideTip;
- (void)shareButtonAnimation;
@end
