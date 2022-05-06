//
//  Inc_AlltermCell.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_AlltermCell : UITableViewCell

//光路
@property (nonatomic, strong) NSDictionary *dic;

//光缆段
@property (nonatomic, strong) NSDictionary *cableDic;

//承载业务
@property (nonatomic, strong) NSDictionary *carryingDic;

//label回调
@property (copy, nonatomic) void(^labelBlock)(UILabel * label);

@end

NS_ASSUME_NONNULL_END
