//
//  PipeMapMainTYKViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/10/9.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "PipeMapMainTYKViewController.h"

#import "CusButton.h"
#import "CusMAPolyline.h"
#import "MBProgressHUD.h"

#import "StrUtil.h"
#import "CusMAPointAnnotation.h"
#import "TYKDeviceInfoMationViewController.h"
#import "IWPPropertiesReader.h"
#import "IWPCleanCache.h"

#define isOfflineDevice(dict) [self isOfflineDevice:(dict)]
@interface PipeMapMainTYKViewController ()<TYKDeviceInfomationDelegate>
@property (strong,nonatomic)UITableView *wellTableView;
@property (strong, nonatomic) NSMutableArray * pipeSegmentArray;//获取到的管道段信息列表
@property (strong,nonatomic) NSMutableArray *faceArray;//获取到的面集合
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSMutableArray * wellArray;//获取到的井信息列表
@property (strong, nonatomic)NSMutableArray *wellLocationArray;//含有经纬度坐标的井列表
@property (strong, nonatomic) NSMutableArray *ledupLocationArray;//含有经纬度坐标的引上点列表
@property (strong, nonatomic) NSMutableArray *occLocationArray;//含有经纬度坐标的OCC列表
@property long selectWellIndex;//当前点击的井覆盖物
@property long selectLedUpIndex;//当前点击的引上点覆盖物
@property long selectOCCIndex;//当前点击的引OCC覆盖物
@property (nonatomic, strong) IWPPropertiesReader * wellReader;
@property (nonatomic, strong) IWPPropertiesSourceModel * wellMainModel;
@property (nonatomic, strong) NSArray <IWPViewModel *>* wellViewModel;

@property (nonatomic, strong) IWPPropertiesReader * ledUpReader;
@property (nonatomic, strong) IWPPropertiesSourceModel * ledUpMainModel;
@property (nonatomic, strong) NSArray <IWPViewModel *>* ledUpViewModel;
@property (nonatomic, strong) NSArray * offlineLedUps;


@property (nonatomic, strong) IWPPropertiesReader * occReader;
@property (nonatomic, strong) IWPPropertiesSourceModel * occMainModel;
@property (nonatomic, strong) NSArray <IWPViewModel *>* occViewModel;
@property (nonatomic, strong) NSArray * offlineOCCs;


@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) BOOL isAutoSetAddr;
@end

@implementation PipeMapMainTYKViewController
{
    UIView *doLayout;//列表操作显示域
    CusButton *getBtn;//分页获取按钮
    
    NSString *latIn;//定位中心点的纬度
    NSString *lonIn;//定位中心点的经度
    MBProgressHUD *HUD;
    NSInteger wellAnnotationIndex;//井
    NSInteger ledUpAnnotationIndex;//引上点
    NSInteger occAnnotationIndex;//OCC
    
    CusMAPointAnnotation *pointAnnotation;//覆盖物
    NSMutableArray *MAPolylineArray;//折线覆盖物列表
    NSMutableArray *pipeSegTypeArray;//折线颜色类型列表
    
    
    BOOL isLocationSelf;//是否手动定位
    UIImageView *icm;//手动定位图标
    UIView *guanlianView;//关联管道段操作域
    UITextField *startText;//起始设施域
    UITextField *endText;//终止设施域
    BOOL isGuanlian;//是否是关联模式
    StrUtil *strUtil;
    double lat,lon;//当前定位坐标
    
    NSMutableArray *pipeSegInfoList;//关联的管道段列表
    NSDictionary *wellselectDic;//关联管道段时当前点击的井
    long wellViewSelectTag;//关联管道段时当前点击井的覆盖物的tag
    
    //井面选择状态
    NSArray *wellFaceSelectArray;
    NSMutableDictionary *faceMuDic;//面
    
    //传感器图片
    UIImageView *arrowImageView;
    //当前是修改管道段还是新建管道段操作
    BOOL isUpdate;
    NSMutableDictionary * newWell;//新增井
    BOOL isFirst;//是否是第一次进来
    BOOL isAddPipeSeg;//当前是否为添加管道段模式下
    NSMutableString *lastClickType;//上一次点击的覆盖物类型
    
    BOOL isSetLevel;
    NSInteger zoomLevel;
    BOOL isFirstAdd;//是否是第一次逆地理编码添加
    
    int limit;
    int radius;
    BOOL isADD;
    
    NSMutableArray *btnShowArr;//显示的按钮数组
    BOOL _isYuanAutoAdd;
}
@synthesize wellTableView;
@synthesize coordinate;
@synthesize wellArray;
@synthesize wellLocationArray;
@synthesize ledupLocationArray;
@synthesize occLocationArray;
@synthesize selectWellIndex;
@synthesize selectLedUpIndex;
@synthesize selectOCCIndex;
- (void)viewDidLoad {
    [self createPropertiesReader];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"管道地图核查";
    
    
    [self initNavigationBar];
    wellArray = [NSMutableArray array];
    wellLocationArray = [[NSMutableArray alloc]init];
    ledupLocationArray = [[NSMutableArray alloc] init];
    occLocationArray = [[NSMutableArray alloc] init];
    MAPolylineArray = [[NSMutableArray alloc] init];
    pipeSegTypeArray = [[NSMutableArray alloc] init];
    lastClickType = [[NSMutableString alloc] init];

    isLocationSelf = NO;
    isGuanlian = NO;
    isFirst = YES;
    isSetLevel = NO;
    strUtil = [[StrUtil alloc]init];
    btnShowArr = [NSMutableArray array];
    isFirstAdd = YES;
    isADD = NO;
    
    limit = 100;
    radius = 500;
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([user valueForKey:@"locationRadius"]!=nil) {
        radius = [[user valueForKey:@"locationRadius"] intValue];
        
    }
    _isAutoSetAddr = [[user valueForKey:@"isAutoSetAddr"] integerValue] == 2 ? NO : YES;
    
    locationManager= [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    if ([CLLocationManager headingAvailable]) {
        //设置精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设置滤波器不工作
        locationManager.headingFilter = kCLHeadingFilterNone;
        //开始更新
        [locationManager startUpdatingHeading];
    }
    
    [self uiInit];
    
    
//    if ([user valueForKey:@"isLocationPages"]!=nil&&[[user valueForKey:@"isLocationPages"] intValue]==2) {
//        //关闭定位分页
//        [self getWellDate];
//    }else{
//        //开启定位分页
//        NSDictionary * param = nil;
//
//        param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"%d\",\"resLogicName\":\"well\",\"id\":%@}",limit,[self.pipe objectForKey:@"GID"]]};
//
//        NSLog(@"param:%@",param);
//
//        [self getWellAndSegmentDate:param :YES];
//    }
    [self getWellDate];
    
    [super viewDidLoad];
}
#pragma mark 解析文件
- (void)createPropertiesReader{

    
    // MARK: 袁全修改 ,  错误原因也是添加UNI_模板 , 由于原先这个类里filename 是写死的 , 所以有错误 , 新版统一库改为 UNI_pole
    
    NSString * wellFilename = @"UNI_well";
    NSString * ledUpFilename = @"UNI_ledUp";
    NSString * OCC_EqutFilename = @"UNI_OCC_Equt";
    
    self.wellReader = [IWPPropertiesReader propertiesReaderWithFileName:wellFilename withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
    
    self.wellMainModel = [IWPPropertiesSourceModel modelWithDict:self.wellReader.result];
    // 创建viewModel
    NSMutableArray * arrr = [NSMutableArray array];
    for (NSDictionary * dict in self.wellMainModel.view) {
        IWPViewModel * viewModel = [IWPViewModel modelWithDict:dict];
        [arrr addObject:viewModel];
    }
    self.wellViewModel = arrr;
    
    self.ledUpReader = [IWPPropertiesReader propertiesReaderWithFileName:ledUpFilename withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
    self.ledUpMainModel = [IWPPropertiesSourceModel modelWithDict:self.ledUpReader.result];
    
    NSMutableArray * arr = [NSMutableArray array];
    for (NSDictionary * dict in self.ledUpMainModel.view) {
        IWPViewModel * viewModel = [IWPViewModel modelWithDict:dict];
        [arr addObject:viewModel];
    }
    self.ledUpViewModel = arr;
    
    self.occReader = [IWPPropertiesReader propertiesReaderWithFileName:OCC_EqutFilename withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
    self.occMainModel = [IWPPropertiesSourceModel modelWithDict:self.occReader.result];
    
    NSMutableArray * ar = [NSMutableArray array];
    for (NSDictionary * dict in self.occMainModel.view) {
        IWPViewModel * viewModel = [IWPViewModel modelWithDict:dict];
        [ar addObject:viewModel];
    }
    self.occViewModel = ar;
}
- (void)initNavigationBar
{
    UIButton *open3DBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    /* 普通状态下显示打开 */
    [open3DBtn setTitle:@"3D" forState:UIControlStateNormal];
    /* 选中状态下显示关闭 */
    [open3DBtn setTitle:@"2D" forState:UIControlStateSelected];
    [open3DBtn sizeToFit];
    /* 添加点击事件 */
    [open3DBtn addTarget:self action:@selector(open3D:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //    /* 创建关闭/打开按钮 */
    //    UIButton * showOrHideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    //    /* 普通状态下显示打开 */
    //    [showOrHideButton setTitle:@"列表" forState:UIControlStateNormal];
    //    /* 选中状态下显示关闭 */
    //    [showOrHideButton setTitle:@"隐藏" forState:UIControlStateSelected];
    //
    //    [showOrHideButton sizeToFit];
    //    /* 添加点击事件 */
    //    [showOrHideButton addTarget:self action:@selector(showOrHideContentView:) forControlEvents:UIControlEventTouchUpInside];
    
    /* 取出当前右侧按钮 */
    NSMutableArray * items = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    
    /* 新建一个item，以 showOrHideButton 初始化*/
    //    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:showOrHideButton];
    UIBarButtonItem * item1 = [[UIBarButtonItem alloc] initWithCustomView:open3DBtn];
    
    /* 加入数组 */
    //    [items addObject:item];
    [items addObject:item1];
    
    /* 赋值 */
    self.navigationItem.rightBarButtonItems = items;
}
- (void)open3D:(UIButton *)sender
{
    if (sender.selected) {
        [self mapState:NO];
    }else{
        [self mapState:YES];
    }
    sender.selected = !sender.selected;
}
-(void)showOrHideContentView:(UIButton *)sender{
    
    /* 开始动画 */
    [UIView animateWithDuration:.3f animations:^{
        /* 取出视图当前位置 */
        CGRect frame = doLayout.frame;
        CGRect getBtnFrame = getBtn.frame;
        if (!sender.selected) {
            // 展开
            
            frame.origin.y = HeigtOfTop;
            getBtnFrame.origin.y = frame.size.height+5;
            
        }else{
            // 收起
            if (btnShowArr.count<6) {
                frame.origin.y = HeigtOfTop - frame.size.height+45;
                getBtnFrame.origin.y = 50;
            }else{
                frame.origin.y = HeigtOfTop - frame.size.height+70;
                getBtnFrame.origin.y = 75;
            }
        }
        
        doLayout.frame = frame;
        getBtn.frame = getBtnFrame;
    }];
    
    sender.selected = !sender.selected;
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
-(void)uiInit{
    MAMapView * mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, HeigtOfTop, ScreenWidth,ScreenHeight-HeigtOfTop)];
    self.mapView = mapView;
    _mapView.scaleOrigin = CGPointMake(5, _mapView.frame.size.height-30);
    _mapView.showsCompass = NO;
    _mapView.logoCenter = CGPointMake(_mapView.frame.size.width-50, _mapView.frame.size.height-15);
    [self mapState:NO];
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    [self.view addSubview:_mapView];
    
    doLayout = [[UIView alloc] initWithFrame:CGRectMake(0,HeigtOfTop-(ScreenHeight-HeigtOfTop)/3+45,ScreenWidth,(ScreenHeight-HeigtOfTop)/3)];
    [doLayout setBackgroundColor:[UIColor colorWithHexString:@"#dcdcdc"]];
    [self.view addSubview:doLayout];
    
    wellTableView=[[UITableView alloc] initWithFrame:CGRectMake(2, 2, doLayout.frame.size.width-4,doLayout.frame.size.height-4-45) style:UITableViewStyleGrouped];
    wellTableView.backgroundColor=[UIColor whiteColor];
    [wellTableView setEditing:NO];
    wellTableView.delegate=self;
    wellTableView.dataSource=self;
    [doLayout addSubview:wellTableView];
    
    CusButton *nowLocationBtn = [self btnInit:@"当前位置"];
    [nowLocationBtn addTarget:self action:@selector(nowLocation:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowArr addObject:nowLocationBtn];
    CusButton *selfLocationBtn = [self btnInit:@"手动定位"];
    [selfLocationBtn addTarget:self action:@selector(selfLocation:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowArr addObject:selfLocationBtn];
    CusButton *nearWellBtn = [self btnInit:@"附近井"];
    [nearWellBtn addTarget:self action:@selector(nearWell:) forControlEvents:UIControlEventTouchUpInside];
    [nearWellBtn setBackgroundColor:[UIColor mainColor]];
    [btnShowArr addObject:nearWellBtn];
    CusButton *addWellBtn = [self btnInit:@"添加井"];
    [addWellBtn addTarget:self action:@selector(addWell:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowArr addObject:addWellBtn];
    CusButton *guanlianBtn = [self btnInit:@"关联井管道段"];
    [guanlianBtn addTarget:self action:@selector(guanlian:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowArr addObject:guanlianBtn];
    
    //根据权限显示
    if ([UserModel.domainCode isEqualToString:@"0/"] ) {
        [btnShowArr removeObject:addWellBtn];
        [btnShowArr removeObject:guanlianBtn];
    }
    if (([[UserModel.powersTYKDic[@"well"] substringToIndex:1] integerValue] == 0)){
        //无添加井权限
        [btnShowArr removeObject:addWellBtn];
    }
    if (([[UserModel.powersTYKDic[@"pipeSegment"] substringToIndex:1] integerValue] == 0)){
        //无添加管道段权限
        [btnShowArr removeObject:guanlianBtn];
    }
    [self showBtn];
    
    guanlianView = [[UIView alloc] initWithFrame:CGRectMake(0, HeigtOfTop, ScreenWidth, /*180*/60)];
    [guanlianView setBackgroundColor:[UIColor whiteColor]];
    [guanlianView setHidden:YES];
    [self.view addSubview:guanlianView];
//    UILabel *qishiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, ScreenWidth/5, 60)];
//    [qishiLabel setText:@"起始设施:"];
//    qishiLabel.font=[UIFont systemFontOfSize:14];
//    [guanlianView addSubview:qishiLabel];
//    startText = [[UITextField alloc] initWithFrame:CGRectMake(ScreenWidth/5, 0, ScreenWidth/5*4, 60)];
//    [startText setBorderStyle:UITextBorderStyleRoundedRect];
//    [startText setEnabled:NO];
//    startText.textAlignment = NSTextAlignmentLeft;
//    [guanlianView addSubview:startText];
//    UILabel *zhongzhiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,60, ScreenWidth/5, 60)];
//    [zhongzhiLabel setText:@"终止设施:"];
//    zhongzhiLabel.font=[UIFont systemFontOfSize:14];
//    [guanlianView addSubview:zhongzhiLabel];
//    endText = [[UITextField alloc] initWithFrame:CGRectMake(ScreenWidth/5, 60, ScreenWidth/5*4, 60)];
//    [endText setBorderStyle:UITextBorderStyleRoundedRect];
//    [endText setEnabled:NO];
//    [guanlianView addSubview:endText];
    
    
    CusButton *saveGuanlian = [[CusButton alloc]initWithFrame:CGRectMake(0, /*120*/0, ScreenWidth/2, 60)];
    [saveGuanlian setTitle:@"保存" forState:UIControlStateNormal];
    [saveGuanlian setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [saveGuanlian setBackgroundColor:[UIColor mainColor]];
    [saveGuanlian addTarget:self action:@selector(saveGuanlian:) forControlEvents:UIControlEventTouchUpInside];
    [guanlianView addSubview:saveGuanlian];
    CusButton *cancelGuanlian = [[CusButton alloc]initWithFrame:CGRectMake(ScreenWidth/2, /*120*/0, ScreenWidth/2, 60)];
    [cancelGuanlian setTitle:@"取消" forState:UIControlStateNormal];
    [cancelGuanlian setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [cancelGuanlian setBackgroundColor:[UIColor mainColor]];
    [cancelGuanlian addTarget:self action:@selector(cancelGuanlian:) forControlEvents:UIControlEventTouchUpInside];
    [guanlianView addSubview:cancelGuanlian];
    
    
    UIImage *image = [UIImage Inc_imageNamed:@"nav_turn_via_2"];
    icm = [[UIImageView alloc] initWithImage:image];
    CGPoint loc = {_mapView.frame.size.width/2 ,_mapView.frame.size.height/2};
    icm.center = loc;
    icm.hidden = YES;
    [_mapView addSubview:icm];
    
    arrowImageView = [[UIImageView alloc] initWithImage:[UIImage Inc_imageNamed:@"zhinanzhen.png"]];
    [arrowImageView setFrame:CGRectMake(_mapView.frame.size.width-60, _mapView.frame.size.height-60, 60, 60)];
    [_mapView addSubview:arrowImageView];
    
//    //分页模式下显示获取按钮
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//    if ([[user objectForKey:@"isLocationPages"] integerValue] != 2) {
//        int y = 0;
//        if (btnShowArr.count<6) {
//            y = 45;
//        }else{
//            y = 70;
//        }
//        getBtn = [[CusButton alloc] initWithFrame:CGRectMake(_mapView.frame.size.width-_mapView.frame.size.width/5-5, y+5, _mapView.frame.size.width/5, 40)];
//        getBtn.layer.cornerRadius = 5;
//        [getBtn setTitle:@"获取" forState:UIControlStateNormal];
//        [getBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
//        getBtn.tag = 8298374;
//        [getBtn setBackgroundColor:[UIColor mainColor]];
//        [getBtn addTarget:self action:@selector(getResource:) forControlEvents:UIControlEventTouchUpInside];
//        [getBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
//        [_mapView addSubview:getBtn];
//    }
    
}
//操作按钮初始化
-(CusButton *)btnInit:(NSString *)btnTitle{
    CusButton *btn = [CusButton new];
    [btn setTitle:btnTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor mainColor]];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    btn.titleLabel.numberOfLines = 0;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    return btn;
}
//显示操作按钮
-(void)showBtn{
    for (int i = 0; i<btnShowArr.count; i++) {
        CusButton *btn = btnShowArr[i];
        if (btnShowArr.count<6) {
            [btn setFrame:CGRectMake(0+(ScreenWidth/btnShowArr.count)*i, doLayout.frame.size.height-45, ScreenWidth/btnShowArr.count, 45)];
        }else{
            [doLayout setFrame:CGRectMake(0,HeigtOfTop-(ScreenHeight-HeigtOfTop)/3+45,ScreenWidth,(ScreenHeight-HeigtOfTop)/3+(70-45))];
            if (i<5) {
                [btn setFrame:CGRectMake(0+(ScreenWidth/5)*i, doLayout.frame.size.height-35*2, ScreenWidth/5, 35-1)];
            }else{
                [btn setFrame:CGRectMake(0+(ScreenWidth/(btnShowArr.count-5))*(i-5), doLayout.frame.size.height-35, ScreenWidth/(btnShowArr.count-5), 35)];
            }
        }
        [doLayout addSubview:btn];
    }
}
- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)location
{
    [self startTimeOutListen];// 开始监听超时时间
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:location.latitude longitude:location.longitude];
    regeo.requireExtension = YES;
    
    [_search AMapReGoecodeSearch:regeo];
}

-(void)startTimeOutListen{
    //    if (HUD == nil) {
    //        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //        HUD.label.text = @"正在获取地址，请稍候……";
    //        HUD.animationType = MBProgressHUDAnimationZoomIn;
    //    }
    
    
    // 如果此修改造成未预知的问题，请解开上面的if判断，并按照标识区域将下列代码屏蔽，这是解决第20条的bug
    
    //////////////////////////////////////开始
    [HUD hideAnimated:YES];
    HUD = nil;
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.label.text = @"正在获取地址，请稍候……";
    HUD.animationType = MBProgressHUDAnimationZoomIn;
    //////////////////////////////////////结束
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10.f target:self selector:@selector(gCodeTimeOutHint) userInfo:nil repeats:NO];
    }
}
-(void)gCodeTimeOutHint{
    [HUD hideAnimated:YES];
    HUD = nil;
    [_search cancelAllRequests];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前网络不佳无法获取真实地址" message:@"是否不添加地址到新增的井中？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * sure = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 跳转详情页
        
        TYKDeviceInfoMationViewController * addPole = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListInsertRfid withMainModel:_wellMainModel withViewModel:_wellViewModel withDataDict:newWell withFileName:@"well"];
        isADD = YES;
        addPole.delegate = self;
        addPole.isOffline = NO;
        
        [self.navigationController pushViewController:addPole animated:YES];
    }];
    
    UIAlertAction * dont = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 重试与否？
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"是否重试？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * sure = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // 重试
            [self addWell:nil];
        }];
        
        UIAlertAction * dont = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:sure];
        [alert addAction:dont];
        
        Present(self, alert);
        
    }];
    
    [alert addAction:sure];
    [alert addAction:dont];
    
    Present(self, alert);
    
    
    [self.timer invalidate];
    self.timer = nil;
}
//获取当前位置按钮点击触发事件
-(IBAction)nowLocation:(CusButton *)sender
{
    isFirst = NO;
    isLocationSelf = NO;
    icm.hidden = YES;
    isSetLevel = YES;
    //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
    _mapView.userTrackingMode=MAUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;//显示定位图层
}
//手动定位按钮点击触发事件
-(IBAction)selfLocation:(CusButton *)sender
{
    isLocationSelf = YES;
    //停止定位监听
    _mapView.showsUserLocation = NO;
    icm.hidden = NO;
}
//附近井按钮点击触发事件
-(IBAction)nearWell:(CusButton *)sender
{
    
    NSString *lonStr;
    NSString *latStr;
    if (isLocationSelf) {
        //手动定位下
        lonStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
        latStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
    }else{
        lonStr = [NSString stringWithFormat:@"%f",lon];
        latStr = [NSString stringWithFormat:@"%f",lat];
    }
    if ([lonStr isEqualToString:@"0.000000"]||[latStr isEqualToString:@"0.000000"]) {
  
        [YuanHUD HUDFullText:@"请先进行位置获取操作"];
        return;
    }
    
    NSMutableDictionary * param = NSMutableDictionary.dictionary;
    param[@"needFace"] = @1;
    param[@"isAll"] = @1;
    param[kResLogicName] = @"well";
    param[@"lon"] = lonStr;
    param[@"lat"] = latStr;
    
//    NSString *requestStr = [NSString stringWithFormat:@"{\"needFace\":\"1\",\"isAll\":\"1\",\"resLogicName\":\"well\",\"lon\":\"%@\",\"lat\":\"%@\"}",lonStr,latStr];
    [self getNearWellData:param.json];
}
//添加井按钮点击触发事件
-(IBAction)addWell:(CusButton *)sender
{
    NSString * latStr, * lonStr;
    /**
     *
     */
    

    
    // MARK: 袁全 修改
    lonStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
    latStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
    
    
    if ([lonStr isEqualToString:@"0.000000"]||[latStr isEqualToString:@"0.000000"]) {

        [YuanHUD HUDFullText:@"请先进行位置获取操作"];

        return;
    }
    newWell = [NSMutableDictionary dictionary];

    
    
    [newWell setValue:_pipe[@"GID"] forKey:@"pipe_Id"];
    
    [newWell setValue:_pipe[@"GID"] forKey:@"pipe_Id"];
    [newWell setValue:_pipe[@"pipeName"] forKey:@"pipe"];
    // 所属局站 // 局站idad
    [newWell setValue:_pipe[@"areaname"] forKey:@"areaname"];
    [newWell setValue:_pipe[@"areaname_Id"] forKey:@"areaname_Id"];
    // 经纬度
    [newWell setValue:latStr forKey:@"lat"];
    [newWell setValue:lonStr forKey:@"lon"];
    
    // 2019年11月11日 新增：跟随管道信息。
    if (self.pipe[@"chanquanxz"] != nil){
        newWell[@"chanquanxz"] = self.pipe[@"chanquanxz"];
    }
    
    if (self.pipe[@"prorertyBelong"] != nil){
        newWell[@"prorertyBelong"] = self.pipe[@"prorertyBelong"];
    }
    
    
    
    if (_pipe[@"retion"]!=nil) {
        [newWell setValue:_pipe[@"retion"] forKey:@"retion"];
    }
    
    newWell[@"wellSubName"] = [NSString stringWithFormat:@"%@#",_pipe[@"pipeName"]];
    newWell[@"wellCode"] = [NSString stringWithFormat:@"%@#",_pipe[@"pipeName"]];
    
    /* 2017年03月02日 新增，工单内添加资源，需要带taskId */
    
    
    // 2021年 1月20 新增 自动
    NSNumber * code = [[NSUserDefaults standardUserDefaults] valueForKey:@"yuan_IsAutoAdd"];
    NSInteger yuan_IsAutoAdd = code.integerValue;
    
    // 手动 yuan_IsAutoAdd == 2
    if (yuan_IsAutoAdd == 2) {
        
        if (_isAutoSetAddr) {
            [self searchReGeocodeWithCoordinate:(CLLocationCoordinate2D){[latStr doubleValue],[lonStr doubleValue]}];
        }
        else{
            TYKDeviceInfoMationViewController * well = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListInsertRfid withMainModel:_wellMainModel withViewModel:_wellViewModel withDataDict:newWell withFileName:@"well"];
            well.delegate = self;
            well.isOffline = NO;
            well.isSubDevice = well.isOffline;
            isADD = YES;
            [self.navigationController pushViewController:well animated:YES];
        }
    }
    // 自动
    else {
        [self autoAdd];
    }
        
   
    
    
}


