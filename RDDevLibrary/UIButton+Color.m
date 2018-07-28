//
//  UIButton+Color.m
//  RDDevLibrary
//
//  Created by radar on 2018/7/24.
//  Copyright © 2018年 Radar. All rights reserved.
//

#import "UIButton+Color.h"
#import "UIImage+Color.h"
#import <objc/runtime.h>


@implementation UIButton (ColorButton)
@dynamic tagData;

static const void *tagDataKey = &tagDataKey;


//扩展属性数据
- (id)tagData{
    return objc_getAssociatedObject(self, tagDataKey);
}

- (void)setTagData:(id)tagData{
    objc_setAssociatedObject(self, tagDataKey, tagData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



//扩展创建方法
+ (id)buttonWithColor:(UIColor*)nomalColor selColor:(UIColor*)selColor
{
    UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imgBtn setExclusiveTouch:YES];
    if(nomalColor)
    {
        UIImage *nimage = [UIImage imageWithColor:nomalColor andSize:CGSizeMake(1, 1)];
        [imgBtn setBackgroundImage:nimage forState:UIControlStateNormal];
    }
    
    if(selColor)
    {
        UIImage *simage = [UIImage imageWithColor:selColor andSize:CGSizeMake(1, 1)];
        [imgBtn setBackgroundImage:simage forState:UIControlStateHighlighted];
        [imgBtn setBackgroundImage:simage forState:UIControlStateSelected];
        [imgBtn setBackgroundImage:simage forState:UIControlStateDisabled];
    }
    
    return imgBtn;
}


@end
