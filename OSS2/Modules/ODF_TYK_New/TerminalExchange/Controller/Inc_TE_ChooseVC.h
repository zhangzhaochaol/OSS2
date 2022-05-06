//
//  Inc_TE_ChooseVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"
#import "Inc_BusAllColumnView.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_TE_ChooseVC : Inc_BaseVC

- (instancetype)initWithDeviceId:(NSString *)GID deviceType:(BusAllColumnType_) type;

@end

NS_ASSUME_NONNULL_END
