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
#import "PassValueDelegate.h"
#import "ShareWithPhotoView.h"

@interface AlbumViewController : BBCustomBackButtonViewController<PassValueDelegate>

@property (nonatomic, readonly) GCPagedScrollView* scrollView;
@property (nonatomic, strong) NSArray *albumArray;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, readwrite) NSUInteger albumIndex;
@property (nonatomic, strong) ShareWithPhotoView *shareView;
@property (nonatomic, strong) NSString *keyString;



- (void)refreshSubView;

- (void)jumpToFirst:(BOOL)first orLast:(BOOL)last;
- (void)backToMainView;

@end
