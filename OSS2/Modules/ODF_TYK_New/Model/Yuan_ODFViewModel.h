//
//  Yuan_ODFViewModel.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/29.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 当前cell 是应该显示单盘 还是显示双盘
typedef NS_ENUM(NSUInteger, ODF_TableView_Cell) {
    ODF_TableView_Cell_Dan_Before = 0,
    ODF_TableView_Cell_Dan_After = 1,
    ODF_TableView_Cell_Shuang = 2,
    ODF_TableView_Cell_None = 3
};

@interface Yuan_ODFViewModel : NSObject

+ (NSInteger) countOfDataSource :(NSMutableArray *)dataSource;




/// 判断当前是显示单盘还是双盘
/// @param array _allData
+ (ODF_TableView_Cell) viewModelCellStateWithDataSource:(NSArray *)array ;



/// 端子数量
+ (NSArray *) terminalCountArr;


/// 行列
+ (NSArray *) VHCountArr;


/// 模块排列
+ (NSArray *) moduleArrangeArr;


+ (UIImage *) dataURL2Image: (NSString *) imgSrc;

@end

NS_ASSUME_NONNULL_END
