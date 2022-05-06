//
//  Yuan_NewFL2_RouteSelectList.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/10/29.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_NewFL2_RouteSelectList : Inc_BaseVC

/// 单设备查询构造
- (instancetype)initWithEqpId:(NSString *) eqpId
                    eqpTypeId:(NSString *)eqpTypeId;


/// 多设备查询构造
- (instancetype)initWithEqpIdA:(NSString *)eqpIdA
                    eqpTypeIdA:(NSString *)eqpTypeIdA
                        eqpIdZ:(NSString *)eqpIdZ
                    eqpTypeIdZ:(NSString *)eqpTypeIdZ;



/** 选中的  block */
@property (nonatomic , copy) void (^selectRouteBlock) (NSDictionary * routeDict);


/** 交换 */
@property (nonatomic , assign) BOOL isExchangeMode;

/** 需要替换的原来的局向光纤 */
@property (nonatomic , copy) NSDictionary * needExchangeDict;


/** 需要过滤的id */
@property (nonatomic , copy) NSArray * filterIdsArr;



/** 向下插入的节点index */
@property (nonatomic , copy) NSIndexPath * insertIndex;

/** 原数据 */
@property (nonatomic , copy) NSArray * insertBaseArray;


@end

NS_ASSUME_NONNULL_END
