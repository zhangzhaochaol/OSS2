//
//  Inc_CFListHeaderCell.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@interface Inc_CFListHeaderCell : UIView

/** 设备名称 */
@property (nonatomic,strong) UILabel * deviceName;

/** 按钮 */
@property (nonatomic,strong) UIButton * btn;

/** 当成端时 , 会多出一个熔接按钮 */
@property (nonatomic , strong) UIButton * btn_2;

/** 批量移除光缆段成端关系 */
@property (nonatomic , strong) UIButton * deleteBtn;

- (CF_HeaderCellType_) getCellType;



/// 根据不同类别 生成不同的cell
/// @param header 开始还是终止
/// @param type 成端还是熔接
- (instancetype) initWithEnum:(CF_HeaderCell_)header
                     typeEnum:(CF_HeaderCellType_)type;



@end

NS_ASSUME_NONNULL_END
