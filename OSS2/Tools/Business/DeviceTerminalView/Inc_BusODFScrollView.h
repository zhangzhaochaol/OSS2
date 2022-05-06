//
//  Inc_BusODFScrollView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inc_BusScrollItem.h"

NS_ASSUME_NONNULL_BEGIN


#define BusDeviceSubTerminalClickNotification @"BusDeviceSubTerminalClickNotification"




@interface Inc_BusODFScrollView : UIScrollView





/** 存放所有collectionView 的数组 */
@property (nonatomic,strong,readonly) NSMutableArray<UICollectionView *> *collectionArray;

/// 初始化
/// @param lineCount 行数   一行是一条记录
/// @param rowCount 列数    一个行内 有几个字段
/// @param inLineNums    行内个数
/// @param import    行优 还是 列优?
/// @param dire     排序方式
/// @param dataSource 网络请求回来的 模块信息 [{}] 格式
/// @param PieDict 端子盘信息 , 也包括 设备id 设备类型等
- (instancetype) initWithLineCount:(int)lineCount
                          rowCount:(int)rowCount
                         Important:(Important_)import
                         Direction:(Direction_)dire
                        dataSource:(NSArray *)dataSource
                           PieDict:(NSDictionary *)pieDict
                                VC:(UIViewController *)VC;



/// 与初始化时一样 , 根据数据重置数据源 , 提示! 会重置UI 清空和重建
- (void) reloadViewWithLineCount:(int)lineCount
                        rowCount:(int)rowCount
                       Important:(Important_)import
                       Direction:(Direction_)dire
                      dataSource:(NSArray *)dataSource
                         PieDict:(NSDictionary *)pieDict;


// 获取所有按钮
- (NSArray <Inc_BusScrollItem *> * ) getBtns;

// 获取所有按钮 , 是按绑卡顺序排列的btn
- (NSArray <Inc_BusScrollItem *> * ) getArrangementBtn;

// 获取所有端子GID
- (NSArray *) getAllTerminalIds;


/// 当构造器4时的初始化 
- (void) reloadWithInitType_4;

/** 点击事件的  block */
@property (nonatomic , copy) void (^itemSelectBlock) (Inc_BusScrollItem * selectItem);

@end

NS_ASSUME_NONNULL_END
