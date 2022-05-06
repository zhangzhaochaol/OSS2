//
//  Inc_CFListCollectionItem.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, CollectionListItemState_) {
    
    CollectionListItemState_None,           // 空白边框状态
    CollectionListItemState_Connect,        // 已关联的边框状态
    CollectionListItemState_SelectingNow    // 当前正在选中的边框状态
};

@interface Inc_CFListCollectionItem : UICollectionViewCell

// 根据不同的状态配置图片

// 配置左上角 图片
- (void) imgConfigUpImage:(CF_HeaderCellType_)upType;

// 配置右下角 图片
- (void) imgConfigDownImg:(CF_HeaderCellType_)downType;


- (void) configNum:(NSString *)index;


/// 根据 oprStateId 去判断颜色 占用:绿色 故障:红色
/// @param oprStateId id
- (void) configColor:(NSString *)oprStateId ;


/// 根据枚举值 , 更改他的边框颜色
/// @param colorState color_enum
- (void) configBorderColor:(CollectionListItemState_)colorState;

@end

NS_ASSUME_NONNULL_END
