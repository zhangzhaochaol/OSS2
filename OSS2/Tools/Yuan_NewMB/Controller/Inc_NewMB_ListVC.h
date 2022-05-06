//
//  Inc_NewMB_ListVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/10.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"
#import "Inc_NewMB_VM.h"


NS_ASSUME_NONNULL_BEGIN

@interface Inc_NewMB_ListVC : Inc_BaseVC

/// 根据新的
- (instancetype)initWithModelEnum:(Yuan_NewMB_ModelEnum_) modelEnum;



/** 分光器时使用 , 分光器所属设备Id , 需要带着这个Id 进行操作 */
@property (nonatomic , copy) NSString * belongDeviceId;

/** 分光器 typeId */
@property (nonatomic , copy) NSString * belongResTypeId;





#pragma mark - 只有当资源需要特殊参数处理时使用 , 通常不要使用一下参数 ---

/** 当查询时 需要传特殊参数 */
@property (nonatomic , copy) NSDictionary * selectDict;

/** 当保存时 需要传特殊参数 */
@property (nonatomic , copy) NSDictionary * modifyDict;

/** 当新增时 需要传特殊参数 */
@property (nonatomic , copy) NSDictionary * insertDict;

/** 当删除时 需要传特殊参数 */
@property (nonatomic , copy) NSDictionary * deleteDict;




@end

NS_ASSUME_NONNULL_END
