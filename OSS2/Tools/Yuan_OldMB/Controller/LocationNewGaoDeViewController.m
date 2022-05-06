//
//  LocationNewGaoDeViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 16/6/12.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "LocationNewGaoDeViewController.h"

#import "CusButton.h"
#import "CusMAPointAnnotation.h"
#import "MBProgressHUD.h"

#import "StrUtil.h"
@interface LocationNewGaoDeViewController ()
@property (nonatomic, strong) NSTimer * timer;
@end
@implementation LocationNewGaoDeViewController
{
    BOOL isLocationSelf;//是否手动定位
    UIImageView *icm;//手动定位图标
    CusButton *locationReBtn;//重置定位按钮
    double lat,lon;//当前位置的经纬度
    NSMutableDictionary *postDic;//回传给上一页的信息
    CLLocationCoordinate2D ret;
    
    MBProgressHUD *HUD;

    StrUtil *strUtil;
    
    BOOL isFirst;//是否是第一次进来
    
    // 袁全添加  如果有经纬度 是手动模式的
    
    // 获取的经纬度
    CLLocationCoordinate2D _getCoordinate;
    
    // 是否成功获取到经纬度 , 如果是 改为手动模式 , 并且地图定位到该位置
    BOOL _isSuccessGetCoordinate;
    
}
@synthesize coordinate;





#pragma mark - 初始化构造方法

- (instancetype) initWithLocation:(CLLocationCoordinate2D)coordinate {
    
    if (self = [super init]) {
        
        _getCoordinate = coordinate;
        
        if (_getCoordinate.latitude != 0 && _getCoordinate.longitude != 0) {
            _isSuccessGetCoordinate = YES;
        }else {
            _isSuccessGetCoordinate = NO;
        }
        
    }
    return self;
}





