//
//  ModelHelper.h
//  childDraw
//
//  Created by meng qian on 13-4-1.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Zipfile;

@interface ModelHelper : NSObject
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
+ (ModelHelper *)sharedInstance;

- (Zipfile *)findZipfileWithFileName:(NSString *)fileName;
- (void)populateZipfile:(Zipfile *)zipfile withServerJSONData:(id)json;

@end
