//
//  AppNetworkAPIClient.m
//  childDraw
//
//  Created by meng qian on 13-3-29.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "AppNetworkAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "UpYun.h"

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

static NSString * const kAppDataLogServerURLString  = @"http://218.61.10.155:9015/";
//static NSString * const kAppDataLogServerURLString  = @"http://192.168.1.104:9015/";

@interface AppNetworkAPIClient ()<UpYunDelegate>
{
    NSLock *_imageQueueLock;
    NSLock *_queuedOperationLock;
    NSLock *_upYunLock;
}

@property (nonatomic, strong) NSMutableDictionary *upYunRequests;
- (void)networkChangeReceived:(NSNotification *)notification;
- (void)upYun:(UpYun *)upYun requestDidFailWithError:(NSError *)error;
- (void)upYun:(UpYun *)upYun requestDidSucceedWithResult:(id)result;
@end

@implementation AppNetworkAPIClient
@synthesize kNetworkStatus;
@synthesize upYunRequests;

+ (AppNetworkAPIClient *)sharedClient {
    static AppNetworkAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AppNetworkAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAppNetworkAPIBaseURLString]];
        [_sharedClient setDefaultHeader:@"Accept-Language" value:nil];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    _upYunLock = [[NSLock alloc] init];
    _imageQueueLock = [[NSLock alloc] init];
    _queuedOperationLock = [[NSLock alloc] init];
    
    self.upYunRequests = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChangeReceived:)
                                                 name:AFNetworkingReachabilityDidChangeNotification object:nil];

    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}


- (void)storeMessageImage:(UIImage *)image thumbnail:(UIImage *)thumbnail withBlock:(void (^)(id responseObject, NSError *error))block
{
    
    UpYun *uy = [[UpYun alloc] init];
    uy.delegate = self;
    uy.expiresIn = 100;
    uy.bucket = @"babydrawuser";
    uy.passcode = @"wgZAU957S5qJYfTM7seKHWnTl6E=";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setObject:@"0,1000" forKey:@"content-length-range"];
//    [params setObject:@"png" forKey:@"allow-file-type"];
    uy.params = params;
    
    NSString *saveKey = nil;
    //[XFox sInstance].guid
    
    NSString *prefix = [[XFox sInstance].guid stringByReplacingOccurrencesOfString:@":" withString:@"_"];

    saveKey = [NSString stringWithFormat:@"/%@_%.0f.jpg",prefix, [[NSDate date] timeIntervalSince1970]];
    
    uy.name = saveKey;
    
    [uy uploadImageData:UIImageJPEGRepresentation(image, JPEG_QUALITY) savekey:saveKey];
    
    NSString *from = @"message";
    
    //void (^handlerCopy)(id, NSError *) ;
    //handlerCopy = Block_copy(block);
    NSDictionary* results = [NSDictionary dictionaryWithObjectsAndKeys:image, @"image", thumbnail, @"thumbnail", saveKey, @"pathname", [block copy], @"block", from, @"from", nil];
    //Block_release(handlerCopy); // dict will -retain/-release, this balances the copy.
    
    [_upYunLock lock];
    [self.upYunRequests setObject:results forKey:uy.name];
    [_upYunLock unlock];
    
    return;
    
}

- (void)upYun:(UpYun *)upYun requestDidFailWithError:(NSError *)error
{
    DDLogError(@"upload image failed: %@", error);
    
    [_upYunLock lock];
    NSDictionary *savedObjects = [self.upYunRequests objectForKey:upYun.name];
    [_upYunLock unlock];
    
    void (^block)(id, NSError *) ;
    block = [savedObjects objectForKey:@"block"];
    if (block) {
        block(nil, error);
    }
}

- (void)upYun:(UpYun *)upYun requestDidSucceedWithResult:(id)result
{
    DDLogInfo(@"upload image succeeded: %@", result);
    
    [_upYunLock lock];
    NSDictionary *savedObjects = [self.upYunRequests objectForKey:upYun.name];
    [_upYunLock unlock];
    
    NSString *from = [savedObjects objectForKey:@"from"];
    
    if ([from isEqualToString:@"message"]) {
        
        void (^block)(id, NSError *) ;
        block = [savedObjects objectForKey:@"block"];
        
        UIImage *image = [savedObjects objectForKey:@"image"];
        UIImage *thumbnail = [savedObjects objectForKey:@"thumbnail"];
        
        NSString *url = [NSString stringWithFormat:@"http://babydrawuser.b0.upaiyun.com%@", upYun.name];
        NSString *thumbnailURL = [NSString stringWithFormat:@"http://babydrawuser.b0.upaiyun.com%@!tm", upYun.name];
        //upyun 自定义版本名称 tm 间隔表示符 !tm
        
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc]initWithDictionary:result];
        [resultDict setObject:thumbnail forKey:@"thumbnail"];
        [resultDict setObject:url forKey:@"url"];
        [resultDict setObject:thumbnailURL forKey:@"thumbnailURL"];
        
        if (block) {
            block(resultDict, nil);
        }
        
    }

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
        if (block) {
            block(JSON, nil);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //
        DDLogVerbose(@"get config failed: %@", error);
        if (block) {
            block(nil, error);
        }
    }];
    
    [[AppNetworkAPIClient sharedClient] enqueueHTTPRequestOperation:loginOperation];
}

