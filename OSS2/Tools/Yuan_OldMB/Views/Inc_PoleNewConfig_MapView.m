//
//  Inc_PoleNewConfig_MapView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/9/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_PoleNewConfig_MapView.h"

#import "Inc_Push_MB.h"
#import "Inc_PoleNewConfig_HttpModel.h"
#import "Inc_PoleNC_ViewModel.h"





typedef NS_ENUM(NSUInteger , PoleNewConfigAnnoEnum_) {
    
    PoleNewConfigAnnoEnum_SinglePoint_Pole, //新增单点电杆
    PoleNewConfigAnnoEnum_SinglePoint_Sp,   //新增单点撑点
    PoleNewConfigAnnoEnum_Route_Pole,       //路由点 - 电杆
    PoleNewConfigAnnoEnum_Route_SP,         //路由点 - 撑点
    PoleNewConfigAnnoEnum_NearPole,         //附近电杆
    PoleNewConfigAnnoEnum_NearSP,           //附近撑点
    
    PoleNewConfigAnnoEnum_RouteLine,        //路由线
    PoleNewConfigAnnoEnum_WillConnetLine,   //即将连接的虚线
};

@interface Inc_PoleNewConfig_MapView () <MAMapViewDelegate>

@end

@implementation Inc_PoleNewConfig_MapView

{
    
    Inc_PoleNC_ViewModel * _VM;
    
    MAMapView * _mapView;
    
    // 附近电杆
    NSMutableArray <Yuan_PointAnnotation *> * _nearPoleViewsArr;
    // 附近撑点
    NSMutableArray <Yuan_PointAnnotation *> * _nearSupportingPointViewsArr;
    // 路由点
    NSMutableArray <Yuan_PointAnnotation *> * _routeAnnosViewsArr;
    
    // 新增单点
    NSMutableArray <Yuan_PointAnnotation *> * _singleAnnosViewsArr;
    
    NSMutableArray <Yuan_PointAnnotation *> * _waitingConnectViewsArr;
    

    NSMutableArray <Yuan_PolyLine *> * _linesViewsArr;
    NSMutableArray <Yuan_PolyLine *> * _xuLineArr;

    
    // 等待上传的杆路段数据
    NSMutableArray * _postPoleLineDatas;
    
    
}


#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        
        // 数组初始化
        _nearPoleViewsArr = NSMutableArray.array;
        _nearSupportingPointViewsArr = NSMutableArray.array;
        _routeAnnosViewsArr = NSMutableArray.array;
        _singleAnnosViewsArr = NSMutableArray.array;
        
        _linesViewsArr = NSMutableArray.array;
        _xuLineArr = NSMutableArray.array;
        _waitingConnectViewsArr = NSMutableArray.array;
        
        _VM = Inc_PoleNC_ViewModel.shareInstance;
        
        
        [self UI_Init];
        
        // 获取杆路下属资源
        [self http_GetDatas_Pole];
        [self http_GetDatas_Line];
    }
    return self;
}


#pragma mark - method ---

// 回到人的定位点
- (void) goBackToPersonCoor {
    
    if (_personCoor.latitude == 0) {
        [YuanHUD HUDFullText:@"未检测到人当前的位置经纬度"];
        return;
    }
    
    [_mapView setCenterCoordinate:_personCoor animated:YES];
    
}


// 新增电杆
- (void) addPolePointDict:(NSDictionary *) dict
                     coor:(CLLocationCoordinate2D) coor {
    
    [self addSingleAnnos:dict Enum:PoleNewConfigAnnoEnum_SinglePoint_Pole];
}


// 新增撑点
- (void) addSupportingPointDict:(NSDictionary *) dict
                           coor:(CLLocationCoordinate2D) coor {
    
    [self addSingleAnnos:dict Enum:PoleNewConfigAnnoEnum_SinglePoint_Sp];
}


// 显示附近电杆
- (void) showNearPole {
    
    // 根据经纬度查询附近电杆
    
    [self http_GetNearPole];
}


// 显示附近撑点
- (void) showNearSP {
    
    // 根据经纬度查询附近撑点
    
    [self http_GetNearSP];
}


