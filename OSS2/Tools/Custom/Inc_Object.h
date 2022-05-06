//
//  Inc_Object.h
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/4/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Inc_Object)

// 基本数据类型 转 json
@property (nonatomic, copy, readonly) NSString * json;

// json 转 基本数据类型
@property (nonatomic, strong, readonly) id object;

// json 转 基本数据类型
@property (nonatomic, strong, readonly) id object_Yuan;

/** 获取图片路径 */
@property (nonatomic , copy, readonly) NSString * sdkPath;

@end

NS_ASSUME_NONNULL_END
