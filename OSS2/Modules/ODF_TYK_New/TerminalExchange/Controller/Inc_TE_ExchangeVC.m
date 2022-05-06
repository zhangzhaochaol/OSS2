//
//  Inc_TE_ExchangeVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TE_ExchangeVC.h"

// ****
#import "Inc_TE_ChooseTopView.h"
#import "Inc_TE_ExChangeTerminalStateView.h"
#import "Inc_TE_BaseScrollView.h"


#import "Yuan_TextFieldPicker.h"

// ****
#import "Inc_TE_HttpModel.h"
#import "Inc_TE_ViewModel.h"

@interface Inc_TE_ExchangeVC ()


/** topView */
@property (nonatomic , strong) Inc_TE_ChooseTopView * topView;

/** scroll */
@property (nonatomic , strong) Inc_TE_BaseScrollView * scrollView;


@end

@implementation Inc_TE_ExchangeVC

{
    
    Inc_TE_ViewModel * _VM;
    
    // AB 状态切换
    Inc_TE_ExChangeTerminalStateView * _terminalState_A;
    Inc_TE_ExChangeTerminalStateView * _terminalState_B;
    
    // picker
    Yuan_TextFieldPicker * _picker;
    
    
    // image
    UILabel * _warningMsg ;
    
    
    // 查看 , 对调 , 取消 按钮
    UIButton * _lookResultBtn;
    UIButton * _exchangeBtn;
    UIButton * _cancelBtn;
    
    
    
    // 业务状态 name 和 id 数组
    NSArray * _OprStateNamesArr;
    NSArray * _OprStateIdsArr;
}


#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        
        _VM = Inc_TE_ViewModel.shareInstance;
        [self OprState_DatasConfig];
    }
    return self;
}


- (void) OprState_DatasConfig {
    
    _OprStateIdsArr = @[
         @"1",
         @"2",
         @"4",
         @"5",
         @"6",
         @"7",
         @"11",
         @"12",
         @"3",
         @"8",
         @"10",
         @"9"
    ];
    
    
    _OprStateNamesArr = @[
        @"空闲" ,
        @"预占" ,
        @"预释放" ,
        @"预留" ,
        @"预选" ,
        @"备用" ,
        @"测试" ,
        @"临时占用" ,
        @"占用" ,
        @"停用" ,
        @"损坏" ,
        @"闲置"
    ];
    
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.f2_Color;
    self.title = @"端子对调";
    
    [self UI_Init];
    [self block_Init];
}



#pragma mark - block Init ---

- (void) block_Init {
    
    __typeof(self)weakSelf = self;
    weakSelf->_terminalState_A.exceptBtnBlcok = ^{
        [self showPicker_Enum:TerminalStateEnum_A];
    };
 
    
    weakSelf->_terminalState_B.exceptBtnBlcok = ^{
        [self showPicker_Enum:TerminalStateEnum_B];
    };
    
    
    // 切换 对调前和对调后 ---
    weakSelf->_scrollView.BaseScroll_StateBlock = ^(BaseScroll_ Enum) {
            
        if (Enum == BaseScroll_Before) {
            _exchangeBtn.hidden = YES;
            _lookResultBtn.hidden = NO;
            
            // 非同设备提示
            _warningMsg.hidden = YES;
        }
        else {
            _exchangeBtn.hidden = NO;
            _lookResultBtn.hidden = YES;
            
            // 非同设备提示
            if (_VM.isSameDeviceInOtherSide) {
                _warningMsg.hidden = NO;
            }
            
        }
        
    };
    
    
    
    // 当对调请求完成后 进行的回调
    weakSelf->_scrollView.exchengeSuccessBlock = ^{
      
        // 端子对调成功后 , 调用修改端子业务状态接口
        [self http_ModifyTerminal_OprStateId];
    };
    
    
}


#pragma mark - picker ---