#pragma mark - Http ---

/// 根据杆路查询下属资源  -- 电杆和撑点
- (void) http_GetDatas_Pole {
    
    
    NSDictionary * postDict_P = @{
        @"start" : @"1",
        @"limit" : @"10000",
        @"resLogicName" : @"pole",
        @"poleLine_Id" : _VM.mb_Dict[@"GID"] ?: @"",
    };
    
    
    NSDictionary * postDict_SP = @{
        @"start" : @"1",
        @"limit" : @"10000",
        @"resLogicName" : @"supportingPoints",
        @"poleLine_Id" : _VM.mb_Dict[@"GID"] ?: @"",
    };
    
    
    
    [Http.shareInstance V2_POST_NoHUD:HTTP_TYK_Normal_Get
                                 dict:postDict_P
                              succeed:^(id data) {
        
        NSArray * datas = data;
        
        if(!datas || datas.count == 0) {
            
            [YuanHUD HUDFullText:@"暂无资源"];
            
            return;
        }
        
        [self addAnnos:datas Enum:PoleNewConfigAnnoEnum_Route_Pole];
    }];
    
    
    
    [Http.shareInstance V2_POST_NoHUD:HTTP_TYK_Normal_Get
                                 dict:postDict_SP
                              succeed:^(id data) {
        
        NSArray * datas = data;
        
        if(!datas || datas.count == 0) {
            
            [YuanHUD HUDFullText:@"暂无资源"];
            
            return;
        }
        
        [self addAnnos:datas Enum:PoleNewConfigAnnoEnum_Route_SP];
    }];
    

}



/// 根据杆路查询下属资源  -- 杆路段
- (void) http_GetDatas_Line {
    
    
    NSDictionary * postDict = @{
        @"start" : @"1",
        @"limit" : @"10000",
        @"resLogicName" : @"poleLineSegment",
        @"poleLine_Id" : _VM.mb_Dict[@"GID"] ?: @"",
    };
    
    [Inc_PoleNewConfig_HttpModel http_GetDatas:postDict
                                       success:^(id  _Nonnull result) {
       
        NSArray * datas = result;
        
        if(!datas || datas.count == 0) {
            
            [YuanHUD HUDFullText:@"暂无资源"];
            
            return;
        }
        
        // 加载路由线资源
        [self addRouteLines:datas];
        
    }];
    
}



// 获取附近的电杆
- (void) http_GetNearPole {

    
    NSString * lat = @"";
    NSString * lon = @"";
    
    
    // 自动定位
    if (_VM.poleLocationEnum == PoleLocationEnum_Auto) {
        
        lat = [Yuan_Foundation fromFloat:_personCoor.latitude];
        lon = [Yuan_Foundation fromFloat:_personCoor.longitude];
    }
    
    if (_VM.poleLocationEnum == PoleLocationEnum_Handle) {
        
        lat = [Yuan_Foundation fromFloat:_mapCenterCoor.latitude];
        lon = [Yuan_Foundation fromFloat:_mapCenterCoor.longitude];
    }
    
    
    
    NSDictionary * postDict = @{
        @"isAll" : @"1",
        @"resLogicName" : @"pole",
        @"lat" : lat,
        @"lon" : lon
    };
    

    [Inc_PoleNewConfig_HttpModel http_GetDatas:postDict
                                       success:^(id  _Nonnull result) {
        
        NSArray * datas = result;
        
        if(!datas || datas.count == 0) {
            
            [YuanHUD HUDFullText:@"暂无资源"];
            
            return;
        }
        
        [self addAnnos:datas Enum:PoleNewConfigAnnoEnum_NearPole];
    }];
    
}



