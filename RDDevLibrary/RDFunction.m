//
//  RDFunction.m
//  RDDevLibrary
//
//  Created by radar on 2018/7/24.
//  Copyright © 2018年 Radar. All rights reserved.
//

#import "RDFunction.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <netinet/in.h>
#import "UIImage+ImageEffects.h"
#import <CommonCrypto/CommonDigest.h>
#import <CoreText/CoreText.h>


@implementation RDFunction


+ (BOOL) IsConnectedToNetwork
{
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    //如果不能获取连接标志，则不能连接网络，直接返回
    if (!didRetrieveFlags) return NO;
    
    //根据获得的连接标志进行判断
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

+ (NSArray*)valueOfComponentForDictionary:(NSDictionary*)dict byKey:(NSString*)key
{
    //content.value.xxxx
    //根据字典的层级结构和要找的最后一层的index，获取最后一层的数据
    if(!dict) return nil;
    if(!key || [key compare:@""] == NSOrderedSame) return nil;
    
    NSDictionary *contentDic = [dict objectForKey:@"content"];
    if(!contentDic) return nil;
    
    NSArray *valueArr = [contentDic objectForKey:@"value"];
    if(!valueArr) return nil;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    for(NSDictionary *valDic in valueArr)
    {
        if(valDic)
        {
            id value = [valDic objectForKey:key];
            if(value)
            {
                [values addObject:value];
            }
        }
    }
    
    return values;
    
}

+ (id)valueOfData:(id)data byPath:(NSString*)path
{
    if(!data) return nil;
    if(!path || [path compare:@""] == NSOrderedSame) return nil;
    
    //获取每个节点的标识，都是string，如果是数组，再临时转化
    NSArray *stones = [path componentsSeparatedByString:@"."];
    
    //开始解析每一层
    id subdata = data;
    for(NSString *stone in stones)
    {
        if(!subdata)
        {
            break;
        }
        
        if([subdata isKindOfClass:[NSDictionary class]])
        {
            id subd = [subdata objectForKey:stone];
            if([subd isKindOfClass:[NSNull class]])
            {
                subd = nil;
            }
            subdata = subd;
            continue;
        }
        else if([subdata isKindOfClass:[NSArray class]])
        {
            NSInteger index = [stone integerValue];
            if(index >= [subdata count]) 
            {
                subdata = nil;
                break;
            }
            
            subdata = [subdata objectAtIndex:index];
            continue;
        }
        else 
        {
            return nil;
        }
    }
    
    return subdata;
}

+ (NSArray*)findValuesForKey:(NSString*)key inData:(id)data
{
    //在data数据源里，找到所有的key对应的数据value，并组成数组返回
    if(!data) return nil;
    if(!key || [key compare:@""] == NSOrderedSame) return nil;
    if(![data isKindOfClass:[NSDictionary class]] && ![data isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    //开始解析
    if([data isKindOfClass:[NSDictionary class]])
    {
        NSArray *keys = [data allKeys];
        for(NSString *akey in keys)
        {
            if([akey compare:key] == NSOrderedSame)
            {
                id value = [data objectForKey:key];
                if(value) 
                {
                    [values addObject:value];
                }
            }
            else
            {
                id adata = [data objectForKey:akey];
                NSArray *avals = [RDFunction findValuesForKey:key inData:adata];
                if(avals && [avals count] != 0)
                {
                    [values addObjectsFromArray:avals];
                }
            }
        }
    }
    else if([data isKindOfClass:[NSArray class]])
    {
        for(id adata in data)
        {
            NSArray *avals = [RDFunction findValuesForKey:key inData:adata];
            if(avals && [avals count] != 0)
            {
                [values addObjectsFromArray:avals];
            }
        }
    }
    
    return values;
}

//在data数据源里，找到key对应的数据value，并返回 //PS: data只能是字典或数组类型，且只能支持data里边只有唯一的一个key，如果出现了两个，则只取第一个
+ (id)getValueForKey:(NSString*)key inData:(id)data
{
    if(!data) return nil;
    if(!key || [key isEqualToString:@""]) return nil;
    if(![data isKindOfClass:[NSDictionary class]] && ![data isKindOfClass:[NSArray class]]) return nil;
    
    id value = nil;
    
    //开始解析
    if([data isKindOfClass:[NSDictionary class]])
    {
        NSArray *keys = [data allKeys];
        for(NSString *akey in keys)
        {
            if([akey compare:key] == NSOrderedSame)
            {
                value = [data objectForKey:key];
                break;
            }
            else
            {
                id adata = [data objectForKey:akey];
                id avalue = [self getValueForKey:key inData:adata];
                if(avalue)
                {
                    value = avalue;
                    break;
                }
            }
        }
    }
    else if([data isKindOfClass:[NSArray class]])
    {
        for(id adata in data)
        {
            id avalue = [self getValueForKey:key inData:adata];
            if(avalue)
            {
                value = avalue;
                break;
            }
        }
    }
    
    return value;
}

    
+ (BOOL)isPureInt:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string]; 
    int val; 
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (NSMutableDictionary *)insertAnObjet:(id)object toData:(NSDictionary *)originalData forPath:(NSString *)path
{
    //path = @"content.value.key" //key就是要添加的数据的key
    if(!originalData) return nil;
    
    NSMutableDictionary *useData = [NSMutableDictionary dictionaryWithDictionary:originalData];
    if(!object || !path || [path isEqualToString:@""]) return useData;
    
    //找到要添加的容器路径和字典key
    NSString *usePath = nil;
    NSString *useKey = path;
    NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
    if(range.length != 0)
    {
        usePath = [path substringToIndex:range.location];
        useKey  = [path substringFromIndex:(range.location+range.length)];
    }
    
    //找到要添加的容器字典
    NSMutableDictionary *instDic = useData;
    if(usePath)
    {
        instDic = [RDFunction valueOfData:originalData byPath:usePath];
    }
    
    //添加字典
    [instDic setObject:object forKey:useKey];
    
    return useData;
}

+ (NSString*)jsonStringFormData:(id)data
{
    if(!data) return nil;
    if(![data isKindOfClass:[NSArray class]] && ![data isKindOfClass:[NSDictionary class]]) return nil;
    
    NSString *jsonString = nil;
    
    if([NSJSONSerialization isValidJSONObject:data])  
    {   
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];  
        jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];  
    }  
    
    return jsonString;
}

