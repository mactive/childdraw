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
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
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
    self.sourceDict = [[NSMutableDictionary alloc]init];
    [[AppNetworkAPIClient sharedClient]getThumbnailsWithBlock:^(id responseDict, NSString *thumbnailPrefix, NSError *error) {
        //
        if (responseDict != nil) {
            self.sourceDict = responseDict;
            NSArray *tempArray = [self.sourceDict allValues];
            NSMutableArray *tempMutableArray = [[NSMutableArray alloc]init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Zipfile" inManagedObjectContext:self.managedObjectContext];
            
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
            
            [self.tableView reloadData];
        }else{
//            [ConvenienceMethods showHUDAddedTo:self.view animated:YES text:T(@"网络错误 暂时无法刷新") andHideAfterDelay:1];
        }
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.sourceData count];
}
#define CELL_HEIGHT 50.0f

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

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = RGBCOLOR(195, 70, 21);
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.layer.cornerRadius = 5.0f;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(80, 30 , 60, 15)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:10];
    label.textColor = [UIColor whiteColor];
    [label.layer setCornerRadius:3];
    label.numberOfLines = 0;
    
    [cell.contentView addSubview:label];
    
    return  cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = [self.sourceData objectAtIndex:indexPath.row];
    cell.textLabel.text = [[dict objectForKey:@"key"] stringValue];
    cell.imageView.image = [dict objectForKey:@"thumbnail"];
    
//    cell.imageView.image = [UIImage imageNamed:@"5.png"];
//    cell.textLabel.text = @"title";
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
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors & selectors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
