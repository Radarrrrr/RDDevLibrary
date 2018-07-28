//
//  RDImageManager.m
//  SMJ
//
//  Created by mac on 10-10-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDImageManager.h"


@implementation RDImageManager





#pragma mark -
#pragma mark out use function
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
	// Create a graphics image context
	UIGraphicsBeginImageContext(newSize);
	
	// Tell the old image to draw in this new context, with the desired
	// new size
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	
	// Get the new image from the context
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// End the context
	UIGraphicsEndImageContext();
	
	// Return the new image.
	return newImage;
}
+ (UIImage*)imageFor3Ratio4WithImage:(UIImage*)image
{
	if(image == nil) return nil;
	if(image.size.width == image.size.height*0.75) return image;
	if(image.size.width == 1936.0 && image.size.height == 2592.0) return image;
	
	
		
	float contxWidth;
	float contxHeight;
	float offsetx;
	float offsety;
	
	if(image.size.width > image.size.height*0.75)
	{
		contxWidth = image.size.width;
		contxHeight = image.size.width/0.75;
		offsetx = 0.0;
		offsety = (contxHeight-image.size.height)/2;
	}
	else
	{
		contxHeight = image.size.height;
		contxWidth = contxHeight*0.75;
		offsetx = (contxWidth-image.size.width)/2;
		offsety = 0.0;
	}


	// Create a graphics image context
	UIGraphicsBeginImageContext(CGSizeMake(contxWidth, contxHeight));
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0.0, 0.0, contxWidth, contxHeight));
	
	// Tell the old image to draw in this new context, with the desired
	// new size
	[image drawInRect:CGRectMake(offsetx, offsety, image.size.width, image.size.height)];
	
	// Get the new image from the context
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// End the context
	UIGraphicsEndImageContext();
	
	// Return the new image.
	return newImage;
}

+ (UIImage*)imageMergedForImage:(UIImage*)originImage maskImage:(UIImage*)maskImage
{
	if(originImage == nil) return nil;
	if(maskImage == nil) return originImage;
	
	CGSize imageSize = originImage.size;
	
	UIGraphicsBeginImageContext(imageSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
    // full the color in the context
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height));
    
	CGContextSetAlpha(ctx, 0.0);
	CGContextClipToMask(ctx, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), [maskImage CGImage]);
	
	// draw source image on the context
	[originImage drawInRect:CGRectMake(0.0, 0.0, imageSize.width, imageSize.height)];
	
    UIImage* mergePhoto = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return mergePhoto;
}
+ (UIImage*)imageCutAndMergedForImage:(UIImage*)originImage maskImage:(UIImage*)maskImage cutRect:(CGRect)cutRect
{
	
	if(originImage == nil) return nil;
	if(maskImage == nil) return originImage;
	
	CGSize imageSize = originImage.size;
	
	UIGraphicsBeginImageContext(cutRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
    // full the color in the context
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0.0, 0.0, cutRect.size.width, cutRect.size.height));
    
	CGContextSetAlpha(ctx, 0.0);
	CGContextClipToMask(ctx, CGRectMake(0.0, 0.0, cutRect.size.width, cutRect.size.height), [maskImage CGImage]);
	
	// draw source image on the context
	[originImage drawInRect:CGRectMake(0.0-cutRect.origin.x, 0.0-cutRect.origin.y, imageSize.width, imageSize.height)];
	
    UIImage* mergePhoto = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return mergePhoto;
	
}
+ (UIImage*)composeImages:(NSArray*)images toSize:(CGSize)coverSize
{
	if(images == nil || [images count] == 0) return nil;
	
	UIGraphicsBeginImageContext(coverSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
    // full the color in the context
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0.0, 0.0, coverSize.width, coverSize.height));
    
    // draw source image on the context
	for(UIImage *image in images)
	{
		[image drawInRect:CGRectMake(0.0, 0.0, coverSize.width, coverSize.height)];
	}
	
    UIImage* compiledPhoto = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return compiledPhoto;
}
+ (UIImage*)cutPhotoFromPhoto:(UIImage*)photo fitSize:(CGSize)fitSize inRect:(CGRect)cutRect
{
	if(!photo) return nil;
	
	UIGraphicsBeginImageContext(cutRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
    // full the color in the context
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0.0, 0.0, cutRect.size.width, cutRect.size.height));
    
    // draw source image on the context
	[photo drawInRect:CGRectMake(-cutRect.origin.x, -cutRect.origin.y, fitSize.width, fitSize.height)];
	
    UIImage* cutPhoto = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return cutPhoto;
}
+ (UIImage*)imageFromLayer:(CALayer*)layer size:(CGSize)size
{
	if(layer == nil) return nil;
	
	UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0.0, 0.0, size.width, size.height));
    
	[layer renderInContext:UIGraphicsGetCurrentContext()];
	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}
+ (UIImage*)imageAddAlpha:(UIImage*)image
{
    CGImageRef CGImage = image.CGImage;
	if (!CGImage)
		return nil;
    
	
	size_t imgWidth	= CGImageGetWidth(CGImage);
	size_t imgHeight  = CGImageGetHeight(CGImage);
	UInt8* buffer = (UInt8*)malloc(imgWidth * imgHeight * 4);
	
	
	CGColorSpaceRef	desColorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bitmapContext = CGBitmapContextCreate(buffer,
													   imgWidth,imgHeight,
													   8, 4*imgWidth,
													   desColorSpace,
													   kCGImageAlphaPremultipliedLast);
	CGContextDrawImage(bitmapContext, CGRectMake(0.0, 0.0, (CGFloat)imgWidth, (CGFloat)imgHeight), image.CGImage);
	
	CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
	UIImage* resultImage = [UIImage imageWithCGImage:cgImage];
	
	CFRelease(desColorSpace);
	CFRelease(bitmapContext);
	CFRelease(cgImage);
	free(buffer);
	
	return resultImage;
}
+ (UIImage*)imageCorrectOrientation:(UIImage*)image
{
    if(!image) return nil;
    
    CGFloat width = image.size.width;   
    CGFloat height = image.size.height; 
    
    CGFloat destW = width;
    CGFloat destH = height;
    CGFloat sourceW = width;
    CGFloat sourceH = height;
    
    if (image.imageOrientation == UIImageOrientationRight || image.imageOrientation == UIImageOrientationLeft) 
    {
        sourceW = height;
        sourceH = width;
    }
    
    
    CGImageRef imageRef = image.CGImage;
    CGContextRef bitmap = CGBitmapContextCreate(NULL, destW, destH,
                                                CGImageGetBitsPerComponent(imageRef), 4*destW, CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    if (image.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM(bitmap, sourceW, sourceH);
        CGContextRotateCTM(bitmap, 180 * (M_PI/180));
    } else if (image.imageOrientation == UIImageOrientationLeft) {
        CGContextTranslateCTM(bitmap, sourceH, 0);
        CGContextRotateCTM(bitmap, 90 * (M_PI/180));
    } else if (image.imageOrientation == UIImageOrientationRight) {
        CGContextTranslateCTM(bitmap, 0, sourceW);
        CGContextRotateCTM(bitmap, -90 * (M_PI/180));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0,0,sourceW,sourceH), imageRef);
    
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;
}


@end