+ (id)dataFromJsonString:(NSString*)string
{
    if(!string || [string compare:@""] == NSOrderedSame) return nil;
    
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    id data = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];  
    
    return data;
}

+ (NSString*)getProperty:(NSString*)propertyKey formLinkURL:(NSString*)linkURL
{
    //从linkURL里拆分出pageID，如 cms://page_id=9527&seq=1,从中拆分出page_id的内容是9527
    if(!linkURL || [linkURL compare:@""] == NSOrderedSame) return nil;
    if(!propertyKey || [propertyKey compare:@""] == NSOrderedSame) return nil;
    
    
    NSString *paramsString = nil;
    
    //做一个query
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:linkURL]];
    NSString *query = [[request URL] query];
    if(query && [query compare:@""]!= NSOrderedSame)
    {
        //有问号
        paramsString = query;
    }
    else
    {
        //没问号
        //找到://后面的部分串
        NSRange range = [linkURL rangeOfString:@"://"];
        if(range.length != 0) 
        {
            NSString *parsString = [linkURL substringFromIndex:(range.location+range.length)]; //page_id=9527&seq=1
            if(parsString && [parsString compare:@""] != NSOrderedSame)
            {
                paramsString = parsString;
            }
        }
    }
    
    if(!paramsString) return nil;
    
    
    //找到数据对
    NSArray *params = [paramsString componentsSeparatedByString:@"&"];
    if(!params || [params count] == 0) return nil;
    
    NSString *property = nil;
    
    //只取遇到的第一个参数
    for(NSString *par in params) //page_id=9527 和 seq=1
    {
        NSArray *keyAndValue = [par componentsSeparatedByString:@"="];
        
        if(!keyAndValue || [keyAndValue count] != 2) continue;
        if([[keyAndValue objectAtIndex:0] isEqualToString:propertyKey])
        {
            property = [keyAndValue objectAtIndex:1];
            break;
        }
    }
    
    return property;
}




// 加密
+ (NSString *)URLEncodedString:(NSString*) strPlainText

{  
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                             kCFAllocatorDefault,
                                                                                             (CFStringRef)strPlainText,
                                                                                             NULL,
                                                                                             CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                             kCFStringEncodingUTF8));
    return result; 
}


