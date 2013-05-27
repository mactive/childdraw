//
//  WeiboPostViewController.m
//  childDraw
//
//  Created by meng qian on 13-5-27.
//  Copyright (c) 2013年 thinktube. All rights reserved.
//

#import "WeiboPostViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DDLog.h"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif


@interface WeiboPostViewController ()<UITextViewDelegate,WeiboRequestDelegate>
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UITextView *textView;
@property(nonatomic, strong)MBProgressHUD *weiboHUD;
@property(nonatomic, strong)UILabel *restCountLabel;

@end

@implementation WeiboPostViewController
@synthesize textView;
@synthesize imageView;
@synthesize photoImage;
@synthesize weiboHUD;
@synthesize delegate;
@synthesize restCountLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#define TOP_HEIGHT 44.0f
#define SIGNATURE_MAX_LENGTH 140

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	// Do any additional setup after loading the view.
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(110, TOP_HEIGHT+20, TOTAL_WIDTH-120, 140)];
    [self.textView setFont:[UIFont systemFontOfSize:12.0]];
    
    self.textView.keyboardType = UIKeyboardTypeDefault;
    self.textView.returnKeyType = UIReturnKeyGo;
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.textView setContentInset:UIEdgeInsetsMake(10, 0, 10, 0)];
    self.textView.delegate = self;

    self.restCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(275, 180, 30, 20)];
    [self.restCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.restCountLabel setBackgroundColor:RGBCOLOR(213, 213, 213)];
    [self.restCountLabel setFont:[UIFont systemFontOfSize:16.0]];
    self.restCountLabel.textColor = RGBCOLOR(106, 106, 106);
    self.restCountLabel.layer.cornerRadius = 3;
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, TOP_HEIGHT+20,90, 90)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:self.textView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.restCountLabel];
    
    [self.view setBackgroundColor:BGCOLOR];
    [self initTopView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (StringHasValue(self.textString)) {
        self.textView.text = DEFAULT_WEIBO;
    }
    
    self.restCountLabel.text = [NSString stringWithFormat:@"%d",SIGNATURE_MAX_LENGTH - self.textString.length];
    
    [self.textView becomeFirstResponder];
    
    if (self.photoImage) {
        [self.imageView setImage:self.photoImage];
    }
    
    
}

//////////////////////////////////////////////////////////////////////////////////
#pragma mark initTopView
//////////////////////////////////////////////////////////////////////////////////
- (void)initTopView
{
    UIImageView *topView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, TOTAL_WIDTH, TOP_HEIGHT)];
    [topView setImage:[UIImage imageNamed:@"top_bg.png"]];
    [topView setUserInteractionEnabled:YES];
    
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, TOP_HEIGHT)];
    titleLabel.text = T(@"发布微博");
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = GRAYCOLOR;
    titleLabel.font = [UIFont boldSystemFontOfSize:22.0f];
    titleLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    titleLabel.layer.shadowRadius = 1;
    titleLabel.layer.shadowOpacity = 1;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setTitle:T(@"关闭") forState:UIControlStateNormal];
    [closeButton setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    [closeButton setFrame:CGRectMake(10, 7, 51, 29)];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"top_button.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton setTitle:T(@"发布") forState:UIControlStateNormal];
    [postButton setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    [postButton setFrame:CGRectMake(260, 7, 51, 29)];
    [postButton setBackgroundImage:[UIImage imageNamed:@"top_button.png"] forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postNewStatus) forControlEvents:UIControlEventTouchUpInside];
    postButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    
    [topView addSubview:titleLabel];
    [topView addSubview:closeButton];
    [topView addSubview:postButton];
    [self.view addSubview:topView];
}

-(void)closeAction
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString * toBeString = [theTextView.text stringByReplacingCharactersInRange:range withString:text];
    
    if ([self.textView isEqual:theTextView])
    {
            
            NSInteger countInt = (SIGNATURE_MAX_LENGTH > [toBeString length]) ? SIGNATURE_MAX_LENGTH - [toBeString length]: 0;
            self.restCountLabel.text = [NSString stringWithFormat:@"%i",countInt];
            
            if ([toBeString length] > SIGNATURE_MAX_LENGTH) {
                theTextView.text = [toBeString substringToIndex:SIGNATURE_MAX_LENGTH];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:T(@"字数有点多") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }

        
    }
    return YES;
}

- (void)postNewStatus
{
    WeiboRequest *request = [[WeiboRequest alloc] initWithDelegate:self];
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *postPath = self.photoImage ? @"statuses/upload.json" : @"statuses/update.json";
    
    [params setObject:DEFAULT_WEIBO forKey:@"status"];
    if (self.photoImage) {
        [params setObject:self.photoImage forKey:@"pic"];
    }
    [request postToPath:postPath params:params];
    
    self.weiboHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.weiboHUD.removeFromSuperViewOnHide = YES;
    self.weiboHUD.labelText = T(@"正在分享到微博");
    
    [self.textView resignFirstResponder];
    
}

- (void)request:(WeiboRequest *)request didFailWithError:(NSError *)error {
    DDLogVerbose(@"Failed to post: %@", error);
    [self.weiboHUD setHidden:YES];

    
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.removeFromSuperViewOnHide = YES;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = T(@"分享失败");
    HUD.detailsLabelText = T(@"您可以在设置中重新绑定微博");
    [HUD hide:YES afterDelay:2];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2
                                                      target:self
                                                    selector:@selector(closeAction)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [self.delegate finishedPostWithStatus:@"error" error:error];
}

- (void)request:(WeiboRequest *)request didLoad:(id)result
{
    Status *status = [Status statusWithJsonDictionary:result];
    DDLogVerbose(@"status id: %lld", status.statusId);
    [self.weiboHUD setHidden:YES];

    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.removeFromSuperViewOnHide = YES;
    HUD.labelText = T(@"分享成功");
    HUD.mode = MBProgressHUDModeText;
        
    [HUD hide:YES afterDelay:1];
    
    [self.delegate finishedPostWithStatus:@"success" error:nil];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2
                                                      target:self
                                                    selector:@selector(closeAction)
                                                    userInfo:nil
                                                     repeats:NO];
    
    
//    [timer invalidate];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
