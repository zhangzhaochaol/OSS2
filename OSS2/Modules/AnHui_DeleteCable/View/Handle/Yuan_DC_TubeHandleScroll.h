//
//  Yuan_DC_TubeHandleScroll.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/12.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , TubeHandleType_) {
    TubeHandleType_Father,
    TubeHandleType_Children
};


@interface Yuan_DC_TubeHandleScroll : UIView



- (void) reloadTitle:(NSString *)name dataSource:(NSArray *)dataSource;


/** 按钮的点击事件  block */
@property (nonatomic , copy) void (^tubeHandleBtnBlock) (NSDictionary * btnDict , TubeHandleType_ type);

@end

NS_ASSUME_NONNULL_END
