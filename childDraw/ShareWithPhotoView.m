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
@property(strong, nonatomic)UIButton *shareButton;
@end

@implementation ShareWithPhotoView
@synthesize cricleView;
@synthesize delegate;
@synthesize photoButton;
@synthesize shareButton;

#define PHOTO_WIDTH 128
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.photoButton setFrame:CGRectMake(100, 60, PHOTO_WIDTH, PHOTO_WIDTH)];
        [self.photoButton setBackgroundImage:[UIImage imageNamed:@"camera_button.png"] forState:UIControlStateNormal];
        [self.photoButton setBackgroundImage:[UIImage imageNamed:@"camera_clicked.png"] forState:UIControlStateHighlighted];
        [self.photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.cricleView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.cricleView.layer setCornerRadius:60.0f];
        [self.cricleView.layer setMasksToBounds:YES];
        
        self.noticeLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 200, 240, 40)];
        self.noticeLabel.backgroundColor = [UIColor clearColor];
        self.noticeLabel.text= T(@"快拍下孩子的创意吧，分享出去。");
        self.noticeLabel.textAlignment = UITextAlignmentCenter;
        self.noticeLabel.font = [UIFont systemFontOfSize:14.0f];
        self.noticeLabel.numberOfLines = 0;
        self.noticeLabel.textColor = GRAYCOLOR;
        
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.shareButton setFrame:CGRectMake(66, 260, 188, 43)];
        [self.shareButton setBackgroundImage:[UIImage imageNamed:@"button_bg.png"] forState:UIControlStateNormal];
        [self.shareButton setBackgroundImage:[UIImage imageNamed:@"button_highlight_bg.png"] forState:UIControlStateHighlighted];
        [self.shareButton setTitle:T(@"分享到微信") forState:UIControlStateNormal];
        [self.shareButton setTitleColor:DARKCOLOR forState:UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        [self.shareButton setEnabled:NO];
        
        
        [self addSubview:self.noticeLabel];
        [self addSubview:self.photoButton];
        [self addSubview:self.cricleView];
        [self addSubview:self.shareButton];

    }
    return self;
}

- (void)photoAction
{
    [self.delegate passStringValue:PHOTOACTION andIndex:1];
}


- (void)shareAction
{
    [self.delegate passStringValue:SHAREACTION andIndex:1];
}

- (void)photoSuccess:(UIImage *)image
{
    [self.cricleView setFrame:CGRectMake(104, 63, 120, 120)];
    [self.cricleView setImage:image];
    

    self.noticeLabel.text = T(@"你可以分享拉");
    [self.shareButton setEnabled:YES];

}

- (void)removePhoto
{
    [self.cricleView setFrame:CGRectZero];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    //

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
