//
//  UIView+YuanFrame.m
//  INCP&EManager
//
//  Created by 袁全 on 2020/4/22.
//  Copyright © 2020 Unigame.space. All rights reserved.
//

#import "UIView+YuanFrame.h"


@implementation UIView (YuanFrame)




- (void)setYuan_x:(CGFloat)Yuan_x {
    
    CGRect frame = self.frame;
    frame.origin.x = Yuan_x;
    self.frame = frame;
}

- (CGFloat)Yuan_x {
    
    return self.frame.origin.x;
}



- (void)setYuan_y:(CGFloat)Yuan_y {
    
    CGRect frame = self.frame;
    frame.origin.y = Yuan_y;
    self.frame = frame;
}


- (CGFloat)Yuan_y {
    
    return self.frame.origin.y;
}




- (void)setYuan_width:(CGFloat)Yuan_width {
    
    CGRect frame = self.frame;
    frame.size.width = Yuan_width;
    self.frame = frame;
}


- (CGFloat)Yuan_width {
    return self.frame.size.width;
}




- (void)setYuan_height:(CGFloat)Yuan_height {
    
    CGRect frame = self.frame;
    frame.size.height = Yuan_height;
    self.frame = frame;
}


- (CGFloat)Yuan_height {
    
    return self.frame.size.height;
}




- (void)setYuan_size:(CGSize)Yuan_size {
    
    CGRect frame = self.frame;
    frame.size = Yuan_size;
    self.frame = frame;
}

- (CGSize)Yuan_size {
    
    return self.frame.size;
}




- (void)setYuan_origin:(CGPoint)Yuan_origin {
    
    CGRect frame = self.frame;
    frame.origin = Yuan_origin;
    self.frame = frame;
}



- (CGPoint)Yuan_origin {
    
    return self.frame.origin;
}


- (void) cornerRadius:(float)cornerRadius
          borderWidth:(float)width
          borderColor:(nullable UIColor *)borderColor {
    
    if (!borderColor) {
        borderColor = UIColor.clearColor;
    }
    
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    
    self.layer.borderWidth = width;
    self.layer.borderColor = borderColor.CGColor;
}

@end
