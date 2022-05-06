//
//  Inc_CFConfigController.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CFConfigController : Inc_BaseVC



/// 构造方法
/// @param type 成端还是熔接
/// @param collectionDataSource 上方collection的数据源
/// @param dict 根据端子盘信息 初始化 
- (instancetype) initWithType:(CF_HeaderCellType_)type
                   dataSource:(NSMutableArray *)collectionDataSource;



/** 对应的设备Id 要求做网络请求 */
@property (nonatomic ,copy)  NSString *deviceId;

/** 设备名称 */
@property (nonatomic,strong) NSString *deviceName_txt;




@end

NS_ASSUME_NONNULL_END
