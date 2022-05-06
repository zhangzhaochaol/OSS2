//
//  Yuan_DC_ChangeConfigView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_DC_ChangeConfigView : UIView


/** <#注释#> */
@property (nonatomic , weak) UIViewController * vc;

- (instancetype)initWithTitle:(NSString *) title;


- (void) mySelect:(BOOL)isSelect;


@end

NS_ASSUME_NONNULL_END
