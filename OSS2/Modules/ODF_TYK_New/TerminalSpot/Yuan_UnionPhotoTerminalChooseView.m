//
//  Yuan_UnionPhotoTerminalChooseView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_UnionPhotoTerminalChooseView.h"
#import "Yuan_TerminalChooseBtn.h"
#import "Yuan_PhotoCheckVM.h"
@implementation Yuan_UnionPhotoTerminalChooseView

{
    
    UILabel * _msg;
    
    Yuan_TerminalChooseBtn * _btnOne;
    Yuan_TerminalChooseBtn * _btnTwo;
    
    UIButton * _enterBtn;
    
    NSInteger _nowSelectIndex;
    
    Yuan_PhotoCheckVM * _PhotoVM;
}


#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        [self UI_Init];
        self.backgroundColor = ColorValue_RGB(0xf2f2f2);
        
        _PhotoVM = Yuan_PhotoCheckVM.shareInstance;
        // 默认选第一个
        _nowSelectIndex = 1;
        [self choose];
    }
    return self;
}


- (void) reloadDataWithIndex:(NSInteger) index position:(NSInteger)position {
    

    NSString * msg = [NSString stringWithFormat:@"%ld-%ld",position,index];
    
    if (_nowSelectIndex == 1) {
        [_btnOne reloadTerminal_Index:msg];
        _btnOne.myPosition = position;
        _PhotoVM.position_Start = position;
    }
    
    else {
        [_btnTwo reloadTerminal_Index:msg];
        _btnTwo.myPosition = position;
        _PhotoVM.position_End = position;
    }
    
}


- (void) UI_Init {
    
    _msg = [UIView labelWithTitle:@"⚠️请分别选择与图片1,2对应的端子,按确认结束"
                            frame:CGRectNull];
    
    _btnOne = [[Yuan_TerminalChooseBtn alloc] initWithIndex:1];
    _btnTwo = [[Yuan_TerminalChooseBtn alloc] initWithIndex:2];
    [_btnOne addTarget:self action:@selector(btnOneClick) forControlEvents:UIControlEventTouchUpInside];
    [_btnTwo addTarget:self action:@selector(btnTwoClick) forControlEvents:UIControlEventTouchUpInside];

    _enterBtn = [UIView buttonWithTitle:@"确认" responder:self SEL:@selector(enterClick) frame:CGRectNull];
    [_enterBtn cornerRadius:3 borderWidth:0 borderColor:UIColor.clearColor];
    [_enterBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _enterBtn.backgroundColor = UIColor.mainColor;
    
    
    [self addSubviews:@[_msg,_btnOne,_btnTwo,_enterBtn]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    float btnWidth = Horizontal(80);
    
    [_msg YuanToSuper_Top:limit];
    [_msg YuanToSuper_Left:limit];
    
    [_btnOne YuanToSuper_Left:limit];
    [_btnOne YuanMyEdge:Top ToViewEdge:Bottom ToView:_msg inset:limit];
    
    [_btnTwo YuanAttributeHorizontalToView:_btnOne];
    [_btnTwo YuanMyEdge:Left ToViewEdge:Right ToView:_btnOne inset:limit];
    
    [_enterBtn YuanAttributeHorizontalToView:_btnOne];
    [_enterBtn YuanMyEdge:Left ToViewEdge:Right ToView:_btnTwo inset:limit];
    
    [_btnOne autoSetDimensionsToSize:CGSizeMake(btnWidth, btnWidth/2)];
    [_btnTwo autoSetDimensionsToSize:CGSizeMake(btnWidth, btnWidth/2)];
    [_enterBtn autoSetDimensionsToSize:CGSizeMake(btnWidth, btnWidth/2)];
}


#pragma mark -  btnClick ---

- (void) enterClick {
    
    
    if (!_btnOne.isAlreadyValue || !_btnTwo.isAlreadyValue) {
        [YuanHUD HUDFullText:@"请选择起始和终止位置"];
        return;
    }
    
    
    if (_btnOne.myPosition == _btnTwo.myPosition) {
        [YuanHUD HUDFullText:@"起始终止不能在同一排"];
        return;
    }
    
    
    //点击后将消失
    if (_enterClickBlock) {
        [UIAlert alertSmallTitle:@"是否确认选择?"
                    agreeBtnBlock:^(UIAlertAction *action) {
            _enterClickBlock();
        }] ;
    }
}


- (void) btnOneClick {
    
    _nowSelectIndex = 1;
    [self choose];
}


- (void) btnTwoClick {
    
    _nowSelectIndex = 2;
    [self choose];
}


- (void) choose {
    
    [_btnOne cornerRadius:0 borderWidth:0 borderColor:UIColor.clearColor];
    [_btnTwo cornerRadius:0 borderWidth:0 borderColor:UIColor.clearColor];
    
    
    if (_nowSelectIndex == 1) {
        [_btnOne cornerRadius:0 borderWidth:1 borderColor:UIColor.mainColor];
    }
    else {
        [_btnTwo cornerRadius:0 borderWidth:1 borderColor:UIColor.mainColor];
    }
}

@end
