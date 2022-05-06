//
//  Inc_CFListHeader.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inc_CFListHeaderCell.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , CFHeaderReset_) {
    CFHeaderReset_Start,
    CFHeaderReset_End,
};

@interface Inc_CFListHeader : UIView



/// 构造方法
/// @param vc 传控制器
- (instancetype) initWithVC:(UIViewController *)vc;


- (void) dataSource:(NSMutableArray *) dataSource;

/** 批量解除成端熔接关系  block */
@property (nonatomic , copy) void (^headerResetBlock) (CFHeaderReset_  resetEnum);

@end

NS_ASSUME_NONNULL_END
