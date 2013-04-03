//
//  ModelDownload.h
//  childDraw
//
//  Created by meng qian on 13-4-3.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PassValueDelegate.h"
@class Zipfile;

@interface ModelDownload : NSObject
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(strong, nonatomic)NSString *filename;
@property(strong, nonatomic)NSString *lastPlanet;

@property(nonatomic,assign) NSObject<PassValueDelegate> *delegate;


+ (ModelDownload *)sharedInstance;

-(void)downloadWithURL:(NSDictionary *)obj;
@end
