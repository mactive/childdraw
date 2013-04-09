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
#import "AppNetworkAPIClient.h"
#import "AppDelegate.h"
#import "Zipfile.h"
#import "ModelHelper.h"
#import "PassValueDelegate.h"
#import "ListViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "DDLog.h"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface MainViewController ()<PassValueDelegate>
{
    SystemSoundID completeSound;
}

@property(strong, nonatomic)UIImageView *titleImage;
@property(strong, nonatomic)AlbumViewController *pageViewController;
@property(strong, nonatomic)UIButton *enterButton;
@property(strong, nonatomic)UIButton *transButton;
@property(strong, nonatomic)CATransition* transition;

@property(strong, nonatomic)NSArray *albumArray;
@property(strong, nonatomic)NSArray *animationArray;
@property(strong, nonatomic)NSString *audioPath;
@property(strong, nonatomic)UIImageView *animArea;
@property(strong, nonatomic)UIButton *listButton;
@property(strong, nonatomic)Zipfile *theZipfile;
@property(assign, nonatomic)NSInteger picCount;
@property(assign, nonatomic)NSInteger aniCount;

@property(strong, nonatomic)UIView *mainView;
@property(strong, nonatomic)UIView *downloadView;
@property(strong, nonatomic)UILabel *dlNumber;
@property(strong, nonatomic)UILabel *dlTitle;
@end

@implementation MainViewController
@synthesize pageViewController;
@synthesize titleImage;
@synthesize enterButton;
@synthesize albumArray;
@synthesize animationArray;
@synthesize audioPath;
@synthesize transButton;
@synthesize animArea;
@synthesize listButton;
@synthesize planetString;
@synthesize theZipfile;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize picCount;
@synthesize aniCount;
@synthesize mainView;
@synthesize downloadView;
@synthesize dlNumber,dlTitle;
@synthesize transition;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.listButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 29)];
        [self.listButton setBackgroundImage:[UIImage imageNamed: @"list_button.png"] forState:UIControlStateNormal];
        [self.listButton addTarget:self action:@selector(listAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.listButton];
    }
    return self;
}


- (void)listAction
{
    [self.navigationController.view.layer addAnimation:self.transition forKey:kCATransition];
    [self.navigationController pushViewController:[self appDelegate].listViewContorller animated:NO];
}

- (void)initViewControllers
{

    [self appDelegate].listViewContorller = [[ListViewController alloc]initWithNibName:nil bundle:nil];
    [self appDelegate].listViewContorller.managedObjectContext = self.managedObjectContext;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageViewController = [[AlbumViewController alloc] init];
    
	// Do any additional setup after loading the view.
    
    self.albumArray = [[NSArray alloc]init];
    self.animationArray = [[NSArray alloc]init];
    
    
    // download view
    [self initMainView];
    [self initDownloadView];
    [self initViewControllers];
    
    // transition animation
    self.transition = [CATransition animation];
    self.transition.duration = 0.1;
    self.transition.type = kCATransitionFade;
    self.transition.timingFunction = UIViewAnimationCurveEaseInOut;
    self.transition.subtype = kCATransitionFromLeft;

}
- (void)passNumberValue:(NSNumber *)value andTitle:(NSString *)title
{
//    DDLogVerbose(@"*****%f %@",value.floatValue,title);
    if ([title isEqualToString:self.planetString]) {
        self.dlTitle.text = T(@"Downloading...");
        self.dlNumber.text = [NSString stringWithFormat:@"%.0f%%",value.floatValue*100];
    }
}
- (void)passStringValue:(NSString *)value andIndex:(NSUInteger)index
{
    if ([value isEqualToString:DOWNLOADFINISH]) {
        [self downloadFinish];
    }else if([value isEqualToString:DOWNLOADING]){
        [self.mainView setHidden:YES];
        [self.downloadView setAlpha:1];
        [self.downloadView setHidden:NO];
        self.dlNumber.text = T(@":)");

    }else if ([value isEqualToString:DOWNLOADFAILED])
    {
        [self.mainView setHidden:YES];
        [self.downloadView setAlpha:1];
        [self.downloadView setHidden:NO];
        self.dlNumber.text = T(@":(");
        self.dlTitle.text = T(@"Failed");
    }
}

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - file verify and count  
/////////////////////////////////////////////////////////////////////////////////////
// 整理数据 写数据库
- (void)makeArrayWithString:(NSString *)planet
{
    self.theZipfile = [[ModelHelper sharedInstance]findZipfileWithFileName:planet];
    
    NSString *path = [[self appDelegate].LIBRARYPATH stringByAppendingPathComponent:planet];
    [self listFileAtPath:path];
    
    DDLogVerbose(@"Dictionary path: %@",path);
}

