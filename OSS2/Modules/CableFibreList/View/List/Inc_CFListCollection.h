//
//  Inc_CFListCollection.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CFListCollection : UIView


/** vc 用来跳转 */
@property (nonatomic,strong) UIViewController *vc;



- (instancetype) initWithEnter:(CF_EnterType_)enterType;




/// 重置数据源
/// @param dataSource 网络请求结果
- (void) dataSource:(NSMutableArray *) dataSource;

// 哪些纤芯成端的端子 缺少superResId , 就把它变黄色
- (void) noSuperResIdSource:(NSArray *) noSuperResIdArray;


/** 声明 点击collection_Item 跳转模板 的block */
@property (nonatomic ,copy) void(^collection_SelectItemBlock)(NSDictionary * dict);

@end

NS_ASSUME_NONNULL_END