// 获取附近的撑点
- (void) http_GetNearSP {
    
    
    NSString * lat = @"";
    NSString * lon = @"";
    
    
    // 自动定位
    if (_VM.poleLocationEnum == PoleLocationEnum_Auto) {
        
        lat = [Yuan_Foundation fromFloat:_personCoor.latitude];
        lon = [Yuan_Foundation fromFloat:_personCoor.longitude];
    }
    
    if (_VM.poleLocationEnum == PoleLocationEnum_Handle) {
        
        lat = [Yuan_Foundation fromFloat:_mapCenterCoor.latitude];
        lon = [Yuan_Foundation fromFloat:_mapCenterCoor.longitude];
    }
    
    NSDictionary * postDict = @{
        @"isAll" : @"1",
        @"resLogicName" : @"supportingPoints",
        @"lat" : lat,
        @"lon" : lon
    };
    

    [Inc_PoleNewConfig_HttpModel http_GetDatas:postDict
                                       success:^(id  _Nonnull result) {
        NSArray * datas = result;
        
        if(!datas || datas.count == 0) {
            
            [YuanHUD HUDFullText:@"暂无资源"];
            
            return;
        }
    }];
    
}


// 把杆路段加入到杆路内
- (void) http_ConnectPoleLines {
    
    if (_postPoleLineDatas.count == 0) {
        
        if (_connectBlock) {
            _connectBlock();
        }
        
        [YuanHUD HUDFullText:@"无需要关联的杆路段"];
        return;
    }
    
    [Inc_PoleNewConfig_HttpModel http_InsertDatas:_postPoleLineDatas
                                          success:^(id  _Nonnull result) {
       
        if (_connectBlock) {
            _connectBlock();
        }
        
        // 清空全部资源
        [self deleteAll];
        
        // 重新获取杆路下属资源
        [self http_GetDatas_Pole];
        [self http_GetDatas_Line];
        
    }];

    
}


#pragma mark - delegate ---




///MARK: 加载资源点  ******* ******* ******* ******* *******
- (MAAnnotationView *)mapView:(MAMapView *)mapView
            viewForAnnotation:(id<MAAnnotation>)annotation {
                
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }
    
    Yuan_PointAnnotation * yuan_anno = (Yuan_PointAnnotation *)annotation;
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        static NSString *busStopIdentifier = @"districtIdentifier";
        
        MAAnnotationView *annotationView = (MAAnnotationView*)[_mapView
        dequeueReusableAnnotationViewWithIdentifier:busStopIdentifier];
        
        if (annotationView == nil)
        {
            annotationView =
            [[MAAnnotationView alloc] initWithAnnotation:yuan_anno
                                         reuseIdentifier:busStopIdentifier];
        }
        
        
        // 电杆
        if ([yuan_anno.type isEqualToString:@"pole"]) {
            annotationView.image = [UIImage Inc_imageNamed:@"Pole_NewIcon_Pole"];
        }
        
        // 撑点
        else {
            annotationView.image = [UIImage Inc_imageNamed:@"Pole_NewIcon_SP"];
        }
        
        // 给大头针添加一个titleView

        UILabel * titleLabel = [self Yuan_MapView_Annotation:annotation];
        
        [annotationView addSubview:titleLabel];
        
        [titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:annotationView withOffset:2];
        
        [titleLabel autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:annotationView withMultiplier:1.0];
        
        
        return annotationView;
    }
    
    return nil;
    
}


