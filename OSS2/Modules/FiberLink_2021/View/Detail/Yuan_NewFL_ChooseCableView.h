//
//  Yuan_NewFL_ChooseCableView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_NewFL_ChooseCableView : UIView

/** <#注释#>  block */
@property (nonatomic , copy) void (^chooseCableBlock) (NSDictionary * _Nullable dict);

// 数据源
- (void) reloadData:(NSArray *) dataSource;

@end

NS_ASSUME_NONNULL_END
