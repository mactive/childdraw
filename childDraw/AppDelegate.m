//
//  AppDelegate.m
//  childDraw
//
//  Created by meng qian on 13-3-22.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "UINavigationBar+customNavigation.h"
#import "AppNetworkAPIClient.h"
#import "AFHTTPRequestOperation.h"
#import "IPAddress.h"
#import "ModelHelper.h"
#import "ModelDownload.h"
#import "Zipfile.h"
#import "SSZipArchive.h"
#import "DDTTYLogger.h"
#import "ServerDataTransformer.h"


#import "DDLog.h"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface AppDelegate()<UIAlertViewDelegate>
{
    NSManagedObjectContext *_managedObjectContext;
    NSUInteger              _defaultGetCount;
}

@property(nonatomic, strong) UIAlertView *versionAlertView;
@property(readwrite, nonatomic) CGFloat systemVersion;
@property(nonatomic,strong)NSMutableArray *downArray;
@property(nonatomic, strong)NSString *lastPlanet; // 最新的package
@property(nonatomic, strong)NSString *lastPlanetTitle; // 最新的package

@end

@implementation AppDelegate
@synthesize mainViewController;
@synthesize versionAlertView;
@synthesize systemVersion;
@synthesize downArray;
@synthesize LIBRARYPATH;
@synthesize lastPlanet;
@synthesize lastPlanetTitle;
@synthesize listViewContorller;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Init DDLog
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    self.systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
    application.statusBarHidden = NO;

    
    // Global UINavigationBar style
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationBar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:121/255 green:123/255 blue:126/255 alpha:1.0] ];
    [[UIBarButtonItem appearance] setTintColor:RGBACOLOR(55, 61, 70, 1)];
    
    if (self.systemVersion > 6.0) {
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }
    
    // Set up Core Data stack.
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"childDraw" withExtension:@"momd"]]];
    NSError *error;
    NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"childDraw.sqlite"] options:nil error:&error];
    if (store == nil) {
        DDLogVerbose(@"Add-Persistent-Store Error: %@", error);
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    [ModelHelper sharedInstance].managedObjectContext = _managedObjectContext;
    [ModelDownload sharedInstance].managedObjectContext = _managedObjectContext;
    
    //
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    self.LIBRARYPATH =[[paths objectAtIndex:0] stringByAppendingPathComponent:@"/Assets/"];
    
    // actions
    [self getConfig];
    
    _defaultGetCount  = 1;
    [self downloadLastFiles:_defaultGetCount];
    
//    [WXApi registerApp:WXAPPID];
    
    return YES;
}


#pragma mark TODO

#warning TODO 第一次下载有个intro 可爱的动画

- (void)startIntroSession
{
    // 在intro的时候下载 然后下载完成10个后进去intro
}

- (void)startMainSession
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // mainMenuViewController
    
    self.mainViewController = [[MainViewController alloc]initWithNibName:nil bundle:nil];
    UINavigationController *mainController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    self.mainViewController.managedObjectContext = _managedObjectContext;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = BGCOLOR;
    [self.window addSubview:self.mainViewController.view];
    [self.window setRootViewController:mainController];
    
    [self.window makeKeyAndVisible];

}

-(void)getTheLastPlanet:(NSArray *)data
{
    NSArray* sorted = [data sortedArrayUsingComparator:(NSComparator)^(NSDictionary *item1, NSDictionary *item2) {
        NSString *score1 = [ServerDataTransformer getStringObjFromServerJSON:item1 byName:@"key"];
        NSString *score2 = [ServerDataTransformer getStringObjFromServerJSON:item2 byName:@"key"];
        return [score1 compare:score2 options:NSNumericSearch];
    }];
    
    NSNumber * tmp = [ServerDataTransformer getNumberObjFromServerJSON:[sorted lastObject] byName:@"key"];
    self.lastPlanet = tmp.stringValue;
    self.lastPlanetTitle = [ServerDataTransformer getStringObjFromServerJSON:[sorted lastObject] byName:@"title"];
}