/// 普通资源点的点击事件
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    
    // 如果点击的是 定位小蓝点的话 直接return
    if ([view.class isEqual:NSClassFromString(@"MAUserLocationView")]) {
        return;
    }
    
    [mapView deselectAnnotation:view.annotation animated:YES];
    
    Yuan_PointAnnotation * yuan_anno = (Yuan_PointAnnotation *)view.annotation;
    
    // 关联模式下
    if (_VM.isConnectModel) {
        
        NSString * resLogicName = yuan_anno.dataSource[@"resLogicName"];
        
        //
        if ([_waitingConnectViewsArr containsObject:yuan_anno]) {
            
            
            if (![yuan_anno isEqual:_waitingConnectViewsArr.lastObject] && _waitingConnectViewsArr.count > 1) {
                return;
            }
            
            [_waitingConnectViewsArr removeObject:yuan_anno];
            
            // 回复称对应的 image 图标
            if ([resLogicName isEqualToString:@"pole"]) {
                view.image = [UIImage Inc_imageNamed:@"Pole_NewIcon_Pole"];
            }
            else {
                view.image = [UIImage Inc_imageNamed:@"Pole_NewIcon_SP"];
            }
        }
        
        else {
            
            // 如果可以添加进去 , 则添加
            if([self chanrgeIsCanInsertToPoleLine:yuan_anno]) {
                
                [_waitingConnectViewsArr addObject:yuan_anno];
                view.image = [UIImage Inc_imageNamed:@"Pole_NewIcon_Select"];
            }
        }
        
        // 关联虚线的绘制
        [self addConnectLines];
    }
    
    // 普通模式
    else {
        

        
        NSString * resLogicName = yuan_anno.dataSource[@"resLogicName"];

        TYKDeviceInfoMationViewController * vc =   [Inc_Push_MB pushFrom:_vc
                                                            resLogicName:resLogicName
                                                                    dict:yuan_anno.dataSource
                                                                    type:TYKDeviceListUpdateRfid];

        // 保存的回调
        vc.savSuccessBlock = ^{
            [self deleteAll];

            // 获取杆路下属资源
            [self http_GetDatas_Pole];
            [self http_GetDatas_Line];
        };
        
    }
    
}





/// 加载线段和图形的 ******* ******* ******* ******* *******

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView
            rendererForOverlay:(id<MAOverlay>)overlay {
 

    // 加载线段
    if ([overlay isKindOfClass:[MAPolyline class]]){
        
        Yuan_PolyLine * yuan_Line = (Yuan_PolyLine *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:yuan_Line];
        
        
        polylineRenderer.lineWidth   = 4.f;
        polylineRenderer.strokeColor = ColorValue_RGB(0xe16061);
        
        if (yuan_Line.lineState == Yuan_PolyLineState_Xu) {
            // 虚线 ~~!
            polylineRenderer.lineDashType =  kMALineDashTypeSquare;
            polylineRenderer.strokeColor = ColorValue_RGB(0x333333);
        }
        
        return polylineRenderer;
    }
    
    
    // 加载圆环
    if ([overlay isKindOfClass:[MACircle class]]) {
        
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        circleRenderer.lineWidth    = 0;
        circleRenderer.fillColor    = [UIColor colorWithRed:0 green:188/255.0 blue:180/255.0 alpha:0.2];

        return circleRenderer;
    }
    
    
    return nil;
            
}






/// 实时获取当前iphoen 位置
- (void)          mapView:(MAMapView *)mapView
    didUpdateUserLocation:(MAUserLocation *)userLocation
         updatingLocation:(BOOL)updatingLocation {
             
    if (userLocation.coordinate.latitude != 0 &&
        userLocation.coordinate.longitude != 0) {
            
        _personCoor = userLocation.coordinate;
    }
             
}


/// 地图移动结束后
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    // 当前中心点的经纬度
    CLLocationCoordinate2D nowCoor = mapView.region.center;
    
    _mapCenterCoor = nowCoor;
    
}


- (UILabel *)Yuan_MapView_Annotation:(id <MAAnnotation>)annotation {
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectNull];
                
        label.text = annotation.title;
        label.backgroundColor = [UIColor colorWithRed:62/255.0 green:113/255.0 blue:1 alpha:0.8];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:10];

        label.numberOfLines = 0;//根据最大行数需求来设置

        label.lineBreakMode = NSLineBreakByTruncatingTail;

        CGSize maximumLabelSize = CGSizeMake(200, 9999);//labelsize的最大值

        //关键语句

        CGSize expectSize = [label sizeThatFits:maximumLabelSize];
            
        [label autoSetDimensionsToSize:CGSizeMake(expectSize.width, expectSize.height)];
        
        return label;
        
}


#pragma mark - UI_Init

- (void) UI_Init {
    
    
    _mapView = [UIView mapViewAndDelegate:self
                                    frame:CGRectNull];
    
    //设置缩放级别
    [_mapView setZoomLevel:17];
    
    [self addSubview:_mapView];
    [_mapView Yuan_Edges:UIEdgeInsetsMake(0, 0, 0, 0)];
}

