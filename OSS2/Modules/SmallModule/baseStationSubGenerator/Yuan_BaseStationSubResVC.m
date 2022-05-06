//
//  Yuan_BaseStationSubResVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_BaseStationSubResVC.h"


#import "Inc_Push_MB.h"

@interface Yuan_BaseStationSubResVC () <MAMapViewDelegate>

/** map */
@property (nonatomic , strong) MAMapView * mapView;
@end

@implementation Yuan_BaseStationSubResVC

{
    
    NSMutableArray * _pointArray;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"机房下属设备";
    
    _pointArray = NSMutableArray.array;
    
    [self http_port];
    
    [self UI_Init];
    
}

- (void) http_port {
    
    if (!_GID) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少Gid"];
        Pop(self);
        return;;
    }
    
    
    NSDictionary * dict = @{
        
        @"resLogicName" : @"generator",
        @"areaname_Id" : _GID       //所属局站ID
    };
    
    
    [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Get
                             dict:dict
                          succeed:^(id data) {
                
        NSArray * arr = data;
        [self configMapSource:arr];
    }];
    
    
    
}


- (void) configMapSource:(NSArray *) arr {
    
    
    if (arr.count == 0) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"暂无数据"];
        return;;
    }
    
    
    
    for (NSDictionary * dict in arr) {
        
        
        Yuan_PointAnnotation * anno = [[Yuan_PointAnnotation alloc] init];

        double lat = [dict[@"lat"] doubleValue];
        double lon = [dict[@"lon"] doubleValue];
        
        anno.coordinate = CLLocationCoordinate2DMake(lat, lon);
        anno.dataSource = dict;
        
        [_pointArray addObject:anno];
    }
    
    [_mapView addAnnotations:_pointArray];
}



#pragma mark - mapViewDelegate ---
- (MAAnnotationView *)mapView:(MAMapView *)mapView
            viewForAnnotation:(id<MAAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }
    
    
    Yuan_PointAnnotation * yuan_anno = (Yuan_PointAnnotation *) annotation;
    
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        
        static NSString *busStopIdentifier = @"yuan_anno";

        
        MAAnnotationView *annotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:busStopIdentifier];
        
        if (annotationView == nil) {
            
           annotationView =
           [[MAAnnotationView alloc] initWithAnnotation:yuan_anno
                                        reuseIdentifier:busStopIdentifier];
       }
        
        
        annotationView.image = [UIImage Inc_imageNamed:@"DC_Anno_OCC"];
        
        
        // 新版 楼宇资源点下方有楼宇名称
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectNull];
                    
        label.text = yuan_anno.dataSource[@"generatorName"] ?: @"";
        label.backgroundColor = Color_V2Red;

        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:13];

        label.numberOfLines = 0;//根据最大行数需求来设置

        label.lineBreakMode = NSLineBreakByTruncatingTail;

        CGSize maximumLabelSize = CGSizeMake(200, 9999);//labelsize的最大值

        //关键语句

        CGSize expectSize = [label sizeThatFits:maximumLabelSize];
            
        [label autoSetDimensionsToSize:CGSizeMake(expectSize.width, expectSize.height)];
        
        
        
        
        [annotationView addSubview:label];
        
        [label autoPinEdge:ALEdgeBottom
                         toEdge:ALEdgeTop
                         ofView:annotationView
                     withOffset:- 2];
        
        [label YuanAttributeVerticalToView:annotationView];
        
        
        
        return annotationView;
    }
    
    return nil;
}



- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    
    // 如果点击的是 定位小蓝点的话 直接return
    if ([view.class isEqual:NSClassFromString(@"MAUserLocationView")]) {
    
        return;
    }
    
    // 立即取消反选
    [_mapView deselectAnnotation:view.annotation animated:YES];
    
    
    Yuan_PointAnnotation * anno = (Yuan_PointAnnotation *)view.annotation;
    NSDictionary * dict = anno.dataSource;
    
    // TODO 智网通模板跳转
    [Inc_Push_MB pushFrom:self resLogicName:@"generator" dict:dict type:TYKDeviceListUpdate];
    
    
    
    
}



- (void) UI_Init {
    
    
    _mapView = [UIView mapViewAndDelegate:self frame:CGRectNull];
    [self.view addSubview:_mapView];
    
    
    [_mapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(NaviBarHeight, 0, BottomZero, 0)];
}

@end
