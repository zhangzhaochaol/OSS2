//
//  Inc_TE_ExTerminalShowView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TE_ExTerminalShowView.h"

@implementation Inc_TE_ExTerminalShowView
{
    
    TE_ExTerminal_ _myTerminalEnum;
    TE_ExTerShow_ _myShowEnum;
    
    UILabel * _ring;
    UILabel * _msg;
    
    NSString * _text;
    
    
}


- (instancetype)initWithTerminalState:(TE_ExTerminal_)terminalEnum
                             showEnum:(TE_ExTerShow_) showEnum
                                  msg:(NSString *) msg {
    
    if (self = [super init]) {
        
        _myTerminalEnum = terminalEnum;
        _myShowEnum = showEnum;
        _text = msg;
        [self UI_Init];
    }
    return self;
    
}


- (void) reloadTerminalResName:(NSString *) resName {
    
    _msg.text = resName;
    
}


#pragma mark - UI_Init

- (void) UI_Init {
    
    UIColor * d2Color = ColorValue_RGB(0xe2e2e2);
    
    _ring = [UIView labelWithTitle:@"" frame:CGRectNull];
    _ring.textAlignment = NSTextAlignmentCenter;
    _ring.font = Font_Bold_Yuan(18);
    
    _msg = [UIView labelWithTitle:_text ?: @"" frame:CGRectNull];
    _msg.backgroundColor = d2Color;
    _msg.font = Font_Yuan(12);
    _msg.lineBreakMode = NSLineBreakByTruncatingHead;
    
    
    [_ring cornerRadius:Horizontal(20) borderWidth:1 borderColor:d2Color];
    [_msg cornerRadius:5 borderWidth:0 borderColor:nil];
    
    
    switch (_myTerminalEnum) {
            
        case TE_ExTerminal_Warning:
            
            [_ring cornerRadius:Horizontal(20) borderWidth:1 borderColor:UIColor.mainColor];
            [_msg cornerRadius:5 borderWidth:1 borderColor:UIColor.mainColor];
            break;
            
        case TE_ExTerminal_A:
            
            [_ring cornerRadius:Horizontal(20) borderWidth:1 borderColor:UIColor.orangeColor];
            _ring.text = @"A";
            break;
            
        case TE_ExTerminal_B:
            
            [_ring cornerRadius:Horizontal(20) borderWidth:1 borderColor:UIColor.orangeColor];
            _ring.text = @"B";
            break;
            
        default:
            break;
    }
    
    [self addSubviews:@[_ring,_msg]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    if (_myShowEnum == TE_ExTerShow_Left) {
        
        
        [_ring YuanToSuper_Right:0];
        [_ring YuanAttributeHorizontalToView:self];
        [_ring Yuan_EdgeSize:CGSizeMake(Horizontal(40), Horizontal(40))];
        
        
        [_msg YuanToSuper_Top:0];
        [_msg YuanToSuper_Left:limit/2];
        [_msg YuanToSuper_Bottom:0];
        [_msg YuanMyEdge:Right ToViewEdge:Left ToView:_ring inset:-limit/2];
        
        _msg.textAlignment = NSTextAlignmentLeft;
    }
    
    else {
        
        
        [_ring YuanToSuper_Left:0];
        [_ring YuanAttributeHorizontalToView:self];
        [_ring Yuan_EdgeSize:CGSizeMake(Horizontal(40), Horizontal(40))];
        
        
        [_msg YuanToSuper_Top:0];
        [_msg YuanToSuper_Right:limit/2];
        [_msg YuanToSuper_Bottom:0];
        [_msg YuanMyEdge:Left ToViewEdge:Right ToView:_ring inset:limit/2];
        
        _msg.textAlignment = NSTextAlignmentRight;
        
    }
    
    
    
    
}


@end
