//
//  LinePipeTableViewCell.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/1/9.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinePipeTableViewCell : UITableViewCell
@property (nonatomic,strong)NSDictionary *dict;
@property (nonatomic,strong)UIView *backView;//背景图片
@property (nonatomic,strong)NSString *type;//0光缆 1光缆段 2端子 3管孔承载缆段/备用承载缆段  4OCC 
@end
