//
//  CuteData.m
//  jiemo
//
//  Created by Xiaosi Li on 12/11/12.
//  Copyright (c) 2012 oyeah. All rights reserved.
//

#import "CuteData.h"
#import "NSObject+SBJson.h"
#import "AppNetworkAPIClient.h"
#import "PageViewLogger.h"
#import "NSData+Godzippa.h"
#import <CommonCrypto/CommonCryptor.h>
#import "DDLog.h"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif
NSString* XFoxAgentVersion = @"0.1";

@interface XFox () <UINavigationControllerDelegate, UITabBarControllerDelegate>
{
    NSString* _appVersion;
}

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *currentSessionKey;
@property (nonatomic, strong) NSMutableDictionary *timedEventDict;
@property (nonatomic, strong) NSMutableArray *currentSessionLogs;
@property (nonatomic, strong) NSMutableDictionary *dataOfSessions;
@property (nonatomic, strong) NSMutableArray *delegateArray;
@property (nonatomic) NSTimeInterval currentSessionStartDateInTimeInterval;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSString *guid;
@end

@implementation XFox

@synthesize apiKey;
@synthesize currentSessionKey;
@synthesize timedEventDict;
@synthesize currentSessionLogs;
@synthesize dataOfSessions;
@synthesize delegateArray;
@synthesize currentSessionStartDateInTimeInterval;
@synthesize dateFormatter;
@synthesize guid;

- (id)init
{
    self = [super init];
    if (self) {
        self.currentSessionKey = nil;
        self.apiKey = nil;
        self.timedEventDict = [NSMutableDictionary dictionaryWithCapacity:100];
        self.dataOfSessions = [NSMutableDictionary dictionaryWithCapacity:10];
        self.currentSessionLogs = [NSMutableArray arrayWithCapacity:100];
        self.delegateArray = [NSMutableArray arrayWithCapacity:10];
        self.currentSessionStartDateInTimeInterval = 0;
        _appVersion = nil;
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss:SSS"];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        // monitor for network status change
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appStatusChangeReceived:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    NotificationsUnobserve();
}

+ (XFox *)sInstance {
    static XFox *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[XFox alloc] init];
    });
    
    return _sharedClient;
}


+ (void)setAppVersion:(NSString *)version
{
    [self sInstance]->_appVersion = version;
}

+ (void)setGUID:(NSString *)guid;
{
    [self sInstance].guid = guid;
}

+ (NSString *)getXFoxAgentVersion
{
    return XFoxAgentVersion;
}

+ (void)startSession:(NSString *)apiKey
{
    XFox *fox = [self sInstance];
    
    fox.apiKey = apiKey;
    if (fox.currentSessionKey != nil) {
        [fox.dataOfSessions setValue:fox.currentSessionLogs forKey:fox.currentSessionKey];
    }
    
    fox.currentSessionKey = [self createSessionKey:apiKey];
    fox.currentSessionLogs = [NSMutableArray arrayWithCapacity:20];
    [fox.timedEventDict removeAllObjects];
    fox.currentSessionStartDateInTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    
}

+ (void)logEvent:(NSString *)eventName
{
    [XFox logEvent:eventName withParameters:nil timed:NO];
}

+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters
{
     [XFox logEvent:eventName withParameters:parameters timed:NO];
}

+ (void)logError:(NSString *)errorID message:(NSString *)message error:(NSError *)error
{
    NSString *errorString = [NSString stringWithFormat:@"%@ - error:%@ message:%@ NSERROR:%@", [NSDate date], errorID, message, error];
    XFox *fox = [self sInstance];
    
    [fox.currentSessionLogs addObject:errorString];
}

+ (void)logError:(NSString *)errorID message:(NSString *)message exception:(NSException *)exception
{
    NSString *errorString = [NSString stringWithFormat:@"%@ - error:%@ message:%@ NSException:%@", [NSDate date], errorID, message, exception];
    XFox *fox = [self sInstance];
    
    [fox.currentSessionLogs addObject:errorString];
}

+ (void)logEvent:(NSString *)eventName timed:(BOOL)timed
{
    XFox *fox = [self sInstance];
    if (timed) {
        NSDate *startTime = [NSDate date];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:startTime forKey:@"___START_TIME___"] ;
        [fox.timedEventDict setValue:dict forKey:eventName];
    } else {
        [self logEvent:eventName];
    }
}

+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters timed:(BOOL)timed
{
    XFox *fox = [self sInstance];
    if (timed) {
        NSDate *startTime = [NSDate date];
        NSMutableDictionary *dictm = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [dictm setValue:startTime forKey:@"___START_TIME___"] ;
        [fox.timedEventDict setValue:dictm forKey:eventName];
    } else {
        XFox *fox = [self sInstance];
        
        [fox.currentSessionLogs addObject:[self createLogEntryWithEventName:eventName parameters:parameters andTimeDuration:0]];
    }
}
                              
+ (void)endTimedEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters
{
    XFox *fox = [self sInstance];
    NSDictionary *value  = (NSDictionary *)[fox.timedEventDict valueForKey:eventName];
    NSMutableDictionary *startParams = [NSMutableDictionary dictionaryWithDictionary:value];
    if (startParams) {
        NSDate *endDate = [NSDate date];
        NSDate *startDate = [startParams valueForKey:@"___START_TIME___"];
        NSTimeInterval duration = [endDate timeIntervalSinceDate:startDate];
        [startParams removeObjectForKey:@"___START_TIME___"];
        
        [startParams addEntriesFromDictionary:parameters];
        
        [fox.currentSessionLogs addObject:[self createLogEntryWithEventName:eventName parameters:startParams andTimeDuration:duration]];
        
        [fox.timedEventDict setValue:nil forKey:eventName];
    }
}

