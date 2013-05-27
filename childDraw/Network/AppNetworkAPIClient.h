//
//  AppNetworkAPIClient.h
//  childDraw
//
//  Created by meng qian on 13-3-29.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "AFHTTPClient.h"


#define GET_CONFIG_PATH         @"/base/getconfig/"
#define GET_ITEMS_PATH          @"/base/queryitems/"
#define GET_THUMBNAIL_PATH      @"/base/querythumbnails/"
#define POST_DEVICE_PATH        @"/base/devicetoken/"
#define POST_FEEDBACK_PATH      @"/base/feedback/"
#define GET_NOTICE_PATH         @"/base/notication/"

#define DATA_SERVER_PATH        @"/data/"

@interface AppNetworkAPIClient : AFHTTPClient

@property (nonatomic) NSNumber * kNetworkStatus;
@property (nonatomic) BOOL isLoggedIn;

+ (AppNetworkAPIClient *)sharedClient;

// get config
- (void)getConfigWithBlock:(void (^)(id, NSError *))block;
// 上传devicetoken
- (void)postDeviceToken;
// post feedback
- (void)postFeedbackEmail:(NSString *)email andPhone:(NSString *)phone andContent:(NSString *)content withBlock:(void(^)(id, NSError *))block;

- (void)postToWeibo:(NSDictionary *)postData andURL:(NSString *)url withBlock:(void(^)(id, NSError *))block;

// get last items with count
- (void)getItemsCount:(NSInteger)count withBlock:(void(^)(id, NSString *, NSError *))block;

// get thumbnails default 20
- (void)getThumbnailsStartPosition:(NSUInteger)startPosition withBlock:(void(^)(id, NSString *, NSError *))block;

// upload log data
- (void)uploadLog:(NSData *)log withBlock:(void (^)(id responseObject, NSError *error))block;

// get notication
- (void)getNoticationWithBlock:(void(^)(id, NSError *))block;


@end
