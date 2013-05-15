//
//  ModelHelper.m
//  childDraw
//
//  Created by meng qian on 13-4-1.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "ModelHelper.h"
#import "Zipfile.h"
//#import "DDLog.h"
#import "AFImageRequestOperation.h"
#import "AppNetworkAPIClient.h"
#import "ServerDataTransformer.h"
// Log levels: off, error, warn, info, verbose
//#if DEBUG
//static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//#else
//static const int ddLogLevel = LOG_LEVEL_ERROR;
//#endif

@interface ModelHelper(){
    
}



@end

@implementation ModelHelper

@synthesize managedObjectContext;

+ (ModelHelper *)sharedInstance {
    static ModelHelper *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ModelHelper alloc] init];
    });
    
    return _sharedClient;
}

- (Zipfile *)findZipfileWithFileName:(NSString *)fileName
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Zipfile" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(fileName = %@)", fileName];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    if ([array count] == 0)
    {
//        DDLogError(@"Zipfile doesn't exist: %@", error);
        return nil;
    } else {
        if ([array count] > 1) {
//            DDLogError(@"More than one user object with same Zipfile name: %@", fileName);
        }
        return [array objectAtIndex:0];
    }
    
}

- (void)populateZipfile:(Zipfile *)zipfile withServerJSONData:(id)json
{
    zipfile.fileName        = [ServerDataTransformer getStringObjFromServerJSON:json byName:@"key"];
    zipfile.downloadTime    = [NSDate date];
    zipfile.isDownload      = [NSNumber numberWithBool:NO];
    zipfile.isZiped         = [NSNumber numberWithBool:NO];
    zipfile.picCount        = @"0";
    zipfile.aniCount        = @"8";
    zipfile.title           = [ServerDataTransformer getStringObjFromServerJSON:json byName:@"title"];
}

- (void)clearAllObjects
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    
    NSArray *dbArray = [[NSArray alloc]initWithObjects:
                        @"Zipfile",
                        nil];
    
    // Common
    NSEntityDescription *entityDescription = [[NSEntityDescription alloc]init];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSError *error = [[NSError alloc]init];
    NSArray *array = [[NSArray alloc] init];
    
    for (int i = 0; i< [dbArray count]; i++) {
        
        entityDescription = [NSEntityDescription entityForName:[dbArray objectAtIndex:i]
                                        inManagedObjectContext:moc];
        [request setEntity:entityDescription];
        array = [moc executeFetchRequest:request error:&error];
        
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [moc deleteObject:obj];
        }];
    }
    MOCSave(self.managedObjectContext);
    
}


@end
