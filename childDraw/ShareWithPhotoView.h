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
- (void)afterPhoto:(UIImage *)image;
@end