+ (void)logAllPageViews:(id)target
{
    XFox *fox = [XFox sInstance];
    
    if ([target isKindOfClass:[UINavigationController class]]) {
        UINavigationController *controller = (UINavigationController *)target;
        PageViewLogger *logger = [[PageViewLogger alloc] initWithNavDelegate:controller.delegate];
        controller.delegate = logger;
        [fox.delegateArray addObject:logger];
    } else if ([target isKindOfClass:[UITabBarController class]]) {
        UITabBarController *controller = (UITabBarController *)target;
        PageViewLogger *logger = [[PageViewLogger alloc] initWithTabDelegate:controller.delegate];
        controller.delegate = logger;
        [fox.delegateArray addObject:logger];
    }
}

+ (NSString *)createLogEntryWithEventName:(NSString *)eventName parameters:(NSDictionary *)parameters andTimeDuration:(double)seconds
{
    XFox *fox = [XFox sInstance];
    NSDictionary *xfoxDict = [[NSDictionary alloc]init];
    NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate] - fox.currentSessionStartDateInTimeInterval;

    if (parameters != nil && [parameters count] > 0) {
        if (seconds > 0) {
            xfoxDict = [[NSDictionary alloc]initWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%.2f", interval],@"offset",
                        eventName, @"action",
                        [parameters JSONRepresentation],@"p",
                        [NSString stringWithFormat:@"%f",seconds], @"dur",
                        nil];
        } else {
            xfoxDict = [[NSDictionary alloc]initWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%.2f", interval],@"offset",
                        eventName, @"action",
                        [parameters JSONRepresentation],@"p",
                        nil];
            
        }
    } else {
        if (seconds > 0) {
            xfoxDict = [[NSDictionary alloc]initWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%.2f", interval],@"offset",
                        eventName, @"action",
                        [NSString stringWithFormat:@"%f",seconds], @"dur",
                        nil];
        } else {
            xfoxDict = [[NSDictionary alloc]initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%.2f", interval],@"offset",
                                        eventName, @"action",
                                        nil];
        }
    }
    
    return [xfoxDict JSONRepresentation];    
    
}

+ (NSString *)createSessionKey:(NSString *)namespace
{
    return [NSString stringWithFormat:@"%@%lu", namespace, random()];
}

- (void)clearLogs
{
    [self.currentSessionLogs removeAllObjects];
}

- (NSData *)AES256EncryptData:(NSData *)data WithKey:(NSString *)key   //加密
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

#define AESKEY @"j1Nx!@0J[ux]nGh*cHuyaNg{1uAnx^Cy"

- (void)appStatusChangeReceived:(NSNotification *)notification
{
    // enter background - save log information
    // create the file
    
    XFox *fox = [XFox sInstance];
    
    
    // sbjson write
    
    NSMutableString *itemsMutableString = [[NSMutableString alloc]init];
    [fox.currentSessionLogs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [itemsMutableString appendFormat:@"%@,", obj];
    }];
    
    NSString *firstString = [itemsMutableString substringToIndex:[itemsMutableString length] - 1];
    // add [string]
    NSString *secondString = [NSString stringWithFormat:@"[%@]}",firstString];
    // replace "p":"{}"
    NSString *thirdString = [secondString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    NSString *fourString = [thirdString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    NSString *itemsString = [fourString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    
    NSDictionary *logDict = [[NSDictionary alloc]initWithObjectsAndKeys:
                                [XFox getXFoxAgentVersion],@"XFoxVer",
                                fox.apiKey,@"appKey",
                                fox->_appVersion,@"appVer",
                                fox.currentSessionKey,@"session",
                                [fox.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:fox.currentSessionStartDateInTimeInterval]],@"startTime",
                                fox.guid, @"guid",
                                @"REPLACECODE",@"items",
                            nil];
    NSString *logDictString = [logDict JSONRepresentation];
    
    NSString *log = [logDictString stringByReplacingOccurrencesOfString:@"\"REPLACECODE\"}" withString:itemsString];
    
//    NSMutableString *log = [NSMutableString stringWithFormat:@"XFoxVer:%@, appKey:%@, appVer:%@ session:%@ startTime:%@\n",
//                            [XFox getXFoxAgentVersion],
//                            fox.apiKey,
//                            fox->_appVersion,
//                            fox.currentSessionKey,
//                            [fox.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:fox.currentSessionStartDateInTimeInterval]]];
    
    
    NSData *logData = [log dataUsingEncoding:NSUTF8StringEncoding];
    NSData *zippedData = [logData dataByGZipCompressingWithError:nil];
    NSData *encryptedData = [self AES256EncryptData:zippedData WithKey:AESKEY];
    
    [[AppNetworkAPIClient sharedClient] uploadLog:encryptedData withBlock:^(id responseObject, NSError *error) {
//        if (responseObject) {
            DDLogVerbose(@"%@",responseObject);
            [fox clearLogs];
//        }
    }];
}

@end
