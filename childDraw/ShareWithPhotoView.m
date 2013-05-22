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
@property(strong, nonatomic)UIButton *shareButton;
@property(strong, nonatomic)UIImageView *frameView;
@property(strong, nonatomic)UIImageView *photoImage;

@property(strong, nonatomic)UIButton *sButton_1;
@property(strong, nonatomic)UIButton *sButton_2;
@property(strong, nonatomic)UIButton *sButton_3;
@property(assign, nonatomic)BOOL isOpen;

@end

@implementation ShareWithPhotoView
@synthesize delegate;
@synthesize photoButton;
@synthesize shareButton;
@synthesize sButton_1,sButton_2,sButton_3;
@synthesize isOpen;

#define PHOTO_WIDTH 128

#define PI_WIDTH    220.0f
#define PI_HEIGHT   300.0f

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
        
        
        self.noticeLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 200, 240, 40)];
        self.noticeLabel.backgroundColor = [UIColor clearColor];
        self.noticeLabel.text= T(@"快拍下宝宝的精彩瞬间吧！");
        self.noticeLabel.textAlignment = UITextAlignmentCenter;
        self.noticeLabel.font = [UIFont systemFontOfSize:14.0f];
        self.noticeLabel.numberOfLines = 0;
        self.noticeLabel.textColor = GRAYCOLOR;
        
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.shareButton setFrame:CGRectMake(119, 260, 82, 82)];
        [self.shareButton setBackgroundImage:[UIImage imageNamed:@"button_share.png"] forState:UIControlStateNormal];
        [self.shareButton setBackgroundImage:[UIImage imageNamed:@"button_highlight_share.png"] forState:UIControlStateHighlighted];
        [self.shareButton addTarget:self action:@selector(shareButtonAnimation) forControlEvents:UIControlEventTouchUpInside];
        [self.shareButton setEnabled:NO];
        [self.shareButton setAlpha:0.3];
        
        self.frameView = [[UIImageView alloc]initWithFrame:CGRectMake((TOTAL_WIDTH - BG_WIDTH)/2, 0, BG_WIDTH, BG_HEIGHT)];
        [self.frameView setImage:[UIImage imageNamed:@"item_bg.png"]];
        
        self.photoImage = [[UIImageView alloc]initWithFrame:CGRectMake( (BG_WIDTH-PI_WIDTH)/2, (BG_HEIGHT - PI_HEIGHT)/2, PI_WIDTH, PI_HEIGHT)];
        [self.photoImage setContentMode:UIViewContentModeScaleAspectFit];
        [self.frameView addSubview:self.photoImage];

        
        // button 
        self.sButton_1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sButton_1 setFrame:CGRectMake(66, 240, 60, 60)];
        [self.sButton_1 setBackgroundImage:[UIImage imageNamed:@"button_share_1.png"] forState:UIControlStateNormal];
        [self.sButton_1 setBackgroundImage:[UIImage imageNamed:@"button_share_1_highlight.png"] forState:UIControlStateHighlighted];
        [self.sButton_1 addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.sButton_1 setHidden:YES];
        self.sButton_1.tag = 1;
        
        
        self.sButton_2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sButton_2 setFrame:CGRectMake(130, 200, 60, 60)];
        [self.sButton_2 setBackgroundImage:[UIImage imageNamed:@"button_share_2.png"] forState:UIControlStateNormal];
        [self.sButton_1 setBackgroundImage:[UIImage imageNamed:@"button_share_2_highlight.png"] forState:UIControlStateHighlighted];
        [self.sButton_2 addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.sButton_2 setHidden:YES];
        self.sButton_2.tag = 2;

        
        self.sButton_3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sButton_3 setFrame:CGRectMake(193, 240, 60, 60)];
        [self.sButton_3 setBackgroundImage:[UIImage imageNamed:@"button_share_3.png"] forState:UIControlStateNormal];
        [self.sButton_1 setBackgroundImage:[UIImage imageNamed:@"button_share_3_highlight.png"] forState:UIControlStateHighlighted];
        [self.sButton_3 addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.sButton_3 setHidden:YES];
        self.sButton_3.tag = 3;

        
        
        [self addSubview:self.photoButton];
        [self addSubview:self.noticeLabel];
        
        [self addSubview:self.frameView];
        [self addSubview:self.shareButton];
        
        [self addSubview:self.sButton_1];
        [self addSubview:self.sButton_2];
        [self addSubview:self.sButton_3];

        [self.frameView setHidden:YES];
        
        self.isOpen = NO;
            
    }
    return self;
}

- (void)photoAction
{
    [self.delegate passStringValue:PHOTOACTION andIndex:1];
}




////////////////////////////////////////////////////////////////
#pragma mark - share button action
////////////////////////////////////////////////////////////////

- (void)shareAction:(UIButton *)sender
{
    if (sender.tag == 1) {
        [self.delegate passStringValue:SHAREWEIBO andIndex:sender.tag];
    }else if(sender.tag == 2){
        [self.delegate passStringValue:SHAREWECHAT andIndex:sender.tag];
    }else if(sender.tag == 3){
        [self.delegate passStringValue:SHAREWECHATFRIEND andIndex:sender.tag];
    }
    
}


- (void)shareButtonAnimation
{
    if (!self.isOpen) {
        [self.sButton_1 setHidden:NO];
        [self.sButton_2 setHidden:NO];
        [self.sButton_3 setHidden:NO];
        
        [self.sButton_1 setAlpha:0];
        [self.sButton_2 setAlpha:0];
        [self.sButton_3 setAlpha:0];

        
        [self moveYOffest:-10 andDelay:0   andAlpha:1 withView:self.sButton_1];
        [self moveYOffest:-10 andDelay:0.2 andAlpha:1 withView:self.sButton_2];
        [self moveYOffest:-10 andDelay:0.3 andAlpha:1 withView:self.sButton_3];
        
        self.isOpen = YES;
    }else{
        [self moveYOffest:10 andDelay:0   andAlpha:0 withView:self.sButton_1];
        [self moveYOffest:10 andDelay:0.2 andAlpha:0 withView:self.sButton_2];
        [self moveYOffest:10 andDelay:0.3 andAlpha:0 withView:self.sButton_3];
        
         self.isOpen = NO;
    }    
}

////////////////////////////////////////////////////////////////
#pragma mark - photo success and remove
////////////////////////////////////////////////////////////////

- (void)photoSuccess:(UIImage *)image
{
    self.noticeLabel.text = T(@"分享是一种美德。");

    [self.frameView setHidden:NO];
    [self.photoImage setImage:image];
    
    [self.shareButton setAlpha:1.0];
    [self.shareButton setEnabled:YES];
}

- (void)removePhoto
{
    [self.frameView setHidden:YES];
    [self.shareButton setEnabled:NO];
    [self.shareButton setAlpha:0.3];
    [self.sButton_1 setHidden:YES];
    [self.sButton_2 setHidden:YES];
    [self.sButton_3 setHidden:YES];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    //

}

- (void)moveYOffest:(CGFloat)offset andDelay:(CGFloat)delay andAlpha:(CGFloat)alpha withView:(UIView *)targetView
{
    CGRect rect = targetView.frame;
    
    rect.origin.y = rect.origin.y + offset ;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelay:delay];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    targetView.alpha = alpha;
    targetView.frame = rect;    
    [UIView commitAnimations];

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
