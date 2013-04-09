//
//  ListViewController.m
//  childDraw
//
//  Created by meng qian on 13-4-3.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "ListViewController.h"
#import "Zipfile.h"
#import "AppNetworkAPIClient.h"
#import "ModelHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "ModelDownload.h"
#import "MainViewController.h"
#import "ThumbnailUIButton.h"
#import "SettingViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "DDLog.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface ListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic)UIButton *settingButton;
@property(strong,nonatomic)NSArray *sourceData;
@property(strong, nonatomic)NSMutableDictionary * sourceDict;
@property(strong, nonatomic)UITableView * tableView;
@property(strong, nonatomic)UIButton *loadMoreButton;
@property( nonatomic, readwrite) NSUInteger startInt;
@property(nonatomic, readwrite) BOOL isLOADMORE;
@end

@implementation ListViewController
@synthesize settingButton;
@synthesize managedObjectContext;
@synthesize sourceData;
@synthesize sourceDict;
@synthesize tableView;
@synthesize loadMoreButton;
@synthesize startInt;
@synthesize isLOADMORE;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization

        self.settingButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 29)];
        [self.settingButton setBackgroundImage:[UIImage imageNamed: @"setting_button.png"] forState:UIControlStateNormal];
        [self.settingButton addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.settingButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = T(@"全部列表");
    
    self.view.backgroundColor = BGCOLOR;
    CGRect tableRect = CGRectMake(0, 0, TOTAL_WIDTH, self.view.frame.size.height -30);
    self.tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    self.tableView.backgroundColor = BGCOLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    self.tableView.separatorColor = SEPCOLOR;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    self.tableView.delegate = self;
    self.tableView.dataSource  = self;
    
    
    self.loadMoreButton  = [[UIButton alloc] initWithFrame:CGRectMake(40, 10, 240, 40)];
    [self.loadMoreButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.loadMoreButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.loadMoreButton setTitleColor:RGBCOLOR(143, 183, 225) forState:UIControlStateHighlighted];
    [self.loadMoreButton.titleLabel setTextAlignment:UITextAlignmentCenter];
    [self.loadMoreButton setTitle:T(@"点击加载更多") forState:UIControlStateNormal];
    [self.loadMoreButton setBackgroundColor:[UIColor clearColor]];
    //    [self.loadMoreButton.layer setBorderColor:[RGBCOLOR(187, 217, 247) CGColor]];
    //    [self.loadMoreButton.layer setBorderWidth:1.0f];
    [self.loadMoreButton.layer setCornerRadius:5.0f];
    [self.loadMoreButton addTarget:self action:@selector(loadMoreAction) forControlEvents:UIControlEventTouchUpInside];
    [self.loadMoreButton setHidden:YES];
    
    [self.tableView.tableFooterView addSubview:self.loadMoreButton];
    [self.view addSubview:self.tableView];
    
    self.sourceData = [[NSArray alloc]init];
    self.startInt = 0;
    self.isLOADMORE = NO;
    
    ///////////// will appear
    [self.loadMoreButton setHidden:NO];
    [self.loadMoreButton setEnabled:YES];
    
    if (self.sourceData == nil || [self.sourceData count] == 0) {
        self.startInt = 0;
        [self populateData:self.startInt];
    }

}

-(void)loadMoreAction
{
    self.isLOADMORE = YES;
    [self populateData:self.startInt];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

}

