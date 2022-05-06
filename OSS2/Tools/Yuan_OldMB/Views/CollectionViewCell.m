//
//  CollectionViewCell.m
//  OSS2.0-ios-v1
//
//  Created by 孟诗萌 on 16/4/24.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0 ,0 ,self.frame.size.width ,self.frame.size.height - 35)];
        _imageView = imageView;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
        
        UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 35)];
        _textLabel = textLabel;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.numberOfLines = 0;
        self.textLabel.font = [UIFont systemFontOfSize:14];
//        self.textLabel.font = [UIFont systemFontOfSize:13];
        self.textLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.textLabel];
    }
    return self;
}

@end
