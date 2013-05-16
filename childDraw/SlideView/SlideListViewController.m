//
//  SlideListViewController.m
//  childDraw
//
//  Created by meng qian on 13-5-6.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "SlideListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppNetworkAPIClient.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "ServerDataTransformer.h"
#import "ModelHelper.h"
#import "ModelDownload.h"
#import "Zipfile.h"
#import "ListItemView.h"
#import "PassValueDelegate.h"
#import "AboutUsViewController.h"
#import "SettingViewController.h"
#import "MBPullDownController.h"

#import "DDLog.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface SlideListViewController ()<PassValueDelegate>
// control view
@property(nonatomic, strong)UIView *controlView;
@property(nonatomic, strong)UIButton *aboutUSButton;
@property(nonatomic, strong)UIButton *setttingButton;

// swipeView
@property(nonatomic, strong)UIView *swipeView;
@property(nonatomic, strong)UISwipeGestureRecognizer *leftSwipe;
@property(nonatomic, strong)UISwipeGestureRecognizer *rightSwipe;
@property(nonatomic, strong)UITapGestureRecognizer *clickTap;
@property(nonatomic, strong)NSMutableDictionary *itemDict;

@property(nonatomic, strong) NSArray *sourceData;
@property(nonatomic, assign) NSUInteger albumIndex;
@property(nonatomic, readwrite) NSUInteger startInt;
@property(nonatomic, readwrite) BOOL isLOADMORE;
@end

@implementation SlideListViewController
@synthesize scrollView;
@synthesize sourceData;
@synthesize swipeView;
@synthesize leftSwipe,rightSwipe,clickTap;
@synthesize startInt;
@synthesize isLOADMORE;
@synthesize managedObjectContext;
@synthesize itemDict;

#define CONTROL_HEIGHT 56

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
    
    [self.view setFrame:CGRectMake(0, 0, TOTAL_WIDTH, TOTAL_HEIGHT())];
    
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:self.view.frame];
    if (IS_IPHONE_5) {
        [bgView setImage:[UIImage imageNamed:@"5_bg.png"]];
    }else{
        [bgView setImage:[UIImage imageNamed:@"4s_bg.png"]];
    }
    [self.view addSubview:bgView];
    
    CGRect viewRect = CGRectMake(0, CONTROL_HEIGHT, TOTAL_WIDTH, BG_HEIGHT+20);
    self.scrollView = [[MCPagedScrollView alloc] initWithFrame:viewRect];
    self.scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    self.scrollView.minimumZoomScale = 1; //最小到0.3倍
    self.scrollView.maximumZoomScale = 1; //最大到3倍
    self.scrollView.clipsToBounds = YES;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.pagingEnabled = NO;
    
    self.scrollView.itemWidth = BG_WIDTH;
    self.scrollView.itemOffset = BG_OFFSET;
    
    [self.view addSubview:self.scrollView];

    
    self.sourceData = [[NSArray alloc]init];
    self.itemDict = [[NSMutableDictionary alloc]init];
    self.startInt = 0;
    self.isLOADMORE = NO;
    
    
    // toucha    
    self.swipeView = [[UIView alloc]initWithFrame:self.view.frame];
    self.swipeView.backgroundColor = RGBACOLOR(255, 0, 0, 0);
    [self.view addSubview:self.swipeView];
    
    self.leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(actionSwipe:)];
    self.leftSwipe.direction = (UISwipeGestureRecognizerDirectionLeft);
    self.leftSwipe.numberOfTouchesRequired = 1;
    [self.swipeView addGestureRecognizer:self.leftSwipe];
    
    self.rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(actionSwipe:)];
    self.rightSwipe.direction = (UISwipeGestureRecognizerDirectionRight);
    self.rightSwipe.numberOfTouchesRequired = 1;
    [self.swipeView addGestureRecognizer:self.rightSwipe];
    
    self.clickTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionTap:)];
    self.clickTap.numberOfTapsRequired = 1;
    self.clickTap.numberOfTouchesRequired = 1;
    [self.swipeView addGestureRecognizer:self.clickTap];
    
    [self initControlView];
    [self initBottomView];
    
    
    if (self.sourceData == nil || [self.sourceData count] == 0) {
//        self.startInt = 0;
//        [self populateData:0];
        [self populateThumbnailData];
    }
    
    [ModelDownload sharedInstance].thumbnailDelegate = (id)self;
}


