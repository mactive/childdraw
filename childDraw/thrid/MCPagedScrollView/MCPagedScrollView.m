//
//  MCPagedScrollView.m
//  GCLibrary
//
//  Created by Guillaume Campagna on 10-11-10.
//  Copyright (c) 2010 LittleKiwi. All rights reserved.
//

#import "MCPagedScrollView.h"
#import <QuartzCore/CATransaction.h>
#import "StyledPageControl.h"

NSString * const MCPagedScrollViewContentOffsetKey = @"contentOffset";
const CGFloat MCPagedScrollViewPageControlHeight = 36.0;

@interface MCPagedScrollView ()

@property (nonatomic, readonly) NSMutableArray* views;
//@property (nonatomic, readonly) UIPageControl* pageControl;
@property (nonatomic, strong) StyledPageControl *pageControl;


- (void) updateViewPositionAndPageControl;
- (void) changePage:(UIPageControl*) aPageControl;

@end

@implementation MCPagedScrollView

@synthesize views;
@synthesize pageControl;
@synthesize itemWidth;
@synthesize itemOffset;
#pragma mark -
#pragma mark Subclass



- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
//        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.scrollsToTop = NO;
        
        NSLog(@"%f %f %f %f",frame.origin.x, frame.origin.y,frame.size.width,frame.size.height);
        
        StyledPageControl *aPageControl = [[StyledPageControl alloc]initWithFrame:CGRectZero];
        [aPageControl setFrame:CGRectMake(20,(self.frame.size.height-20)/2,self.frame.size.width-40,20)];
        [aPageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        [aPageControl setPageControlStyle:PageControlStyleWithPageNumber];
        [aPageControl setUserInteractionEnabled:NO];
//        [self addSubview:aPageControl];

        self.pageControl = aPageControl;
        
    }
    return self;
}


#pragma mark -
#pragma mark Add/Remove content

- (void) addContentSubview:(UIView *)view {
    [self addContentSubview:view atIndex:[self.views count]];
}

- (void) addContentSubview:(UIView *)view atIndex:(NSUInteger)index {
    [self insertSubview:view atIndex:index];
    [self.views insertObject:view atIndex:index];
    [self updateViewPositionAndPageControl];
//    self.contentOffset = CGPointMake(0, - self.scrollIndicatorInsets.top);
}

- (void)addContentSubviewsFromArray:(NSArray *)contentViews {
    for (UIView* contentView in contentViews) {
        [self addContentSubview:contentView];
    }
}

- (void) removeContentSubview:(UIView *)view {
    [view removeFromSuperview];
    
    [self.views removeObject:view];
    [self updateViewPositionAndPageControl];
}

- (void)removeContentSubviewAtIndex:(NSUInteger)index {
    [self removeContentSubview:[self.views objectAtIndex:index]];
}

- (void) removeAllContentSubviews {
    for (UIView* view in self.views) {
        [view removeFromSuperview];
    }
    
    [self.views removeAllObjects];
    [self updateViewPositionAndPageControl];
}

#pragma mark -
#pragma mark Layout

- (void) updateViewPositionAndPageControl {
    // default a
    CGFloat A = (self.frame.size.width - itemWidth) /2;

    [self.views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView* view = (UIView*) obj;
        
        CGFloat X = A + idx * itemWidth + itemWidth / 2 + itemOffset *idx;
        view.center = CGPointMake( X, BG_HEIGHT / 2);
        
    }];
    
    UIEdgeInsets inset = self.scrollIndicatorInsets;
    CGFloat heightInset = inset.top + inset.bottom;
    self.contentSize = CGSizeMake(A*2 + (itemWidth + itemOffset) * [self.views count] - itemOffset,
                                  self.frame.size.height - heightInset);
//    NSLog(@"ContentSize: %.0f %.0f",self.contentSize.width,self.contentSize.height);
    self.pageControl.numberOfPages = self.views.count;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    //Avoid that the pageControl move
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    CGRect frame = self.pageControl.frame;
    frame.origin.x = self.contentOffset.x;
    frame.origin.y = self.frame.size.height - MCPagedScrollViewPageControlHeight - self.scrollIndicatorInsets.bottom - self.scrollIndicatorInsets.top;
    frame.size.width = self.frame.size.width;
    self.pageControl.frame = frame;
    
    [CATransaction commit];
}

#pragma mark -
#pragma mark Getters/Setters

//- (void) setFrame:(CGRect) newFrame {
//    [super setFrame:newFrame];
//    [self updateViewPositionAndPageControl];
//}

- (void) changePage:(UIPageControl*) aPageControl {
    [self setPage:aPageControl.currentPage animated:YES];
}

- (void) setContentOffset:(CGPoint) new {
    new.y = -self.scrollIndicatorInsets.top;
    [super setContentOffset:new];
    
    self.pageControl.currentPage = self.page; //Update the page number
}

- (NSMutableArray*) views {
    if (views == nil) {
        views = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return views;
}

- (NSUInteger) page {
    return floor(self.contentOffset.x / (itemOffset+itemWidth));
}

- (void) setPage:(NSUInteger)page {
    [self setPage:page animated:NO];
}

- (void) setPage:(NSUInteger)page animated:(BOOL) animated {
    CGFloat tt = itemWidth + itemOffset;
//    NSLog(@"%.0f",tt *page);
    [self setContentOffset:CGPointMake(page * tt, - self.scrollIndicatorInsets.top) animated:animated];
}

#pragma mark -
#pragma mark Dealloc



@end
