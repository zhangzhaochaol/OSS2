//
//  Inc_CableMapView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CableMapView : UIView

@property (nonatomic, copy) void (^btnBlock)(void);

//显示设备数据
@property (nonatomic, strong) NSArray *pointArr;

@end

NS_ASSUME_NONNULL_END
