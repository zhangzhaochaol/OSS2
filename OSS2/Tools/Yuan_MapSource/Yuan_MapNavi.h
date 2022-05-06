//
//  Yuan_MapNavi.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/8/10.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_MapNavi : NSObject



/// 配置起点和终点  直接进入导航页面
/// @param endLocation 经纬度
/// @param endPoint_name 终点名字
- (void) startLocation:(CLLocationCoordinate2D)startLocation
             startName:(NSString *)startPoint_name
           endLocation:(CLLocationCoordinate2D)endLocation
               endName:(NSString *)endPoint_name;




/// 值传终点    起点默认我当前位置
/// @param endLocation 终点经纬度
/// @param endPoint_name 终点名字 -- 非必选
- (void) endLocation:(CLLocationCoordinate2D)endLocation
             endName:(NSString *)endPoint_name;


@end

NS_ASSUME_NONNULL_END
