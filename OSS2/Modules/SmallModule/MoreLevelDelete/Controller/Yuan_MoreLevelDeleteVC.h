//
//  Yuan_MoreLevelDeleteVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/25.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_MoreLevelDeleteVC : Inc_BaseVC

/** 失败原因 */
@property (nonatomic , copy) NSString * errorMsg;

/** <#注释#> */
@property (nonatomic , copy) NSDictionary * resourceDict;

/** <#注释#> */
@property (nonatomic , copy) NSString * resName;


- (instancetype)initWithRequestDict:(NSDictionary *)requestDict;

@end

NS_ASSUME_NONNULL_END
