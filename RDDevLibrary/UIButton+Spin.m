//
//  UIButton+Spin.m
//  RDDevLibrary
//
//  Created by radar on 2018/7/24.
//  Copyright © 2018年 Radar. All rights reserved.
//

#import "UIButton+Spin.h"


@implementation UIButton (SpinButton)


//扩展方法
- (void)startSpining
{
    if (!animating) {  
        animating = YES;  
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];  
    } 
}
- (void)stopSpining
{
    // set the flag to stop spinning after one last 90 degree increment  
    animating = NO;  
}



static BOOL animating;  
- (void) spinWithOptions: (UIViewAnimationOptions) options {  
    // this spin completes 360 degrees every 2 seconds  
    [UIView animateWithDuration: 0.3f  
                          delay: 0.0f  
                        options: options  
                     animations: ^{  
                         self.transform = CGAffineTransformRotate(self.transform, M_PI / 2);  
                     }  
                     completion: ^(BOOL finished) {  
                         if (finished) {  
                             if (animating) {  
                                 // if flag still set, keep spinning with constant speed  
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];  
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {  
                                 // one last spin, with deceleration  
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];  
                             }  
                         }  
                     }];  
}  







@end
