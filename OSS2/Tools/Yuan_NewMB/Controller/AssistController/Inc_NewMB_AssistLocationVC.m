//
//  Inc_NewMB_AssistLocationVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2022/2/16.
//  Copyright © 2022 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewMB_AssistLocationVC.h"
#import "Yuan_AMap.h"
#import "Inc_Push_MB.h"

@interface Inc_NewMB_AssistLocationVC () <MAMapViewDelegate>

/** 地图 */
@property (nonatomic , strong) MAMapView * mapView;

@end

@implementation Inc_NewMB_AssistLocationVC

{
    
    NSArray * _datas;
    
    Yuan_NewMB_ModelEnum_ _modelEnum;
    
}

#pragma mark - 初始化构造方法

- (instancetype)initWithLocationRes:(NSArray *) datas
                          modelEnum:(Yuan_NewMB_ModelEnum_)modelEnum{
    
    if (self = [super init]) {
        
        _datas = datas;
        _modelEnum = modelEnum;
    }
    return self;
}



- (void)viewDidLoad {
    
    [super viewDidLoad];

    _mapView = [UIView mapViewAndDelegate:self frame:CGRectNull];

    [self.view addSubview:_mapView];
    
    [_mapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(NaviBarHeight,
                                                                      0,
                                                                      BottomZero,
                                                                      0)];
    [self addPoints];
}



- (void) addPoints {
    
    NSMutableArray * pointsViewArr = NSMutableArray.array;
    
    for (NSDictionary * resDict in _datas) {
        
        Yuan_PointAnnotation * anno = [[Yuan_PointAnnotation alloc] init];
        anno.dataSource = resDict;
        
        NSString * lat = resDict[@"lat"];
        NSString * lon = resDict[@"lon"];
        
        anno.coordinate = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
        anno.title = resDict[@"name"];
        [pointsViewArr addObject:anno];
    }
    
    [_mapView addAnnotations:pointsViewArr];
    
}


#pragma mark ---  高德地图代理方法  ---

/// 实时获取当前iphoen 位置
- (void)          mapView:(MAMapView *)mapView
    didUpdateUserLocation:(MAUserLocation *)userLocation
         updatingLocation:(BOOL)updatingLocation {
    
    // mapView.region.center 地图中心坐标
    // userLocation.coordinate iphone当前坐标
}


/// 初始化资源点 大头针
- (MAAnnotationView *)mapView:(MAMapView *)mapView
            viewForAnnotation:(id<MAAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }
    
    
    Yuan_PointAnnotation *cusAnotation = (Yuan_PointAnnotation *)annotation;
    if ([annotation isKindOfClass:[Yuan_PointAnnotation class]]) {
        
        
        MAAnnotationView *annotationView =
        [[MAAnnotationView alloc] initWithAnnotation:cusAnotation
                                     reuseIdentifier:@"Yuan_Anno"];
        
        annotationView.annotation = cusAnotation;
        annotationView.image = [UIImage Inc_imageNamed:@"icon_SI_anno_normal"];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectNull];
                    
        label.text = cusAnotation.title;
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



- (MAOverlayRenderer *)mapView:(MAMapView *)mapView
            rendererForOverlay:(id<MAOverlay>)overlay {
    
    
    // 线段
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineRenderer.strokeColor = [UIColor blueColor];
        polylineRenderer.lineWidth   = 5.f;
        
        return polylineRenderer;
    }
    // 圆环
    if ([overlay isKindOfClass:[MACircle class]])
    {
        
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        circleRenderer.lineWidth    = 0;
        
        circleRenderer.fillColor    = [UIColor colorWithRed:0 green:188/255.0 blue:180/255.0 alpha:0.2];
        return circleRenderer;
    }
    
    // 图形
    if ([overlay isKindOfClass:[MAPolygon class]]) {
        
        MAPolygonRenderer * polygonRenderer = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        
        
        
        polygonRenderer.strokeColor  = [UIColor colorWithRed:0 green:0.75 blue:0.73 alpha:0.6];
        
        polygonRenderer.fillColor = [UIColor colorWithRed:0 green:0.75 blue:0.73 alpha:0.6];
        
        
        return polygonRenderer;
    }
    
    // 海量点
    if ([overlay isKindOfClass:[MAMultiPointOverlay class]])
    {
        MAMultiPointOverlayRenderer * renderer = [[MAMultiPointOverlayRenderer alloc] initWithMultiPointOverlay:overlay];
        
        ///设置锚点
        renderer.anchor = CGPointMake(0.5, 1.0);
        renderer.delegate = self;
        
        MAMultiPointOverlay * overlay_Yuan = (MAMultiPointOverlay *)renderer.overlay;
        
        NSArray <MAMultiPointItem *> * items = overlay_Yuan.items;
        
        for (MAMultiPointItem * yuan_Item in items) {
            
            Yuan_MultiPointItem * yuan_anno = (Yuan_MultiPointItem *) yuan_Item;
            // 根据不同的数据进行适配
        }
        
        return renderer;
    }
    
    return nil;
}


/// 大头针资源点 点击事件
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    
    
    // 如果点击的是 定位小蓝点的话 直接return
    if ([view.class isEqual:NSClassFromString(@"MAUserLocationView")]) {
        
        return;
    }
    
    Yuan_PointAnnotation * anno = (Yuan_PointAnnotation *)view.annotation;
    
    [Inc_Push_MB NewMB_GetDetailDictFromGid:anno.dataSource[@"gid"] Enum:_modelEnum success:^(NSDictionary * _Nonnull dict) {
                
        [Inc_Push_MB push_NewMB_Detail_RequestDict:dict Enum:_modelEnum vc:self];
    }];
    
}



@end