// 解密
+ (NSString*)URLDecodedString:(NSString*) utf8String
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                                                             kCFAllocatorDefault,
                                                                                                             (CFStringRef)utf8String,
                                                                                                             CFSTR(""),
                                                                                                             kCFStringEncodingUTF8));
    return result; 
}




+ (NSArray*)findAllSpecifyViewByClass:(Class)theClass onView:(UIView*)theView
{
    //根据类型，在本类view内部所有的各种层级的view中找到class对应的view，返回数组
    //PS://不能包含一个类上面还有另一个相同类的情况
    if(!theView) return nil;
    
    NSMutableArray *finds = [[NSMutableArray alloc] init];
    
    NSArray *subviews = [theView subviews];
    if(!subviews || [subviews count] == 0) return nil;
    
    for(id subV in subviews)
    {
        if([subV isKindOfClass:theClass])
        {
            [finds addObject:subV];
        }
        else
        {
            NSArray *subs = [RDFunction findAllSpecifyViewByClass:theClass onView:subV];
            if(subs && [subs count])
            {
                [finds addObjectsFromArray:subs];
            }
        }
    }
    
    return finds;
}

+ (void)safelyReleaseDelegate:(UIView *)theView
{
    //在本类view内部所有的各种层级的view中找到有delegate的view，并设定为nil
    if(!theView) return;

    NSArray *subviews = [theView subviews];
    if(!subviews || [subviews count] == 0) return;
    
    for(id subV in subviews)
    {
        //处理本页面
        if([subV respondsToSelector:@selector(setDelegate:)])
        {
            //NSLog(@"释放delegate");
            [subV performSelector:@selector(setDelegate:) withObject:nil];
        }
        
        //递归继续处理子页面
        [RDFunction safelyReleaseDelegate:subV];
    }
    
}

+ (void)safelyReleaseDelegateForClass:(Class)theClass fromView:(UIView*)theView
{
    //在本类view内部所有的各种层级的view中找到有delegate的view，如果是指定类型，则释放delegate，并设定为nil
    if(!theView) return;
    
    NSArray *subviews = [theView subviews];
    if(!subviews || [subviews count] == 0) return;
    
    for(id subV in subviews)
    {
        //处理本页面
        if([subV respondsToSelector:@selector(setDelegate:)])
        {
            if([subV isKindOfClass:theClass])
            {
                //NSLog(@"释放delegate");
                [subV performSelector:@selector(setDelegate:) withObject:nil];
            }
        }
        
        //递归继续处理子页面
        [RDFunction safelyReleaseDelegate:subV];
    }
    
}

+ (float)getTextViewHeightForString:(NSString*)string font:(UIFont*)font width:(float)width
{    
    float height = 0.0;
    
    if(string != nil && [string compare:@""] != NSOrderedSame)
    {        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 30.0)];
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 130.0)];
        textView.backgroundColor = [UIColor redColor];
        textView.font = font;
        textView.text = string;
        
        [backView addSubview:textView];
        UIView *topView = [UIApplication sharedApplication].keyWindow;
        [topView addSubview:backView];
        
        height = textView.contentSize.height;
        
        [backView removeFromSuperview];
    }
    
    return height;
}

+ (float)getHeightForString:(NSString *)string font:(UIFont *)font width:(float)width
{	
    if(string && [string compare:@""] != NSOrderedSame) return 0.0;
        
    //段落设置与实际显示的 Label 属性一致 采用 NSMutableParagraphStyle 设置Nib 中 Label 的相关属性传入到 NSAttributeString 中计算；
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    
    NSAttributedString *useString = [[NSAttributedString alloc]initWithString:string attributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:style}];
    
    CGSize size =  [useString boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    //NSLog(@" size =  %@", NSStringFromCGSize(size));
    
    //计算出来的数据是小数，在应用到布局的时候稍微差一点点就不能保证按照计算时那样排列，所以为了确保布局按照我们计算的数据来，就在原来计算的基础上 取ceil值，再加1；
    CGFloat height = ceil(size.height) + 1;
    
    return height;
}

