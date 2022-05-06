//
//  Yuan_BatchHoldView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , BatchHold_) {
    BatchHold_Enter,
    BatchHold_Cancel,
    BatchHold_Clear,
};


@interface Yuan_BatchHoldView : UIView

/** block  block */
@property (nonatomic , copy) void (^BatchHold_StateBlock) (BatchHold_ holdType);

@end

NS_ASSUME_NONNULL_END
