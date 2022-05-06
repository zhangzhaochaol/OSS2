//
//  Inc_CFListTableCell.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CFListTableCell : UITableViewCell

/** 列数 */
@property (nonatomic,strong) UILabel *headerLab;

/** 业务名称 */
@property (nonatomic,strong) UILabel * titleBusiness;


// 根据不同的状态配置图片

// 配置左上角 图片
- (void) imgConfigUpImage:(CF_HeaderCellType_)upType;

// 配置右下角 图片
- (void) imgConfigDownImg:(CF_HeaderCellType_)downType;


// 配置显示文字内容
- (void) configMsg:(NSString *) msg;


// 配置光纤性能
- (void) fiberPerformance:(NSString *) performance  num:(NSString *)num;


/// 根据 oprStateId 去判断颜色 占用:绿色 故障:红色
/// @param oprStateId id
- (void) configColor:(NSString *)oprStateId ;

@end

NS_ASSUME_NONNULL_END
