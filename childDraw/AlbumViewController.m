//
//  GCPagedScrollViewDemoViewController.m
//  GCPagedScrollViewDemo
//
//  Created by Guillaume Campagna on 11-04-30.
//  Copyright 2011 LittleKiwi. All rights reserved.
//

#import "AlbumViewController.h"
#import "UIImage+ProportionalFill.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "WXApi.h"

#import "DDLog.h"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif



@interface AlbumViewController ()<UIScrollViewAccessibilityDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,WXApiDelegate>

- (UIView*) createViewForObj:(id)obj;
@property(strong, nonatomic)UIView *targetView;
@property(strong, nonatomic)NSMutableArray *targetArray;
@property(strong, nonatomic)UIActionSheet *photoActionSheet;
@property(strong, nonatomic)UIActionSheet *shareActionSheet;
@property(nonatomic, strong)UIImagePickerController *pickerController;
@property(nonatomic, strong)UIImage *photoImage;
@property(nonatomic, strong)UISwipeGestureRecognizer *leftSwipe;
@property(nonatomic, strong)GCPagedScrollView *scrollView;
@end

@implementation AlbumViewController
@synthesize albumArray;
@synthesize albumIndex;
@synthesize targetView;
@synthesize targetArray;
@synthesize photoActionSheet,shareActionSheet;
@synthesize titleArray;
@synthesize shareView;
@synthesize pickerController;
@synthesize keyString;
@synthesize photoImage;
@synthesize leftSwipe;
@synthesize scrollView;


#define kCameraSource       UIImagePickerControllerSourceTypeCamera
#define LIST_OFFSET 0

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0, 0, TOTAL_WIDTH, TOTAL_HEIGHT())];

    UIImageView *bgView = [[UIImageView alloc]initWithFrame:self.view.frame];
    if (IS_IPHONE_5) {
        [bgView setImage:[UIImage imageNamed:@"5_bg.png"]];
    }else{
        [bgView setImage:[UIImage imageNamed:@"4s_bg.png"]];
    }
    
    
    UIImageView *backImage = [[UIImageView alloc]initWithFrame:CGRectMake(LIST_OFFSET, LIST_OFFSET/2, 90, 60)];
    [backImage setImage:[UIImage imageNamed:@"button_back.png"]];
    backImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToMainView)];
    [backImage addGestureRecognizer:singleTap];
    
    self.scrollView = [[GCPagedScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
//    self.targetArray = [[NSMutableArray alloc]init];
//    self.targetView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 432)];
    self.scrollView.backgroundColor = [UIColor clearColor];

    self.scrollView.minimumZoomScale = 1.0; //最小到0.3倍
    self.scrollView.maximumZoomScale = 1.0; //最大到3倍
    self.scrollView.clipsToBounds = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    
    [self.view addSubview:bgView];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:backImage];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.scrollView setPage:self.albumIndex];
    
//    self.targetView = [self.targetArray objectAtIndex:self.scrollView.page];
    //DDLogVerbose(@"page %d %@",self.scrollView.page,self.targetView);
    NSUInteger count = [self.albumArray count];
    if (self.shareView != nil) {
        count = count + 1;
    }
    
    self.shareView.delegate = self;
    
    [XFox logEvent:EVENT_READING_TIMER
    withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.keyString,@"key", nil]
             timed:YES];

    [XFox logEvent:EVENT_READING_FINISH_TIMER
    withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.keyString,@"key", nil]
             timed:YES];
    
    [self refreshSubView];

}

// refresh

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.scrollView]) {
        NSUInteger count = [self.albumArray count];
        if (self.scrollView.page == count) {
            [XFox endTimedEvent:EVENT_READING_FINISH_TIMER withParameters:nil];
        }
    }
}




#pragma mark -
#pragma mark Helper methods

- (UIView *)createViewForObj:(id)obj withIndex:(NSInteger)index{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20,
                                                            self.view.frame.size.height - 50)];
    view.backgroundColor = [UIColor clearColor];
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:view.bounds];
    imageView.tag = 1001;
    if ([obj isKindOfClass:[UIImage class]]) {
        imageView.image = obj;
    }
        
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [view addSubview:imageView];
    
    return view;
}

