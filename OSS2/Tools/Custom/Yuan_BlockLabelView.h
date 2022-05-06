//
//  Yuan_BlockLabelView.h
//  INCP&EManager
//
//  Created by 袁全 on 2020/7/29.
//  Copyright © 2020 智能运维. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_BlockLabelView : UIView

- (instancetype) initWithBlockColor:(UIColor *)color
                              title:(NSString *)title;

- (void) title:(NSString *)title ;

- (void) blockColor:(UIColor *)color;

- (void) font:(float)font_fl;

@end

NS_ASSUME_NONNULL_END
