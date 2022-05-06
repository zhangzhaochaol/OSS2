//
//  Yuan_New_ODFModelVC.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/28.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN





@interface Yuan_New_ODFModelVC : Inc_BaseVC


/// 初始化列框信息
/// @param enterType 入口的类别
/// @param gid id
- (instancetype) initWithType:(InitType)enterType
                          Gid:(NSString *)gid
                         name:(NSString *)name;


/** 模板dict */
@property (nonatomic , copy) NSDictionary * mb_Dict;

@end

NS_ASSUME_NONNULL_END
