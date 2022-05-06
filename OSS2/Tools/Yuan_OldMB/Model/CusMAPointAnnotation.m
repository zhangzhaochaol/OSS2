//
//  CusMKPointAnnotation.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 16/6/12.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "CusMAPointAnnotation.h"

@implementation CusMAPointAnnotation
@synthesize tag;
@synthesize type;



/// 检测 传入的资源点位置 和我是否一致
/// @param location 传入的资源点的位置
- (BOOL) checkPointIsMyPoint:(CLLocationCoordinate2D)location  {
    
    if (_yuan_Location.latitude == location.latitude &&
        _yuan_Location.longitude == location.longitude) {
        return YES;
    }
    
    return NO;
}


@end
