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

#import "DDLog.h"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif



@interface AlbumViewController ()<UIScrollViewAccessibilityDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (UIView*) createViewForObj:(id)obj;
@property(strong, nonatomic)UIView *targetView;
@property(strong, nonatomic)UIButton *moreButton;
@property(strong, nonatomic)NSMutableArray *targetArray;
@property(strong, nonatomic)UIActionSheet *photoActionSheet;
@property(nonatomic, strong)UIImagePickerController *pickerController;
@end

@implementation AlbumViewController
@synthesize albumArray;
@synthesize albumIndex;
@synthesize targetView;
@synthesize targetArray;
@synthesize moreButton;
@synthesize photoActionSheet;
@synthesize titleArray;
@synthesize shareView;
@synthesize pickerController;


#define kCameraSource       UIImagePickerControllerSourceTypeCamera

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GCPagedScrollView* scrollView = [[GCPagedScrollView alloc] initWithFrame:self.view.frame];
    scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.view = scrollView;
    self.targetArray = [[NSMutableArray alloc]init];
    
    self.targetView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 432)];
    self.scrollView.backgroundColor = BGCOLOR;
    

    self.scrollView.minimumZoomScale = 1; //最小到0.3倍
    self.scrollView.maximumZoomScale = 3.0; //最大到3倍
    self.scrollView.clipsToBounds = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    [self refreshSubView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.scrollView setPage:self.albumIndex];
    
    self.targetView = [self.targetArray objectAtIndex:self.scrollView.page];
    //DDLogVerbose(@"page %d %@",self.scrollView.page,self.targetView);
    NSUInteger count = [self.albumArray count];
    if (self.shareView != nil) {
        count = count + 1;
    }
    
    self.shareView.delegate = self;

}

// refresh

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    if ([scrollView isEqual:self.scrollView]) {
//        //DDLogVerbose(@"End page %d %@",self.scrollView.page,self.targetView);
//        self.targetView = [self.targetArray objectAtIndex:self.scrollView.page];
//        NSUInteger count = [self.albumArray count];
//        if (self.shareView != nil) {
//            count = count + 1;
//        }
//        self.title = [NSString stringWithFormat:@"%d/%d",self.scrollView.page+1,count];
//    }
//}


#pragma mark -
#pragma mark Getters

- (GCPagedScrollView *)scrollView {
    return (GCPagedScrollView*) self.view;
}


#pragma mark -
#pragma mark Helper methods

- (UIView *)createViewForObj:(id)obj withIndex:(NSInteger)index{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 20,
                                                            self.view.frame.size.height - 50)];
    
    view.backgroundColor = BGCOLOR;
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
    self.targetArray = [[NSMutableArray alloc]init];
    
    for (NSUInteger index = 0; index < [self.albumArray count]; index ++) {
        //You add your content views here
        id obj = [self.albumArray objectAtIndex:index];
        
        [self.scrollView addContentSubview:[self createViewForObj:obj withIndex:index]];
        [self.targetArray addObject:[self createViewForObj:obj withIndex:index]];
    }
    
    if (self.shareView != nil) {
        [self.scrollView addContentSubview:self.shareView];
        [self.targetArray addObject:self.shareView];
    }
}

//////////////////////////////////////////////////////////////////////
// photo action sheet
//////////////////////////////////////////////////////////////////////

- (void)passStringValue:(NSString *)value andIndex:(NSUInteger)index
{
    if ([value isEqualToString:PHOTOACTION] && index == 1) {
        //
        [self takePhotoFromCamera];
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



//////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIImagePickerControllerDelegateMethods
//////////////////////////////////////////////////////////////////////////////////////////


- (void)takePhotoFromLibaray
{
    self.pickerController = [[UIImagePickerController alloc] init];
    self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.pickerController.delegate = self;
    self.pickerController.allowsEditing = NO;
    [self presentModalViewController:self.pickerController animated:YES];
}

- (void)takePhotoFromCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:kCameraSource]) {
        UIAlertView *cameraAlert = [[UIAlertView alloc] initWithTitle:T(@"cameraAlert") message:T(@"Camera is not available.") delegate:self cancelButtonTitle:T(@"Cancel") otherButtonTitles:nil, nil];
        [cameraAlert show];
		return;
	}
    
    //    self.tableView.allowsSelection = NO;
    self.pickerController = [[UIImagePickerController alloc] init];
    self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	self.pickerController.delegate = self;
	self.pickerController.allowsEditing = YES;
    
    [self presentModalViewController:self.pickerController animated:YES];
}

// UIImagePickerControllerSourceTypeCamera and UIImagePickerControllerSourceTypePhotoLibrary

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
	UIImage *originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *screenImage = [originalImage imageByScalingToSize:CGSizeMake(320, 320)];
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
        [HUD hide:YES afterDelay:2];
        [picker dismissModalViewControllerAnimated:YES];
        [self finishPhoto:image];

    }else if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
//        self.selectedImageView.image = image;
//        self.uploadImage = image;
//        [picker.view addSubview:self.selectedView];
    }
}

- (void)finishPhoto:(UIImage *)image
{
    NSUInteger count = [self.albumArray count];
    
    [self.scrollView setPage:count];
    self.targetView = [self.targetArray objectAtIndex:count];
    
    [self.shareView afterPhoto:image];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.shareView removePhoto];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    /* keep the order first dismiss picker and pop controller */
    [picker dismissModalViewControllerAnimated:YES];
    //    [self.controller.navigationController popViewControllerAnimated:NO];
}




@end
