//
//  UIAlert.m
//  守望者
//
//  Created by Ryan on 17/3/15.
//  Copyright © 2017年 Yuan. All rights reserved.
//

#import "UIAlert.h"
#import <UIKit/UIKit.h>
@implementation UIAlert

void Yuan_SmallAlert (NSString * title , NSString * btnMsg) {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:btnMsg style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    
    
}


+ (void) alertSmallTitle:(NSString *)title {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}



+ (void) alertSmallTitle:(NSString *)title
           agreeBtnBlock:(void(^)(UIAlertAction *action))block  {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *IKnowAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 把点击事件回调给调用的界面
        if (block) {
            block(action);
        }
    }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //什么也不做
    }];
    
    
    // Add the actions.
    [alertController addAction:IKnowAction];
    [alertController addAction:cancelAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    
    
    
    
}

/// 单独一个确定按钮的Alert
+ (void) alertSingle_SmallTitle:(NSString *)title
                  agreeBtnBlock:(void(^)(UIAlertAction *action))block  {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *IKnowAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 把点击事件回调给调用的界面
        if (block) {
            block(action);
        }
    }];
    
        
    // Add the actions.
    [alertController addAction:IKnowAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}


+ (void) alertSmallTitle:(NSString *)title
           agreeBtnBlock:(void(^)(UIAlertAction *action))agreeBtnBlock
          cancelBtnBlock:(void(^)(UIAlertAction *action))cancelBtnBlock {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *IKnowAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 把点击事件回调给调用的界面
        if (agreeBtnBlock) {
            agreeBtnBlock(action);
        }
    }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // 把点击事件回调给调用的界面
        if (cancelBtnBlock) {
            cancelBtnBlock(action);
        }
        
    }];
    
    
    // Add the actions.
    [alertController addAction:IKnowAction];
    [alertController addAction:cancelAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    
}



/* 警示框文字提示 , 传入固定的controller (多数为模态下使用) , 需要实现确定按钮的block回调 */
+ (void) alertSmallTitle:(NSString *)title
                      vc:(UIViewController *)vc
           agreeBtnBlock:(void(^)(UIAlertAction *action))block  {
    
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *IKnowAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 把点击事件回调给调用的界面
        if (block) {
            block(action);
        }
    }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //什么也不做
    }];
    
    
    // Add the actions.
    [alertController addAction:IKnowAction];
    [alertController addAction:cancelAction];
    
    // vc 为模态视图控制器 
    [vc presentViewController:alertController animated:YES completion:nil];
}



/* ActionSheet */
+ (void) alertSmallActionSheetTitle:(NSString *)title
                                 vc:(UIViewController *)vc
                         firstTitle:(NSString *)title_First
                        secondTitle:(NSString *)title_Second
                      firstBtnBlock:(void(^)(UIAlertAction *action))block_Fir
                     secondBtnBlock:(void(^)(UIAlertAction *action))block_Sec {
    
    
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    // Create the actions.
    UIAlertAction *first = [UIAlertAction actionWithTitle:title_First
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
        
        // 把点击事件回调给调用的界面
        if (block_Fir) {
            block_Fir(action);
        }
    }];
    
    
    UIAlertAction *second = [UIAlertAction actionWithTitle:title_Second
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
        
        // 把点击事件回调给调用的界面
        if (block_Sec) {
            block_Sec(action);
        }
    }];
    
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //什么也不做
    }];
    
    
    // Add the actions.
    [alertController addAction:first];
    [alertController addAction:second];
    [alertController addAction:cancelAction];
    
    // vc 为模态视图控制器
    [vc presentViewController:alertController animated:YES completion:nil];
}

























#pragma mark - 已废弃 ---


+ (void)showOkayCancelAlertClassHome:(id)classHome title:(NSString *)title message:(NSString *)message cancelBtnTitle:(NSString *)cancelTitle {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    
    

    // Add the actions.
    [alertController addAction:cancelAction];
    
    
    
    [classHome presentViewController:alertController animated:YES completion:nil];
}



+ (void)showAlertClassHome:(id)classHome title:(NSString *)title
             agreeBtnBlock:(void(^)(UIAlertAction *action))block
             agreeBtnTitle:(NSString *)agreeTitle {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *agreeAction = [UIAlertAction actionWithTitle:agreeTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        block(action);
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];


    [alertController addAction:agreeAction];
    [alertController addAction:cancelAction];
    [classHome presentViewController:alertController animated:YES completion:nil];
    
    
    
}





+ (void)showOkayCancelAlertClassHome:(id)classHome
                             message:(NSString *)message {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    

    // Add the actions.
    [alertController addAction:cancelAction];
    
    [classHome presentViewController:alertController animated:YES completion:nil];
}



+ (void)showAlertClassHome:(id)classHome
                   message:(NSString *)message
             agreeBtnBlock:(void(^)(UIAlertAction *action))block  {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *agreeAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        block(action);
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];


    [alertController addAction:agreeAction];
    [alertController addAction:cancelAction];
    [classHome presentViewController:alertController animated:YES completion:nil];
}









@end
