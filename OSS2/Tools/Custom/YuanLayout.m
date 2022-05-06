//
//  YuanLayout.m
//  守望
//
//  Created by Ryan on 2018/11/8.
//  Copyright © 2018年 Ryan Treem. All rights reserved.
//

#import "YuanLayout.h"

//判断iPhoneX
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)

//判断iPhone12_Mini
#define DX_Is_iPhone12_Mini ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1080, 2340), [[UIScreen mainScreen] currentMode].size) && !DX_UI_IS_IPAD : NO)

//判断iPhone12 | 12Pro
#define DX_Is_iPhone12 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1170, 2532), [[UIScreen mainScreen] currentMode].size) && !DX_UI_IS_IPAD : NO)

//判断iPhone12 Pro Max
#define DX_Is_iPhone12_ProMax ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1284, 2778), [[UIScreen mainScreen] currentMode].size) && !DX_UI_IS_IPAD : NO)


@implementation YuanLayout

+ (float) YuanLayoutHorizontal : (float)horizontal {

    return (horizontal)*(ScreenWidth)/375;
}

+ (float) YuanLayoutVertical: (float)vertical {
    
    // 刘海屏以前
    if (NaviBarHeight == 64) {
        return vertical * ScreenHeight / 667;
    }
    
    // 刘海屏
    else {
        // X XS
        if (ScreenHeight == 812) {
            return vertical * 724 / 667;
        }
        // XR XS Max
        else if (ScreenHeight == 896) {
            return vertical * 808 / 667;
        }
        // 780 944 926  iphone 12 12mini 12proMax
        else {
            return vertical * (ScreenHeight - 88)  / 667;
        }
    }
    return vertical * ScreenHeight / 667;
}

@end
