//
//  Zipfile.h
//  childDraw
//
//  Created by meng qian on 13-4-1.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Zipfile : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSNumber * isDownload;
@property (nonatomic, retain) NSNumber * isZiped;
@property (nonatomic, retain) NSDate * downloadTime;
@property (nonatomic, retain) NSString * picCount;
@property (nonatomic, retain) NSString * aniCount;
@property (nonatomic, retain) NSString * title;

@end
