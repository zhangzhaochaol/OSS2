//
//  Yuan_TerminalChooseBtn.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_TerminalChooseBtn.h"

@implementation Yuan_TerminalChooseBtn

{
    
    
    NSInteger _myIndex;
    
    UILabel * _position; // 1 或 2
    
    // 端子选择后 的 position - Index
    UILabel * _ScrollTerminal_Index;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithIndex:(NSInteger) index {
    
    if (self = [super init]) {
        _myIndex = index;
        [self UI_Init];
        self.backgroundColor = UIColor.whiteColor;
    }
    return self;
}


- (void) reloadTerminal_Index : (NSString *) Terminal_Index {
    
    _ScrollTerminal_Index.text = Terminal_Index;
    _isAlreadyValue = YES;
}






- (void) UI_Init {
    
    
    _position = [UIView labelWithTitle:[Yuan_Foundation fromInteger:_myIndex]
                                 frame:CGRectNull];
    
    _ScrollTerminal_Index = [UIView labelWithTitle:@" " frame:CGRectNull];
    
    _position.textAlignment = NSTextAlignmentCenter;
    _ScrollTerminal_Index.textAlignment = NSTextAlignmentCenter;
    
    [_position cornerRadius:0 borderWidth:1 borderColor:ColorValue_RGB(0xf2f2f2)];
    [_ScrollTerminal_Index cornerRadius:0 borderWidth:1 borderColor:ColorValue_RGB(0xf2f2f2)];
    
    [self addSubviews:@[_position,_ScrollTerminal_Index]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    [_position YuanToSuper_Left:0];
    [_position YuanToSuper_Top:0];
    [_position YuanToSuper_Bottom:0];
    [_position autoSetDimension:ALDimensionWidth toSize:Horizontal(40)];
    
    [_ScrollTerminal_Index YuanMyEdge:Left ToViewEdge:Right ToView:_position inset:0];
    [_ScrollTerminal_Index YuanToSuper_Top:0];
    [_ScrollTerminal_Index YuanToSuper_Bottom:0];
    [_ScrollTerminal_Index YuanToSuper_Right:0];
}

@end
