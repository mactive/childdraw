//
//  ThumbnailUIButton.h
//  childDraw
//
//  Created by meng qian on 13-4-7.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbnailUIButton : UIButton
@property(readwrite, nonatomic)NSUInteger buttonIndex;

- (void)setAvatar:(NSString *)filename;
@end
