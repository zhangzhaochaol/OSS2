//
//  Inc_KP_Config.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/5/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_KP_Config.h"

@implementation Inc_KP_Config


+ (Inc_KP_Config*)sharedInstanced{
    static Inc_KP_Config *_sharedInstanced = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstanced = [[Inc_KP_Config alloc] init];
    });
    return _sharedInstanced;
}

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}



/**
 时间转字符串   nsdate --- nsstring
 */
- (NSString *)getDate:(NSDate *)data  andFormatter:(NSString *)format{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:data]];
}

/**
 时间戳字符串   nsinteger --- nsstring
 */
- (NSString *)getTime:(NSInteger)time  andFormatter:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
       [formatter setDateStyle:NSDateFormatterMediumStyle];
       [formatter setTimeStyle:NSDateFormatterShortStyle];
       [formatter setDateFormat:format];
       NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
       [formatter setTimeZone:timeZone];
       
       NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
       
       NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    return confromTimespStr;
}


/**
 增加min分钟  symbol 1 增加   -1 减少
 */
- (NSString *)addTime:(NSString *)dateStr symbol:(int)symbol min:(int)min{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
   
    NSTimeInterval  interval =min*60*symbol; //15分钟
    NSDate *inputDate = [dateFormatter dateFromString:dateStr];

    NSDate*date1 =  [inputDate initWithTimeInterval:interval sinceDate:inputDate];
    
    NSString *strDate = [dateFormatter stringFromDate:date1];

    
    return strDate;
}


/**
 转时间戳
 */
-(NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format

{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateStyle:NSDateFormatterMediumStyle];

    [formatter setTimeStyle:NSDateFormatterShortStyle];

    [formatter setDateFormat:format];

    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];

    [formatter setTimeZone:timeZone];

    //将字符串按formatter转成nsdate

    NSDate* date = [formatter dateFromString:formatTime];

    //时间转时间戳的方法:

    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];

    NSLog(@"将某个时间转化成 时间戳&&&&&&&timeSp:%ld",(long)timeSp); //时间戳的值

    return timeSp;

}




/**
 计算两个时间相差   返回多少秒
 */
- (NSTimeInterval)pleaseInsertStarTime:(NSString *)starTime andInsertEndTime:(NSString *)endTime{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"HH:mm:ss"];//根据自己的需求定义格式
    NSDate* startDate = [formater dateFromString:starTime];
    NSDate* endDate = [formater dateFromString:endTime];
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    return time;
}


/**
 两个时间比较
 */
-(int)compareDateTime:(NSString*)date01 withDate:(NSString*)date02 andFormat:(NSString *)format{
    

    NSDateFormatter*df = [[NSDateFormatter alloc]init];
    
    [df setDateFormat:format];
    
    NSDate*dt1 = [[NSDate alloc]init];
    
    NSDate*dt2 = [[NSDate alloc]init];
    
    dt1 = [df dateFromString:date01];
    
    dt2 = [df dateFromString:date02];
    
    NSComparisonResult result = [dt1 compare:dt2];
    
    if (result == NSOrderedDescending) {
        //在指定时间前面 过了指定时间 过期
        NSLog(@"oneDay  is in the future");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //没过指定时间 没过期
        //NSLog(@"Date1 is in the past");
        return -1;
    }
    //刚好时间一样.
    //NSLog(@"Both dates are the same");
    return 0;
}


/**
 *  判断当前时间是否处于某个时间段内
 *  时分秒
 *  @param startTime        开始时间
 *  @param expireTime       结束时间
 */

- (BOOL)validateWithStartTime:(NSString *)startTime withExpireTime:(NSString *)expireTime nowTIme:(NSString *)nowTime{
//    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    // 时间格式,此处遇到过坑,建议时间HH大写,手机24小时进制和12小时禁止都可以完美格式化
    [dateFormat setDateFormat:@"HH:mm:ss"];
    
    NSDate *start = [dateFormat dateFromString:startTime];
    NSDate *expire = [dateFormat dateFromString:expireTime];
    NSDate *today = [dateFormat dateFromString:nowTime];
    
    if ([today compare:start] == NSOrderedDescending && [today compare:expire] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}



/**
 日期比较   年月日
 */
- (int)compareOneDay:(NSString *)current withAnotherDay:(NSString *)endDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *dateA = [dateFormatter dateFromString:current];
    NSDate *dateB = [dateFormatter dateFromString:endDay];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"oneDay : %@, anotherDay : %@", current, endDay);
    if (result == NSOrderedDescending) {
        //在指定时间前面 过了指定时间 过期
        NSLog(@"oneDay  is in the future");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //没过指定时间 没过期
        //NSLog(@"Date1 is in the past");
        return -1;
    }
    //刚好时间一样.
    //NSLog(@"Both dates are the same");
    return 0;
    
}



/**判断两个日期的大小

 *date01 : 第一个日期

 *date02 : 第二个日期

 *format : 日期格式 如：@"yyyy-MM-dd HH:mm"

 *return : 0（等于）1（大于）-1（小于）

 */

