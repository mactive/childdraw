//
//  MainViewController.m
//  childDraw
//
//  Created by meng qian on 13-3-22.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "MainViewController.h"
#import "AlbumViewController.h"
#import "MBPullDownController.h"
#import "SlideListViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "JSONKit/JSONKit.h"
#import "AppNetworkAPIClient.h"
#import "AppDelegate.h"
#import "Zipfile.h"
#import "ModelHelper.h"
#import "ModelDownload.h"
#import "PassValueDelegate.h"
#import "ListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ShareWithPhotoView.h"
#import "MBProgressHUD.h"
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
    MBProgressHUD *HUD;
}

@property(strong, nonatomic)UIImageView *titleImage;
@property(strong, nonatomic)AlbumViewController *albumViewController;
@property(strong, nonatomic)UIButton *enterButton;
@property(strong, nonatomic)UIView *swipeView;
@property(strong, nonatomic)UIButton *listButton;
@property(strong, nonatomic)UIButton *backDownButton;


@property(strong, nonatomic)NSArray *albumArray;
@property(strong, nonatomic)NSArray *animationArray;
@property(strong, nonatomic)NSString *audioPath;
@property(strong, nonatomic)UIImageView *animArea;
@property(strong, nonatomic)Zipfile *theZipfile;
@property(assign, nonatomic)NSInteger picCount;
@property(assign, nonatomic)NSInteger aniCount;

@property(strong, nonatomic)UIView *mainView;
@property(strong, nonatomic)UIView *downloadView;
@property(strong, nonatomic)UILabel *dlNumber;
@property(strong, nonatomic)UILabel *dlTitle;
@property(strong, nonatomic)UIImageView *dlImage;

@property(readwrite, nonatomic)CGFloat offsetViewY;

@property(nonatomic, strong)UISwipeGestureRecognizer *leftSwipe;
@property(nonatomic, strong)UITapGestureRecognizer *clickTap;

@end

@implementation MainViewController
@synthesize albumViewController;
@synthesize titleImage;
@synthesize enterButton;
@synthesize albumArray;
@synthesize animationArray;
@synthesize audioPath;
@synthesize swipeView;
@synthesize animArea;
@synthesize planetString;
@synthesize theZipfile;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize picCount;
@synthesize aniCount;
@synthesize mainView;
@synthesize downloadView;
@synthesize dlNumber,dlTitle,dlImage;
@synthesize titleString;
@synthesize listButton;
@synthesize backDownButton;

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
    
    self.albumViewController = [[AlbumViewController alloc] init];
    
	// Do any additional setup after loading the view.
    
    self.albumArray = [[NSArray alloc]init];
    self.animationArray = [[NSArray alloc]init];
    
    if (IS_IPHONE_5) {
        self.offsetViewY = (TOTAL_HEIGHT() - TOTAL_WIDTH) / 2 ;
    }else{
        self.offsetViewY = (TOTAL_HEIGHT() - TOTAL_WIDTH) / 3 ;
    }
    
    self.view = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, TOTAL_WIDTH, TOTAL_HEIGHT())];

    //    [self.view setFrame:CGRectMake(0, 0, TOTAL_WIDTH, TOTAL_HEIGHT())];

    UIImageView *bgView = [[UIImageView alloc]initWithFrame:self.view.frame];
    
    if (IS_IPHONE_5) {
        [bgView setImage:[UIImage imageNamed:@"5_bg.png"]];
    }else{
        [bgView setImage:[UIImage imageNamed:@"4s_bg.png"]];
    }
    [self.view addSubview:bgView];
    
    
    // download view
    [self initMainView];
    [self initDownloadView];
    [self initListButton];
//    [self initBottomView];
    
    self.title = PRODUCT_NAME;
    
    DDLogVerbose(@"open %d",self.pullDownController.open);
    
}

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - download progress
/////////////////////////////////////////////////////////////////////////////////////


