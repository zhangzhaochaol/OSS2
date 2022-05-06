//
//  Inc_TE_HttpModel.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_TE_HttpModel : NSObject

/// 根据端子Id 获取所在链路信息
+ (void) Http_TE_GetDatasFromTerminalIds:(NSDictionary *) terminalIds
                                 success:(void(^)(id result)) success;


/// 返回对调后的数据
+ (void) Http_TE_ExchangeTerminal:(NSDictionary *) param
                          success:(void(^)(id result)) success;


@end

NS_ASSUME_NONNULL_END
