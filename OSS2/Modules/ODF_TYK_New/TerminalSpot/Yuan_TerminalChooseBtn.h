//
//  Yuan_TerminalChooseBtn.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_TerminalChooseBtn : UIButton



- (instancetype)initWithIndex:(NSInteger) index;

- (void) reloadTerminal_Index : (NSString *) Terminal_Index;

/** 是否已经赋值了? */
@property (nonatomic , assign , readonly) BOOL isAlreadyValue;

/** 选择的position */
@property (nonatomic , assign) NSInteger myPosition;


@end

NS_ASSUME_NONNULL_END