#pragma mark - resource ---

- (void) addAnnos:(NSArray *) annos Enum:(PoleNewConfigAnnoEnum_) Enum{
    
    NSInteger index = 0;
    
    for (NSDictionary * dict in annos) {
        
        double lat = [Yuan_Foundation fromObject:dict[@"lat"]].doubleValue;
        double lon = [Yuan_Foundation fromObject:dict[@"lon"]].doubleValue;
        
        CLLocationCoordinate2D latlon = CLLocationCoordinate2DMake(lat, lon);
        
        Yuan_PointAnnotation * yuan_Anno = [[Yuan_PointAnnotation alloc] init];
        
        yuan_Anno.dataSource = dict;
        yuan_Anno.coordinate = latlon;
        
        yuan_Anno.deviceID = dict[@"GID"];
        
        // 附近电杆
        if(Enum == PoleNewConfigAnnoEnum_NearPole) {
            
            BOOL isExist = NO;
            
            // 附近资源
            for (Yuan_PointAnnotation * anno in _nearPoleViewsArr) {
                if ([anno.dataSource[@"GID"] isEqualToString:yuan_Anno.deviceID]) {
                    isExist = YES;
                    break;
                }
            }
            
            // 路由
            for (Yuan_PointAnnotation * anno in _routeAnnosViewsArr) {
                if ([anno.dataSource[@"GID"] isEqualToString:yuan_Anno.deviceID]) {
                    isExist = YES;
                    break;
                }
            }
            
            // 如果存在 则不添加到地图中
            if (isExist) {
                continue;
            }
            
            yuan_Anno.type = @"pole";
            [_nearPoleViewsArr addObject:yuan_Anno];
        }
        
        // 附近撑点
        if(Enum == PoleNewConfigAnnoEnum_NearSP) {
            
            BOOL isExist = NO;
            
            // 附近资源
            for (Yuan_PointAnnotation * anno in _nearSupportingPointViewsArr) {
                if ([anno.dataSource[@"GID"] isEqualToString:yuan_Anno.deviceID]) {
                    isExist = YES;
                    break;
                }
            }
            // 路由
            for (Yuan_PointAnnotation * anno in _routeAnnosViewsArr) {
                if ([anno.dataSource[@"GID"] isEqualToString:yuan_Anno.deviceID]) {
                    isExist = YES;
                    break;
                }
            }
            
            // 如果存在 则不添加到地图中
            if (isExist) {
                continue;
            }
            
            
            yuan_Anno.type = @"sp";
            [_nearSupportingPointViewsArr addObject:yuan_Anno];
        }
        
        // 杆路下的杆路段路由  -- 电杆
        if( Enum == PoleNewConfigAnnoEnum_Route_Pole) {
            yuan_Anno.type = @"pole";
            [_routeAnnosViewsArr addObject:yuan_Anno];
            yuan_Anno.title = dict[@"poleSubName"];
            
        }
        
        
        // 杆路下的杆路段路由 -- 撑点
        if( Enum == PoleNewConfigAnnoEnum_Route_SP) {
            yuan_Anno.type = @"sp";
            [_routeAnnosViewsArr addObject:yuan_Anno];
            yuan_Anno.title = dict[@"supportPSubName"];
        }
        
        index++;
    }
    
    // 杆路下的杆路段路由
    if( Enum == PoleNewConfigAnnoEnum_Route_Pole || Enum == PoleNewConfigAnnoEnum_Route_SP) {
        [_mapView addAnnotations:_routeAnnosViewsArr];
    }
    
    // 附近电杆
    if(Enum == PoleNewConfigAnnoEnum_NearPole) {
        [_mapView addAnnotations:_nearPoleViewsArr];
    }
    
    // 附近撑点
    if(Enum == PoleNewConfigAnnoEnum_NearSP) {
        [_mapView addAnnotations:_nearSupportingPointViewsArr];
    }
    
}


