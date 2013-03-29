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
#define GET_THUMBNAIL_PATH      @"/base/querythumbnails/startpositon/"
#define POST_DEVICE_PATH        @"/base/deviceToken/"
#define POST_FEEDBACK_PATH        @"/base/feedback/"

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

// get last items with count
- (void)getItemsCount:(NSInteger)count withBlock:(void(^)(id, NSError *))block;

// get thumbnails default 20
- (void)getThumbnailsWithBlock:(void(^)(id, NSError *))block;

@end
