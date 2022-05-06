//
//  Yuan_MLD_DetailVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/28.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_MLD_DetailVC : Inc_BaseVC

- (instancetype)initWithDict:(NSDictionary *)dict;

/** <#注释#> */
@property (nonatomic , assign) BOOL isHiddenTopBtns;

@end

NS_ASSUME_NONNULL_END
