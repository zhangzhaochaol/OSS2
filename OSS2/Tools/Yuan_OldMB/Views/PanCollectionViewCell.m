//
//  PanCollectionViewCell.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/8/31.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "PanCollectionViewCell.h"

@implementation PanCollectionViewCell
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        CusLabel * textLabel = [[CusLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _textLabel = textLabel;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        //        self.textLabel.numberOfLines = 0;
        self.textLabel.font = [UIFont systemFontOfSize:16.f];
        self.textLabel.textColor = [UIColor blackColor];
        //        self.textLabel.layer.borderColor =[UIColor mainColor].CGColor;
        //        self.textLabel.layer.borderWidth = 1;
        
        self.layer.borderColor = [UIColor mainColor].CGColor;
        self.layer.borderWidth = 1.f;
        
        [self.textLabel setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.textLabel];
        
        self.clipsToBounds = true;
        //        self.textLabel.backgroundColor = [UIColor getStochasticColor];
        
        self.textLabel.outLineWidth = 4;
        
        self.textLabel.outLinetextColor = [UIColor whiteColor];
        
        self.textLabel.labelTextColor = [UIColor blackColor];
        
    }
    return self;
}
@end