- (void)populateThumbnailData
{
    NSString *is_first = [[NSUserDefaults standardUserDefaults]objectForKey:@"is_first"];
    NSArray *nowContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self appDelegate].THUMBNAILPATH
                                                                                    error:NULL];
    
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending: NO];
    NSArray *thumbnailContent =  [nowContent sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
    NSMutableArray *allData = [[NSMutableArray alloc]initWithArray:self.sourceData];

    for (int count = 0; count < (int)[thumbnailContent count]; count++)
    {
        NSString *fileName = [thumbnailContent objectAtIndex:count];
        
        DDLogVerbose(@"name : %@",fileName);
        
        Zipfile *aZipfile = [[ModelHelper sharedInstance]findZipfileWithFileName:fileName];
        if (aZipfile != nil) {
            [allData addObject:aZipfile];
        }
    
    }
    
    self.sourceData = [[NSArray alloc]initWithArray:allData];
    if ([self.sourceData count] == 0 || [is_first isEqualToString:@"YES"]) {
        [self populateData:0];
        [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"is_first"];

    }
    
    [self refreshSubView];
    
    DDLogVerbose(@"[self appDelegate].scrollIndex: %d",[self appDelegate].scrollIndex);
    
    self.startInt =  [self.sourceData count];
    
    
    if ([self appDelegate].scrollIndex > 0 && [self appDelegate].scrollIndex < self.startInt ) {
        [self.scrollView setPage:[self appDelegate].scrollIndex];
    }else{
        [self.scrollView setPage:0 animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)actionSwipe:(UISwipeGestureRecognizer *)paramSender
{
    if (paramSender.direction & UISwipeGestureRecognizerDirectionLeft) {
        DDLogVerbose(@"<<< left");
        if (self.scrollView.page >= 0 && self.scrollView.page < [self.sourceData count]-1) {
            [self.scrollView setPage:self.scrollView.page + 1 animated:YES];
        }else{
            // load more
            self.isLOADMORE = YES;
            [self populateData:self.startInt];
        }
        [self appDelegate].scrollIndex = self.scrollView.page+1;
        DDLogVerbose(@"[self appDelegate].scrollIndex: %d",[self appDelegate].scrollIndex);
    }
    if (paramSender.direction & UISwipeGestureRecognizerDirectionRight) {
        DDLogVerbose(@">>> right");
        if (self.scrollView.page > 0 && self.scrollView.page <= [self.sourceData count]-1) {
            [self.scrollView setPage:self.scrollView.page - 1 animated:YES];
        }
        [self appDelegate].scrollIndex = self.scrollView.page -1 ;
        DDLogVerbose(@"[self appDelegate].scrollIndex: %d",[self appDelegate].scrollIndex);
    }
}

- (void)actionTap:(UISwipeGestureRecognizer *)paramSender
{
    [self.pullDownController setOpen:NO animated:YES];
    [self.pullDownController.frontController setEditing:NO];
    
//    [self.navigationController setNavigationBarHidden:NO];
//    [self.navigationController popToRootViewControllerAnimated:NO];
    
    Zipfile *theZipfile = [self.sourceData objectAtIndex:self.scrollView.page];
    NSLog(@"sender.buttonIndex %d %@",self.scrollView.page,theZipfile.fileName);

    [self appDelegate].mainViewController.planetString = theZipfile.fileName;
    [self appDelegate].mainViewController.titleString = theZipfile.title;
//    [[self appDelegate].mainViewController.listButton setHidden:NO];

    [ModelDownload sharedInstance].lastPlanet = theZipfile.fileName;
    /* 绑定这两个 delegate */
    [ModelDownload sharedInstance].delegate = (id)[self appDelegate].mainViewController;
    [[ModelDownload sharedInstance] downloadAndUpdate:theZipfile];
}



// 解析公司列表
- (void)populateData:(NSUInteger)start
{
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = T(@"努力加载中");
    HUD.detailsLabelText = T(@"每天都更新呦");
    
    [[AppNetworkAPIClient sharedClient]getThumbnailsStartPosition:start withBlock:^(id responseDict, NSString *thumbnailPrefix, NSError *error) {
        //
        if (responseDict != nil) {
            [HUD hide:YES afterDelay:0.5];
            
            NSMutableArray *allData = [[NSMutableArray alloc]initWithArray:self.sourceData];
            NSArray *tempArray = [[NSArray alloc] initWithArray:responseDict];
            NSMutableArray *tempMutableArray = [[NSMutableArray alloc]init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Zipfile" inManagedObjectContext:self.managedObjectContext];
                        
            // load more
            if (self.isLOADMORE) {
                for (int i=0; i < [tempArray count]; i++) {
                    NSDictionary *dict = [tempArray objectAtIndex:i];
                    Zipfile *aZipfile = [[ModelHelper sharedInstance]findZipfileWithFileName:[ServerDataTransformer getStringObjFromServerJSON:dict byName:@"key"]];
                    if (aZipfile == nil) {
                        aZipfile = (Zipfile *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
                        [[ModelHelper sharedInstance]populateZipfile:aZipfile withServerJSONData:dict];
                    }
                    [allData addObject:aZipfile];
                    [self downloadThumbnail:[ServerDataTransformer getStringObjFromServerJSON:dict byName:@"key"]];

                }
                self.sourceData = [[NSArray alloc]initWithArray:allData];
            }
            // first data
            else{
                for (int i=0; i < [tempArray count]; i++) {
                    NSDictionary *dict = [tempArray objectAtIndex:i];
                    Zipfile *aZipfile = [[ModelHelper sharedInstance]findZipfileWithFileName:[ServerDataTransformer getStringObjFromServerJSON:dict byName:@"key"]];
                    if (aZipfile == nil) {
                        aZipfile = (Zipfile *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
                        [[ModelHelper sharedInstance]populateZipfile:aZipfile withServerJSONData:dict];
                    }
                    [tempMutableArray addObject:aZipfile];
                    DDLogVerbose(@"key %@",[ServerDataTransformer getStringObjFromServerJSON:dict byName:@"key"]);
                    
                    [self downloadThumbnail:[ServerDataTransformer getStringObjFromServerJSON:dict byName:@"key"]];

                }
                
                self.sourceData = [[NSArray alloc]initWithArray:tempMutableArray];
            }
        
            
            // 数量太少不出现 load more
            if([tempArray count] == 0) {
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                MBProgressHUD* HUD2 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD2.removeFromSuperViewOnHide = YES;
                HUD2.mode = MBProgressHUDModeText;
                HUD2.labelText = T(@"没有更多了");
                [HUD2 hide:YES afterDelay:1];
                
            } else {
                // save to database immediately
                MOCSave(self.managedObjectContext);
                
                [self refreshSubView];
                DDLogVerbose(@"[self appDelegate].scrollIndex: %d",[self appDelegate].scrollIndex);
                self.startInt += [tempArray count];

                if ([self appDelegate].scrollIndex > 0 && [self appDelegate].scrollIndex < self.startInt ) {
                    [self.scrollView setPage:[self appDelegate].scrollIndex animated:YES];
                }else{
                    [self.scrollView setPage:start animated:YES];
                }
            }

        }
        if (error != nil) {
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = T(@"亲,连不上网啦! ");
            HUD.detailsLabelText = T(@"检查一下吧");
            [HUD hide:YES afterDelay:1];
        }
        
        self.isLOADMORE = NO;
    }];
}

- (void)downloadThumbnail:(NSString *)filename
{
    [[ModelDownload sharedInstance]downloadThumbnailwithFilename:filename];
}

- (void)refreshSubView
{
    CGRect frame = CGRectMake(0, 0, BG_WIDTH, BG_HEIGHT);

    for (NSUInteger index = 0; index < [self.sourceData count]; index ++) {
        //You add your content views here
        if (index >= self.startInt) {
            
            Zipfile *theFile = (Zipfile *)[self.sourceData objectAtIndex:index];
            NSLog(@"self.sourceData: %@",theFile.fileName);
            
            ListItemView *view = [[ListItemView alloc]initWithFrame:frame];
            [view setAvatar:theFile.fileName];

            [self.scrollView addContentSubview:view];
            [self.itemDict setObject:view forKey:theFile.fileName];
        }
        
    }
}

-(void)passStringValue:(NSString *)value andIndex:(NSUInteger )index
{
    NSLog(@"********* %@",value);
//    if ([value isEqualToString:self.fileName]) {
//        [self setAvatar:self.fileName];
//    }
    ListItemView *view = [self.itemDict objectForKey:value];    
    [view setAvatar:value];
    
}


//- (void)refreshSubView
//{
//    [self.scrollView removeAllContentSubviews];
//    for (NSUInteger index = 0; index < [self.sourceData count]; index ++) {
//        //You add your content views here
//        id obj = [self.sourceData objectAtIndex:index];
//        
//        [self.scrollView addContentSubview:[self createViewForObj:obj withIndex:index]];
////        [self.targetArray addObject:[self createViewForObj:obj withIndex:index]];
//    }
//}

- (UIView *)createViewForObj:(id)obj withIndex:(NSInteger)index{
    CGRect frame = CGRectMake(0, 0, BG_WIDTH, BG_HEIGHT);
    
    ListItemView *view = [[ListItemView alloc]initWithFrame:frame];
    return view;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark controlview
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define B_WIDTH 60
#define B_HEIGHT 30
#define X_OFFSET 10
#define Y_OFFSET 5

- (void)initControlView
{
    self.controlView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOTAL_WIDTH, CONTROL_HEIGHT)];
    
    self.aboutUSButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.aboutUSButton setFrame:CGRectMake(X_OFFSET, Y_OFFSET, B_WIDTH, B_HEIGHT)];
    [self.aboutUSButton setBackgroundImage:[UIImage imageNamed:@"button_us.png"] forState:UIControlStateNormal];
    [self.aboutUSButton addTarget:self action:@selector(aboutUSAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.setttingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.setttingButton setFrame:CGRectMake(TOTAL_WIDTH - X_OFFSET - B_WIDTH, Y_OFFSET, B_WIDTH, B_HEIGHT)];
    [self.setttingButton setBackgroundImage:[UIImage imageNamed:@"button_setting.png"] forState:UIControlStateNormal];
    [self.setttingButton addTarget:self action:@selector(setttingAction) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((TOTAL_WIDTH-B_WIDTH) /2, Y_OFFSET, B_WIDTH, B_HEIGHT)];
    titleLabel.text = T(@"全部");
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = GRAYCOLOR;
    titleLabel.font = [UIFont boldSystemFontOfSize:22.0f];
    titleLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    titleLabel.layer.shadowRadius = 1;
    titleLabel.layer.shadowOpacity = 1;
    
    UIImageView *bottomLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 41, TOTAL_WIDTH, 3)];
    [bottomLine setImage:[UIImage imageNamed:@"keyline_full.png"]];
    
    [self.controlView addSubview:self.aboutUSButton];
    [self.controlView addSubview:self.setttingButton];
    [self.controlView addSubview:titleLabel];
    [self.controlView addSubview:bottomLine];
    
    [self.view addSubview:self.controlView];
}

- (void)initBottomView
{
    UIImageView *bottomView = [[UIImageView alloc]initWithFrame:CGRectMake(0,  TOTAL_HEIGHT()- 43, TOTAL_WIDTH, 32)];
    [bottomView setImage:[UIImage imageNamed:@"bottom_full.png"]];
    
    [self.view addSubview:bottomView];
}

- (void)aboutUSAction
{
    AboutUsViewController *controller = [[AboutUsViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController presentModalViewController:controller animated:YES];
}

- (void)setttingAction
{
    SettingViewController *controller = [[SettingViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController presentModalViewController:controller animated:YES];

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors & selectors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


@end
