//
//  ResourceLocationTYKViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2018/1/29.
//  Copyright © 2018年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "ResourceLocationTYKViewController.h"

#import "CusMAPointAnnotation.h"
#import "IWPPropertiesReader.h"
#import "TYKDeviceInfoMationViewController.h"
#import "GeneratorTYKViewController.h"
#import "ResourceTYKListViewController.h"

#import "MBProgressHUD.h"
#import "IWPCleanCache.h"
#import "StrUtil.h"
@interface ResourceLocationTYKViewController ()<TYKDeviceInfomationDelegate>
@property (nonatomic, strong) IWPPropertiesReader * reader;
@property (nonatomic, strong) IWPPropertiesSourceModel * mainModel;
@property (nonatomic, strong) NSArray <IWPViewModel *>* viewModel;
@property (nonatomic, weak) id<ptotocolDelegate> delegate;

@end

@implementation ResourceLocationTYKViewController
{
    
    NSMutableArray *pointAnnotationArray;
    NSInteger annotationIndex;
    
    MBProgressHUD *HUD;
    long index;
    long indexOffline;
}
@synthesize labelText;
@synthesize imageName;
@synthesize resourceArray;
@synthesize resourceOfflineArray;
@synthesize latIn;
@synthesize lonIn;
@synthesize type;
@synthesize nameArray;
@synthesize nameOfflineArray;
@synthesize selectIndex;
@synthesize coordinate;
- (void)viewDidLoad {
    
    
    self.title = labelText;
    
    [self initNavigationBar];
    
    pointAnnotationArray = [[NSMutableArray alloc]init];

    index = -1;
    indexOffline = -1;
    
    [self uiInit];
    
    [self initOverlay];
    [super viewDidLoad];
    
}
-(void)uiInit{
    _mapView = [[MAMapView alloc]initWithFrame:self.view.bounds];
    
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
    [self mapState:NO];
    
    
    CGPoint center = _mapView.logoCenter;
    center.x += 10.f;
    center.y -= 10.f;
    _mapView.logoCenter = center;
    
    [self.view addSubview:_mapView];
}
-(void)mapState:(BOOL) boo{
    //_mapView.showsBuildings = boo;
//    _mapView.skyModelEnable = boo;
    _mapView.rotateEnabled = boo;
    _mapView.rotateCameraEnabled = boo;
    if (boo == NO) {
        //关闭特效时，地图角度恢复初始
        _mapView.rotationDegree = 0.0;
        _mapView.cameraDegree = 0.0;
    }else{
        //开启特效时，地图设置一定角度
        _mapView.cameraDegree = 39.0;
    }
}

