//
//  Yuan_NewFL_AZField.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_AZField.h"

@implementation Yuan_NewFL_AZField

{
    
    UILabel * _deviceTitle;
    UIView * _backView;
    
    UILabel * _searchDevice;
    UIButton * _btn;
    
    Yuan_NewFL_AZField_ _AZ;
}

#pragma mark - 初始化构造方法

- (instancetype)initWithAZ:(Yuan_NewFL_AZField_) AZ {
    
    if (self = [super init]) {
        
        _AZ = AZ;
        
        [self UI_Init];
        
    }
    return self;
}


- (void) UI_Init {
    
    
    NSString * title;
    NSString * btnTest;

    if (_AZ == Yuan_NewFL_AZField_A) {
        title = @"A端设备";
        btnTest = @"搜索";
    }
    else if (_AZ == Yuan_NewFL_AZField_Z){
        title = @"Z端设备";
        btnTest = @"搜索";
    }
    else{
        title = @"经过设备";
        btnTest = @"获取";
    }
    
    _deviceTitle = [UIView labelWithTitle:title frame:CGRectNull];
    _deviceTitle.font = Font(15);
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    [_backView cornerRadius:5 borderWidth:1 borderColor:ColorValue_RGB(0xf2f2f2)];
    
    
    _searchDevice = [UIView labelWithTitle:@" " frame:CGRectNull];
    _searchDevice.font = Font_Yuan(13);
    _btn = [UIView buttonWithTitle:btnTest responder:self SEL:@selector(btnClick) frame:CGRectNull];
    [_btn setTitleColor:UIColor.mainColor forState:UIControlStateNormal];
    
    [self addSubviews:@[_deviceTitle,_backView]];
    [_backView addSubviews:@[_searchDevice,_btn]];
    
    [self yuan_LayoutSubViews];
}



- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    
    [_deviceTitle YuanToSuper_Top:limit/2];
    [_deviceTitle YuanToSuper_Left:limit];
    
    [_backView YuanMyEdge:Top ToViewEdge:Bottom ToView:_deviceTitle inset:limit/2];
    [_backView YuanToSuper_Left:limit/2];
    [_backView YuanToSuper_Right:limit/2];
    [_backView YuanToSuper_Bottom:0];
    
    [_searchDevice YuanToSuper_Left:limit/2];
    [_searchDevice YuanToSuper_Top:0];
    [_searchDevice YuanToSuper_Bottom:0];
    [_searchDevice YuanToSuper_Right:80];
    
    [_btn YuanToSuper_Right:limit/2];
    [_btn YuanAttributeHorizontalToView:_searchDevice];
    
}


- (void) btnClick {
    
    if (_AZ_Block) {
        _AZ_Block(_AZ);
    }
}

- (void)clear {
    
    _searchDevice.text = @"";
}


- (void) reloadName:(NSString *) name {
    
    _searchDevice.text = name;
    
}

@end