#pragma mark - 自动添加电杆 ---
- (void) autoAdd {
    
    _isYuanAutoAdd = YES;
    
    newWell[@"wellSubName"] = self.pipe[@"pipeName"];
    newWell[@"wellCode"] = self.pipe[@"pipeName"];
    
    
    
    NSString * latStr = nil;
    NSString * lonStr = nil;
    
    lonStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
    latStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
    
    
    
    // 如果没有数据 暂时走手动
    if (wellLocationArray.count == 0 ) {
        _isYuanAutoAdd = NO;
        [self searchReGeocodeWithCoordinate:(CLLocationCoordinate2D){[latStr doubleValue],[lonStr doubleValue]}];
        return;
    }
    else {
        [self searchReGeocodeWithCoordinate:(CLLocationCoordinate2D){[latStr doubleValue],[lonStr doubleValue]}];
    }
    
    NSDictionary * lastDict = wellLocationArray.lastObject;
    
    // newWell
    
    
    
    NSInteger large = 0;
    
    for (NSDictionary * dict in wellLocationArray) {

        NSString * wellCode = dict[@"wellSubName"];
        
        NSArray * codeArr = [wellCode componentsSeparatedByString:@"#"];
        
        NSString * newName = codeArr.lastObject;
        
        if (!newName) {
            continue;
        }
        
        
        if (newName.integerValue > large) {
            // 记得 +1
            large = newName.integerValue;
        }
        
    }
    // 记得 +1
    large++;
    
    if (large == 1) {
        newWell[@"wellCode"] = [NSString stringWithFormat:@"%@#01",newWell[@"wellCode"]];
        newWell[@"wellSubName"] = [NSString stringWithFormat:@"%@#01",newWell[@"wellSubName"]];
    }
    else {
        newWell[@"wellCode"] = [NSString stringWithFormat:@"%@#%ld",newWell[@"wellCode"],large];
        newWell[@"wellSubName"] = [NSString stringWithFormat:@"%@#%ld",newWell[@"wellSubName"],large];
    }
    
    
    for (NSString * key in lastDict.allKeys) {
        
        if (![newWell.allKeys containsObject:key] &&
            ![key isEqualToString:@"GID"] &&
            ![key isEqualToString:@"rfid"]) {
            
            newWell[key] = lastDict[key];
        }
    }
    
    // 走保存接口
//    [10]    (null)    @"GID" : @"019005080100000011628804"
//    [1]    (null)    @"pipe_Id" : @"190005000100000011121098"    
    [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Insert
                             dict:newWell
                          succeed:^(id data) {
            
        NSArray * arr = data;
        
        if (arr.count > 0) {
            
            isADD = YES;
            
            NSDictionary * dict = arr.firstObject;
            [self newWellWithDict:dict];
        }
        else {
            [[Yuan_HUD shareInstance] HUDFullText:@"自动添加电杆失败"];
        }
    }];
}







