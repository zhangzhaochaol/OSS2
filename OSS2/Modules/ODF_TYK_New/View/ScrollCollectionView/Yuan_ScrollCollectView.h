//
//  Yuan_ScrollCollectView.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/3.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Yuan_ScrollHorizontalCell.h"  // 行优 cell
#import "Yuan_ScrollVerticalCell.h"    // 列优 cell

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_ScrollCollectView : UIScrollView




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





// 刷新
- (void) reloadLineCount:(int)lineCount
                rowCount:(int)rowCount
               Important:(Important_)import
               Direction:(Direction_)dire
              dataSource:(NSArray *)dataSource
                 PieDict:(NSDictionary *)pieDict
                      VC:(UIViewController *)VC;


#pragma mark - 2021.1.22 ---

- (void) btns_Union_PhotoArray:(NSArray *) unionArray
                         image:(UIImage *)image
                     base64Img:(NSString *)base64Img
                        matrix:(NSArray *)MATRIX;

- (void) reConfigClick;

- (void) endUnionClick;


// 校验完成 重新对端子赋值
- (void) PhotoCheckEnd:(NSArray *) array;


// 批量修改端子状态 **
- (void) clear_BatchHold;
- (void) BatchHold_Save;
- (void) BatchHold_Start:(BOOL)isStart;





/** 刷新 block */
@property (nonatomic , copy) void (^BatchHold_SaveBlock) (NSArray *batchHoldArray);


/** 点击 核查按钮的点击事件  block */
@property (nonatomic , copy) void (^reConfigClickBlock) (NSDictionary * dict);

/** 当选择1,2模式下 , 点击端子的回调  block */
@property (nonatomic , copy) void (^terminalBtnClick_Block) (NSInteger index , NSInteger position);

/** 新版 批量修改端子状态后 进行弹框提示  block */
@property (nonatomic , copy) void (^BatchHold_SaveClick_TipsShow) (void);

// 获取所有端子的view 数组
- (NSArray *) getAllDatas;


// 获取行内端子个数
- (NSInteger) getInlineNums;

//
- (NSArray *) getAllBtnS;


// 调用保存
- (void) http_BatchHold_Save;

@property (nonatomic ,copy) void(^remarkBlock)(NSString *num,NSDictionary *dict);

@end

NS_ASSUME_NONNULL_END