// 检查文件数据 
-(void)listFileAtPath:(NSString *)path
{
    self.picCount = 0;
    self.aniCount = 0;
//    self.albumArray = [[NSArray alloc] init];
//    self.animationArray = [[NSArray alloc] init];
//    self.audioPath = @"";
    
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *name = [directoryContent objectAtIndex:count];
        
        // check picture
        NSRange pRange = [name rangeOfString:@"p"];
        if (pRange.location == 0) {
            self.picCount = self.picCount + 1;
        }
        
        // check animation
        NSRange aRange = [name rangeOfString:@"a"];
        if (aRange.location == 0) {
            self.aniCount = self.aniCount + 1;
        }
//        DDLogVerbose(@"pic %d, ani %d",self.picCount, self.aniCount);

    }
    
    // count 
    self.theZipfile.aniCount = STR_INT(self.aniCount);
    self.theZipfile.picCount = STR_INT(self.picCount);
    
    self.albumArray = [self makeAlbumArrayWithCount:self.picCount andPath:path];
    self.animationArray = [self makeAnimationArrayWithCount:self.aniCount andPath:path];

    self.audioPath = [path stringByAppendingPathComponent:@"/sound.wav"];
    DDLogVerbose(@"path %@ %@ ",path, self.planetString);
    
}

/* 生成数组 make album array */

- (NSArray *)makeAlbumArrayWithCount:(NSInteger)count andPath:(NSString *)path
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < count; i++) {
        NSString *picFilePath = [NSString stringWithFormat:@"%@/p%d.png",path,i];
        UIImage *image = [UIImage imageWithContentsOfFile:picFilePath];
        [tmpArray addObject:image];
    }
    
    NSArray *resultArray = [[NSArray alloc]initWithArray:tmpArray];
    
    return resultArray;
}

/* 生成数组 make animation array */

- (NSArray *)makeAnimationArrayWithCount:(NSInteger)count andPath:(NSString *)path
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < count; i++) {
        NSString *picFilePath = [NSString stringWithFormat:@"%@/a%d.png",path,i];
        UIImage *image = [UIImage imageWithContentsOfFile:picFilePath];
        [tmpArray addObject:image];
    }
    
    NSArray *resultArray = [[NSArray alloc]initWithArray:tmpArray];
    return resultArray;
}



/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - init mainView and DownloadView
/////////////////////////////////////////////////////////////////////////////////////

- (void)initMainView
{
    self.mainView  = [[UIView alloc]initWithFrame:CGRectMake(10, 40, TOTAL_WIDTH, self.view.frame.size.height)];
    self.mainView.backgroundColor = [UIColor clearColor];
    
    self.enterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.enterButton setTitle:@"Enter" forState:UIControlStateNormal];
    
    [self.enterButton setFrame:CGRectMake(60, 280, 200, 40)];
    [self.enterButton addTarget:self action:@selector(enterAction) forControlEvents:UIControlEventTouchUpInside];
    
    // or animview
    self.transButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.transButton.frame = CGRectMake(0, 0, TOTAL_WIDTH, 290);
    [self.transButton setTitle:@"" forState:UIControlStateNormal];
    [self.transButton addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
    self.transButton.alpha = 1;
    self.transButton.tag = 0;
    
    self.animArea = [[UIImageView alloc] initWithFrame:CGRectMake(35, 0, 250, 250)];

    [self.mainView addSubview:self.transButton];
    [self.mainView addSubview:self.animArea];
    [self.mainView addSubview:self.enterButton];

    [self.mainView setHidden:YES];
    [self.view addSubview:self.mainView];
}