- (void)passNumberValue:(NSNumber *)value andTitle:(NSString *)title
{
//    DDLogVerbose(@"*****%f %@",value.floatValue,title);
    if ([title isEqualToString:self.planetString]) {
        self.dlTitle.text = T(@"下载中...");
        if (value.floatValue > 0.99) {
            [self.dlImage setImage:[UIImage imageNamed:@"dl_success.png"]];
            self.dlNumber.text = @"";
        }else{
            [self.dlImage setImage:nil];
            self.dlNumber.text = [NSString stringWithFormat:@"%.0f%%",value.floatValue*100];
        }
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

    }else if ([value isEqualToString:DOWNLOADFAILED])
    {
        [self.mainView setHidden:YES];
        [self.downloadView setAlpha:1];
        [self.downloadView setHidden:NO];
        self.dlNumber.text = T(@"=.=!");
        [self.dlImage setImage:[UIImage imageNamed:@"dl_error.png"]];
        self.dlTitle.text = T(@"失败!");
    }
}

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - file verify and count  
/////////////////////////////////////////////////////////////////////////////////////
// 整理数据 写数据库
- (void)makeArrayWithString:(NSString *)planet
{
    self.theZipfile = [[ModelHelper sharedInstance]findZipfileWithFileName:planet];
    
    NSString *path = [[self appDelegate].ASSETPATH stringByAppendingPathComponent:planet];
    [self listFileAtPath:path];
    
}

// 检查文件数据 
-(void)listFileAtPath:(NSString *)path
{
    self.picCount = 0;
    self.aniCount = 0;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    
    if ([directoryContent count] == 0) {
        self.theZipfile.isDownload  = [NSNumber numberWithBool:NO];
        self.theZipfile.isZiped     = [NSNumber numberWithBool:NO];
        [[ModelDownload sharedInstance]downloadAndUpdate:self.theZipfile];
        return;
    }
    
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
//    DDLogVerbose(@"path %@ %@ ",path, self.planetString);
    NSURL *audioURL = [NSURL fileURLWithPath:self.audioPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioURL, &completeSound);
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
    self.mainView  = [[UIView alloc]initWithFrame:CGRectMake(0, self.offsetViewY, TOTAL_WIDTH, TOTAL_WIDTH+50 )];
    self.mainView.backgroundColor = [UIColor clearColor];
    
    self.enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.enterButton setTitle:@"Enter" forState:UIControlStateNormal];
    [self.enterButton setFrame:CGRectMake(115, TOTAL_WIDTH-20, 90, 60)];
    [self.enterButton setBackgroundImage:[UIImage imageNamed:@"button_next.png"] forState:UIControlStateNormal];
    [self.enterButton setBackgroundImage:[UIImage imageNamed:@"button_next_highlight.png"] forState:UIControlStateHighlighted];
    [self.enterButton setTitle:@"" forState:UIControlStateNormal];
    [self.enterButton addTarget:self action:@selector(enterAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.animArea = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300, 300)];

    // or animview
    self.swipeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOTAL_WIDTH, TOTAL_WIDTH)];
    self.swipeView.backgroundColor = RGBACOLOR(255, 0, 0, 0);

    self.leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(actionSwipe:)];
    self.leftSwipe.direction = (UISwipeGestureRecognizerDirectionLeft);
    self.leftSwipe.numberOfTouchesRequired = 1;
    [self.swipeView addGestureRecognizer:self.leftSwipe];
    
    self.clickTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionTap:)];
    self.clickTap.numberOfTapsRequired = 1;
    self.clickTap.numberOfTouchesRequired = 1;
    [self.swipeView addGestureRecognizer:self.clickTap];
    
    [self.mainView addSubview:self.animArea];
    [self.mainView addSubview:self.swipeView];
    [self.mainView addSubview:self.enterButton];

    [self.mainView setHidden:YES];
    [self.view addSubview:self.mainView];
}

