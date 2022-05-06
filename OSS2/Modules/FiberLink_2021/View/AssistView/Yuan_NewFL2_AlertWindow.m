//
//  Yuan_NewFL2_AlertWindow.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/10/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL2_AlertWindow.h"

@implementation Yuan_NewFL2_AlertWindow
{
    
    UIView * _backView;
    UILabel * _TitleLabel;
    UILabel * _msgLabel;
    
    UIButton * _goBtn;
    UIButton * _cancelBtn;
    
    
    AlertWindow_ _myEnum;
}



#pragma mark - 初始化构造方法

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self UI_Init];
    }
    return self;
}

#pragma mark - method ---

- (void) reloadWithEnum:(AlertWindow_) Enum {
    
    _myEnum = Enum;
    
    NSString * btnTitle = @"";
    NSString * msg = @"";

    switch (Enum) {
        case AlertWindow_TF:
            btnTitle = @"强制执行";
            msg = @"检测到已经存在 '成端/熔接' 关系,强制选择后已经存在的关系会被解除，确定更换吗？";
            break;
            
        case AlertWindow_Route:
            btnTitle = @"查看局向光纤";
            msg = @"检测到已经存在 '局向光纤' 关系,无法进行更换，如果更换可以点击【查看局向光纤】后解除关系后再次更换？";
            break;
            
        case AlertWindow_Link:
            btnTitle = @"查看光路路由";
            msg = @"检测到已经存在 '光路路由' 关系,无法进行更换，如果更换可以点击【查看光路路由】后解除关系后再次更换？";
            break;
            
        default:
            break;
    }
    
    [_goBtn setTitle:btnTitle forState:0];
    _msgLabel.text = msg;
    
}


#pragma mark - btnClick ---


- (void) goClick {
    
    if (!_AlertGoBlock) {
        [YuanHUD HUDFullText:@"未实现block"];
        return;
    }
    
    switch (_myEnum) {
        
        case AlertWindow_TF:
            
            // 强制交换
            _AlertGoBlock(AlertChooseType_ConstraintExchange);
            break;
            
        case AlertWindow_Link:
        case AlertWindow_Route:
            
            // 查看
            _AlertGoBlock(AlertChooseType_Look);
            break;
            
        default:
            break;
    }
}


- (void) cancelClick {
    
    if (_AlertGoBlock) {
        // 取消
        _AlertGoBlock(AlertChooseType_Cancel);
    }
}


#pragma mark - UI_Init

- (void) UI_Init {
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    [_backView cornerRadius:10 borderWidth:0 borderColor:nil];
    
    _TitleLabel = [UIView labelWithTitle:@"端子路由检测" frame:CGRectNull];
    _TitleLabel.font = Font_Bold_Yuan(16);
    
    _msgLabel = [UIView labelWithTitle:@"内容" frame:CGRectNull];
    
    _goBtn = [UIView buttonWithTitle:@"go"
                           responder:self
                                 SEL:@selector(goClick)
                               frame:CGRectNull];
    
    _cancelBtn = [UIView buttonWithTitle:@"取消"
                               responder:self
                                     SEL:@selector(cancelClick)
                                   frame:CGRectNull];
    
    [_goBtn cornerRadius:0 borderWidth:1 borderColor:UIColor.f2_Color];
    [_cancelBtn cornerRadius:0 borderWidth:1 borderColor:UIColor.f2_Color];
    
    [self addSubviews:@[_backView]];
    [_backView addSubviews:@[_TitleLabel,_msgLabel,_goBtn,_cancelBtn]];
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(10);
    
    float backWidth = Horizontal(300);
    
    [_backView YuanAttributeHorizontalToView:self];
    [_backView YuanAttributeVerticalToView:self];
    [_backView Yuan_EdgeSize:CGSizeMake(backWidth, Vertical(200))];
    
    [_TitleLabel YuanAttributeVerticalToView:self];
    [_TitleLabel YuanToSuper_Top:limit];
    
    [_msgLabel YuanToSuper_Left:limit];
    [_msgLabel YuanToSuper_Right:limit];
    [_msgLabel YuanMyEdge:Top ToViewEdge:Bottom ToView:_TitleLabel inset:limit/2];
    [_msgLabel YuanToSuper_Bottom:Vertical(40)];
    
    [_goBtn YuanToSuper_Left:0];
    [_goBtn Yuan_EdgeWidth:backWidth/2];
    [_goBtn YuanMyEdge:Top ToViewEdge:Bottom ToView:_msgLabel inset:0];
    [_goBtn YuanToSuper_Bottom:0];
    
    [_cancelBtn YuanToSuper_Right:0];
    [_cancelBtn Yuan_EdgeWidth:backWidth/2 - 1];
    [_cancelBtn YuanMyEdge:Top ToViewEdge:Bottom ToView:_msgLabel inset:0];
    [_cancelBtn YuanToSuper_Bottom:0];
    
}

@end
