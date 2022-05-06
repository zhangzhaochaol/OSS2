//
//  Inc_BusScrollItem.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define BusScrollItemLongPressNotification @"BusScrollItemLongPressNotification"

@interface Inc_BusScrollItem : UIButton


/** 设置数据源 */
@property (nonatomic,strong) NSDictionary *dict;






/** 是否使用的是新数据源 */
@property (nonatomic , assign , readonly) BOOL isNewDict;

// 设置新数据源 , 虽然还用 dict  但需要转换一下
- (void) configNewDict:(NSDictionary *) newDict;








/** 端子GID */
@property (nonatomic , copy , readonly) NSString * terminalId;

/** 按钮的编号 */
@property (nonatomic ,assign) int index;

/** btn 所在的position */
@property (nonatomic ,assign) NSInteger position ;

/** 是否可以点击 */
@property (nonatomic , assign) BOOL canSelect;

/** note -- 作为特殊标记使用 */
@property (nonatomic , copy) NSString * note;



#pragma mark - 2021-08-02 新增  端子返回的三个关系数组 ---

/** 成端关系 */
@property (nonatomic , copy , readonly) NSArray * opticTermList;

/** 跳纤关系 */
@property (nonatomic , copy , readonly) NSArray * optLineRelationList;

/** 光路路由关系 */
@property (nonatomic , copy , readonly) NSArray * optPairRouterList;



// Method *** ***

/// 配置我的按钮的编号
/// @param num 编号 通过for循环创建
- (void) configMyNum:(int) num;


/// 绑定对应的纤芯的编号
/// @param num 纤芯编号
- (void) configBindingNum:(NSString *) num
                     from:(configBindingNumFrom_)type;


// 背景色
- (void) configColor:(UIColor *)color;

// 边框颜色
- (void) borderColor:(UIColor *)borderColor;

/// 当特殊状况 , 不显示端子序号 需要显示其他状态时 使用 , 暂时是 initType = 4 的时候
- (void) configTerminalText:(NSString *) text color:(UIColor *) color;


//MARK: 其他配置 ---

/// 暂时只有分光器端子 绑定时使用
- (void) config_ConnectNum:(NSString *) connectNum;

/// 是否显示跳纤的标志 -- 底部的小绿点
- (void) Terminal_JumpFiber_Sympol_IsShow:(BOOL) isShow_JF_Sympol;

/// 是否显示成端标志 -- 左上角
- (void) Terminal_ChengD_Sympol_IsShow:(BOOL) isShow_ChengD_Sympol;

/// 是否显示端子在光路内标志 -- 右上角
- (void) Terminal_InFiberLink_Sympol_IsShow:(BOOL) isShow_inFiberLink_Sympol;

@end

NS_ASSUME_NONNULL_END
