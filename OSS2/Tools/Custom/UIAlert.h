//
//  UIAlert.h
//  守望者
//
//  Created by Ryan on 17/3/15.
//  Copyright © 2017年 Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAlert : NSObject


void Yuan_SmallAlert (NSString * title , NSString * btnMsg);


/* 警示框文字提示 , 点击后即关闭 */
+ (void) alertSmallTitle:(NSString *)title;
/* 警示框文字提示 , 需要实现我知道了的block回调 */
+ (void) alertSmallTitle:(NSString *)title
           agreeBtnBlock:(void(^)(UIAlertAction *action))block ;


/* 警示框文字提示 , 传入固定的controller (多数为模态下使用) , 需要实现确定按钮的block回调 */
+ (void) alertSmallTitle:(NSString *)title
                      vc:(UIViewController *)vc
           agreeBtnBlock:(void(^)(UIAlertAction *action))block ;


/// 单独一个确定按钮的Alert
+ (void) alertSingle_SmallTitle:(NSString *)title
                  agreeBtnBlock:(void(^)(UIAlertAction *action))block ;

+ (void) alertSmallTitle:(NSString *)title
           agreeBtnBlock:(void(^)(UIAlertAction *action))agreeBtnBlock
          cancelBtnBlock:(void(^)(UIAlertAction *action))cancelBtnBlock;


/* ActionSheet */
+ (void) alertSmallActionSheetTitle:(NSString *)title
                                 vc:(UIViewController *)vc
                         firstTitle:(NSString *)title_First
                        secondTitle:(NSString *)title_Second
                      firstBtnBlock:(void(^)(UIAlertAction *action))block_Fir
                     secondBtnBlock:(void(^)(UIAlertAction *action))block_Sec;














#pragma mark - 已废弃 ---

+ (void)showOkayCancelAlertClassHome:(id)classHome
                             message:(NSString *)message DEPRECATED_MSG_ATTRIBUTE("已弃用的方法 , 依然可以但不建议使用");;





+ (void)showAlertClassHome:(id)classHome
                   message:(NSString *)message
             agreeBtnBlock:(void(^)(UIAlertAction *action))block DEPRECATED_MSG_ATTRIBUTE("已弃用的方法 , 依然可以但不建议使用");;


+ (void)showOkayCancelAlertClassHome:(id)classHome
                               title:(NSString *)title
                             message:(NSString *)message
                      cancelBtnTitle:(NSString *)cancelTitle
                 DEPRECATED_MSG_ATTRIBUTE("已弃用的方法 , 依然可以但不建议使用");


+ (void)showAlertClassHome:(id)classHome title:(NSString *)title
             agreeBtnBlock:(void(^)(UIAlertAction *action))block
             agreeBtnTitle:(NSString *)agreeTitle       DEPRECATED_MSG_ATTRIBUTE("已弃用的方法 , 依然可以但不建议使用");



@end