#define ICON_W 77
#define ICON_H 44
- (void)initDownloadView
{
    CGFloat dowmY = 0;
    if (IS_IPHONE_5) {
        dowmY = self.offsetViewY *2;
    }else{
        dowmY = self.offsetViewY *3;
    }
    CGRect rect = CGRectMake((TOTAL_WIDTH-BIG_BUTTON_WIDTH)/2 , dowmY , BIG_BUTTON_WIDTH, BIG_BUTTON_WIDTH+50);
    self.downloadView  = [[UIView alloc]initWithFrame:rect];
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0 ,0, BIG_BUTTON_WIDTH, BIG_BUTTON_WIDTH)];
    [bgView setImage:[UIImage imageNamed:@"circle_button_bg.png"]];
    
    self.dlTitle = [[UILabel alloc]initWithFrame:CGRectMake(0 , BIG_BUTTON_WIDTH+10, BIG_BUTTON_WIDTH, 20)];
    self.dlTitle.backgroundColor = [UIColor clearColor];
    self.dlTitle.font = [UIFont systemFontOfSize:14.0f];
    self.dlTitle.textColor = GRAYCOLOR;
    self.dlTitle.textAlignment = NSTextAlignmentCenter;
    self.dlTitle.text = T(@"等待中...");
    
    self.dlNumber = [[UILabel alloc]initWithFrame:bgView.frame];
    self.dlNumber.backgroundColor = [UIColor clearColor];
    self.dlNumber.font = BIGCUSTOMFONT;
    self.dlNumber.textColor = DARKCOLOR;
    self.dlNumber.textAlignment = NSTextAlignmentCenter;
    
    self.dlImage = [[UIImageView alloc]initWithFrame:
                    CGRectMake((BIG_BUTTON_WIDTH - ICON_W)/2, (BIG_BUTTON_WIDTH - ICON_H)/2,ICON_W ,ICON_H)];
    [self.dlImage setImage:[UIImage imageNamed:@"dl_now.png"]];
    
    [self.downloadView addSubview:bgView];
    [self.downloadView addSubview:self.dlImage];
    [self.downloadView addSubview:self.dlNumber];
    [self.downloadView addSubview:self.dlTitle];
//    [self.downloadView setHidden:YES];
    
    [self.view addSubview:self.downloadView];
}

#define LIST_OFFSET 12
#define LIST_WIDTH  60

- (void)initListButton
{
    // list button
    self.listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.listButton setFrame:CGRectMake(LIST_OFFSET, LIST_OFFSET, LIST_WIDTH, LIST_WIDTH)];
    [self.listButton setBackgroundImage:[UIImage imageNamed:@"button_list.png"] forState:UIControlStateNormal];
    [self.listButton setBackgroundImage:[UIImage imageNamed:@"button_list_highlight.png"] forState:UIControlStateHighlighted];
    [self.listButton addTarget:self action:@selector(listAction) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat backy = 0;
    if (IS_IPHONE_5) {
        backy = 13;
    }else{
        backy = 5;
    }
    
    self.backDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backDownButton setFrame:CGRectMake(0, backy, TOTAL_WIDTH, 32)];
    [self.backDownButton setBackgroundColor:[UIColor clearColor]];
    [self.backDownButton setBackgroundImage:[UIImage imageNamed:@"bottom_full.png"] forState:UIControlStateNormal];
    [self.backDownButton addTarget:self action:@selector(backDownAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backDownButton setHidden:YES];

    [self.view addSubview:self.listButton];
    [self.view addSubview:self.backDownButton];
}

- (void)listAction
{
    [self.pullDownController setOpen:YES animated:YES];
    [self.listButton setHidden:YES];
    [self.backDownButton setHidden:NO];
}

-(void)backDownAction
{
    [self.pullDownController setOpen:NO animated:YES];
    [self.listButton setHidden:NO];
    [self.backDownButton setHidden:YES];
}



