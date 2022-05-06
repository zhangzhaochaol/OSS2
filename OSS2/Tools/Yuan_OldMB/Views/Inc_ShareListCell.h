//
//  Inc_ShareListCell.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/7/14.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , ShareListEnum_) {
    
    ShareListEnum_CanShare,         // 可转发
    ShareListEnum_AlreadyShare,     // 已转发
    ShareListEnum_Look,             // 查看
    ShareListEnum_Do,               // 执行
};


@interface Inc_ShareListCell : UITableViewCell

- (void) reloadWithDict:(NSDictionary *)dict;

/** vc */
@property (nonatomic , weak) UIViewController * vc;

/** 重新请求列表数据  block */
@property (nonatomic , copy) void (^reloadHttpList) (void );

@end

NS_ASSUME_NONNULL_END
