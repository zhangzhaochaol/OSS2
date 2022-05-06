//
//  Yuan_TerminalSelectCableView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/9.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_TerminalSelectCableView : UIView

- (instancetype)initWithCableName:(NSString *)cableName
                            block:(void(^)(void))selectBlock;


- (void)updateCarryName:(NSString *)carryName;

@end

NS_ASSUME_NONNULL_END
