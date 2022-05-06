//
//  Yuan_DOList_HeaderView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/21.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_DOList_HeaderView.h"

@implementation Yuan_DOList_HeaderView
{
    UIButton * _myOrder;
    UIButton * _historyOrder;
    UIView * _line;
    
    NSLayoutConstraint * _lineConstraint;
    
    BOOL _isMLD;
    
    NSString * _firstTitle;
    NSString * _secondTitle;
}


#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        [self UI_Init];
    }
    return self;
}


#pragma mark - 初始化构造方法

- (instancetype)init_MLD {
    
    if (self = [super init]) {
        _isMLD = YES;
        [self UI_Init];
    }
    return self;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithFirst:(NSString *)first
                       Second:(NSString *)second {
    
    if (self = [super init]) {
        _firstTitle = first;
        _secondTitle = second;
        
        [self UI_Init];
    }
    return self;
}


- (void) UI_Init {
    
    _myOrder = [UIView buttonWithTitle:@"我的工单"
                             responder:self
                                   SEL:@selector(myOrderClick)
                                 frame:CGRectNull];
    
    _historyOrder = [UIView buttonWithTitle:@"历史工单"
                                  responder:self
                                        SEL:@selector(historyOrderClick)
                                      frame:CGRectNull];
    
    
    _line = [UIView viewWithColor:Color_V2Red];
    
    [self addSubviews:@[_myOrder,_historyOrder,_line]];
    [self yuan_LayoutSubViews];
    
    
    if (_isMLD) {
        [_myOrder setTitle:@"待审核" forState:UIControlStateNormal];
        [_historyOrder setTitle:@"已审核" forState:UIControlStateNormal];
    }
    
    if (_firstTitle && _secondTitle) {
        [_myOrder setTitle:_firstTitle forState:UIControlStateNormal];
        [_historyOrder setTitle:_secondTitle forState:UIControlStateNormal];
    }
    
}



- (void) yuan_LayoutSubViews {
    
    //float limit = Horizontal(15);
    
    [_myOrder YuanAttributeHorizontalToView:self];
    [_historyOrder YuanAttributeHorizontalToView:self];
    
    [_myOrder autoConstrainAttribute:ALAttributeVertical
                         toAttribute:ALAttributeVertical
                              ofView:self
                      withMultiplier:0.5];
    
    [_historyOrder autoConstrainAttribute:ALAttributeVertical
                              toAttribute:ALAttributeVertical
                                   ofView:self
                           withMultiplier:1.5];
    
    [_line autoSetDimensionsToSize:CGSizeMake(Horizontal(50), Vertical(2))];
    
    _lineConstraint = [_line YuanAttributeVerticalToView:_myOrder];
    [_line autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
}


#pragma mark - btnClick ---

- (void) myOrderClick {
    
    [self choose:Yuan_DOHeaderType_MyOrder];
    
    if (_doHeaderChooseBlock) {
        _doHeaderChooseBlock(Yuan_DOHeaderType_MyOrder);
    }
}


- (void) historyOrderClick {
    
    [self choose:Yuan_DOHeaderType_HistoryOrder];
    
    if (_doHeaderChooseBlock) {
        _doHeaderChooseBlock(Yuan_DOHeaderType_HistoryOrder);
    }
    
}



- (void) choose:(Yuan_DOHeaderType_) type {
    
    _lineConstraint.active = NO;
    
    if (type == Yuan_DOHeaderType_MyOrder) {
        
        _lineConstraint = [_line YuanAttributeVerticalToView:_myOrder];
    }
    else {
        
        _lineConstraint = [_line YuanAttributeVerticalToView:_historyOrder];
    }
}


@end
