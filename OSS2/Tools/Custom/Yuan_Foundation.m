//
//  Yuan_Foundation.m
//  INCP&EManager
//
//  Created by 袁全 on 2020/4/13.
//  Copyright © 2020 Unigame.space. All rights reserved.
//

#import "Yuan_Foundation.h"

#include <sys/types.h>
#include <sys/sysctl.h>

#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation Yuan_Foundation

/**
 
 H5传的url 是否带“？”  不带NO  带YES
 */
+ (BOOL)doseUrlByH5Bool:(NSString *)url{

    if ([url rangeOfString:@"?"].location == NSNotFound) {
        // 不带“？”拼接“？”
        return YES;
    }else{
        // 带“？”  需要&
        return NO;
    }
}

+ (NSString *)currentSecond {
    NSDate * date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr;
    
}


/**
 *  获取当天的日期  eg: 2016-08-31
 */
+ (NSString *)currentDate{

    NSDate * date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr;
}


/// 年月日 时分秒 现在
+ (NSString *)currentDate_Time{

    NSDate * date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr;
}



+ (NSString *)currentMonth{
    NSDate * date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr;
}

+ (NSString *)currentYear {
    NSDate * date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr;
}



+(NSDate *) currentDateFromString:(NSString *)currentDate{
//    currentDate : @"yyyy-MM-dd HH:mm:ss"
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:currentDate];
    return date;
}


+(NSDate *) currentDateFromString:(NSString *)Date
                      dateFormate:(NSString *)formate{
//    currentDate : @"yyyy-MM-dd HH:mm:ss"
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formate];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    NSDate *date = [dateFormatter dateFromString:Date];
    return date;
}


/// 根据 date 返回 yyyy-mm-dd 格式的日期字符串
/// @param date date
+ (NSString *) stringFromDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr;
    

}



/**
 *  获取当天的星期
 */
+ (NSString*)weekdayStringFromDate{
    NSDate * date = [NSDate date];
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:date];
    
    return [weekdays objectAtIndex:theComponents.weekday];
}



/**
 *  获取 @"yyyy-MM-dd" 对应的星期几
 *
 *  @param currentDate @"yyyy-MM-dd" 字符串
 *
 *  @return weekDay
 */
+ (NSString *)weekdayStringFromDateString:(NSString *)currentDate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *date = [dateFormatter dateFromString:currentDate];
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:date];
    
    return [weekdays objectAtIndex:theComponents.weekday];
}


/*
    只获取字符串中的数字
 */

+ (NSString *)GetOnlyNumberString:(NSString *)string {
    
    NSString *pureNumbers = [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    return pureNumbers;
}

/**
 *  截取字符串后几位
 *
 *  @param tobeProcessed 待处理的字符串
 *  @param position      截取几位
 *
 *  @return 截取后的字符串
 */

+(NSString *)interceptionLastFew:(NSString *)tobeProcessed interceptionPosition:(int)position{

    return [tobeProcessed substringFromIndex:tobeProcessed.length - position];
}


//截取字符串前几位
+ (NSString *)interceptionFirstFew:(NSString *)tobeProcessed interceptionPosition:(int)position{

    return [tobeProcessed substringToIndex:position];
}



+ (NSString *)removeLastNumberChar:(int)number String:(NSString *)string {

    [string substringToIndex:[string length] - number];
    
    return string;
}


-(BOOL)judgeObject:(id)object isKindOfClass:(NSString *)type{

    return [object isKindOfClass:[NSClassFromString(type) class]];
}



/**
 *  字典转JSON字符串
 *
 *  @param dic 字典
 *
 *  @return JSON字符串
 */
+ (NSString*)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}



