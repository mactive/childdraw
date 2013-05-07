//
//  ListItemView.h
//  childDraw
//
//  Created by meng qian on 13-5-7.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListItemView : UIView

@property(readwrite, nonatomic)NSUInteger buttonIndex;

- (void)setAvatar:(NSString *)filename;

@end
