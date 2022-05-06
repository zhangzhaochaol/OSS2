//
//  Inc_TE_ExLinkType_NameView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//  局向光纤

#import "Inc_TE_ExLinkType_NameView.h"

@implementation Inc_TE_ExLinkType_NameView

{
    
    UILabel * _resTypeName;
    UILabel * _resName;
}



#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        [self UI_Init];
    }
    return self;
}


- (void) reloadWithResType:(NSString *) resTypeName
                   resName:(NSString *) resName {
    

    if ([resTypeName isEqualToString:@"无"]) {
        _resTypeName.textAlignment = NSTextAlignmentLeft;
    }
    
    else {
        _resTypeName.textAlignment = NSTextAlignmentCenter;
        [_resTypeName cornerRadius:0 borderWidth:1 borderColor:UIColor.orangeColor];
    }
    
    
    
    _resTypeName.text = resTypeName;
    _resName.text = resName;
    
}



#pragma mark - UI_Init

- (void) UI_Init {
    
    
    _resTypeName = [UIView labelWithTitle:@" " frame:CGRectNull];
    _resTypeName.backgroundColor = UIColor.whiteColor;

    
    _resName = [UIView labelWithTitle:@" " frame:CGRectNull];
    _resName.font = Font_Yuan(12);
    
    [self addSubviews:@[_resTypeName,
//                        _resName
    ]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    [_resTypeName YuanToSuper_Top:2];
    [_resTypeName YuanToSuper_Left:2];
    [_resTypeName YuanToSuper_Right:2];
//    [_resTypeName Yuan_EdgeHeight:Vertical(20)];
    
    [_resTypeName YuanToSuper_Bottom:2];
    
    return;
    
    [_resName YuanMyEdge:Top ToViewEdge:Bottom ToView:_resTypeName inset:2];
    [_resName YuanToSuper_Left:2];
    [_resName YuanToSuper_Right:2];
    [_resName YuanToSuper_Bottom:2];
    
    
    
}

@end
