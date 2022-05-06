//
//  Inc_TE_ExchangeVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_TE_ExchangeVC : Inc_BaseVC

/** 对调成功 重新初始化  block */
@property (nonatomic , copy) void (^TE_SuccessBlock) (void);

@end

NS_ASSUME_NONNULL_END