// 解析公司列表
- (void)populateData:(NSUInteger)start
{
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = T(@"努力加载中");
    
    [[AppNetworkAPIClient sharedClient]getThumbnailsStartPosition:start withBlock:^(id responseDict, NSString *thumbnailPrefix, NSError *error) {
        //
        if (responseDict != nil) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSMutableArray *allData = [[NSMutableArray alloc]initWithArray:self.sourceData];
            NSArray *tempArray = [[NSArray alloc] initWithArray:responseDict];
            NSMutableArray *tempMutableArray = [[NSMutableArray alloc]init];
            
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Zipfile" inManagedObjectContext:self.managedObjectContext];            
            
            self.startInt += [tempArray count];
            
            // load more
            if (self.isLOADMORE) {
                for (int i=0; i < [tempArray count]; i++) {
                    NSDictionary *dict = [tempArray objectAtIndex:i];
                    Zipfile *aZipfile = [[ModelHelper sharedInstance]findZipfileWithFileName:[[dict objectForKey:@"key"] stringValue]];
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
                    Zipfile *aZipfile = [[ModelHelper sharedInstance]findZipfileWithFileName:[[dict objectForKey:@"key"] stringValue]];
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
                [self.loadMoreButton setTitle:T(@"没有更多了") forState:UIControlStateNormal];
            } else {
                [self.loadMoreButton setTitle:T(@"点击加载更多") forState:UIControlStateNormal];
            }

            [self.tableView reloadData];
            
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
        [self.loadMoreButton setEnabled:YES];
        [self.loadMoreButton setHidden:NO];
        self.isLOADMORE = NO;
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define CELL_HEIGHT     125.0f
#define BUTTON_PER_CELL 2

#define BUTTON_L_TAG    1
#define LABEL_L_TAG     2

#define BUTTON_R_TAG    3
#define LABEL_R_TAG     4
#define CELL_BG_TAG     5

#define BUTTON_X        13.0f
#define BUTTON_Y        0.0f
#define BUTTON_WIDTH    135.0f
#define BUTTON_HEIGHT   95.0f
#define LABEL_HEIGHT    24.0f
#define BG_Y            93.0f
#define BG_HEIGHT       15.0f

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // left button
    UILabel *labelLeft = [[UILabel alloc]initWithFrame:CGRectMake(BUTTON_X, BUTTON_HEIGHT, BUTTON_WIDTH, LABEL_HEIGHT)];
    labelLeft.textAlignment = NSTextAlignmentCenter;
    labelLeft.font = [UIFont boldSystemFontOfSize:14];
    labelLeft.textColor = BLUECOLOR;
    labelLeft.backgroundColor = [UIColor clearColor];
    labelLeft.numberOfLines = 1;
    labelLeft.tag = LABEL_L_TAG;
    
    ThumbnailUIButton *buttonLeft = [ThumbnailUIButton buttonWithType:UIButtonTypeCustom];
    [buttonLeft setFrame:CGRectMake(BUTTON_X, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT)];
    buttonLeft.tag = BUTTON_L_TAG;

    // right button
    UILabel *labelRight = [[UILabel alloc]initWithFrame:CGRectMake(BUTTON_X*2+BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_WIDTH, LABEL_HEIGHT)];
    labelRight.textAlignment = NSTextAlignmentCenter;
    labelRight.font = [UIFont boldSystemFontOfSize:14];
    labelRight.textColor = BLUECOLOR;
    labelRight.backgroundColor = [UIColor clearColor];
    labelRight.numberOfLines = 1;
    labelRight.tag = LABEL_R_TAG;
    
    ThumbnailUIButton *buttonRight = [ThumbnailUIButton buttonWithType:UIButtonTypeCustom];
    [buttonRight setFrame:CGRectMake(BUTTON_X*2+BUTTON_WIDTH, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT)];
    buttonRight.tag = BUTTON_R_TAG;
    
    UIImageView *cell_bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, BG_Y, TOTAL_WIDTH, BG_HEIGHT)];
    [cell_bg setImage:[UIImage imageNamed:@"cell_shadow.png"]];
    cell_bg.tag = CELL_BG_TAG;
    
    [cell.contentView addSubview:cell_bg];
    [cell.contentView addSubview:labelLeft];
    [cell.contentView addSubview:buttonLeft];
    [cell.contentView addSubview:labelRight];
    [cell.contentView addSubview:buttonRight];
    
    return  cell;
}

- (NSUInteger)leftIndex:(NSIndexPath *)indexPath
{
    return indexPath.row * BUTTON_PER_CELL;
}

- (NSUInteger)rightIndex:(NSIndexPath *)indexPath
{
    return indexPath.row * BUTTON_PER_CELL+1;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger count = [self.sourceData count];
    // left
    UILabel *leftLabel = (UILabel *)[cell viewWithTag:LABEL_L_TAG];
    ThumbnailUIButton *leftButton = (ThumbnailUIButton *)[cell viewWithTag:BUTTON_L_TAG];

    
    // right
    UILabel *rightLabel = (UILabel *)[cell viewWithTag:LABEL_R_TAG];
    ThumbnailUIButton *rightButton = (ThumbnailUIButton *)[cell viewWithTag:BUTTON_R_TAG];
    
    
    Zipfile *leftZipfile = [self.sourceData objectAtIndex:[self leftIndex:indexPath]];
    leftLabel.text = leftZipfile.title;
    [leftButton setAvatar:leftZipfile.fileName];
    
    
    // 偶数
    if (count %2 == 0 || (count %2 == 1 && indexPath.row < floor(count / 2))) {
        NSLog(@"%d %d show",indexPath.row, count);
        
        Zipfile *rightZipfile = [self.sourceData objectAtIndex:[self rightIndex:indexPath]];
        rightLabel.text = rightZipfile.title;
        [rightButton setAvatar:rightZipfile.fileName];
        [rightButton setHidden:NO];
        
    }else{
        [rightButton setHidden:YES];
    }
    
    leftButton.buttonIndex = indexPath.row * BUTTON_PER_CELL;
    rightButton.buttonIndex= indexPath.row * BUTTON_PER_CELL + 1;
    
    [leftButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // bgview
    UIImageView *bgView = (UIImageView *)[cell viewWithTag:CELL_BG_TAG];
    
    if (count %2 == 0) {
        [bgView setImage:[UIImage imageNamed:@"cell_shadow.png"]];
        bgView.frame = CGRectMake(0, BG_Y, TOTAL_WIDTH, BG_HEIGHT);
    }else{
        [bgView setImage:[UIImage imageNamed:@"half_cell_shadow.png"]];
        bgView.frame = CGRectMake(0, BG_Y, TOTAL_WIDTH/2, BG_HEIGHT);
    }

}

- (void)buttonClick:(ThumbnailUIButton *)sender
{
    NSLog(@"sender.buttonIndex %d",sender.buttonIndex);
    [self.navigationController popToRootViewControllerAnimated:NO];

    Zipfile *theZipfile = [self.sourceData objectAtIndex:sender.buttonIndex];
    
    [self appDelegate].mainViewController.planetString = theZipfile.fileName;
    [self appDelegate].mainViewController.title = theZipfile.title;

    [ModelDownload sharedInstance].lastPlanet = theZipfile.fileName;
    /* 绑定这两个 delegate */
    [ModelDownload sharedInstance].delegate = (id)[self appDelegate].mainViewController;
    [[ModelDownload sharedInstance] downloadAndUpdate:theZipfile];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSUInteger count = [self.sourceData count];
    if (count % 2 == 0) {
        return floor(count / 2);
    }else{
        return floor(count / 2) + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MainListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
    }
    
    
    // Configure the cell...
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}


- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = BGCOLOR;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    Company *aCompany = [self.sourceData objectAtIndex:indexPath.row];
    
//    [self getDict:aCompany.companyID];
//    back to mainviewcontroller and set
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors & selectors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)settingAction
{
    SettingViewController *controller = [[SettingViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
