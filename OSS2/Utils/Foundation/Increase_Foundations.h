//
//  Increase_Foundations.h
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/3/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Increase_Foundations : NSObject


/// 移除字符串中的空格
+ (NSString *)removeSpaceAndNewline:(NSString *)str;


/// 判断字符串是否为纯数字
+ (BOOL)isNumber:(NSString *)strValue;


/// json 解析
extern NSString * json (id data);


@end

NS_ASSUME_NONNULL_END
