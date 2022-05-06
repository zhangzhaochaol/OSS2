//
//  Inc_BusScrollHorizontalCell.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inc_BusScrollItem.h"
NS_ASSUME_NONNULL_BEGIN

// 点击事件的代理回调
@protocol ScrollHorizontalDeletate <NSObject>

- (void) horizontal_TerminalBtn:(Inc_BusScrollItem *)sender;

@end

@interface Inc_BusScrollHorizontalCell : UICollectionViewCell


/** 按钮的点击事件代理 */
@property (nonatomic,weak) id <ScrollHorizontalDeletate> delegate;

/// 设置 模块position
/// @param position positon
- (void) CellPosition:(NSInteger)position;



/// 设置 模块内的端子个数 与排序
/// terminalCount 端子个数
/// moduleRows 盘内端子列数
/// moduleColumn 盘内端子行数
- (void) CellTerminal:(int)terminalCount
           moduleRows:(int)moduleRows
         moduleColumn:(int)moduleColumn;




/// 按钮的数据源 用于跳转到模板时传参 或 判断当前端子状态与颜色
/// @param btnDataSource 数据源
- (void) CellBtnMap_Dict:(NSDictionary *)btnDataSource;

- (NSArray *) btnsArr;



/** key:position value为 btnArray 的map */
@property (nonatomic,strong) NSDictionary *position_btnArray_Dict;


@end

NS_ASSUME_NONNULL_END
