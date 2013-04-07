//
//  GCPagedScrollViewDemoViewController.h
//  GCPagedScrollViewDemo
//
//  Created by Guillaume Campagna on 11-04-30.
//  Copyright 2011 LittleKiwi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCPagedScrollView.h"
#import "BBCustomBackButtonViewController.h"

@interface AlbumViewController : BBCustomBackButtonViewController

@property (nonatomic, readonly) GCPagedScrollView* scrollView;
@property (nonatomic, strong) NSArray *albumArray;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, readwrite) NSUInteger albumIndex;


- (void)refreshSubView;

@end
