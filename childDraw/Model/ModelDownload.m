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
        if(StringHasValue([[obj objectForKey:@"key"] stringValue])){
            keyString = [[obj objectForKey:@"key"] stringValue];
        }
    }
    
    NSManagedObjectContext *moc = self.managedObjectContext;

    NSString *zipPrefixString = ZIPPREFIX;

    
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
        
        //                    [self checkIsDownloadedWithZipfile:newZipfile];
        
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
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        // pass to mainview
        float progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
//        DDLogVerbose(@"download precent %f",progress);
        if ([self.lastPlanet isEqualToString:theZipfile.fileName]) {
            [self.delegate passNumberValue:[NSNumber numberWithFloat:progress] andTitle:theZipfile.fileName];
        }
    }];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Successfully downloaded file to %@ %@", path,urlString);
        theZipfile.isDownload = NUM_BOOL(YES);
        [self unzipFileName:theZipfile.fileName WithPath:path];
        theZipfile.isZiped = NUM_BOOL(YES);
        if ([self.lastPlanet isEqualToString:theZipfile.fileName]) {
            [self.delegate passStringValue:DOWNLOADFINISH andIndex:0];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        theZipfile.isDownload = NUM_BOOL(NO);
        theZipfile.isZiped = NUM_BOOL(NO);
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

// unzip

- (void)unzipFileName:(NSString *)filename WithPath:(NSString*)path
{
    
    // unzip path to directory filename
    NSString *zipPath = path;
    NSString *destinationPath = [[self appDelegate].LIBRARYPATH stringByAppendingPathComponent:filename];
    [SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath];
}

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


@end
