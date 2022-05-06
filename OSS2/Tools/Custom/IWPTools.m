//
//  IWPTools.m
//  CUOSS2.5
//
//  Created by 王旭焜 on 2016/8/7.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPTools.h"
#import "sys/utsname.h"
#import <CommonCrypto/CommonDigest.h>
//static NSString * _object_JSON_lasError = @"";
@class YKLAboutViewController;
//@implementation NSObject (IWPTool)
//-(id).object{
//    NSData * data = nil;
//
//    if ([self isKindOfClass:[NSString class]]) {
//        data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
//    }else if ([self isKindOfClass:[NSData class]]){
//        data = (NSData *)self;
//    }else{
//
//
//        NSString * error = [NSString stringWithFormat:@"JSON - 错误的数据类型：%@", self];
////        _object_JSON_lasError = error;
//        NSLog(@"%@", error);
//
//        return nil;
//    }
//
//    if (data) {
//
//        NSError * error = nil;
//
//        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//
//        if (error == nil) {
//            return obj;
//        }else{
//
////            _object_JSON_lasError = error.localizedDescription;
//            return @{@"error":error.localizedDescription};
//        }
//
//    }else{
////        _object_JSON_lasError = [NSString stringWithFormat:@"JSON - 错误的数据类型：%@", self];
//        return @{@"error":[NSString stringWithFormat:@"JSON - 错误的数据类型：%@", self]};
//    }
//}
//-(NSString *)json{
//    if ([NSJSONSerialization isValidJSONObject:self]) {
//
//        NSError * error = nil;
//
//        NSJSONWritingOptions options = NSJSONWritingPrettyPrinted;
//        if (@available(ios 11, *)) {
//            options = NSJSONWritingSortedKeys;
//        }
//
//
//        NSData * data = [NSJSONSerialization dataWithJSONObject:self options:options error:&error];
//
//        if (error == nil) {
//
//            NSString * json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//            return json;
//        }else{
//
////            _object_JSON_lasError = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"{\"error\":\"%@\"}", error.localizedDescription]];
//
//            return [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"{\"error\":\"%@\"}", error.localizedDescription]];
//
//        }
//
//    }else{
////        _object_JSON_lasError = [NSString stringWithFormat:@"JSON - 错误的数据类型：%@", self];
//        return [NSString stringWithFormat:@"{\"error\":\"错误的数据格式：%@\"}", self];
//    }
//}
//-(NSString *)JSON_lastError{
//    return @"";
//}
//@end

#pragma mark - NSDate延展
@implementation NSDate (IWPDate)

-(NSString *)dateToTimeInterval{
    return [NSString stringWithFormat:@"%ld",(long)[self timeIntervalSince1970]];
}
-(NSString *)GMTToLocalWithAMPM{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss a"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *strDate = [dateFormatter stringFromDate:self];
    
    return strDate;
}
-(NSString *)GMTToLocal{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *strDate = [dateFormatter stringFromDate:self];
    
    return strDate;
}
-(NSString *)localToGMT{

    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    
    NSString *strDate = [dateFormatter stringFromDate:self];
    
    NSLog(@"%@", strDate);
    return strDate;
}

- (NSString *)dateToStringWithoutTime{
    
    
    NSLog(@"%@", self);
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *strDate = [dateFormatter stringFromDate:self];
    
    return strDate;
    
}

-(NSString *)LocalToGMTWithSecond{
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    
    NSString *strDate = [dateFormatter stringFromDate:self];
    
    NSLog(@"%@", strDate);
    return strDate;
    
}
-(NSString *)GMTTolocalWithSecond{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *strDate = [dateFormatter stringFromDate:self];
    
    return strDate;
}

-(NSInteger)secound{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitSecond;
    comps = [calendar components:unitFlags fromDate:self];
    return [comps second];
    
}

-(NSInteger)minute{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitMinute;
    comps = [calendar components:unitFlags fromDate:self];
    
    return [comps minute];
}

