//
//  Yuan_FL_ListCell.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/12/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_FL_ListCell : UITableViewCell


/** 当前端子在路由中的顺序 */
@property (nonatomic ,copy)  NSString *sequence;

/** 资源类型名 */
@property (nonatomic ,copy)  NSString *resLogicName;

/** 设备Id */
@property (nonatomic ,copy)  NSString *deviceId;


- (void) reload_FiberDict:(NSDictionary *)dict;

- (void) reload_LinkDict:(NSDictionary *)dict;

- (void) isCurrentDevice:(BOOL) isCurrent;


@end

NS_ASSUME_NONNULL_END
