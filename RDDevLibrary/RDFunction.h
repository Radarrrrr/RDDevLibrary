//
//  RDFunction.h
//  RDDevLibrary
//
//  Created by radar on 2018/7/24.
//  Copyright © 2018年 Radar. All rights reserved.
//
// 一些类方法

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface RDFunction : NSObject


#pragma mark - 
#pragma mark 数据处理
//根据组件字典的层级结构和要找的最后一层的key，获取最后一层的数据,并组成数组
//PS: 仅适用于从cms返回来的组件字典, 层级结构关系是content.value.xxxx,前两层固定
+ (NSArray *)valueOfComponentForDictionary:(NSDictionary *)dict byKey:(NSString *)key;

//根据data数据源和指定的path，得到path对应的value
//PS: data只能是字典或数组类型，path的结构是: ret.0.content.value.0.img_url，其中，数字表示供数组的index，字符串表示字典的key
//PS: 使用的时候，必须手动控制data和path内部的结构，否则会出错，如果解析有问题，请检查path和data的结构是否对应
+ (id)valueOfData:(id)data byPath:(NSString *)path;

//在data数据源里，找到key对应的数据value，并返回 //PS: data只能是字典或数组类型，且只能支持data里边只有唯一的一个key，如果出现了两个，则只取第一个
+ (id)getValueForKey:(NSString*)key inData:(id)data;

//在data数据源里，找到所有的相同的key对应的数据value，并组成数组返回
//PS: data只能是字典或数组类型
+ (NSArray *)findValuesForKey:(NSString *)key inData:(id)data;

+ (BOOL)isPureInt:(NSString *)string; //判断是否纯数字

//在原始数据里边添加一个新的数据，用key的最后一层制定的key来当作节点的key
//PS: 目前只能支持字典的处理
//path = @"content.value.key" //key就是要添加的数据的key
+ (NSMutableDictionary *)insertAnObjet:(id)object toData:(NSDictionary *)originalData forPath:(NSString *)path;



#pragma mark - 
#pragma mark 数据转换
//json <-> data 互转 你懂得。。。
+ (NSString *)jsonStringFormData:(id)data;   //data转化成json字符串
+ (id)dataFromJsonString:(NSString *)string; //json字符串转化成data



#pragma mark - 
#pragma mark 数据拆分和解析
//从linkURL里拆分出property，如 cms://page_id=9527&seq=1,从中拆分出page_id的内容是9527 或者如 http://192.168.85.11:8282/paycenter.php?op=submit&type=sdk&pay_id=79 从中解析出pay_id的值是79
+ (NSString *)getProperty:(NSString *)propertyKey formLinkURL:(NSString*)linkURL; //PS:处理cms相关的linkURL用这个//PS:多重url还无法处理



#pragma mark - 
#pragma mark 字符串&URL的encoding和decoding
// 加密
+ (NSString *)URLEncodedString:(NSString *)strPlainText;
// 解密
+ (NSString *)URLDecodedString:(NSString *)utf8String;
    


#pragma mark - 
#pragma mark 页面层级相关
+ (NSArray *)findAllSpecifyViewByClass:(Class)theClass onView:(UIView *)theView;//在theView上找到所有theClass类对应的view，做成一个数组
+ (void)safelyReleaseDelegate:(UIView *)theView; //在本类view内部所有的各种层级的view中找到有delegate的view，并设定为nil, 注意，传入参数必须为view
+ (void)safelyReleaseDelegateForClass:(Class)theClass fromView:(UIView *)theView; //在本类view内部所有的各种层级的view中找到有delegate的view，如果是指定类型，则释放delegate，并设定为nil



#pragma mark - 
#pragma mark 实用方法相关
+ (float)getTextViewHeightForString:(NSString*)string font:(UIFont*)font width:(float)width; //注: 此方法可能根据iOS版本不同有效果不同
+ (float)getHeightForString:(NSString *)string font:(UIFont *)font width:(float)width;
+ (float)getWidthForString:(NSString *)string font:(UIFont *)font height:(float)height;

+ (NSInteger)getLinesForString:(NSString *)string font:(UIFont *)font width:(float)width;

+ (UIColor *)colorFromHexString:(NSString *)hexString; //16进制颜色(html颜色值)字符串转为UIColor 如：#3300ff

+ (BOOL)checkStringValid:(NSString *)string; //检查一个字符串是否有效
+ (BOOL)checkArrayValid:(NSArray *)array;    //检查一个数组是否有效
+ (BOOL)checkDictionaryValid:(NSDictionary *)dictionary; //检查一个字典是否有效
+ (BOOL)checkInArrayOfIndex:(NSInteger)index ofArray:(NSArray *)array; //检查一个index是否在数组的区域内

+ (NSString *)getDeviceType; //获得设备型号

+ (void)addLineToLabel:(UILabel *)label useColor:(UIColor *)color; //给一个label加上线划掉, 仅限一行文字, PS:会在内部强制改变了label的frame
+ (void)addLineToViewTop:(UIView*)view useColor:(UIColor*)color;    //给一个view加上 上划线
+ (void)addLineToViewBottom:(UIView*)view useColor:(UIColor*)color; //给一个view加上 下划线

+ (BOOL)checkIsIPad;//检查是否是iPad，如果是就返回YES。iphone和其他设备，都返回NO

+ (BOOL) IsConnectedToNetwork; //判断网络是否可用

+ (UIImageView*)createBlurView:(UIView*)view; //创建一个毛玻璃模糊view

+ (void)addRadiusToView:(UIView*)view radius:(float)radius; //给一个view添加圆角

+ (void)addBorderToView:(UIView*)view color:(UIColor*)color lineWidth:(float)lineWidth; //给一个view加描边

+ (void)ActionAfterDelay:(NSTimeInterval)delay action:(void (^)(void))completion; //延迟delay秒以后做某件事情

+ (double)randomFrom:(double)numMin to:(double)numMax; //从numMin-numMax之间随机生成一个数 注: numMin 必须小于 numMax

+ (void)changeHeightForView:(UIView *)view to:(float)toHeight; //把view的frame高度改为toHeight指定的高度 //PS:不带动画，如果需要 在外面套一层 animateWithDuration 方法即可

+ (NSString *)md5FormString:(NSString *)string; //给一个字符串做MD5，输出MD5格式的串


#pragma mark -
#pragma mark 时间解析相关
+ (NSDate *)dateFromString:(NSString *)dateString useFormat:(NSString *)format; //从时间字符串转化成NSDate, fromat=@"yyyy-MM-dd HH:mm:ss", 需要根据实际情况更换格式
+ (NSString *)stringFromDate:(NSDate *)date useFormat:(NSString *)format;   //转化为要显示的时间格式如：@"MM-dd HH:mm"



#pragma mark -
#pragma mark 系统相关
+ (BOOL)isiOS7orLater;      //判断系统是否iOS7以上版本




@end