- (void)viewDidLoad {
    
    self.title = @"资源定位";
    
    [self initNavigationBar];
    

    strUtil = [[StrUtil alloc]init];
    isFirst = YES;
    
    [self uiInit];
    if (!_isOffline) {
        if([self.fileName isEqualToString:@"ledUp"]||[self.fileName isEqualToString:@"OCC_Equt"]){
            //从引上点/OCC进来，需要显示所属井
            if (self.well==nil) {
                //需要从中心获取井信息
                [self wellDataInit];
            }else{
                //直接根据传过来的井信息显示在地图上
                [self addOverlayView];
            }
        }
    }
    
    [super viewDidLoad];
}
-(void)mapInit{
    _mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, HeigtOfTop, ScreenWidth, ScreenHeight-HeigtOfTop)];
    _mapView.scaleOrigin = CGPointMake(5, _mapView.frame.size.height-30);
    _mapView.logoCenter = CGPointMake(_mapView.frame.size.width-50, _mapView.frame.size.height-15);
    [self mapState:NO];
    _mapView.delegate = self;
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    //设置地图缩放级别
    [_mapView setZoomLevel:17.0 animated:NO];
    [_mapView setZoomEnabled:YES];
    
    if (_isSuccessGetCoordinate) {
        // 如果 get到了经纬度信息  则地图中心点设置到该位置信息 , 并且 手动定位模式 -- yuan
        [_mapView setCenterCoordinate:_getCoordinate animated:YES];
        [self Yuan_locationBySelf];
        
    }else{
        [_mapView setCenterCoordinate:coordinate];
        //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
        _mapView.userTrackingMode=MAUserTrackingModeFollow;
        _mapView.showsUserLocation = YES;//显示定位图层
    }
    
    [self.view addSubview:_mapView];
}
-(void)mapState:(BOOL) boo{

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
    
//    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setTitle:@"开启特效" forState:UIControlStateNormal];
//    [btn setTitle:@"关闭特效" forState:UIControlStateSelected];
//    [btn sizeToFit];
//    [btn addTarget:self action:@selector(open3D:) forControlEvents:UIControlEventTouchUpInside];
//
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开启3D"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(open3D)];
}
//-(void)open3D:(UIButton *)sender{
//    sender.selected = !sender.selected;
//
//    _mapView.skyModelEnable = !_mapView.skyModelEnable;
//    _mapView.rotateEnabled = !_mapView.rotateEnabled;
//    _mapView.rotateCameraEnabled = !_mapView.rotateCameraEnabled;
//    if (!sender.selected) {
//        //关闭特效时，地图角度恢复初始
//        _mapView.rotationDegree = 0.0;
//        _mapView.cameraDegree = 0.0;
//    }
//    
//}
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
-(void)uiInit{
    [self mapInit];
    
    CusButton *locationCommitBtn = [[CusButton alloc]initWithFrame:CGRectMake(ScreenWidth-110, HeigtOfTop+50, 100, 50)];
    [locationCommitBtn setTitle:@"确认定位" forState:UIControlStateNormal];
    [locationCommitBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [locationCommitBtn setBackgroundColor:[UIColor mainColor]];
    [locationCommitBtn addTarget:self action:@selector(locationCommit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationCommitBtn];
    
    CusButton *locationSelfBtn = [[CusButton alloc]initWithFrame:CGRectMake(ScreenWidth-110, HeigtOfTop+50+60, 100, 50)];
    [locationSelfBtn setTitle:@"手动定位" forState:UIControlStateNormal];
    [locationSelfBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [locationSelfBtn setBackgroundColor:[UIColor mainColor]];
    [locationSelfBtn addTarget:self action:@selector(locationSelf:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationSelfBtn];
    
    locationReBtn = [[CusButton alloc]initWithFrame:CGRectMake(ScreenWidth-110, HeigtOfTop+50+120, 100, 50)];
    [locationReBtn setTitle:@"重置定位" forState:UIControlStateNormal];
    [locationReBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [locationReBtn setBackgroundColor:[UIColor mainColor]];
    [locationReBtn addTarget:self action:@selector(locationRe:) forControlEvents:UIControlEventTouchUpInside];
    locationReBtn.hidden = YES;
    [self.view addSubview:locationReBtn];
    
    UIImage *image = [UIImage Inc_imageNamed:@"nav_turn_via_2"];
    icm = [[UIImageView alloc] initWithImage:image];
    CGPoint loc = {_mapView.frame.size.width/2 ,_mapView.frame.size.height/2};
    icm.center = loc;
    icm.hidden = YES;
    [_mapView addSubview:icm];
    
    
    if (_isSuccessGetCoordinate) {
        // 如果 get到了经纬度信息  则地图中心点设置到该位置信息 , 并且 手动定位模式 -- yuan
        [_mapView setCenterCoordinate:_getCoordinate animated:YES];
        [self Yuan_locationBySelf];
        
    }else{
        [_mapView setCenterCoordinate:coordinate];
        //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
        _mapView.userTrackingMode=MAUserTrackingModeFollow;
        _mapView.showsUserLocation = YES;//显示定位图层
    }
    
    
    
}
//添加资源覆盖物
- (void)addOverlayView{
    CusMAPointAnnotation *pointAnnotation = [[CusMAPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude = [[self.well objectForKey:@"lat"] doubleValue];
    coor.longitude = [[self.well objectForKey:@"lon"] doubleValue];
    pointAnnotation.coordinate = coor;
    [_mapView addAnnotation:pointAnnotation];
}
//确认定位按钮点击触发事件
-(IBAction)locationCommit:(CusButton *)sender
{
    NSString *msg = nil;
    
    if (isLocationSelf) {
        msg = [NSString stringWithFormat:@"经度：%f\n纬度：%f",_mapView.centerCoordinate.longitude,_mapView.centerCoordinate.latitude];
        ret = _mapView.centerCoordinate;
    }else{
        msg = [NSString stringWithFormat:@"经度：%f\n纬度：%f",lon,lat];
        ret.longitude = lon;
        ret.latitude = lat;
    }

    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"定位" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * save = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        if ([self.delegate respondsToSelector:@selector(saveCoordinate:withAddr:)] && !_isOffline) {
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            
            BOOL isAutoSetAddr = [[user valueForKey:@"isAutoSetAddr"] integerValue] == 2 ? NO : YES;
            if (isAutoSetAddr) {
                [self searchReGeocodeWithCoordinate:ret];
            }else{
                [self.delegate saveCoordinate:ret withAddr:@""];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }else if([self.delegate respondsToSelector:@selector(saveCoordinate:withAddr:)]){
             [self.delegate saveCoordinate:ret withAddr:@""];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [alert addAction:cancle];
    [alert addAction:save];
    Present(self, alert);
}
//井数据初始化
-(void)wellDataInit{

    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];
    
    //调用查询接口
    //测试用：{"needLedUp":"1","resLogicName":"well","pipe_Id":982}
    
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"resLogicName\":\"well\",\"wellId\":%d}",self.wellId]};
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * url = [NSString stringWithFormat:@"%@data!getData.interface",BaseURL];
#else
    NSString * url = [NSString stringWithFormat:@"%@data!getData.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    
    [Http.shareInstance POST:url parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {


        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            //操作执行完后取消对话框
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            if (arr.count>0) {
                self.well = arr[0];
                [self addOverlayView];
            }
        }else{
            //操作执行完后取消对话框
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            //操作失败，提示用户
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            if (dic==nil ||([dic objectForKey:@"info"]==nil)) {
                HUD.label.text = @"操作失败，数据为空";
            }else{
                HUD.detailsLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"info"]];
            }
            HUD.mode = MBProgressHUDModeText;
            
                        dispatch_async(dispatch_get_main_queue(), ^{
                
                HUD.mode = MBProgressHUDModeText ;
                
                
                
                [HUD hideAnimated:YES afterDelay:2];
                
                HUD = nil;
            });
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.label.text = @"亲，网络请求出错了";
        HUD.detailsLabel.text = error.localizedDescription;
        HUD.mode = MBProgressHUDModeText;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            HUD.mode = MBProgressHUDModeText ;
            
            [HUD hideAnimated:YES afterDelay:2];
            
            HUD = nil;
        });
        
    }];
}
-(void)startTimeOutListen{
    
    
        if (HUD == nil) {
            [YuanHUD HUDFullText:@"正在获取地址，请稍候……"];
        }
    
    
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10.f target:self selector:@selector(showTimeOutHint) userInfo:nil repeats:NO];
        
    }
}

-(void)showTimeOutHint{
    [self.timer invalidate];
    self.timer = nil;
    // 超时提示
    [_search cancelAllRequests];
    [HUD hideAnimated:YES];
//    HUD = nil;
//    UIViewController * vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    
    if (self.delegate) {
        AlertShow([UIApplication sharedApplication].keyWindow, @"地址获取失败", 2.f, @"网络状态不佳，请稍候重试。");
        
        if ([self.delegate respondsToSelector:@selector(saveCoordinate:withAddr:)]) {
            [self.delegate saveCoordinate:ret withAddr:nil];
        }
        
        ;// 不要写成nil，否则代理方法里还得改——！（set a nil object to dict）
    }
    
    
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)location
{
    
    // 开始超时监听
    [self startTimeOutListen];
    
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:location.latitude longitude:location.longitude];
    regeo.requireExtension = YES;
    
    [_search AMapReGoecodeSearch:regeo];
}


