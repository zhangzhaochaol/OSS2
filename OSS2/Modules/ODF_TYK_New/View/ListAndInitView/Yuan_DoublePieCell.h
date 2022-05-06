//
//  Yuan_DoublePieCell.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/29.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Yuan_Pie.h"

NS_ASSUME_NONNULL_BEGIN



@interface Yuan_DoublePieCell : UITableViewCell


/** A */
@property (nonatomic,strong) Yuan_Pie *Pie_A;

/** B */
@property (nonatomic,strong) Yuan_Pie *Pie_B;





/// 根据外界传值 改变按钮的状态
/// @param dict map
/// @param isFaceInverse 当前是否是正面 , true 正面 false 反面
- (void) A_Dict:(NSDictionary *)dict isFaceInverse:(BOOL) isFaceInverse;



/// 根据外界传值 改变按钮的状态
/// @param dict map
/// @param isFaceInverse 当前是否是正面 , true 正面 false 反面
- (void) B_Dict:(NSDictionary *)dict isFaceInverse:(BOOL) isFaceInverse;


@end

NS_ASSUME_NONNULL_END
