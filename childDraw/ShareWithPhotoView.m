//
//  ShareWithPhotoView.m
//  childDraw
//
//  Created by meng qian on 13-4-9.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "ShareWithPhotoView.h"
#import <QuartzCore/QuartzCore.h>

@interface ShareWithPhotoView()
@property(strong, nonatomic)UIImageView *cricleView;
@property(strong, nonatomic)UIButton *photoButton;
@property(strong, nonatomic)UILabel *noticeLabel;
@end

@implementation ShareWithPhotoView
@synthesize cricleView;
@synthesize delegate;
@synthesize photoButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.photoButton setFrame:CGRectMake(100, 60, 120, 120)];
        [self.photoButton setBackgroundImage:[UIImage imageNamed:@"camera_button.png"] forState:UIControlStateNormal];
        [self.photoButton setBackgroundImage:[UIImage imageNamed:@"camera_clicked.png"] forState:UIControlStateHighlighted];
        [self.photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.cricleView = [[UIImageView alloc]initWithFrame:self.photoButton.frame];
        [self.cricleView.layer setCornerRadius:60.0f];
        [self.cricleView.layer setMasksToBounds:YES];
        
        self.noticeLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 160, 240, 40)];
        self.noticeLabel.backgroundColor = [UIColor clearColor];
        self.noticeLabel.text= T(@"下一个版本就会有分享功能哟。");
        self.noticeLabel.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:self.noticeLabel];
        [self addSubview:self.photoButton];
        [self addSubview:self.cricleView];

        [self.cricleView setHidden:YES];
    }
    return self;
}

- (void)photoAction
{
    [self.delegate passStringValue:PHOTOACTION andIndex:1];
}

- (void)afterPhoto:(UIImage *)image
{
    [self.cricleView setHidden:NO];
    [self.cricleView setImage:image];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
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
