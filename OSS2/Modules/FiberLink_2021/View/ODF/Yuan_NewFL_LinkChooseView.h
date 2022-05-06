//
//  Yuan_NewFL_LinkChooseView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , LinkChooseType_) {
    LinkChooseType_First,
    LinkChooseType_Second,
};


@interface Yuan_NewFL_LinkChooseView : UIButton

- (instancetype)initWithType:(LinkChooseType_) type;
- (void) reloadAddress:(NSString *)address;

@end

NS_ASSUME_NONNULL_END
