//
//  Inc_PoleNewConfig_MapView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/9/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Yuan_PointAnnotation.h"
#import "Yuan_AMap.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_PoleNewConfig_MapView : UIView


/** 弱引用外部controller */
@property (nonatomic , weak) UIViewController * vc;

/** 当前地图中心点的经纬度 */
@property (nonatomic , assign , readonly) CLLocationCoordinate2D mapCenterCoor;

/** 用户的经纬度 */
@property (nonatomic , assign , readonly) CLLocationCoordinate2D personCoor;

/** 关联的回调  block */
@property (nonatomic , copy) void (^connectBlock) (void);

// 新增电杆
- (void) addPolePointDict:(NSDictionary *) dict coor:(CLLocationCoordinate2D) coor;

// 新增撑点
- (void) addSupportingPointDict:(NSDictionary *) dict coor:(CLLocationCoordinate2D) coor;


// 显示附近电杆
- (void) showNearPole;

// 显示附近撑点
- (void) showNearSP;

// 回到人的定位点
- (void) goBackToPersonCoor;

// 关联杆路段
- (void) connectPoleLine;

// 获取路由数据
- (NSArray <Yuan_PointAnnotation *>*) getRouters;

@end

NS_ASSUME_NONNULL_END
