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

@end

@implementation ListViewController
@synthesize settingButton;
@synthesize managedObjectContext;
@synthesize sourceData;
@synthesize sourceDict;
@synthesize tableView;

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
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.tableView.delegate = self;
    self.tableView.dataSource  = self;
    [self.view addSubview:self.tableView];
    
    self.sourceData = [[NSArray alloc]init];
    [self populateData];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// 解析公司列表
- (void)populateData
{
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = T(@"努力加载中");
    
    [[AppNetworkAPIClient sharedClient]getThumbnailsWithBlock:^(id responseDict, NSString *thumbnailPrefix, NSError *error) {
        //
        if (responseDict != nil) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];

            NSArray *tempArray = [[NSArray alloc] initWithArray:responseDict];
            NSMutableArray *tempMutableArray = [[NSMutableArray alloc]init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Zipfile" inManagedObjectContext:self.managedObjectContext];
            
            for (int i=0; i < [tempArray count]; i++) {
                NSDictionary *dict = [tempArray objectAtIndex:i];
                Zipfile *aZipfile = [[ModelHelper sharedInstance]findZipfileWithFileName:[[dict objectForKey:@"key"] stringValue]];
                if (aZipfile == nil) {
                    aZipfile = (Zipfile *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
                    [[ModelHelper sharedInstance]populateZipfile:aZipfile withServerJSONData:dict];
//                    [[ModelDownload sharedInstance] downloadWithURL:dict];
                }else{
//                    [[ModelDownload sharedInstance] downloadAndUpdate:aZipfile];
                }
                [tempMutableArray addObject:aZipfile];
            }
            
            self.sourceData = [[NSArray alloc]initWithArray:tempMutableArray];
            [self.tableView reloadData];
            
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];

//            [ConvenienceMethods showHUDAddedTo:self.view animated:YES text:T(@"网络错误 暂时无法刷新") andHideAfterDelay:1];
        }
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define CELL_HEIGHT     130.0f
#define BUTTON_PER_CELL 2

#define BUTTON_L_TAG    1
#define LABEL_L_TAG     2

#define BUTTON_R_TAG    3
#define LABEL_R_TAG     4

#define BUTTON_X        10.0f
#define BUTTON_Y        0.0f
#define BUTTON_WIDTH    145.0f
#define BUTTON_HEIGHT   90.0f
#define LABEL_HEIGHT    24.0f


- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
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

@end
