//
//  Inc_TE_ChooseTopView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TE_ChooseTopView.h"
#import "Inc_TE_ChooseBtn.h"

// ****
#import "Inc_TE_HttpModel.h"
#import "Inc_TE_ViewModel.h"

@implementation Inc_TE_ChooseTopView

{
    Inc_TE_ChooseBtn * _TerminalA;
    Inc_TE_ChooseBtn * _TerminalB;
    
    TE_ChooseTop_ _Enum;
    Inc_TE_ViewModel * _VM;
}

#pragma mark - 初始化构造方法

- (instancetype)initWithEnum:(TE_ChooseTop_)Enum {
    
    if (self = [super init]) {
        
        _Enum = Enum;
        _VM = Inc_TE_ViewModel.shareInstance;
        
        // 默认是A
        _nowState_A_Or_B = true;
        self.backgroundColor = UIColor.whiteColor;
        [self UI_Init];
        
        [self block_Init];
        
    }
    return self;
}


- (void) reloadWithDict:(NSDictionary *) dict{
    
    
    NSString * oprStateId = dict[@"oprStateId"];
    NSString * termName = dict[@"termName"];
    
    if (_nowState_A_Or_B) {
        _VM.Terminal_A_Dict = dict;
        [_TerminalA reloadWithState:oprStateId resName:termName];
        
        // A点击完 需要切换到B
        _nowState_A_Or_B = NO;
        [self borderRed];
    }
    else {
        _VM.Terminal_B_Dict = dict;
        [_TerminalB reloadWithState:oprStateId resName:termName];
    }
    
}


- (void) clear {
    
    [_TerminalA reloadWithState:@"0" resName:@""];
    [_TerminalB reloadWithState:@"0" resName:@""];
}


#pragma mark - method ---

- (void) block_Init {
    
    __typeof(self)weakSelf = self;
    
    weakSelf->_VM.chooseTerminalBlock = ^(NSDictionary * _Nonnull terminalDict) {
        
    };
    
}


/// A 点击事件
- (void) A_Click {
    
    if (_Enum == TE_ChooseTop_FullScreen) {
        return;
    }
    
//    [_TerminalA reloadWithState:@"170002" resName:@"端子名称A"];
    _nowState_A_Or_B = YES;
    [self borderRed];
}

/// B 点击事件
- (void) B_Click {
    
    if (_Enum == TE_ChooseTop_FullScreen) {
        return;
    }
    
//    [_TerminalB reloadWithState:@"170147" resName:@"端子名称B"];
    _nowState_A_Or_B = NO;
    [self borderRed];
}

- (void) borderRed {
    
    
    [_TerminalA cornerRadius:0 borderWidth:1 borderColor:UIColor.f2_Color];
    [_TerminalB cornerRadius:0 borderWidth:1 borderColor:UIColor.f2_Color];
    
    if (_nowState_A_Or_B) {
        [_TerminalA cornerRadius:0 borderWidth:1 borderColor:UIColor.redColor];
    }
    else {
        [_TerminalB cornerRadius:0 borderWidth:1 borderColor:UIColor.redColor];
    }
    
}


#pragma mark - UI_Init

- (void) UI_Init {
    
    _TerminalA = [[Inc_TE_ChooseBtn alloc] initWithEnum:TE_ChooseBtn_A];
    _TerminalB = [[Inc_TE_ChooseBtn alloc] initWithEnum:TE_ChooseBtn_B];
    
    [_TerminalA addTarget:self action:@selector(A_Click) forControlEvents:UIControlEventTouchUpInside];
    [_TerminalB addTarget:self action:@selector(B_Click) forControlEvents:UIControlEventTouchUpInside];
    
    [_TerminalA cornerRadius:0 borderWidth:1 borderColor:UIColor.f2_Color];
    [_TerminalB cornerRadius:0 borderWidth:1 borderColor:UIColor.f2_Color];
    
    
    // 当 选择界面时  , 默认A 是 红色边框
    if (_Enum == TE_ChooseTop_HalfScreen) {
        [_TerminalA cornerRadius:0 borderWidth:1 borderColor:UIColor.mainColor];
    }
    
    // 当 对调界面时 , 直接进行赋值 
    [_TerminalA reloadWithState:_VM.Terminal_A_Dict[@"oprStateId"]
                        resName:_VM.Terminal_A_Dict[@"termName"]];
    
    [_TerminalB reloadWithState:_VM.Terminal_B_Dict[@"oprStateId"]
                        resName:_VM.Terminal_B_Dict[@"termName"]];
    
    
    
    [self addSubviews:@[_TerminalA,_TerminalB]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float Width = ScreenWidth;
    
    if (_Enum == TE_ChooseTop_HalfScreen) {
        Width = ScreenWidth /4 * 3;
    }
    
    
    [_TerminalA YuanToSuper_Left:0];
    [_TerminalA YuanToSuper_Top:0];
    [_TerminalA YuanToSuper_Bottom:0];
    [_TerminalA Yuan_EdgeWidth:Width/2 - 1];
    
    [_TerminalB YuanToSuper_Right:0];
    [_TerminalB YuanToSuper_Top:0];
    [_TerminalB YuanToSuper_Bottom:0];
    [_TerminalB YuanMyEdge:Left ToViewEdge:Right ToView:_TerminalA inset:0];
    
}


@end
