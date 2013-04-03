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

#import "DDLog.h"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface MainViewController ()
{
    SystemSoundID completeSound;
}

@property(strong, nonatomic)UIImageView *titleImage;
@property(strong, nonatomic)AlbumViewController *pageViewController;
@property(strong, nonatomic)UIButton *enterButton;
@property(strong, nonatomic)UIButton *button1;

@property(strong, nonatomic)NSArray *albumArray;
@property(strong, nonatomic)NSArray *animationArray;
@property(strong, nonatomic)NSString *audioPath;
@property(strong, nonatomic)UIImageView *animArea;
@property(strong, nonatomic)UIButton *listButton;
@property(strong, nonatomic)Zipfile *theZipfile;
@property(assign, nonatomic)NSInteger picCount;
@property(assign, nonatomic)NSInteger aniCount;
@end

@implementation MainViewController
@synthesize pageViewController;
@synthesize titleImage;
@synthesize enterButton;
@synthesize albumArray;
@synthesize animationArray;
@synthesize audioPath;
@synthesize button1;
@synthesize animArea;
@synthesize listButton;
@synthesize planetString;
@synthesize theZipfile;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize picCount;
@synthesize aniCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = T(@"小羊咩咩叫");
        
        self.listButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 29)];
        [self.listButton setBackgroundImage:[UIImage imageNamed: @"list_button.png"] forState:UIControlStateNormal];
        [self.listButton addTarget:self action:@selector(listAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.listButton];
    }
    return self;
}
// 整理数据 写数据库
- (void)makeArrayWithString:(NSString *)planet
{
    self.theZipfile = [[ModelHelper sharedInstance]findZipfileWithFileName:planet];
    
    if (self.theZipfile.isDownload.boolValue) {
        NSString *path = [[self appDelegate].LIBRARYPATH stringByAppendingPathComponent:planet];
        NSArray *tt = [self listFileAtPath:path];
        
        DDLogVerbose(@"------%@",path);
    }
    


}

-(NSArray *)listFileAtPath:(NSString *)path
{
    self.picCount = 0;
    self.aniCount = 0;
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *name = [directoryContent objectAtIndex:count];
        
        NSRange pRange = [name rangeOfString:@"p"];
        if (pRange.location == 0) {
//            DDLogVerbose(@"%@",[name substringFromIndex:1]);
            self.picCount = self.picCount + 1;
        }
        
        NSRange aRange = [name rangeOfString:@"a"];
        if (aRange.location == 0) {
//            DDLogVerbose(@"%@",[name substringFromIndex:1]);
            self.aniCount = self.aniCount + 1;
        }
        
//        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
//        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:name]];
        
//        DDLogVerbose(@"pic %d, ani %d",self.picCount, self.aniCount);

    }
    
    
    self.theZipfile.aniCount = STR_INT(self.aniCount);
    self.theZipfile.picCount = STR_INT(self.picCount);
    
    
//    self.albumArray = self
    self.albumArray = [self makeAlbumArrayWithCount:self.picCount andPath:path];
    self.animationArray = [self makeAnimationArrayWithCount:self.aniCount andPath:path];
    self.audioPath = [path stringByAppendingPathComponent:@"/sound.wav"];
    
    return directoryContent;
}

// make album array

- (NSArray *)makeAlbumArrayWithCount:(NSInteger)count andPath:(NSString *)path
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < count; i++) {
        NSString *picFilePath = [NSString stringWithFormat:@"%@/p%d.png",path,i];
        UIImage *image = [UIImage imageWithContentsOfFile:picFilePath];
//        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",i+1]];

        [tmpArray addObject:image];
//        [tmpArray insertObject:image atIndex:i];
    }
    
    NSArray *resultArray = [[NSArray alloc]initWithArray:tmpArray];
    
    return resultArray;
}

// make animation array
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

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.enterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.enterButton setTitle:@"Enter" forState:UIControlStateNormal];
    
    [self.enterButton setFrame:CGRectMake(60, 300, 200, 40)];
    [self.enterButton addTarget:self action:@selector(enterAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.enterButton];
    
    self.pageViewController = [[AlbumViewController alloc] init];
    
	// Do any additional setup after loading the view.
    
    self.albumArray = [[NSArray alloc]init];
    self.animationArray = [[NSArray alloc]init];
    
    id json = [self.albumArray JSONString];
    NSLog(@"%@",json);
    
    //button1
    self.button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button1.frame = CGRectMake(0, 0, 320, 290);
    [self.button1 setTitle:@"" forState:UIControlStateNormal];
    [self.button1 addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
    self.button1.alpha = 1;
    self.button1.tag = 0;
    [self.view addSubview:self.button1];
    

    // that is overall seconds. hence: frames divided by about 30 or 20.
    [self makeArrayWithString:self.planetString];
    
    self.animArea = [[UIImageView alloc] initWithFrame:CGRectMake(60, 40, 200, 200)];
    self.animArea.animationImages = self.animationArray;
    self.animArea.animationRepeatCount = 0;
    self.animArea.animationDuration = 1.2;
    
    [self.animArea startAnimating];
    [self.view addSubview:self.animArea];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)enterAction
{
    
    self.pageViewController.albumArray = self.albumArray;
//    self.pageViewController.titleArray = [[NSArray alloc]initWithObjects:
//    T(@"两个圈圈放中间"),T(@"眼在头上身描边"),T(@"四个小腿画下面"),T(@"最后加上耳鼻眼"),T(@"咩. 咩. 咩. "), nil];
    //    albumViewController.albumIndex = sender.tag;
    [self.pageViewController setHidesBottomBarWhenPushed:YES];
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:self.pageViewController animated:YES];

}


-(void) playSound {
    
    NSURL *audioURL = [NSURL fileURLWithPath:self.audioPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioURL, &completeSound);
    AudioServicesPlaySystemSound (completeSound);
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
