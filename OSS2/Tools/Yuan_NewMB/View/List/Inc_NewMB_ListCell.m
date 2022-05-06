//
//  Inc_NewMB_ListCell.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewMB_ListCell.h"

@implementation Inc_NewMB_ListCell

{
    
    UIImageView * _img;
    UILabel * _title;
}



#pragma mark - 初始化构造方法

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self UI_Init];
    }
    return self;
}


- (void) cellImgWithResEnum:(Yuan_NewMB_ModelEnum_)modelEnum
                  cellTitle:(NSString *)title {
    
    _title.text = title;
    
    NSString * imageName = @"";
    
    switch (modelEnum) {
            
        case Yuan_NewMB_ModelEnum_obd:
            imageName = @"YuanMB_OBD";
            break;
            
        case Yuan_NewMB_ModelEnum_voltage_changer:
            imageName = @"YuanMB_VoltageChanger";
            break;
            
        case Yuan_NewMB_ModelEnum_equipment_power:
            imageName = @"YuanMB_EquipmentPower";
            break;

        case Yuan_NewMB_ModelEnum_baseEqp:
            imageName = @"YuanMB_baseEqt";
            break;
            
        case Yuan_NewMB_ModelEnum_MCPE:
            imageName = @"YuanMB_MCPE";
            break;
            
        case Yuan_NewMB_ModelEnum_UTN:
            imageName = @"YuanMB_UTN";
            break;
       
        case Yuan_NewMB_ModelEnum_powerMeterEqp:
            imageName = @"YuanMB_PowerMeterEqp";
            break;

        case Yuan_NewMB_ModelEnum_optSect:
            imageName = @"YuanMB_optSect";
            break;
            
        case Yuan_NewMB_ModelEnum_complexBox:
            imageName = @"YuanMB_complexBox";
            break;
            
        default:
            imageName = @"YuanMB_OBD";
            break;
    }
 
    _img.image = [UIImage Inc_imageNamed:imageName];
    
}



- (void) UI_Init {
    
    _img = [[UIImageView alloc] initWithImage:[UIImage Inc_imageNamed:@""]];
    _title = [UIView labelWithTitle:@"" frame:CGRectNull];
    
    [self.contentView addSubviews:@[_img,_title]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_img YuanToSuper_Left:limit];
    [_img YuanAttributeHorizontalToView:self];
    
    [_title YuanMyEdge:Left ToViewEdge:Right ToView:_img inset:limit];
    [_title YuanToSuper_Right:limit];
    [_title YuanAttributeHorizontalToView:self];
}




@end
