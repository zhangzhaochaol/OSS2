//
//  Inc_PoleNewConfig_HttpModel.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/9/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_PoleNewConfig_HttpModel : NSObject

/// 统一库通用资源查询
+ (void) http_GetDatas:(NSDictionary *) dict
               success:(void(^)(id result))success;



/// 统一库通用资源查询
+ (void) http_InsertDatas:(NSArray *) arr
                  success:(void(^)(id result))success;

@end

NS_ASSUME_NONNULL_END
