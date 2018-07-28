//
//  RDMacros.h
//  RDDevLibrary
//
//  Created by radar on 2018/7/24.
//  Copyright © 2018年 Radar. All rights reserved.
//


#pragma mark - 
#pragma mark 字体和颜色相关，这里边都是默认的一些宏，如果项目中需要额外的，可以在项目中自定义constance.h来定义

//颜色和字体相关的宏
#define RGB(r, g, b)        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBS(x)             [UIColor colorWithRed:x/255.0 green:x/255.0 blue:x/255.0 alpha:1.0]
#define RGBA(r, g, b, a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define FONT(x)   [UIFont systemFontOfSize:x]
#define FONT_B(x) [UIFont boldSystemFontOfSize:x]
#define CUSFONT(x)  [UIFont fontWithName:@"DFPWaWaW7-B5" size:x] 


//文字颜色
#define COLOR_TEXT_A          [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f]
#define COLOR_TEXT_B          [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]
#define COLOR_TEXT_C          [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f]

//文字输入框placeholder颜色
#define COLOR_PLACE_HOLDER    [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f]

//分隔线颜色
#define COLOR_LINE_A          [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f]
#define COLOR_LINE_B          [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f]

//描边使用的颜色
#define COLOR_BORDER          [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]

//背景颜色
#define COLOR_CELL_SELECT     [UIColor colorWithRed:217.0f/255.0f green:217.0f/255.0f blue:217.0f/255.0f alpha:1.0f]
#define COLOR_BACK_GROUND     [UIColor colorWithRed:250.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f]

//蓝灰色背景颜色
#define COLOR_BLUE_GRAY_BACK_GROUND     [UIColor colorWithRed:235.0f/255.0f green:240.0f/255.0f blue:243.0f/255.0f alpha:1.0f]

//标题栏背景颜色
#define COLOR_TITLEBAR_BACK_GROUND     [UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1.0f]

//规定的特殊颜色
#define COLOR_ORANGE          [UIColor colorWithRed:255.0f/255.0f green:150.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
#define COLOR_BLUE            [UIColor colorWithRed:50.0f/255.0f green:220.0f/255.0f blue:210.0f/255.0f alpha:1.0f]
#define COLOR_RED             [UIColor colorWithRed:255.0f/255.0f green:93.0f/255.0f blue:98.0f/255.0f alpha:1.0f]
#define COLOR_GOLD            [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:126.0f/255.0f alpha:1.0f]
#define COLOR_LAKEBLUE        [UIColor colorWithRed:47.0f/255.0f green:177.0f/255.0f blue:255.0f/255.0f alpha:1.0f]
#define COLOR_YELLOW          [UIColor colorWithRed:249.0f/255.0f green:207.0f/255.0f blue:26.0f/255.0f alpha:1.0f]
#define COLOR_CLEAR           [UIColor clearColor]

//下拉水滴颜色
#define COLOR_DROP_REFRESH    [UIColor colorWithRed:50.0f/255.0f green:220.0f/255.0f blue:210.0f/255.0f alpha:1.0f]

//随机颜色（RGB）
#define COLOR_RANDOM          [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0f];




#pragma mark -
#pragma mark 实用工具

#define IS_IOS7_ORLATER             [RDFunction isiOS7orLater]          //判断当前操作系统是否iOS7以上
#define IS_FAST_DEVICE              [DDUIUtils checkIsFastDevice]       //用来判断是否是快机器
#define STRVALID(str)               [RDFunction checkStringValid:str]   //检查一个字符串是否有效
#define ARRAYVALID(array)           [RDFunction checkArrayValid:array]  //检查一个数组是否有效
#define DICTIONARYVALID(dict)       [RDFunction checkDictionaryValid:dict]  //检查一个数组是否有效
#define CHECKINARRAY(index, array)  [RDFunction checkInArrayOfIndex:index ofArray:array] //检查一个index是否在数组的区域内
#define OBJECTISNULL(obj)           [obj isEqual:[NSNull null]]// 判断对象是否为null值

//从mainBundle中 拿图片
#define ImageFromResource(x) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:x ofType:nil]]

//安全释放一个view上面所有subview的delegate
#define SAFELY_RELEASE_DELEGATE(view) [RDFunction safelyReleaseDelegate:view]

//安全释放一个view上面制定类型subview的delegate
#define SAFELY_RELEASE_CLASS_DELEGATE(class, view) [RDFunction safelyReleaseDelegateForClass:class fromView:view]


//获取屏幕高度
#define SCR_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCR_WIDTH  [UIScreen mainScreen].bounds.size.width



#import <Foundation/Foundation.h>

@interface RDMacros : NSObject

@end


