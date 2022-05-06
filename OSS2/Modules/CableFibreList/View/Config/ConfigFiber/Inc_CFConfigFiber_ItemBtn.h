//
//  Inc_CFConfigFiber_ItemBtn.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inc_CFConfigFiber_ItemBtn.h"

NS_ASSUME_NONNULL_BEGIN



@interface Inc_CFConfigFiber_ItemBtn : UIButton

/** 设置数据源 */
@property (nonatomic,strong) NSDictionary *dict;

/** 按钮的编号 */
@property (nonatomic ,assign) int index;

/** btn 所在的position */
@property (nonatomic ,assign) NSInteger position ;

/// 配置我的按钮的编号
/// @param num 编号 通过for循环创建
- (void) configMyNum:(int) num;



/// 绑定对应的纤芯的编号
/// @param num 纤芯编号
- (void) configBindingNum:(NSString *) num
                     from:(configBindingNumFrom_)type;



/// 动态赋值时要使用 
- (NSString *) circleArray:(NSMutableArray *)array
                      myId:(NSString *)myId;

@end

NS_ASSUME_NONNULL_END
