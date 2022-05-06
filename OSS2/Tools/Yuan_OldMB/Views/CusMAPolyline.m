//
//  CusMAPolyline.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 16/8/24.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "CusMAPolyline.h"

@implementation CusMAPolyline
@synthesize type;
@synthesize color;




/// 检查传入的资源点经纬度 和 当前线的起点或终点是否有重合?
/// @param pointLocation 传入的经纬度
- (YuanPoint_At_Line_) checkPointLocation:(CLLocationCoordinate2D)pointLocation {
    
    
    if (pointLocation.latitude == _startCoor.latitude &&
        pointLocation.longitude == _startCoor.longitude) {
        
        // 证明 传入点和 当前线段的起始位置相同
        return YuanPoint_At_Line_Start;
    }
    
    
    if (pointLocation.latitude == _endCoor.latitude &&
        pointLocation.longitude == _endCoor.longitude) {
        
        // 证明 传入点和 当前线段的起始位置相同
        return YuanPoint_At_Line_End;
    }
    
    
    
    return YuanPoint_At_Line_UnKnow;
    
}



- (CLLocationCoordinate2D) backLines_AnotherPoint:(CLLocationCoordinate2D)onePoint {
    
    // 当前点 在线段的起点 ? 终点 ?   或者无关?
    
    YuanPoint_At_Line_ type = [self checkPointLocation:onePoint];
    
    if (type == YuanPoint_At_Line_Start) {
        // 返回他的终点给外面
        return self.endCoor;
    }
    
    if (type == YuanPoint_At_Line_End) {
        return self.startCoor;
    }
    
    
    // 如果到大海上了 证明 有的点失联了
    NSLog(@"CusMAPolyline.m -- 传入的点(%lf,%lf) 不在线段的起点和终点上",onePoint.latitude,onePoint.longitude);
    
    return CLLocationCoordinate2DMake(0, 0);
    
}


- (BOOL) checkPointsIsCreateMyLineStartCoor:(CLLocationCoordinate2D)startCoor
                                    endCoor:(CLLocationCoordinate2D)endCoor {
    
    
    if (([self pointA:startCoor pointB:_startCoor] && [self pointA:endCoor pointB:_endCoor]) ||
        ([self pointA:startCoor pointB:_endCoor] && [self pointA:endCoor pointB:_startCoor])) {
        
        return YES;
    }

    
    return NO;
}



- (BOOL) pointA:(CLLocationCoordinate2D)A pointB:(CLLocationCoordinate2D)B{
    
    
    if (A.longitude == B.longitude && A.latitude == B.latitude) {
        return YES;
    }
    
    return NO;
    
}

@end
