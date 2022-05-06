//
//  Inc_CFListHeaderCell.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CFListHeaderCell.h"

@implementation Inc_CFListHeaderCell

{
    // 起止类型
    CF_HeaderCell_ _header;
    
    // 成端熔断
    CF_HeaderCellType_ _type;
 
    UIImageView * _img;
    
    UIView * _lineFir;

    UIView * _lineSec;
    
    
}


#pragma mark - 初始化构造方法

- (instancetype) initWithEnum:(CF_HeaderCell_)header
                     typeEnum:(CF_HeaderCellType_)type{
    
    if (self = [super init]) {
        
        _header = header;
        _type = type;
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [ColorValue_RGB(0xf2f2f2) CGColor];
        
        [self UI_Config];
        [self layoutAllSubViews];
    }
    return self;
}



- (CF_HeaderCellType_) getCellType {
    
    return _type;
    
}




- (void) UI_Config {
    
    NSString * imgName;
    
    if (_header == CF_HeaderCell_Start) {
        imgName = @"cf_qi";
    }else {
        imgName = @"cf_zhong";
    }
    
    _img = [UIView imageViewWithImg:[UIImage Inc_imageNamed:imgName] frame:CGRectNull];
    
    _lineFir = [UIView viewWithColor:ColorValue_RGB(0xf2f2f2)];
    _lineSec = [UIView viewWithColor:ColorValue_RGB(0xf2f2f2)];
    
    _deviceName = [UIView labelWithTitle:@"设备名称" frame:CGRectNull];
    _deviceName.numberOfLines = 0;//根据最大行数需求来设置
    _deviceName.lineBreakMode = NSLineBreakByTruncatingTail;
    _deviceName.font = Font_Yuan(13);
    
    
    
    _btn = [[UIButton alloc] init];
    _btn.layer.cornerRadius = 3;
    _btn.layer.masksToBounds = YES;
    [_btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btn.titleLabel.font = [UIFont systemFontOfSize:13];
    
    _btn_2 = [[UIButton alloc] init];
    _btn_2.layer.cornerRadius = 3;
    _btn_2.layer.masksToBounds = YES;
    [_btn_2 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btn_2.titleLabel.font = [UIFont systemFontOfSize:13];
    

    _deleteBtn = [[UIButton alloc] init];
    [_deleteBtn setImage:[UIImage Inc_imageNamed:@"cf_cableDelete"]
                forState:UIControlStateNormal];
    
    if (_type == CF_HeaderCellType_ChengDuan) {
        
        [_btn setBackgroundColor:Color_V2Blue];
        [_btn setTitle:@"成端" forState:UIControlStateNormal];
    
        [_btn_2 setBackgroundColor:Color_V2Red];
        [_btn_2 setTitle:@"熔接" forState:UIControlStateNormal];
        
    }
    
    else if (_type == CF_HeaderCellType_RongJie) {
        
        [_btn setBackgroundColor:Color_V2Red];
        [_btn setTitle:@"熔接" forState:UIControlStateNormal];
        
        _btn_2.hidden = YES;
    }
    
    // 其他 例如省界
    else {
        _btn.hidden = YES;
        _btn_2.hidden = YES;
    }
    
    
    
    
    
    
    [self addSubviews:@[_img,
                        _lineFir,
                        _deviceName,
                        _btn_2,
                        _btn,
                        _deleteBtn]];
    
}



#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
 
    // 图片
    [_img autoConstrainAttribute:ALAttributeHorizontal
                     toAttribute:ALAttributeHorizontal
                          ofView:self withMultiplier:1.0];
    
    [_img autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(10)];
    [_img autoSetDimension:ALDimensionWidth toSize:Horizontal(14)];
    
    // 线1
    [_lineFir autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_img withOffset:Horizontal(10)];
    
    [_lineFir autoSetDimensionsToSize:CGSizeMake(1, 15)];
    
    
    // 设备名称
    [_deviceName autoPinEdge:ALEdgeLeft
                      toEdge:ALEdgeRight
                      ofView:_lineFir
                  withOffset:Horizontal(10)];
    
    [_deviceName autoSetDimension:ALDimensionWidth toSize:Horizontal(180)];
    

    float btn_Width = Horizontal(35);
    
    [_deleteBtn YuanAttributeHorizontalToView:self];
    [_deleteBtn YuanToSuper_Right:Horizontal(10)];
    
    // 按钮
    [_btn autoSetDimension:ALDimensionWidth toSize:btn_Width];
    [_btn YuanMyEdge:Right ToViewEdge:Left ToView:_deleteBtn inset:Horizontal(-10)];
    [_btn autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
    
    [_btn_2 autoSetDimensionsToSize:CGSizeMake(btn_Width, Vertical(30))];
    [_btn_2 YuanMyEdge:Right ToViewEdge:Left ToView:_btn inset:-5];
    
    
    [self HorizontalArray:@[_lineFir,_deviceName,_btn,_btn_2,_deleteBtn]];
    
    
    
}


- (void) HorizontalArray:(NSArray *)viewArray {
    
    for (UIView * myView in viewArray) {
        
        [myView autoConstrainAttribute:ALAttributeHorizontal
                           toAttribute:ALAttributeHorizontal
                                ofView:_img
                        withMultiplier:1.0];
    }
    
    
    
    
    
    
}



@end
