//
//  ListViewController.h
//  childDraw
//
//  Created by meng qian on 13-4-3.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBCustomBackButtonViewController.h"
@interface ListViewController : BBCustomBackButtonViewController

@property(strong, nonatomic)NSManagedObjectContext *managedObjectContext;

@end
