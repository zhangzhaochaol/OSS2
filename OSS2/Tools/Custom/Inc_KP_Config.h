//
//  Inc_KP_Config.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/5/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_KP_Config : NSObject


+ (Inc_KP_Config*)sharedInstanced;



/**
 时间转字符串   nsdate --- nsstring
 */
- (NSString *)getDate:(NSDate *)data  andFormatter:(NSString *)format;

/**
 时间戳字符串   nsinteger --- nsstring
 */
- (NSString *)getTime:(NSInteger)time  andFormatter:(NSString *)format;

/**
 增加min分钟  symbol 1 增加   -1 减少
 */
- (NSString *)addTime:(NSString *)dateStr symbol:(int)symbol min:(int)min;


/**
 转时间戳
 */
-(NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format;


/**
 计算两个时间相差   返回多少秒
 */
- (NSTimeInterval)pleaseInsertStarTime:(NSString *)starTime andInsertEndTime:(NSString *)endTime;

/**
 两个时间比较
 */
-(int)compareDateTime:(NSString*)date01 withDate:(NSString*)date02 andFormat:(NSString *)format;

/**
 *  判断当前时间是否处于某个时间段内
 *
 *  @param startTime        开始时间
 *  @param expireTime       结束时间
 */

- (BOOL)validateWithStartTime:(NSString *)startTime withExpireTime:(NSString *)expireTime nowTIme:(NSString *)nowTime;


/**
 日期比较
 */
- (int)compareOneDay:(NSString *)current withAnotherDay:(NSString *)endDay;



/**判断两个日期的大小

 *date01 : 第一个日期

 *date02 : 第二个日期

 *format : 日期格式 如：@"yyyy-MM-dd HH:mm"

 *return : 0（等于）1（大于）-1（小于）

 */

- (int)compareDate:(NSString*)date01 withDate:(NSString*)date02 toDateFormat:(NSString*)format;


/**当前时间周几
 inputDate 输入时间
 */
- (NSString*)weekdayStringFromDate:(NSString*)inputDate;


/**虚线边框
 view  需要画框的view
 color 颜色
 */
-(void)addDottedBorderWithView:(UIView*)view color:(UIColor *)color;

/**
 textView 文字居中显示
 */
+ (void)Zhang_ContentSizeToFit:(UITextView *)textView textViewHeight:(CGFloat)textViewHeight;


// 64base字符串转图片

- (UIImage *)stringToImage:(NSString *)str;

// 图片转64base字符串

- (NSString *)imageToString:(UIImage *)image;

// 设置单独页面的导航图片
-(void)setUpNavBarBackImage:(UIImage *)image nav:(UINavigationController *)nav;

//取消单独页面的导航图片
-(void)cancelUpNavBarBackImage:(UINavigationController *)nav;

@end

NS_ASSUME_NONNULL_END
