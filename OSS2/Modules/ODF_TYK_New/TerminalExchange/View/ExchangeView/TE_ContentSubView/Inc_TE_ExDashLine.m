//
//  Inc_TE_ExDashLine.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TE_ExDashLine.h"

@implementation Inc_TE_ExDashLine

{
    
    UIImageView * _line;
    // 线上的标识
    UIImageView * _sympolImgInLine;
    UIImageView * _sympol_JumpFiber;
    
    TE_ExDashLine_ _Enum;
    TE_ExTerShow_ _showEnum;
}

#pragma mark - 初始化构造方法

- (instancetype)initWithEnum:(TE_ExDashLine_) Enum leftOrRight:(TE_ExTerShow_) showEnum{
    
    if (self = [super init]) {
        
        _Enum = Enum;
        _showEnum = showEnum;
                
        [self UI_Init];
    }
    return self;
}


#pragma mark - UI_Init

- (void) UI_Init {
    
    NSString * imageName = @"TE_XuLine";
    NSString * sympolImageName = @"";
    NSString * sympol_JumpFiberName = @"";
    
    if (_Enum == TE_ExDashLine_Fiber) {
        imageName = @"TE_ShiLine";
        sympolImageName = @"TE_FiberBall";
    }
    
    if (_Enum == TE_ExDashLine_Xu) {
        imageName = @"TE_XuLine";
        
        if (_showEnum == TE_ExTerShow_Left) {
            sympol_JumpFiberName = @"TE_JumpTerminal_Left";
        }
        else {
            sympol_JumpFiberName = @"TE_JumpTerminal_Right";
        }
        
    }
    
    if (_Enum == TE_ExDashLine_Warning) {
        imageName = @"TE_XuLine";
        sympolImageName = @"TE_Warning";
        
        if (_showEnum == TE_ExTerShow_Left) {
            sympol_JumpFiberName = @"TE_JumpTerminal_Left";
        }
        else {
            sympol_JumpFiberName = @"TE_JumpTerminal_Right";
        }
    }

    
    
    _line = [UIView imageViewWithImg:[UIImage Inc_imageNamed:imageName]
                               frame:CGRectNull];
    
    _sympolImgInLine = [UIView imageViewWithImg:[UIImage Inc_imageNamed:sympolImageName]
                                          frame:CGRectNull];
    
    _sympol_JumpFiber = [UIView imageViewWithImg:[UIImage Inc_imageNamed:sympol_JumpFiberName]
                                           frame:CGRectNull];
    
    
    if (sympolImageName.length == 0) {
        _sympolImgInLine.hidden = YES;
    }
    
    if (sympol_JumpFiberName.length == 0) {
        _sympol_JumpFiber.hidden = YES;
    }
        
    
    [self addSubviews:@[_line,_sympolImgInLine,_sympol_JumpFiber]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(21);
    
    
    if (_showEnum == TE_ExTerShow_Left) {
        [_line YuanToSuper_Right:limit];
    }
    
    else {
        [_line YuanToSuper_Left:limit];
    }

    [_line YuanToSuper_Top:0];
    [_line YuanToSuper_Bottom:0];
    [_line Yuan_EdgeWidth:2];
    
    [_sympolImgInLine YuanAttributeHorizontalToView:self];
    [_sympolImgInLine YuanAttributeVerticalToView:_line];
    
    
    if (_showEnum == TE_ExTerShow_Left) {
        [_sympol_JumpFiber YuanToSuper_Right:Horizontal(50)];
    }
    else {
        [_sympol_JumpFiber YuanToSuper_Left:Horizontal(50)];
    }
    
    [_sympol_JumpFiber YuanAttributeHorizontalToView:self];
    
}


@end