-(NSInteger)hour{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitHour;
    comps = [calendar components:unitFlags fromDate:self];
    
    return [comps hour];
}

-(NSInteger)day{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];//设置成中国阳历
    NSInteger unitFlags = NSCalendarUnitDay;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self];
    NSLog(@"%@", self);
    
    
    return [comps day];
}

-(NSInteger)month{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitMonth;
    comps = [calendar components:unitFlags fromDate:self];
    
    return [comps month];
}

-(NSInteger)year{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear;
    comps = [calendar components:unitFlags fromDate:self];
    NSLog(@"%@", [comps year]);
    return [comps year];
}

-(NSInteger)weekDay{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitWeekday;
    comps = [calendar components:unitFlags fromDate:self];
    
    return [comps weekday];
}


-(NSDateComponents *)compents{
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    
    
    NSCalendarUnit unit = NSCalendarUnitYear |
    NSCalendarUnitMonth |
    NSCalendarUnitDay |
    NSCalendarUnitHour |
    NSCalendarUnitMinute |
    NSCalendarUnitSecond;
    
    comps = [calendar components:unit fromDate:self];
    
    return comps;
}


-(NSDate *)setSecound:(NSInteger)secound{
    
    if (secound > 59 || secound < 0) {
        
        return self;
        
    }
    
    NSDateComponents * comps = [self compents];
    
    
    [comps setSecond:secound];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    return [gregorian dateFromComponents:comps];
    
    
}

-(NSDate *)setMinute:(NSInteger)minute{

    if (minute > 59 || minute < 0) {
        
        return self;
        
    }
    
    NSDateComponents * comps = [self compents];
    
    
    [comps setMinute:minute];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    return [gregorian dateFromComponents:comps];
    
    
}

-(NSDate *)setHour:(NSInteger)hour{
 
    if (hour > 24 || hour < 0) {
        
        return self;
        
    }
    
    NSDateComponents * comps = [self compents];
    
    [comps setHour:hour];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    return [gregorian dateFromComponents:comps];
    
}

- (BOOL)isLeapYear{
    
    return [NSDate isLeapYear:self.year];
    
}

+ (BOOL)isLeapYear:(NSInteger)year{
  
    return (year % 4  == 0 && year % 100 != 0)  || year % 400 == 0;
    
}

-(NSDate *)setDay:(NSInteger)day{
    
    if (day > 0) {
        
        NSInteger month = self.month;
        
        // 大月，日不大于31
        if (month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12) {
            
            if (day > 31) {
                return self;
            }
            
        } // 小月，日不大于30
        else if (month == 4 || month == 6 || month == 9 || month == 11){
            
            if (day > 30) {
                return self;
            }
            
        }
        else{
            // 二月，需要判断是否为闰年
            
            if ([self isLeapYear]) {
                
                if (day > 29) {
                    return self;
                }
                
            }else{
                
                if (day > 28) {
                    return self;
                }
                
            }

        }
        
    }
    
    NSDateComponents * comps = [self compents];
    
    
    [comps setDay:day];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    return [gregorian dateFromComponents:comps];
    
}

-(NSDate *)setMonth:(NSInteger)month{
    
    NSDate * ret = self;
    
    // 要设置的月份为这些时，需要重置日为最大值；
    
    if (month > 0 && month < 13) {
        
        // 如：2017-3-31 当设置月份为4时，需要将31 改成30；
        if ((month == 4 || month == 6 || month == 9 || month == 11)) {
            
            // 小月，若当前日大于30，重置为30
            
            if (ret.day > 30) {
                
                ret = [ret setDay:30];
                
            }
            
            
            
        }else if (month == 2){
            
            if (ret.day > 28 || ret.day > 29) {
                
                if ([self isLeapYear]) {
                    
                    ret = [ret setDay:29];
                    
                }else{
                    
                    ret = [ret setDay:28];
                    
                }
                
            }
            
        }
        
    }
    
    
    
    
    NSDateComponents * comps = [ret compents];
    
    
    [comps setMonth:month];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    return [gregorian dateFromComponents:comps];
    
}