// get notification
- (void)getNotificationWithBlock:(void(^)(id, NSError *))block{
    
    NSMutableURLRequest *request = [[AppNetworkAPIClient sharedClient] requestWithMethod:@"GET" path:GET_NOTICE_PATH parameters:nil];
    AFJSONRequestOperation * loginOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //
        DDLogVerbose(@"get notification JSON received: %@", JSON);
        
        NSString *notificationString = [JSON objectForKey:@"notification"];
        if (!StringHasValue(notificationString)) {
            notificationString = DEFAULT_NOTIFICATION;
        }
        if (block) {
            block(notificationString, nil);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //
        DDLogVerbose(@"get notification failed: %@", error);
        if (block) {
            block(nil, error);
        }
    }];
    
    [[AppNetworkAPIClient sharedClient] enqueueHTTPRequestOperation:loginOperation];
}



// getItemsCount
- (void)getItemsCount:(NSInteger)count withBlock:(void(^)(id, NSString *, NSError *))block
{
    NSString *pathString = [NSString stringWithFormat:@"%@%d/",GET_ITEMS_PATH, count];
    NSMutableURLRequest *itemRequest = [[AppNetworkAPIClient sharedClient] requestWithMethod:@"GET" path:pathString parameters:nil];
//    [itemRequest setTimeoutInterval:2.0];
    
    AFJSONRequestOperation * itemOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:itemRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //
        DDLogVerbose(@"get getItemsCount JSON received: %@", JSON);
        
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
    
//    [[AppNetworkAPIClient sharedClient] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        //
//        DDLogVerbose(@"status:%d",status);
//        if (status == 0) {
//            NSError *error = [[NSError alloc]initWithDomain:@"http://c.wingedstone.com" code:status userInfo:nil];
//            block(nil, nil, error);
//        }
//    }];
    
}

// getItemsThumbnail
- (void)getThumbnailsStartPosition:(NSUInteger)startPosition withBlock:(void(^)(id, NSString *, NSError *))block
{
    NSString *pathString = [NSString stringWithFormat:@"%@%d/",GET_THUMBNAIL_PATH,startPosition];
    NSMutableURLRequest *itemRequest = [[AppNetworkAPIClient sharedClient] requestWithMethod:@"GET" path:pathString parameters:nil];
    [itemRequest setTimeoutInterval:2.0];

    AFJSONRequestOperation * itemOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:itemRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //
        NSString *thumbnailPrefix = [NSString stringWithFormat:@"http://%@/",[JSON valueForKey:@"thumbnail_prefix"]];
        [[NSUserDefaults standardUserDefaults] setObject:thumbnailPrefix forKey:@"thumbnail_prefix"];

//        DDLogVerbose(@"getThumbnailsWithBlock JSON received: %@", JSON);
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
    
//    [[AppNetworkAPIClient sharedClient] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        //
//        DDLogVerbose(@"status:%d",status);
//        if (status == 0) {
//            NSError *error = [[NSError alloc]initWithDomain:@"http://c.wingedstone.com" code:status userInfo:nil];
//            block(nil, nil, error);
//        }
//    }];
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
        DDLogVerbose(@"%@",responseObject);
        DDLogInfo(@"device successfully uploaded");
#warning 3天 after
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@",error);
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

- (void)postToWeibo:(NSDictionary *)postData andURL:(NSString *)url withBlock:(void(^)(id, NSError *))block
{
    AppNetworkAPIClient *dataLogClient = [[AppNetworkAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAppDataLogServerURLString]];
    [dataLogClient setDefaultHeader:@"Content-Type" value:@"multipart/form-data"];

    
    NSMutableURLRequest *postRequest = [dataLogClient multipartFormRequestWithMethod:@"POST" path:url parameters:postData constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //
        NSData* imageData = UIImagePNGRepresentation((UIImage*)[postData objectForKey:@"pic"]);
        [formData appendPartWithFileData:imageData name:@"pic" fileName:@"try.png" mimeType:@"image/png"];
    }];

    
    AFHTTPRequestOperation *operation = [dataLogClient HTTPRequestOperationWithRequest:postRequest success:nil failure:nil];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block) {
            block(responseObject, nil);

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            DDLogError(@"%@",error);
            block(nil, error);
        }
    }];
    
    [dataLogClient enqueueHTTPRequestOperation:operation];

}

- (void)followWeibo:(NSDictionary *)postData andURL:(NSString *)url withBlock:(void(^)(id, NSError *))block
{
    
    [[AppNetworkAPIClient sharedClient] postPath:url parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"follow success: %@", responseObject);
        if (block ) {
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"follow failed: %@", error);
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

- (void)uploadLog:(NSData *)log withBlock:(void (^)(id, NSError *))block
{
    AppNetworkAPIClient *dataLogClient = [[AppNetworkAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAppDataLogServerURLString]];
    [dataLogClient setDefaultHeader:@"Accept-Language" value:nil];
    
    
    NSString* csrfToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"csrfmiddlewaretoken"];
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys: csrfToken, @"csrfmiddlewaretoken", nil];

    NSMutableURLRequest *postRequest = [dataLogClient multipartFormRequestWithMethod:@"POST" path:DATA_SERVER_PATH parameters:paramDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:log name:@"ih" fileName:@"flu.gz" mimeType:@"application/octet-stream"];
    }];
    
    AFHTTPRequestOperation *operation = [dataLogClient HTTPRequestOperationWithRequest:postRequest success:nil failure:nil];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            DDLogError(@"%@",error);
            block(nil, error);
        }
    }];
    
    [dataLogClient enqueueHTTPRequestOperation:operation];
}

- (void)networkChangeReceived:(NSNotification *)notification
{
    self.kNetworkStatus = (NSNumber *)[notification.userInfo valueForKey:AFNetworkingReachabilityNotificationStatusItem];
}

@end
