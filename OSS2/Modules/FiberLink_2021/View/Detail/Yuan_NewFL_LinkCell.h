//
//  Yuan_NewFL_LinkCell.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_NewFL_LinkCell : UITableViewCell

// 光纤
- (void) cellDict:(NSDictionary *)dict;

// 局向
- (void) reloadRouteData:(NSDictionary *) dict;
@end

NS_ASSUME_NONNULL_END
