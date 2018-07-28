//
//  UIButton+Color.h
//  RDDevLibrary
//
//  Created by radar on 2018/7/24.
//  Copyright © 2018年 Radar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ColorButton)

//扩展属性 数据data
@property (nonatomic,retain) id tagData;

//这个方法创建的button就只是一个设定了背景色的button，其他属性还必须自己去设定
+ (id)buttonWithColor:(UIColor*)nomalColor selColor:(UIColor*)selColor;

@end