//手动定位按钮点击触发事件
-(IBAction)locationSelf:(CusButton *)sender
{
    isLocationSelf = YES;
    //停止定位监听
    _mapView.showsUserLocation = NO;//显示定位图层
    
    icm.hidden = NO;
    locationReBtn.hidden = NO;
}
//重置定位按钮点击触发事件
-(IBAction)locationRe:(CusButton *)sender
{
    if (_isSuccessGetCoordinate) {
        // 如果 有传过来的经纬度 , 回到刚才的位置上
        coordinate = _getCoordinate;
    }else {
        // 如果没有传过来的经纬度 , 回到本人当前位置
        coordinate = CLLocationCoordinate2DMake(lat,lon);
    }
    
    
    int zoomLevel = _mapView.zoomLevel;
    MACoordinateRegion region ;//表示范围的结构体
    region.center = coordinate;//中心点
    [_mapView setRegion:region animated:YES];
    [_mapView setCenterCoordinate:coordinate];
    [_mapView setZoomLevel:zoomLevel animated:NO];
    
}


/// 袁全 模拟手动定位
- (void) Yuan_locationBySelf{
    
    isLocationSelf = YES;
    //停止定位监听
    _mapView.showsUserLocation = NO;//显示定位图层
    
    icm.hidden = NO;
    locationReBtn.hidden = NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewWillAppear:(BOOL)animated
{
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
    _search.delegate = self;
    [super viewWillAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [self.view.layer removeAllAnimations];
    _mapView = nil;
    _search = nil;
    _mapView.showsUserLocation = NO;
    _mapView.delegate = nil; // 不用时，置nil
    _search.delegate = nil;
    self.delegate = nil;// 反地理编码会多次回调代理方法，可能会导致程序崩溃，。2017年01月13日14:26:17，by HSKW， 2017年01月21日 挪到这里
    [super viewDidDisappear:animated];
}
// Override
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    
    
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]] && ![annotation isKindOfClass:[MAUserLocation class]]) {
        //设置覆盖物显示相关基本信息
        MAAnnotationView *annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
//        annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_well"];
        annotationView.image = [UIImage Inc_imageNamed:@"red_point"];
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height*0.5));
        annotationView.draggable = NO;
        
        
        //在大头针上绘制文字
        UILabel *lable=[[UILabel alloc]init];
        lable.font=[UIFont systemFontOfSize:13];
        lable.textColor=[UIColor blueColor];
        lable.text=@"关联的井";
        [lable sizeToFit];
        [annotationView addSubview:lable];
        
        CGRect viewFrame = annotationView.frame;
        viewFrame.size.width = 30.f;
        viewFrame.size.height = 30.f;
        annotationView.frame = viewFrame;
        
        return annotationView;
        
    }
    return nil;
    
}
#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation)
    {
        if (isFirst) {
            
            isFirst = NO;
            NSLog(@"userlocation :%@", userLocation.location);
            lat =userLocation.location.coordinate.latitude;
            lon = userLocation.location.coordinate.longitude;
            coordinate = CLLocationCoordinate2DMake(lat,lon);
            MACoordinateRegion region ;//表示范围的结构体
            region.center = coordinate;//中心点
            region.span.latitudeDelta = 0.1;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
            region.span.longitudeDelta = 0.1;//纬度范围
            [_mapView setRegion:region animated:NO];
            [_mapView setZoomLevel:17.0 animated:NO];
        }
       
    }
}


#pragma mark - AMapSearchDelegate

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
    [self.timer invalidate];
    self.timer = nil;
    
    [HUD hideAnimated:YES];
    HUD = nil;
    [_search cancelAllRequests];
    if (response.regeocode != nil)
    {
        NSLog(@"%f,%f,%@",ret.latitude,ret.longitude,response.regeocode.formattedAddress);
        [self.delegate saveCoordinate:ret withAddr:response.regeocode.formattedAddress];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [_search cancelAllRequests];
    
    [self.timer invalidate];
    self.timer = nil;
    
    _search = nil;
}
-(void)viewDidAppear:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [super viewDidAppear:animated];
}
@end
