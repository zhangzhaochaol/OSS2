//
//  Inc_TE_ExChangeTerminalStateView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , TerminalStateEnum_) {
    TerminalStateEnum_A,
    TerminalStateEnum_B,
};

@interface Inc_TE_ExChangeTerminalStateView : UIView


- (instancetype)initWithNowStateId:(NSInteger) nowStateId
                 TerminalStateEnum:(TerminalStateEnum_)Enum;



// 刷新目标业务状态Id
- (void) reloadStateId:(NSInteger) newStateId;


/** exceptBtnClick  block */
@property (nonatomic , copy) void (^exceptBtnBlcok) (void);

@end

NS_ASSUME_NONNULL_END
