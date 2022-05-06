//
//  Yuan_OBD_PointsVM.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/21.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_OBD_PointsVM : NSObject


/** 分光器端口 map */
@property (nonatomic , copy) NSDictionary * obd_Point_Dict;


/** 设备端子 map */
@property (nonatomic , copy) NSDictionary * terminal_Dict;


/** 设备端子 分光器端口 关联关系数组 设备端子相关 */
@property (nonatomic , copy) NSArray * point_Terminal_ShipArr;



/** 设备端子 分光器端口 关联关系数组 obd端子相关 */
@property (nonatomic , copy) NSArray * point_Terminal_Ship_OBDPoint_Arr;


// 输入端配对
- (void) handleModel_InputConfig:(void(^)(void))handleSuccess_Block;



// 输出端手动配对
- (void) handleModel_Config:(void(^)(void))handleSuccess_Block;

// 输出端自动配对
- (void) autoModel_Config:(void(^)(void))handleSuccess_Block;




/** 分光器端口 数组  -- 截取过的 , 截取部分为 选中位置到最后 */
@property (nonatomic , copy) NSArray * obd_PointsArr;

/** 设备端子 数组 -- 截取过的 ,截取部分为 选中位置到最后 */
@property (nonatomic , copy) NSArray * terminalsArr;

@end

NS_ASSUME_NONNULL_END
