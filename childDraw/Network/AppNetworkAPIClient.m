//
//  AppNetworkAPIClient.m
//  childDraw
//
//  Created by meng qian on 13-3-29.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "AppNetworkAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "DDLog.h"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

// default 
static NSString * const kAppNetworkAPIBaseURLString = @"http://192.168.1.104:8004/";

@interface AppNetworkAPIClient ()
{
    NSLock *_imageQueueLock;
    NSLock *_queuedOperationLock;
}

@property (nonatomic, strong) NSMutableArray *queuedOperations;

@end

@implementation AppNetworkAPIClient
@synthesize kNetworkStatus;
@synthesize queuedOperations;

+ (AppNetworkAPIClient *)sharedClient {
    static AppNetworkAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AppNetworkAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAppNetworkAPIBaseURLString]];
        [_sharedClient setDefaultHeader:@"Accept-Language" value:nil];
    });
    
    return _sharedClient;
}

// getConfig
- (void)getConfigWithBlock:(void (^)(id, NSError *))block
{
    NSMutableURLRequest *loginRequest = [[AppNetworkAPIClient sharedClient] requestWithMethod:@"GET" path:GET_CONFIG_PATH parameters:nil];
    AFJSONRequestOperation * loginOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:loginRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //
        DDLogVerbose(@"get config JSON received: %@", JSON);
        [[NSUserDefaults standardUserDefaults] setObject:[JSON valueForKey:@"csrfmiddlewaretoken"] forKey:@"csrfmiddlewaretoken"];
        [[NSUserDefaults standardUserDefaults] setObject:[JSON valueForKey:@"ios_ver"] forKey:@"ios_ver"];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //
        DDLogVerbose(@"get config failed: %@", error);
        if (block) {
            block(nil, error);
        }
    }];
    
    [[AppNetworkAPIClient sharedClient] enqueueHTTPRequestOperation:loginOperation];
}


// 上传devicetoken
- (void)postDeviceToken{
    
    NSString* csrfToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"csrfmiddlewaretoken"];
    NSString* dToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];
    
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     csrfToken, @"csrfmiddlewaretoken",
                                     dToken, @"dt",
                                     nil];
    
    NSMutableURLRequest *postRequest = [[AppNetworkAPIClient sharedClient] requestWithMethod:@"POST" path:POST_DEVICE_PATH parameters:postDict];
    AFHTTPRequestOperation *oper = [[AppNetworkAPIClient sharedClient] HTTPRequestOperationWithRequest:postRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"device successfully uploaded");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogInfo(@"device failed uploaded");
    }];
    
    if (self.isLoggedIn) {
        [[AppNetworkAPIClient sharedClient] enqueueHTTPRequestOperation:oper];
    } else {
        [_queuedOperationLock lock];
        [self.queuedOperations addObject:oper];
        [_queuedOperationLock unlock];
    }
    
}


@end
