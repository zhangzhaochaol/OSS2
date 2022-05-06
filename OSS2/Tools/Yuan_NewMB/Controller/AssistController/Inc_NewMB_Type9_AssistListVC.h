//
//  Inc_NewMB_Type9_AssistListVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/30.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_NewMB_Type9_AssistListVC : Inc_BaseVC

- (instancetype)initWithPostDict:(NSDictionary *)postDict ;


// 配置标题
- (void) configTitle:(NSString *) title;

/** 选择  block */
@property (nonatomic , copy) void (^Type9_Choose_ResBlock) (NSDictionary * dict);

@end

NS_ASSUME_NONNULL_END
