//
//  Yuan_BusOBD_PointItem.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define BusOBDItemLongPressNotification @"BusOBDItemLongPressNotification"

@interface Yuan_BusOBD_PointItem : UICollectionViewCell

/** 我的数据源 */
@property (nonatomic , copy , readonly) NSDictionary * myDict;


- (void) reloadWithDict:(NSDictionary *) dict;


// 是否显示右上角角标
- (void) connectSympol:(BOOL) isShow;

/** 是否已经和端子关联 */
@property (nonatomic , assign , readonly) BOOL isConnect;


/** <#注释#>  block */
@property (nonatomic , copy) void (^BusOBD_LongPressBlock) (NSDictionary * myDict);

@end

NS_ASSUME_NONNULL_END
