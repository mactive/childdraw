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
#import "Zipfile.h"
#import "SSZipArchive.h"
#import "DDTTYLogger.h"

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
@end

@implementation AppDelegate
@synthesize mainViewController;
@synthesize versionAlertView;
@synthesize systemVersion;
@synthesize downArray;
@synthesize LIBRARYPATH;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Init DDLog
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    self.systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // mainMenuViewController
    
    self.mainViewController = [[MainViewController alloc]initWithNibName:nil bundle:nil];
    UINavigationController *mainController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = BGCOLOR;
    [self.window addSubview:self.mainViewController.view];
    [self.window setRootViewController:mainController];
    
    // Global UINavigationBar style
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationBar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:121/255 green:123/255 blue:126/255 alpha:1.0] ];
    [[UIBarButtonItem appearance] setTintColor:RGBACOLOR(55, 61, 70, 1)];
    
    if (self.systemVersion > 6.0) {
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }
    
    
    application.statusBarHidden = NO;
    // Set up Core Data stack.
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"childDraw" withExtension:@"momd"]]];
    NSError *error;
    NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"childDraww.sqlite"] options:nil error:&error];
    if (store == nil) {
        DDLogVerbose(@"Add-Persistent-Store Error: %@", error);
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    [ModelHelper sharedInstance].managedObjectContext = _managedObjectContext;
    
    //
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    self.LIBRARYPATH =[[paths objectAtIndex:0] stringByAppendingPathComponent:@"/Assets/"];
    
    // actions
    [self getConfig];
    
    _defaultGetCount  = 7;
    [self downloadLastFiles:_defaultGetCount];
    
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)downloadLastFiles:(NSInteger)count
{
    NSManagedObjectContext *moc = _managedObjectContext;    
    
    self.downArray = [[NSMutableArray alloc]init];
    
    [[AppNetworkAPIClient sharedClient]getItemsCount:count withBlock:^(id responseObject, NSString *zipPrefixString, NSError * error) {
        
//        NSDictionary *responseDict = responseObject;
//        NSDictionary *responseItem;
//        NSEnumerator *enumerator = [responseDict objectEnumerator];
//
//        while (responseItem = [enumerator nextObject]) {
//            NSString *urlString = [NSString stringWithFormat:@"%@%@.zip",zipPrefixString,[responseItem objectForKey:@"key"]];
//            [downloadURL addObject:urlString];
//            [self downloadWithURLString:urlString];
//        }
        
        if (!StringHasValue(zipPrefixString)) {
            zipPrefixString = ZIPPREFIX;
        }
        
        if (responseObject != nil) {
            
            NSArray *sourceData = [[NSArray alloc]initWithArray:responseObject];
            
            [sourceData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                //
                NSString *urlString = [NSString stringWithFormat:@"%@%@.zip",zipPrefixString,[obj objectForKey:@"key"]];
                DDLogVerbose(@"urlString %@",urlString);
                [self.downArray addObject:urlString];

                Zipfile *newZipfile = [[ModelHelper sharedInstance] findZipfileWithFileName:[obj objectForKey:@"key"]];
                if (newZipfile == nil) {
                    newZipfile = [NSEntityDescription insertNewObjectForEntityForName:@"Zipfile" inManagedObjectContext:moc];
                    [[ModelHelper sharedInstance]populateZipfile:newZipfile withServerJSONData:obj];
                    DDLogVerbose(@"SYNC insert a zipfile");
                    
                    // go download
                    [self downloadURLString:urlString withZipfile:newZipfile];
                    newZipfile.downloadTime = [NSDate date];
                    
                }else{
                    if ([newZipfile.isDownload isEqualToNumber:NUM_BOOL(NO)]) {
                        DDLogVerbose(@"SYNC download a zipfile");
                        // go download
                        [self downloadURLString:urlString withZipfile:newZipfile];
                        newZipfile.downloadTime = [NSDate date];
                    }else{
                        // 存在而且已经下载 不再下载
                    }
                }
#warning mocsave
             // MOCSave(moc);
            }];
            
        }

     
     
    }];
}

// download
- (void)downloadURLString:(NSString *)urlString withZipfile:(Zipfile *)theZipfile
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    // 不同的文件
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:theZipfile.fileName];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Successfully downloaded file to %@ %@", path,urlString);
        theZipfile.isDownload = NUM_BOOL(YES);
        [self unzipFileName:theZipfile.fileName WithPath:path];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        theZipfile.isDownload = NUM_BOOL(NO);
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

// unzip

- (void)unzipFileName:(NSString *)filename WithPath:(NSString*)path
{
    // unzip pathdfdfddfadfd
    NSString *zipPath = path;
    NSString *destinationPath = [self.LIBRARYPATH stringByAppendingPathComponent:filename];
    [SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath];
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
    [self saveContext];
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
#pragma mark - getIPAddress
//////////////////////////////////

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

@end