- (void) showPicker_Enum:(TerminalStateEnum_)Enum {
    
    UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [self.view addSubview:textField];
    
    _picker =
    [[Yuan_TextFieldPicker alloc] initWithDataSource:_OprStateNamesArr
                                           textField:textField];
    
    [_picker show];
    
    __typeof(self)weakSelf = self;
    weakSelf->_picker.commitBlock = ^(NSInteger selectIndex) {
        
        NSString * value = _OprStateIdsArr[selectIndex];
        
        
        if (Enum == TerminalStateEnum_A) {
            [_terminalState_A reloadStateId:value.integerValue];
        }
        
        else {
            [_terminalState_B reloadStateId:value.integerValue];
        }
        
    };
}


#pragma mark - btnClick ---

// 查看对调结果 -- 翻页
- (void) lookResultClick {
    
    _exchangeBtn.hidden = NO;
    _lookResultBtn.hidden = YES;
    
    // 切换到下一个 页面
    [_scrollView changePageToAfter];
}

// 开始端子对调接口
- (void) exchangeClick {
    
    [UIAlert alertSmallTitle:@"是否将AB两个端子进行对调?"
               agreeBtnBlock:^(UIAlertAction *action) {
        
        // 发起对调请求
        [_scrollView startExchange];
    }];
}


// 取消
- (void) cancelClick {
    
    Pop(self);
}



#pragma mark - 修改端子的业务状态 ---

/// 修改端子业务状态接口
- (void) http_ModifyTerminal_OprStateId {
    
    NSInteger A_AimOprId = _VM.terminal_A_ExceptOprStateId;
    NSInteger B_AimOprId = _VM.terminal_B_ExceptOprStateId;
    
    NSString * A_Gid = _VM.Terminal_A_Dict[@"GID"];
    NSString * B_Gid = _VM.Terminal_B_Dict[@"GID"];
    
    NSString * resLogicName = _VM.Terminal_A_Dict[@"resLogicName"];
    
    NSArray * postArr = @[
        @{
            @"resLogicName" : resLogicName,
            @"GID" : A_Gid,
            @"oprStateId" : @(A_AimOprId)
        },
        @{
            @"resLogicName" : resLogicName,
            @"GID" : B_Gid,
            @"oprStateId" : @(B_AimOprId)
        }
    ];
    
    
    [Http.shareInstance V2_POST_SendMore:HTTP_TYK_Normal_UpData
                                   array:postArr
                                 succeed:^(id data) {
        
        [YuanHUD HUDFullText:@"端子对调完成"];
        
        if (_TE_SuccessBlock) {
            _TE_SuccessBlock();
        }
        
        Pop(self);
    }];
    
}




#pragma mark - UI_Init

