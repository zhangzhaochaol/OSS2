//
//  Inc_NewFL_GisVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2022/3/1.
//  Copyright © 2022 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewFL_GisVC.h"
#import "Yuan_NewFL_VM.h"
#import "Yuan_AMap.h"

@interface Inc_NewFL_GisVC () <MAMapViewDelegate>

/** mapView */
@property (nonatomic , strong) MAMapView * mapView;

/** 链路切换 */
@property (nonatomic , strong) UIView * linkChangeView;

@end

@implementation Inc_NewFL_GisVC

{
    
    Yuan_NewFL_VM * _VM;
    NewFL_Gis_ _Enum;
    NSDictionary * _dict;
    
    NSMutableArray * _annoArr;
    NSMutableArray * _lineArr;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithEnum:(NewFL_Gis_)Enum
                        dict:(NSDictionary *)dict {
    
    if (self = [super init]) {
        _Enum = Enum;
        _dict = dict;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Gis";
    
    _annoArr = NSMutableArray.array;
    _lineArr = NSMutableArray.array;
    
    _VM = Yuan_NewFL_VM.shareInstance;
    [self UI_Init];
    [self http_SelectPointCoors];
}


- (void) http_SelectPointCoors {
    
    NSMutableDictionary * mt_Dict = NSMutableDictionary.dictionary;
    
    if (_Enum == NewFL_Gis_Link) {
        mt_Dict[@"type"] = @"optPairLink";
    }
    else {
        mt_Dict[@"type"] = @"logicOptPair";
    }
    
    mt_Dict[@"id"] = _dict[@"Id"];
    
    
    [Yuan_NewFL_HttpModel Http3_SelectPointCoorsDict:mt_Dict
                                             success:^(id result) {
        
        NSArray * resultArr = result;
        
        if (resultArr.count > 0) {
            
            NSInteger index = 0;
            
            for (NSDictionary * dict in result) {
                
                // 端子
                if ([dict[@"nodeTypeId"] isEqualToString:@"317"] ||
                    [dict[@"eptTypeId"] isEqualToString:@"317"]) {
                    
                    Yuan_PointAnnotation * anno = [[Yuan_PointAnnotation alloc] init];
                    
                    NSString * lat = dict[@"lat"];
                    NSString * lon = dict[@"lon"];
                    
                    anno.coordinate = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
                    anno.title = dict[@"nodeName"];
                    
                    [_annoArr addObject:anno];
                    [_mapView addAnnotations:_annoArr];
                    
                    if (index == 0) {
                        [_mapView setCenterCoordinate:anno.coordinate animated:YES];
                    }
                    
                }
                
                // 纤芯
                if ([dict[@"nodeTypeId"] isEqualToString:@"702"] ||
                    [dict[@"eptTypeId"] isEqualToString:@"702"]) {
                    
                    NSDictionary * optSect = dict[@"optSect"];
                    
                    NSString * slat = optSect[@"slat"];
                    NSString * slon = optSect[@"slon"];
                    
                    NSString * elat = optSect[@"elat"];
                    NSString * elon = optSect[@"elon"];
                    
                    CLLocationCoordinate2D scoor = CLLocationCoordinate2DMake(slat.doubleValue, slon.doubleValue);
                    
                    CLLocationCoordinate2D ecoor = CLLocationCoordinate2DMake(elat.doubleValue, elon.doubleValue);
                    
                    Yuan_PolyLine * line = [Yuan_PolyLine lineWith_sCoor:scoor eCoor:ecoor];

                    [_lineArr addObject:line];
                    [_mapView addOverlays:_lineArr];
                }
                
                
                // 如果是局向光纤
                
                if ([dict[@"eptTypeId"] isEqualToString:@"731"]) {
                    
                    
                    NSArray * optLogicRouteList = dict[@"optLogicRouteList"];
                    
                    for (NSDictionary * dict in optLogicRouteList) {
                        
                        // 端子
                        if ([dict[@"nodeTypeId"] isEqualToString:@"317"] ||
                            [dict[@"eptTypeId"] isEqualToString:@"317"]) {
                            
                            Yuan_PointAnnotation * anno = [[Yuan_PointAnnotation alloc] init];
                            
                            NSString * lat = dict[@"lat"];
                            NSString * lon = dict[@"lon"];
                            
                            anno.coordinate = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
                            anno.title = dict[@"nodeName"];
                            
                            [_annoArr addObject:anno];
                            [_mapView addAnnotations:_annoArr];
                            
                            if (index == 0) {
                                [_mapView setCenterCoordinate:anno.coordinate animated:YES];
                            }
                            
                        }
                        
                        // 纤芯
                        if ([dict[@"nodeTypeId"] isEqualToString:@"702"] ||
                            [dict[@"eptTypeId"] isEqualToString:@"702"]) {
                            
                            NSDictionary * optSect = dict[@"optSect"];
                            
                            NSString * slat = optSect[@"slat"];
                            NSString * slon = optSect[@"slon"];
                            
                            NSString * elat = optSect[@"elat"];
                            NSString * elon = optSect[@"elon"];
                            
                            CLLocationCoordinate2D scoor = CLLocationCoordinate2DMake(slat.doubleValue, slon.doubleValue);
                            
                            CLLocationCoordinate2D ecoor = CLLocationCoordinate2DMake(elat.doubleValue, elon.doubleValue);
                            
                            Yuan_PolyLine * line = [Yuan_PolyLine lineWith_sCoor:scoor eCoor:ecoor];

                            [_lineArr addObject:line];
                            [_mapView addOverlays:_lineArr];
                        }
                        
                    }

                }
                            
                index++;
            }
        }
    }];
}



#pragma mark ---  高德地图代理方法  ---

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
        
        
        // **** **** 地址
        
        UILabel * titleLabel = [UIView labelWithTitle:cusAnotation.title
                                                frame:CGRectNull];
        
        titleLabel.textColor = UIColor.whiteColor;
        titleLabel.backgroundColor = UIColor.mainColor;
        
        [annotationView addSubview:titleLabel];
        
        [titleLabel autoPinEdge:ALEdgeBottom
                         toEdge:ALEdgeTop
                         ofView:annotationView
                     withOffset:- 2];
        
        [titleLabel Yuan_EdgeWidth:Horizontal(200)];
        
        [titleLabel YuanAttributeVerticalToView:annotationView];
        
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

    return nil;
}


#pragma mark - UI_Init

- (void) UI_Init {
    
    _mapView = [UIView mapViewAndDelegate:self frame:CGRectNull];
        
    [self.view addSubviews:@[_mapView]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    //float limit = Horizontal(15);
    [_mapView Yuan_Edges:UIEdgeInsetsMake(NaviBarHeight, 0, BottomZero, 0)];
 
}


@end
