//
//  Inc_CFConfigCableCollectionView.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CFConfigCableCollectionView : UIView

/// 重置数据源
/// @param dataSource 网络请求结果
- (void) dataSource:(NSMutableArray *) dataSource;

/** 用来跳转 */
@property (nonatomic,strong) UIViewController *vc;

@end

NS_ASSUME_NONNULL_END
