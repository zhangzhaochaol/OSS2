//
//  Yuan_ODFViewModel.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/29.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_ODFViewModel.h"

@implementation Yuan_ODFViewModel

+ (NSInteger) countOfDataSource :(NSMutableArray *)dataSource
{
    
    if ([dataSource isEqual:[NSNull null]] || !dataSource) {
        return 0;
    }
    
    
    
    NSInteger count = dataSource.count;
    
    if (count <= 8) {
        return count;
    }
    
    if (count > 8) {
        return 8;
    }
    
    
    return 0;
}





/// 判断当前是显示单盘还是双盘
/// @param array _allData
+ (ODF_TableView_Cell) viewModelCellStateWithDataSource:(NSArray *)array{
    
    // 如果 position 有 1 到 8 , 没有 9 - 16 则显示单盘
    
    // 如果 position 有 9 - 16  , 没有 1-8 同样显示单盘
    
    // 二者都有 则显示双盘
    
    // 如果在编辑模式下 , 必然显示双盘
    
    
    BOOL isHaveBeforeHalf = NO;   // 是否包含前半段
    BOOL isHaveAfterHalf = NO;    // 是否包含后半段
    
    
    for (NSDictionary * dict in array) {
        
        if (dict.allKeys.count > 1) {
            
            // 证明不是只有 一个key为'position'的占位dict
            // 该dict是网络请求回来 替换过的dict
            
            int position = [dict[@"position"] intValue];
            
            if (position >= 1 && position <= 8) {
                // 在此范围内有值 , 则改变状态
                isHaveBeforeHalf = YES;
            }
            
            if (position >= 9 && position <= 16) {
                // 在此范围内有值 , 则改变状态
                isHaveAfterHalf = YES;
            }
            
        }
        
    }
    
    
    // 根据遍历的结果判断
    
    if (isHaveAfterHalf && isHaveBeforeHalf) {
        // 同时包含 前半段和后半段  1-8 和 9-16的情况 , 双盘
        return ODF_TableView_Cell_Shuang;
    }
    
    if (isHaveBeforeHalf) {
        return ODF_TableView_Cell_Dan_Before;
    }
    
    if (isHaveAfterHalf) {
        return ODF_TableView_Cell_Dan_After;
    }
    
    
    return 0;
    
}



/// 端子数量
+ (NSArray *) terminalCountArr{
    
    NSMutableArray * arr = [NSMutableArray array];
    
    for (int i = 1 ; i < 25; i++) {
        [arr addObject:[Yuan_Foundation fromInt:i]];
    }
    
    return arr;

}


/// 行列数量
+ (NSArray *) VHCountArr {
    
    NSMutableArray * arr = [NSMutableArray array];
    
    for (int i = 1 ; i < 31; i++) {
        [arr addObject:[Yuan_Foundation fromInt:i]];
    }
    
    
    return arr;
}


/// 模块排列
+ (NSArray *) moduleArrangeArr {
    
    NSMutableArray * arr = [NSMutableArray array];
    
    
    NSArray * array = @[@"行优、上左",
                        @"行优、上右",
                        @"行优、下左",
                        @"行优、下右",
                        @"列优、上左",
                        @"列优、上右",
                        @"列优、下左",
                        @"列优、下右"];
     
    
    for (NSString * str in array) {
        [arr addObject:str];
    }
    
    return arr;
}



+ (UIImage *) dataURL2Image: (NSString *) imgSrc
{
    NSData *ImageData = [[NSData alloc] initWithBase64EncodedString:imgSrc options:NSDataBase64DecodingIgnoreUnknownCharacters];

    UIImage *testImage = [UIImage imageWithData:ImageData];
    return testImage;
}
@end
