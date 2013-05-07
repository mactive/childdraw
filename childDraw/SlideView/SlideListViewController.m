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
#import "UIImageView+AFNetworking.h"
#import "Zipfile.h"

#import "DDLog.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface SlideListViewController ()
@property(nonatomic, strong)UIView *swipeView;
@property(nonatomic, strong)UISwipeGestureRecognizer *leftSwipe;
@property(nonatomic, strong)UISwipeGestureRecognizer *rightSwipe;

@property(nonatomic, strong) NSArray *sourceData;
@property(nonatomic, assign) NSUInteger albumIndex;
@property(nonatomic, readwrite) NSUInteger startInt;
@property(nonatomic, readwrite) BOOL isLOADMORE;
@end

@implementation SlideListViewController
@synthesize scrollView;
@synthesize sourceData;
@synthesize swipeView;
@synthesize leftSwipe,rightSwipe;
@synthesize startInt;
@synthesize isLOADMORE;
@synthesize managedObjectContext;


const CGFloat _itemWidth = 220.0f;
const CGFloat _itemOffset = 20.0f;




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
    CGRect viewRect = CGRectMake(0, 50, 320, 320);
    self.scrollView = [[MCPagedScrollView alloc] initWithFrame:viewRect];
    
    self.scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    self.scrollView.backgroundColor = BLUECOLOR;
    
    self.scrollView.minimumZoomScale = 1; //最小到0.3倍
    self.scrollView.maximumZoomScale = 1; //最大到3倍
    self.scrollView.clipsToBounds = YES;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.pagingEnabled = NO;
    
    self.scrollView.itemWidth = _itemWidth;
    self.scrollView.itemOffset = _itemOffset;
    
    self.sourceData = [[NSArray alloc]init];
    [self.view addSubview:self.scrollView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
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
}

- (void)actionSwipe:(UISwipeGestureRecognizer *)paramSender
{
    if (paramSender.direction & UISwipeGestureRecognizerDirectionLeft) {
        DDLogVerbose(@"<<< left");
        if (self.scrollView.page >= 0 && self.scrollView.page < [self.sourceData count]-1) {
            [self.scrollView setPage:self.scrollView.page + 1 animated:YES];
        }
    }
    if (paramSender.direction & UISwipeGestureRecognizerDirectionRight) {
        DDLogVerbose(@">>> right");
        if (self.scrollView.page > 0 && self.scrollView.page <= [self.sourceData count]-1) {
            [self.scrollView setPage:self.scrollView.page - 1 animated:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.sourceData == nil || [self.sourceData count] == 0) {
        self.startInt = 0;
        [self populateData:self.startInt];
    }
//    [self refreshSubView];
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
            
            self.startInt += [tempArray count];
            
            // load more
            if (self.isLOADMORE) {
                for (int i=0; i < [tempArray count]; i++) {
                    NSDictionary *dict = [tempArray objectAtIndex:i];
                    Zipfile *aZipfile = [[ModelHelper sharedInstance]findZipfileWithFileName:[ServerDataTransformer getStringObjFromServerJSON:dict byName:@"key"]];
                    if (aZipfile == nil) {
                        aZipfile = (Zipfile *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
                        [[ModelHelper sharedInstance]populateZipfile:aZipfile withServerJSONData:dict];
                    }
                    [allData addObject:aZipfile];
                }
                self.sourceData = [[NSArray alloc]initWithArray:allData];
            }
            // first data
            else{
                for (int i=0; i < [tempArray count]; i++) {
                    NSDictionary *dict = [tempArray objectAtIndex:i];
                    Zipfile *aZipfile = [[ModelHelper sharedInstance]findZipfileWithFileName:[ServerDataTransformer getStringObjFromServerJSON:dict byName:@"key"]];
                    if (aZipfile == nil) {
                        aZipfile = (Zipfile *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
                        [[ModelHelper sharedInstance]populateZipfile:aZipfile withServerJSONData:dict];
                    }
                    [tempMutableArray addObject:aZipfile];
                }
                
                self.sourceData = [[NSArray alloc]initWithArray:tempMutableArray];
            }
            
            // 数量太少不出现 load more
            if([tempArray count] == 0) {
//                [self.loadMoreButton setTitle:T(@"没有更多了") forState:UIControlStateNormal];
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                MBProgressHUD* HUD2 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD2.removeFromSuperViewOnHide = YES;
                HUD2.mode = MBProgressHUDModeText;
                HUD2.labelText = T(@"没有更多了");
                [HUD2 hide:YES afterDelay:1];
                
            } else {
//                [self.loadMoreButton setTitle:T(@"点击加载更多") forState:UIControlStateNormal];
            }
            
            [self refreshSubView];
            
            
        }
        if (error != nil) {
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = T(@"亲,连不上网啦! ");
            HUD.detailsLabelText = T(@"检查一下吧");
            [HUD hide:YES afterDelay:1];
        }
        
//        [self.loadMoreButton setEnabled:YES];
//        [self.loadMoreButton setHidden:NO];
        self.isLOADMORE = NO;
    }];
}




- (void)refreshSubView
{
    [self.scrollView removeAllContentSubviews];
    for (NSUInteger index = 0; index < [self.sourceData count]; index ++) {
        //You add your content views here
        id obj = [self.sourceData objectAtIndex:index];
        
        [self.scrollView addContentSubview:[self createViewForObj:obj withIndex:index]];
//        [self.targetArray addObject:[self createViewForObj:obj withIndex:index]];
    }
}



- (UIView *)createViewForObj:(id)obj withIndex:(NSInteger)index{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake( (TOTAL_WIDTH-_itemWidth)/2 , 0, _itemWidth,
                                                            TOTAL_WIDTH)];
    
    Zipfile *theFile = (Zipfile *)[self.sourceData objectAtIndex:index];

    view.backgroundColor = BGCOLOR;
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:view.bounds];
    imageView.tag = 1001;
    imageView.contentMode = UIViewContentModeScaleAspectFill;

    NSString *prefix = [[NSUserDefaults standardUserDefaults] objectForKey:@"thumbnail_prefix"];
    NSString *url = [NSString stringWithFormat:@"%@%@.png",prefix,theFile.fileName];
    NSLog(@"URL %@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [imageView setImageWithURLRequest:request
                           placeholderImage:nil
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        
                                        [imageView setImage:image];
                                        
                                        
                                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        //
                                        [imageView setImage:[UIImage imageNamed:@"icon.png"]];
                                    }];

    
   
    
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 300, view.frame.size.width, 20)];
    titleLabel.font = [UIFont systemFontOfSize:12.0f];
    titleLabel.text = theFile.title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [view addSubview:imageView];
    [view addSubview:titleLabel];
    return view;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
