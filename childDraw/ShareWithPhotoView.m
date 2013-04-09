//
//  ShareWithPhotoView.m
//  childDraw
//
//  Created by meng qian on 13-4-9.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "ShareWithPhotoView.h"

@interface ShareWithPhotoView()<UIImagePickerControllerDelegate,UIActionSheetDelegate>
@property(strong, nonatomic)UIImageView *cricleView;
@end

@implementation ShareWithPhotoView
@synthesize cricleView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cricleView = [[UIImageView alloc]initWithFrame:CGRectMake(60, 60, 120, 120)];
        [self.cricleView setImage:[UIImage imageNamed:@"circle_button_bg.png"]];
        [self addSubview:self.cricleView];
    }
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
