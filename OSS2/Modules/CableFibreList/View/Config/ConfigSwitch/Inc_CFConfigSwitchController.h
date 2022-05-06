//
//  Inc_CFConfigSwitchController.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/22.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CFConfigSwitchController : UIViewController

- (instancetype) initWithDataSource:(NSArray *)dataSource
                              block:(void(^)(id cableDict))cableArr ;


/** 声明 最终选择的设备名称的回调 的block */
@property (nonatomic ,copy) void(^cableName_Block)(NSString * name);




@end

NS_ASSUME_NONNULL_END
