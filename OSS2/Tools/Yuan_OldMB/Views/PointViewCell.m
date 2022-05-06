//
//  PointViewCell.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 16/7/15.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "PointViewCell.h"

@implementation PointViewCell
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0 ,0 ,self.frame.size.width ,self.frame.size.height)];
        _imageView = imageView;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
        
        UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0 ,0 ,self.frame.size.width ,self.frame.size.height)];
        _textLabel = textLabel;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.numberOfLines = 0;
        self.textLabel.font = [UIFont systemFontOfSize:10];
        self.textLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.textLabel];
    }
    return self;
}
@end
