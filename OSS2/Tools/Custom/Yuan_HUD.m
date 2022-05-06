//
//  Yuan_HUD.m
//  FTP图影音
//
//  Created by 袁全 on 2020/3/27.
//  Copyright © 2020 袁全. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Yuan_HUD.h"
#import "MBProgressHUD.h"




@implementation Yuan_HUD {
    
    MBProgressHUD * HUD;
    
    
    
}



+ (Yuan_HUD *) shareInstance {
    
    static Yuan_HUD *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}



#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
        HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
        animated:YES];
    }
    return self;
}



- (void) HUDFullText:(NSString *)text {
    
    // 拿到主线程中刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!HUD) {
            
            HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                       animated:YES];
        }
        
        [HUD showAnimated:YES];
            
        HUD.detailsLabel.text = text;
        
        //纯文本HUD枚举
        HUD.mode = MBProgressHUDModeText;
        
        [HUD hideAnimated:YES afterDelay:2];
        
        HUD = nil;
    });
    

}


- (void) HUDFullText:(NSString *)text delay:(float)delay {
    
    // 拿到主线程中刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!HUD) {
            
            HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                       animated:YES];
        }
        
        [HUD showAnimated:YES];
            
        HUD.detailsLabel.text = text;
        
        //纯文本HUD枚举
        HUD.mode = MBProgressHUDModeText;
        
        [HUD hideAnimated:YES afterDelay:delay];
        
        HUD = nil;
    });
    

}



- (void) HUDStartText:(NSString *)text {
    
    // 拿到主线程中刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!HUD) {
            
            HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                       animated:YES];
        }
        
        [HUD showAnimated:YES];
            
        HUD.label.text = text;
        
        //纯文本HUD枚举
        HUD.mode = MBProgressHUDModeIndeterminate;
    });
    


}



- (void) HUDHide {
    
    // 拿到主线程中刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [HUD hideAnimated:YES];
        HUD = nil;
    });
    
    
}



- (void) HUDHideText:(NSString *)text {
    
    // 拿到主线程中刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        
        HUD.mode = MBProgressHUDModeText ;
        
        HUD.label.text = text;
        
        [HUD hideAnimated:YES afterDelay:2];
        
        HUD = nil;
    });
    

    
}






@end
