//
//  SettingViewController.m
//  childDraw
//
//  Created by meng qian on 13-4-8.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "SettingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "ModelHelper.h"

@interface SettingViewController ()<UIAlertViewDelegate>
@property(strong, nonatomic)UIButton *clearButton;
@property(strong, nonatomic)UIButton *adviseButton;
@property(strong, nonatomic)UIButton *rateButton;
@property(strong, nonatomic)UIButton *weiboButton;
@property(strong, nonatomic)NSArray *assetContent;
@property(strong, nonatomic)UIAlertView *clearAlertView;
@end

@implementation SettingViewController
@synthesize clearButton;
@synthesize adviseButton;
@synthesize rateButton;
@synthesize clearAlertView;
@synthesize weiboButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define BUTTON_H 50
#define BUTTON_W TOTAL_WIDTH-40
#define BUTTON_X 20
#define BUTTON_Y 80
#define BUTTON_Y_OFFSET 20

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = BGCOLOR;
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clearButton setFrame:CGRectMake( BUTTON_X, BUTTON_Y, BUTTON_W,BUTTON_H)];
    [self.clearButton setTitle:T(@"清除缓存") forState:UIControlStateNormal];
    self.clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.clearButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.clearButton setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    self.clearButton.layer.cornerRadius = 5.0f;
    self.clearButton.layer.shadowColor = DARKCOLOR.CGColor;
    self.clearButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.clearButton.layer.shadowRadius = 1;
    self.clearButton.layer.shadowOpacity = 0.4;
    [self.clearButton setImage:[UIImage imageNamed:@"clear_icon.png"] forState:UIControlStateNormal];
    [self.clearButton setImageEdgeInsets:UIEdgeInsetsMake(0, 230, 0, 0)];
    [self.clearButton setBackgroundColor:[UIColor whiteColor]];
    [self.clearButton addTarget:self action:@selector(clearAlertAction) forControlEvents:UIControlEventTouchUpInside];

    self.adviseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.adviseButton setFrame:CGRectMake( BUTTON_X, BUTTON_Y+BUTTON_H+BUTTON_Y_OFFSET, BUTTON_W,BUTTON_H)];
    [self.adviseButton setTitle:T(@"建议或反馈") forState:UIControlStateNormal];
    self.adviseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.adviseButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self.adviseButton setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    self.adviseButton.layer.cornerRadius = 5.0f;
    self.adviseButton.layer.shadowColor = DARKCOLOR.CGColor;
    self.adviseButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.adviseButton.layer.shadowRadius = 1;
    self.adviseButton.layer.shadowOpacity = 0.4;
    [self.adviseButton setImage:[UIImage imageNamed:@"advise_icon.png"] forState:UIControlStateNormal];
    [self.adviseButton setImageEdgeInsets:UIEdgeInsetsMake(0, 230, 0, 0)];
    [self.adviseButton setBackgroundColor:[UIColor whiteColor]];
    [self.adviseButton addTarget:self action:@selector(adviseAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.rateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rateButton setFrame:CGRectMake( BUTTON_X, BUTTON_Y+BUTTON_H*2+BUTTON_Y_OFFSET*2, BUTTON_W,BUTTON_H)];
    [self.rateButton setTitle:T(@"给个好评") forState:UIControlStateNormal];
    self.rateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.rateButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self.rateButton setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    self.rateButton.layer.cornerRadius = 5.0f;
    self.rateButton.layer.shadowColor = DARKCOLOR.CGColor;
    self.rateButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.rateButton.layer.shadowRadius = 1;
    self.rateButton.layer.shadowOpacity = 0.4;
    [self.rateButton setImage:[UIImage imageNamed:@"rate_icon.png"] forState:UIControlStateNormal];
    [self.rateButton setImageEdgeInsets:UIEdgeInsetsMake(0, 230, 0, 0)];
    [self.rateButton setBackgroundColor:[UIColor whiteColor]];
    [self.rateButton addTarget:self action:@selector(rateButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.weiboButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.weiboButton setFrame:CGRectMake( BUTTON_X, BUTTON_Y+BUTTON_H*3+BUTTON_Y_OFFSET*3, BUTTON_W,BUTTON_H)];
    [self.weiboButton setTitle:T(@"绑定微博") forState:UIControlStateNormal];
    self.weiboButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.weiboButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self.weiboButton setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    self.weiboButton.layer.cornerRadius = 5.0f;
    self.weiboButton.layer.shadowColor = DARKCOLOR.CGColor;
    self.weiboButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.weiboButton.layer.shadowRadius = 1;
    self.weiboButton.layer.shadowOpacity = 0.4;
    [self.weiboButton setImage:[UIImage imageNamed:@"weibo_icon.png"] forState:UIControlStateNormal];
    [self.weiboButton setImageEdgeInsets:UIEdgeInsetsMake(0, 230, 0, 0)];
    [self.weiboButton setBackgroundColor:[UIColor whiteColor]];
    [self.weiboButton addTarget:self action:@selector(weiboAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.clearButton];
    [self.view addSubview:self.adviseButton];
    [self.view addSubview:self.rateButton];
    [self.view addSubview:self.weiboButton];
    
    _weiboSignIn = [[WeiboSignIn alloc] init];
    _weiboSignIn.delegate = self;
    
    [self initTopView];
    [self calcCacheSize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *bind = [[NSUserDefaults standardUserDefaults]objectForKey:@"bind_weibo_success"];
    
    if ([bind isEqualToString:@"YES"]) {
        [self.weiboButton setTitle:T(@"绑定成功") forState:UIControlStateNormal];
    }
}

- (void)calcCacheSize
{
    CGFloat totalSize = 0.0f;
    self.assetContent = [[NSArray alloc]init];
    self.assetContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self appDelegate].ASSETPATH
                                                                            error:NULL];

    totalSize += [self fileSizeForDir:[self appDelegate].THUMBNAILPATH];


    for (int count = 0; count < (int)[self.assetContent count]; count++)
    {
        NSString *name = [self.assetContent objectAtIndex:count];
//        NSLog(@"fileDict :%f KB",[self fileSizeForDir:[self appDelegate].ASSETPATH]);
        NSString *path = [NSString stringWithFormat:@"%@/%@",[self appDelegate].ASSETPATH,name];
        totalSize += [self fileSizeForDir:path];
    }

    NSString *size = [NSString stringWithFormat:@"清除缓存  %.2fMB",totalSize/1024];
    [self.clearButton setTitle:size forState:UIControlStateNormal];
}

-(void)clearAlertAction
{
    self.clearAlertView = [[UIAlertView alloc] initWithTitle:T(@"确认清除缓存么? ")
                                                     message:T(@"会删除所有下载过的资源")
                                                    delegate:self
                                           cancelButtonTitle:T(@"取消")
                                           otherButtonTitles:T(@"确认"), nil];
    [self.clearAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.clearAlertView]) {
        if (buttonIndex == 0){
            //cancel clicked ...do your action
        }else if (buttonIndex == 1){
            [self clearAction];
        }
    }
}

