//
//  UIView+YuanFrame.h
//  INCP&EManager
//
//  Created by 袁全 on 2020/4/22.
//  Copyright © 2020 Unigame.space. All rights reserved.
//




#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (YuanFrame)


@property (assign, nonatomic) CGFloat Yuan_x;
@property (assign, nonatomic) CGFloat Yuan_y;
@property (assign, nonatomic) CGFloat Yuan_width;
@property (assign, nonatomic) CGFloat Yuan_height;
@property (assign, nonatomic) CGSize Yuan_size;
@property (assign, nonatomic) CGPoint Yuan_origin;

- (void) cornerRadius:(float)cornerRadius
          borderWidth:(float)width
          borderColor:(nullable UIColor *)borderColor;

@end

NS_ASSUME_NONNULL_END
