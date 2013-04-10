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
@property(strong, nonatomic)UIButton *enterButton;
@end

@implementation AboutUsViewController
@synthesize drawImageView, aboutImageView;
@synthesize aboutLabel;

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
	// Do any additional setup after loading the view.
    self.title = T(@"关于我们");
    self.drawImageView = [[UIImageView alloc]initWithFrame:CGRectMake((TOTAL_WIDTH - DRAW_WIDTH)/2, 10, DRAW_WIDTH, DRAW_HEIGHT)];
    self.drawImageView.image = [UIImage imageNamed:@"about_draw.png"];
    
    self.aboutLabel = [[UILabel alloc]initWithFrame:CGRectMake((TOTAL_WIDTH - ABOUT_L_WIDTH)/2, DRAW_HEIGHT +20, ABOUT_L_WIDTH, ABOUT_L_HEIGHT)];
    self.aboutLabel.text = T(@"每天更新的简笔画，享受和孩子一起画画的时光。\n\n清新的选材，清晰的分步教学，有乐趣的互动。让我们一起绚出孩子们精彩的创意吧。");
    self.aboutLabel.textColor = DARKCOLOR;
    self.aboutLabel.font = [UIFont systemFontOfSize:12.0f];
    self.aboutLabel.numberOfLines = 0;
    self.aboutLabel.backgroundColor = [UIColor clearColor];
    
    self.aboutImageView = [[UIImageView alloc]initWithFrame:CGRectMake((TOTAL_WIDTH - ABOUT_WIDTH)/2, DRAW_HEIGHT + ABOUT_L_HEIGHT +90, ABOUT_WIDTH, ABOUT_HEIGHT)];
    self.aboutImageView.image = [UIImage imageNamed:@"about_team.png"];
    
    self.enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.enterButton setTitle:@"Enter" forState:UIControlStateNormal];
    [self.enterButton setFrame:CGRectMake(56, 215, 188, 43)];
    [self.enterButton setBackgroundImage:[UIImage imageNamed:@"button_bg.png"] forState:UIControlStateNormal];
    [self.enterButton setBackgroundImage:[UIImage imageNamed:@"button_highlight_bg.png"] forState:UIControlStateHighlighted];
    [self.enterButton setTitle:T(@"建议或反馈") forState:UIControlStateNormal];
    [self.enterButton setTitleColor:DARKCOLOR forState:UIControlStateNormal];
    [self.enterButton addTarget:self action:@selector(enterAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.drawImageView];
    [self.view addSubview:self.aboutLabel];
    [self.view addSubview:self.aboutImageView];
    [self.view addSubview:self.enterButton];
    
}

- (void)enterAction
{
    NSString *emailStr = [NSString stringWithFormat:@"mailto:%@",FEEDBACK_EMAIL];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailStr]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end