- (void)initBottomView
{
    UIImageView *bottomView = [[UIImageView alloc]initWithFrame:CGRectMake(0,  8, TOTAL_WIDTH, 32)];
    [bottomView setImage:[UIImage imageNamed:@"bottom_full.png"]];
    
    [self.view addSubview:bottomView];
}

//- (void)listAction
//{
//    SlideListViewController *controller = [[SlideListViewController alloc]initWithNibName:nil bundle:nil];
//    controller.managedObjectContext = self.managedObjectContext;
//    [self.navigationController pushViewController:controller animated:NO];
//}


//- (void)initViewControllers
//{
//    [self appDelegate].listViewContorller = [[ListViewController alloc]initWithNibName:nil bundle:nil];
//    [self appDelegate].listViewContorller.managedObjectContext = self.managedObjectContext;
//}


/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - GestureRecognizer action
/////////////////////////////////////////////////////////////////////////////////////

- (void)actionSwipe:(UISwipeGestureRecognizer *)paramSender
{
    if (paramSender.direction & UISwipeGestureRecognizerDirectionLeft) {
        DDLogVerbose(@"<<< left");
        [self enterAction];
    }
}

- (void)actionTap:(UISwipeGestureRecognizer *)paramSender
{
    [self playSound];
}



//- (void)downloadLastPlanet:(NSNumber *)value andTitle:(NSString *)title
//{
//    if (self.downloadView.hidden) {
//        [self.downloadView setHidden:NO];
//    }
//    
//    if ([title isEqualToString:self.planetString]) {
//        self.dlTitle.text = T(@"下载中...");
//        self.dlNumber.text = [NSString stringWithFormat:@"%.0f%%",value.floatValue*100];
//        [self.dlImage setImage:nil];
//    }
//}

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - download finish
/////////////////////////////////////////////////////////////////////////////////////

- (void)downloadFinish
{
    [self moveYOffest:20 andDelay:0 andAlpha:0 withView:self.downloadView];
    [self.downloadView setHidden:YES];
//    self.dlNumber.text = T(@"0%");
    [self.dlImage setImage:[UIImage imageNamed:@"dl_now.png"]];
    [self moveYOffest:-20 andDelay:1 andAlpha:0 withView:self.downloadView];
    
    [self.mainView setHidden:NO];
    [self.mainView setAlpha:0];
    [self moveYOffest:0 andDelay:0.3 andAlpha:1 withView:self.mainView];
    
    
//    DDLogVerbose(@"Main View %@",self.planetString);
    // that is overall seconds. hence: frames divided by about 30 or 20.
    [self makeArrayWithString:self.planetString];
    
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


///////////////////////

- (void)enterAction
{
    [self enterFirst:YES orLast:NO];
}

- (void)backAction
{
    [self.albumViewController backToMainView];
}


- (void)enterFirst:(BOOL)first orLast:(BOOL)last
{
    self.albumViewController.albumArray = self.albumArray;
    self.albumViewController.shareView = [[ShareWithPhotoView alloc]initWithFrame:CGRectMake(0, 0, TOTAL_WIDTH, TOTAL_WIDTH)];
//    [self.albumViewController refreshSubView];
    [self.albumViewController setHidesBottomBarWhenPushed:YES];
    self.albumViewController.title = self.titleString;
    self.albumViewController.keyString = self.planetString;
    // Pass the selected object to the new view controller.

    [self.albumViewController jumpToFirst:first orLast:last];
    
//    NSLog(@"%@",ttNC);
    NSLog(@"%@",self.navigationController);
    [self.navigationController pushViewController:self.albumViewController animated:YES];
}


-(void)playSound {
    AudioServicesPlaySystemSound (completeSound);
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.animArea startAnimating];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
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

- (void)setEditing:(BOOL)editing
{
    if (editing == YES) {
        [self.listButton setHidden:YES];
        [self.backDownButton setHidden:NO];
    }else{
        [self.listButton setHidden:NO];
        [self.backDownButton setHidden:YES];
    }
}



@end
