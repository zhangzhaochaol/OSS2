//
//  Inc_TE_ChooseBtn.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , TE_ChooseBtn_) {
    TE_ChooseBtn_A,
    TE_ChooseBtn_B,
};

@interface Inc_TE_ChooseBtn : UIButton


- (instancetype)initWithEnum:(TE_ChooseBtn_) Enum;


/// 重新刷新 端子状态
- (void) reloadWithState:(NSString *) state resName:(NSString *) resName;

@end

NS_ASSUME_NONNULL_END
