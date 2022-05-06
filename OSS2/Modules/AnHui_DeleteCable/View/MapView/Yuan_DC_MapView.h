//
//  Yuan_DC_MapView.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2021/1/11.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface Yuan_DC_MapView : UIView

/** 控制器 */
@property (nonatomic,weak) UIViewController *vc;


/** 地图 */
@property (nonatomic,strong) MAMapView *mapView;


// 获取路由
- (void) http_GetCableRoute;


// 加载起始终止设备
- (void) loadStartEnd:(NSArray *) startEndDeviceArray;


// 加载屏幕中心点附近资源
- (void) http_LoadCircleRadiusRes:(NSArray *) circleRadiusArray;



// 显示和隐藏 中心点圆环
- (void) showCenterCircle;
- (void) hideCenterCircle;

//全部撤缆
- (void) http_AllDeleteRoute:(NSDictionary *) param;

@end

NS_ASSUME_NONNULL_END
