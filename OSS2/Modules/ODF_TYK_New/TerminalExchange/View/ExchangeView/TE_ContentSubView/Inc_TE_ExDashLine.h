//
//  Inc_TE_ExDashLine.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

// ****
#import "Inc_TE_ViewModel.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger , TE_ExDashLine_) {
    
    TE_ExDashLine_Xu = 0,           //虚线
    TE_ExDashLine_Fiber,            //实线有纤芯原点
    TE_ExDashLine_Warning,          //虚线有警告红叉
};

@interface Inc_TE_ExDashLine : UIView


- (instancetype)initWithEnum:(TE_ExDashLine_) Enum
                 leftOrRight:(TE_ExTerShow_) showEnum;


@end

NS_ASSUME_NONNULL_END