- (void)downloadLastFiles:(NSInteger)count
{
    [self startMainSession];

    NSManagedObjectContext *moc = _managedObjectContext;
    
    self.downArray = [[NSMutableArray alloc]init];
    
    [[AppNetworkAPIClient sharedClient]getItemsCount:count withBlock:^(id responseObject, NSString *zipPrefixString, NSError * error) {
        
        if (!StringHasValue(zipPrefixString)) {
            zipPrefixString = ZIPPREFIX;
        }
        
        if (responseObject != nil) {
            
            NSArray *sourceData = [[NSArray alloc]initWithArray:responseObject];
            
            [self getTheLastPlanet:sourceData];
            self.mainViewController.planetString = self.lastPlanet;
            self.mainViewController.titleString = self.lastPlanetTitle;

//            self.lastPlanet = @"1364803267";
            [ModelDownload sharedInstance].lastPlanet = self.lastPlanet;
            /* 绑定这两个 delegate */
            [ModelDownload sharedInstance].delegate = (id)self.mainViewController;
            
            [sourceData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                // 交给 delegate 去做
                [[ModelDownload sharedInstance] downloadWithURL:obj];
#warning mocsave // MOCSave(moc);
            }];
            
            
        }else{
            DDLogWarn(@"Not get nothing");
        }
     
    }];
    
}

///////////////////////////////////////////////////////
#pragma mark -- get config
///////////////////////////////////////////////////////

- (BOOL)getConfig
{
    [[AppNetworkAPIClient sharedClient]getConfigWithBlock:^(id responseObject, NSError *error) {
        if (responseObject != nil) {
            //
            [self checkIOSVersion];
        }
    }];
    return YES;
}

///////////////////////////////////////////////////////
// check version
///////////////////////////////////////////////////////
- (void)checkIOSVersion
{
    NSString *iOSVersion =  [[NSUserDefaults standardUserDefaults] objectForKey:@"ios_ver"];
    if (StringHasValue(iOSVersion) ) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        self.versionAlertView = [[UIAlertView alloc]initWithTitle:T(@"目前有新版本，是否升级") message:T(@"更多新功能，运行更流畅") delegate:self cancelButtonTitle:T(@"否") otherButtonTitles:T(@"是"), nil];
        
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        
        NSNumber *iOSVersion_num = [f numberFromString:iOSVersion];
        NSNumber *version_num = [f numberFromString:version];
        
        
        if (iOSVersion_num.floatValue > version_num.floatValue ) {
            [self.versionAlertView show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.versionAlertView]) {
        if (buttonIndex == 0){
            //cancel clicked ...do your action
        }else if (buttonIndex == 1){
            NSString *str = [NSString stringWithFormat:
                             @"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%d",
                             M_APPLEID ];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
    }
}

///////////////////////////////////////////////////////
#pragma mark - application delegate
///////////////////////////////////////////////////////

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self startIntroSession];
    [self downloadLastFiles:1];
}

- (void)saveContext
{
    NSError *error = nil;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DDLogVerbose(@"Unresolved error saving object context s%@, %@", error, [error userInfo]);
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    [self saveContext];
}

//////////////////////////////////
#pragma mark - didRegisterForRemoteNotificationsWithDeviceToken
//////////////////////////////////
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokenStr = [NSString stringWithFormat:@"%@",deviceToken];
    NSString *deviceTokenString = [[deviceTokenStr substringWithRange:NSMakeRange(0, 72)] substringWithRange:NSMakeRange(1, 71)];
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey:@"deviceToken"];
    [[AppNetworkAPIClient sharedClient] postDeviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    DDLogVerbose(@"token %@",str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    for (id key in userInfo) {
        DDLogVerbose(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
}

//////////////////////////////////
#pragma mark - wechat rewrite
//////////////////////////////////
/*
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [WXApi handleOpenURL:url delegate:self];
}
*/

//////////////////////////////////
#pragma mark - getIPAddress
//////////////////////////////////
/*
- (void)getIPAddress
{
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    
    int i;
    NSString *deviceIP = nil;
    for (i=0; i<MAXADDRS; ++i)
    {
        static unsigned long localHost = 0x7F000001;        // 127.0.0.1
        unsigned long theAddr;
        
        theAddr = ip_addrs[i];
        
        if (theAddr == 0) break;
        if (theAddr == localHost) continue;
        
        NSLog(@"Name: %s MAC: %s IP: %s\n", if_names[i], hw_addrs[i], ip_names[i]);
        
        //decided what adapter you want details for
        if (strncmp(if_names[i], "en", 2) == 0)
        {
            NSLog(@"Adapter en has a IP of %s %s", hw_addrs[i], ip_names[i]);
        }
    }
}
*/

@end
