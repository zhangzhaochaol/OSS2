//
//  Inc_DeviceTitleView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/8/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_DeviceTitleView.h"

@interface Inc_DeviceTitleView ()
{
    //切换按钮
    UIButton *_titleBtn;
}

@end


@implementation Inc_DeviceTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColor.clearColor;

        [self createUI];
        
    }
    return self;
}

- (void)createUI {
    
    _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_titleBtn  addTarget:self action:@selector(titleBntClick:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBtn setImage:[UIImage Inc_imageNamed:@"zzc_fanmian"] forState:UIControlStateSelected];
    [_titleBtn setImage:[UIImage Inc_imageNamed:@"zzc_zhengmain"] forState:UIControlStateNormal];
    _titleBtn.adjustsImageWhenHighlighted = NO;
    
    [self addSubview:_titleBtn];
    
    [_titleBtn autoCenterInSuperview];

}

- (void)titleBntClick:(UIButton *)btn{
    
    if (self.btnClickBlock) {
        self.btnClickBlock(btn.selected);
    }
    
    btn.selected = !btn.selected;

}

//不添加 titleView 无法点击
- (CGSize)intrinsicContentSize{
    return UILayoutFittingExpandedSize;
}

@end
