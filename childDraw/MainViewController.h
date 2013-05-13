//
//  MainViewController.h
//  childDraw
//
//  Created by meng qian on 13-3-22.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Zipfile.h"

@interface MainViewController : UIViewController

@property(strong, nonatomic)NSString *planetString;
@property(strong, nonatomic)NSString *titleString;


@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)downloadLastPlanet:(NSNumber *)value andTitle:(NSString *)title;
- (void)downloadFinish;

- (void)enterFirst:(BOOL)first orLast:(BOOL)last;
- (void)backAction;

// set open and close
- (void)mainViewOpen;
- (void)mainViewClose;


@end
