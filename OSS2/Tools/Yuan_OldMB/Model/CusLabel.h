//
//  CusLabel.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/7/12.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CusLabel : UILabel
@property(strong,nonatomic)NSMutableDictionary *tagDic;
@property (nonatomic, assign) NSInteger outLineWidth;
/** 外轮颜色*/
@property (nonatomic, strong) UIColor *outLinetextColor;
/** 里面字体默认颜色*/
@property (nonatomic, strong) UIColor *labelTextColor;

- (void)drawTextInRect:(CGRect)rect;
@end