- (void)initDownloadView
{
    self.downloadView  = [[UIView alloc]initWithFrame:CGRectMake((TOTAL_WIDTH-BIG_BUTTON_WIDTH)/2 , 50, BIG_BUTTON_WIDTH, BIG_BUTTON_WIDTH+50)];
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0 , 50, BIG_BUTTON_WIDTH, BIG_BUTTON_WIDTH)];
    [bgView setImage:[UIImage imageNamed:@"circle_button_bg.png"]];
    
    self.dlTitle = [[UILabel alloc]initWithFrame:CGRectMake(0 , BIG_BUTTON_WIDTH+60, BIG_BUTTON_WIDTH, 20)];
    self.dlTitle.backgroundColor = [UIColor clearColor];
    self.dlTitle.font = [UIFont systemFontOfSize:14.0f];
    self.dlTitle.textColor = GRAYCOLOR;
    self.dlTitle.textAlignment = NSTextAlignmentCenter;
    self.dlTitle.text = T(@"Waiting...");
    
    self.dlNumber = [[UILabel alloc]initWithFrame:bgView.frame];
    self.dlNumber.backgroundColor = [UIColor clearColor];
    self.dlNumber.font = BIGCUSTOMFONT;
    self.dlNumber.textColor = DARKCOLOR;
    self.dlNumber.textAlignment = NSTextAlignmentCenter;
    
    [self.downloadView addSubview:bgView];
    [self.downloadView addSubview:self.dlNumber];
    [self.downloadView addSubview:self.dlTitle];
    [self.view addSubview:self.downloadView];
    [self.downloadView setHidden:YES];
}


/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - download progress
/////////////////////////////////////////////////////////////////////////////////////
- (void)downloadLastPlanet:(NSNumber *)value andTitle:(NSString *)title
{
    if (self.downloadView.hidden) {
        [self.downloadView setHidden:NO];
    }
    
    if ([title isEqualToString:self.planetString]) {
        self.dlTitle.text = T(@"Downloading...");
        self.dlNumber.text = [NSString stringWithFormat:@"%.0f%%",value.floatValue*100];
    }
}

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - download finish
/////////////////////////////////////////////////////////////////////////////////////

- (void)downloadFinish
{
    [self moveYOffest:20 andDelay:0 andAlpha:0 withView:self.downloadView];
    [self.downloadView setHidden:YES];
    [self moveYOffest:-20 andDelay:1 andAlpha:0 withView:self.downloadView];
    
    [self.mainView setHidden:NO];
    [self.mainView setAlpha:0];
    [self moveYOffest:0 andDelay:0.3 andAlpha:1 withView:self.mainView];
    
    
    DDLogVerbose(@"Main View %@",self.planetString);
    // that is overall seconds. hence: frames divided by about 30 or 20.
    [self makeArrayWithString:self.planetString];
    
    DDLogVerbose(@"%@",self.animArea.animationImages);
    [self.animArea setAnimationImages:self.animationArray];
    self.animArea.animationRepeatCount = 0;
    self.animArea.animationDuration = 1.2;
    
    [self.animArea startAnimating];
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



- (void)enterAction
{
    self.pageViewController.albumArray = self.albumArray;
    [self.pageViewController refreshSubView];
    [self.pageViewController setHidesBottomBarWhenPushed:YES];
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:self.pageViewController animated:YES];

}


-(void)playSound {

    
    NSURL *audioURL = [NSURL fileURLWithPath:self.audioPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioURL, &completeSound);
    AudioServicesDisposeSystemSoundID(completeSound);
    AudioServicesPlaySystemSound (completeSound);
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.animArea startAnimating];

//    self.theZipfile = [[ModelHelper sharedInstance]findZipfileWithFileName:self.planetString];
//    if (self.theZipfile.isDownload.floatValue) {
//        [self.downloadView setHidden:YES];
//        [self downloadFinish];
//    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.animArea stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


@end
