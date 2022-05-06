//
//  IWPTools.h
//  CUOSS2.5
//
//  Created by 王旭焜 on 2016/8/7.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;
//@interface NSObject (IWPTool)
//- (NSString *)json;
//- (id).object;
//
//- (NSString *)JSON_lastError;
//
//@end

#pragma mark NSDate延展
@interface NSDate (IWPDate)
/**
 * 转时间戳
 */
- (NSString * _Nullable)dateToTimeInterval;

/**
 * 将标准时间格式转为需要的时间格式
 */
- (NSString * _Nullable)GMTToLocal;

/**
 * 将标准时间格式转为需要的时间格式含上下午
 */
- (NSString * _Nullable)GMTToLocalWithAMPM;

/**
 * 将当前显示时间格式转为标准时间格式
 */
- (NSString * _Nullable)localToGMT;

/**
 * 将当前显示时间格式转为标准时间格式 - 带时分秒
 */
- (NSString * _Nonnull)LocalToGMTWithSecond;
/**
 * 将标准时间格式转为需要的时间格式 - 带时分秒
 */
- (NSString * _Nonnull)GMTTolocalWithSecond;

/**
 判断是否为闰年

 @return true 闰年，FALSE 不是闰年
 */
- (BOOL)isLeapYear;
/**
 判断某年是否为闰年
 
 @return true 闰年，FALSE 不是闰年
 */
+ (BOOL)isLeapYear:(NSInteger)year;
/**
 取秒
 */
-(NSInteger)secound;

/**
 取分钟
 */
-(NSInteger)minute;

/**
 取小时
 */
-(NSInteger)hour;

/**
 取日期
 */
-(NSInteger)day;

/**
 取月份
 */
-(NSInteger)month;

/**
 取年份
 */
-(NSInteger)year;

/**
 取星期
 */
-(NSInteger)weekDay;


/**
 设置秒数

 @param secound 要设置的秒数
 @return 修改后的Date
 */
-(NSDate *_Nullable)setSecound:(NSInteger)secound;

/**
 设置分钟

 @param minute 要设置的分钟
 @return 修改后的Date
 */
-(NSDate *_Nullable)setMinute:(NSInteger)minute;

/**
 设置小时

 @param hour 要设置的小时
 @return 修改后的Date
 */
-(NSDate *_Nullable)setHour:(NSInteger)hour;
/**
 设置日期
 
 @param hour 要设置的日期
 @return 修改后的Date
 */
-(NSDate *_Nullable)setDay:(NSInteger)day;
/**
 设置月份
 
 @param hour 要设置的月份
 @return 修改后的Date
 */
-(NSDate *_Nullable)setMonth:(NSInteger)month;
/**
 设置年份
 
 @param hour 要设置的年份
 @return 修改后的Date
 */
-(NSDate *_Nullable)setYear:(NSInteger)year;
- (NSString *_Nullable)dateToStringWithoutTime;
@end
#pragma mark NSString延展
@interface NSString (IWPString)
- (BOOL)isEmptyString;
- (BOOL)isNumber;
- (BOOL)isEnglishChar;
/**
 使用data创建字符串
 
 @param data data
 @return 字符串，默认以UTF-8编码
 */
+ (instancetype _Nonnull)stringWithData_V2:(NSData * _Nonnull)data;

/**
 使用data创建字符串
 
 @param data data
 @param encoding 编码格式
 @return 字符串
 */
+ (instancetype _Nonnull)stringWithData_V2:(NSData * _Nonnull)data encoding:(NSStringEncoding)encoding;
/**
 依据文件名获取ID字段
 @param fileName 文件名
 */
// +(NSString * _Nonnull)idKeyWithFileName:(NSString * _Nonnull)fileName;

/**
 依据文件名获取ID字段
 */
-(NSString * _Nonnull)makeIdkey;

/**
 GMT时间字符串转Local时间字符串
 */
-(NSString * _Nonnull)GMTToLocal;

/**
 Local时间字符串转Date
 */
-(NSDate * _Nonnull)localStringToDate;

/**
 GMT时间字符串转Date
 */
-(NSDate * _Nonnull)GMTStringToDate;

/**
 Local时间字符串转Date，无时分秒
 */
-(NSDate * _Nonnull)localStringToDateWithoutTime;

/**
 GMT时间字符串转Date，无时分秒
 */
-(NSDate * _Nonnull)GMTStringToDateWithoutTime;

/**
 获取两个字符串间的内容

 @param startString 起始标记
 @param endString 终止标记
 @return 两者之间的内容
 */
- (NSString * _Nullable)getSrtingBetweenSting:(NSString * _Nonnull )startString andString:(NSString * _Nonnull)endString;


/**
 判断self是否与列表中任意一个字符串相同

 @param string 字符串,字符串,字符串...nil
 @return TRUE 有相同，FALSE 无相同
 */
- (BOOL)isEqualToAnyString:(NSString *_Nonnull)string, ...NS_REQUIRES_NIL_TERMINATION;


/**
 字典转换时需要的方法，bool对象转换
 */
-(NSNumber *_Nullable)charValue;

@end

#pragma mark UIImage延展
#import <CoreLocation/CoreLocation.h>
@interface UIImage (IWPImage)
/**
 * 图片添加水印
 */
-(UIImage *_Nonnull)addText:(NSDictionary * _Nonnull)text;

/**
 缩放图片到指定大小

 @param targetSize 目标大小
 */
- (UIImage * _Nullable)imageByScalingAndCroppingForSize:(CGSize)targetSize withCoordinate:(CLLocationCoordinate2D)coordinate;
@end


#pragma mark - 版本控制器
@interface IWPVersionControl : NSObject

/**
 获取应用版本号，以version.bundle拼接
 */
+(NSString * _Nonnull)applicationVersion;

/**
 获取当前系统版本

 @return <#return value description#>
 */
+(float)systemVersion;
@end

@interface UIView (IWPView)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

-(void)addSubviews:( NSArray * _Nonnull )subviews;
@end

@interface IWPJsonTool : NSObject

+ (NSString *)objToJson:(id)obj;
+ (id)jsonToObj:(id)json;

@end
