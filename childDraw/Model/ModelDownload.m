//
//  ModelDownload.m
//  childDraw
//
//  Created by meng qian on 13-4-3.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "ModelDownload.h"
#import "AppNetworkAPIClient.h"
#import "AFHTTPRequestOperation.h"
#import "IPAddress.h"
#import "ModelHelper.h"
#import "Zipfile.h"
#import "SSZipArchive.h"
#import "AppDelegate.h"
#import "ServerDataTransformer.h"

#import "DDLog.h"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif

@interface ModelDownload()


@end

@implementation ModelDownload
@synthesize managedObjectContext;
@synthesize filename;
@synthesize lastPlanet;
@synthesize delegate;

+ (ModelDownload *)sharedInstance {
    static ModelDownload *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ModelDownload alloc] init];
    });
    
    return _sharedClient;
}

-(void)downloadWithURL:(NSDictionary *)obj
{
    NSString *keyString;
    if (StringHasValue(self.filename)) {
        keyString = self.filename;
    }else if (obj != nil){
        if(StringHasValue([ServerDataTransformer getStringObjFromServerJSON:obj byName:@"key"])){
            keyString = [ServerDataTransformer getStringObjFromServerJSON:obj byName:@"key"];
        }
    }
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    
    // zipPrefixString
    NSString *zipPrefixString = [[NSUserDefaults standardUserDefaults] objectForKey:@"zip_prefix"];
    if (!StringHasValue(zipPrefixString)) {
        zipPrefixString = ZIPPREFIX;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@.zip",zipPrefixString,keyString];
    DDLogVerbose(@"urlString %@",urlString);
//    [self.downArray addObject:urlString];

    Zipfile *newZipfile = [[ModelHelper sharedInstance] findZipfileWithFileName:keyString];
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
            // 存在而且已经下载 不再下载 直接播放
            [self.delegate passStringValue:DOWNLOADFINISH andIndex:0];
        }
    }
}

- (void)downloadAndUpdate:(Zipfile *)theZipfile
{    
    if (theZipfile.isDownload.floatValue) {
        [self.delegate passStringValue:DOWNLOADFINISH andIndex:0];
    }else{
        // zipPrefixString
        NSString *zipPrefixString = [[NSUserDefaults standardUserDefaults] objectForKey:@"zip_prefix"];
        if (!StringHasValue(zipPrefixString)) {
            zipPrefixString = ZIPPREFIX;
        }
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@.zip",zipPrefixString,theZipfile.fileName];
        [self downloadURLString:urlString withZipfile:theZipfile];
        theZipfile.downloadTime = [NSDate date];

    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - download and unzip
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

// download
- (void)downloadURLString:(NSString *)urlString withZipfile:(Zipfile *)theZipfile
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    // 不同的文件
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:theZipfile.fileName];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    
    [self.delegate passStringValue:DOWNLOADING andIndex:0];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        // pass to mainview
        float progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
//        DDLogVerbose(@"download precent %f",progress);
        if ([self.lastPlanet isEqualToString:theZipfile.fileName]) {
            [self.delegate passNumberValue:[NSNumber numberWithFloat:progress] andTitle:theZipfile.fileName];
        }
    }];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogVerbose(@"Successfully downloaded file to %@ %@", path,urlString);
        theZipfile.isDownload = NUM_BOOL(YES);
#warning unzip is
        [self unzipFileName:theZipfile.fileName WithPath:path];
        theZipfile.isZiped = NUM_BOOL(YES);
        if ([self.lastPlanet isEqualToString:theZipfile.fileName]) {
            [self.delegate passStringValue:DOWNLOADFINISH andIndex:0];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        theZipfile.isDownload = NUM_BOOL(NO);
        theZipfile.isZiped = NUM_BOOL(NO);
        DDLogError(@"Error: %@", error);
        [self.delegate passStringValue:DOWNLOADFAILED andIndex:0];

    }];
    
    [operation start];
}

// unzip

- (void)unzipFileName:(NSString *)filename WithPath:(NSString*)path
{
    // unzip path to directory filename
    NSString *zipPath = path;
    NSString *destinationPath = [[self appDelegate].ASSETPATH stringByAppendingPathComponent:filename];
    [SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - download thumbnail
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)downloadThumbnailwithFilename:(NSString *)fileName
{
    
    NSString *prefix = [[NSUserDefaults standardUserDefaults] objectForKey:@"thumbnail_prefix"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@.png",prefix,filename];    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // 不同的文件
    NSString *path = [[self appDelegate].THUMBNAILPATH stringByAppendingPathComponent:fileName];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogVerbose(@"Successfully thumbnail file to %@ %@", path,urlString);
        
#warning passstring
        // 下载成功之后再显示 passstring 给那个listview to show
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"Error: %@", error);
    }];
    
    [operation start];
}

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


@end
