//
//  Yuan_MapNavi.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/8/10.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

//  导航 !!!!~~~! Giao .. ~

#import "Yuan_MapNavi.h"
#import <AMapNaviKit/AMapNaviKit.h>


@interface Yuan_MapNavi ()
<AMapNaviCompositeManagerDelegate>

/** <#注释#> */
@property (nonatomic,strong) AMapNaviCompositeManager *compositeManager;

@end

@implementation Yuan_MapNavi


#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
//        [self Navi_Init];
    }
    return self;
}

- (void) Navi_Init {
    
    self.compositeManager = [[AMapNaviCompositeManager alloc] init];

    self.compositeManager.delegate = self;
    
}




/// 配置起点和终点  直接进入导航页面
/// @param endLocation 经纬度
/// @param endPoint_name 终点名字
- (void) startLocation:(CLLocationCoordinate2D)startLocation
             startName:(NSString *)startPoint_name
           endLocation:(CLLocationCoordinate2D)endLocation
               endName:(NSString *)endPoint_name{
    
    self.compositeManager = [[AMapNaviCompositeManager alloc] init];

    self.compositeManager.delegate = self;
    
    //导航组件配置类 since 5.2.0
    AMapNaviCompositeUserConfig *config = [[AMapNaviCompositeUserConfig alloc] init];


    //传入起点， POIId 是啥??

    [config setRoutePlanPOIType:AMapNaviRoutePlanPOITypeStart
                       location:[AMapNaviPoint locationWithLatitude:startLocation.latitude
                                                          longitude:startLocation.longitude]
                           name:startPoint_name
                          POIId:nil];

    //传入终点坐标
    [config setRoutePlanPOIType:AMapNaviRoutePlanPOITypeEnd
                       location:[AMapNaviPoint locationWithLatitude:endLocation.latitude
                                                          longitude:endLocation.longitude]
                           name:endPoint_name
                          POIId:nil];


    //直接进入导航界面
    [config setStartNaviDirectly:YES];
    
    //启动
    [self.compositeManager presentRoutePlanViewControllerWithOptions:config];
    
}



/// 值传终点    起点默认我当前位置
/// @param endLocation 终点经纬度
/// @param endPoint_name 终点名字 -- 非必选
- (void) endLocation:(CLLocationCoordinate2D)endLocation
             endName:(NSString *)endPoint_name {
    
    
    self.compositeManager = [[AMapNaviCompositeManager alloc] init];

    self.compositeManager.delegate = self;
    
    //导航组件配置类 since 5.2.0
    AMapNaviCompositeUserConfig *config = [[AMapNaviCompositeUserConfig alloc] init];

    
    //传入终点，并且带高德POIId
    [config setRoutePlanPOIType:AMapNaviRoutePlanPOITypeEnd location:[AMapNaviPoint locationWithLatitude:39.918058 longitude:116.397026] name:@"故宫" POIId:@"B000A8UIN8"];
    
    [config setStartNaviDirectly:YES];
    //启动
    [self.compositeManager presentRoutePlanViewControllerWithOptions:config];
    
}




#pragma mark -  delegate  ---


// 开始导航的回调函数
- (void)compositeManager:(AMapNaviCompositeManager *)compositeManager
            didStartNavi:(AMapNaviMode)naviMode {
    
    [[Yuan_HUD shareInstance] HUDFullText:@"开始导航"];
}


@end
