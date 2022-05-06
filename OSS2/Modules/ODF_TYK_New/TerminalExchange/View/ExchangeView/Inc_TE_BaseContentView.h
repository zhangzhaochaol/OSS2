//
//  Inc_TE_BaseContentView.h
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



@interface Inc_TE_BaseContentView : UIView

- (instancetype)initWithEnum:(BaseScroll_) Enum
                       frame:(CGRect) frame;



/// 根据端子对应的链路数据 , 初始化
- (void) reloadFrom_ADict:(NSDictionary *) terminal_LinkDict_A
                    BDict:(NSDictionary *)terminal_LinkDict_B;



/// 根据特殊模式下的数据. 
- (void) reloadSpecialEnum:(TE_ContentSpecialMode_) specialModel
                     ADict:(NSDictionary *) terminal_LinkDict_A
                     BDict:(NSDictionary *)terminal_LinkDict_B;

@end

NS_ASSUME_NONNULL_END
