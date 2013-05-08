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
#import "NSDate-Utilities.h"
#import "AppDelegate.h"

@interface ListItemView()
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UIImageView *bgView;
@property(nonatomic, strong)UILabel *timeLabel;
@end


@implementation ListItemView
@synthesize imageView;
@synthesize bgView;
@synthesize timeLabel;

#define ITEM_WIDTH  225.0f
#define TIME_HEIGHT  20.0f
#define TIME_WIDTH  80.0f


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

        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width-TIME_WIDTH, BG_HEIGHT, TIME_WIDTH, TIME_HEIGHT)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.textColor = BLUECOLOR;
        self.timeLabel.font = LITTLECUSTOMFONT;

        [self addSubview:self.bgView];
        [self addSubview:self.imageView];
        [self addSubview:self.timeLabel];

    }
    return self;
}

- (void)setAvatar:(NSString *)filename
{
    NSString *path = [[self appDelegate].THUMBNAILPATH stringByAppendingPathComponent:filename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSLog(@"file exist %@",path);
        [self.imageView setImage:[UIImage imageWithContentsOfFile:path]];
    }else{
        NSLog(@"file not exist %@",path);

    }
    
    [self setTime:filename];
}
/*
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
    [self setTime:filename];
}
*/
- (void)setTime:(NSString *)filename
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(filename.floatValue)];
    self.timeLabel.text = [NSString stringWithFormat:@"%d-%d-%d",date.year,date.month, date.day];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    //
    
}
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
