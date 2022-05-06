//
//  IWPColor.h
//  IWPColorDemo
//
//  Created by 王旭焜 on 2016/5/27.
//  Copyright © 2016年 王旭焜. All rights reserved.
//

///////////////////////////////////////////////////////////////////////////////////////////
//        IWPColor 第二版 2016年05月27日
//       支援透過十六進制的顏色代碼字符串來設置view的顏色,支援取得隨機顏色(在循環創建view時可以方便的區
//    分各個view的位置), 增加了新的顏色----Tiffany藍;
//
//       調用說明: hexString支援格式: #AARRGGBB 或 #RRGGBB 或 #RGB (使用時請確保你知道#RGB的含義)
///////////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>

@interface UIColor (IWPColor)
/**
 *  重设颜色的透明度
 *
 *  @param alpha 想要设置的透明度 0.f~1.f;
 *
 *  @return 重设后的颜色
 */
- (UIColor *)setAlpha:(CGFloat)alpha;
/**
 * 透過字符串創建顏色
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;
/**
 * 取隨機色
 */
+ (UIColor *)getStochasticColor;
/**
 * 取隨機色
 */
+ (UIColor *)anyColor;
/**
 * tiffany藍
 */
+ (UIColor *)tiffanyBlue;
/**
 *  從圖片取色
 */
+ (UIColor *)colorwithImage:(NSString *)imageName;
+ (UIColor *)mainColor;
+ (UIColor *)f2_Color;
@end
