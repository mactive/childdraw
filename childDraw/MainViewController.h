//
//  MainViewController.h
//  childDraw
//
//  Created by meng qian on 13-3-22.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Zipfile.h"
#import "PassValueDelegate.h"

@interface MainViewController : UIViewController<PassValueDelegate>

@property(strong, nonatomic)NSString *planetString;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)downloadLastPlanet:(NSNumber *)value andTitle:(NSString *)title;
- (void)downloadFinish;
@end
