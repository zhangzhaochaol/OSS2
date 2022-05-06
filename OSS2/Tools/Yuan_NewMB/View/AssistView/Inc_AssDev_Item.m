//
//  Inc_AssDev_Item.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/14.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_AssDev_Item.h"

@implementation Inc_AssDev_Item

{
    UIImageView * _img;
    
    UILabel * _title;
}

#pragma mark - 初始化构造方法

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self UI_Init];
    }
    return self;
}


- (void) reloadImg:(NSString *) imgName title:(NSString *) title {
    
    _img.image = [UIImage Inc_imageNamed:imgName];
    _title.text = title;
}




- (void) UI_Init {
    
    _img = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"instruments"]
                              frame:CGRectNull];
    _title = [UIView labelWithTitle:@"名称" frame:CGRectNull];
    _title.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubviews:@[_img,_title]];
    [self yuan_LayoutSubViews];
}

- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(5);
    
    [_img YuanToSuper_Top:limit];
    [_img YuanAttributeVerticalToView:self.contentView];
    [_img autoSetDimensionsToSize:CGSizeMake(Horizontal(70), Horizontal(70))];
    
    [_title YuanAttributeVerticalToView:self.contentView];
    [_title YuanToSuper_Bottom:limit];
    
    [_title YuanToSuper_Left:limit];
    [_title YuanToSuper_Right:limit];
    
}

@end