//关联管道段按钮点击触发事件
-(IBAction)guanlian:(CusButton *)sender
{
    isGuanlian = YES;
    if (icm!=nil &&isLocationSelf == YES) {
        [icm setHidden:YES];
    }
    [self addOverlayView];
    [self addLineView];
    [guanlianView setHidden:NO];
    pipeSegInfoList = [[NSMutableArray alloc] init];
}
//关联管道段保存按钮点击触发事件
-(IBAction)saveGuanlian:(CusButton *)sender
{

    [self pipesegSet];
    
    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
    for (int i = 0; i<wellLocationArray.count; i++) {
        if (wellLocationArray[i][@"doType"]!=nil) {
            [wellLocationArray[i] removeObjectForKey:@"doType"];
        }
    }
    
    
    //去掉重名管道段
    for (int i = 0; i<_pipeSegmentArray.count; i++) {
        NSDictionary *pipeSegment = _pipeSegmentArray[i];
        for (int j = 0; j<pipeSegInfoList.count; j++) {
            NSDictionary *temp = pipeSegInfoList[j];
            if ([[pipeSegment objectForKey:@"pipeSegName"] isEqualToString:[temp objectForKey:@"pipeSegName"]]) {
                [pipeSegInfoList removeObjectAtIndex:j];
                j--;
            }
        }
    }
    
    //去掉可能会出现的只有起始没有终止资源的情况(最后一个资源)
    if (pipeSegInfoList.count>0) {
        NSDictionary *lastPipeSegDic = pipeSegInfoList[pipeSegInfoList.count-1];
        if ([lastPipeSegDic objectForKey:@"startDevice_Id"]!=nil &&[lastPipeSegDic objectForKey:@"endDevice_Id"]==nil ) {
            [pipeSegInfoList removeObjectAtIndex:pipeSegInfoList.count-1];
        }
    }
    NSLog(@"发送的列表:%@",pipeSegInfoList);
    
    [self addPipeSegDate];
}
//取消关联管道段按钮点击触发事件
-(IBAction) cancelGuanlian:(CusButton *)sender
{
    isUpdate = NO;
    isGuanlian = NO;
    if (icm!=nil &&isLocationSelf == YES) {
        [icm setHidden:NO];
    }
    [guanlianView setHidden:YES];
    startText.text = @"";
    endText.text = @"";
    pipeSegInfoList = nil;
    
    
    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
    for (int i = 0; i<wellLocationArray.count; i++) {
        if (wellLocationArray[i][@"doType"]!=nil) {
            [wellLocationArray[i] removeObjectForKey:@"doType"];
        }
    }
    
    [self addOverlayView];
    [self addLineView];
}
//获取资源按钮点击触发事件
-(IBAction)getResource:(CusButton *)sender
{
    NSString * latStr, * lonStr;
    if (isLocationSelf) {
        //手动定位下
        lonStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
        latStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
    }else{
        lonStr = [NSString stringWithFormat:@"%f",lon];
        latStr = [NSString stringWithFormat:@"%f",lat];
    }
    if ([lonStr isEqualToString:@"0.000000"]||[latStr isEqualToString:@"0.000000"]) {

        [YuanHUD HUDFullText:@"请先进行位置获取操作"];
        return;
    }
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"lon\":\"%@\",\"lat\":\"%@\",\"radius\":\"%d\",\"resLogicName\":\"well\",\"id\":%@}",lonStr,latStr,radius,[self.pipe objectForKey:@"GID"]]};
    [self getWellAndSegmentDate:param :NO];
}
//地图定位显示
-(void)mapLocationInit{
    CLLocationCoordinate2D coor;
    
    if ([wellLocationArray count]>0) {
        
        coor.latitude = [[wellLocationArray[0] objectForKey:@"lat"] doubleValue];
        coor.longitude = [[wellLocationArray[0] objectForKey:@"lon"] doubleValue];
        
        [_mapView setZoomLevel:17 animated:NO];
    }else if([ledupLocationArray count]>0){
        coor.latitude = [[ledupLocationArray[0] objectForKey:@"lat"] doubleValue];
        coor.longitude = [[ledupLocationArray[0] objectForKey:@"lon"] doubleValue];
        
        [_mapView setZoomLevel:17 animated:NO];
    }else if([occLocationArray count]>0){
        coor.latitude = [[occLocationArray[0] objectForKey:@"lat"] doubleValue];
        coor.longitude = [[occLocationArray[0] objectForKey:@"lon"] doubleValue];
        
        [_mapView setZoomLevel:17 animated:NO];
    }
}
//初始化地图显示位置
- (void)initOverlay {
    if ([wellLocationArray count]>0) {
        //当列表不为空且至少有一个资源有坐标时
        latIn = [wellLocationArray[0] objectForKey:@"lat"];
        lonIn = [wellLocationArray[0] objectForKey:@"lon"];
        
        
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
        
        selectWellIndex = 1000000;
        selectLedUpIndex = 1000000;
        selectOCCIndex = 1000000;
        //设置地图类型
        _mapView.mapType=MAMapTypeStandard;
        
    }else{
        //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
        _mapView.userTrackingMode=MAUserTrackingModeFollow;
        _mapView.showsUserLocation = YES;//显示定位图层
    
        [YuanHUD HUDFullText:@"没有井记录，无法获取井经纬度"];

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
    wellAnnotationIndex = 0;
    ledUpAnnotationIndex = 0;
    occAnnotationIndex = 0;
    //加载井资源信息
    for (int i = 0; i<[wellLocationArray count]; i++) {
        wellAnnotationIndex = i;
        pointAnnotation = [[CusMAPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        
        coor.latitude = [[wellLocationArray[i] objectForKey:@"lat"] doubleValue];
        coor.longitude = [[wellLocationArray[i] objectForKey:@"lon"] doubleValue];
        pointAnnotation.tag = 10000+i;
        
        pointAnnotation.coordinate = coor;
        pointAnnotation.subtitle = [NSString stringWithFormat:@"%d",10000+i];
        
        NSLog(@"wellAnnotationIndex:%ld",(long)wellAnnotationIndex);
        [_mapView addAnnotation:pointAnnotation];
        
    }
    //加载引上点资源信息
    for (int i = 0; i<[ledupLocationArray count]; i++) {
        ledUpAnnotationIndex = i;
        pointAnnotation = [[CusMAPointAnnotation alloc] init];
        CLLocationCoordinate2D coor;
        
        coor.latitude = [[ledupLocationArray[i] objectForKey:@"lat"] doubleValue];
        coor.longitude = [[ledupLocationArray[i] objectForKey:@"lon"] doubleValue];
        pointAnnotation.tag = 20000+i;
        
        pointAnnotation.coordinate = coor;
        pointAnnotation.subtitle = [NSString stringWithFormat:@"%d",20000+i];
        
        [_mapView addAnnotation:pointAnnotation];
    }
    //加载OCC资源信息
    for (int i = 0; i<[occLocationArray count]; i++) {
        occAnnotationIndex = i;
        pointAnnotation = [[CusMAPointAnnotation alloc] init];
        CLLocationCoordinate2D coor;
        
        coor.latitude = [[occLocationArray[i] objectForKey:@"lat"] doubleValue];
        coor.longitude = [[occLocationArray[i] objectForKey:@"lon"] doubleValue];
        pointAnnotation.tag = 30000+i;
        
        pointAnnotation.coordinate = coor;
        pointAnnotation.subtitle = [NSString stringWithFormat:@"%d",30000+i];
        
        [_mapView addAnnotation:pointAnnotation];
    }
}
//添加资源画线
-(void)addLineView
{
    [MAPolylineArray removeAllObjects];
    [pipeSegTypeArray removeAllObjects];
    //加载管道段资源信息
    for (int i = 0; i<_pipeSegmentArray.count; i++) {
        NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        NSMutableDictionary *seg = _pipeSegmentArray[i];
        for (int j = 0; j<wellLocationArray.count; j++) {
            NSMutableDictionary *well = wellLocationArray[j];
            if ([[NSString stringWithFormat:@"%@",[well objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"startDevice_Id"]]]) {
                [p1 setObject:[well objectForKey:@"lat"] forKey:@"lat"];
                [p1 setObject:[well objectForKey:@"lon"] forKey:@"lon"];
                [points addObject:p1];
            }
            if ([[NSString stringWithFormat:@"%@",[well objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"endDevice_Id"]]]) {
                [p2 setObject:[well objectForKey:@"lat"] forKey:@"lat"];
                [p2 setObject:[well objectForKey:@"lon"] forKey:@"lon"];
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
                //根据管道段段不同类型，区别不同颜色
                if ([seg objectForKey:@"startFaceLocation"]==nil ||[seg objectForKey:@"endFaceLocation"] ==nil) {
                    [pipeSegTypeArray addObject:[NSNumber numberWithInt:0]];//导入数据，没有面直接关联了管道段
                }else{
                    if ([seg objectForKey:@"pipeSegmentType"]!=nil &&[[seg objectForKey:@"pipeSegmentType"] isEqualToString:@"5"]) {
                        [pipeSegTypeArray addObject:[NSNumber numberWithInt:1]];//通道
                    }else{
                        if ([seg objectForKey:@"unionBuild"]!=nil &&![[seg objectForKey:@"unionBuild"] isEqualToString:@"0"]) {
                            [pipeSegTypeArray addObject:[NSNumber numberWithInt:2]];//联建管道
                        }else{
                            [pipeSegTypeArray addObject:[NSNumber numberWithInt:3]];//含有面的默认管道
                        }
                    }
                }
                
                
                [_mapView addOverlay:polyline];
                break;
            }
        }
    }
    //加载井和引上点连线
    for (int i = 0; i<ledupLocationArray.count; i++) {
        NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        NSMutableDictionary *ledUp = ledupLocationArray[i];
        for (int j = 0; j<wellLocationArray.count; j++) {
            NSMutableDictionary *well = wellLocationArray[j];
            if ([ledUp objectForKey:@"well_Id"]!=nil &&[[ledUp objectForKey:@"well_Id"] isEqualToString:[well objectForKey:@"GID"]]) {
                if ([well objectForKey:@"lat"]!=nil &&[well objectForKey:@"lon"]!=nil) {
                    [p1 setObject:[well objectForKey:@"lat"] forKey:@"lat"];
                    [p1 setObject:[well objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p1];
                }
            }
            if ([ledUp objectForKey:@"lat"]!=nil&&[ledUp objectForKey:@"lon"]!=nil) {
                [p2 setObject:[ledUp objectForKey:@"lat"] forKey:@"lat"];
                [p2 setObject:[ledUp objectForKey:@"lon"] forKey:@"lon"];
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
                //根据折线段不同类型，区别不同颜色
                [pipeSegTypeArray addObject:[NSNumber numberWithInt:4]];//引上点和井连线
                
                [_mapView addOverlay:polyline];
                break;
            }
        }
    }
    //加载井和OCC连线
    for (int i = 0; i<occLocationArray.count; i++) {
        NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        NSMutableDictionary *occ = occLocationArray[i];
        for (int j = 0; j<wellLocationArray.count; j++) {
            NSMutableDictionary *well = wellLocationArray[j];
            if ([occ objectForKey:@"well_Id"]!=nil &&[[occ objectForKey:@"well_Id"] isEqualToString:[well objectForKey:@"GID"]]) {
                if ([well objectForKey:@"lat"]!=nil &&[well objectForKey:@"lon"]!=nil) {
                    [p1 setObject:[well objectForKey:@"lat"] forKey:@"lat"];
                    [p1 setObject:[well objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p1];
                }
            }
            if ([occ objectForKey:@"lat"]!=nil&&[occ objectForKey:@"lon"]!=nil) {
                [p2 setObject:[occ objectForKey:@"lat"] forKey:@"lat"];
                [p2 setObject:[occ objectForKey:@"lon"] forKey:@"lon"];
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
                //根据折线段不同类型，区别不同颜色
                [pipeSegTypeArray addObject:[NSNumber numberWithInt:4]];//引上点和井连线
                
                [_mapView addOverlay:polyline];
                break;
            }
        }
    }
}
//添加资源画线
-(void)addTempLineView
{
    for (int i = 0; i<pipeSegInfoList.count; i++) {
        NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        NSMutableDictionary *seg = pipeSegInfoList[i];
        for (int j = 0; j<wellLocationArray.count; j++) {
            NSMutableDictionary *well = wellLocationArray[j];
            if ([[NSString stringWithFormat:@"%@",[well objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"startDevice_Id"]]]) {
                [p1 setObject:[well objectForKey:@"lat"] forKey:@"lat"];
                [p1 setObject:[well objectForKey:@"lon"] forKey:@"lon"];
                [points addObject:p1];
            }
            if ([[NSString stringWithFormat:@"%@",[well objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"endDevice_Id"]]]) {
                [p2 setObject:[well objectForKey:@"lat"] forKey:@"lat"];
                [p2 setObject:[well objectForKey:@"lon"] forKey:@"lon"];
                [points addObject:p2];
            }
            if (p1!=nil && p2!=nil && [[p1 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p1 objectForKey:@"lon"] doubleValue]&& [[p2 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p2 objectForKey:@"lon"] doubleValue]) {
                CLLocationCoordinate2D coors[2] = {0};
                coors[0].latitude = [[p1 objectForKey:@"lat"] doubleValue];
                coors[0].longitude = [[p1 objectForKey:@"lon"] doubleValue];
                coors[1].latitude = [[p2 objectForKey:@"lat"] doubleValue];
                coors[1].longitude = [[p2 objectForKey:@"lon"] doubleValue];
                
                
                NSLog(@"coors:%f,%f,%f,%f",coors[0].latitude,coors[0].longitude,coors[1].latitude,coors[1].longitude);
                CusMAPolyline *polyline = [CusMAPolyline polylineWithCoordinates:coors count:2];
                polyline.type = 1;//虚线
                [_mapView addOverlay:polyline];
                break;
            }
            
        }
    }
}
//关联井管道段选择立面事件
-(void)choowslm{
    if ([wellselectDic objectForKey:@"faces"] == nil) {
        //新建井，无面信息，需要从中心获取
        [self getFaceData:[wellselectDic objectForKey:@"GID"]];
    }else{
        //改为由井带回的面数据直接获得（2016.11.09支持批量关联后）
        NSArray *arr = [wellselectDic objectForKey:@"faces"];
        _faceArray = [NSMutableArray arrayWithArray:arr];
        [self showWellFace];
    }
}
//显示井面信息
-(void)showWellFace{
    UIView *fullView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [fullView setBackgroundColor:[UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:0.5]];
    fullView.tag = 500000;
    [self.view addSubview:fullView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    tap.cancelsTouchesInView = NO;
    [fullView addGestureRecognizer:tap];
    
    UIView *faceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth/2, ScreenWidth/2)];
    [faceView setCenter:fullView.center];
    [faceView setBackgroundColor:[UIColor whiteColor]];
    faceView.tag = 600000;
    [fullView addSubview:faceView];
    
    UIButton *faceXiBeiBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, faceView.frame.size.width/3-2, faceView.frame.size.height/3-2)];
    [faceXiBeiBtn setTitle:@"西北" forState:UIControlStateNormal];
    [faceXiBeiBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [faceXiBeiBtn setBackgroundColor:[UIColor mainColor]];
    faceXiBeiBtn.tag = 500001;
    [faceXiBeiBtn addTarget:self action:@selector(faceSelect:) forControlEvents:UIControlEventTouchUpInside];
    [faceView addSubview:faceXiBeiBtn];
    
    UIButton *faceBeiBtn = [[UIButton alloc] initWithFrame:CGRectMake(faceView.frame.size.width/3+1, 0, faceView.frame.size.width/3-2, faceView.frame.size.height/3-2)];
    [faceBeiBtn setTitle:@"北" forState:UIControlStateNormal];
    [faceBeiBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [faceBeiBtn setBackgroundColor:[UIColor mainColor]];
    faceBeiBtn.tag = 500002;
    [faceBeiBtn addTarget:self action:@selector(faceSelect:) forControlEvents:UIControlEventTouchUpInside];
    [faceView addSubview:faceBeiBtn];
    
    UIButton *faceDongBeiBtn = [[UIButton alloc] initWithFrame:CGRectMake(faceView.frame.size.width/3*2+2, 0, faceView.frame.size.width/3-2, faceView.frame.size.height/3-2)];
    [faceDongBeiBtn setTitle:@"东北" forState:UIControlStateNormal];
    [faceDongBeiBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [faceDongBeiBtn setBackgroundColor:[UIColor mainColor]];
    faceDongBeiBtn.tag = 500003;
    [faceDongBeiBtn addTarget:self action:@selector(faceSelect:) forControlEvents:UIControlEventTouchUpInside];
    [faceView addSubview:faceDongBeiBtn];
    
    UIButton *faceXiBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, faceView.frame.size.height/3+1, faceView.frame.size.width/3-2, faceView.frame.size.height/3-2)];
    [faceXiBtn setTitle:@"西" forState:UIControlStateNormal];
    [faceXiBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [faceXiBtn setBackgroundColor:[UIColor mainColor]];
    faceXiBtn.tag = 500004;
    [faceXiBtn addTarget:self action:@selector(faceSelect:) forControlEvents:UIControlEventTouchUpInside];
    [faceView addSubview:faceXiBtn];
    
    UIImageView *faceJiantouImg = [[UIImageView alloc] initWithFrame:CGRectMake(faceView.frame.size.width/3+1, faceView.frame.size.height/3+1, faceView.frame.size.width/3-2, faceView.frame.size.height/3-2)];
    faceJiantouImg.image = [UIImage Inc_imageNamed:@"xiaojiantou"];
    [faceView addSubview:faceJiantouImg];
    
    UIButton *faceDongBtn = [[UIButton alloc] initWithFrame:CGRectMake(faceView.frame.size.width/3*2+2, faceView.frame.size.height/3+1, faceView.frame.size.width/3-2, faceView.frame.size.height/3-2)];
    [faceDongBtn setTitle:@"东" forState:UIControlStateNormal];
    [faceDongBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [faceDongBtn setBackgroundColor:[UIColor mainColor]];
    faceDongBtn.tag = 500005;
    [faceDongBtn addTarget:self action:@selector(faceSelect:) forControlEvents:UIControlEventTouchUpInside];
    [faceView addSubview:faceDongBtn];
    
    UIButton *faceXiNanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, faceView.frame.size.height/3*2+2, faceView.frame.size.width/3-2, faceView.frame.size.height/3-2)];
    [faceXiNanBtn setTitle:@"西南" forState:UIControlStateNormal];
    [faceXiNanBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [faceXiNanBtn setBackgroundColor:[UIColor mainColor]];
    faceXiNanBtn.tag = 500006;
    [faceXiNanBtn addTarget:self action:@selector(faceSelect:) forControlEvents:UIControlEventTouchUpInside];
    [faceView addSubview:faceXiNanBtn];
    
    UIButton *faceNanBtn = [[UIButton alloc] initWithFrame:CGRectMake(faceView.frame.size.width/3+1, faceView.frame.size.height/3*2+2, faceView.frame.size.width/3-2, faceView.frame.size.height/3-2)];
    [faceNanBtn setTitle:@"南" forState:UIControlStateNormal];
    [faceNanBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [faceNanBtn setBackgroundColor:[UIColor mainColor]];
    faceNanBtn.tag = 500007;
    [faceNanBtn addTarget:self action:@selector(faceSelect:) forControlEvents:UIControlEventTouchUpInside];
    [faceView addSubview:faceNanBtn];
    
    UIButton *faceDongNanBtn = [[UIButton alloc] initWithFrame:CGRectMake(faceView.frame.size.width/3*2+2, faceView.frame.size.height/3*2+2, faceView.frame.size.width/3-2, faceView.frame.size.height/3-2)];
    [faceDongNanBtn setTitle:@"东南" forState:UIControlStateNormal];
    [faceDongNanBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [faceDongNanBtn setBackgroundColor:[UIColor mainColor]];
    faceDongNanBtn.tag = 500008;
    [faceDongNanBtn addTarget:self action:@selector(faceSelect:) forControlEvents:UIControlEventTouchUpInside];
    [faceView addSubview:faceDongNanBtn];
    
    wellFaceSelectArray = @[faceXiBeiBtn,faceBeiBtn,faceDongBeiBtn,faceXiBtn,faceDongBtn,faceXiNanBtn,faceNanBtn,faceDongNanBtn];
    if (faceMuDic == nil) {
        faceMuDic = [[NSMutableDictionary alloc] init];
    }else{
        [faceMuDic removeAllObjects];
    }
    for (int i = 0; i <[_faceArray count]; i++) {
        NSDictionary *face = _faceArray[i];
        [faceMuDic setObject:face forKey:[face objectForKey:@"locationNo"]];
    }
    for (int i = 0; i<[wellFaceSelectArray count]; i++) {
        NSDictionary *face = [faceMuDic objectForKey:((CusButton *)(wellFaceSelectArray[i])).titleLabel.text];
        NSLog(@"face:%@",face);
        if (face == nil) {

            [YuanHUD HUDFullText:@"获取面信息失败"];
            return;
        }
        //设置面可用点击状态
        if ([[face objectForKey:@"isVisible"] intValue] == 1) {
            [((CusButton *)(wellFaceSelectArray[i])) setBackgroundColor:[UIColor mainColor]];
            [((CusButton *)(wellFaceSelectArray[i])) setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            [((CusButton *)(wellFaceSelectArray[i])) setBackgroundColor:[[UIColor mainColor] setAlpha:.5f]];
            [((CusButton *)(wellFaceSelectArray[i])) setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        //设置面关联管道段显示
        if ([face objectForKey:@"pipeSegment_Id"]!=nil && ![[face objectForKey:@"pipeSegment_Id"] isEqualToString:@""]) {
            [((CusButton *)(wellFaceSelectArray[i])) setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        }
        //设置面虚拟关联管道段显示
        for (int j = 0; j<pipeSegInfoList.count; j++) {
            NSDictionary *pipeSeg = pipeSegInfoList[j];
            if ([[face objectForKey:@"well_Id"] isEqualToString:[wellselectDic objectForKey:@"GID"]] &&([face[@"faceId"] isEqualToString:pipeSeg[@"startFaceLocation_Id"]]||[face[@"faceId"] isEqualToString:pipeSeg[@"endFaceLocation_Id"]])) {
                if ([((CusButton *)(wellFaceSelectArray[i])).titleLabel.text isEqualToString:face[@"locationNo"]]) {
                    [((CusButton *)(wellFaceSelectArray[i])) setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
                }
            }
        }
    }
}
//关联管道段具体判断
-(void)pipeSegGuanlian:(NSDictionary *)faceTemp{
    NSMutableDictionary *pipeSegInfo;//当前待关联的管道段
    if (pipeSegInfoList.count>0) {
        NSDictionary *lastPipeSeg = pipeSegInfoList[pipeSegInfoList.count-1];
        if ([lastPipeSeg objectForKey:@"startDevice_Id"]!=nil &&([lastPipeSeg objectForKey:@"endDevice_Id"]==nil)) {
            //上一个管道段有起始但是无终止
            pipeSegInfo = [[NSMutableDictionary alloc] initWithDictionary:pipeSegInfoList[pipeSegInfoList.count-1]];
            endText.text = [NSString stringWithFormat:@"#%@-%@",[[wellselectDic objectForKey:@"wellSubName"] componentsSeparatedByString:@"#"].count>0?[[wellselectDic objectForKey:@"wellSubName"] componentsSeparatedByString:@"#"][1]:@"",[faceTemp objectForKey:@"locationNo"]];
            [pipeSegInfo setObject:[wellselectDic objectForKey:@"GID"] forKey:@"endDevice_Id"];
            [pipeSegInfo setObject:[wellselectDic objectForKey:@"wellSubName"] forKey:@"endDevice"];
            [pipeSegInfo setObject:[NSNumber numberWithInt:1] forKey:@"endDevice_Type"];
            [pipeSegInfo setObject:[NSString stringWithFormat:@"%@",[faceTemp objectForKey:@"faceId"]] forKey:@"endFaceLocation_Id"];
            NSString *pipeSegName = [NSString stringWithFormat:@"%@%@）",[pipeSegInfo objectForKey:@"pipeSegName"],[wellselectDic objectForKey:@"wellSubName"]];
            [pipeSegInfo setObject:pipeSegName forKey:@"pipeSegName"];
            [pipeSegInfo setObject:[wellselectDic objectForKey:@"lat"] forKey:@"zzlat"];
            [pipeSegInfo setObject:[wellselectDic objectForKey:@"lon"] forKey:@"zzlon"];
            if ([wellselectDic objectForKey:@"pipe_Id"]!=nil) {
                [pipeSegInfo setObject:[wellselectDic objectForKey:@"pipe_Id"] forKey:@"zzpipe_Id"];
            }
            
            pipeSegInfoList[pipeSegInfoList.count-1] = pipeSegInfo;
        }else if ([lastPipeSeg objectForKey:@"startDevice_Id"]!=nil &&([lastPipeSeg objectForKey:@"endDevice_Id"]!=nil)){
            //上一个管道段既有起始也有终止，此次点击的资源为起始
            endText.text = @"";
            startText.text = [NSString stringWithFormat:@"#%@-%@",[[wellselectDic objectForKey:@"wellSubName"] componentsSeparatedByString:@"#"].count>0?[[wellselectDic objectForKey:@"wellSubName"] componentsSeparatedByString:@"#"][1]:@"",[faceTemp objectForKey:@"locationNo"]];
            
            pipeSegInfo = [[NSMutableDictionary alloc] init];
            [pipeSegInfo setObject:[wellselectDic objectForKey:@"GID"] forKey:@"startDevice_Id"];
            [pipeSegInfo setObject:[wellselectDic objectForKey:@"wellSubName"] forKey:@"startDevice"];
            [pipeSegInfo setObject:[NSNumber numberWithInt:1] forKey:@"startDevice_Type"];
            [pipeSegInfo setObject:[NSString stringWithFormat:@"%@",[faceTemp objectForKey:@"faceId"] ]forKey:@"startFaceLocation_Id"];
            NSString *pipeSegName = [NSString stringWithFormat:@"%@（%@_",[self.pipe objectForKey:@"pipeName"],[wellselectDic objectForKey:@"wellSubName"]];
            [pipeSegInfo setObject:pipeSegName forKey:@"pipeSegName"];
            
            [pipeSegInfo setObject:[wellselectDic objectForKey:@"lat"] forKey:@"qslat"];
            [pipeSegInfo setObject:[wellselectDic objectForKey:@"lon"] forKey:@"qslon"];
            if ([wellselectDic objectForKey:@"pipe_Id"]!=nil) {
                [pipeSegInfo setObject:[wellselectDic objectForKey:@"pipe_Id"] forKey:@"qspipe_Id"];
            }
            [pipeSegInfoList addObject:pipeSegInfo];
        }
    }else{
        //进行关联管道段的首个资源
        startText.text = [NSString stringWithFormat:@"#%@-%@",[[wellselectDic objectForKey:@"wellSubName"] componentsSeparatedByString:@"#"].count>0?[[wellselectDic objectForKey:@"wellSubName"] componentsSeparatedByString:@"#"][1]:@"",[faceTemp objectForKey:@"locationNo"]];
        
        pipeSegInfo = [[NSMutableDictionary alloc] init];
        [pipeSegInfo setObject:[wellselectDic objectForKey:@"GID"] forKey:@"startDevice_Id"];
        [pipeSegInfo setObject:[wellselectDic objectForKey:@"wellSubName"] forKey:@"startDevice"];
        [pipeSegInfo setObject:[NSNumber numberWithInt:1] forKey:@"startDevice_Type"];
        [pipeSegInfo setObject:[NSString stringWithFormat:@"%@",[faceTemp objectForKey:@"faceId"] ]forKey:@"startFaceLocation_Id"];
        NSString *pipeSegName = [NSString stringWithFormat:@"%@（%@_",[self.pipe objectForKey:@"pipeName"],[wellselectDic objectForKey:@"wellSubName"]];
        [pipeSegInfo setObject:pipeSegName forKey:@"pipeSegName"];
        
        [pipeSegInfo setObject:[wellselectDic objectForKey:@"lat"] forKey:@"qslat"];
        [pipeSegInfo setObject:[wellselectDic objectForKey:@"lon"] forKey:@"qslon"];
        if ([wellselectDic objectForKey:@"pipe_Id"]!=nil) {
            [pipeSegInfo setObject:[wellselectDic objectForKey:@"pipe_Id"] forKey:@"qspipe_Id"];
        }
        [pipeSegInfoList addObject:pipeSegInfo];
    }
    NSLog(@"pipeSegInfoList:%@",pipeSegInfoList);
}
-(IBAction)faceSelect:(UIButton *)sender{
    NSDictionary *face = [faceMuDic objectForKey:sender.titleLabel.text];
    if (face!=nil) {
        if ((face!=nil)&&([[face objectForKey:@"isVisible"] intValue] == 0)) {


            [YuanHUD HUDFullText:@"该面不可用"];
            return;
        }
    }
    NSDictionary *faceTemp = [faceMuDic objectForKey:sender.titleLabel.text];
    
    //当点了虚拟管道段列表里已经有了的井面后，再点不做响应
    if (pipeSegInfoList.count>0) {
        for (int i = 0; i<pipeSegInfoList.count; i++) {
            NSDictionary *pipeSeg = pipeSegInfoList[i];
            if ([[pipeSeg objectForKey:@"startDevice_Id"] isEqualToString:[wellselectDic objectForKey:@"GID"]] &&[faceTemp[@"faceId"] isEqualToString:pipeSeg[@"startFaceLocation_Id"]]) {
                NSLog(@"起始相同");
                [self showHUD:@"该面已经存在于管道段中"];
                return;
            }
            if ([[pipeSeg objectForKey:@"endDevice_Id"] isEqualToString:[wellselectDic objectForKey:@"GID"]]  &&[faceTemp[@"faceId"] isEqualToString:pipeSeg[@"endFaceLocation_Id"]]) {
                NSLog(@"终止相同");
                [self showHUD:@"该面已经存在于管道段中"];
                return;
            }
        }
    }
    
    BOOL isHave = NO;
    if ([faceTemp objectForKey:@"pipeSegment_Id"]!=nil && ![[faceTemp objectForKey:@"pipeSegment_Id"] isEqualToString:@""]) {
        isHave = YES;
    }
    if (isHave) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"该面已经关联过管道段，是否继续?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){}];
        [alertController addAction:cancelAction];
        UIAlertAction *commitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            isUpdate = YES;
            //面字体颜色变化，设置当前选中面为绿色
            for (UIButton *temp in wellFaceSelectArray) {
                NSDictionary *face = [faceMuDic objectForKey:temp.titleLabel.text];
                if (face!=nil) {
                    if ([[face objectForKey:@"isVisible"] intValue] == 1) {
                        [temp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }else{
                        [temp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }
                    if ([face objectForKey:@"pipeSegment_Id"]!=nil && ![[face objectForKey:@"pipeSegment_Id"] isEqualToString:@""]) {
                        [temp setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
                    }
                }
            }
            [sender setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            
            [self pipeSegGuanlian:faceTemp];
            
            UIView *fullView = [self.view viewWithTag:500000];
            UIView *faceView = [fullView viewWithTag:600000];
            for (UIButton *temp in wellFaceSelectArray) {
                [temp removeFromSuperview];
            }
            [faceView removeFromSuperview];
            [fullView removeFromSuperview];
            
            //变色标记
            for (CusMAPointAnnotation *cmpa in [_mapView annotations]) {
                MAAnnotationView * maav = [_mapView viewForAnnotation:cmpa];
                if ((maav.tag-100+10000) == wellViewSelectTag) {
                    maav.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
                    
                    //添加自定义属性，规避高德地图回调重加在问题
                    wellLocationArray[maav.tag-100] = [[NSMutableDictionary alloc] initWithDictionary:wellLocationArray[maav.tag-100]];
                    [wellLocationArray[maav.tag-100] setObject:@"isGuanlian" forKey:@"doType"];
                    
                }
            }
            //添加虚拟管道段标记
            [self addTempLineView];
            
        }];
        [alertController addAction:commitAction];
        Present(self, alertController);
    }else{
        //面字体颜色变化，设置当前选中面为绿色
        for (UIButton *temp in wellFaceSelectArray) {
            NSDictionary *face = [faceMuDic objectForKey:temp.titleLabel.text];
            if (face!=nil) {
                if ([[face objectForKey:@"isVisible"] intValue] == 1) {
                    [temp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }else{
                    [temp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                if ([face objectForKey:@"pipeSegment_Id"]!=nil && ![[face objectForKey:@"pipeSegment_Id"] isEqualToString:@""]) {
                    [temp setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
                }
            }
        }
        [sender setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        
        [self pipeSegGuanlian:faceTemp];
        
        UIView *fullView = [self.view viewWithTag:500000];
        UIView *faceView = [fullView viewWithTag:600000];
        for (UIButton *temp in wellFaceSelectArray) {
            [temp removeFromSuperview];
        }
        [faceView removeFromSuperview];
        [fullView removeFromSuperview];
        
        //变色标记
        for (CusMAPointAnnotation *cmpa in [_mapView annotations]) {
            MAAnnotationView * maav = [_mapView viewForAnnotation:cmpa];
            if ((maav.tag-100+10000) == wellViewSelectTag) {
                maav.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
                
                //添加自定义属性，规避高德地图回调重加在问题
                wellLocationArray[maav.tag-100] = [[NSMutableDictionary alloc] initWithDictionary:wellLocationArray[maav.tag-100]];
                [wellLocationArray[maav.tag-100] setObject:@"isGuanlian" forKey:@"doType"];
            }
        }
        //添加虚拟管道段标记
        [self addTempLineView];
    }
    
}
-(void)handleTapBehind:(UITapGestureRecognizer *)sender{
    UIView *fullView = [self.view viewWithTag:500000];
    CGPoint location = [sender locationInView:fullView];
    UIView *faceView = [fullView viewWithTag:600000];
    if(![faceView pointInside:[faceView convertPoint:location fromView:faceView.window] withEvent:nil]){
        for (UIButton *temp in wellFaceSelectArray) {
            [temp removeFromSuperview];
        }
        [faceView removeFromSuperview];
        [fullView removeFromSuperview];
    }
}
-(void)showHUD:(NSString *)labelText{

    [YuanHUD HUDFullText:labelText];
}
//关联管道段相关设置
-(void)pipesegSet
{
    for (int i = 0; i<pipeSegInfoList.count; i++) {
        NSMutableDictionary *newPipseg = pipeSegInfoList[i];
        
        [newPipseg setObject:[self.pipe objectForKey:@"GID"] forKey:@"pipe_Id"];
        [newPipseg setObject:[NSString stringWithFormat:@"%@",[self.pipe objectForKey:@"pipeName"]] forKey:@"pipe"];
        [newPipseg setObject:[NSNumber numberWithInt:1] forKey:@"pipeSegmentType"];
        if ([self.pipe objectForKey:@"domain"] !=nil) {
            [newPipseg setObject:[NSString stringWithFormat:@"%@",[self.pipe objectForKey:@"domain"]] forKey:@"domain"];
        }
        if ([self.pipe objectForKey:@"taskId"] !=nil) {
            [newPipseg setObject:[NSString stringWithFormat:@"%@",[self.pipe objectForKey:@"taskId"]] forKey:@"taskId"];
        }
        if ([self.pipe objectForKey:@"retion"] !=nil) {
            [newPipseg setObject:[NSString stringWithFormat:@"%@",[self.pipe objectForKey:@"retion"]] forKey:@"retion"];
        }

        
        
        [newPipseg setObject:@"pipeSegment" forKey:@"resLogicName"];
        
        // 业务状态oprStateId 维护状态 mntStateId
        newPipseg[@"oprStateId"] = self.pipe[@"oprStateId"];
        newPipseg[@"mntStateId"] = self.pipe[@"mntStateId"];
        
        double qslat = [newPipseg[@"qslat"] doubleValue];
        double qslon = [newPipseg[@"qslon"] doubleValue];
        double zzlat = [newPipseg[@"zzlat"] doubleValue];
        double zzlon = [newPipseg[@"zzlon"] doubleValue];
        
        //计算长度
        if (qslat!=0.000000 &&qslon!=0.000000 && zzlat!=0.000000 &&zzlon !=0.000000) {
            [newPipseg setObject:[NSNumber numberWithDouble:[self pipeSegmentLengthWithLat1:qslat Lon1:qslon Lat2:zzlat Lon2:zzlon]] forKey:@"pipeSegmentLength"];
        }
        if ([self.pipe objectForKey:@"areaname_Id"]!=nil) {
            [newPipseg setObject:[self.pipe objectForKey:@"areaname_Id"] forKey:@"areaname_Id"];
            [newPipseg setObject:[self.pipe objectForKey:@"areaname"] forKey:@"areaname"];
        }
        if (self.pipe[@"retion"]!=nil) {
            [newPipseg setObject:self.pipe[@"retion"] forKey:@"retion"];
        }
        
        //去掉手机端为了方便判断自己添加的一些属性字段
        [newPipseg removeObjectForKey:@"qslat"];
        [newPipseg removeObjectForKey:@"qslon"];
        [newPipseg removeObjectForKey:@"qspipe_Id"];
        [newPipseg removeObjectForKey:@"zzlat"];
        [newPipseg removeObjectForKey:@"zzlon"];
        [newPipseg removeObjectForKey:@"zzpipe_Id"];
        
        NSLog(@"newPipseg----,%@",newPipseg);
        pipeSegInfoList[i] = newPipseg;
    }
}
//计算管道段长度
-(double)pipeSegmentLengthWithLat1:(double)lat1 Lon1:(double)lon1 Lat2:(double)lat2 Lon2:(double)lon2
{
    //第一个坐标
    CLLocation *current=[[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
    //第二个坐标
    CLLocation *before=[[CLLocation alloc] initWithLatitude:lat2 longitude:lon2];
    // 计算距离
    CLLocationDistance meters=[current distanceFromLocation:before];
    return meters;
}
//获取当前管道下井的信息
-(void)getWellDate
{
    NSMutableArray * wellInPipe = [NSMutableArray array];
    NSNumber * mainDeviceId = [NSNumber numberWithInteger:[self.pipe[[NSString stringWithFormat:@"%@Id",self.pipe[@"resLogicName"]]] integerValue]];
    
    
    NSArray * well = [NSArray arrayWithArray:[[IWPCleanCache new] readSubDevicesFromMainDevice:self.pipe[@"resLogicName"] withMainDeviceId:mainDeviceId]];
    NSLog(@"%@",well);
    
    
    
    for (NSDictionary * dict in well) {
        if ([dict objectForKey:@"GID"]!=nil) {
            [wellInPipe addObject:dict];
        }
    }
    
    [Yuan_HUD.shareInstance HUDStartText:@"请稍后"];
    
    //调用查询接口
    //测试用：{"needLedUp":"1","resLogicName":"well","pipe_Id":982}
    
    NSDictionary *param = nil;
    
    
    param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"10000\",\"needLedUp\":\"1\",\"needFace\":\"1\",\"resLogicName\":\"well\",\"pipe_Id\":%@}",[self.pipe objectForKey:@"GID"]]};
    
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
    
    
    __weak typeof(self) wself = self;
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@rm!getWellInPipe.interface",baseURL] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {

            
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            
            
            for (NSDictionary * well in arr) {
                [self.wellArray addObject:well];
            }
            for (NSDictionary * well in wellInPipe) {
                [self.wellArray addObject:well];
            }
            if (wellArray!=nil && wellArray.count>0) {
                for (int i = 0; i<wellArray.count; i++) {
                    if (([wellArray[i] objectForKey:@"lon"]!=nil)&&(![[wellArray[i] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[wellArray[i] objectForKey:@"lon"] isEqualToString:@""])) {
                        [wellLocationArray addObject:wellArray[i]];
                    }
                }
            }
            [wself initOverlay];
            [self addOverlayView];
            [wself getPipeSegmentDate];
        }else{
            if (dic==nil ||([dic objectForKey:@"info"]==nil)) {

                [YuanHUD HUDFullText:@"操作失败，数据为空"];

            }else{

                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];

            }
            [wself initOverlay]; // 跳到当前城市
            [[Yuan_HUD shareInstance] HUDHide];

//            [self addOverlayView];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}
//获取当前管道下管道段信息
-(void)getPipeSegmentDate
{
    [Yuan_HUD.shareInstance HUDStartText:@"请稍后"];

    
    //调用查询接口
    //测试用：{"resLogicName":"pipeSegment","pipe_Id":982}
    
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"10000\",\"resLogicName\":\"pipeSegment\",\"pipe_Id\":%@}",[self.pipe objectForKey:@"GID"]]};
    
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
    
    
    NSLog(@"param %@",param);
    __weak typeof(self) wself = self;
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@rm!getCommonData.interface",baseURL] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {


        
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {

            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            
            _pipeSegmentArray = [NSMutableArray arrayWithArray:arr];
            //从管道段中提取不是该管道的井
            for (int i = 0; i<_pipeSegmentArray.count; i++) {
                if ([_pipeSegmentArray[i] objectForKey:@"wells"] != nil&&[[_pipeSegmentArray[i] objectForKey:@"wells"] count]>0) {
                    NSArray *wells = [NSArray arrayWithArray:[_pipeSegmentArray[i] objectForKey:@"wells"]];
                    for (int j = 0; j<wells.count; j++) {
                        BOOL isHave = NO;
                        for (int k = 0; k < wellArray.count; k++) {
                            if ([wells[j][@"GID"] isEqualToString:wellArray[k][@"GID"]]) {
                                isHave = YES;
                                break;
                            }
                        }
                        if (!isHave) {
                            [wellArray addObject:wells[j]];
                            if (([wells[j] objectForKey:@"lon"]!=nil)&&(![[wells[j] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[wells[j] objectForKey:@"lon"] isEqualToString:@""])) {
                                [wellLocationArray addObject:wells[j]];
                            }
                        }
                    }
                }
            }
            //提取引上点列表
            for (int i = 0; i<wellArray.count; i++) {
                if ([wellArray[i] objectForKey:@"ledUps"] != nil&&[[wellArray[i] objectForKey:@"ledUps"] count]>0) {
                    NSArray *ledUps = [NSArray arrayWithArray:[wellArray[i] objectForKey:@"ledUps"]];
                    for (int j = 0; j<ledUps.count; j++) {
                        if (([ledUps[j] objectForKey:@"lon"]!=nil)&&(![[ledUps[j] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[ledUps[j] objectForKey:@"lon"] isEqualToString:@""])) {
                            [ledupLocationArray addObject:ledUps[j]];
                        }
                    }
                }
            }
            //提取OCC列表
            for (int i = 0; i<wellArray.count; i++) {
                if ([wellArray[i] objectForKey:@"OCC_Equts"] != nil&&[[wellArray[i] objectForKey:@"OCC_Equts"] count]>0) {
                    NSArray *occs = [NSArray arrayWithArray:[wellArray[i] objectForKey:@"OCC_Equts"]];
                    for (int j = 0; j<occs.count; j++) {
                        if (([occs[j] objectForKey:@"lon"]!=nil)&&(![[occs[j] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[occs[j] objectForKey:@"lon"] isEqualToString:@""])) {
                            [occLocationArray addObject:occs[j]];
                        }
                    }
                }
            }
            if (isUpdate) {
                //TODO：
            }
            
            
            [self addLineView];
            if (!isAddPipeSeg) {
                [wself mapLocationInit];
            }
            
        }else{
            if (dic==nil ||([dic objectForKey:@"info"]==nil)) {

                [YuanHUD HUDFullText:@"操作失败，数据为空"];

            }else{

                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];

            }
            
        }
        
        [[Yuan_HUD shareInstance] HUDHide];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}
//获取当前管道下默认添加的前100个井的信息，方便杆路地图初始化定位
-(void)getWellAndSegmentDate:(NSDictionary *)param :(BOOL)isStart
{
    [Yuan_HUD.shareInstance HUDStartText:@"请稍后"];

    //调用查询接口
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
    
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@GIS!getResByPageAndLatLon.interface",baseURL] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
          
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            
            
            NSArray *wellArr = [[NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil] objectForKey:@"wellList"];
            
            [wellLocationArray removeAllObjects];
            [self.wellArray removeAllObjects];
            
            for (NSDictionary * well in wellArr) {
                [self.wellArray addObject:well];
            }
            NSLog(@"wellArray.count:%lu",(unsigned long)wellArray.count);
            for (int i = 0; i<wellArray.count; i++) {
                if (([wellArray[i] objectForKey:@"lon"]!=nil)&&(![[wellArray[i] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[wellArray[i] objectForKey:@"lon"] isEqualToString:@""])) {
                    [wellLocationArray addObject:wellArray[i]];
                    NSLog(@"add__________________");
                }
            }
            
            NSArray *pipeSegArr = [[NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil] objectForKey:@"pipeSegmentList"];
            _pipeSegmentArray = [NSMutableArray arrayWithArray:pipeSegArr];
            NSLog(@"_pipeSegmentArray:%lu",(unsigned long)_pipeSegmentArray.count);
            
            //从管道段中提取不是该管道的井
            for (int i = 0; i<_pipeSegmentArray.count; i++) {
                if ([_pipeSegmentArray[i] objectForKey:@"wells"] != nil&&[[_pipeSegmentArray[i] objectForKey:@"wells"] count]>0) {
                    NSArray *wells = [NSArray arrayWithArray:[_pipeSegmentArray[i] objectForKey:@"wells"]];
                    for (int j = 0; j<wells.count; j++) {
                        BOOL isHave = NO;
                        for (int k = 0; k < wellArray.count; k++) {
                            if ([wells[j][@"GID"] isEqualToString:wellArray[k][@"GID"]]) {
                                isHave = YES;
                                break;
                            }
                        }
                        if (!isHave) {
                            [wellArray addObject:wells[j]];
                            if (([wells[j] objectForKey:@"lon"]!=nil)&&(![[wells[j] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[wells[j] objectForKey:@"lon"] isEqualToString:@""])) {
                                [wellLocationArray addObject:wells[j]];
                            }
                        }
                    }
                }
            }
            //提取引上点列表
            [ledupLocationArray removeAllObjects];
            for (int i = 0; i<wellArray.count; i++) {
                if ([wellArray[i] objectForKey:@"ledUps"] != nil&&[[wellArray[i] objectForKey:@"ledUps"] count]>0) {
                    NSArray *ledUps = [NSArray arrayWithArray:[wellArray[i] objectForKey:@"ledUps"]];
                    for (int j = 0; j<ledUps.count; j++) {
                        if (([ledUps[j] objectForKey:@"lon"]!=nil)&&(![[ledUps[j] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[ledUps[j] objectForKey:@"lon"] isEqualToString:@""])) {
                            [ledupLocationArray addObject:ledUps[j]];
                        }
                    }
                }
            }
            //提取OCC列表
            [occLocationArray removeAllObjects];
            
            for (int i = 0; i<wellArray.count; i++) {
                if ([wellArray[i] objectForKey:@"OCC_Equts"] != nil&&[[wellArray[i] objectForKey:@"OCC_Equts"] count]>0) {
                    NSArray *occs = [NSArray arrayWithArray:[wellArray[i] objectForKey:@"OCC_Equts"]];
                    for (int j = 0; j<occs.count; j++) {
                        if (([occs[j] objectForKey:@"lon"]!=nil)&&(![[occs[j] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[occs[j] objectForKey:@"lon"] isEqualToString:@""])) {
                            [occLocationArray addObject:occs[j]];
                        }
                    }
                }
            }
            
            
            [YuanHUD HUDHideText:@"获取资源成功"];
            
            if (isStart) {
                [self initOverlay];
            }
            
            [self addOverlayView];
            [self addLineView];
            if (!isAddPipeSeg&&isStart) {
                [self mapLocationInit];
            }
        }else{
            if (dic==nil ||([dic objectForKey:@"info"]==nil)) {

                [YuanHUD HUDFullText:@"操作失败，数据为空"];

            }else{

                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];

            }
        }
        [[Yuan_HUD shareInstance] HUDHide];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
    NSLog(@"%@",wellArray);
    NSLog(@"%@",wellLocationArray);
}
//获取附近井线程
-(void)getNearWellData:(NSString *) jsonRequest
{
    [Yuan_HUD.shareInstance HUDStartText:@"请稍后"];

    //调用查询接口
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":jsonRequest};
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
            
            selectWellIndex = 1000000;
            NSMutableArray *nearWellArray = [NSMutableArray arrayWithArray:arr];
            for (NSDictionary *well in nearWellArray) {
                BOOL isHave = NO;
                for (NSDictionary *wTemp in wellArray) {
                    if ([[well objectForKey:@"GID"] isEqualToString:[wTemp objectForKey:@"GID"]]) {
                        isHave = YES;
                        break;
                    }
                }
                if (!isHave) {
                    [wellArray addObject:well];
                    if (([well objectForKey:@"lon"]!=nil)&&(![[well objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[well objectForKey:@"lon"] isEqualToString:@""])) {
                        [wellLocationArray addObject:well];
                    }
                }
            }
            [wself addOverlayView];
            [wself addLineView];
        }else{
            if (dic==nil ||([dic objectForKey:@"info"]==nil)) {

                [YuanHUD HUDFullText:@"操作失败，数据为空"];

            }else{

                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];

            }
            
        }
        
        [[Yuan_HUD shareInstance] HUDHide];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}
//获取面信息
-(void)getFaceData:(NSString *) GID{

    
    [Yuan_HUD.shareInstance HUDStartText:@"请稍后"];

    //调用查询接口
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"well_Id\":%@,\"resLogicName\":\"face\"}",GID]};
    NSLog(@"param %@",param);
    
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
    
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@%@",baseURL,@"data!getData.interface"] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        

        NSDictionary *dic = responseObject;
        if([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {

            
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            _faceArray = [NSMutableArray arrayWithArray:arr];
            [self showWellFace];
            
        }else{
            if (dic==nil ||([dic objectForKey:@"info"]==nil)) {

                [YuanHUD HUDFullText:@"操作失败，数据为空"];

            }else{

                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];

            }
            
        }
        
        [[Yuan_HUD shareInstance] HUDHide];

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}
//新建管道段线程
-(void)addPipeSegDate
{
    
    if (pipeSegInfoList.count == 0) {
        
        [YuanHUD HUDFullText:@"请至少关联一条管道段"];
        return;
    }
    
    //弹出进度框
    [Yuan_HUD.shareInstance HUDStartText:@"请稍后"];
    NSString * request = @"[";
    for (NSDictionary * tempInfo in pipeSegInfoList) {
//        request = [request stringByAppendingString:[NSString stringWithFormat:@"%@,",DictToString(dict)]];
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:tempInfo];
        
        // 2019年11月11日 新增：跟随管道信息。
        if (self.pipe[@"chanquanxz"] != nil){
            dict[@"chanquanxz"] = self.pipe[@"chanquanxz"];
        }
        
        if (self.pipe[@"prorertyBelong"] != nil){
            dict[@"prorertyBelong"] = self.pipe[@"prorertyBelong"];
        }
        
        // 2019年11月14日 新增：编号跟随名称
        // pipeSegmentCode  = pipeSegName
        
        dict[@"pipeSegmentCode"] = dict[@"pipeSegName"];
        
        request = [request stringByAppendingString:[NSString stringWithFormat:@"%@,",DictToString(dict)]];
        
        
    }
    request = [request substringWithRange:NSMakeRange(0, request.length - 1)];
    request = [request stringByAppendingString:@"]"];
    
    NSLog(@"%@",request);
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":request};
    NSLog(@"param %@",param);
    
    __weak typeof(self) wself = self;
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
    
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@%@",baseURL,@"rm!insertCommonData.interface"] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        

        NSDictionary *dic = responseObject;
        if([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {

            
            [YuanHUD HUDHideText:@"关联操作成功"];

            isAddPipeSeg = YES;
            //更新井面信息
            //1.将拿到的管道段起始和终止面分别遍历,找到和已经存在面相同的ID；
//            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
//            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            
//            NSMutableArray *tempPipeArr = [NSMutableArray arrayWithArray:arr];
            NSMutableSet *tempPipeHaveFaceId = [[NSMutableSet alloc] init];
//            for (NSDictionary *tempPipe in tempPipeArr) {
//                [tempPipeHaveFaceId addObject:tempPipe[@"startFaceLocation_Id"]];
//                [tempPipeHaveFaceId addObject:tempPipe[@"endFaceLocation_Id"]];
//            }
            //2.将对应的面的所属管道段ID赋值进入
            //faceArray遍历，有所属管道段的把对应的ID(pipeSegment_Id)附一个临时值@“temp”
            NSMutableArray *totalFaceArr = [[NSMutableArray alloc] init];
            for (NSDictionary *well in wellArray) {
                for (NSDictionary *face in well[@"faces"]) {
                    [totalFaceArr addObject:face];
                }
                
            }
            for (int i = 0;i< totalFaceArr.count;i++) {
                BOOL isHave = NO;
                NSMutableDictionary *faceTemp =[[NSMutableDictionary alloc] initWithDictionary: totalFaceArr[i]];
                for (NSString *faceId in tempPipeHaveFaceId) {
                    if ([faceTemp[@"faceId"] isEqualToString:faceId]) {
                        isHave = YES;
                        break;
                    }
                }
                if (isHave) {
                    [faceTemp setObject:@"temp" forKey:@"pipeSegment_Id"];
                    totalFaceArr[i] = faceTemp;
                }
            }
            //3.变更井的面信息
            for (NSDictionary *faceTemp in totalFaceArr) {
                if ([faceTemp[@"pipeSegment_Id"] isEqualToString:@"temp"]) {
                    for (int j = 0;j<wellArray.count;j++) {
                        NSDictionary *temp = wellArray[j];
                        if ([temp[@"GID"] isEqualToString:faceTemp[@"well_Id"]]) {
                            NSArray *tempFaces = temp[@"faces"];
                            for (int i = 0; i<tempFaces.count; i++) {
                                NSDictionary *tempFace = tempFaces[i];
                                if ([faceTemp[@"faceId"] isEqualToString:tempFace[@"faceId"]]) {
                                    NSMutableDictionary *well = [[NSMutableDictionary alloc] initWithDictionary:temp];
                                    NSMutableArray *faces = [[NSMutableArray alloc] initWithArray:tempFaces];
                                    faces[i] = faceTemp;
                                    [well setObject:faces forKey:@"faces"];
                                    wellArray[j] = well;
                                }
                            }
                            
                        }
                        
                    }
                }
            }
            [wellLocationArray removeAllObjects];
            if (wellArray!=nil && wellArray.count>0) {
                for (int i = 0; i<wellArray.count; i++) {
                    if (([wellArray[i] objectForKey:@"lon"]!=nil)&&(![[wellArray[i] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[wellArray[i] objectForKey:@"lon"] isEqualToString:@""])) {
                        [wellLocationArray addObject:wellArray[i]];
                    }
                }
            }
            
            [wself getPipeSegmentDate];
            startText.text = @"";
            endText.text = @"";
            [guanlianView setHidden:YES];
            isGuanlian = NO;
            isUpdate = NO;
            pipeSegInfoList = nil;
            
            //关联成功，开始画线
            [wself addOverlayView];
            [wself addLineView];
            
        }else{
            if (dic==nil ||([dic objectForKey:@"info"]==nil)) {

                [YuanHUD HUDFullText:@"操作失败，数据为空"];

            }else{

                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];

            }
            
        }
        
        [[Yuan_HUD shareInstance] HUDHide];

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
    
}
#pragma mark tableviewdatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [wellArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"identifier";
    UITableViewCell *cell=[wellTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = [wellArray[indexPath.row] objectForKey:@"wellSubName"];
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingHead;//设置显示模式为省略开头
    
    
    
    if ([[wellArray[indexPath.row] valueForKey:@"deviceId"] integerValue] > 0) {
        cell.textLabel.textColor = [UIColor mainColor];
        
        UIImageView * accessoryView = [[UIImageView alloc] initWithImage:[UIImage Inc_imageNamed:@"offline_icon"]];
        
        accessoryView.frame = CGRectMake(0, 0, 24, 24);
        
        cell.accessoryView = accessoryView;
        
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryView = nil;
    }
    
    
    cell.detailTextLabel.textColor = [UIColor grayColor];
    return cell;
}
//点击跳转到详细信息
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isGuanlian) {

        [YuanHUD HUDFullText:@"请先退出关联操作"];

        return;
    }
    
    TYKDeviceInfoMationViewController * well = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_wellMainModel withViewModel:_wellViewModel withDataDict:wellArray[indexPath.row] withFileName:@"well"];
    well.delegate = self;
    well.isOffline = NO;
    well.isSubDevice = well.isOffline;
    if (well.isOffline) {
        well.devices = [self.wellArray copy];
    }
    isADD = NO;
    [self.navigationController pushViewController:well animated:YES];
    
}
#pragma mark tableviewdelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return .00001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return .000001f;
}
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    if(isFirst){
        isFirst = NO;
        coordinate = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
        MACoordinateRegion region ;//表示范围的结构体
        region.center = coordinate;//中心点
        region.span.latitudeDelta = 0.1;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
        region.span.longitudeDelta = 0.1;//纬度范围
        [_mapView setRegion:region animated:YES];
        _mapView.showsUserLocation = NO;//关闭定位图层
    }
    else{
        if (isSetLevel) {
            isSetLevel = NO;
            [_mapView setZoomLevel:17 animated:NO];
        }
    }
    lon = userLocation.location.coordinate.longitude;
    lat = userLocation.location.coordinate.latitude;
    
}
/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    [self.timer invalidate];
    self.timer = nil;
    [HUD hideAnimated:YES];
    HUD = nil;
    if (response.regeocode != nil)
    {
        
            // 地址
        [newWell setValue:response.regeocode.formattedAddress forKey:@"addr"];
        

        NSLog(@"%@",newWell);
        
        if (!_isYuanAutoAdd) {
            TYKDeviceInfoMationViewController * well = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListInsertRfid withMainModel:_wellMainModel withViewModel:_wellViewModel withDataDict:newWell withFileName:@"well"];
            well.delegate = self;
            well.isOffline = NO;
            well.isSubDevice = well.isOffline;
            isADD = YES;
            [self.navigationController pushViewController:well animated:YES];
        }
    }
}
// Override
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    CusMAPointAnnotation *cusAnotation = (CusMAPointAnnotation *)annotation;
    if ([annotation isKindOfClass:[CusMAPointAnnotation class]]) {
        //设置覆盖物显示相关基本信息
        MAAnnotationView * annotationView = [[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        NSInteger tag = [annotation.subtitle intValue];
        //设置标注的图片
        NSLog(@"----------%ld",cusAnotation.tag);
        if (cusAnotation.tag>=10000&&cusAnotation.tag<20000) {
            //当为井类型时
            annotationView.tag = 100 + wellAnnotationIndex;
            
            NSString *type = wellLocationArray[cusAnotation.tag-10000][@"doType"];
            
            if ([lastClickType isEqualToString:@"well"] &&(selectWellIndex == tag)) {
                if ([type isEqualToString:@"isGuanlian"]) {
                    annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
                }else{
                    annotationView.image = [UIImage Inc_imageNamed:@"red_point_1"];
                }
            }
            else{
                if ([type isEqualToString:@"isGuanlian"]) {
                    annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
                }else{
                    annotationView.image = [UIImage Inc_imageNamed:@"red_point"];
                }
            }
            
            annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height*0.5));
            annotationView.draggable = YES;
            
            //在大头针上绘制文字
            UILabel *lable=[strUtil makeAnnotationViewLabel:wellLocationArray[cusAnotation.tag-10000][@"wellNo"] :wellLocationArray[cusAnotation.tag-10000][@"wellSubNo"]:@"#":YES];
            
            NSDictionary * well = wellLocationArray[cusAnotation.tag - 10000];
            NSString * wellName = well[@"wellSubName"];
            
            if ([wellName.lowercaseString rangeOfString:@"#"].length > 0) {
                
                wellName = [NSString stringWithFormat:@"#%@", [wellName componentsSeparatedByString:@"#"].lastObject];
                
            }
            lable.text = wellName;
            
            [lable sizeToFit];
            
            
            if ([lable.text isEqualToString:@"无序号"]) {
                lable.text = @"";
            }
            
            if ([[wellLocationArray[cusAnotation.tag-10000] valueForKey:@"deviceId"] integerValue] > 0) {
                // 离线设备
                lable.textColor = [UIColor colorWithHexString:@"#dfc200"];
                lable.font = [UIFont boldSystemFontOfSize:13.f];
            }
            
            if (lable.text.length == @"#".length) {
                
                lable.hidden = true;
                
            }
            [annotationView addSubview:lable];
            
        }else if(cusAnotation.tag>=20000&&cusAnotation.tag<30000) {
            //当为引上类型时
            annotationView.tag = 200 + ledUpAnnotationIndex;
            if ([lastClickType isEqualToString:@"ledup"] &&(selectLedUpIndex == tag)) {
                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
            }
            else{
                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_2_tyk"];
            }
            annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height*0.5));
            annotationView.draggable = YES;
            
            //在大头针上绘制文字
            UILabel *lable=[strUtil makeAnnotationViewLabel:ledupLocationArray[cusAnotation.tag-20000][@"ledupPointCode"] :nil:@"YS":YES];
            
        
            if ([lable.text isEqualToString:@"无序号"]) {
                lable.text = @"";
            }
            if ([[ledupLocationArray[cusAnotation.tag-20000] valueForKey:@"deviceId"] integerValue] > 0) {
                // 离线设备
                lable.textColor = [UIColor colorWithHexString:@"#dfc200"];
                lable.font = [UIFont boldSystemFontOfSize:13.f];
                
            }
            [annotationView addSubview:lable];
        }else if(cusAnotation.tag>=30000&&cusAnotation.tag<40000) {
            //当为OCC类型时
            annotationView.tag = 200 + occAnnotationIndex;
            if ([lastClickType isEqualToString:@"occ"] &&(selectOCCIndex == tag)) {
                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
            }
            else{
                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_occ_tyk"];
            }
            annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height*0.5));
            annotationView.draggable = YES;
            
            //在大头针上绘制文字
            UILabel *lable=[strUtil makeAnnotationViewLabel:occLocationArray[cusAnotation.tag-30000][@"OCCNo"] :nil:@"GJ":YES];
            if ([lable.text isEqualToString:@"无序号"]) {
                lable.text = @"";
            }
            if ([[occLocationArray[cusAnotation.tag-30000] valueForKey:@"deviceId"] integerValue] > 0) {
                // 离线设备
                lable.textColor = [UIColor colorWithHexString:@"#dfc200"];
                lable.font = [UIFont boldSystemFontOfSize:13.f];
                
            }
            [annotationView addSubview:lable];
        }
        return annotationView;
    }
    return nil;
}
-(void)overloadMarks{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSObject *view in _mapView.overlays) {
        if ([view isKindOfClass:[CusMAPolyline class]]) {
            [arr addObject:view];
        }
    }
    NSArray *array = [NSArray arrayWithArray:arr];
    [_mapView removeOverlays:array];
    [self addLineView];
    [self addTempLineView];
}
//当选中一个annotation views时，调用此接口
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    CusMAPointAnnotation *cusAnotation = (CusMAPointAnnotation *)view.annotation;
    //坐标
    if ([view.annotation isKindOfClass:[CusMAPointAnnotation class]]) {
        //取出piAnnoarray中的每个标注
        if (cusAnotation.tag>=10000&&cusAnotation.tag<20000) {
            //当为井类型时
            NSLog(@"!!!!!!!!!!!!!!");
            NSDictionary *wellTemp = wellLocationArray[cusAnotation.tag-10000];
            
            NSString * TASKID = wellTemp[@"taskId"];
            
            if (![StrUtil isMyOrderWithTaskId:TASKID] && TASKID != nil && TASKID.length > 0) {
                
                /* 取出工单 */
                NSString * taskId = [StrUtil taskIdWithTaskId:TASKID];
                /* 工单接收人 */
                NSString * reciverName = [StrUtil reciverWithTaskId:TASKID];
                /* 提示 */
                [YuanHUD HUDFullText:@"无权操作该工单资源"];
                return;
            }
            
            if (isGuanlian) {
                //关联管道段模式
                
                
                //统一库里面暂时没有面的概念,直接关联到井上
                
                if ([[wellTemp valueForKey:@"deviceId"] integerValue] > 0) {

                    [YuanHUD HUDFullText:@"离线资源无法参与关联"];
                    return;
                }
                
                //再次点击去除当前批量关联管道段下末个资源
               
                NSString *clickResId = [wellTemp objectForKey:@"GID"];
                
                if (pipeSegInfoList.count>0) {
                    NSMutableDictionary *lastPipeSeg = pipeSegInfoList[pipeSegInfoList.count-1];
                    NSLog(@"lastPipeSeg%@",lastPipeSeg);
                    if ([lastPipeSeg objectForKey:@"startDevice_Id"]!=nil &&([lastPipeSeg objectForKey:@"endDevice_Id"]==nil) &&([lastPipeSeg[@"startDevice_Id"] isEqualToString:clickResId])) {
                        //上一个管道段有起始但是无终止,最后一个点击的是起始资源
                        view.image = [UIImage Inc_imageNamed:@"red_point"];
                        
                        [pipeSegInfoList removeObject:lastPipeSeg];
                        //当前管道段个数大于0，则说明这个起始井也是上一段管道段的终止井，需要将对应的终止井也remove掉
                        if (pipeSegInfoList.count>0) {
                            NSInteger index = pipeSegInfoList.count-1;
                            [pipeSegInfoList[index] removeObjectForKey:@"endDevice_Id"];
                            [pipeSegInfoList[index] removeObjectForKey:@"endDevice"];
                            NSString *pipeSegName = [NSString stringWithFormat:@"%@（%@_",[self.pipe objectForKey:@"pipeName"],[pipeSegInfoList[index] objectForKey:@"startDevice"]];
                            [pipeSegInfoList[index] setObject:pipeSegName forKey:@"pipeSegName"];
                            [pipeSegInfoList[index] removeObjectForKey:@"pipeSegmentLength"];
                            [pipeSegInfoList[index] removeObjectForKey:@"zzlat"];
                            [pipeSegInfoList[index] removeObjectForKey:@"zzlon"];
                        }
                        [_mapView deselectAnnotation:view.annotation animated:YES];
                        [self overloadMarks];
                        
                        //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
                        if (wellLocationArray[cusAnotation.tag-10000][@"doType"]!=nil) {
                            [wellLocationArray[cusAnotation.tag-10000] removeObjectForKey:@"doType"];
                        }
                        
                        return;
                    }else if ([lastPipeSeg objectForKey:@"startDevice_Id"]!=nil &&([lastPipeSeg objectForKey:@"endDevice_Id"]!=nil) &&([lastPipeSeg[@"endDevice_Id"] isEqualToString:clickResId])) {
                        //上一个管道段有起始且有终止,最后一个点击的是终止资源
                        view.image = [UIImage Inc_imageNamed:@"red_point"];
                        
                        [lastPipeSeg removeObjectForKey:@"endDevice_Id"];
                        [lastPipeSeg removeObjectForKey:@"endDevice"];
                        NSString *pipeSegName = [NSString stringWithFormat:@"%@（%@_",[self.pipe objectForKey:@"pipeName"],[lastPipeSeg objectForKey:@"startDevice"]];
                        [lastPipeSeg setObject:pipeSegName forKey:@"pipeSegName"];
                        [lastPipeSeg removeObjectForKey:@"pipeSegmentLength"];
                        [lastPipeSeg removeObjectForKey:@"zzlat"];
                        [lastPipeSeg removeObjectForKey:@"zzlon"];
                        [_mapView deselectAnnotation:view.annotation animated:YES];
                        [self overloadMarks];
                        
                        //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
                        if (wellLocationArray[cusAnotation.tag-10000][@"doType"]!=nil) {
                            [wellLocationArray[cusAnotation.tag-10000] removeObjectForKey:@"doType"];
                        }
                        
                        return;
                    }
                }
                
                //当点了虚拟管道段列表里已经有了的资源后，再点不做响应
                if (pipeSegInfoList.count>0) {
                    for (int i = 0; i<pipeSegInfoList.count; i++) {
                        NSDictionary *pipeSeg = pipeSegInfoList[i];
                        if ([wellTemp[@"GID"] isEqualToString:pipeSeg[@"startDevice_Id"]]) {
                            NSLog(@"起始相同");
                            return;
                        }
                        if ([wellTemp[@"GID"] isEqualToString:pipeSeg[@"endDevice_Id"]]) {
                            NSLog(@"终止相同");
                            return;
                        }
                    }
                }

                view.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
                NSMutableDictionary *pipeSegInfo;//当前待关联的管道段
                
                if (pipeSegInfoList.count>0) {
                    NSDictionary *lastPipeSeg = pipeSegInfoList[pipeSegInfoList.count-1];
                    
                    if ([lastPipeSeg objectForKey:@"startDevice_Id"]!=nil &&([lastPipeSeg objectForKey:@"endDevice_Id"]==nil)) {
                        //上一个管道段有起始但是无终止
                        pipeSegInfo = [[NSMutableDictionary alloc] initWithDictionary:pipeSegInfoList[pipeSegInfoList.count-1]];
                        [pipeSegInfo setObject:[wellTemp objectForKey:@"GID"] forKey:@"endDevice_Id"];
                        [pipeSegInfo setObject:[wellTemp objectForKey:@"wellSubName"] forKey:@"endDevice"];
                        NSString *pipeSegName = [NSString stringWithFormat:@"%@%@）",[pipeSegInfo objectForKey:@"pipeSegName"],[wellTemp objectForKey:@"wellSubName"]];
                        [pipeSegInfo setObject:pipeSegName forKey:@"pipeSegName"];
                        [pipeSegInfo setObject:[wellTemp objectForKey:@"lat"] forKey:@"zzlat"];
                        [pipeSegInfo setObject:[wellTemp objectForKey:@"lon"] forKey:@"zzlon"];
                        if ([wellTemp objectForKey:@"pipe_Id"]!=nil) {
                            [pipeSegInfo setObject:[wellTemp objectForKey:@"pipe_Id"] forKey:@"zzPipeP_Id"];
                        }
                        pipeSegInfoList[pipeSegInfoList.count-1] = pipeSegInfo;
                    }else if ([lastPipeSeg objectForKey:@"startDevice_Id"]!=nil &&([lastPipeSeg objectForKey:@"endDevice_Id"]!=nil)){
                        //上一个管道段既有起始也有终止，此次点击需要将上一个管道段的终止设为当前起始，且此次点击的资源设为终止
                        pipeSegInfo = [[NSMutableDictionary alloc] init];
                        [pipeSegInfo setObject:[lastPipeSeg objectForKey:@"endDevice_Id"] forKey:@"startDevice_Id"];
                        [pipeSegInfo setObject:[lastPipeSeg objectForKey:@"endDevice"] forKey:@"startDevice"];
                        NSString *pipeSegName = [NSString stringWithFormat:@"%@（%@_",[self.pipe objectForKey:@"pipeName"],[lastPipeSeg objectForKey:@"endDevice"]];
                        [pipeSegInfo setObject:pipeSegName forKey:@"pipeSegName"];
                        [pipeSegInfo setObject:[lastPipeSeg objectForKey:@"zzlat"] forKey:@"qslat"];
                        [pipeSegInfo setObject:[lastPipeSeg objectForKey:@"zzlon"] forKey:@"qslon"];
                        if ([lastPipeSeg objectForKey:@"zzPipeP_Id"]!=nil) {
                            [pipeSegInfo setObject:[lastPipeSeg objectForKey:@"zzPipeP_Id"] forKey:@"qsPipeP_Id"];
                        }
                        
                        
                        [pipeSegInfo setObject:[wellTemp objectForKey:@"GID"] forKey:@"endDevice_Id"];
                        [pipeSegInfo setObject:[wellTemp objectForKey:@"wellSubName"] forKey:@"endDevice"];
                        
                        pipeSegName = [NSString stringWithFormat:@"%@%@）",[pipeSegInfo objectForKey:@"pipeSegName"],[wellTemp objectForKey:@"wellSubName"]];
                        [pipeSegInfo setObject:pipeSegName forKey:@"pipeSegName"];
                        [pipeSegInfo setObject:[wellTemp objectForKey:@"lat"] forKey:@"zzlat"];
                        [pipeSegInfo setObject:[wellTemp objectForKey:@"lon"] forKey:@"zzlon"];
                        if ([wellTemp objectForKey:@"pipe_Id"]!=nil) {
                            [pipeSegInfo setObject:[wellTemp objectForKey:@"pipe_Id"] forKey:@"zzPipeP_Id"];
                        }
                        
                        [pipeSegInfoList addObject:pipeSegInfo];
                    }
                }else{
                    //进行关联管道段的首个资源
                    pipeSegInfo = [[NSMutableDictionary alloc] init];
                    [pipeSegInfo setObject:[wellTemp objectForKey:@"GID"] forKey:@"startDevice_Id"];
                    [pipeSegInfo setObject:[wellTemp objectForKey:@"wellSubName"] forKey:@"startDevice"];
                    NSString *pipeSegName = [NSString stringWithFormat:@"%@（%@_",[self.pipe objectForKey:@"pipeName"],[wellTemp objectForKey:@"wellSubName"]];
                    [pipeSegInfo setObject:pipeSegName forKey:@"pipeSegName"];
                    [pipeSegInfo setObject:[wellTemp objectForKey:@"lat"] forKey:@"qslat"];
                    [pipeSegInfo setObject:[wellTemp objectForKey:@"lon"] forKey:@"qslon"];
                    if ([wellTemp objectForKey:@"pipe_Id"]!=nil) {
                        [pipeSegInfo setObject:[wellTemp objectForKey:@"pipe_Id"] forKey:@"qsPipeP_Id"];
                    }
                    
                    [pipeSegInfoList addObject:pipeSegInfo];
                }
                NSLog(@"pipeSegInfoList:%@",pipeSegInfoList);
                
                
                //添加自定义属性，规避高德地图回调重加在问题
                wellLocationArray[cusAnotation.tag-10000] = [[NSMutableDictionary alloc] initWithDictionary:wellTemp];
                [wellLocationArray[cusAnotation.tag-10000] setObject:@"isGuanlian" forKey:@"doType"];
                
                
                
                
                
                double qslat = [pipeSegInfo[@"qslat"] doubleValue];
                double qslon = [pipeSegInfo[@"qslon"] doubleValue];
                double zzlat = [pipeSegInfo[@"zzlat"] doubleValue];
                double zzlon = [pipeSegInfo[@"zzlon"] doubleValue];
                //计算管道段长度
                NSLog(@"qslat:%f,qslon:%f,zzlat:%f,zzlon:%f",qslat,qslon,zzlat,zzlon);
                if (qslat!=0.000000&&qslon!=0.000000&&zzlat!=0.000000&&zzlon!=0.000000) {
                    float pipeSegmentLength = [self pipeSegmentLengthWithLat1:qslat Lon1:qslon Lat2:zzlat Lon2:zzlon];
                    [pipeSegInfo setObject:[NSString stringWithFormat:@"%f",pipeSegmentLength] forKey:@"pipeSegmentLength"];
                    if (self.pipe[@"retion"]!=nil) {
                        [pipeSegInfo setObject:self.pipe[@"retion"] forKey:@"retion"];
                    }
                    if (self.pipe[@"areaname"]!=nil) {
                        [pipeSegInfo setObject:self.pipe[@"areaname"] forKey:@"areaname"];
                    }
                    if (self.pipe[@"areaname_Id"]!=nil) {
                        [pipeSegInfo setObject:self.pipe[@"areaname_Id"] forKey:@"areaname_Id"];
                    }
                    if (pipeSegInfo[@"pipeSegName"]!=nil) {
                        [pipeSegInfo setObject:pipeSegInfo[@"pipeSegName"] forKey:@"pipeSegmentCode"];
                    }
                    [pipeSegInfo setObject:[NSNumber numberWithInt:1] forKey:@"startDevice_Type"];
                    [pipeSegInfo setObject:[NSNumber numberWithInt:1] forKey:@"endDevice_Type"];
                    
                    [self addTempLineView];
                    
                    
                    NSLog(@"…………………………%@",pipeSegInfoList);
                }
                //取消当前大头针的点击事件，方便用户再次点击时撤销关联管道段操作
                [_mapView deselectAnnotation:view.annotation animated:YES];
                
                
            }else{
                [lastClickType setString:@"well"];
                
                //获取地图的所有标注点 同时获取标注点的标注view
                for (CusMAPointAnnotation *cmpa in [mapView annotations]) {
                    MAAnnotationView * maav = [_mapView viewForAnnotation:cmpa];
                    if (maav.tag>=10000&&maav.tag<20000) {
                        maav.image = [UIImage Inc_imageNamed:@"red_point"];
                    }
                }
                
                view.image = [UIImage Inc_imageNamed:@"red_point_1"];
                
                /// 设置当前地图的中心点 把选中的标注作为地图中心点
                [_mapView setCenterCoordinate:view.annotation.coordinate animated:YES] ;
                
                selectWellIndex = [view.annotation.subtitle intValue];
                
                //跳转到详细信息界面
                
                NSLog(@"wellTemp:%@",wellTemp);
                
                
                TYKDeviceInfoMationViewController * well = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_wellMainModel withViewModel:_wellViewModel withDataDict:wellTemp withFileName:@"well"];
                well.delegate = self;
                well.isOffline = NO;
                well.isSubDevice = well.isOffline;
                if (well.isOffline) {
                    well.devices = [self.wellArray copy];
                }
                isADD = NO;
                [self.navigationController pushViewController:well animated:YES];
                
            }
            
        }else if (cusAnotation.tag>=20000&&cusAnotation.tag<30000) {
            //当为引上点类型时
            
            NSDictionary *ledUpTemp = ledupLocationArray[cusAnotation.tag-20000];
            
            NSString * TASKID = ledUpTemp[@"taskId"];
            
            if (![StrUtil isMyOrderWithTaskId:TASKID] && TASKID != nil && TASKID.length > 0) {
                
                /* 取出工单 */
                NSString * taskId = [StrUtil taskIdWithTaskId:TASKID];
                /* 工单接收人 */
                NSString * reciverName = [StrUtil reciverWithTaskId:TASKID];
                /* 提示 */
                [YuanHUD HUDFullText:@"无权操作该工单资源"];
                return;
            }
            
            
            [lastClickType setString:@"ledup"];
            //            获取地图的所有标注点 同时获取标注点的标注view
            for (CusMAPointAnnotation *cmpa in [mapView annotations]) {
                MAAnnotationView * maav = [_mapView viewForAnnotation:cmpa];
                if (maav.tag>=20000&&maav.tag<30000) {
                    maav.image = [UIImage Inc_imageNamed:@"icon_gcoding_2"];
                }
            }
            
            view.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
            
            // 设置当前地图的中心点 把选中的标注作为地图中心点
            [_mapView setCenterCoordinate:view.annotation.coordinate animated:YES] ;
            selectLedUpIndex = [view.annotation.subtitle intValue];
            
            
            //跳转到详细信息界面
            TYKDeviceInfoMationViewController * ledUp = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_ledUpMainModel withViewModel:_ledUpViewModel withDataDict:ledUpTemp withFileName:@"ledUp"];
            ledUp.delegate = self;
            isADD = NO;
            [self.navigationController pushViewController:ledUp animated:YES];
            NSLog(@"!!!!!!!引上点:%@",[ledUpTemp objectForKey:@"ledupPointCode"]);
            
        }else if (cusAnotation.tag>=30000&&cusAnotation.tag<40000) {
            //当为OCC类型时
            NSDictionary *occTemp = occLocationArray[cusAnotation.tag-30000];
            
            NSString * TASKID = occTemp[@"taskId"];
            
            if (![StrUtil isMyOrderWithTaskId:TASKID] && TASKID != nil && TASKID.length > 0) {
                
                /* 取出工单 */
                NSString * taskId = [StrUtil taskIdWithTaskId:TASKID];
                /* 工单接收人 */
                NSString * reciverName = [StrUtil reciverWithTaskId:TASKID];
                /* 提示 */
                [YuanHUD HUDFullText:@"无权操作该工单资源"];
                return;
            }
            
            [lastClickType setString:@"occ"];
            //            获取地图的所有标注点 同时获取标注点的标注view
            for (CusMAPointAnnotation *cmpa in [mapView annotations]) {
                MAAnnotationView * maav = [_mapView viewForAnnotation:cmpa];
                if (maav.tag>=30000&&maav.tag<40000) {
                    maav.image = [UIImage Inc_imageNamed:@"icon_gcoding_2"];
                }
            }
            
            view.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
            
            /// 设置当前地图的中心点 把选中的标注作为地图中心点
            [_mapView setCenterCoordinate:view.annotation.coordinate animated:YES] ;
            selectOCCIndex = [view.annotation.subtitle intValue];
            
            
            //跳转到详细信息界面
            TYKDeviceInfoMationViewController * occ = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_occMainModel withViewModel:_occViewModel withDataDict:occTemp withFileName:@"OCC_Equt"];
            occ.delegate = self;
            isADD = NO;
            [self.navigationController pushViewController:occ animated:YES];
            NSLog(@"!!!!!!!OCC:%@",[occTemp objectForKey:@"OCCNo"]);
            
        }
        
        [_mapView selectAnnotation:nil animated:NO];
        
    }
}
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[CusMAPolyline class]])
    {
        MAPolylineRenderer* polylineView = [[MAPolylineRenderer alloc] initWithOverlay:overlay];
        CusMAPolyline *temp = (CusMAPolyline *)overlay;
        if (temp.type == 1) {
            //虚拟管道段
//            polylineView.lineDash     = YES;
            polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:1];
        }else{
            if ([pipeSegTypeArray[[MAPolylineArray count]-1] intValue] == 1) {
                polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:1];
            }else if ([pipeSegTypeArray[[MAPolylineArray count]-1] intValue] == 2) {
                polylineView.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:1];
            }else if ([pipeSegTypeArray[[MAPolylineArray count]-1] intValue] == 3) {
                polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:1];
            }else if ([pipeSegTypeArray[[MAPolylineArray count]-1] intValue] == 4) {
                polylineView.strokeColor = [[UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1.0] colorWithAlphaComponent:1];
            }else{
                polylineView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:1];
            }
        }
        polylineView.lineWidth = 5.0;
        return polylineView;
    }
    return nil;
}
#pragma mark locationManager成员方法
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    //每次要重置view的位置，才能保证图片每次偏转量正常，而不是叠加，指针方向正确。
    arrowImageView.transform = CGAffineTransformIdentity;
    CGAffineTransform transform = CGAffineTransformMakeRotation(-1 * M_PI*newHeading.magneticHeading/180.0);
    
    arrowImageView.transform = transform;
}
#pragma mark delegate

