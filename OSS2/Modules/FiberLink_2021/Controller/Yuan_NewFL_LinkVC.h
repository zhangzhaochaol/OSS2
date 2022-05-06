//
//  Yuan_NewFL_LinkVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN



//NewFL_LinkState_ChooseJointCable

@interface Yuan_NewFL_LinkVC : Inc_BaseVC


/** <#注释#> */
@property (nonatomic , copy) NSDictionary * MB_Dict;


/// 新增构造方法 , 在端子查询所属光路路由时使用
- (instancetype)initFromTerminalId_SelectFiberLinkDatas:(NSDictionary *) fiberLinkDicts;


/// 2期构造方法 - 根据光链路id 查询 光链路 , 但会组合成光路查看
- (instancetype)initFromLinkDatas:(NSDictionary *) fiberLinkDicts;


@end

NS_ASSUME_NONNULL_END
