//
//  Yuan_NewFL_VM.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Yuan_NewFL_HttpModel.h"
NS_ASSUME_NONNULL_BEGIN


// 局向光纤下属节点 , 新增字段 ,判断所属的局向光纤 -- 有这个字段 , 证明是光链路中 展开的局向光纤 , 内部的节点map
static const NSString * belongRouteId = @"belongRouteId";

typedef NS_ENUM(NSUInteger , NewFL_LinkState_) {
    NewFL_LinkState_ChooseDevice,                   //初始化光路路由 , 插入一个新的设备  -- ODF ODB OCC  只出现一次
    NewFL_LinkState_ChooseCable,                    //根据设备查光缆段 , 不用去重
    NewFL_LinkState_ChooseCable_Repeat,             //根据设备/接头查光缆段 , 需要去重
    NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType, // 根据设备查光缆段, 去重并且 不弹出 选取成端熔接 , 直接弹出纤芯面板图
    NewFL_LinkState_ChooseJuXiangLastEptTerminal,   //根据局向光纤最后一个节点设备 , 去选择一组新的端子作为新路由的起点.
    NewFL_LinkState_ChooseTerminalFromLastDevice,   //根据最后一个设备 , 选择一对新的端子
    NewFL_LinkState_ChooseError,                    //错误
};


typedef NS_ENUM(NSUInteger , NewFL2_InsertMode_) {
    NewFL2_InsertMode_None,     //无操作
    NewFL2_InsertMode_Up,       //向上插入
    NewFL2_InsertMode_Down,     //向下插入
};


@interface Yuan_NewFL_VM : NSObject

+ (Yuan_NewFL_VM *) shareInstance;


/** 当前的链路状态 */
@property (nonatomic , assign) NewFL_LinkState_ nowLinkState;

/** 当前展示的光链路Id */
@property (nonatomic , copy) NSString * nowLinkId;

/** 当前所展示的光链路完整路由 */
@property (nonatomic , copy) NSArray * nowLinkRouters;


/** 链路1 选择端子 */
@property (nonatomic , copy) NSDictionary * _Nullable LinkA_TerminalChooseDict;

/** 链路2 选择端子 */
@property (nonatomic , copy) NSDictionary * _Nullable LinkB_TerminalChooseDict;


/** 链路1 选择纤芯 */
@property (nonatomic , copy) NSDictionary * _Nullable LinkA_FiberChooseDict;

/** 链路2 选择纤芯 */
@property (nonatomic , copy) NSDictionary * _Nullable LinkB_FiberChooseDict;


/** 链路1 选取的一个局向光纤 */
@property (nonatomic , copy) NSDictionary * _Nullable LinkA_RouteChooseDict;

/** 链路2 选取的一个局向光纤 */
@property (nonatomic , copy) NSDictionary * _Nullable LinkB_RouteChooseDict;


/** 当前是否是空链路 */
@property (nonatomic , assign) BOOL isEmptyLink;


/** 几条光路 1 或 2 */
@property (nonatomic , assign) int numberOfLink;

/** 当前是第几条光链路? */
@property (nonatomic , assign) int now_LinkNum;


/** 当前查询光缆段所使用的设备map   cableStart_Id  cableStart_Type 两个字段*/
@property (nonatomic , copy) NSDictionary * nowSelectCableDevice_Dict;


/** saveBusiness_Fiber 方法中的 BOOL 值 , 根据路由最后一条是不是纤芯来判断 ,纤芯是true */
@property (nonatomic , assign) BOOL isNeedRongJ;

/** 当A链和B链长度不一致的情况下 */
@property (nonatomic , assign) BOOL isDoubleLinks_NotBothLength;

/** 倒叙的当前光链路 , 用于向上插入时使用 */
@property (nonatomic , copy) NSArray * nowLinkRouters_flashback;

/** 插入模式 */
@property (nonatomic , assign) NewFL2_InsertMode_ insertMode;

// 清空数据
- (void) clean_LinkChooseData;


#pragma mark - 保存事件的抽离 ---
// 保存事件的逻辑抽离 保存端子时
- (NSDictionary *) saveBusiness_Terminal:(NSDictionary *)selectDict
                              deviceDict:(NSDictionary *)myDict;

// 保存事件的逻辑抽离 保存纤芯时  , 如果是纤芯和纤芯熔接的情况 , 需要传中间设备的Id
- (NSDictionary *) saveBusiness_Fiber:(NSDictionary *)selectDict
                           deviceDict:(NSDictionary *)myDict
                        isNeedRongJie:(BOOL) isNeedRongJie;


// 保存局向光纤
- (NSDictionary *) saveBusiness_Route:(NSDictionary *)selectDict;





// ******** 二期新增 保存端子和纤芯

/// 保存端子点击事件 传参 --- 当双链路 并且长度不一致时的保存方式
- (NSDictionary *) Links2_DoubleLinks_NotBothLength_SaveBusiness_Terminal:(NSDictionary *)selectDict
                                                               deviceDict:(NSDictionary *)myDict;


/// 保存纤芯时的 传参整理 --- 当双链路 并且长度不一致时的保存方式
- (NSDictionary *) Links2_DoubleLinks_NotBothLength_SaveBusiness_Fiber:(NSDictionary *)selectDict
                                                            deviceDict:(NSDictionary *)myDict
                                                         isNeedRongJie:(BOOL)isNeedRongJie;



#pragma mark - 光缆段处理 ---
/// 对光缆段进行去重处理 , 去掉已经出现在路由中的光缆段  (包括局向里的光缆段)
/// @param data 根据设备返回回来的光缆段完整列表
- (NSArray *) cableList_Repeat:(NSArray *)data
                       linkArr:(NSArray *)linkArr;


/// 对光缆段进行去重处理 , 去掉已经出现在路由中的光缆段 -- 二期
/// @param data 根据设备返回回来的光缆段完整列表
- (NSArray *) Links2_CableList_Repeat:(NSArray *)data
                              linkArr:(NSArray *)linkArr;


/// 对光缆段进行去重处理 , 去掉已经出现在路由中的光缆段 -- 二期 双链并且不同长度的情况
/// @param data 根据设备返回回来的光缆段完整列表
- (NSArray *) DoubleLinks_NotBothLength_CableList_Repeat:(NSArray *)data
                                                 linkArr:(NSArray *)linkArr;


#pragma mark - 当前应该用哪个设备去请求光缆段 ---
/// 根据 光链路1的最后一个设备 , 返回需要请求光缆段列表的设备
/// @param firstLink 光链路1的数据
- (void) nowSelectCableDevice:(NSArray *)firstLinkArr
                        block:(void(^)(NSDictionary * dict))block;



#pragma mark - 2021-10 版本更新 ---

/// 判断哪些能组成局向光纤
- (NSArray *) viewModel_ComboToRouters:(NSArray *) eptTypeIdArr;


/// 根据 -- 端子纤芯端子 生成一个新的 , 无id的局向光纤 , 作为占位符
- (NSDictionary *) viewModel_GetNewRouterFromTerminalAndFibers:(NSArray *) subRoutes;


/// 倒叙当前的光链路节点数组
- (NSArray *) configNowLinkRouters_flashback;


/// 是否是 2021 新业务
+ (BOOL) isNew_2021;

/// 是否是 光路纤芯衰耗分解
+ (BOOL) isFiberDecay;

@end

NS_ASSUME_NONNULL_END
