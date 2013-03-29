//
//  UINavigationBar+customNavigation.m
//  childDraw
//
//  Created by meng qian on 13-3-28.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "UINavigationBar+customNavigation.h"

@implementation UINavigationBar (customNavigation)

- (CGSize)sizeThatFits:(CGSize)size {
    // size
    CGSize newSize = CGSizeMake(self.frame.size.width,CUSTOM_NAV_HEIGHT);
    
    // text attrbutters
    self.titleTextAttributes =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 RGBCOLOR(64, 70, 76), UITextAttributeTextColor,
                                 [UIColor whiteColor], UITextAttributeTextShadowColor,
                                 [NSValue valueWithUIOffset:UIOffsetMake(0, -1)], UITextAttributeTextShadowOffset,
                                 [UIFont boldSystemFontOfSize:18.0f], UITextAttributeFont,
                                 nil];
    
    return newSize;
}

@end
