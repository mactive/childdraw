//
//  GCPagedScrollViewDemoViewController.m
//  GCPagedScrollViewDemo
//
//  Created by Guillaume Campagna on 11-04-30.
//  Copyright 2011 LittleKiwi. All rights reserved.
//

#import "AlbumViewController.h"
#import "UIImage+ProportionalFill.h"


@interface AlbumViewController ()<UIScrollViewAccessibilityDelegate,UIActionSheetDelegate>

- (UIView*) createViewForObj:(id)obj;
@property(strong, nonatomic)UIView *targetView;
@property(strong, nonatomic)UIButton *moreButton;
@property(strong, nonatomic)NSMutableArray *targetArray;
@property(strong, nonatomic)UIActionSheet *moreActionSheet;
@end

@implementation AlbumViewController
@synthesize albumArray;
@synthesize albumIndex;
@synthesize targetView;
@synthesize targetArray;
@synthesize moreButton;
@synthesize moreActionSheet;
@synthesize titleArray;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GCPagedScrollView* scrollView = [[GCPagedScrollView alloc] initWithFrame:self.view.frame];
    scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.view = scrollView;
    self.targetArray = [[NSMutableArray alloc]init];
    
    self.targetView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 432)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    self.moreButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 29)];
    [self.moreButton setBackgroundImage:[UIImage imageNamed: @"barbutton_more.png"] forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.moreButton];
    

    self.scrollView.minimumZoomScale = 1; //最小到0.3倍
    self.scrollView.maximumZoomScale = 3.0; //最大到3倍
    self.scrollView.clipsToBounds = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;

    
    for (NSUInteger index = 0; index < [self.albumArray count]; index ++) {
        //You add your content views here
        id obj = [self.albumArray objectAtIndex:index];
//        if ([obj isKindOfClass:[UIImage class]]) {
//            continue;
//        } 
//        else if ([obj isKindOfClass:[NSString class]]) {
//            NSString *urlPath = obj;
//            if (!StringHasValue(urlPath)) {
//                continue;
//            }
//        }else {
//            continue;
//        }
//        
        [self.scrollView addContentSubview:[self createViewForObj:obj withIndex:index]];
        [self.targetArray addObject:[self createViewForObj:obj withIndex:index]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scrollView setPage:self.albumIndex];
    
    self.targetView = [self.targetArray objectAtIndex:self.scrollView.page];
    //DDLogVerbose(@"page %d %@",self.scrollView.page,self.targetView);
    self.title = [NSString stringWithFormat:@"%d/%d",self.scrollView.page+1,[self.albumArray count]];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.scrollView]) {
        //DDLogVerbose(@"End page %d %@",self.scrollView.page,self.targetView);
        self.targetView = [self.targetArray objectAtIndex:self.scrollView.page];
        self.title = [NSString stringWithFormat:@"%d/%d",self.scrollView.page+1,[self.albumArray count]];
    }
}


#pragma mark -
#pragma mark Getters

- (GCPagedScrollView *)scrollView {
    return (GCPagedScrollView*) self.view;
}


#pragma mark -
#pragma mark Helper methods

- (UIView *)createViewForObj:(id)obj withIndex:(NSInteger)index{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 20,
                                                            self.view.frame.size.height - 50)];
    
    view.backgroundColor = [UIColor whiteColor];
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:view.bounds];
    imageView.tag = 1001;
    if ([obj isKindOfClass:[UIImage class]]) {
        imageView.image = obj;
    }
    
//    if ([obj isKindOfClass:[NSString class]]) {
//#warning when is this being used? would the use of HUD causing the user stuck in there waiting for load finish?
//        
//        
//        [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:obj]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        }];
//    }
    
    [imageView setContentMode:UIViewContentModeScaleAspectFit];

    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, self.view.frame.size.height - 100, 200, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [self.titleArray objectAtIndex:index];
    
    [view addSubview:label];
    [view addSubview:imageView];
    return view;
}



@end
