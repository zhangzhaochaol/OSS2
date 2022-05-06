//
//  Yuan_ScrollVerticalCell.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/3.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Yuan_terminalBtn.h"    //端子按钮

NS_ASSUME_NONNULL_BEGIN




// 点击事件的代理回调
@protocol ScrollVerticalDeletate <NSObject>

- (void) vertical_TerminalBtn:(Yuan_terminalBtn *)sender;

@end



@interface Yuan_ScrollVerticalCell : UICollectionViewCell


/** 按钮的点击事件代理 */
@property (nonatomic,weak) id <ScrollVerticalDeletate> delegate;


/** 声明 长按发起初始化模块请求 的block */
@property (nonatomic ,copy) void(^LongPressInitBlock)(NSInteger position);


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
- (void) CellBtnMap_Dict:(NSDictionary *)btnDataSource ;


- (NSArray *) btnsArr;

@property (nonatomic ,copy) void(^remarkBlock)(NSString *num);


@end

NS_ASSUME_NONNULL_END
