//
//  Yuan_PolyLine.m
//  INCP&EManager
//
//  Created by 袁全 on 2020/6/11.
//  Copyright © 2020 Unigame.space. All rights reserved.
//

#import "Yuan_PolyLine.h"

@implementation Yuan_PolyLine

#pragma mark - 初始化构造方法

+ (Yuan_PolyLine *)lineWith_sCoor:(CLLocationCoordinate2D)sCoor
                            eCoor:(CLLocationCoordinate2D)eCoor {
    
    
    CLLocationCoordinate2D coors_A[2] = {0};
    coors_A[0] = sCoor;
    coors_A[1] = eCoor;
    
    return [Yuan_PolyLine polylineWithCoordinates:coors_A count:2];
}


/// 通过起点 终点 连线
- (BOOL) formLine {
    
    if (_startCoor.latitude == 0 ||
        _startCoor.longitude == 0 ||
        _endCoor.latitude == 0 ||
        _endCoor.longitude == 0) {
        
        NSLog(@"缺少起点或终点的经纬度信息");
        
        return NO;
    }
    
    CLLocationCoordinate2D coors[2] = {0};
    coors[0] = _startCoor;
    coors[1] = _endCoor;
    
    return [self setPolylineWithCoordinates:coors count:2];
}

@end
