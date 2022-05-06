//
//  Yuan_ODFInit_ShowCell.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/2.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_ODFInit_ShowCell.h"





@implementation Yuan_ODFInit_ShowCell


#pragma mark - 初始化构造方法

- (instancetype) initWithStyle:(UITableViewCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.key];
        [self.contentView addSubview:self.value];
        
        [self layoutAllSubViews];
        
    }
    return self;
}


#pragma mark -  UI **** **** **** **** **** ****

- (UILabel *)key {
    
    if (!_key) {
        _key = [UIView labelWithTitle:@"标题" frame:CGRectNull];
        _key.textColor = ColorValue_RGB(0x606060);
        _key.textAlignment = NSTextAlignmentLeft;
    }
    return _key;
}


- (UILabel *)value {
    
    if (!_value) {
        _value = [UIView labelWithTitle:@"值" frame:CGRectNull];
        _value.textColor = ColorValue_RGB(0x000000);
        
        _value.numberOfLines = 0;
        _value.lineBreakMode = NSLineBreakByTruncatingTail;
        _value.textAlignment = NSTextAlignmentRight;
        _value.font = [UIFont systemFontOfSize:13];
    }
    return _value;
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    [_key autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(15)];
    [_key autoConstrainAttribute:ALAttributeHorizontal
                     toAttribute:ALAttributeHorizontal
                          ofView:self.contentView
                  withMultiplier:1.0];
    
    
    [_value autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(15)];
    [_value autoConstrainAttribute:ALAttributeHorizontal
                       toAttribute:ALAttributeHorizontal
                            ofView:self.contentView
                    withMultiplier:1.0];
    [_value autoSetDimension:ALDimensionWidth toSize:Horizontal(220)];
    
}

@end
