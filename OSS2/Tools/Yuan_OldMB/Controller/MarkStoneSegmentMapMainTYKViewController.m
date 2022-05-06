//
//  MarkStoneSegmentMapMainTYKViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2018/1/29.
//  Copyright © 2018年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "MarkStoneSegmentMapMainTYKViewController.h"
#import "MBProgressHUD.h"

#import "CusMAPolyline.h"
#import "StrUtil.h"
#import "CusMAPointAnnotation.h"
#import "TYKDeviceInfoMationViewController.h"
#import "IWPPropertiesReader.h"
#import "IWPCleanCache.h"


@interface MarkStoneSegmentMapMainTYKViewController () <TYKDeviceInfomationDelegate>
@property (strong, nonatomic) NSMutableArray * markStoneArray;//获取到的标石信息列表
@property (nonatomic, assign) long selectIndex;//当前点击的覆盖物
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) IWPPropertiesReader * reader;
@property (nonatomic, strong) IWPPropertiesSourceModel * mainModel;
@property (nonatomic, strong) NSArray <IWPViewModel *>* viewModel;
@end
@implementation MarkStoneSegmentMapMainTYKViewController
{
    MBProgressHUD *HUD;
    
    NSInteger annotationIndex;
    CusMAPointAnnotation *pointAnnotation;//覆盖物
    NSMutableArray *MAPolylineArray;//折线覆盖物列表
    StrUtil *strUtil;
}
@synthesize selectIndex;
@synthesize coordinate;
- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"标石段定位";
    
    [self initNavigationBar];
    [self propertiesReader:@"markStone"];
    

    MAPolylineArray = [[NSMutableArray alloc] init];
    _markStoneArray = [[NSMutableArray alloc] init];
    selectIndex = 1000000;
    strUtil = [[StrUtil alloc]init];
    
    [self uiInit];
    [self getStartMarkStoneDate];
    [super viewDidLoad];
}
-(void)propertiesReader:(NSString *)fileName{
  
    self.mainModel = [[IWPPropertiesReader propertiesReaderWithFileName:fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] mainModel];
    self.viewModel = [[IWPPropertiesReader propertiesReaderWithFileName:fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] viewModels];
    
}
-(void)uiInit{
    _mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, HeigtOfTop, ScreenWidth,ScreenHeight-HeigtOfTop)];
    _mapView.scaleOrigin = CGPointMake(5, _mapView.frame.size.height-30);
    _mapView.logoCenter = CGPointMake(_mapView.frame.size.width-50, _mapView.frame.size.height-15);
    _mapView.showsCompass = NO;
    [self mapState:NO];
    
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
//地图定位显示
-(void)mapLocationInit{
    if ([_markStoneArray count]>0) {
        //当列表不为空且至少有一个资源有坐标时
        NSString *latIn = [_markStoneArray[0] objectForKey:@"lat"];
        NSString *lonIn = [_markStoneArray[0] objectForKey:@"lon"];
        
        
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
        [_mapView setRegion:region animated:YES];
        
        
        //设置地图缩放级别
        [_mapView setZoomLevel:17 animated:NO];
        
        selectIndex = 1000000;
        //设置地图类型
        _mapView.mapType=MAMapTypeStandard;
        
    }else{
        //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
        _mapView.userTrackingMode=MAUserTrackingModeFollow;
        _mapView.showsUserLocation = YES;//显示定位图层
        
        [YuanHUD HUDFullText:@"没有标石记录，无法获取标石经纬度"];
    }
}
//添加资源覆盖物
- (void)addOverlayView{
    //清空
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (MAAnnotationView *view in _mapView.annotations) {
        if (![view isKindOfClass:[MAUserLocation class]]) {
            [arr addObject:view];
        }
    }
    NSArray *array = [NSArray arrayWithArray:arr];
    [_mapView removeAnnotations:array];
    
    arr = [[NSMutableArray alloc] init];
    for (NSObject *view in _mapView.overlays) {
        if (![view isKindOfClass:[MACircle class]]) {
            [arr addObject:view];
        }
    }
    array = [NSArray arrayWithArray:arr];
    [_mapView removeOverlays:array];
    annotationIndex = 0;
    //加载标石资源信息
    for (int i = 0; i<[_markStoneArray count]; i++) {
        annotationIndex = i;
        pointAnnotation = [[CusMAPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        
        coor.latitude = [[_markStoneArray[i] objectForKey:@"lat"] doubleValue];
        coor.longitude = [[_markStoneArray[i] objectForKey:@"lon"] doubleValue];
        pointAnnotation.tag = 10000+i;
        
        pointAnnotation.coordinate = coor;
        pointAnnotation.subtitle = [NSString stringWithFormat:@"%d",10000+i];
        
        NSLog(@"annotationIndex:%ld",(long)annotationIndex);
        [_mapView addAnnotation:pointAnnotation];
        
    }
}
//添加资源画线
-(void)addLineView
{
    [MAPolylineArray removeAllObjects];
    //加载标石段资源信息
    NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
    NSMutableArray *points = [[NSMutableArray alloc] init];
    for (int j = 0; j<_markStoneArray.count; j++) {
        NSMutableDictionary *markStone = _markStoneArray[j];
        if ([[NSString stringWithFormat:@"%@",[markStone objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[_markStoneSegment objectForKey:@"startmarkStone_Id"]]]) {
            [p1 setObject:[markStone objectForKey:@"lat"] forKey:@"lat"];
            [p1 setObject:[markStone objectForKey:@"lon"] forKey:@"lon"];
            [points addObject:p1];
        }
        if ([[NSString stringWithFormat:@"%@",[markStone objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[_markStoneSegment objectForKey:@"endmarkStone_Id"]]]) {
            [p2 setObject:[markStone objectForKey:@"lat"] forKey:@"lat"];
            [p2 setObject:[markStone objectForKey:@"lon"] forKey:@"lon"];
            [points addObject:p2];
        }
        if (p1!=nil && p2!=nil && [[p1 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p1 objectForKey:@"lon"] doubleValue]&& [[p2 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p2 objectForKey:@"lon"] doubleValue]) {
            CLLocationCoordinate2D coors[2] = {0};
            coors[0].latitude = [[p1 objectForKey:@"lat"] doubleValue];
            coors[0].longitude = [[p1 objectForKey:@"lon"] doubleValue];
            coors[1].latitude = [[p2 objectForKey:@"lat"] doubleValue];
            coors[1].longitude = [[p2 objectForKey:@"lon"] doubleValue];
            
            
            CusMAPolyline *polyline = [CusMAPolyline polylineWithCoordinates:coors count:2];
            [MAPolylineArray addObject:polyline];
            
            
            [_mapView addOverlay:polyline];
            break;
        }
    }
}
//获取当前标石段起始标石的信息
-(void)getStartMarkStoneDate
{
  
    [Yuan_HUD.shareInstance HUDStartText:@"请稍等"];
    
    //调用查询接口
    //测试用：{"needLedUp":"1","resLogicName":"well","pipe_Id":982}
    
    NSDictionary *param = nil;
    
    
    param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"1000\",\"resLogicName\":\"markStone\",\"GID\":%@}",[self.markStoneSegment objectForKey:@"startmarkStone_Id"]]};
    
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
    
    
    __weak typeof(self) wself = self;
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@rm!getCommonData.interface",baseURL] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {


            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            
            
            for (NSDictionary * markStone in arr) {
                if ([markStone[@"lat"] length] > 0) {
                    [self.markStoneArray addObject:markStone];
                }
            }
            [wself getEndMarkStoneDate];
        }else{

            if (dic==nil ||([dic objectForKey:@"info"]==nil)) {

                [YuanHUD HUDFullText:@"操作失败，数据为空"];

            }else{

                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];

            }
           
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
    }];
}
//获取当前标石段终止标石的信息
-(void)getEndMarkStoneDate
{

    [Yuan_HUD.shareInstance HUDStartText:@"请稍等"];
    
    //调用查询接口
    //测试用：{"needLedUp":"1","resLogicName":"well","pipe_Id":982}
    
    NSDictionary *param = nil;
    
    
    param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"1000\",\"resLogicName\":\"markStone\",\"GID\":%@}",[self.markStoneSegment objectForKey:@"endmarkStone_Id"]]};
    
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
    
    
    __weak typeof(self) wself = self;
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@rm!getCommonData.interface",baseURL] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {


            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            
            
            for (NSDictionary * markStone in arr) {
                if ([markStone[@"lat"] length] > 0) {
                    [self.markStoneArray addObject:markStone];
                }
            }
            NSLog(@"self.markStoneArray:%@",self.markStoneArray);
            [wself mapLocationInit];
            [wself addOverlayView];
            [wself addLineView];
        }else{
            if (dic==nil ||([dic objectForKey:@"info"]==nil)) {

                [YuanHUD HUDFullText:@"操作失败，数据为空"];

            }else{

                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];

            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
    }];
}
// Override
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    CusMAPointAnnotation *cusAnotation = (CusMAPointAnnotation *)annotation;
    if ([annotation isKindOfClass:[CusMAPointAnnotation class]]) {
        //设置覆盖物显示相关基本信息
        MAAnnotationView *annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        NSInteger tag = [annotation.subtitle intValue];
        //设置标注的图片
        NSDictionary * dict = _markStoneArray[cusAnotation.tag-10000];
        
        NSString *doType = dict[@"doType"];
        
        if (selectIndex == tag) {
            if ([doType isEqualToString:@"isGuanlian"]) {
                annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
            }else if ([doType isEqualToString:@"isGLD"]) {
                annotationView.image = [UIImage Inc_imageNamed:@"icon_biaoshi_cable"];
            }else{
                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
            }
            //在大头针上绘制文字
            if ([dict[@"resLogicName"] isEqualToString:@"markStone"]){
                UILabel *lable=[strUtil makeAnnotationViewLabel:dict[@"markStoneNumber"] :nil :@"号标":NO];
                if ([[dict valueForKey:@"deviceId"] integerValue] > 0) {
                    // 离线设备
                    lable.textColor = [UIColor mainColor];
                    lable.font = [UIFont boldSystemFontOfSize:13.f];
                }
                [annotationView addSubview:lable];
            }
        }else if ([dict[@"resLogicName"] isEqualToString:@"markStone"]){
            if ([doType isEqualToString:@"isGuanlian"]) {
                annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
            }else if ([doType isEqualToString:@"isGLD"]) {
                annotationView.image = [UIImage Inc_imageNamed:@"icon_biaoshi_cable"];
            }else{
                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_tyk"];
            }
            //在大头针上绘制文字
            UILabel *lable=[strUtil makeAnnotationViewLabel:dict[@"markStoneNumber"] :nil :@"号标":NO];
            if ([[dict valueForKey:@"deviceId"] integerValue] > 0) {
                // 离线设备
                lable.textColor = [UIColor mainColor];
                lable.font = [UIFont boldSystemFontOfSize:13.f];
            }
            [annotationView addSubview:lable];
        }
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height*0.5));
        annotationView.draggable = YES;
        
        return annotationView;
        
    }
    return nil;
}
//当选中一个annotation views时，调用此接口
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    CusMAPointAnnotation *cusAnotation = (CusMAPointAnnotation *)view.annotation;
    if ([view.annotation isKindOfClass:[CusMAPointAnnotation class]]) {
        NSMutableDictionary * resourceDic = [[NSMutableDictionary alloc] initWithDictionary:_markStoneArray[cusAnotation.tag-10000]];
        NSLog(@"resourceDic:%@",resourceDic);
        NSString * TASKID = resourceDic[@"taskId"];
        if (![StrUtil isMyOrderWithTaskId:TASKID] && TASKID != nil && TASKID.length > 0) {
            /* 取出工单 */
            NSString * taskId = [StrUtil taskIdWithTaskId:TASKID];
            /* 工单接收人 */
            NSString * reciverName = [StrUtil reciverWithTaskId:TASKID];
            /* 提示 */
            [YuanHUD HUDFullText:@"无权操作该工单资源"];
            return;
        }
        
        //查看所选资源的详细信息
        //            获取地图的所有标注点 同时获取标注点的标注view
        for (CusMAPointAnnotation *cmpa in [mapView annotations]) {
            MAAnnotationView * maav = [_mapView viewForAnnotation:cmpa];
            if ([maav isKindOfClass:[MAPointAnnotation class]]) {
                NSDictionary * dict = _markStoneArray[maav.tag-10000];
                if ([dict[@"resLogicName"] isEqualToString:@"markStone"]) {
                    maav.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_tyk"];
                }
                
            }
        }
        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
        
        // 设置当前地图的中心点 把选中的标注作为地图中心点
        [_mapView setCenterCoordinate:view.annotation.coordinate animated:YES] ;
        selectIndex = [view.annotation.subtitle intValue];
        
        //跳转到详细信息界面
        if ([resourceDic[@"resLogicName"] isEqualToString:@"markStone"]) {
            TYKDeviceInfoMationViewController * markStone = [[TYKDeviceInfoMationViewController alloc] initWithControlMode:TYKDeviceListUpdate withMainModel:self.mainModel withViewModel:_viewModel withDataDict:resourceDic withFileName:@"markStone"];
            markStone.delegate = self;
            //暂时写死
            markStone.isOffline = NO;
            markStone.isSubDevice = markStone.isOffline;
            [self.navigationController pushViewController:markStone animated:YES];
        }
        [_mapView selectAnnotation:nil animated:NO];
        [_mapView deselectAnnotation:view.annotation animated:YES];
    }
}
//根据overlay生成对应的View
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[CusMAPolyline class]])
    {
        MAPolylineRenderer* polylineView = [[MAPolylineRenderer alloc] initWithOverlay:overlay];
        CusMAPolyline *temp = (CusMAPolyline *)overlay;
        if (temp.type == 1) {
//            polylineView.lineDash     = YES;
        }
        polylineView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:1];
        polylineView.lineWidth = 5.0;
        
        return polylineView;
    }
    return nil;
}
-(void)newDeciceWithDict:(NSDictionary<NSString *,NSString *> *)dict{
    NSLog(@"dict:%@",dict);
    for (int i = 0; i<_markStoneArray.count; i++) {
        if ([_markStoneArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
            [_markStoneArray replaceObjectAtIndex:i withObject:dict];
            break;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewDidDisappear:(BOOL)animated
{
    [self.view.layer removeAllAnimations];
    _mapView.delegate = nil; // 不用时，置nil
    [super viewDidDisappear:animated];
}
-(void)viewDidAppear:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [self addOverlayView];
    [self addLineView];
    [super viewDidAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}
@end
