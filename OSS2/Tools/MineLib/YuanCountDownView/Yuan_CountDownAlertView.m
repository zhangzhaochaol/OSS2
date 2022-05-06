//
//  Yuan_CountDownAlertView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/11/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_CountDownAlertView.h"

@implementation Yuan_CountDownAlertView

{
    
    NSString * _headerTitle;
    NSString * _detailMsg;
    NSInteger _time;
    NSTimer * _timer;


    UIView * _backView;
    UILabel * _headerTitleLab;
    
    UIView * _detailView;
    UILabel * _detailMsgLab;
    
    UIButton * _btn;
    
    
}


#pragma mark - 初始化构造方法

/// 文字描述 文字详细信息弹框
- (instancetype)initWithSecond:(NSInteger) time
                   headerTitle:( NSString * _Nullable ) headerTitle
                     detailMsg:( NSString * _Nullable ) detailMsg {
    
    if (self = [super initWithFrame:UIScreen.mainScreen.bounds]) {
        
        _headerTitle = headerTitle ?: @"";
        _detailMsg = detailMsg ?: @"";
        
        _time = time + 1;
        
        [self UI_Init];
        [self timeStart];
    }
    return self;
}



#pragma mark - Click ---

- (void) btnClick {
    
    [self timeEnd];
    
    if (_CountDownAlertBlock) {
        _CountDownAlertBlock();
    }
}



- (void) timeClick {
    
    if (_time == 0) {
        
        [self btnClick];
        return;
    }
    
    _time = _time - 1;
    
    NSString * btnTime = [NSString stringWithFormat:@"确认 (%lds)",_time];
    [_btn setTitle:btnTime forState:0];
}



- (void) timeStart {
    
    // 开始定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(timeClick)
                                            userInfo:nil
                                             repeats:true];

    // 网络请求成功后 fire;
    [_timer fire];
    
}


- (void) timeEnd {
    [_timer invalidate];
    _timer = nil;
}



#pragma mark - UI_Init

- (void) UI_Init {
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    [_backView cornerRadius:10 borderWidth:0 borderColor:nil];
    
    _headerTitleLab = [UIView labelWithTitle:_headerTitle frame:CGRectNull];
    _detailMsgLab = [UIView labelWithTitle:_detailMsg frame:CGRectNull];
    
    _detailView = [UIView viewWithColor:UIColor.whiteColor];
    [_detailView cornerRadius:5 borderWidth:1 borderColor:UIColor.f2_Color];
    
    NSString * btnTime = [NSString stringWithFormat:@"确认 (%lds)",_time + 1];
    
    _btn = [UIView buttonWithTitle:btnTime
                         responder:self
                               SEL:@selector(btnClick)
                             frame:CGRectNull];
    
    [_btn cornerRadius:5 borderWidth:0 borderColor:nil];
    _btn.backgroundColor = UIColor.mainColor;
    [_btn setTitleColor:UIColor.whiteColor forState:0];
    
    [self addSubview:_backView];
    
    [_backView addSubviews:@[_headerTitleLab,
                             _detailView,
                             _btn]];
    
    [_detailView addSubview:_detailMsgLab];
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_backView YuanAttributeHorizontalToView:self];
    [_backView YuanAttributeVerticalToView:self];
    
    [_backView Yuan_EdgeHeight:Vertical(200)];
    [_backView Yuan_EdgeWidth:Horizontal(300)];
    
    
    [_headerTitleLab YuanToSuper_Top:limit];
    [_headerTitleLab YuanAttributeVerticalToView:self];
    
    
    [_detailView YuanToSuper_Left:limit];
    [_detailView YuanToSuper_Right:limit];
    [_detailView YuanMyEdge:Top
                 ToViewEdge:Bottom
                     ToView:_headerTitleLab
                      inset:limit];
    
    [_detailView YuanToSuper_Bottom:Vertical(50)];
    
    [_detailMsgLab YuanToSuper_Top:limit/2];
    [_detailMsgLab YuanToSuper_Left:limit/2];
    [_detailMsgLab YuanToSuper_Right:limit/2];
    [_detailMsgLab YuanToSuper_Bottom:limit/2];
    
    
    [_btn YuanToSuper_Left:limit];
    [_btn YuanToSuper_Right:limit];
    [_btn YuanToSuper_Bottom:limit/2];
    [_btn YuanMyEdge:Top ToViewEdge:Bottom ToView:_detailView inset:limit/2];
    
    
    
    
}




@end
