//
//  RDKeyChain.h
//  RDDevLibrary
//
//  Created by radar on 2018/7/24.
//  Copyright © 2018年 Radar. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface RDKeyChain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)remove:(NSString *)service;

@end