- (void)initNavigationBar
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开启3D"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(open3D)];
}
- (void)open3D
{
    if (_mapView.rotateEnabled) {
        [self mapState:NO];
        self.navigationItem.rightBarButtonItem=nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开启3D"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(open3D)];
    }else{
        [self mapState:YES];
        self.navigationItem.rightBarButtonItem=nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭3D"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(open3D)];
    }
}
//初始化地图显示位置
- (void)initOverlay {
    if ([latIn isEqualToString:@""]) {
        latIn = @"0.000000";
    }
    if ([lonIn isEqualToString:@""]) {
        lonIn = @"0.000000";
    }
    coordinate = CLLocationCoordinate2DMake([latIn doubleValue],[lonIn doubleValue]);
    MACoordinateRegion region ;//表示范围的结构体
    region.center = coordinate;//中心点
    region.span.latitudeDelta = 0.1;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
    region.span.longitudeDelta = 0.1;//纬度范围
    [_mapView setRegion:region animated:NO];
    NSLog(@"lat:%f,lon:%f",region.center.latitude,region.center.longitude);
    
    NSLog(@"lat:%f,lon:%f",_mapView.centerCoordinate.latitude,_mapView.centerCoordinate.longitude);
    
    //设置地图缩放级别
    [_mapView setZoomLevel:15 animated:YES];
    
    selectIndex = 100000000;
    //设置地图类型
    _mapView.mapType=MAMapTypeStandard;
    NSLog(@"lat:%f,lon:%f",_mapView.centerCoordinate.latitude,_mapView.centerCoordinate.longitude);
    
}
//添加资源覆盖物
- (void)addOverlayView{
    NSLog(@"添加资源覆盖物");
    //    [mapView removeAnnotations:pointAnnotationArray];//清空图层
    [pointAnnotationArray removeAllObjects];
    //清空
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    annotationIndex = 0;
    
    //加载项目资源信息
    for (int i = 0; i<[resourceArray count]; i++) {
        annotationIndex = i;
        CusMAPointAnnotation *pointAnnotation = [[CusMAPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        coor.latitude = [[resourceArray[i] objectForKey:@"lat"] doubleValue];
        coor.longitude = [[resourceArray[i] objectForKey:@"lon"] doubleValue];
        pointAnnotation.coordinate = coor;
        pointAnnotation.tag = 1000000+i;
        pointAnnotation.title = nameArray[i];
        pointAnnotation.subtitle = [NSString stringWithFormat:@"%d",1000000+i];
        [_mapView addAnnotation:pointAnnotation];
    }
    NSLog(@"resourceOfflineArray count:%lu",(unsigned long)[resourceOfflineArray count]);
    for (int i = 0; i<[resourceOfflineArray count]; i++) {
        annotationIndex = i;
        CusMAPointAnnotation *pointAnnotation = [[CusMAPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        coor.latitude = [[resourceOfflineArray[i] objectForKey:@"lat"] doubleValue];
        coor.longitude = [[resourceOfflineArray[i] objectForKey:@"lon"] doubleValue];
        pointAnnotation.coordinate = coor;
        pointAnnotation.tag = 2000000+i;
        pointAnnotation.title = nameOfflineArray[i];
        pointAnnotation.subtitle = [NSString stringWithFormat:@"%d",2000000+i];
        [_mapView addAnnotation:pointAnnotation];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.view.layer removeAllAnimations];
    _mapView.delegate = nil; // 不用时，置nil
}
-(void)viewDidAppear:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
    [self addOverlayView];
    [super viewDidAppear:animated];
}
// Override
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    CusMAPointAnnotation *cusAnotation = (CusMAPointAnnotation *)annotation;
    
    if ([annotation isKindOfClass:[CusMAPointAnnotation class]]) {
        //设置覆盖物显示相关基本信息
        MAAnnotationView *annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        NSInteger tag = [annotation.subtitle intValue];
        NSLog(@"-------%ld,%ld",selectIndex,(long)tag);
        if (selectIndex == tag) {
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
        }
        else{
            annotationView.image = [UIImage Inc_imageNamed:imageName];
        }
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height*0.5));
        annotationView.draggable = YES;
        
        
        //在大头针上绘制文字
        UILabel *lable=[[UILabel alloc]init];
        lable.font=[UIFont systemFontOfSize:13];
        
        
        if ([type isEqualToString:@"occ"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                NSString *title = [resourceArray[cusAnotation.tag-1000000] objectForKey:@"occName"];
                lable.text=title;
                lable.textColor=[UIColor blueColor];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                NSString *title = [resourceOfflineArray[cusAnotation.tag-2000000] objectForKey:@"occName"];
                lable.text=title;
                lable.textColor = [UIColor colorWithHexString:@"#dfc200"];
            }
            
        }else if ([type isEqualToString:@"station"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                NSString *title = [resourceArray[cusAnotation.tag-1000000] objectForKey:@"stationName"];
                lable.text=title;
                lable.textColor=[UIColor blueColor];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                NSString *title = [resourceOfflineArray[cusAnotation.tag-2000000] objectForKey:@"stationName"];
                lable.text=title;
                lable.textColor = [UIColor colorWithHexString:@"#dfc200"];
            }
            
        }else if ([type isEqualToString:@"generator"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                NSString *title = [resourceArray[cusAnotation.tag-1000000] objectForKey:@"generatorName"];
                lable.text=title;
                lable.textColor=[UIColor blueColor];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                NSLog(@"tag:%ld",cusAnotation.tag);
                NSString *title = [resourceOfflineArray[cusAnotation.tag-2000000] objectForKey:@"generatorName"];
                lable.text=title;
                lable.textColor = [UIColor colorWithHexString:@"#dfc200"];
            }
            
        }else if ([type isEqualToString:@"EquipmentPoint"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                NSString *title = [resourceArray[cusAnotation.tag-1000000] objectForKey:@"EquipmentPointName"];
                lable.text=title;
                lable.textColor=[UIColor blueColor];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                NSLog(@"tag:%ld",cusAnotation.tag);
                NSString *title = [resourceOfflineArray[cusAnotation.tag-2000000] objectForKey:@"EquipmentPointName"];
                lable.text=title;
                lable.textColor = [UIColor colorWithHexString:@"#dfc200"];
            }
            
        }else if ([type isEqualToString:@"markStone"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                NSString *title = [resourceArray[cusAnotation.tag-1000000] objectForKey:@"markName"];
                lable.text=title;
                lable.textColor=[UIColor blueColor];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                NSLog(@"tag:%ld",cusAnotation.tag);
                NSString *title = [resourceOfflineArray[cusAnotation.tag-2000000] objectForKey:@"markName"];
                lable.text=title;
                lable.textColor = [UIColor colorWithHexString:@"#dfc200"];
            }
            
        }else if ([type isEqualToString:@"odb"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                NSString *title = [resourceArray[cusAnotation.tag-1000000] objectForKey:@"odbName"];
                lable.text=title;
                lable.textColor=[UIColor blueColor];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                NSLog(@"tag:%ld",cusAnotation.tag);
                NSString *title = [resourceOfflineArray[cusAnotation.tag-2000000] objectForKey:@"odbName"];
                lable.text=title;
                lable.textColor = [UIColor colorWithHexString:@"#dfc200"];
            }
            
        }else if ([type isEqualToString:@"joint"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                NSString *title = [resourceArray[cusAnotation.tag-1000000] objectForKey:@"jointName"];
                lable.text=title;
                lable.textColor=[UIColor blueColor];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                NSLog(@"tag:%ld",cusAnotation.tag);
                NSString *title = [resourceOfflineArray[cusAnotation.tag-2000000] objectForKey:@"jointName"];
                lable.text=title;
                lable.textColor = [UIColor colorWithHexString:@"#dfc200"];
            }
            
        }
        [lable sizeToFit];
        [annotationView addSubview:lable];
        
        return annotationView;
        
    }
    return nil;
    
}
//当选中一个annotation views时，调用此接口
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    
    
    CusMAPointAnnotation *cusAnotation = (CusMAPointAnnotation *)view.annotation;
    
    /* 非自己工单 */
    
    NSString * TASKID = [resourceArray[cusAnotation.tag-1000000] valueForKey:@"taskId"];
    
    if (![StrUtil isMyOrderWithTaskId:TASKID] && TASKID != nil) {
        
        /* 取出工单 */
        NSString * taskId = [StrUtil taskIdWithTaskId:TASKID];
        /* 工单接收人 */
        NSString * reciverName = [StrUtil reciverWithTaskId:TASKID];
        /* 提示 */
        [YuanHUD HUDFullText:@"无权操作该工单资源"];
        return;
    }
    
    
    if ([view.annotation isKindOfClass:[MAPointAnnotation class]]) {
        //            获取地图的所有标注点 同时获取标注点的标注view
        for (CusMAPointAnnotation *cmpa in [mapView annotations]) {
            MAAnnotationView * maav = [_mapView viewForAnnotation:cmpa];
            if ([maav isKindOfClass:[MAPointAnnotation class]]) {
                maav.image = [UIImage Inc_imageNamed:imageName];
            }
        }
        
        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
        
        /// 设置当前地图的中心点 把选中的标注作为地图中心点
        [_mapView setCenterCoordinate:view.annotation.coordinate animated:YES] ;
        //                    view.tag = 100+i;
        selectIndex = [view.annotation.subtitle intValue];
        
        
        //跳转到详细信息界面
        if ([type isEqualToString:@"occ"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                [self propertiesReader:@"OCC_Equt"];
                
                NSDictionary * occDict = resourceArray[cusAnotation.tag-1000000];
                
                TYKDeviceInfoMationViewController * occ = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:occDict withFileName:@"OCC_Equt"];
                occ.isInWorkOrder = _isInWorkOrder;
                occ.taskId = occDict[@"taskId"];
                occ.delegate = self;
                occ.isOffline = [self isOfflineDevice:occDict];
                index = cusAnotation.tag-1000000;
                [self.navigationController pushViewController:occ animated:YES];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                [self propertiesReader:@"OCC_Equt"];
                
                NSDictionary * occDict = resourceOfflineArray[cusAnotation.tag-2000000];
                
                TYKDeviceInfoMationViewController * occ = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:occDict withFileName:@"OCC_Equt"];
                occ.delegate = self;
                occ.taskId = occDict[@"taskId"];
                occ.isInWorkOrder = _isInWorkOrder;
                occ.isOffline = [self isOfflineDevice:occDict];
                indexOffline = cusAnotation.tag-2000000;
                [self.navigationController pushViewController:occ animated:YES];
            }
        }else if ([type isEqualToString:@"station"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                [self propertiesReader:@"stationBase"];
                
                NSDictionary * stationBaseDict = resourceArray[cusAnotation.tag-1000000];
                
                TYKDeviceInfoMationViewController *station = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:stationBaseDict withFileName:@"stationBase"];
                station.delegate = self;
                station.isInWorkOrder = _isInWorkOrder;
                station.taskId = stationBaseDict[@"taskId"];
                station.isOffline = [self isOfflineDevice:stationBaseDict];
                index = cusAnotation.tag-1000000;
                [self.navigationController pushViewController:station animated:YES];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                [self propertiesReader:@"stationBase"];
                
                NSDictionary * stationBaseDict = resourceOfflineArray[cusAnotation.tag-2000000];
                
                TYKDeviceInfoMationViewController *station = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:stationBaseDict withFileName:@"stationBase"];
                station.delegate = self;
                station.taskId = stationBaseDict[@"taskId"];
                station.isOffline = [self isOfflineDevice:stationBaseDict];
                indexOffline = cusAnotation.tag-2000000;
                [self.navigationController pushViewController:station animated:YES];
            }
            
        }else if ([type isEqualToString:@"generator"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                [self propertiesReader:@"generator"];
                
                NSDictionary * generatorDict = resourceArray[cusAnotation.tag-1000000];
                
                GeneratorTYKViewController *generator = [GeneratorTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:generatorDict withFileName:@"generator"];
                generator.delegate = self;
                generator.isInWorkOrder = _isInWorkOrder;
                generator.taskId = _taskId;
                generator.isOffline = [self isOfflineDevice:generatorDict];
                index = cusAnotation.tag-1000000;
                [self.navigationController pushViewController:generator animated:YES];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                [self propertiesReader:@"generator"];
                
                NSDictionary * generatorDict = resourceOfflineArray[cusAnotation.tag-2000000];
                
                GeneratorTYKViewController *generator = [GeneratorTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:generatorDict withFileName:@"generator"];
                generator.delegate = self;
                generator.isInWorkOrder = _isInWorkOrder;
                generator.taskId = generatorDict[@"taskId"];
                generator.isOffline = [self isOfflineDevice:resourceOfflineArray[cusAnotation.tag-2000000]];
                NSLog(@"generator.isOffline:%@",generator.isOffline == YES?@"YES":@"NO");
                indexOffline = cusAnotation.tag-2000000;
                [self.navigationController pushViewController:generator animated:YES];
            }
        }else if ([type isEqualToString:@"EquipmentPoint"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                [self propertiesReader:@"EquipmentPoint"];
                
                NSDictionary * equipmentPointDict = resourceArray[cusAnotation.tag-1000000];
                
                TYKDeviceInfoMationViewController *equipmentPoint = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:equipmentPointDict withFileName:@"EquipmentPoint"];
                equipmentPoint.delegate = self;
                equipmentPoint.isInWorkOrder = _isInWorkOrder;
                equipmentPoint.taskId = _taskId;
                equipmentPoint.isOffline = [self isOfflineDevice:equipmentPointDict];
                index = cusAnotation.tag-1000000;
                [self.navigationController pushViewController:equipmentPoint animated:YES];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                [self propertiesReader:@"EquipmentPoint"];
                
                NSDictionary * equipmentPointDict = resourceOfflineArray[cusAnotation.tag-2000000];
                
                TYKDeviceInfoMationViewController *equipmentPoint = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:equipmentPointDict withFileName:@"EquipmentPoint"];
                equipmentPoint.delegate = self;
                equipmentPoint.isInWorkOrder = _isInWorkOrder;
                equipmentPoint.taskId = equipmentPointDict[@"taskId"];
                equipmentPoint.isOffline = [self isOfflineDevice:resourceOfflineArray[cusAnotation.tag-2000000]];
                NSLog(@"EquipmentPoint.isOffline:%@",equipmentPoint.isOffline == YES?@"YES":@"NO");
                indexOffline = cusAnotation.tag-2000000;
                [self.navigationController pushViewController:equipmentPoint animated:YES];
            }
        }else if ([type isEqualToString:@"markStone"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                [self propertiesReader:@"markStone"];
                
                NSDictionary * markStoneDict = resourceArray[cusAnotation.tag-1000000];
                
                TYKDeviceInfoMationViewController *markStone = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:markStoneDict withFileName:@"markStone"];
                markStone.delegate = self;
                markStone.isInWorkOrder = _isInWorkOrder;
                markStone.taskId = _taskId;
                markStone.isOffline = [self isOfflineDevice:markStoneDict];
                index = cusAnotation.tag-1000000;
                [self.navigationController pushViewController:markStone animated:YES];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                [self propertiesReader:@"markStone"];
                
                NSDictionary * markStoneDict = resourceOfflineArray[cusAnotation.tag-2000000];
                
                TYKDeviceInfoMationViewController *markStone = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:markStoneDict withFileName:@"markStone"];
                markStone.delegate = self;
                markStone.isInWorkOrder = _isInWorkOrder;
                markStone.taskId = markStoneDict[@"taskId"];
                markStone.isOffline = [self isOfflineDevice:resourceOfflineArray[cusAnotation.tag-2000000]];
                NSLog(@"markStone.isOffline:%@",markStone.isOffline == YES?@"YES":@"NO");
                indexOffline = cusAnotation.tag-2000000;
                [self.navigationController pushViewController:markStone animated:YES];
            }
        }else if ([type isEqualToString:@"odb"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                [self propertiesReader:@"ODB_Equt"];
                
                NSDictionary * odbDict = resourceArray[cusAnotation.tag-1000000];
                
                TYKDeviceInfoMationViewController *odb = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:odbDict withFileName:@"ODB_Equt"];
                odb.delegate = self;
                odb.isInWorkOrder = _isInWorkOrder;
                odb.taskId = _taskId;
                odb.isOffline = [self isOfflineDevice:odbDict];
                index = cusAnotation.tag-1000000;
                [self.navigationController pushViewController:odb animated:YES];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                [self propertiesReader:@"ODB_Equt"];
                
                NSDictionary * odbDict = resourceOfflineArray[cusAnotation.tag-2000000];
                
                TYKDeviceInfoMationViewController *odb = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:odbDict withFileName:@"ODB_Equt"];
                odb.delegate = self;
                odb.isInWorkOrder = _isInWorkOrder;
                odb.taskId = odbDict[@"taskId"];
                odb.isOffline = [self isOfflineDevice:resourceOfflineArray[cusAnotation.tag-2000000]];
                NSLog(@"ODB_Equt.isOffline:%@",odb.isOffline == YES?@"YES":@"NO");
                indexOffline = cusAnotation.tag-2000000;
                [self.navigationController pushViewController:odb animated:YES];
            }
        }else if ([type isEqualToString:@"joint"]) {
            if (cusAnotation.tag>=1000000 &&cusAnotation.tag<2000000) {
                //在线
                [self propertiesReader:@"joint"];
                
                NSDictionary * jointDict = resourceArray[cusAnotation.tag-1000000];
                
                TYKDeviceInfoMationViewController *joint = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:jointDict withFileName:@"joint"];
                joint.delegate = self;
                joint.isInWorkOrder = _isInWorkOrder;
                joint.taskId = _taskId;
                joint.isOffline = [self isOfflineDevice:jointDict];
                index = cusAnotation.tag-1000000;
                [self.navigationController pushViewController:joint animated:YES];
            }else if (cusAnotation.tag>=2000000 &&cusAnotation.tag<3000000){
                //离线
                [self propertiesReader:@"joint"];
                
                NSDictionary * jointDict = resourceOfflineArray[cusAnotation.tag-2000000];
                
                TYKDeviceInfoMationViewController *joint = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:jointDict withFileName:@"joint"];
                joint.delegate = self;
                joint.isInWorkOrder = _isInWorkOrder;
                joint.taskId = jointDict[@"taskId"];
                joint.isOffline = [self isOfflineDevice:resourceOfflineArray[cusAnotation.tag-2000000]];
                NSLog(@"joint.isOffline:%@",joint.isOffline == YES?@"YES":@"NO");
                indexOffline = cusAnotation.tag-2000000;
                [self.navigationController pushViewController:joint animated:YES];
            }
        }
        
        
        [_mapView selectAnnotation:nil animated:NO];
    }
}
#pragma mark 解析文件

