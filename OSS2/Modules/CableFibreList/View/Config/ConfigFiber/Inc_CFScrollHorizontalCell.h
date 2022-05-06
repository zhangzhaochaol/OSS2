//
//  Inc_CFScrollHorizontalCell.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inc_CFConfigFiber_ItemBtn.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CFScrollHorizontalCell : UICollectionViewCell


/// 设置 模块position
/// @param position positon
- (void) CellPosition:(NSInteger)position;




/// terminalCount 端子个数
/// moduleRows 盘内端子列数
/// moduleColumn 盘内端子行数
- (void) CellTerminal:(int)terminalCount
           moduleRows:(int)moduleRows
         moduleColumn:(int)moduleColumn;



/// 按钮的数据源 用于跳转到模板时传参 或 判断当前端子状态与颜色
/// @param btnDataSource 数据源
- (void) CellBtnMap_Dict:(NSDictionary *)btnDataSource;


/** key:position value为 btnArray 的map */
@property (nonatomic,strong) NSDictionary *position_btnArray_Dict;

@end

NS_ASSUME_NONNULL_END
