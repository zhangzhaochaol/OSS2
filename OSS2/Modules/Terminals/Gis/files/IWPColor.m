//
//  IWPColor.m
//  IWPColorDemo
//
//  Created by 王旭焜 on 2016/5/27.
//  Copyright © 2016年 王旭焜. All rights reserved.
//


#import "IWPColor.h"

#define SHISHUANGSE [UIColor colorWithRed:176.f / 255.f green:135.f / 255.f blue:26.f / 255.f alpha:255.f / 255.f]

typedef struct colors{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
} IWPColorValues;

IWPColorValues color;

@implementation UIColor (IWPColor)
-(UIColor *)setAlpha:(CGFloat)alpha{
    
    
    return [self colorWithAlphaComponent:alpha];
}
+ (UIColor *)colorWithHexString:(NSString *)hexString{
    if (hexString == nil) return UIColor.blackColor;
    
    NSUInteger length = hexString.length;
    
    // 判斷格式和取值範圍, 不合法返回一個屎黃色
    NSMutableString * regex = [NSMutableString stringWithString:@"[#]"];
    // 循環添加正則表達式匹配內容
    for (int i = 0; i < hexString.length - 1; i++) {
        [regex insertString:@"+[A-Fa-f0-9]" atIndex:regex.length];
    }
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%@ MATCHES %@",hexString, regex];

    if (![predicate evaluateWithObject:hexString]) {
        NSLog(@"輸入有誤:%@\n不包含'#'或取值範圍有誤.",hexString);
         return SHISHUANGSE;
    }
    
    // 容錯
    // 如果傳入的字符串不符合標準預設,返回一個屎黃色
    if (length != 9  && length != 7 && length != 4) {
        NSLog(@"輸入有誤:%@,請檢查長度是否正確.",hexString);
        return SHISHUANGSE;
    }
    
    // 移除 #
    NSString * string = [hexString substringFromIndex:1];
    
    if (string.length != 8 && string.length != 6 && string.length != 3) {
        NSLog(@"輸入有誤:%@,請檢查#字符后的長度是否正確.",hexString);
        // 返回一個屎黃色
        return SHISHUANGSE;
    }
    
    // 這裡判斷字符串長度是否為#RGB,只有在RR一樣GG一樣BB一樣時可用,即(FFAABB = FAB),所以這裡要對字符串進行一個擴充
    if (string.length == 3) {
        string = [[self resetStingWithString:string] copy];
    }

    // 轉為數值 并 對全局變量color賦值
    [self colorValueWithString:string];
    
    // 返回顏色
    return [UIColor colorWithRed:color.red / 255.f green:color.green / 255.f blue:color.blue / 255.f alpha:color.alpha / 255.f];
}
+ (NSString *)resetStingWithString:(NSString *)string{
    
// RGB => RRGGBB
    // 創建一個字符串, 用於存儲擴充後的字符串
    NSMutableString * result = [NSMutableString string];
    // 使用range分隔字符串
    NSRange range;
    range.length = 1;
    
    // 循環添加
    for (NSInteger i = 0,j = 0; i < string.length; i++) {
        // 起始位置為i的當前值
        range.location = i;
        // 再次循環, 因為每取出一個字符要添加兩次
        for (int k = 0; k < 2; k++) {
            // 插入字符串
            [result insertString:[string substringWithRange:range] atIndex:j++]; //j用於指定插入位置
        }
    }
    return result;
}


// 從字符串取數值
+ (void)colorValueWithString:(NSString *)string{
    
    // 創建接收變量
    unsigned long long result = 0;
    // 從字符串中採集數值
    [[NSScanner scannerWithString:string] scanHexLongLong:&result];
    
    // 從結果中分離數值
    color.blue = result & 0xFF;
    color.green = result >> 8 & 0xFF;
    color.red = result >> 16  & 0xFF;
    color.alpha = result >> 24 & 0xFF;
    
    
    // 攔截判斷
    if (color.alpha <= 0.f) {
        color.alpha = 0xFF;
    }
}

// 取隨機色
+ (UIColor *)anyColor{

#if DEBUG
    // 取隨機值
    color.red = arc4random_uniform(256);
    color.blue = arc4random_uniform(256);
    color.green = arc4random_uniform(256);
//    color.alpha = arc4random_uniform(255) + 1.f;
//
    return [UIColor colorWithRed:color.red / 255.f green:color.green / 255.f blue:color.blue / 255.f alpha:255.f / 255.f];
#else
    return [UIColor clearColor];
#endif
    
}

+(UIColor *)getStochasticColor{
    return [self anyColor];
}
// tiffany藍
//
//+ (UIColor *)blackColor{
//    return [UIColor colorWithHexString:@"#4c4c4c"];
//}

+ (UIColor *)tiffanyBlue{
    return [UIColor colorWithHexString:@"#81d8d0"];
}

+ (UIColor *)colorwithImage:(NSString *)imageName{
    return [UIColor colorWithPatternImage:[UIImage Inc_imageNamed:imageName]];
}


@end
