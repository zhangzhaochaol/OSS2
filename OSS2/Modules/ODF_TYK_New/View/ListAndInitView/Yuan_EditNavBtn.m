//
//  Yuan_EditNavBtn.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/28.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_EditNavBtn.h"


@interface Yuan_EditNavBtn ()

/** 图片 */
@property (nonatomic,strong) UIImageView *img;

/** 文字 */
@property (nonatomic,strong) UILabel *text;

@end

@implementation Yuan_EditNavBtn

#pragma mark - 初始化构造方法

- (instancetype) initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.img];
        [self addSubview:self.text];
        [self layoutAllSubViews];
    }
    return self;
}



- (void) setTxt:(NSString *)txt {
    
    _text.text = txt;
    
}


#pragma mark - 懒加载


- (UIImageView *)img {
    
    if (!_img) {
        _img = [[UIImageView alloc] init];
        _img.image = [UIImage Inc_imageNamed:@"bianji"];
    }
    return _img;
}


- (UILabel *)text {
    
    if (!_text) {
        _text = [UIView labelWithTitle:@"编辑" frame:CGRectNull];
        _text.font = [UIFont systemFontOfSize:14];
        _text.textColor = [UIColor whiteColor];
    }
    return _text;
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    [_img autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [_img autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self withMultiplier:1.0];
    
    [_text autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_img withOffset:1];
    [_text autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self withMultiplier:1.0];
    
    [_text autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
}


@end
