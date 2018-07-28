//
//  UIButton+Spin.h
//  RDDevLibrary
//
//  Created by radar on 2018/7/24.
//  Copyright © 2018年 Radar. All rights reserved.
//
//本类目前只扩展到无限旋转，如果需要限定旋转次数，再继续扩展

#import <UIKit/UIKit.h>

@interface UIButton (SpinButton)

//扩展方法
- (void)startSpining;   //开始旋转
- (void)stopSpining;    //停止旋转


@end