- (void)refreshSubView
{
    [self.scrollView removeAllContentSubviews];
//    self.targetArray = [[NSMutableArray alloc]init];
    
    DDLogVerbose(@"self.albumArray: %@",self.albumArray);
    
    for (NSUInteger index = 0; index < [self.albumArray count]; index ++) {
        //You add your content views here
        id obj = [self.albumArray objectAtIndex:index];
        
        [self.scrollView addContentSubview:[self createViewForObj:obj withIndex:index]];
//        [self.targetArray addObject:[self createViewForObj:obj withIndex:index]];
    }
    
    if (self.shareView != nil) {
        [self.scrollView addContentSubview:self.shareView];
//        [self.targetArray addObject:self.shareView];
    }
    
    
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - share weibo
/////////////////////////////////////////////////////////////////////////////
/*
- (void)ssoButtonPressed
{
    NSString *bind = [[NSUserDefaults standardUserDefaults]objectForKey:@"bind_weibo_success"];
    if ([bind isEqualToString:@"YES"]) {
        //成功绑定过
        [self sendWebContent:self.photoImage];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请在设置页面绑定微博"
                                                       message:@"谢谢"
                                                      delegate:self
                                             cancelButtonTitle:T(@"确定")
                                             otherButtonTitles:nil];
        [alert show];
    }
}


- (void)sendWebContent:(UIImage *)sendImage
{

    WBMessageObject *message = [[WBMessageObject alloc] init];
    WBImageObject *image = [WBImageObject object];
    message.text = @"我拍了张孩子画画的照片 @宝宝来画画";
    
    image.imageData = UIImageJPEGRepresentation(sendImage , JPEG_QUALITY);
//    imageObject.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about_team" ofType:@"png"]];
    
//    WBWebpageObject *pageObject = [WBWebpageObject object];
//    UIImage *sendImage = [photoImage imageByScalingToSize:CGSizeMake(120, 180)];
//    pageObject.objectID = @"identifier1";
//    pageObject.thumbnailData = UIImageJPEGRepresentation(sendImage , JPEG_QUALITY);
//    pageObject.title = @"分享宝宝的画";
//    pageObject.description = @"宝宝来画画,一起够了世界吧";
//    pageObject.webpageUrl = @"http://www.wingedstone.com/childcraw/";
    
//    message.mediaObject = pageObject;
    
    message.imageObject = image;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
    
    
}
*/


- (void)postNewStatus
{
    WeiboRequest *request = [[WeiboRequest alloc] initWithDelegate:self];

    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *postPath = self.photoImage ? @"statuses/upload.json" : @"statuses/update.json";
    [params setObject:@"分享ddd成功" forKey:@"status"];
    if (self.photoImage) {
        [params setObject:self.photoImage forKey:@"pic"];
    }
    [request postToPath:postPath params:params];
    
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - share weichat
/////////////////////////////////////////////////////////////////////////////
- (void) sendWechatImageContent:(UIImage *)image withOption:(NSUInteger)option
{
    if ([WXApi isWXAppInstalled]  && [WXApi isWXAppSupportApi]) {

        WXMediaMessage *message = [WXMediaMessage message];
        
        UIImage *thumbnailImage = [image imageByScalingToSize:CGSizeMake(40, 60)];
        
        [message setThumbImage:thumbnailImage];
        [message setTitle:PRODUCT_NAME];
        [message setDescription:@"和宝宝一起画画的App"];
        
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = UIImageJPEGRepresentation(image, 0.7);;
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        if (option == 3) {
            req.scene = WXSceneTimeline;
        }else if (option == 2){
            req.scene = WXSceneSession;
        }
        
        //选择发送到朋友圈，默认值为WXSceneSession，发送到会话
        
        [WXApi sendReq:req];
    }else{
        self.shareView.noticeLabel.text = T(@"呀,还没有安装微信, 或者版本过低.");
    }
}

//////////////////////////////////////////////////////////////////////
// photo action sheet
//////////////////////////////////////////////////////////////////////

- (void)passStringValue:(NSString *)value andIndex:(NSUInteger)index
{
    if ([value isEqualToString:PHOTOACTION] && index == 1) {
        
        [self takePhotoFromCamera];
        self.albumIndex = [self.albumArray count];
        [XFox logEvent:EVENT_PHOTO];
    }
    
    else if ([value isEqualToString:SHAREWECHAT] || [value isEqualToString:SHAREWECHATFRIEND]) {
        [self sendWechatImageContent:self.photoImage withOption:index];
    }
    
    else if ([value isEqualToString:SHAREWEIBO]) {
        //        self.photoImage = [UIImage imageNamed:@"about_team.png"];
        [self postNewStatus];
    }
    
}


//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIImagePickerControllerDelegateMethods
//////////////////////////////////////////////////////////////////////////////////////////


- (void)takePhotoFromCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:kCameraSource]) {
        UIAlertView *cameraAlert = [[UIAlertView alloc] initWithTitle:T(@"cameraAlert") message:T(@"Camera is not available.") delegate:self cancelButtonTitle:T(@"Cancel") otherButtonTitles:nil, nil];
        [cameraAlert show];
		return;
	}
    
    self.pickerController = [[UIImagePickerController alloc] init];
    self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	self.pickerController.delegate = self;
	self.pickerController.allowsEditing = NO;
    
    [self presentModalViewController:self.pickerController animated:YES];
}