- (void) UI_Init {
    
    
    _topView = [[Inc_TE_ChooseTopView alloc] initWithEnum:TE_ChooseTop_FullScreen];
    
    NSString * stateA = _VM.Terminal_A_Dict[@"oprStateId"];
    NSString * stateB = _VM.Terminal_B_Dict[@"oprStateId"];
    
    _terminalState_A = [[Inc_TE_ExChangeTerminalStateView alloc] initWithNowStateId:stateA.integerValue
                                                                  TerminalStateEnum:TerminalStateEnum_A];
    
    _terminalState_B = [[Inc_TE_ExChangeTerminalStateView alloc] initWithNowStateId:stateB.integerValue
                                                                  TerminalStateEnum:TerminalStateEnum_B];
    
    
    _scrollView = [[Inc_TE_BaseScrollView alloc] init];
    _scrollView.backgroundColor = UIColor.whiteColor;
    
    
    _warningMsg = [UIView labelWithTitle:@" ⚠️ AB端子的对端端子不在同一设备,对调后会造成光路不通,且如果有跳接关系,则会被解除。"
                                   frame:CGRectNull];
    
    [_warningMsg cornerRadius:0 borderWidth:1 borderColor:UIColor.mainColor];
    _warningMsg.textColor = UIColor.mainColor;
    _warningMsg.font = Font_Yuan(12);
    _warningMsg.hidden = YES;
    
    
    _lookResultBtn = [UIView buttonWithTitle:@"查看对调结果"
                                   responder:self
                                         SEL:@selector(lookResultClick)
                                       frame:CGRectNull];
    
    
    _exchangeBtn = [UIView buttonWithTitle:@"开始对调"
                                 responder:self
                                       SEL:@selector(exchangeClick)
                                     frame:CGRectNull];
    
    
    _cancelBtn = [UIView buttonWithTitle:@"取消"
                               responder:self
                                     SEL:@selector(cancelClick)
                                   frame:CGRectNull];
    
    [_lookResultBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    [_exchangeBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    [_cancelBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    
    _exchangeBtn.backgroundColor =_lookResultBtn.backgroundColor = UIColor.mainColor;
    [_exchangeBtn setTitleColor:UIColor.whiteColor forState:0];
    [_lookResultBtn setTitleColor:UIColor.whiteColor forState:0];
    
    _cancelBtn.backgroundColor = ColorValue_RGB(0xd2d2d2);
    [_cancelBtn setTitleColor:UIColor.whiteColor forState:0];
    
    
    // 初始状态下 , 对调按钮是隐藏的
    _exchangeBtn.hidden = YES;
    
    
    [self.view addSubviews:@[_topView ,
                             _terminalState_A ,
                             _terminalState_B ,
                             _scrollView,
                             _lookResultBtn,
                             _exchangeBtn,
                             _cancelBtn,
                             _warningMsg]];
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    float terminalState_Height = Vertical(20);
    
    
    [_topView YuanToSuper_Top:NaviBarHeight];
    [_topView YuanToSuper_Left:0];
    [_topView YuanToSuper_Right:0];
    [_topView Yuan_EdgeHeight:Vertical(50)];
    
    [_terminalState_A YuanMyEdge:Top ToViewEdge:Bottom ToView:_topView inset:0];
    [_terminalState_A YuanToSuper_Left:0];
    [_terminalState_A Yuan_EdgeSize:CGSizeMake(ScreenWidth / 2 - 1, terminalState_Height)];
    
    [_terminalState_B YuanMyEdge:Top ToViewEdge:Bottom ToView:_topView inset:0];
    [_terminalState_B YuanToSuper_Right:0];
    [_terminalState_B Yuan_EdgeSize:CGSizeMake(ScreenWidth / 2 - 1, terminalState_Height)];
    
    [_scrollView YuanToSuper_Left:0];
    [_scrollView YuanToSuper_Right:0];
    [_scrollView YuanMyEdge:Bottom ToViewEdge:Top ToView:_warningMsg inset: - 5];
    [_scrollView YuanToSuper_Top:NaviBarHeight + Vertical(50) + terminalState_Height + 5];
    
    
    
    
    [_warningMsg YuanToSuper_Left:5];
    [_warningMsg YuanToSuper_Right:5];
    [_warningMsg YuanMyEdge:Bottom ToViewEdge:Top ToView:_lookResultBtn inset:-5];
    [_warningMsg Yuan_EdgeHeight:Vertical(35)];
    
    
    [_lookResultBtn YuanToSuper_Bottom:BottomZero + limit/2];
    [_lookResultBtn YuanToSuper_Left:limit];
    [_lookResultBtn Yuan_EdgeSize:CGSizeMake(Horizontal(150), Vertical(40))];
    
    
    [_exchangeBtn YuanToSuper_Bottom:BottomZero + limit/2];
    [_exchangeBtn YuanToSuper_Left:limit];
    [_exchangeBtn Yuan_EdgeSize:CGSizeMake(Horizontal(150), Vertical(40))];
    
    
    [_cancelBtn YuanToSuper_Bottom:BottomZero + limit/2];
    [_cancelBtn YuanToSuper_Right:limit];
    [_cancelBtn Yuan_EdgeSize:CGSizeMake(Horizontal(150), Vertical(40))];
    
}


@end
