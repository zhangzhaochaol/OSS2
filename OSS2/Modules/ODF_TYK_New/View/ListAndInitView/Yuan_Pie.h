//
//  Yuan_Pie.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/28.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, PieState) {
    
    PieState_Normal_Gray = 0,           // 未选中状态
    PieState_Colorful = 1               // 选中状态
};


@interface Yuan_Pie : UIButton



/** 第几个 */
@property (nonatomic ,assign) NSInteger index;


/** 关闭按钮 */
@property (nonatomic,strong) UIButton *guanBi_Btn;


/** 盘对应的dict */
@property (nonatomic,strong) NSDictionary *dict;



/// 根据盘的状态 初始化
/// @param state 状态
- (instancetype) initWithState:(PieState)state;

- (instancetype)initWithFrame:(CGRect)frame
                        State:(PieState)state;






/// 切换盘的状态
/// @param state 盘的状态
- (void) changePieState:(PieState)state;


/// 获取当前的state状态
- (PieState) getNowPieState;



/// 切换编辑状态
/// @param isEditStat 当前状态是否是编辑状态 ?  false是退出编辑状态 true 进入编辑状态
- (void) changeEditState:(BOOL) isEditStat
           isFaceInverse:(BOOL)isFaceInverse;





/// 配置左上角的数字
/// @param count 数字字符串
- (void) setCountNum:(NSString *)count;


@end

NS_ASSUME_NONNULL_END