+ (float)getWidthForString:(NSString *)string font:(UIFont *)font height:(float)height
{
    if(string && [string compare:@""] != NSOrderedSame) return 0.0;
    
    //段落设置与实际显示的 Label 属性一致 采用 NSMutableParagraphStyle 设置Nib 中 Label 的相关属性传入到 NSAttributeString 中计算；
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    
    NSAttributedString *useString = [[NSAttributedString alloc]initWithString:string attributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:style}];
    
    CGSize size =  [useString boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    //NSLog(@" size =  %@", NSStringFromCGSize(size));
    
    //计算出来的数据是小数，在应用到布局的时候稍微差一点点就不能保证按照计算时那样排列，所以为了确保布局按照我们计算的数据来，就在原来计算的基础上 取ceil值，再加1；
    CGFloat width = ceil(size.width) + 1;
    
    return width;
}

+ (NSInteger)getLinesForString:(NSString *)string font:(UIFont *)font width:(float)width
{	
	if(!string) return 0;
	if([string compare:@""] == NSOrderedSame) return 1;
    
    NSArray *linesArray = [self getLinesArrayOfStringInLabel:string font:font andLableWidth:width];
    
    NSInteger lines = 0;
    if(linesArray)
    {
        lines = [linesArray count];
    }
    
    return lines;
}

+ (NSArray*)getLinesArrayOfStringInLabel:(NSString *)string font:(UIFont *)font andLableWidth:(CGFloat)lableWidth
{
    //* 返回结果即为包含每行文字的数组，行数即为count数
    //* 该方法主要是预先的计算出文本在UIlable等控件中的显示情况，从而进行一些其它的后续操作。
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge  id)myFont range:NSMakeRange(0, attStr.length)];
    CFRelease(myFont);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,lableWidth,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge  CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [string substringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithInt:0.0]));
        [linesArray addObject:lineString];
    }
    
    CGPathRelease(path);
    CFRelease( frame );
    CFRelease(frameSetter);
    return (NSArray *)linesArray;
}




+ (UIColor *)colorFromHexString:(NSString *)hexString 
{
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


+ (BOOL)checkStringValid:(NSString *)string
{
    if(!string) return NO;
    if(![string isKindOfClass:[NSString class]]) return NO;
    if([string compare:@""] == NSOrderedSame) return NO;
    if([string compare:@"(null)"] == NSOrderedSame) return NO;
    
    return YES;
}

+ (BOOL)checkArrayValid:(NSArray *)array
{
    if(!array) return NO;
    if(![array isKindOfClass:[NSArray class]]) return NO;
    if([array count] == 0) return NO;
    
    return YES;
}
+ (BOOL)checkDictionaryValid:(NSDictionary *)dictionary
{
    if(!dictionary) return NO;
    if(![dictionary isKindOfClass:[NSDictionary class]]) return NO;
    if([dictionary count] == 0) return NO;
    
    return YES;
}

+ (BOOL)checkInArrayOfIndex:(NSInteger)index ofArray:(NSArray *)array
{
    if(!array) return NO;
    if([array count] == 0) return NO;
    
    if(index < 0) return NO;
    if(index > [array count]-1) return NO;
    
    return YES;
}


+ (NSString *)getDeviceType
{
	// Device Name:
	// iPone1,2 = 3G iPhone
	// iPhone2,1 = 3GS iPhone
	// iPod1,2 = 1st gen iPod
	// iPod2,1 = 2nd gen iPod
	// iPad... = iPad
	// i386 = simulator
	// iPod5 = iPod5,1
    // iPhone4s = iPhone4,1
    // iPhone4  = iPhone3,1
	
	size_t size;
	
	// Set 'oldp' parameter to NULL to get the size of the data
	// returned so we can allocate appropriate amount of space
	sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
	
	// Allocate the space to store name
	char *name = (char*) malloc(size);
	
	// Get the platform name
	sysctlbyname("hw.machine", name, &size, NULL, 0);
	
	// Place name into a string
	NSString *machine = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
	
	// Done with this
	free(name);
	
	return machine;
}

+ (void)addLineToLabel:(UILabel*)label useColor:(UIColor*)color
{
    if(!label || ![RDFunction checkStringValid:label.text]) return;
    
    float lwidth = [self getWidthForString:label.text font:label.font height:label.frame.size.height];
    CGRect lframe = label.frame;
    lframe.size.width = lwidth;
    label.frame = lframe;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(-3, lframe.size.height/2, lframe.size.width+6, 1)];
    line.backgroundColor = color;
    [label addSubview:line];
}

