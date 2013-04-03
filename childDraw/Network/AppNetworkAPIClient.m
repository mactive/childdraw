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
//static NSString * const kAppNetworkAPIBaseURLString = @"http://192.168.1.104:8004/";
static NSString * const kAppNetworkAPIBaseURLString = @"http://c.wingedstone.com:8004/";

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

// getItemsCount
- (void)getItemsCount:(NSInteger)count withBlock:(void(^)(id, NSString *, NSError *))block
{
    NSString *pathString = [NSString stringWithFormat:@"%@%d",GET_ITEMS_PATH, count];
    NSMutableURLRequest *itemRequest = [[AppNetworkAPIClient sharedClient] requestWithMethod:@"GET" path:pathString parameters:nil];
    
    AFJSONRequestOperation * itemOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:itemRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //
//        DDLogVerbose(@"get getItemsCount JSON received: %@", JSON);
        
        NSString *httpZipPrefix = [NSString stringWithFormat:@"http://%@/",[JSON valueForKey:@"zip_prefix"]];
        [[NSUserDefaults standardUserDefaults] setObject:httpZipPrefix forKey:@"zip_prefix"];
        
        NSString* type = [JSON valueForKey:@"type"];
        if (![@"error" isEqualToString:type]) {
            if (block) {
                block ([JSON valueForKey:@"items"], httpZipPrefix , nil);
            }
        } else {
            if (block) {
                NSError *error = [[NSError alloc] initWithDomain:@"wingedstone.com" code:403 userInfo:nil];
                block (nil, nil, error);
            }
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //
        DDLogVerbose(@"get getItemsCount failed: %@", error);
        if (block) {
            block(nil, nil, error);
        }
    }];
    
    [[AppNetworkAPIClient sharedClient] enqueueHTTPRequestOperation:itemOperation];
}

// getItemsThumbnail
- (void)getThumbnailsWithBlock:(void(^)(id, NSString *, NSError *))block
{
    NSMutableURLRequest *itemRequest = [[AppNetworkAPIClient sharedClient] requestWithMethod:@"GET" path:GET_THUMBNAIL_PATH parameters:nil];
    
    AFJSONRequestOperation * itemOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:itemRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //
        NSString *thumbnailPrefix = [NSString stringWithFormat:@"http://%@/",[JSON valueForKey:@"thumbnail_prefix"]];
        [[NSUserDefaults standardUserDefaults] setObject:thumbnailPrefix forKey:@"thumbnail_prefix"];

        DDLogVerbose(@"getThumbnailsWithBlock JSON received: %@", JSON);
        NSString* type = [JSON valueForKey:@"type"];
        if (![@"error" isEqualToString:type]) {
            if (block) {
                block ([JSON valueForKey:@"items"],thumbnailPrefix, nil);
            }
        } else {
            if (block) {
                NSError *error = [[NSError alloc] initWithDomain:@"wingedstone.com" code:403 userInfo:nil];
                block (nil, nil, error);
            }
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //
        DDLogVerbose(@"getThumbnailsWithBlock failed: %@", error);
        if (block) {
            block(nil, nil, error);
        }
    }];
    
    [[AppNetworkAPIClient sharedClient] enqueueHTTPRequestOperation:itemOperation];
}


// upload devicetoken
- (void)postDeviceToken{
    
    NSString* csrfToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"csrfmiddlewaretoken"];
    NSString* dToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];

    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     csrfToken, @"csrfmiddlewaretoken",
                                     dToken, @"dt",
                                     nil];
    
    [[AppNetworkAPIClient sharedClient]postPath:POST_DEVICE_PATH parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"device successfully uploaded");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) { 
        DDLogInfo(@"device failed uploaded");
    }];

}

// feedback
- (void)postFeedbackEmail:(NSString *)email andPhone:(NSString *)phone andContent:(NSString *)content withBlock:(void(^)(id, NSError *))block
{
    NSString* csrfToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"csrfmiddlewaretoken"];
    
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     csrfToken, @"csrfmiddlewaretoken",
                                     email, @"email",
                                     phone, @"phone",
                                     content, @"content",
                                     nil];
    DDLogInfo(@"%@",postDict);
    
    [[AppNetworkAPIClient sharedClient] postPath:POST_FEEDBACK_PATH parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"upload feedback received response: %@", responseObject);
        NSString* status = [responseObject valueForKey:@"status"];
        if ([status isEqualToString:@"success"]) {
            if (block ) {
                block(responseObject, nil);
            }
        }
        else {
            if (block) {
                NSError *error = [[NSError alloc] initWithDomain:@"wingedstone.com" code:403 userInfo:nil];
                block (nil, error);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"upload rating failed: %@", error);
        if (block) {
            block(nil, error);
        }
    }];
}


#pragma mark - common post path
- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

@end
