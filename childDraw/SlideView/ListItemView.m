//
//  ListItemView.m
//  childDraw
//
//  Created by meng qian on 13-5-7.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "ListItemView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"

@interface ListItemView()
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UIImageView *bgView;
@end


@implementation ListItemView
@synthesize imageView;
@synthesize bgView;

#define ITEM_WIDTH  225.0f

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.bgView = [[UIImageView alloc]initWithFrame:frame];
//        NSLog(@"%f %f %f %f",frame.origin.x, frame.origin.y,frame.size.width,frame.size.height);
        [self.bgView setImage:[UIImage imageNamed:@"item_bg.png"]];
        
        self.imageView = [[UIImageView alloc]initWithFrame:
                          CGRectMake((frame.size.width - ITEM_WIDTH)/2, (frame.size.height-ITEM_WIDTH)/2, ITEM_WIDTH, ITEM_WIDTH)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;

        [self addSubview:self.bgView];
        [self addSubview:self.imageView];
    }
    return self;
}


- (void)setAvatar:(NSString *)filename
{
    NSString *prefix = [[NSUserDefaults standardUserDefaults] objectForKey:@"thumbnail_prefix"];
    NSString *url = [NSString stringWithFormat:@"%@%@.png",prefix,filename];
    NSLog(@"URL %@",url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.imageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       [self.imageView setImage:image];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       [self.imageView setImage:[UIImage imageNamed:@"default_item.png"]];
                                   }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    //
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
