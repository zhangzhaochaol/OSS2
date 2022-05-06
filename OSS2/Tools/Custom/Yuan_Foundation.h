//
//  Yuan_Foundation.h
//  INCP&EManager
//
//  Created by 袁全 on 2020/4/13.
//  Copyright © 2020 Unigame.space. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_Foundation : NSObject

/**

 H5传的url 是否带“？”
 */
+ (BOOL)doseUrlByH5Bool:(NSString *)url;




/**
 *  获取今天的日期 2016-08-31_12:12:12
 *
 *  @return 精确到秒的字符串
 */
+ (NSString *)currentSecond;



/**
 *  获取今天的日期 2016-08-31
 *
 *  @return 日期字符串
 */
+ (NSString *)currentDate;


/// 年月日 时分秒 现在
+ (NSString *)currentDate_Time;

/**
 *  获取当前 年-月
 *
 *  @return 年月字符串
 */
+ (NSString *)currentMonth;

/**
 *  获取currentDate对应的那天的Date
 *
 *  @param currentDate @"yyyy-MM-dd"格式的字符串
 *
 *  @return NSDate
 */
+ (NSDate *)currentDateFromString:(NSString *)currentDate;



/// 根据parmater 设置 string2date
/// @param Date d_str
/// @param formate parmater
+(NSDate *) currentDateFromString:(NSString *)Date
                      dateFormate:(NSString *)formate;


/// 根据 date 返回 yyyy-mm-dd 格式的日期字符串
/// @param date date
+ (NSString *) stringFromDate:(NSDate *)date;

/**
 *  获取当前是哪年
 */
+ (NSString *)currentYear;



/**
 *  获取今天的星期
 *
 *  @return 星期字符串
 */
+ (NSString*)weekdayStringFromDate;




/**
 *  获取currentDate对应的那天的星期
 *
 *  @param currentDate @"yyyy-MM-dd"格式的字符串
 *
 *  @return weekDay
 */
+ (NSString *)weekdayStringFromDateString:(NSString *)currentDate;




/**
 *  截取字符串后几位
 *
 *  @param tobeProcessed 待处理的字符串
 *  @param position      截取几位
 *
 *  @return 截取后的字符串
 */
+(NSString *)interceptionLastFew:(NSString *)tobeProcessed interceptionPosition:(int)position;


/**
 *  值获取字符串中的数字
 */

+ (NSString *)GetOnlyNumberString:(NSString *)string;


/**
 *  截取字符串后几位
 */

+ (NSString *)interceptionFirstFew:(NSString *)tobeProcessed interceptionPosition:(int)position;




/*
    移除字符串最后几位字符
 */
+ (NSString *)removeLastNumberChar:(int)number String:(NSString *)string;


/**
 *  判断传入的对象 是步数这个类的类对象
 *
 *  @param object 对象
 *  @param type   是不是这个类的对象
 */
-(BOOL)judgeObject:(id)object isKindOfClass:(NSString *)type;



/**
 *  字典转JSON字符串
 *
 *  @param dic 字典
 *
 *  @return 字符串
 */
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;



/**
 *  JSON转字典
 *
 *  @param jsonString JSON字符串
 *
 *  @return 字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;




/**
 *  通过转码后的MacAddress返回加冒号的MacAddress
 *
 *  @param macAddress model.address
 *
 *  @return 加冒号的MacAddress
 */
+(NSString *)stringBackMacAddressWithString:(NSString *)macAddress;







/*
 *      获取当前是 iPhone5 ? iPhone6 ? iPhone7 ? iPhone7 Plus ?
 */
+ (NSString *)getCurrentDeviceModel;


+ (NSString *)_TStr;



/// 时间差
/// @param starTime 开始时间
/// @param endTime 结束时间
+ (NSTimeInterval)pleaseInsertStarTime:(NSString *)starTime
                      andInsertEndTime:(NSString *)endTime;




/// 获取字符串中的数字
/// @param str 字符串
+ (NSString *) getNumberFromString :(NSString *)str  ;



/// 判断字符串是否为纯数字
+ (BOOL)isNumber:(NSString *)strValue;


/// 四舍五入 或 去掉小数点  NSRoundPlain 根据这个判断
/// @param price 你的小数值
/// @param position 小数点后几位有效
+ (NSString *)notRounding:(float)price afterPoint:(int)position;


+ (NSString *) fromInt:(int)value;
+ (NSString *) fromInteger:(NSInteger)value;
+ (NSString *) fromFloat:(float)value;
+ (NSString *) fromObject:(id)value;

+ (NSString *) getIpAddress;



// 避免 NSDictionary 传入 Nil 导致的崩溃
id DictValue (id value);

/// 新增的C语言函数 -- 任意类型的字符串包装
extern NSString * StringObject (id obj);
extern NSString * StringInt (int obj) ;
extern NSString * StringInteger (NSInteger obj);
extern NSString * StringDouble (double obj) ;
@end

NS_ASSUME_NONNULL_END
