//
//  Inc_TE_ExTerminalShowView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
// ****
#import "Inc_TE_ViewModel.h"
NS_ASSUME_NONNULL_BEGIN



@interface Inc_TE_ExTerminalShowView : UIView

- (instancetype)initWithTerminalState:(TE_ExTerminal_)terminalEnum
                             showEnum:(TE_ExTerShow_) showEnum
                                  msg:(NSString *) msg;


- (void) reloadTerminalResName:(NSString *) resName;

@end

NS_ASSUME_NONNULL_END