-(NSDate *)setYear:(NSInteger)year{
 
    
    NSDate * ret = self;
    
    
    if ([ret isLeapYear] && ![NSDate isLeapYear:year] && ret.month == 2 ) {
        
        if (ret.day > 28) {
            
             ret = [ret setDay:28];
            
        }
        
        
    }
    
    
    NSDateComponents * comps = [ret compents];
    
    [comps setYear:year];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    return [gregorian dateFromComponents:comps];
    
}



@end
#pragma mark - NSString延展
@implementation NSString (IWPString)

-(BOOL)isEmptyString{
    if (!self) {
        return YES;
    }
    if ([self isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!self.length) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [self stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}

-(BOOL)isNumber{
    
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < self.length) {
        NSString * string = [self substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

-(BOOL)isEnglishChar{
    
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];
    int i = 0;
    while (i < self.length) {
        NSString * string = [[self substringWithRange:NSMakeRange(i, 1)] lowercaseString];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
    
}

+ (instancetype)stringWithData_V2:(NSData *)data{
    return [NSString stringWithData_V2:data encoding:NSUTF8StringEncoding];
}
+ (instancetype)stringWithData_V2:(NSData *)data encoding:(NSStringEncoding)encoding{
    return [[NSString alloc] initWithData:data encoding:encoding];
}

//+(NSString *)idKeyWithFileName:(NSString *)fileName{
//
//    return [NSString stringWithFormat:@"%@Id", fileName];
//
//}

-(NSString *)makeIdkey{
    
    return [NSString stringWithFormat:@"%@Id", self];
    
}

-(NSString *)makeMD5{
//    const char *myPasswd = [self UTF8String];
//    
//    unsigned char mdc[16];
//    
//    CC_MD5 (myPasswd, (CC_LONG)strlen(myPasswd), mdc);
//    
//    NSMutableString * md5String = [NSMutableString string];
//    
//    for ( int i = 0 ; i < 16 ; i++) {
//        [md5String appendFormat:@"%02x" ,mdc[i]];
//    }
//    
//    NSRange range = NSMakeRange(8,16);
//    
//    NSString* newStr = [md5String substringWithRange:range];
//    
//    // return newStr; // 加密后
    return self; // 不加密
}
-(NSString *)GMTToLocal{
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    
    NSDate *inDate=[dateFormatter dateFromString:self];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *strDate = [dateFormatter stringFromDate:inDate];
    
    return strDate;
}
-(NSNumber *)charValue{
    NSLog(@"%s -- %@", __func__, self);
    return [NSNumber numberWithBool:self.boolValue];
}
-(BOOL)isEqualToAnyString:(NSString *)string, ...NS_REQUIRES_NIL_TERMINATION{
    
    if ([self isEqualToString:string]) {
        return TRUE;
    }
    
    va_list args;
    va_start(args, string);
    if (string)
    {
        
        
        
        NSString * otherString = nil;
        
        do {
            otherString = va_arg(args,id);
            
            
            
            if ([self isEqualToString:otherString]) {
                
                NSLog(@"同：%@ ===== %@", self, otherString);
                
                return TRUE;
            }else{
            
                NSLog(@"不同：%@ ===== %@", self, otherString);
                
            }
            
        } while (otherString != nil);
        
        
        
    }
    va_end(args);
    
    return FALSE;
    
}

- (NSString *)getSrtingBetweenSting:(NSString *)startString andString:(NSString *)endString{
    
    NSRange startRange = [self rangeOfString:startString];
    NSRange endRange = [self rangeOfString:endString];
    
    NSRange trueRange = NSMakeRange(startRange.length + startRange.location, endRange.location - (startRange.length + startRange.location));
    
    if (trueRange.length > self.length) {
        return @"";
    }
    
    return [self substringWithRange:trueRange];
    
}


-(NSDate *)GMTStringToDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:self];
    
    
    
    return date;
    
}
-(NSDate *)localStringToDate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:self];
    
    return date;
    
}


-(NSDate *)GMTStringToDateWithoutTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    NSDate *date = [dateFormatter dateFromString:self];
    
    
    
    return date;
    
}
-(NSDate *)localStringToDateWithoutTime{
    

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:self];
    
    
    
    return date;
    
}





@end
#pragma mark - UIImage延展

@implementation UIImage (IWPImage)
-(UIImage * _Nullable)imageByScalingAndCroppingForSize:(CGSize)targetSize withCoordinate:(CLLocationCoordinate2D)coordinate{
    
    UIImage * newImage = nil;
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }// scale to fit height
        else{
            scaleFactor = heightFactor; // scale to fit width
        }
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [self drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    // 添加水印
    
    // 测试
    
    newImage = [newImage addText:@{@"lat":[NSNumber numberWithDouble:coordinate.latitude], @"lon":[NSNumber numberWithDouble:coordinate.longitude]}];
    
    return newImage;
}
-(UIImage *)addText:(NSDictionary *)text{
    
    if (self) {
        UIGraphicsBeginImageContext(self.size);
        
        [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        
        NSDate * now = [NSDate date];
        
        NSDateFormatter * format = [[NSDateFormatter alloc] init];
        
        [format setDateFormat:@"yyyy-MM-dd"];

        NSString * date = [format stringFromDate:now];
        
        NSString * waterMark = [NSString stringWithFormat:@"经纬度：%@/%@\n日期：%@",text[@"lon"],text[@"lat"],date];
        
        // NSFontAttributeName 字体
        // NSForegroundColorAttributeName 前景颜色
        
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:self.size.width / 15.f],
                                      NSForegroundColorAttributeName:[UIColor redColor]};
        
        [waterMark drawInRect:CGRectMake(0, 0, self.size.width, self.size.height) withAttributes:attributes];
        UIImage * ret = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return ret;
        
    }else{
        return self;
    }

}
@end


@implementation IWPVersionControl

+ (NSString *)applicationVersion{
    
    NSDictionary * dic = [[NSBundle mainBundle] infoDictionary];
    
    return [NSString stringWithFormat:@"V%@", dic[@"CFBundleShortVersionString"]];
}

+ (float)systemVersion{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

@end


@implementation UIView (IWPView)

-(void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
-(void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
-(void)setWidth:(CGFloat)width{
    
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
    
}
-(void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

-(CGFloat)x{
    return self.frame.origin.x;
}
-(CGFloat)y{
    return self.frame.origin.y;
}
-(CGFloat)width{
    return self.frame.size.width;
}
-(CGFloat)height{
    return self.frame.size.height;
}

-(void)addSubviews:(NSArray *)subviews{
    
    for (UIView * view in subviews) {
        if ([view isKindOfClass:[UIView class]]) {
//            view.backgroundColor = [UIColor anyColor];
            
            [self addSubview:view];
        }
    }
    
}

@end
@implementation IWPJsonTool
+ (id)jsonToObj:(id)json{
    
    
    NSData * data = nil;
    
    if ([json isKindOfClass:[NSString class]]) {
        data = [json dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        data = json;
    }
    
    if (data) {
        
        NSError * error = nil;
        
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (error == nil) {
            return obj;
        }else{
            return @{@"error":error.localizedDescription};
        }
        
    }else{
        return @{@"error":@"错误的数据格式"};
    }
    
}

+ (NSString *)objToJson:(id)obj{
    
    
    if ([NSJSONSerialization isValidJSONObject:obj]) {
        
        NSError * error = nil;
        
        NSData * data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
        
        if (error == nil) {
            
            NSString * json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            return json;
        }else{
            
            return [NSString stringWithFormat:@"{\"error\":\"%@\"}", error.localizedDescription];
            
        }
        
    }else{
        return @"{\"error\":\"错误的数据格式\"}";
    }
    
}

@end