+ (void)addLineToViewTop:(UIView*)view useColor:(UIColor*)color
{
    if(!view) return;
    if(!color) return;
    
    //给一个view加上 上划线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), 0.5)];
    line.backgroundColor = color;
    [view addSubview:line];
}

+ (void)addLineToViewBottom:(UIView*)view useColor:(UIColor*)color
{
    if(!view) return;
    if(!color) return;
    
    //给一个view加上 下划线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame)-0.5, CGRectGetWidth(view.frame), 0.5)];
    line.backgroundColor = color;
    [view addSubview:line];
}


+ (BOOL)checkIsIPad
{
    BOOL isIPad = NO;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        isIPad = YES;
    }
    
    return isIPad;
}

+ (UIImageView*)createBlurView:(UIView*)view
{
    CGRect rect = view.bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        [view drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    }
    else
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [view.layer renderInContext:ctx];
    }
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        img=[img applyBlurWithRadius:5.0f tintColor:[UIColor colorWithWhite:1.0 alpha:0.3] saturationDeltaFactor:1.8 maskImage:nil];
    }
    
    UIImageView *blurView = [[UIImageView alloc] init];
    blurView.userInteractionEnabled=YES;
    blurView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
    blurView.alpha = 1.0f;
    
    blurView.image = img;
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        UIView *fadeView = [[UIView alloc] init];
        fadeView.frame = [UIScreen mainScreen].bounds;
        fadeView.backgroundColor = [UIColor whiteColor];
        fadeView.alpha = 0.8f;
        [blurView addSubview:fadeView];
    }
    
    return blurView;
}

+ (void)addRadiusToView:(UIView*)view radius:(float)radius
{
    if(!view) return;
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}

+ (void)addBorderToView:(UIView*)view color:(UIColor*)color lineWidth:(float)lineWidth
{
    if(!view) return;
    if(!color) return;
        
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = lineWidth;
}

+ (void)ActionAfterDelay:(NSTimeInterval)delay action:(void (^)(void))completion
{
    double delayInSeconds = delay;  
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));  
    dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){  
        
        if(completion)
        {
            completion();
        }
    }); 
}

+ (double)randomFrom:(double)numMin to:(double)numMax
{
    if(numMin == numMax) return numMin;
    
    int startVal = numMin*10000;
    int endVal = numMax*10000; 
    
    int minVal = startVal;
    if(endVal < minVal) minVal = endVal;
     
    int randomValue = minVal + (arc4random()%ABS(endVal - startVal));
    double a = randomValue;
    
    return(a/10000.0);
}

+ (void)changeHeightForView:(UIView *)view to:(float)toHeight
{
    if(!view) return;
    
    CGRect nframe = view.frame;
    nframe.size.height = toHeight;
    view.frame = nframe;
}

+ (NSString *)md5FormString:(NSString *)string 
{
    if(!string || [string isEqualToString:@""]) return nil;
    
    const char *cStr =[string UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (int)strlen(cStr), result);
    return [NSString stringWithFormat:
           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
           result[0], result[1], result[2], result[3],
           result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11],
           result[12], result[13], result[14], result[15]
           ];
}


#pragma mark -
#pragma mark 时间解析相关
+ (NSDate*)dateFromString:(NSString*)dateString useFormat:(NSString*)format
{
    if(!dateString || [dateString isEqualToString:@""]) return nil;
    if(!format || [format isEqualToString:@""]) return nil;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [formatter setDateFormat:format];
    
    NSDate* adate = [formatter dateFromString:dateString];
    
    return adate;
}

+ (NSString*)stringFromDate:(NSDate*)date useFormat:(NSString*)format
{
    //转化为要显示的时间格式如：@"MM-dd HH:mm"
    if(!date) return nil;
    if(!format || [format isEqualToString:@""]) return nil;
    
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone defaultTimeZone]];
	[formatter setDateFormat:format];
    
	NSString *dateString = [formatter stringFromDate:date];
	
	return dateString;
}

#pragma mark -
#pragma mark 系统版本
+ (BOOL)isiOS7orLater
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
    {
        return YES;
    }
    return NO;
}





@end