-(void)propertiesReader:(NSString *)fileName{
  
    
    NSString * UNI_FileName = [NSString stringWithFormat:@"UNI_%@",fileName];
    
    self.mainModel = [[IWPPropertiesReader propertiesReaderWithFileName:UNI_FileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] mainModel];
    self.viewModel = [[IWPPropertiesReader propertiesReaderWithFileName:UNI_FileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] viewModels];
}
-(void)didReciveANewDeviceOnMap:(NSDictionary *)dict isTakePhoto:(BOOL)isTakePhoto{
    //离线调用这个
    NSInteger Secindex = 0;
    NSInteger SecindexOffline = 0;
    if ([type isEqualToString:@"occ"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"occName"]];
        }else{
            //离线
            for (NSDictionary * dict2 in self.resourceOfflineArray) {
                if ([dict2[@"deviceId"] isEqualToNumber:dict[@"deviceId"]]) {
                    break;
                }
                SecindexOffline++;
            }
            
            [self.resourceOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict];
            [self.nameOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict[@"occName"]];
        }
        
    }else if ([type isEqualToString:@"station"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"stationName"]];
        }else{
            //离线
            for (NSDictionary * dict2 in self.resourceOfflineArray) {
                if ([dict2[@"deviceId"] isEqualToNumber:dict[@"deviceId"]]) {
                    break;
                }
                SecindexOffline++;
            }
            
            [self.resourceOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict];
            [self.nameOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict[@"stationName"]];
        }
        
    }else if ([type isEqualToString:@"generator"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"generatorName"]];
        }else{
            for (NSDictionary * dict2 in self.resourceOfflineArray) {
                if ([dict2[@"deviceId"] isEqualToNumber:dict[@"deviceId"]]) {
                    break;
                }
                SecindexOffline++;
            }
            
            [self.resourceOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict];
            [self.nameOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict[@"generatorName"]];
        }
    }else if ([type isEqualToString:@"EquipmentPoint"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"EquipmentPointName"]];
        }else{
            for (NSDictionary * dict2 in self.resourceOfflineArray) {
                if ([dict2[@"deviceId"] isEqualToNumber:dict[@"deviceId"]]) {
                    break;
                }
                SecindexOffline++;
            }
            
            [self.resourceOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict];
            [self.nameOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict[@"EquipmentPointName"]];
        }
    }else if ([type isEqualToString:@"markStone"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"markName"]];
        }else{
            for (NSDictionary * dict2 in self.resourceOfflineArray) {
                if ([dict2[@"deviceId"] isEqualToNumber:dict[@"deviceId"]]) {
                    break;
                }
                SecindexOffline++;
            }
            
            [self.resourceOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict];
            [self.nameOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict[@"markName"]];
        }
    }else if ([type isEqualToString:@"odb"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"odbName"]];
        }else{
            for (NSDictionary * dict2 in self.resourceOfflineArray) {
                if ([dict2[@"deviceId"] isEqualToNumber:dict[@"deviceId"]]) {
                    break;
                }
                SecindexOffline++;
            }
            
            [self.resourceOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict];
            [self.nameOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict[@"odbName"]];
        }
    }else if ([type isEqualToString:@"joint"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"jointName"]];
        }else{
            for (NSDictionary * dict2 in self.resourceOfflineArray) {
                if ([dict2[@"deviceId"] isEqualToNumber:dict[@"deviceId"]]) {
                    break;
                }
                SecindexOffline++;
            }
            
            [self.resourceOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict];
            [self.nameOfflineArray replaceObjectAtIndex:SecindexOffline withObject:dict[@"jointName"]];
        }
    }
    
    NSArray *array = [self.navigationController viewControllers];
    if ([[array objectAtIndex:array.count-3] isKindOfClass:[ResourceTYKListViewController class]]) {
        //列表页面进来
        ResourceTYKListViewController *iWPDeviceListVC = (ResourceTYKListViewController *)[array objectAtIndex:array.count-3];
        self.delegate=iWPDeviceListVC;
        [self.delegate newDeciceWithDict:dict];
    }else if ([[array objectAtIndex:array.count-4] isKindOfClass:[ResourceTYKListViewController class]]) {
        //列表页面进来(拍照)
        ResourceTYKListViewController *iWPDeviceListVC = (ResourceTYKListViewController *)[array objectAtIndex:array.count-4];
        self.delegate=iWPDeviceListVC;
        [self.delegate newDeciceWithDict:dict];
    }
    
    if (!isTakePhoto) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)newDeciceWithDict:(NSDictionary<NSString *,NSString *> *)dict{
    //在线调用这个,包括在线转离线
    NSInteger Secindex = 0;
    //    NSInteger SecindexOffline = 0;
    if ([type isEqualToString:@"occ"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"occName"]];
        }else{
            //在线转离线
            
            //去掉在线的
            [resourceArray removeObjectAtIndex:index];
            [self.nameArray removeObjectAtIndex:index];
            //添加离线的
            if (self.resourceOfflineArray == nil) {
                self.resourceOfflineArray = [[NSMutableArray alloc] init];
            }
            [self.resourceOfflineArray addObject:dict];
            [self.nameOfflineArray addObject:dict];
            selectIndex = 2000000+[self.resourceOfflineArray count]-1;
        }
    }else if ([type isEqualToString:@"station"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"stationName"]];
        }else{
            //在线转离线
            
            //去掉在线的
            [resourceArray removeObjectAtIndex:index];
            [self.nameArray removeObjectAtIndex:index];
            //添加离线的
            if (self.resourceOfflineArray == nil) {
                self.resourceOfflineArray = [[NSMutableArray alloc] init];
            }
            [self.resourceOfflineArray addObject:dict];
            [self.nameOfflineArray addObject:dict];
            selectIndex = 2000000+[self.resourceOfflineArray count]-1;
        }
    }else if ([type isEqualToString:@"generator"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"generatorName"]];
        }else{
            //在线转离线
            
            //去掉在线的
            [resourceArray removeObjectAtIndex:index];
            [self.nameArray removeObjectAtIndex:index];
            //添加离线的
            if (self.resourceOfflineArray == nil) {
                self.resourceOfflineArray = [[NSMutableArray alloc] init];
            }
            [self.resourceOfflineArray addObject:dict];
            [self.nameOfflineArray addObject:dict];
            selectIndex = 2000000+[self.resourceOfflineArray count]-1;
        }
        
    }else if ([type isEqualToString:@"EquipmentPoint"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"EquipmentPointName"]];
        }else{
            //在线转离线
            
            //去掉在线的
            [resourceArray removeObjectAtIndex:index];
            [self.nameArray removeObjectAtIndex:index];
            //添加离线的
            if (self.resourceOfflineArray == nil) {
                self.resourceOfflineArray = [[NSMutableArray alloc] init];
            }
            [self.resourceOfflineArray addObject:dict];
            [self.nameOfflineArray addObject:dict];
            selectIndex = 2000000+[self.resourceOfflineArray count]-1;
        }
        
    }else if ([type isEqualToString:@"markStone"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"markName"]];
        }else{
            //在线转离线
            
            //去掉在线的
            [resourceArray removeObjectAtIndex:index];
            [self.nameArray removeObjectAtIndex:index];
            //添加离线的
            if (self.resourceOfflineArray == nil) {
                self.resourceOfflineArray = [[NSMutableArray alloc] init];
            }
            [self.resourceOfflineArray addObject:dict];
            [self.nameOfflineArray addObject:dict];
            selectIndex = 2000000+[self.resourceOfflineArray count]-1;
        }
        
    }else if ([type isEqualToString:@"odb"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"odbName"]];
        }else{
            //在线转离线
            
            //去掉在线的
            [resourceArray removeObjectAtIndex:index];
            [self.nameArray removeObjectAtIndex:index];
            //添加离线的
            if (self.resourceOfflineArray == nil) {
                self.resourceOfflineArray = [[NSMutableArray alloc] init];
            }
            [self.resourceOfflineArray addObject:dict];
            [self.nameOfflineArray addObject:dict];
            selectIndex = 2000000+[self.resourceOfflineArray count]-1;
        }
    }else if ([type isEqualToString:@"joint"]) {
        if (![self isOfflineDevice:dict]) {
            //在线
            for (NSDictionary * dict2 in self.resourceArray) {
                if ([dict2[@"GID"] isEqualToString:dict[@"GID"]]) {
                    break;
                }
                Secindex++;
            }
            
            [self.resourceArray replaceObjectAtIndex:Secindex withObject:dict];
            [self.nameArray replaceObjectAtIndex:Secindex withObject:dict[@"jointName"]];
        }else{
            //在线转离线
            
            //去掉在线的
            [resourceArray removeObjectAtIndex:index];
            [self.nameArray removeObjectAtIndex:index];
            //添加离线的
            if (self.resourceOfflineArray == nil) {
                self.resourceOfflineArray = [[NSMutableArray alloc] init];
            }
            [self.resourceOfflineArray addObject:dict];
            [self.nameOfflineArray addObject:dict];
            selectIndex = 2000000+[self.resourceOfflineArray count]-1;
        }
    }
    
    NSArray *array = [self.navigationController viewControllers];
    if ([[array objectAtIndex:array.count-3] isKindOfClass:[ResourceTYKListViewController class]]) {
        //列表页面进来
        ResourceTYKListViewController *iWPDeviceListVC = (ResourceTYKListViewController *)[array objectAtIndex:array.count-3];
        self.delegate=iWPDeviceListVC;
        [self.delegate newDeciceWithDict:dict];
    }else if ([[array objectAtIndex:array.count-4] isKindOfClass:[ResourceTYKListViewController class]]) {
        //列表页面进来(拍照)
        ResourceTYKListViewController *iWPDeviceListVC = (ResourceTYKListViewController *)[array objectAtIndex:array.count-4];
        self.delegate=iWPDeviceListVC;
        [self.delegate newDeciceWithDict:dict];
    }
    
    
    // 保存一次
    
    if ([dict[@"deviceId"] integerValue] > 0) {
        [[IWPCleanCache new] saveDeviceToLocation:dict];
    }
    
    
}
-(void)deleteDeviceWithDict:(NSDictionary *)dict
    withViewControllerClass:(__unsafe_unretained Class)vcClass{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确定要删除该%@?",_mainModel.name] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteDevice:dict];
    }];
    UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        return;
    }];
    
    [alert addAction:actionYES];
    [alert addAction:actionNO];
    Present(self, alert);
    
}

