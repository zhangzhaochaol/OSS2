//
//  Yuan_NewFL2_InsertWindow.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/10/25.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL2_InsertWindow.h"

@implementation Yuan_NewFL2_InsertWindow
{
    
    UIView * _backView;
    
    UILabel * _Title;
    
    UIView * _line;
    
    UIButton * _insertPointBtn;
    UIButton * _insertRouteBtn;
    
    InsertWindowFromType_ _Enum;
    
}
#pragma mark - 初始化构造方法

- (instancetype)initWithFrame:(CGRect)frame Enum:(InsertWindowFromType_) Enum {
    
    if (self = [super initWithFrame:frame]) {
        
        _Enum = Enum;
        [self UI_Init];
    }
    return self;
}


#pragma mark - btnClick ---

// 插入节点
- (void) insertPointClick {
    if (_insertTypeBlock) {
        _insertTypeBlock(NO);
    }
}

// 插入局向光纤
- (void) insertRouteClick {
    if (_insertTypeBlock) {
        _insertTypeBlock(YES);
    }
}


#pragma mark - UI_Init

- (void) UI_Init {
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    [_backView cornerRadius:10 borderWidth:0 borderColor:nil];
    
    _Title = [UIView labelWithTitle:@"操作选择" frame:CGRectNull];
    _line = [UIView viewWithColor:UIColor.f2_Color];
    
    _insertPointBtn = [UIView buttonWithImage:@"FL_InsertPoint"
                                    responder:self
                                    SEL_Click:@selector(insertPointClick)
                                        frame:CGRectNull];
    
    _insertRouteBtn = [UIView buttonWithImage:@"FL_InsertRoute"
                                    responder:self
                                    SEL_Click:@selector(insertRouteClick)
                                        frame:CGRectNull];
    
    
    [self addSubviews:@[_backView]];
    
    [_backView addSubviews:@[_Title,_line,_insertPointBtn,_insertRouteBtn]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(10);
    
    [_backView YuanAttributeHorizontalToView:self];
    [_backView YuanAttributeVerticalToView:self];
    [_backView Yuan_EdgeWidth:Horizontal(300)];
    [_backView Yuan_EdgeHeight:Vertical(200)];
    
    [_Title YuanAttributeVerticalToView:self];
    [_Title YuanToSuper_Top:limit];
    
    [_line YuanMyEdge:Top ToViewEdge:Bottom ToView:_Title inset:limit];
    [_line YuanToSuper_Left:0];
    [_line YuanToSuper_Right:0];
    [_line Yuan_EdgeHeight:1];
    
    
    // 从光链路进入
    if (_Enum == InsertWindowFromType_Links) {
        
        [_insertPointBtn YuanAttributeHorizontalToView:self];
        [_insertPointBtn YuanToSuper_Left:limit * 5];
        
        [_insertRouteBtn YuanAttributeHorizontalToView:self];
        [_insertRouteBtn YuanToSuper_Right:limit * 5];
    }
    
    // 从局向光纤进入
    else {
        [_insertPointBtn YuanAttributeHorizontalToView:self];
        [_insertPointBtn YuanAttributeVerticalToView:self];
    }
    
}

@end
