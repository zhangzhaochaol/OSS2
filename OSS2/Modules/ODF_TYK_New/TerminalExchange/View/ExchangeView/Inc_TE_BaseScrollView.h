//
//  Inc_TE_BaseScrollView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

// ****
#import "Inc_TE_HttpModel.h"
#import "Inc_TE_ViewModel.h"
NS_ASSUME_NONNULL_BEGIN





@interface Inc_TE_BaseScrollView : UIView


/** 当前切换的状态  block */
@property (nonatomic , copy) void (^BaseScroll_StateBlock) (BaseScroll_ Enum);

/** 对调完成的  block */
@property (nonatomic , copy) void (^exchengeSuccessBlock) (void);



- (void) changePageToAfter;


// 开始对调
- (void) startExchange;



@end

NS_ASSUME_NONNULL_END
