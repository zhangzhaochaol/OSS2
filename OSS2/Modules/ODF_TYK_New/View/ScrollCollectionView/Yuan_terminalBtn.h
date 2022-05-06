//
//  Yuan_terminalBtn.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/4.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_terminalBtn : UIButton

/** 数据源 */
@property (nonatomic,strong) NSDictionary *dict;

/** 按钮的编号 */
@property (nonatomic ,assign) int index;

/** 按钮所属绑卡 */
@property (nonatomic , assign) NSInteger position;


/// 修改业务状态 ID 让按钮改变颜色
/// @param oprStateId oprStateId
- (void) change_OprStateId:(NSString *)oprStateId;




- (void) showMyUnionPhotoState:(NSDictionary *)unionDict;

- (void) hideMyUnionPhotoState:(BOOL) isNeedClearUnionLabel;



/// 2021年1月新增

- (BOOL) isNeedChangeState;


/// 2021年3月新增 , 红色边框
- (void) redBorder:(BOOL)isNeedRedBorder;

@end

NS_ASSUME_NONNULL_END
