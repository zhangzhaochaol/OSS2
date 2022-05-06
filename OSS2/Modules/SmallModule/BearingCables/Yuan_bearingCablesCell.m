//
//  Yuan_bearingCablesCell.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/9/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_bearingCablesCell.h"

@implementation Yuan_bearingCablesCell



#pragma mark - 初始化构造方法

- (instancetype) initWithStyle:(UITableViewCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _bearingCables_Name = [UIView labelWithTitle:@"名称"
                                               frame:CGRectNull];
        
        _bearingCables_Name.numberOfLines = 0;//根据最大行数需求来设置
        _bearingCables_Name.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [self.contentView addSubview:_bearingCables_Name];
        [self layoutAllSubViews];
    }
    return self;
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    float limit = Horizontal(15);
    [_bearingCables_Name YuanAttributeHorizontalToView:self.contentView];
    [_bearingCables_Name autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_bearingCables_Name autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
}

@end
