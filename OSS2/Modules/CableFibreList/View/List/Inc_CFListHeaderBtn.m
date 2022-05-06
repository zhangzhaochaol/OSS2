//
//  Inc_CFListHeaderBtn.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CFListHeaderBtn.h"

@implementation Inc_CFListHeaderBtn

{
    
    /** 按钮类型 */
    UILabel * _btnType;

    /** 数量 */
    UILabel * _count;
    
}
#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
        
        _btnType = [UIView labelWithTitle:@"纤芯数量" frame:CGRectNull];
        _btnType.textColor = ColorValue_RGB(0x888888);
        _btnType.font = [UIFont systemFontOfSize:14];
        
        
        _count = [UIView labelWithTitle:@"123" frame:CGRectNull];
        _count.font = [UIFont fontWithName:@"Helvetica-Bold" size:15]; //加粗
        _count.textAlignment = NSTextAlignmentCenter;
        _btnType.textAlignment = NSTextAlignmentCenter;
        
        [self addSubviews:@[_btnType,_count]];
        [self layoutAllSubViews];
    }
    return self;
}


/// 配置设备类型和数量
- (void) btnType:(NSString *)btnType
           count:(NSString *)count {
    
    if (btnType && count) {
        
        _btnType.text = btnType;
        _count.text = count;
    }
    
    if ([btnType isEqualToString:@"纤芯数量"]) {
        _count.textColor = Color_V2Red;
    }
    
    if ([btnType isEqualToString:@"成端数量"]) {
        _count.textColor = Color_V2Blue;
    }
    
    
}

- (void) text :(NSString *)text {
    
    _count.text = text;
    
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    [_btnType autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_btnType autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_btnType autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    
    
    [_count autoConstrainAttribute:ALAttributeVertical
                       toAttribute:ALAttributeVertical
                            ofView:self
                    withMultiplier:1.0];
    
    
    [_count autoPinEdge:ALEdgeTop
                 toEdge:ALEdgeBottom
                 ofView:_btnType
             withOffset:Vertical(5)];
    
    
}


@end
