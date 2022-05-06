//
//  Yuan_NewFL_ChooseAddTypeView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/23.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_ChooseAddTypeView.h"
#import "Yuan_BlockLabelView.h"

@implementation Yuan_NewFL_ChooseAddTypeView

{
    Yuan_BlockLabelView * _blockView;
    UIButton * _cancelBtn;
    
    UIButton * _ChengD_Btn;
    UIButton * _RongJ_Btn;
}


#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        self.backgroundColor = UIColor.whiteColor;
        [self UI_Init];
    }
    return self;
}


- (void) UI_Init {
    
    _blockView = [[Yuan_BlockLabelView alloc] initWithBlockColor:UIColor.mainColor title:@"请选择连接方式"];
    
    _cancelBtn = [UIView buttonWithImage:@"icon_guanbi"
                               responder:self
                               SEL_Click:@selector(cancelClick)
                                   frame:CGRectNull];
    
    _ChengD_Btn = [UIView buttonWithTitle:@"成端"
                                responder:self
                                      SEL:@selector(chengD_Click)
                                    frame:CGRectNull];
    
    _RongJ_Btn = [UIView buttonWithTitle:@"熔接"
                               responder:self
                                     SEL:@selector(rongJ_Click)
                                   frame:CGRectNull];
    
    [self addSubviews:@[_blockView,_cancelBtn,_ChengD_Btn,_RongJ_Btn]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15) / 2;
    
    [_blockView YuanToSuper_Left:limit];
    [_blockView YuanToSuper_Top:0];
    [_blockView autoSetDimension:ALDimensionHeight toSize:Vertical(40)];

    [_cancelBtn YuanAttributeHorizontalToView:_blockView];
    [_cancelBtn YuanToSuper_Right:limit];
    
    [_ChengD_Btn YuanToSuper_Left:limit];
    [_ChengD_Btn YuanMyEdge:Top ToViewEdge:Bottom ToView:_blockView inset:0];
    [_ChengD_Btn YuanToSuper_Right:0];
    [_ChengD_Btn autoSetDimension:ALDimensionHeight toSize:Vertical(40)];

    [_RongJ_Btn YuanToSuper_Left:limit];
    [_RongJ_Btn YuanMyEdge:Top ToViewEdge:Bottom ToView:_ChengD_Btn inset:0];
    [_RongJ_Btn YuanToSuper_Right:0];
    [_RongJ_Btn autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    
    
    
}


- (void) cancelClick {
    
    if (_chooseAddTypeBlock) {
        _chooseAddTypeBlock(NewFL_ChooseAddType_Cancel);
    }
}


- (void) chengD_Click {
    
    if (_chooseAddTypeBlock) {
        _chooseAddTypeBlock(NewFL_ChooseAddType_ChengDuan);
    }
}


- (void) rongJ_Click {
    
    if (_chooseAddTypeBlock) {
        _chooseAddTypeBlock(NewFL_ChooseAddType_RongJie);
    }
}




@end