-(void)clearAction
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error;
    if ([fileMgr removeItemAtPath:[self appDelegate].THUMBNAILPATH error:&error] == YES){
        NSLog(@"remove thumbnail");
        [fileMgr createDirectoryAtPath:[self appDelegate].THUMBNAILPATH withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    for (int count = 0; count < (int)[self.assetContent count]; count++)
    {
        NSString *name = [self.assetContent objectAtIndex:count];
        NSString *path = [NSString stringWithFormat:@"%@/%@",[self appDelegate].ASSETPATH,name];
        NSString *cachePath = [NSString stringWithFormat:@"%@/%@",[self appDelegate].CACHEILPATH,name];
        
        if ([fileMgr removeItemAtPath:path error:&error] == YES){
            NSLog(@"remove item");
        }
        
        if ([fileMgr removeItemAtPath:cachePath error:&error] == YES){
            NSLog(@"remove cache");
        }
        
    }
    
    // remove all core data
    [[ModelHelper sharedInstance] clearAllObjects];
    [self appDelegate].scrollIndex = 0;
    [[self appDelegate] startMainSession];

}

-(CGFloat)fileSizeForDir:(NSString*)path//计算文件夹下文件的总大小
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    CGFloat size = 0.0;
    
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic=[fileManager attributesOfItemAtPath:fullPath error:nil];
            size+= fileAttributeDic.fileSize;
        }
        else
        {
            [self fileSizeForDir:fullPath];
        }
    }

    return size/1024;
    
}

- (void)weiboAction
{

    [_weiboSignIn signInOnViewController:self];

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



#define TOP_HEIGHT 44.0f
//////////////////////////////////////////////////////////////////////////////////
#pragma mark initTopView
//////////////////////////////////////////////////////////////////////////////////
- (void)initTopView
{
    UIImageView *topView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, TOTAL_WIDTH, TOP_HEIGHT)];
    [topView setImage:[UIImage imageNamed:@"top_bg.png"]];
    [topView setUserInteractionEnabled:YES];
    
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, TOP_HEIGHT)];
    titleLabel.text = T(@"设置");
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = GRAYCOLOR;
    titleLabel.font = [UIFont boldSystemFontOfSize:22.0f];
    titleLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    titleLabel.layer.shadowRadius = 1;
    titleLabel.layer.shadowOpacity = 1;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setTitle:T(@"关闭") forState:UIControlStateNormal];
    [closeButton setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    [closeButton setFrame:CGRectMake(260, 7, 51, 29)];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"top_button.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    
    [topView addSubview:titleLabel];
    [topView addSubview:closeButton];
    [self.view addSubview:topView];
}

-(void)closeAction
{
    [self dismissModalViewControllerAnimated:YES];
}


- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

//////////////////////////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
