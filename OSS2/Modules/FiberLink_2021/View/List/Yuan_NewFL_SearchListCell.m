//
//  Yuan_NewFL_SearchListCell.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_SearchListCell.h"

@implementation Yuan_NewFL_SearchListCell

{
    
    UIImageView * _img;
    UILabel * _deviceName;
}

#pragma mark - 初始化构造方法

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        
        [self UI_Init];
    }
    return self;
}


- (void) deviceName:(NSString *)name {
    
    _deviceName.text = name;
}


- (void) UI_Init {
    
    _img = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"FL_Route"]
                              frame:CGRectNull];
    
    _deviceName = [UIView labelWithTitle:@"设备名称" frame:CGRectNull];
    _deviceName.numberOfLines = 0;//根据最大行数需求来设置
    _deviceName.lineBreakMode = NSLineBreakByTruncatingTail;
    
    
    [self.contentView addSubviews:@[_img,_deviceName]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_img YuanAttributeHorizontalToView:self.contentView];
    [_img YuanToSuper_Left:limit];
    
    [_deviceName YuanAttributeHorizontalToView:_img];
    [_deviceName YuanToSuper_Left:Horizontal(60)];
    [_deviceName YuanToSuper_Right:limit];
    
}




@end
