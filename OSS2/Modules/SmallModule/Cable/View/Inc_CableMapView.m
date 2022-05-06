//
//  Inc_CableMapView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CableMapView.h"

#import "Yuan_PointAnnotation.h"
#import "Yuan_PolyLine.h"

@interface Inc_CableMapView ()<MAMapViewDelegate>
{
    //选择btn
    UIButton *_selectBtn;
}

@property (nonatomic, strong) MAMapView *mapView;//地图

@end

@implementation Inc_CableMapView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        
        [self addSubview:self.mapView];
        
        _selectBtn = [UIView buttonWithTitle:@"选择" responder:self SEL:@selector(btnClick) frame:CGRectMake(self.width - 60, 10, 50, 30)];
        [_selectBtn setTitleColor:HexColor(@"#838383") forState:UIControlStateNormal];
        _selectBtn.backgroundColor = UIColor.whiteColor;
        [_selectBtn setCornerRadius:3 borderColor:UIColor.clearColor borderWidth:1];
        
        [self addSubview:_selectBtn];
    }
    
    return self;
}

- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _mapView.showsUserLocation = NO;
//        _mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
        _mapView.showsCompass = NO;
        //比例尺坐标
        _mapView.scaleOrigin = CGPointMake(_mapView.frame.origin.x, _mapView.frame.size.height - 20);

        _mapView.delegate = self;
//        [_mapView setZoomLevel:18];
        
        //logo隐藏
        for (UIView *view in _mapView.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }
        }
//        //显示位置图标
//        MAUserLocationRepresentation *represent = [[MAUserLocationRepresentation alloc] init];
//        represent.showsAccuracyRing = NO;
//        represent.showsHeadingIndicator = NO;
//        represent.showsAccuracyRing = NO;
//        represent.enablePulseAnnimation = NO;
//        [self.mapView updateUserLocationRepresentation:represent];
        
    }
    return _mapView;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    Yuan_PointAnnotation *cusAnotation = (Yuan_PointAnnotation *)annotation;
    
    if ([annotation isKindOfClass:[MAUserLocation class]]){
        return nil;
    }
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:reuseIndetifier];
        }
        annotationView.annotation = cusAnotation;
        if (cusAnotation.tag == 0) {
            annotationView.image = [UIImage Inc_imageNamed:@"zzc_cable_start_end"];
            
        }else if (cusAnotation.tag == 1) {
            annotationView.image = [UIImage Inc_imageNamed:@"zzc_cable_start_end"];
            
        }else{
            annotationView.image = [UIImage Inc_imageNamed:@"zzc_cable_other"];
        }
        
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -9);
        return annotationView;
    }
    
    return nil;
}

#pragma mark - mapView Delegate

////不加该方法不显示定位信息
//- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager {
//    [locationManager requestAlwaysAuthorization];
//}


//禁止气泡
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MAAnnotationView *view = views[0];
    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        view.canShowCallout = NO;
    }
}

//线样式
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    Yuan_PolyLine *maPolyline = (Yuan_PolyLine*)overlay;
    
    if ([overlay isKindOfClass:[Yuan_PolyLine class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:maPolyline];
        
        polylineRenderer.lineWidth    = 2.0f;
        
        if (maPolyline.type == 1) {
            polylineRenderer.strokeColor  = HexColor(@"#0697F3");
        }else{
            polylineRenderer.strokeColor  = HexColor(@"#7FBE25");
            polylineRenderer.lineDashType = kMALineDashTypeSquare;
        }
        return polylineRenderer;
    }

    return nil;
}


