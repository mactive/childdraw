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

@interface SettingViewController ()
@property(strong, nonatomic)UIButton *clearButton;
@property(strong, nonatomic)NSArray *assetContent;
@end

@implementation SettingViewController
@synthesize clearButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = BGCOLOR;
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clearButton setFrame:CGRectMake(20, 80, TOTAL_WIDTH-40,50)];

    [self.clearButton setTitle:T(@"清除缓存") forState:UIControlStateNormal];
    [self.clearButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -100, 0, 0)];
    [self.clearButton setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    
    self.clearButton.layer.cornerRadius = 5.0f;
    self.clearButton.layer.shadowColor = DARKCOLOR.CGColor;
    self.clearButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.clearButton.layer.shadowRadius = 1;
    self.clearButton.layer.shadowOpacity = 0.4;
    
    [self.clearButton setImage:[UIImage imageNamed:@"clear_icon.png"] forState:UIControlStateNormal];
    [self.clearButton setImageEdgeInsets:UIEdgeInsetsMake(0, 230, 0, 0)];
    
    [self.clearButton setBackgroundColor:[UIColor whiteColor]];
    
    [self.clearButton addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.clearButton];
    
    [self initTopView];
    
    [self calcCacheSize];
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
    [self calcCacheSize];

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
    titleLabel.textColor = DARKCOLOR;
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