// UIImagePickerControllerSourceTypeCamera and UIImagePickerControllerSourceTypePhotoLibrary

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
	UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *screenImage = [originalImage imageByScalingToSize:CGSizeMake(320, 480)];
    NSData *imageData = UIImageJPEGRepresentation(screenImage, JPEG_QUALITY);
    DDLogVerbose(@"Imagedata size %i", [imageData length]);
    UIImage *image = [UIImage imageWithData:imageData];
    
    // HUD show
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.removeFromSuperViewOnHide = YES;
    HUD.labelText = T(@"已经保存至本地");
    HUD.mode = MBProgressHUDModeText;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        // Save Video to Photo Album
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:imageData
                                         metadata:nil
                                  completionBlock:^(NSURL *assetURL, NSError *error){}];
        [HUD hide:YES afterDelay:1];
        [picker dismissModalViewControllerAnimated:YES];
        self.photoImage = image;
        [self finishPhoto:self.photoImage];

    }else if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
//        self.selectedImageView.image = image;
//        self.uploadImage = image;
//        [picker.view addSubview:self.selectedView];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    /* keep the order first dismiss picker and pop controller */
    [picker dismissModalViewControllerAnimated:YES];
    //    [self.controller.navigationController popViewControllerAnimated:NO];
}


//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - finish photo action
//////////////////////////////////////////////////////////////////////////////////////////

- (void)finishPhoto:(UIImage *)image
{
    NSUInteger count = [self.albumArray count];
    [self.scrollView setPage:count];
//    self.targetView = [self.targetArray objectAtIndex:count];
    [self.shareView photoSuccess:image];
    [self.shareView.photoButton setEnabled:NO];
}


- (void)jumpToFirst:(BOOL)first orLast:(BOOL)last
{
    NSUInteger count = [self.albumArray count];

    if (first) {
        self.albumIndex = 0;
    }else if (last){
        self.albumIndex = count;
        [XFox logEvent:EVENT_SHARE];
        self.shareView.noticeLabel.text = T(@"谢谢您的分享.您可以再次拍照");
    }
}

- (void)backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.shareView removePhoto];
    [XFox endTimedEvent:EVENT_READING_TIMER withParameters:nil];
}




/*
 - (void)shareButtonAction
 {
 [self.shareView.photoButton setEnabled:YES];
 
 self.shareActionSheet = [[UIActionSheet alloc]
 initWithTitle:T(@"分享到")
 delegate:self
 cancelButtonTitle:T(@"取消")
 destructiveButtonTitle:nil
 otherButtonTitles:T(@"微信朋友圈"), T(@"微信好友"),nil];
 self.shareActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
 [self.shareActionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
 }
 
 
 - (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
 {
 if (actionSheet == self.shareActionSheet) {
 if (buttonIndex == 0 || buttonIndex == 1) {
 [self sendImageContent:self.photoImage withOption:buttonIndex];
 }
 }
 }
 
 
 - (void)photoButtonAction
 {
 self.photoActionSheet = [[UIActionSheet alloc]
 initWithTitle:T(@"选择图片或者相机")
 delegate:self
 cancelButtonTitle:T(@"取消")
 destructiveButtonTitle:nil
 otherButtonTitles:T(@"本地相册"), T(@"照相"),nil];
 self.photoActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
 [self.photoActionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
 
 }
 
 - (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
 {
 if (actionSheet == self.photoActionSheet) {
 if (buttonIndex == 0) {
 [self takePhotoFromLibaray];
 }else if (buttonIndex == 1) {
 [self takePhotoFromCamera];
 }
 }
 
 }
 
 - (void)takePhotoFromLibaray
 {
 self.pickerController = [[UIImagePickerController alloc] init];
 self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
 self.pickerController.delegate = self;
 self.pickerController.allowsEditing = NO;
 [self presentModalViewController:self.pickerController animated:YES];
 }
 */

/*
 - (void)didReceiveWeiboRequest:(WBBaseResponse *) response {
 
 if ([response isKindOfClass:WBAuthorizeResponse.class])
 {
 NSString *title = @"认证结果";
 NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n 原请求UserInfo数据: %@",
 response.statusCode,
 [(WBAuthorizeResponse *)response userID],
 [(WBAuthorizeResponse *)response accessToken],
 response.userInfo,
 response.requestUserInfo];
 
 NSLog(@"title:%@ %@",title,message);
 }
 }
 */




@end
