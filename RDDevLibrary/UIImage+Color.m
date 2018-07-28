//
//  UIImage+Color.m
//  RDDevLibrary
//
//  Created by radar on 2018/7/24.
//  Copyright © 2018年 Radar. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (ColorImage)


+ (UIImage*)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage*)imageNamed:(NSString *)name forme:(id)me
{
    if(!name || [name isEqualToString:@""]) return nil;
    if(!me) return nil;
    
    NSBundle *bundle = [NSBundle bundleForClass:[me class]];
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil]; 
    
    return image;
}


@end
