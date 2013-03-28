//
//  MainViewController.m
//  childDraw
//
//  Created by meng qian on 13-3-22.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "MainViewController.h"
#import "AlbumViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "JSONKit/JSONKit.h"

@interface MainViewController ()
@property(strong, nonatomic)UIImageView *titleImage;
@property(strong, nonatomic)AlbumViewController *pageViewController;
@property(strong, nonatomic)UIButton *enterButton;
@property(strong, nonatomic)UIButton *button1;
@property(strong, nonatomic)NSArray *albumArray;
@property(strong, nonatomic)UIImageView *animArea;
@end

@implementation MainViewController
@synthesize pageViewController;
@synthesize titleImage;
@synthesize enterButton;
@synthesize albumArray;
@synthesize button1;
@synthesize animArea;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Intro";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.enterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.enterButton setTitle:@"Enter" forState:UIControlStateNormal];
    
    [self.enterButton setFrame:CGRectMake(60, 300, 200, 40)];
    [self.enterButton addTarget:self action:@selector(enterAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.enterButton];
    
    self.pageViewController = [[AlbumViewController alloc] init];
    
	// Do any additional setup after loading the view.
    
    self.albumArray = [[NSArray alloc]initWithObjects:
                       [UIImage imageNamed:@"1.png"],
                       [UIImage imageNamed:@"2.png"],
                       [UIImage imageNamed:@"3.png"],
                       [UIImage imageNamed:@"4.png"],
                       [UIImage imageNamed:@"5.png"],
                       nil];
    
    
    id json = [self.albumArray JSONString];
    NSLog(@"%@",json);
    
    //button1
    self.button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button1.frame = CGRectMake(0, 0, 320, 290);
    [self.button1 setTitle:@"" forState:UIControlStateNormal];
    [self.button1 addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
    self.button1.alpha = 1;
    self.button1.tag = 0;
    [self.view addSubview:self.button1];
    
    
    NSArray *happyDays  = [[NSArray alloc] initWithObjects:
                           [UIImage imageNamed:@"hh1.png"],
                           [UIImage imageNamed:@"hh2.png"],
                           [UIImage imageNamed:@"hh3.png"],
                           [UIImage imageNamed:@"hh4.png"],
                           [UIImage imageNamed:@"hh5.png"],
                           [UIImage imageNamed:@"hh6.png"],
                           [UIImage imageNamed:@"hh7.png"],
                           [UIImage imageNamed:@"hh8.png"],
                           nil];
    
    
    self.animArea = [[UIImageView alloc] initWithFrame:CGRectMake(60, 40, 200, 200)];
    self.animArea.animationImages = happyDays;
    self.animArea.animationRepeatCount = 0;
    self.animArea.animationDuration = 1.2;
    
    [self.animArea startAnimating];
    // that is overall seconds. hence: frames divided by about 30 or 20.
    [self.view addSubview:self.animArea];
}

- (void)enterAction
{
    
    self.pageViewController.albumArray = self.albumArray;
    self.pageViewController.titleArray = [[NSArray alloc]initWithObjects:
    T(@"两个圈圈放中间"),T(@"眼在头上身描边"),T(@"四个小腿画下面"),T(@"最后加上耳鼻眼"),T(@"咩. 咩. 咩. "), nil];
    //    albumViewController.albumIndex = sender.tag;
    [self.pageViewController setHidesBottomBarWhenPushed:YES];
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:self.pageViewController animated:YES];

}


-(void) playSound {
    

    
    SystemSoundID completeSound;
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"sheep" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
    AudioServicesPlaySystemSound (completeSound);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