-(BOOL)isOfflineDevice:(NSDictionary *)dict{
    // 判断该设备是否为离线设备
    if ([dict[@"deviceId"] integerValue] > 0) {
        return YES;
    }
    return NO;
}
-(void)deleteDevice:(NSDictionary *)dict{
    NSLog(@"resourceArray:----%@",resourceArray);
    NSLog(@"offline:----%@",resourceOfflineArray);
    // 删除事件
    
    if (![self isOfflineDevice:dict]) {
        
#ifdef BaseURL
        NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL, @"rm!deleteCommonData.interface"];
#else
        NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL_Auto(([IWPServerService sharedService].link)), @"rm!deleteCommonData.interface"];
#endif
        
        NSLog(@"%@",requestURL);
        
        NSMutableDictionary * param = [NSMutableDictionary dictionary];
        [param setValue:UserModel.uid forKey:@"UID"];
        
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [param setValue:str forKey:@"jsonRequest"];
        [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
 
            NSDictionary *dic = responseObject;
            
            if([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {

                
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除成功" preferredStyle: UIAlertControllerStyleAlert];
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    if (resourceArray!=nil) {
                        [resourceArray removeObjectAtIndex:index];
                        [self.nameArray removeObjectAtIndex:index];
                        
                        [self addOverlayView];
                        NSArray *array = [self.navigationController viewControllers];
                        if ([[array objectAtIndex:array.count-3] isKindOfClass:[ResourceTYKListViewController class]]) {
                            //列表页面进来
                            ResourceTYKListViewController *iWPDeviceListVC = (ResourceTYKListViewController *)[array objectAtIndex:array.count-3];
                            self.delegate=iWPDeviceListVC;
                            [self.delegate reloadTableViewWithDict:dict];
                        }
                    }
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
                [alert addAction:action];
                Present(self.navigationController, alert);
            }else{

                [YuanHUD HUDFullText:@"操作失败，数据为空"];
            }
            
            
            
        }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [YuanHUD HUDFullText:@"亲，网络请求出错了"];
            });
        }];
    }else{
        if (resourceOfflineArray!=nil) {
            [resourceOfflineArray removeObjectAtIndex:indexOffline];
            [self.nameOfflineArray removeObjectAtIndex:indexOffline];
            
            [self addOverlayView];
            NSArray *array = [self.navigationController viewControllers];
            if ([[array objectAtIndex:array.count-3] isKindOfClass:[ResourceTYKListViewController class]]) {
                //列表页面进来
                ResourceTYKListViewController *iWPDeviceListVC = (ResourceTYKListViewController *)[array objectAtIndex:array.count-3];
                self.delegate=iWPDeviceListVC;
                //                iWPDeviceListVC.indexPath = [NSIndexPath indexPathForRow:indexOffline inSection:0];
                [self.delegate reloadTableViewWithDict:dict];
            }
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    selectIndex = 100000000;
}
@end