- (int)compareDate:(NSString*)date01 withDate:(NSString*)date02 toDateFormat:(NSString*)format{
    
    int num;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    [df setDateFormat:format];
    
    NSDate*dt01 = [[NSDate alloc]init];
    
    NSDate*dt02 = [[NSDate alloc]init];
    
    dt01 = [df dateFromString:date01];
    
    dt02 = [df dateFromString:date02];
    
    NSComparisonResult result = [dt01 compare:dt02];
    
    switch(result){
        case NSOrderedAscending: num=1;break;
            
        case NSOrderedDescending: num=-1;break;
            
        case NSOrderedSame: num=0;break;
            
        default:NSLog(@"erorr dates %@, %@", dt02, dt01);break;
            
    }
    
    return num;
}

// 获取当前时间时周几
- (NSString*)weekdayStringFromDate:(NSString*)inputDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    NSDate *nowDate = [dateFormatter dateFromString:inputDate];

    
    NSArray *weekdays = [NSArray arrayWithObjects: @"", @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:nowDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
}

//添加虚线边框
-(void)addDottedBorderWithView:(UIView*)view color:(UIColor *)color{
    CGFloat viewWidth = view.width;
    CGFloat viewHeight = view.height;
    view.layer.cornerRadius = 0;
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.bounds = CGRectMake(0, 0, viewWidth, viewHeight);
    borderLayer.position = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:1].CGPath;
    borderLayer.lineWidth = 1.5 / [[UIScreen mainScreen] scale];
    borderLayer.lineDashPattern = @[@4, @4];
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = color.CGColor;
    [view.layer addSublayer:borderLayer];
}


+ (void)Zhang_ContentSizeToFit:(UITextView *)textView textViewHeight:(CGFloat)textViewHeight
{
    //先判断一下有没有文字（没文字就没必要设置居中了）
    if([textView.text length]>0)
    {
        //textView的contentSize属性
        CGSize contentSize = textView.contentSize;
        //textView的内边距属性
        UIEdgeInsets offset;
        CGSize newSize = contentSize;
        //解决约束textView.frame.size.height起始为0时；需要默认textViewHeight；否则无法实现居中显示
        if (textViewHeight == 0) {
            textViewHeight = textView.frame.size.height;
        }
        //如果文字内容高度没有超过textView的高度
        if(contentSize.height <= textViewHeight)
        {
            //textView的高度减去文字高度除以2就是Y方向的偏移量，也就是textView的上内边距
            CGFloat offsetY = (textViewHeight - contentSize.height)/2;
            offset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
        }
        else          //如果文字高度超出textView的高度
        {
            newSize = textView.frame.size;
            offset = UIEdgeInsetsZero;
//            CGFloat fontSize = 14;
           //通过一个while循环，设置textView的文字大小，使内容不超过整个textView的高度（这个根据需要可以自己设置）
//            while (contentSize.height > textView.frame.size.height)
//            {
//                [textView setFont:[UIFont systemFontOfSize:fontSize]];
//                contentSize = textView.contentSize;
//            }
            newSize = contentSize;
        }
        
        //根据前面计算设置textView的ContentSize和Y方向偏移量
        [textView setContentSize:newSize];
        [textView setContentInset:offset];
        
    }
}






// 64base字符串转图片

- (UIImage *)stringToImage:(NSString *)str {
    
    NSData * imageData =[[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    UIImage *photo = [UIImage imageWithData:imageData ];
    
    return photo;
    
}

// 图片转64base字符串

- (NSString *)imageToString:(UIImage *)image {
    
    NSData *imagedata = UIImagePNGRepresentation(image);
    
    NSString *image64 = [imagedata base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return image64;
    
}



-(void)setUpNavBarBackImage:(UIImage *)image nav:(UINavigationController *)nav {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        appearance.backgroundImage = image;
        appearance.shadowColor = UIColor.clearColor;
        //设置导航条标题颜色
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setValue:UIColor.whiteColor forKey:NSForegroundColorAttributeName];
        appearance.titleTextAttributes = attributes;
        
        nav.navigationBar.standardAppearance = appearance;
        nav.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        image = [image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
        [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
}

-(void)cancelUpNavBarBackImage:(UINavigationController *)nav  {
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        appearance.backgroundImage = [UIImage Inc_imageNamed:@""];
        [appearance configureWithOpaqueBackground];
        //设置导航条背景色
        appearance.backgroundColor = [UIColor colorWithHexString:@"#666"];
        appearance.shadowColor = UIColor.clearColor;
        //设置导航条标题颜色
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setValue:UIColor.whiteColor forKey:NSForegroundColorAttributeName];
        appearance.titleTextAttributes = attributes;

        nav.navigationBar.standardAppearance = appearance;
        nav.navigationBar.scrollEdgeAppearance = appearance;
        
    } else {
        [nav.navigationBar setBackgroundImage:[UIImage Inc_imageNamed:@""] forBarMetrics:UIBarMetricsDefault];

    }
    
}
@end
