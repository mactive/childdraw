//
//  MCPagedScrollView.h
//  GCLibrary
//
//  Created by Guillaume Campagna on 10-11-10.
//  Copyright (c) 2010 LittleKiwi. All rights reserved.
//

#import <UIKit/UIKit.h>
//Simple UIScrollView subclass that automatically handle UIPageControl and paged content
@interface MCPagedScrollView : UIScrollView

@property (nonatomic, assign) NSUInteger page; //Zero based number of page
@property (nonatomic, assign) CGFloat itemWidth; //content
@property (nonatomic, assign) CGFloat itemOffset; //content offset

- (void) setPage:(NSUInteger)page animated:(BOOL) animated;

//Add or remove content view from the scrollview
- (void) addContentSubview:(UIView*) view;
- (void) addContentSubview:(UIView*) view atIndex:(NSUInteger) index;
- (void) addContentSubviewsFromArray:(NSArray*) contentViews;

- (void) removeContentSubview:(UIView*) view;
- (void) removeContentSubviewAtIndex:(NSUInteger) index;
- (void) removeAllContentSubviews;

@end
