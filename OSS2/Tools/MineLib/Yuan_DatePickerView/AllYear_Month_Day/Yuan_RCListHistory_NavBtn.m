//
//  Yuan_RCListHistory_NavBtn.m
//  INCP&EManager
//
//  Created by 袁全 on 2020/6/17.
//  Copyright © 2020 Unigame.space. All rights reserved.
//

#import "Yuan_RCListHistory_NavBtn.h"


@interface Yuan_RCListHistory_NavBtn ()

/** icon */
@property (nonatomic,strong) UIImageView *img;

/** 文字 */
@property (nonatomic,strong) UILabel *title_txt;

@end

@implementation Yuan_RCListHistory_NavBtn

{
    
    NSString * _title;
    
    RC_ListHistoryBtn_SelectType _type;  //初始化类型
}


- (instancetype)initWithTitle:(NSString * )title
   NavBtnChangeImageWithType:(RC_ListHistoryBtn_SelectType)type

{
    self = [super init];
    if (self) {
        
        _title = title;
        _type = type;
        
        [self addSubview:self.img];
        [self addSubview:self.title_txt];
        [self layoutAllSubViews];
        
        [self NavBtnChangeImageWithType:_type];
        
    }
    return self;
}


/// 根据枚举值 改变按钮状态
/// @param type 枚举
- (void) NavBtnChangeImageWithType:(RC_ListHistoryBtn_SelectType)type  {
    
    if (type == RC_ListHistoryBtn_SelectType_Normal) {
        // 未选中
        _img.image = [UIImage Inc_imageNamed:@"chuangjian_icon_normal"];
    }else {
        // 选中
        _img.image = [UIImage Inc_imageNamed:@"chuangjian_icon_selected"];
    }
    
    
}



- (UIImageView *)img {
    
    if (!_img) {
        _img = [[UIImageView alloc] init];
        _img.image = [UIImage Inc_imageNamed:@"chuangjian_icon_normal"];
    }
    return _img;
}


- (UILabel *)title_txt {
    
    if (!_title_txt) {
        _title_txt = [UIView labelWithTitle:_title frame:CGRectNull];
        _title_txt.font = [UIFont systemFontOfSize:13];
    }
    return _title_txt;
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    float border_length = Horizontal(15);
    
    // 图片
    [_img autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    
    [_img autoConstrainAttribute:ALAttributeHorizontal
                     toAttribute:ALAttributeHorizontal
                          ofView:self
                  withMultiplier:1.0];
    
    [_img autoSetDimensionsToSize:CGSizeMake(border_length, border_length)];
    
    _img.layer.cornerRadius = border_length/2;
    _img.layer.masksToBounds = YES;
    
    
    // 文字
    
    [_title_txt autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_img withOffset:2];
    [_title_txt autoConstrainAttribute:ALAttributeHorizontal
                           toAttribute:ALAttributeHorizontal
                                ofView:self
                        withMultiplier:1.0];
    
    [_title_txt autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    
}
@end

