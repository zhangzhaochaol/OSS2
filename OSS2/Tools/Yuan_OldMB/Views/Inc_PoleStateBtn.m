//
//  Inc_PoleStateBtn.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/9/6.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_PoleStateBtn.h"

@implementation Inc_PoleStateBtn

{
    
    NSString * _imageName;
    NSString * _titleName;
    UIColor * _textColor;
    
    UIImageView * _img;
    UILabel * _title;
    
}


#pragma mark - 初始化构造方法

- (instancetype)initWithBtnState:(PoleState_)Enum {
    
    if (self = [super init]) {
        
        self.backgroundColor = UIColor.whiteColor;
        
        _myEnum = Enum;
        [self getImageAndTitle];
        
        [self UI_Init];
    }
    return self;
}



#pragma mark - UI_Init

- (void) UI_Init {
    
    _img = [UIView imageViewWithImg:[UIImage Inc_imageNamed:_imageName] frame:CGRectNull];
    _title = [UIView labelWithTitle:_titleName frame:CGRectNull];
    _title.textColor = ColorValue_RGB(0x333333);
    
    [self addSubviews:@[_img,_title]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(10);
    
    
    [_img YuanAttributeHorizontalToView:self];
    [_img YuanToSuper_Left:limit];
    
    [_title YuanAttributeHorizontalToView:self];
    [_title YuanMyEdge:Left ToViewEdge:Right ToView:_img inset:limit];
    
}



- (void)myState_IsSelect:(BOOL)mySelectState {
    
    
    if (_myEnum == PoleState_AddPole || _myEnum == PoleState_AddSupportingPoints) {
        return;
    }
    
    
    if (mySelectState == NO) {
        
        if (_myEnum >= 6) {
            _myEnum -= 3;
        }
    }
    
    
    else {
    
        if (_myEnum < 6) {
            _myEnum += 3;
        }
    }
    
    
    
    [self getImageAndTitle];
    
    _title.text = _titleName;
    _title.textColor = _textColor;
    _img.image = [UIImage Inc_imageNamed:_imageName];

}




#pragma mark - 状态切换 ---

- (void) getImageAndTitle {
    
    switch (_myEnum) {
            
        case PoleState_AddPole:
            _imageName = @"Pole_Add";
            _titleName = @"添加电杆";
            _textColor = ColorValue_RGB(0x333333);
            break;
            
            
        case PoleState_AddSupportingPoints:
            _imageName = @"Pole_Add";
            _titleName = @"添加撑点";
            _textColor = ColorValue_RGB(0x333333);
            break;
            
            
        case PoleState_AddPoleLine:
            _imageName = @"Pole_Connect";
            _titleName = @"关联杆路段";
            _textColor = ColorValue_RGB(0x333333);
            break;
            
            
        case PoleState_NearSupportingPoints:
            _imageName = @"Pole_NearSupportingPoints";
            _titleName = @"附近撑点";
            _textColor = ColorValue_RGB(0x333333);
            break;
            
            
        case PoleState_NearPoleLine:
            _imageName = @"Pole_NearPole";
            _titleName = @"附近电杆";
            _textColor = ColorValue_RGB(0x333333);
            break;

            
        case PoleState_AddPoleLine_Select:
            _imageName = @"Pole_ConnectSelect";
            _titleName = @"确认关联";
            _textColor = UIColor.mainColor;
            break;
            
        default:
            break;
    }
    
    
}



@end