-(void)newLedupWithDict:(NSDictionary<NSString *,NSString *> *)dict{
    NSInteger index = 0;
    for (NSDictionary * dict2 in self.ledupLocationArray) {
        if ([dict2[@"ledUpId"] isEqualToString:dict[@"ledUpId"]]) {
            break;
        }
        index++;
    }
    NSLog(@"🐅%@",dict);
    
    [self.ledupLocationArray replaceObjectAtIndex:index withObject:dict];
}

-(void)newOccWithDict:(NSDictionary<NSString *,NSString *> *)dict{
    NSInteger index = 0;
    for (NSDictionary * dict2 in self.occLocationArray) {
        if ([dict2[@"OCC_EqutId"] isEqualToString:dict[@"OCC_EqutId"]]) {
            break;
        }
        index++;
    }
    [self.occLocationArray replaceObjectAtIndex:index withObject:dict];
}
-(void)newWellWithDict:(NSDictionary<NSString *,NSString *> *)dict{
    NSLog(@"dict:%@",dict);
    NSLog(@"%@ - %@", self.wellArray, self.wellLocationArray);
    if (isADD) {
        if (self.wellArray.count>0 && [dict[@"GID"] isEqualToString:self.wellArray[self.wellArray.count-1][@"GID"]]) {
            //因为会有调两遍的情况，所以需要做一个判断，如果和列表中最后一个ID相同则为第二次重复添加，所以需要return
            return;
        }
        //新添加的井一定在当前管道下，因此需要刷新当前管道下井列表
        [self.wellArray addObject:dict];
        [self.wellTableView reloadData];
        //新添加的井一定有经纬度，因此需要刷新地图数据
        [self.wellLocationArray addObject:dict];
        //标记值恢复初始
        selectWellIndex = 1000000;
        isADD = NO;
        isFirstAdd = YES;
        NSLog(@"-----wellArray:%@",self.wellArray);
        
        [self addOverlayView];
        [self addLineView];
    }else{
        //在线情况下
        //1.循环全部井列表
        for (int i = 0; i<wellArray.count; i++) {
            if ([wellArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
                [wellArray replaceObjectAtIndex:i withObject:dict];
                break;
            }
        }
        [self.wellTableView reloadData];
        //2.循环地图上显示的资源列表，如果为井类型时，判断修改的是哪个井
        for (int i = 0; i<wellLocationArray.count; i++) {
            if ([wellLocationArray[i][@"resLogicName"] isEqualToString:@"well"] && [wellLocationArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
                [wellLocationArray replaceObjectAtIndex:i withObject:dict];
                break;
            }
        }
        
    }
//    [self.navigationController popViewControllerAnimated:YES];
}
-(void)deleteWell:(NSDictionary *)dict withClass:(Class)class{
    //弹出进度框

    [Yuan_HUD.shareInstance HUDStartText:@"请稍等"];
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setValue:UserModel.uid forKey:@"UID"];
    
    [param setValue:DictToString(dict) forKey:@"jsonRequest"];
    NSLog(@"param %@",param);
    
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
    
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@%@",baseURL,@"rm!deleteCommonData.interface"] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        

        NSDictionary *dic = responseObject;
        if([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框

            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除成功" preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                selectWellIndex = 1000000;
                //在线情况下
                //1.循环全部井列表
                for (int i = 0; i<wellArray.count; i++) {
                    if ([wellArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
                        [wellArray removeObjectAtIndex:i];
                        break;
                    }
                }
                [self.wellTableView reloadData];
                //2.循环地图上显示的资源列表，如果为井类型时，判断删除的是哪根井
                for (int i = 0; i<wellLocationArray.count; i++) {
                    if ([wellLocationArray[i][@"resLogicName"] isEqualToString:@"well"] && [wellLocationArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
                        [wellLocationArray removeObjectAtIndex:i];
                        break;
                    }
                }
                
                if ([dict[@"isOnlineSubdevice"] isEqualToNumber:@1]) {
                    if (class != self.class) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }else{
                    if ([self.delegate respondsToSelector:@selector(deleteWellWithDict:withClass:)]) {
                        [self.delegate deleteWellWithDict:dict withClass:class ];
                    }
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            [alert addAction:action];
            Present(self.navigationController, alert);
            
        }else{
            if (dic==nil ||([dic objectForKey:@"info"]==nil)) {

                [YuanHUD HUDFullText:@"操作失败，数据为空"];

            }else{

                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];

            }
            
        }
        
        [[Yuan_HUD shareInstance] HUDHide];

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}

-(void)deleteLedUp:(NSDictionary *)dict withClass:(Class)class{
    selectLedUpIndex = 1000000;
    for (int i = 0; i<ledupLocationArray.count; i++) {
        if ([ledupLocationArray[i][@"ledUpId"] isEqualToString:dict[@"ledUpId"]]) {
            [ledupLocationArray removeObjectAtIndex:i];
            break;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(deleteLedUpWithDict:withClass:)]) {
        [self.delegate deleteLedUpWithDict:dict withClass:class];
    }
    
}
-(void)deleteOcc:(NSDictionary *)dict withClass:(Class)class{
    selectOCCIndex = 1000000;
    for (int i = 0; i<occLocationArray.count; i++) {
        if ([occLocationArray[i][@"OCC_EqutId"] isEqualToString:dict[@"OCC_EqutId"]]) {
            [occLocationArray removeObjectAtIndex:i];
            break;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(deleteOccWithDict:withClass:)]) {
        [self.delegate deleteOccWithDict:dict withClass:class];
    }
    
}
-(void)deleteDeviceWithDict:(NSDictionary *)dict withViewControllerClass:(__unsafe_unretained Class)vcClass{
    __weak typeof(self) wself = self;
    if ([dict[@"resLogicName"] isEqualToString:@"well"]) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确定要删除该%@?",@"井"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [wself deleteWell:dict withClass:vcClass];
        }];
        UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
        
        [alert addAction:actionYES];
        [alert addAction:actionNO];
        Present(self, alert);
        
    }else if ([dict[@"resLogicName"] isEqualToString:@"ledUp"]){
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确定要删除该%@?",@"引上点"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [wself deleteLedUp:dict withClass:vcClass];
        }];
        UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
        
        [alert addAction:actionYES];
        [alert addAction:actionNO];
        Present(self, alert);
    }else if ([dict[@"resLogicName"] isEqualToString:@"OCC_Equt"]){
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确定要删除该%@?",@"光交接箱"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [wself deleteOcc:dict withClass:vcClass];
        }];
        UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
        
        [alert addAction:actionYES];
        [alert addAction:actionNO];
        Present(self, alert);
    }
}
-(void)newDeciceWithDict:(NSDictionary<NSString *,NSString *> *)dict{
    NSString *fileType = dict[kResLogicName];
    NSLog(@"fileType = %@", fileType);
    
    if ([dict[@"resLogicName"] isEqualToString:@"ledUp"]) {
        //引上点
        [self newLedupWithDict:dict];
    }else if ([dict[@"resLogicName"] isEqualToString:@"well"]){
        //井
        [self newWellWithDict:dict];
    }else if ([dict[@"resLogicName"] isEqualToString:@"OCC_Equt"]) {
        //OCC
        [self newOccWithDict:dict];
    }
}
//变更当前选择的井面信息
-(void)wellFaceRefreshWithDict:(NSDictionary *)dict :(NSString *)locationNo{
    NSLog(@"111---:%@",dict);
    NSLog(@"222---%@",locationNo);
    NSString *GID;
    NSMutableDictionary *temp;
    
    for (int i = 0;i< self.wellLocationArray.count;i++) {
        NSDictionary * dict2 = self.wellLocationArray[i];
        if ([dict2[@"GID"] isEqualToString:dict[locationNo][@"well_Id"]]) {
            GID = dict2[@"GID"];
            NSMutableArray *faceArr = [[NSMutableArray alloc] initWithArray:self.wellLocationArray[i][@"faces"]];
            temp = [[NSMutableDictionary alloc] initWithDictionary:self.wellLocationArray[i]];
            self.wellLocationArray[i] = temp;
            [self.wellLocationArray[i] setObject:faceArr forKey:@"faces"];
            for (int j = 0; j<faceArr.count; j++) {
                if ([faceArr[j][@"locationNo"] isEqualToString:locationNo]) {
                    NSLog(@"333----%@",self.wellLocationArray[i][@"faces"][j]);
                    self.wellLocationArray[i][@"faces"][j] = dict[locationNo];
                    NSLog(@"444----%@",self.wellLocationArray[i][@"faces"][j]);
                }
            }
            break;
        }
    }
    for (int i = 0; i<self.wellArray.count; i++) {
        if ([self.wellArray[i][@"GID"] isEqualToString:GID]) {
            self.wellArray[i] = temp;
            break;
        }
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
    _search.delegate = self;
    isFirstAdd = YES;
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [self.view.layer removeAllAnimations];
    _mapView.delegate = nil; // 不用时，置nil
    _search.delegate = nil;
    [super viewDidDisappear:animated];
}
-(void)viewDidAppear:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    zoomLevel = _mapView.zoomLevel;
    [self addOverlayView];
    [self addLineView];
    [super viewDidAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
