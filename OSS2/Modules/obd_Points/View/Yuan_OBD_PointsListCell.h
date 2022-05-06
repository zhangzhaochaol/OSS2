//
//  Yuan_OBD_PointsListCell.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_OBD_PointsListCell : UITableViewCell

// 刷新
- (void) reloadDict:(NSDictionary *) dict;

@end

NS_ASSUME_NONNULL_END
