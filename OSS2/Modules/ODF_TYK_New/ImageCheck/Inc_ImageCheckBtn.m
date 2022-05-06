//
//  Inc_ImageCheckBtn.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/8/10.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_ImageCheckBtn.h"

@interface Inc_ImageCheckBtn ()
{
    UILabel *_titleLabel;
}

@end

@implementation Inc_ImageCheckBtn

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    
        [self createUI];
        
    }
    return self;
}

- (void)createUI {
    _titleLabel  = [UIView labelWithTitle:@"" frame:CGRectNull];
    _titleLabel.font = Font_Yuan(6);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    [_titleLabel YuanToSuper_Top:0];
    [_titleLabel YuanToSuper_Left:0];
    [_titleLabel Yuan_EdgeSize:CGSizeMake(self.width/3, self.width/3)];

}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    _titleLabel.textColor = titleColor;
    [_titleLabel setCornerRadius:0 borderColor:titleColor borderWidth:0.2];
    
    [self setCornerRadius:0 borderColor:titleColor borderWidth:1];


}

@end