- (void) addSingleAnnos:(NSDictionary *) dict
                   Enum:(PoleNewConfigAnnoEnum_) Enum {
              
                       
    double lat = [Yuan_Foundation fromObject:dict[@"lat"]].doubleValue;
    double lon = [Yuan_Foundation fromObject:dict[@"lon"]].doubleValue;
    
    CLLocationCoordinate2D latlon = CLLocationCoordinate2DMake(lat, lon);
    
    Yuan_PointAnnotation * yuan_Anno = [[Yuan_PointAnnotation alloc] init];
    
    yuan_Anno.dataSource = dict;
    yuan_Anno.coordinate = latlon;
    
    yuan_Anno.deviceID = dict[@"GID"];

    // 新增单独电杆
    if(Enum == PoleNewConfigAnnoEnum_SinglePoint_Pole) {
        yuan_Anno.type = @"pole";
        yuan_Anno.title = dict[@"poleSubName"];
    }

   // 新增单独撑点
    if(Enum == PoleNewConfigAnnoEnum_SinglePoint_Sp) {
        yuan_Anno.type = @"sp";
        yuan_Anno.title = dict[@"supportPSubName"];
    }

    
    [_mapView addAnnotation:yuan_Anno];
    
    // 加入到数组中管理
    [_singleAnnosViewsArr addObject:yuan_Anno];
    
}

