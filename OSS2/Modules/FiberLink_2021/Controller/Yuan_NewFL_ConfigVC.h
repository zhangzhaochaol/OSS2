//
//  Yuan_NewFL_ConfigVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , NewFL_ConfigType_) {
    NewFL_ConfigType_Device,    //设备端子
    NewFL_ConfigType_Cable,     //光缆段纤芯
};


typedef NS_ENUM(NSUInteger , NewFL_InsertType_) {
    NewFL_InsertType_None,
    NewFL_InsertType_Links,
    NewFL_InsertType_Routes,
};


@interface Yuan_NewFL_ConfigVC : Inc_BaseVC


- (instancetype)initWithType:(NewFL_ConfigType_)type
                        data:(NSDictionary *)dict;


/** 光链路数组 */
@property (nonatomic , copy) NSDictionary * optRoadAndLink;





/** 是否是要进行光链路 / 局向光纤的节点替换? */
@property (nonatomic , assign) BOOL isExchangeRoute;

/** 操作的是第几行? */
@property (nonatomic , assign) NSInteger exchangeIndex;

/** 操作的map */
@property (nonatomic , copy) NSDictionary * exchangeCellDict;





/** 向下插入的节点index */
@property (nonatomic , copy) NSIndexPath * insertIndex;

/** 向下插入的类型 对局向光纤还是光链路 进行向下插入? */
@property (nonatomic , assign) NewFL_InsertType_ insertTypeEnum;

/** 等待插入的光链路数据 / 局向光纤的路由数据 */
@property (nonatomic , copy) NSArray * insertBaseArray;





/** 保存成功的回调  block */
@property (nonatomic , copy) void (^ConfigSave_ReturnDataBlock) (id returnData);

/** 保存成功 让光链路刷新  block */
@property (nonatomic , copy) void (^Config_RefreshDatasBlock) (void);

@end

NS_ASSUME_NONNULL_END
