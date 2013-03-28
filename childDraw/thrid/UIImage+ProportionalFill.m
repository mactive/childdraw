//
//  UIImage+ProportionalFill.m
//
//  Created by Matt Gemmell on 20/08/2008.
//  Copyright 2008 Instinctive Code.
//

#import "UIImage+ProportionalFill.h"


@implementation UIImage (MGProportionalFill)


- (UIImage *)imageToFitSize:(CGSize)fitSize method:(MGImageResizingMethod)resizeMethod
{
	float imageScaleFactor = 1.0;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	if ([self respondsToSelector:@selector(scale)]) {
		imageScaleFactor = [self scale];
	}
#endif
    
	float sourceWidth = [self size].width * imageScaleFactor;
	float sourceHeight = [self size].height * imageScaleFactor;
	float targetWidth = fitSize.width;
	float targetHeight = fitSize.height;
	BOOL cropping = !(resizeMethod == MGImageResizeScale);
    
	// Calculate aspect ratios
	float sourceRatio = sourceWidth / sourceHeight;
	float targetRatio = targetWidth / targetHeight;
    
	// Determine what side of the source image to use for proportional scaling
	BOOL scaleWidth = (sourceRatio <= targetRatio);
	// Deal with the case of just scaling proportionally to fit, without cropping
	scaleWidth = (cropping) ? scaleWidth : !scaleWidth;
    
	// Proportionally scale source image
	float scalingFactor, scaledWidth, scaledHeight;
	if (scaleWidth) {
		scalingFactor = 1.0 / sourceRatio;
		scaledWidth = targetWidth;
		scaledHeight = round(targetWidth * scalingFactor);
	} else {
		scalingFactor = sourceRatio;
		scaledWidth = round(targetHeight * scalingFactor);
		scaledHeight = targetHeight;
	}
	float scaleFactor = scaledHeight / sourceHeight;
    
	// Calculate compositing rectangles
	CGRect sourceRect, destRect;
	if (cropping) {
		destRect = CGRectMake(0, 0, targetWidth, targetHeight);
		float destX, destY;
		if (resizeMethod == MGImageResizeCrop) {
			// Crop center
			destX = round((scaledWidth - targetWidth) / 2.0);
			destY = round((scaledHeight - targetHeight) / 2.0);
		} else if (resizeMethod == MGImageResizeCropStart) {
			// Crop top or left (prefer top)
			if (scaleWidth) {
				// Crop top
				destX = 0.0;
				destY = 0.0;
			} else {
				// Crop left
				destX = 0.0;
				destY = round((scaledHeight - targetHeight) / 2.0);
			}
		} else if (resizeMethod == MGImageResizeCropEnd) {
			// Crop bottom or right
			if (scaleWidth) {
				// Crop bottom
				destX = round((scaledWidth - targetWidth) / 2.0);
				destY = round(scaledHeight - targetHeight);
			} else {
				// Crop right
				destX = round(scaledWidth - targetWidth);
				destY = round((scaledHeight - targetHeight) / 2.0);
			}
		}
		sourceRect = CGRectMake(destX / scaleFactor, destY / scaleFactor,
								targetWidth / scaleFactor, targetHeight / scaleFactor);
	} else {
		sourceRect = CGRectMake(0, 0, sourceWidth, sourceHeight);
		destRect = CGRectMake(0, 0, scaledWidth, scaledHeight);
	}
    
	// Create appropriately modified image.
	UIImage *image = nil;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	CGImageRef sourceImg = nil;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		UIGraphicsBeginImageContextWithOptions(destRect.size, NO, 0.f); // 0.f for scale means "scale for device's main screen".
		sourceImg = CGImageCreateWithImageInRect([self CGImage], sourceRect); // cropping happens here.
		image = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:self.imageOrientation]; // create cropped UIImage.
        
	} else {
		UIGraphicsBeginImageContext(destRect.size);
		sourceImg = CGImageCreateWithImageInRect([self CGImage], sourceRect); // cropping happens here.
		image = [UIImage imageWithCGImage:sourceImg]; // create cropped UIImage.
	}
    
	CGImageRelease(sourceImg);
	[image drawInRect:destRect]; // the actual scaling happens here, and orientation is taken care of automatically.
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
#endif
    
	if (!image) {
		// Try older method.
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(NULL, scaledWidth, scaledHeight, 8, (scaledWidth * 4),
													 colorSpace, kCGImageAlphaPremultipliedLast);
		CGImageRef sourceImg = CGImageCreateWithImageInRect([self CGImage], sourceRect);
		CGContextDrawImage(context, destRect, sourceImg);
		CGImageRelease(sourceImg);
		CGImageRef finalImage = CGBitmapContextCreateImage(context);
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
		image = [UIImage imageWithCGImage:finalImage];
		CGImageRelease(finalImage);
	}
    
	return image;
}


- (UIImage *)imageCroppedToFitSize:(CGSize)fitSize
{
	return [self imageToFitSize:fitSize method:MGImageResizeCrop];
}


- (UIImage *)imageScaledToFitSize:(CGSize)fitSize
{
	return [self imageToFitSize:fitSize method:MGImageResizeScale];
}

// try self

-(UIImage*)imageByScalingToSize:(CGSize)areaSize
{
    float imageScaleFactor = 1.0;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	if ([self respondsToSelector:@selector(scale)]) {
		imageScaleFactor = [self scale];
	}
#endif
    
    UIImage* sourceImage = self;
    
	CGFloat areaWidth   = areaSize.width;
	CGFloat areaHeight  = areaSize.height;
    
    CGFloat sourceWidth = sourceImage.size.width *imageScaleFactor;
	CGFloat sourceHeight = sourceImage.size.height *imageScaleFactor;
    
    CGFloat calcWidth = 0.0f;
	CGFloat calcHeight = 0.0f;
    
        
        if (sourceWidth < areaWidth) {
            if (sourceHeight < areaHeight) {
                calcWidth = sourceWidth;
                calcHeight = sourceHeight;
            }else{
                calcHeight = areaHeight;
                calcWidth = sourceHeight *  areaHeight / sourceHeight;
            }
        }else{
            if (sourceHeight < areaHeight) {
                calcWidth = areaWidth;
                calcHeight = sourceHeight * areaWidth / sourceWidth;
            }else{
                if (sourceWidth/areaWidth > sourceHeight/areaHeight) {
                    calcWidth = areaWidth;
                    calcHeight = sourceHeight * areaWidth/sourceWidth;
                }else{
                    calcHeight = areaHeight;
                    calcWidth = sourceWidth * areaHeight/sourceHeight;
                } 
            }
        }
    
//    NSLog(@"A %f %f",areaWidth,areaHeight);
//    NSLog(@"S %f %f",sourceWidth,sourceHeight);
//    NSLog(@"C %f %f",calcWidth,calcHeight);
    
    // create a new bitmap image context at the device resolution (retina/non-retina)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(calcWidth , calcHeight), YES, 0.0);
    
    // get context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // push context to make it current
    // (need to do this manually because we are not drawing in a UIView)
    UIGraphicsPushContext(context);
    
    // drawing code comes here- look at CGContext reference
    // for available operations
    // this example draws the inputImage into the context
    [sourceImage drawInRect:CGRectMake(0, 0, calcWidth, calcHeight)];
    
    // pop context
    UIGraphicsPopContext();
    
    // get a UIImage from the image context- enjoy!!!
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
    return outputImage;
}
@end