#pragma mark - 线资源 ---
/// **** 路由线资源
- (void) addRouteLines:(NSArray *) lines {
    
    for(NSDictionary * seg in lines ) {
     
        NSMutableDictionary *startPoint = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *endPoint = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *points = [[NSMutableArray alloc] init];
        
        Yuan_PolyLine *polyline = nil;
        
        for (Yuan_PointAnnotation * anno in _routeAnnosViewsArr) {
            
            NSDictionary * resource = anno.dataSource;
            
            
            if ([resource[@"resLogicName"] isEqualToString:@"pole"]) {
                
                if (([seg[@"startPole_Type"] isEqualToString:@"1"]) &&
                    [resource[@"GID"] isEqualToString:seg[@"startPole_Id"]]) {
                    
                    [startPoint setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [startPoint setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:startPoint];
                }
                if (([seg[@"endPole_Type"] isEqualToString:@"1"]) &&
                    [resource[@"GID"] isEqualToString:seg[@"endPole_Id"]]) {
                    
                    [endPoint setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [endPoint setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:endPoint];
                }
            }
            else if ([resource[@"resLogicName"] isEqualToString:@"supportingPoints"]) {
                
                if (([seg[@"startPole_Type"] isEqualToString:@"2"]) &&
                    [resource[@"supportingPointsId"] isEqualToString:seg[@"startPole_Id"]]) {
                    
                    [startPoint setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [startPoint setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:startPoint];
                }
                if (([seg[@"endPole_Type"] isEqualToString:@"2"]) &&
                    [resource[@"supportingPointsId"] isEqualToString:seg[@"endPole_Id"]]) {
                    
                    [endPoint setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [endPoint setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:endPoint];
                }
            }
            
            
            
            /// * 通用 * /
            if (startPoint!=nil &&
                endPoint!=nil &&
                [[startPoint objectForKey:@"lat"] doubleValue] !=0 &&
                [[startPoint objectForKey:@"lon"] doubleValue] != 0&&
                [[endPoint objectForKey:@"lat"] doubleValue] !=0 &&
                [[endPoint objectForKey:@"lon"] doubleValue] != 0) {
                
                CLLocationCoordinate2D coors[2] = {0};
                coors[0].latitude = [[startPoint objectForKey:@"lat"] doubleValue];
                coors[0].longitude = [[startPoint objectForKey:@"lon"] doubleValue];
                coors[1].latitude = [[endPoint objectForKey:@"lat"] doubleValue];
                coors[1].longitude = [[endPoint objectForKey:@"lon"] doubleValue];
                
                
                NSLog(@"coors:%f,%f,%f,%f",coors[0].latitude,coors[0].longitude,coors[1].latitude,coors[1].longitude);
                polyline = [Yuan_PolyLine polylineWithCoordinates:coors count:2];
                // 实线
                polyline.lineState = Yuan_PolyLineState_Shi;
                polyline.dataSource = seg;
                
                [_mapView addOverlay:polyline];
                break;
            }
        }
        
        if (polyline) {
            [_linesViewsArr addObject:polyline];
        }
    }
}


// 加载关联的虚线 -- 杆路段
- (void) addConnectLines {
    
    [_mapView removeOverlays:_xuLineArr];
    _xuLineArr = NSMutableArray.array;
    _postPoleLineDatas = NSMutableArray.array;
    
    if (_waitingConnectViewsArr.count < 2) {
        return;
    }
    
    NSInteger index = 0;
    
    for (Yuan_PointAnnotation * yuan_Anno in _waitingConnectViewsArr) {
    
        if (index == 0) {
            index++;
            continue;
        }
        
        Yuan_PointAnnotation * before_Anno = _waitingConnectViewsArr[index - 1];
                
        CLLocationCoordinate2D coors[2] = {0};
        coors[0].latitude = before_Anno.coordinate.latitude;
        coors[0].longitude = before_Anno.coordinate.longitude;
        coors[1].latitude = yuan_Anno.coordinate.latitude;
        coors[1].longitude = yuan_Anno.coordinate.longitude;
        

        Yuan_PolyLine * polyline = [Yuan_PolyLine polylineWithCoordinates:coors count:2];
        // 实线
        polyline.lineState = Yuan_PolyLineState_Xu;
        [_mapView addOverlay:polyline];
        [_xuLineArr addObject:polyline];
    
        
        NSString * startPole_Type = [before_Anno.type isEqualToString:@"pole"] ? @"1" : @"2";
        NSString * endPole_Type = [yuan_Anno.type isEqualToString:@"pole"] ? @"1" : @"2";
        
        NSString * startPole_Id = before_Anno.dataSource[@"GID"];
        NSString * endPole_Id = yuan_Anno.dataSource[@"GID"];
        
        NSString * startPole = [before_Anno.type isEqualToString:@"pole"] ? before_Anno.dataSource[@"poleSubName"] : before_Anno.dataSource[@"supportPSubName"];
        
        NSString * endPole = [yuan_Anno.type isEqualToString:@"pole"] ? yuan_Anno.dataSource[@"poleSubName"] : yuan_Anno.dataSource[@"supportPSubName"];
        
        
        NSString * nameCode = [NSString stringWithFormat:@"%@（%@_%@）",_VM.mb_Dict[@"poleLineName"],startPole,endPole];
        

        CLLocation *current=[[CLLocation alloc] initWithLatitude:coors[0].latitude
                                                       longitude:coors[0].longitude];

        CLLocation *before=[[CLLocation alloc] initWithLatitude:coors[1].latitude
                                                      longitude:coors[1].longitude];

        // 距离
        NSString * meter = [Yuan_Foundation fromFloat:[current distanceFromLocation:before]];
        
        
        // 生成杆路段的数据
        
        NSMutableDictionary * postPoleLineDict = NSMutableDictionary.dictionary;
        
        postPoleLineDict[@"resLogicName"] = @"poleLineSegment";
        
        postPoleLineDict[@"retion"] = _VM.mb_Dict[@"retion"];
        postPoleLineDict[@"areaname"] = _VM.mb_Dict[@"areaname"];
        postPoleLineDict[@"areaname_Id"] = _VM.mb_Dict[@"areaname_Id"];
        postPoleLineDict[@"chanquanxz"] = _VM.mb_Dict[@"chanquanxz"];
        postPoleLineDict[@"prorertyBelong"] = _VM.mb_Dict[@"prorertyBelong"];
        
        postPoleLineDict[@"startPole_Type"] = startPole_Type;
        postPoleLineDict[@"endPole_Type"] = endPole_Type;
        postPoleLineDict[@"startPole_Id"] = startPole_Id;
        postPoleLineDict[@"endPole_Id"] = endPole_Id;
        postPoleLineDict[@"startPole"] = startPole;
        postPoleLineDict[@"endPole"] = endPole;
        
        postPoleLineDict[@"poleLineSegmentName"] = nameCode;
        postPoleLineDict[@"poleLineSegmentCode"] = nameCode;
        
        postPoleLineDict[@"poleLine_Id"] = _VM.mb_Dict[@"GID"];
        postPoleLineDict[@"poleLine"] = _VM.mb_Dict[@"poleLineName"];
        postPoleLineDict[@"poleLineSegmentLength"] = meter;
        

        [_postPoleLineDatas addObject:postPoleLineDict];
        
        index++;
    }

}



#pragma mark - 关联杆路段的判断 ---

- (BOOL) chanrgeIsCanInsertToPoleLine: (Yuan_PointAnnotation *) yuan_Anno {
    
    if(_waitingConnectViewsArr.count < 1) {
        return true;
    }
    
    // 1. 两个杆路段 是否都不来自同一杆路下
    
    Yuan_PointAnnotation * before_Anno = _waitingConnectViewsArr.lastObject;
    
    if(![before_Anno.dataSource[@"poleLine_Id"] isEqualToString:_VM.mb_Dict[@"GID"]] &&
       ![yuan_Anno.dataSource[@"poleLine_Id"] isEqualToString:_VM.mb_Dict[@"GID"]]){
        
        [YuanHUD HUDFullText:@"至少有一个资源的所属杆路 , 是当前杆路"];
        return false;
    }
    
    
    // 2. 是否已经存在了当前杆路段
    
    NSString * startPole = [before_Anno.type isEqualToString:@"pole"] ? before_Anno.dataSource[@"poleSubName"] : before_Anno.dataSource[@"supportPSubName"];
    
    NSString * endPole = [yuan_Anno.type isEqualToString:@"pole"] ? yuan_Anno.dataSource[@"poleSubName"] : yuan_Anno.dataSource[@"supportPSubName"];
    
    
    NSString * nameCode = [NSString stringWithFormat:@"%@（%@_%@）",_VM.mb_Dict[@"poleLineName"],startPole,endPole];
    
    for(Yuan_PolyLine * line in _linesViewsArr) {
        
        if([line.dataSource[@"poleLineSegmentName"] isEqualToString:nameCode]) {
            
            [YuanHUD HUDFullText:@"已存在的杆路段"];
            return false;
            break;
        }
    }
    
    
    return true;
}

#pragma mark - 关联杆路段 ---

- (void) connectPoleLine {
    
    if (_waitingConnectViewsArr.count == 0) {
        
        if (_connectBlock) {
            _connectBlock();
        }
        
        return;
    }
    
    
    if (_waitingConnectViewsArr.count == 1) {
        [YuanHUD HUDFullText:@"无法形成杆路段"];
        return;
    }
    
    [UIAlert alertSmallTitle:@"是否确认关联杆路段"
               agreeBtnBlock:^(UIAlertAction *action) {
            
        [self http_ConnectPoleLines];

    }];
    

     
}

// 获取路由数据
- (NSArray *)getRouters {
    
    NSMutableArray * arrs = [NSMutableArray arrayWithArray:_routeAnnosViewsArr];
    [arrs addObjectsFromArray:_singleAnnosViewsArr];
    
    return arrs;
}


#pragma mark - 清除全部地图内容 ---

- (void) deleteAll {
    
    
    [_mapView removeAnnotations:_nearPoleViewsArr];
    [_mapView removeAnnotations:_nearSupportingPointViewsArr];
    [_mapView removeAnnotations:_routeAnnosViewsArr];
    [_mapView removeAnnotations:_singleAnnosViewsArr];
    
    [_mapView removeOverlays:_linesViewsArr];
    [_mapView removeOverlays:_xuLineArr];
    [_mapView removeOverlays:_linesViewsArr];
    
    
    _nearPoleViewsArr = NSMutableArray.array;
    _nearSupportingPointViewsArr = NSMutableArray.array;
    _routeAnnosViewsArr = NSMutableArray.array;
    _singleAnnosViewsArr = NSMutableArray.array;
    _linesViewsArr = NSMutableArray.array;
    _xuLineArr = NSMutableArray.array;
    _waitingConnectViewsArr = NSMutableArray.array;
}



@end
