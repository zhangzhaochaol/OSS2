//
//  StrUtil.h
//  OSS2.0-ios-v1
//
//  Created by 孟诗萌 on 16/4/5.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>

@interface StrUtil : NSObject
//MD5加密
- (NSString *)strToMD5:(NSString *)str;
//将可变字典转为服务器所约定的传输格式
-(NSString *)dicToJSon:(NSMutableDictionary *)dic;
//将数组中可变字典转为服务器所约定的传输格式
-(NSString *)dicArrToJSon:(NSMutableArray *)arr;
//将标准时间格式转为需要的时间格式
-(NSString *)GMTToLocal:(NSString *)intime;
//将标准时间格式转为需要的时间格式含上下午
-(NSString *)GMTToLocalWithAMPM:(NSString *)intime;
-(NSString *)LocalToGMTWithSecond:(NSString *)date;
-(NSString *)GMTToLocalWithSecond:(NSString *)intime;
-(NSString *)GMTToLocalWithSecond_PMAM:(NSString *)intime;
//将当前显示时间格式转为标准时间格式
-(NSString *)LocalToGMT:(NSString *)intime;
//图片添加水印
- (UIImage *)addText:(UIImage *)img lon:(NSString *)lon lat:(NSString *)lat;
//转时间戳
- (NSString *)dateToTimeInterval:(NSDate *)date;
//获取手机型号
- (NSString*)deviceVersion;
//获取手机系统版本
- (NSString *)systemVersion;
//获取网络状态
- (NSString *)getNetWorkStates;
//获取当前设备可用内存(单位：MB）
- (double)availableMemory;
//设置大头针上绘制的文字
-(UILabel *)makeAnnotationViewLabel:(NSString *)titleCode :(NSString *)titleSubNum :(NSString *)mark :(BOOL)markFirst;
/**
 判断工单是否为自己的工单
 @param taskId 资源中的taskId中的内容
 @return 是否为自己工单
 */
+ (BOOL)isMyOrderWithTaskId:(NSString *)taskId;

/**
 获取工单Id

 @param taskId 资源中的taskId中的内容
 @return 工单Id
 */
+ (NSString *)taskIdWithTaskId:(NSString *)taskId;

/**
 获取某工单的接收人

 @param taskId 资源中的taskId中的内容
 @return 工单Id
 */
+ (NSString *)reciverWithTaskId:(NSString *)taskId;

/**
 2017年03月02日 新增，判断某资源于列表显示时的颜色
 自身工单返回 #e60d36
 他人工单返回 #096ee0
 非工单返回 #000

 @param taskId 该资源的taskId
 @return 对应的颜色
 */
+ (NSString *)textColorWithDevice:(NSString *)taskId;



/**
 获取应用当前版本号

 @return 当前版本号
 */
+ (NSString *)getAppVersion;


+ (CGFloat)heightOfTop;
@end

@interface NSString (IWPString2)
/**
 获取两个字符串之间的内容
 
 @param startString 起始目标字符串
 @param endString 终止目标字符串
 @return 其间的的字符串
 */
- (NSString *)getSrtingBetweenSting:(NSString *)startString andString:(NSString *)endString;
- (NSString *)deleteZeroString;

/**
 获取按位变色的二维码；

 @return 
 */
- (NSAttributedString *)getColorfulQRCode;
-(BOOL)isEqualToAnyString:(NSString *)string,...NS_REQUIRES_NIL_TERMINATION;
-(NSString *)makeDeviceId;
-(NSString *)GMTToLocalWithSecond;

- (BOOL)isEqualToAnyStringInArr:(NSArray *)arr;

@end
