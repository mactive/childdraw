//
//  SlideListViewController.h
//  childDraw
//
//  Created by meng qian on 13-5-6.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCPagedScrollView.h"
@interface SlideListViewController : UIViewController

@property(nonatomic, strong) MCPagedScrollView* scrollView;
@property(strong, nonatomic)NSManagedObjectContext *managedObjectContext;

@end
