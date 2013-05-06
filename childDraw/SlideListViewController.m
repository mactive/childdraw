//
//  SlideListViewController.m
//  childDraw
//
//  Created by meng qian on 13-5-6.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "SlideListViewController.h"
#import <QuartzCore/QuartzCore.h>


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
@end

@implementation SlideListViewController
@synthesize scrollView;
@synthesize albumArray;
@synthesize swipeView;
@synthesize leftSwipe,rightSwipe;

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
//    self.scrollView.delegate = self;
    
    self.albumArray = [[NSArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E", nil];
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
        if (self.scrollView.page >= 0 && self.scrollView.page < [self.albumArray count]-1) {
            [self.scrollView setPage:self.scrollView.page + 1 animated:YES];
        }
    }
    if (paramSender.direction & UISwipeGestureRecognizerDirectionRight) {
        DDLogVerbose(@">>> right");
        if (self.scrollView.page > 0 && self.scrollView.page <= [self.albumArray count]-1) {
            [self.scrollView setPage:self.scrollView.page - 1 animated:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshSubView];
}
- (void)refreshSubView
{
    [self.scrollView removeAllContentSubviews];
    for (NSUInteger index = 0; index < [self.albumArray count]; index ++) {
        //You add your content views here
        id obj = [self.albumArray objectAtIndex:index];
        
        [self.scrollView addContentSubview:[self createViewForObj:obj withIndex:index]];
//        [self.targetArray addObject:[self createViewForObj:obj withIndex:index]];
    }
}



- (UIView *)createViewForObj:(id)obj withIndex:(NSInteger)index{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake( (TOTAL_WIDTH-_itemWidth)/2 , 0, _itemWidth,
                                                            TOTAL_WIDTH)];
    
    view.backgroundColor = BGCOLOR;
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:view.bounds];
    imageView.tag = 1001;
    if ([obj isKindOfClass:[UIImage class]]) {
        imageView.image = obj;
    }
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 200, view.frame.size.width, 40)];
    titleLabel.font = [UIFont systemFontOfSize:40.0f];
    titleLabel.text = [self.albumArray objectAtIndex:index];
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
