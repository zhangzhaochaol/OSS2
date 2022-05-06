//
//  Yuan_OBD_Points_DeviceListVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_OBD_Points_DeviceListVC : Inc_BaseVC

- (void) reloadData:(NSArray *) arr;


/** 选中了哪个分光器 block */
@property (nonatomic , copy) void (^choose_OBD) (NSDictionary * dict);

@end

NS_ASSUME_NONNULL_END
