//
//  Inc_TE_ExChangeTerminalStateView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//  修改端子的目标状态

#import "Inc_TE_ExChangeTerminalStateView.h"

// ****
#import "Inc_TE_HttpModel.h"
#import "Inc_TE_ViewModel.h"

@implementation Inc_TE_ExChangeTerminalStateView
{
    
    // 当前状态
    UILabel * _nowState;
    
    // 文字
    UILabel * _changeToLab;
    
    // 目标状态
    UIButton * _exceptState;
    
    
    TerminalStateEnum_ _Enum;
    Inc_TE_ViewModel * _VM;
    
    
    // 当前的端子状态Id
    NSInteger _nowStateId;
    
    // 目标端子状态Id
    NSInteger _exceptStateId;
}

#pragma mark - 初始化构造方法

- (instancetype)initWithNowStateId:(NSInteger) nowStateId
                 TerminalStateEnum:(TerminalStateEnum_)Enum{
    
    if (self = [super init]) {
        
        _Enum = Enum;
        _VM = Inc_TE_ViewModel.shareInstance;
        _nowStateId = nowStateId;
        self.backgroundColor = UIColor.whiteColor;
        [self UI_Init];
    }
    return self;
}



// 刷新目标业务状态Id
- (void) reloadStateId:(NSInteger) newStateId {
    
    _exceptStateId = newStateId;
    
    // 为 viewmodel 赋值
    if (_Enum == TerminalStateEnum_A) {
        _VM.terminal_A_ExceptOprStateId = _exceptStateId;
    }
    else {
        _VM.terminal_B_ExceptOprStateId = _exceptStateId;
    }
    
    
    NSString * msg = [NSString stringWithFormat:@"%@ ●",[_VM msgFromState:_exceptStateId]];
    
    [_exceptState setTitle:msg forState:0];
    [_exceptState setTitleColor:[_VM colorFromState:_exceptStateId needAlpha:NO]
                       forState:0];
}


#pragma mark - click ---

- (void) exceptClick {
    
    if (_exceptBtnBlcok) {
        _exceptBtnBlcok();
    }
    
}


#pragma mark - UI_Init

- (void) UI_Init {
    
    _nowState = [UIView labelWithTitle:[NSString stringWithFormat:@"● %@",[_VM msgFromState:_nowStateId]]
                                 frame:CGRectNull];
    
    _nowState.textColor = [_VM colorFromState:_nowStateId needAlpha:NO];
    
    
    _changeToLab = [UIView labelWithTitle:@"> 状态 >" frame:CGRectNull];
    _changeToLab.textColor = UIColor.lightGrayColor;
    
    
    // 端子A  目标是损坏
    if (_Enum == TerminalStateEnum_A) {
        _exceptStateId = 10;
    }
    // 端子B  目标是占用
    else {
        _exceptStateId = 3;
    }
    
    // 为 viewmodel 赋值
    if (_Enum == TerminalStateEnum_A) {
        _VM.terminal_A_ExceptOprStateId = _exceptStateId;
    }
    else {
        _VM.terminal_B_ExceptOprStateId = _exceptStateId;
    }
    
    
    NSString * msg = [NSString stringWithFormat:@"%@ ●",[_VM msgFromState:_exceptStateId]];
    
    _exceptState = [UIView buttonWithTitle:msg
                                 responder:self
                                       SEL:@selector(exceptClick)
                                     frame:CGRectNull];
    
    [_exceptState setTitleColor:[_VM colorFromState:_exceptStateId needAlpha:NO] forState:0];
    
    
    _nowState.font = _changeToLab.font = _exceptState.titleLabel.font = Font_Yuan(12);
    _nowState.textAlignment = _changeToLab.textAlignment = NSTextAlignmentCenter;
    
    [self addSubviews:@[_nowState , _changeToLab , _exceptState]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float width = ScreenWidth / 2 / 3;
    
    [_nowState YuanToSuper_Left:0];
    [_nowState YuanToSuper_Top:0];
    [_nowState YuanToSuper_Bottom:0];
    [_nowState Yuan_EdgeWidth:width];
    
    [_changeToLab YuanAttributeHorizontalToView:self];
    [_changeToLab YuanMyEdge:Left ToViewEdge:Right ToView:_nowState inset:0];
    [_changeToLab Yuan_EdgeWidth:width];
    
    [_exceptState YuanToSuper_Right:0];
    [_exceptState YuanToSuper_Top:0];
    [_exceptState YuanToSuper_Bottom:0];
    [_exceptState Yuan_EdgeWidth:width];
    
    
    
}

@end
