//
//  Inc_CFListTableView.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CFListTableView : UIView


/** vc 用来跳转 */
@property (nonatomic,strong) UIViewController *vc;


/// 重置数据源
/// @param dataSource 网络请求结果
- (void) dataSource:(NSMutableArray *) dataSource;


// 哪些纤芯成端的端子 缺少superResId , 就把它变黄色
- (void) noSuperResIdSource:(NSArray *) noSuperResIdArray;



/** 声明 点击tableView 跳转模板 的block */
@property (nonatomic ,copy) void(^tableView_SelectCellBlock)(NSDictionary * dict);


/** 声明 删除绑定成功 刷新列表 的block */
@property (nonatomic ,copy) void(^tableView_DeleteSuccessBlock)(void);


//长按回调  返回长按数据对应list位置
@property (nonatomic, copy) void (^PressGestureBlock)(int index);


@end

NS_ASSUME_NONNULL_END
