//
//  Yuan_ImageTerminalBtn.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/3.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_ImageTerminalBtn : UIButton
/** btn对应的Dict */
@property (nonatomic , copy) NSDictionary * myDict;


/** <#注释#> */
@property (nonatomic , assign) BOOL isSmall;

/** <#注释#> */
@property (nonatomic , assign) BOOL isBig;

@end

NS_ASSUME_NONNULL_END