/**
 *  JSON转字典
 *
 *  @param jsonString JSON字符串
 *
 *  @return 字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
        
        
    }
    
    
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    return dic;
}





+(NSString *)stringBackMacAddressWithString:(NSString *)macAddress{
    
    if (macAddress.length < 7) {
        return nil;
    }
    
    
    if ([macAddress rangeOfString:@":"].location !=NSNotFound) {
        return macAddress;
    }
    else{
    
        NSMutableString * string = [[NSMutableString alloc] initWithString:macAddress];
        
        [string insertString:@":" atIndex:2];
        [string insertString:@":" atIndex:5];
        [string insertString:@":" atIndex:8];
        [string insertString:@":" atIndex:11];
        [string insertString:@":" atIndex:14];
        
        return string;
    
    }

}



+ (NSString *)getCurrentDeviceModel
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([platform isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"])   return @"国行(A1863)、日行(A1906)iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"])   return @"美版(Global/A1905)iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"])   return @"国行(A1864)、日行(A1898)iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"])   return @"美版(Global/A1897)iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"])   return @"国行(A1865)、日行(A1902)iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"])   return @"美版(Global/A1901)iPhone X";
    if ([platform isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([platform isEqualToString:@"iPad6,11"])    return @"iPad 5 (WiFi)";
    if ([platform isEqualToString:@"iPad6,12"])    return @"iPad 5 (Cellular)";
    if ([platform isEqualToString:@"iPad7,1"])     return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    if ([platform isEqualToString:@"iPad7,2"])     return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    if ([platform isEqualToString:@"iPad7,3"])     return @"iPad Pro 10.5 inch (WiFi)";
    if ([platform isEqualToString:@"iPad7,4"])     return @"iPad Pro 10.5 inch (Cellular)";
    if ([platform isEqualToString:@"iPad7,5"])     return @"iPad 6th generation";
    if ([platform isEqualToString:@"iPad7,6"])     return @"iPad 6th generation";
    if ([platform isEqualToString:@"iPad8,1"])     return @"iPad Pro (11-inch)";
    if ([platform isEqualToString:@"iPad8,2"])     return @"iPad Pro (11-inch)";
    if ([platform isEqualToString:@"iPad8,3"])     return @"iPad Pro (11-inch)";
    if ([platform isEqualToString:@"iPad8,4"])     return @"iPad Pro (11-inch)";
    if ([platform isEqualToString:@"iPad8,5"])     return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([platform isEqualToString:@"iPad8,6"])     return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([platform isEqualToString:@"iPad8,7"])     return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([platform isEqualToString:@"iPad8,8"])     return @"iPad Pro (12.9-inch) (3rd generation)";
    
    
    if ([platform isEqualToString:@"AppleTV2,1"])    return @"Apple TV 2";
    if ([platform isEqualToString:@"AppleTV3,1"])    return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])    return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV5,3"])    return @"Apple TV 4";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";

    return platform;
}

// 当前毫秒数
+ (NSString*)_TStr {
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *sendtime = [NSString stringWithFormat:@"%llu", recordTime];
    return sendtime;
}





+ (NSInteger)numberOfDaysWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents    * comp = [calendar components:NSCalendarUnitDay
                                             fromDate:fromDate
                                               toDate:toDate
                                              options:NSCalendarWrapComponents];
    return (comp.day+1);
}




#pragma mark - 时间比较大小

+ (NSTimeInterval)pleaseInsertStarTime:(NSString *)starTime
                      andInsertEndTime:(NSString *)endTime{
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //根据自己的需求定义格式
    
    NSDate* startDate = [formater dateFromString:starTime];
    NSDate* endDate = [formater dateFromString:endTime];
    
    // 首先 判断谁大
    
    
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    
    BOOL compare = [Yuan_Foundation compareDate:startDate withDate:endDate];
    
    if (compare) {
        // 结束时间 大于 开始时间        (未过期)
        return time;
    }else {
        // 结束时间等于 / 小于 开始时间   (过期)
        return -time;
    }
    
    
    
    return 0;
}


//比较两个日期的大小
+ (BOOL)compareDate:(NSDate*)stary withDate:(NSDate*)end
{
    NSComparisonResult result = [stary compare: end];
      if (result==NSOrderedSame)
    {
        //相等
        return NO;
    }else if ((result=NSOrderedAscending))
    {
       //结束时间大于开始时间
        return YES;
    }else if ((result=NSOrderedDescending))
    {
        //结束时间小于开始时间
        return NO;
    }
    return NO;
}


+ (NSString *) getNumberFromString :(NSString *)str {
    
    
    if (!str || [str isEqualToString:@""] || [str isEqual:[NSNull null]]) {
        return @"";
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet]
                            intoString:nil];
    
    int number;

    [scanner scanInt:&number];

    NSString *num=[NSString stringWithFormat:@"%d",number];

    return num;
    
}





/// 四舍五入 或 去掉小数点  NSRoundPlain 根据这个判断
/// @param price 你的小数值
/// @param position 小数点后几位有效
+ (NSString *)notRounding:(float)price afterPoint:(int)position{
    
    NSDecimalNumberHandler* roundingBehavior =
    [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    return [NSString stringWithFormat:@"%@",roundedOunces];
}


+ (NSString *) fromInt:(int)value {

    return [NSString stringWithFormat:@"%d",value];
}



+ (NSString *) fromInteger:(NSInteger)value {
    
    return [NSString stringWithFormat:@"%ld",value];
    
}



+ (NSString *) fromFloat:(float)value {
    
    return [NSString stringWithFormat:@"%f",value];
}


+ (NSString *) fromObject:(id)value {
    
    if (!value) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"%@",value];
    
}


/// 判断字符串是否为纯数字
+ (BOOL)isNumber:(NSString *)strValue
{
    if (strValue == nil || [strValue length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSString *filtered = [[strValue componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![strValue isEqualToString:filtered])
    {
        return NO;
    }
    return YES;
}


// 构建dict的返回值类型  避免崩溃
id DictValue (id value) {
    
    if (value && ![value isEqual:[NSNull null]]) {
        return [NSString stringWithFormat:@"%@", value];
    }
    
    
    if (value == nil  ||
        [value isEqual:[NSNull null]] ||
        [value isEqualToString:@"(null)"]) {
        
        return @"";
    }
    
    
    return @"";
}



+ (NSString *)getIpAddress{
    
      NSString *address = @"Not Found";
      struct ifaddrs *interfaces = NULL;
      struct ifaddrs *temp_addr = NULL;
      int success = 0;
      success = getifaddrs(&interfaces);
      if (success == 0) {
          temp_addr = interfaces;
          while(temp_addr != NULL) {
              if(temp_addr->ifa_addr->sa_family == AF_INET) {
                  if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                      address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                  }
              }
              temp_addr = temp_addr->ifa_next;
          }
      }
      freeifaddrs(interfaces);
      return address;
}





/// 新增的C语言函数 -- 任意类型的字符串包装
NSString * StringObject (id obj) {
    return [NSString stringWithFormat:@"%@",obj];
}


NSString * StringInt (int obj) {
    return [NSString stringWithFormat:@"%d",obj];
}

NSString * StringInteger (NSInteger obj) {
    return [NSString stringWithFormat:@"%ld",obj];
}


NSString * StringDouble (double obj) {
    return [NSString stringWithFormat:@"%lf",obj];
}



@end
