//
//  AboutUsViewController.m
//  childDraw
//
//  Created by meng qian on 13-4-10.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()
@property(strong, nonatomic)UIImageView *drawImageView;
@property(strong, nonatomic)UIImageView *aboutImageView;
@property(strong, nonatomic)UILabel *aboutLabel;
@property(strong, nonatomic)UIButton *adviseButton;
@property(strong, nonatomic)UIButton *rateButton;
@end

@implementation AboutUsViewController
@synthesize drawImageView, aboutImageView;
@synthesize aboutLabel;
@synthesize adviseButton, rateButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define DRAW_WIDTH 230.0f
#define DRAW_HEIGHT 100.0f

#define ABOUT_L_WIDTH 270.0f
#define ABOUT_L_HEIGHT 80.0f

#define ABOUT_WIDTH 176.0f
#define ABOUT_HEIGHT 120.0f



- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat sep;

    if (IS_IPHONE_5) {
        sep = 35.0f;
    }else{
        sep = 15.0f;
    }
    
	// Do any additional setup after loading the view.
    self.title = T(@"关于我们");
    self.drawImageView = [[UIImageView alloc]initWithFrame:CGRectMake((TOTAL_WIDTH - DRAW_WIDTH)/2, sep/2, DRAW_WIDTH, DRAW_HEIGHT)];
    self.drawImageView.image = [UIImage imageNamed:@"about_draw.png"];
    
    self.aboutLabel = [[UILabel alloc]initWithFrame:CGRectMake((TOTAL_WIDTH - ABOUT_L_WIDTH)/2, DRAW_HEIGHT +sep, ABOUT_L_WIDTH, ABOUT_L_HEIGHT)];
    self.aboutLabel.text = T(@"每天更新的简笔画，享受和孩子一起画画的时光 :)\n\n清新的选材，清晰的分步教学，有乐趣的互动。让我们一起秀出孩子们精彩的创意吧！");
    self.aboutLabel.textColor = DARKCOLOR;
    self.aboutLabel.font = [UIFont systemFontOfSize:12.0f];
    self.aboutLabel.numberOfLines = 0;
    self.aboutLabel.backgroundColor = [UIColor clearColor];
    
    self.aboutImageView = [[UIImageView alloc]initWithFrame:CGRectMake((TOTAL_WIDTH - ABOUT_WIDTH)/2, DRAW_HEIGHT + ABOUT_L_HEIGHT + 60 +sep*3, ABOUT_WIDTH, ABOUT_HEIGHT)];
    self.aboutImageView.image = [UIImage imageNamed:@"about_team.png"];
    
    self.adviseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.adviseButton setTitle:@"Enter" forState:UIControlStateNormal];
    [self.adviseButton setFrame:CGRectMake(15, DRAW_HEIGHT+ABOUT_L_HEIGHT +sep*2, 140, 43)];
    [self.adviseButton setBackgroundImage:[UIImage imageNamed:@"lite_button_bg.png"] forState:UIControlStateNormal];
    [self.adviseButton setBackgroundImage:[UIImage imageNamed:@"lite_button_highlight_bg.png"] forState:UIControlStateHighlighted];
    [self.adviseButton setTitle:T(@"建议或反馈") forState:UIControlStateNormal];
    [self.adviseButton setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    [self.adviseButton addTarget:self action:@selector(adviseAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.rateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rateButton setTitle:@"Enter" forState:UIControlStateNormal];
    [self.rateButton setFrame:CGRectMake(165, DRAW_HEIGHT+ABOUT_L_HEIGHT +sep*2, 140, 43)];
    [self.rateButton setBackgroundImage:[UIImage imageNamed:@"lite_button_bg.png"] forState:UIControlStateNormal];
    [self.rateButton setBackgroundImage:[UIImage imageNamed:@"lite_button_highlight_bg.png"] forState:UIControlStateHighlighted];
    [self.rateButton setTitle:T(@"给个好评") forState:UIControlStateNormal];
    [self.rateButton setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    [self.rateButton addTarget:self action:@selector(rateAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.drawImageView];
    [self.view addSubview:self.aboutLabel];
    [self.view addSubview:self.aboutImageView];
    [self.view addSubview:self.adviseButton];
    [self.view addSubview:self.rateButton];
    
}

- (void)adviseAction
{
    NSString *emailStr = [NSString stringWithFormat:@"mailto:%@",FEEDBACK_EMAIL];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailStr]];
}

- (void)rateAction
{
    NSString *str = [NSString stringWithFormat:
                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",
                     M_APPLEID ];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
