//
//  Inc_CFListController.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CFListController : Inc_BaseVC


/** 模板dict */
@property (nonatomic,strong) NSDictionary *moban_Dict;


/// 构造方法
/// @param cableId 光缆段ID
- (instancetype) initWithCableId:(NSString *)cableId;



@end

NS_ASSUME_NONNULL_END