-(void)setPointArr:(NSArray *)pointArr {
    
    _pointArr = pointArr;
    
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];

    int i = 0;
    for (NSDictionary *dic in pointArr) {
        
        Yuan_PointAnnotation *pointAnnotation = [[Yuan_PointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake([dic[@"lat"] doubleValue], [dic[@"lon"] doubleValue]);
        
        if ([dic[@"facilitiesState"] isEqualToString:@"start"]) {
            pointAnnotation.tag = 0;
        }else if ([dic[@"facilitiesState"] isEqualToString:@"end"]) {
            pointAnnotation.tag = 1;
        }else{
            pointAnnotation.tag = 2;
        }
        
        [_mapView addAnnotation:pointAnnotation];

        i++;
    }
    
    [_mapView showAnnotations:_mapView.annotations animated:YES];
    
    [self setPolyline:pointArr];
        
}

//选择btn
-(void)btnClick {
    
    if (self.btnBlock) {
        self.btnBlock();
    }
}

-(void)setPolyline:(NSArray *)pointArr {
    
    NSDictionary *startDic;
    NSDictionary *endDic;
    NSDictionary *otherDic;

    for (NSDictionary *dic in pointArr) {
        
        if ([dic[@"facilitiesState"] isEqualToString:@"start"]) {
            startDic = dic;
        }else if ([dic[@"facilitiesState"] isEqualToString:@"end"]){
            endDic = dic;
        }else if ([dic[@"facilitiesState"] isEqualToString:@"other"]){
            otherDic = dic;
        }
    }
    //画起始终止设施  实线
    if ([startDic[@"lat"] doubleValue] > 0 && [endDic[@"lat"] doubleValue] > 0) {
        
        CLLocationCoordinate2D commonPolylineCoords[2];

        commonPolylineCoords[0].latitude = [startDic[@"lat"] doubleValue];
        commonPolylineCoords[0].longitude = [startDic[@"lon"] doubleValue];
        
        commonPolylineCoords[1].latitude = [endDic[@"lat"] doubleValue];
        commonPolylineCoords[1].longitude = [endDic[@"lon"] doubleValue];
        
        //构造折线对象
        Yuan_PolyLine *startEndPolyline = [Yuan_PolyLine polylineWithCoordinates:commonPolylineCoords count:2];
        startEndPolyline.type = 1;
        //在地图上添加折线对象
        [_mapView addOverlays:@[startEndPolyline]];
    }
    //画起始设施和选择的设施  虚线
    if ([startDic[@"lat"] doubleValue] > 0 && [otherDic[@"lat"] doubleValue] > 0 ) {
        
        CLLocationCoordinate2D commonPolylineCoords[2];

        commonPolylineCoords[0].latitude = [startDic[@"lat"] doubleValue];
        commonPolylineCoords[0].longitude = [startDic[@"lon"] doubleValue];
        
        commonPolylineCoords[1].latitude = [otherDic[@"lat"] doubleValue];
        commonPolylineCoords[1].longitude = [otherDic[@"lon"] doubleValue];
        
        //构造折线对象
        Yuan_PolyLine *startOtherPolyline = [Yuan_PolyLine polylineWithCoordinates:commonPolylineCoords count:2];
        startOtherPolyline.type = 2;
        //在地图上添加折线对象
        [_mapView addOverlays:@[startOtherPolyline]];
    }
    //画终止设施和选择的设施  虚线
    if ([otherDic[@"lat"] doubleValue] > 0 && [endDic[@"lat"] doubleValue] > 0 ) {
        
        CLLocationCoordinate2D commonPolylineCoords[2];

        commonPolylineCoords[0].latitude = [otherDic[@"lat"] doubleValue];
        commonPolylineCoords[0].longitude = [otherDic[@"lon"] doubleValue];
        
        commonPolylineCoords[1].latitude = [endDic[@"lat"] doubleValue];
        commonPolylineCoords[1].longitude = [endDic[@"lon"] doubleValue];
        
        //构造折线对象
        Yuan_PolyLine *otherEndPolyline = [Yuan_PolyLine polylineWithCoordinates:commonPolylineCoords count:2];
        otherEndPolyline.type = 2;
        //在地图上添加折线对象
        [_mapView addOverlays:@[otherEndPolyline]];
    }
    
    
}

@end
