//
//  IWPULMarkStonePathLocationViewController.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2018/4/25.
//  Copyright © 2018年 青岛英凯利信息科技有限公司. All rights reserved.
//

//
//  MarkStoneLineMapNewMainViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/5/17.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPULMarkStonePathLocationViewController.h"

#import "TYKDeviceInfoMationViewController.h"

#import "CusButton.h"
#import "MBProgressHUD.h"

#import "StrUtil.h"
#import "CusMAPointAnnotation.h"
#import "CusMAPolyline.h"
#import "IWPPropertiesReader.h"
//#import "IWPMarkStoneViewController.h"
#import "IWPCleanCache.h"
//#import "CableSelectResultViewController.h"

@interface IWPULMarkStonePathLocationViewController ()<TYKDeviceInfomationDelegate>
@property (strong, nonatomic) NSMutableArray * markStoneSegmentArray;//获取到的标石段信息列表
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSMutableArray * markStoneArray;//获取到的标石信息列表
@property (nonatomic)  NSMutableArray *resourceLocationArray;//含有经纬度坐标的资源列表

@property (strong,nonatomic)UITableView *markStoneTableView;
@property (nonatomic, strong) IWPPropertiesReader * reader;
@property (nonatomic, strong) IWPPropertiesSourceModel * model;
@property (nonatomic, strong) NSArray <IWPViewModel *>* viewModel;
@property (nonatomic, assign) long selectIndex;//当前点击的覆盖物

@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) BOOL isAutoSetAddr;

@end

@implementation IWPULMarkStonePathLocationViewController
{
    UIButton * showOrHideButton;//title上的按钮
    
    UIView *doLayout;//列表操作显示域
    CusButton *getBtn;//分页获取按钮
    
    NSString *latIn;//定位中心点的纬度
    NSString *lonIn;//定位中心点的经度
    MBProgressHUD *HUD;
    
    NSInteger resourceAnnotationIndex;
    CusMAPointAnnotation *pointAnnotation;//覆盖物
    
    BOOL isLocationSelf;//是否手动定位
    UIImageView *icm;//手动定位图标
    BOOL isGuanlian;//是否是关联模式
    
    CusButton *guanlianBtn;//关联标石段按钮
    StrUtil *strUtil;
    double lat,lon;//当前定位坐标
    
    CusButton *guanlianCableBtn;//关联光缆段按钮
    UITextView *cableTextView;//光缆段显示信息
    UIView *guanlianCableView; //批量关联光缆段缆段显示操作域
    
    NSMutableArray *markStoneSegInfoList;//关联的标石段列表
    NSMutableDictionary * newMarkStone;//新增标石
    BOOL isGLD;//是否是关联光缆段模式
    NSDictionary *markStoneCableInfo;//关联的光缆段
    NSMutableArray *markStoneCableInfoList;//关联的光缆段列表
    BOOL isFirst;//是否是第一次进来
    BOOL isSetLevel;
    
    BOOL isAdd;
    
    int limit;
    int radius;
    
    NSMutableArray *btnShowArr;//显示的按钮数组
    //传感器图片
    UIImageView *arrowImageView;
    
    BOOL isShowMenu;//是否默认显示操作菜单
    CusButton *showMenuBtn;//显示操作按钮的菜单按钮
    NSMutableArray *plGuanlanCable;/*用来显示的批量关联的光缆段列表*/
    NSMutableArray *plMarkStoneCableInfoList;/*实际的关联光缆段的资源列表*/
    NSMutableDictionary *plGuanlanCableStateDic;//批量关联的光缆段是否选中状态(光缆段ID作为字典key值)
    NSMutableArray *upPlList;
    BOOL isPLCable;//todo:是否是批量穿缆（临时，正式确定后这个变量可以删了）
    
    NSMutableArray * _linesArray;
    BOOL _isYuanAutoAdd;
}
@synthesize coordinate;
@synthesize markStoneArray;
@synthesize markStoneTableView;
@synthesize resourceLocationArray;
@synthesize selectIndex;
@synthesize markStonePath;
-(NSMutableArray *)markStoneArray{
    if (markStoneArray == nil) {
        markStoneArray = [NSMutableArray array];
    }
    return markStoneArray;
}
-(NSMutableArray *)resourceLocationArray{
    if (resourceLocationArray == nil) {
        resourceLocationArray = [NSMutableArray array];
    }
    return resourceLocationArray;
}
- (void)viewDidLoad {
    [self createPropertiesReader];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"标石路径定位";
    if (self.isOffline) {
        self.title = [self.title stringByAppendingString:@"(离线)"];
    }
    
    isPLCable = NO;
    
    [self initNavigationBar];
    
    resourceLocationArray = [[NSMutableArray alloc]init];

    isLocationSelf = NO;
    isGuanlian = NO;
    isGLD = NO;
    isFirst = YES;
    isSetLevel = NO;
    isAdd = NO;
    strUtil = [[StrUtil alloc]init];
    btnShowArr = [NSMutableArray array];
    
    // 所有线段的集合
    _linesArray = NSMutableArray.array;
    
    selectIndex = 1000000;
    limit = 100;
    radius = 500;
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([user valueForKey:@"locationRadius"]!=nil) {
        radius = [[user valueForKey:@"locationRadius"] intValue];
        
    }
    _isAutoSetAddr = [[user valueForKey:@"isAutoSetAddr"] integerValue] == 2 ? NO : YES;
    //从设置里获取
    isShowMenu = [[user valueForKey:@"isAutoShowMenu"] integerValue] == 2 ? NO : YES;
    
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
    
    
    // 统一库暂不支持定位分页
    if (([user valueForKey:@"isLocationPages"]!=nil&&[[user valueForKey:@"isLocationPages"] intValue]==2)) {
        //关闭定位分页
        [self getMarkStoneDate];
    }else{
        NSDictionary *param = nil;
        
        if (_taskId == nil && !_isInWorkOrder) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"%d\",\"resLogicName\":\"markStone\",\"ssmarkStoneP_Id\":%@}", 10000,[self.markStonePath objectForKey:@"markStonePathId"]]};
        }else{
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"%d\",\"resLogicName\":\"markStone\",\"ssmarkStoneP_Id\":%@, \"taskId\":\"%@\"}",10000,[self.markStonePath objectForKey:@"markStonePathId"], _taskId]};
        }
        
        
        [self getMarkStoneAndSegmentDate:param isStart:YES];
    }
    
    [super viewDidLoad];
}
#pragma mark 解析文件
- (void)createPropertiesReader{
 
    
    self.reader = [IWPPropertiesReader propertiesReaderWithFileName:@"UNI_markStone" withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
    
    self.model = [IWPPropertiesSourceModel modelWithDict:self.reader.result];
    NSLog(@"wweghjvjgghjgjhg = %@",self.model.subName);
    // 创建viewModel
    NSMutableArray * arrr = [NSMutableArray array];
    for (NSDictionary * dict in self.model.view) {
        IWPViewModel * viewModel = [IWPViewModel modelWithDict:dict];
        [arrr addObject:viewModel];
    }
    self.viewModel = arrr;
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
    
    
    /* 创建关闭/打开按钮 */
    showOrHideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    /* 普通状态下显示打开 */
    if (isPLCable) {
        [showOrHideButton setTitle:@"光缆段" forState:UIControlStateNormal];
    }else{
        [showOrHideButton setTitle:@"列表" forState:UIControlStateNormal];
    }
    /* 选中状态下显示关闭 */
    [showOrHideButton setTitle:@"隐藏" forState:UIControlStateSelected];
    
    [showOrHideButton sizeToFit];
    /* 添加点击事件 */
    [showOrHideButton addTarget:self action:@selector(showOrHideContentView:) forControlEvents:UIControlEventTouchUpInside];
    
    /* 取出当前右侧按钮 */
    NSMutableArray * items = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    
    /* 新建一个item，以 showOrHideButton 初始化*/
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:showOrHideButton];
    UIBarButtonItem * item1 = [[UIBarButtonItem alloc] initWithCustomView:open3DBtn];
    
    /* 加入数组 */
    [items addObject:item];
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
            if (!isShowMenu&&[showMenuBtn.titleLabel.text isEqualToString:@"菜单"]) {
                [showMenuBtn setTitle:@"隐藏" forState:UIControlStateNormal];
            }
        }else{
            // 收起
            if (btnShowArr.count<6) {
                frame.origin.y = HeigtOfTop - frame.size.height+45;
                getBtnFrame.origin.y = 50;
            }else{
                frame.origin.y = HeigtOfTop - frame.size.height+80;
                getBtnFrame.origin.y = 85;
            }
            if (!isShowMenu&&[showMenuBtn.titleLabel.text isEqualToString:@"隐藏"]) {
                [showMenuBtn setTitle:@"菜单" forState:UIControlStateNormal];
                if (btnShowArr.count<6) {
                    frame.origin.y = HeigtOfTop-(ScreenHeight-HeigtOfTop)/3;
                }else{
                    frame.origin.y = HeigtOfTop-(ScreenHeight-HeigtOfTop)/3-(80-45);
                }
                getBtnFrame.origin.y = 5;
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
    _mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, HeigtOfTop, ScreenWidth,ScreenHeight-HeigtOfTop)];
    _mapView.scaleOrigin = CGPointMake(5, _mapView.frame.size.height-30);
    _mapView.logoCenter = CGPointMake(_mapView.frame.size.width-50, _mapView.frame.size.height-15);
    _mapView.showsCompass = NO;
    [self mapState:NO];
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    [self.view addSubview:_mapView];
    
    doLayout = [[UIView alloc] initWithFrame:CGRectMake(0,HeigtOfTop-(ScreenHeight-HeigtOfTop)/3+45,ScreenWidth,(ScreenHeight-HeigtOfTop)/3)];
    if (!isShowMenu) {
        [doLayout setFrame:CGRectMake(0, HeigtOfTop-(ScreenHeight-HeigtOfTop)/3, ScreenWidth, (ScreenHeight-HeigtOfTop)/3)];
    }
    [doLayout setBackgroundColor:[UIColor colorWithHexString:@"#dcdcdc"]];
    [self.view addSubview:doLayout];
    
    markStoneTableView=[[UITableView alloc] initWithFrame:CGRectMake(2, 2, doLayout.frame.size.width-4,doLayout.frame.size.height-4-45) style:UITableViewStyleGrouped];
    markStoneTableView.backgroundColor=[UIColor whiteColor];
    [markStoneTableView setEditing:NO];
    markStoneTableView.delegate=self;
    markStoneTableView.dataSource=self;
    [doLayout addSubview:markStoneTableView];
    
    CusButton *nowLocationBtn = [self btnInit:@"当前位置"];
    [nowLocationBtn addTarget:self action:@selector(nowLocation:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowArr addObject:nowLocationBtn];
    CusButton *selfLocationBtn = [self btnInit:@"手动定位"];
    [selfLocationBtn addTarget:self action:@selector(selfLocation:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowArr addObject:selfLocationBtn];
    
    CusButton *nearMarkStoneBtn = [self btnInit:@"附近标石"];
    [nearMarkStoneBtn addTarget:self
                         action:@selector(nearMarkStoneBtnClick)
               forControlEvents:UIControlEventTouchUpInside];
    
    [btnShowArr addObject:nearMarkStoneBtn];
    
    CusButton *addMarkStoneBtn = [self btnInit:@"添加标石"];
    [addMarkStoneBtn addTarget:self action:@selector(addMarkStone:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowArr addObject:addMarkStoneBtn];
    guanlianBtn = [self btnInit:@"关联标石段"];
    [guanlianBtn addTarget:self action:@selector(guanlian:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowArr addObject:guanlianBtn];
    guanlianCableBtn = [self btnInit:@"关联光缆段"];
    [guanlianCableBtn addTarget:self action:@selector(guanlianCable:) forControlEvents:UIControlEventTouchUpInside];
//    [btnShowArr addObject:guanlianCableBtn];
    
    //根据权限显示
    if (!_isOffline) {
        if ([UserModel.domainCode isEqualToString:@"0/"] ) {
            [btnShowArr removeObject:addMarkStoneBtn];
            [btnShowArr removeObject:guanlianBtn];
            [btnShowArr removeObject:guanlianCableBtn];
        }
        if (([[UserModel.powersTYKDic[@"markStone"] substringToIndex:1] integerValue] == 0)){
            //无添加标石权限
            [btnShowArr removeObject:addMarkStoneBtn];
        }
        if (([[UserModel.powersTYKDic[@"markStoneSegment"] substringToIndex:1] integerValue] == 0)){
            //无关联标石权限
            [btnShowArr removeObject:guanlianBtn];
        }
        if (([[UserModel.powersTYKDic[@"markStone"] substringFromIndex:2] integerValue] == 0)){
            //无核查标石权限
            [btnShowArr removeObject:guanlianCableBtn];
        }
    }
    [self showBtn];
    
    //分页模式下显示获取按钮
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([[user objectForKey:@"isLocationPages"] integerValue] != 2) {
        int y = 0;
        if (btnShowArr.count<6) {
            y = 45;
        }else{
            y = 70;
        }
        if (!isShowMenu) {
            y = 5;
        }
        getBtn = [[CusButton alloc] initWithFrame:CGRectMake(_mapView.frame.size.width-_mapView.frame.size.width/5-5, y+5, _mapView.frame.size.width/5, 40)];
        getBtn.layer.cornerRadius = 5;
        [getBtn setTitle:@"获取" forState:UIControlStateNormal];
        [getBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        getBtn.tag = 8298374;
        [getBtn setBackgroundColor:[UIColor mainColor]];
        [getBtn addTarget:self action:@selector(getResource:) forControlEvents:UIControlEventTouchUpInside];
        [getBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_mapView addSubview:getBtn];
    }
    if (!isPLCable) {
        //批量关联光缆段缆段显示操作域
        guanlianCableView = [[UIView alloc] initWithFrame:CGRectMake(20, ScreenHeight-30-50, ScreenWidth-40, 50)];
        [guanlianCableView setHidden:YES];
        [self.view addSubview:guanlianCableView];
        
        cableTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, guanlianCableView.frame.size.width/4*3-2, 50)];
        cableTextView.layer.cornerRadius = 5;
        cableTextView.layer.borderColor = [UIColor colorWithHexString:@"#aaaaaa"].CGColor;
        cableTextView.layer.borderWidth = 0.5f;
        [cableTextView setFont:[UIFont systemFontOfSize:17.0f]];
        [cableTextView setEditable:NO];
        [guanlianCableView addSubview:cableTextView];
        
        CusButton *cabelCancelBtn = [[CusButton alloc] initWithFrame:CGRectMake(guanlianCableView.frame.size.width/4*3, 0, guanlianCableView.frame.size.width/4, 50)];
        [cabelCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cabelCancelBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [cabelCancelBtn setBackgroundColor:[UIColor mainColor]];
        [cabelCancelBtn.layer setCornerRadius:10.0];
        [cabelCancelBtn addTarget:self action:@selector(cabelCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        [guanlianCableView addSubview:cabelCancelBtn];
    }
    
    UIImage *image = [UIImage Inc_imageNamed:@"nav_turn_via_2"];
    icm = [[UIImageView alloc] initWithImage:image];
    CGPoint loc = {_mapView.frame.size.width/2 ,_mapView.frame.size.height/2};
    icm.center = loc;
    icm.hidden = YES;
    [_mapView addSubview:icm];
    
    arrowImageView = [[UIImageView alloc] initWithImage:[UIImage Inc_imageNamed:@"zhinanzhen.png"]];
    [arrowImageView setFrame:CGRectMake(_mapView.frame.size.width-60, _mapView.frame.size.height-60, 60, 60)];
    [_mapView addSubview:arrowImageView];
    
    //非默认显示操作按钮设置下，显示菜单按钮
    if (!isShowMenu) {
        showMenuBtn = [[CusButton alloc] initWithFrame:CGRectMake(_mapView.frame.size.width-55, _mapView.frame.size.height-110, 48, 48)];
        [showMenuBtn setTitle:@"菜单" forState:UIControlStateNormal];
        [showMenuBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [showMenuBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [showMenuBtn setBackgroundColor:[UIColor mainColor]];
        [showMenuBtn.layer setCornerRadius:24.0];
        [showMenuBtn addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
        [_mapView addSubview:showMenuBtn];
    }
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
            if (!isShowMenu) {
                [doLayout setFrame:CGRectMake(0,HeigtOfTop-(ScreenHeight-HeigtOfTop)/3-(80-45),ScreenWidth,(ScreenHeight-HeigtOfTop)/3+(80-45))];
            }
            if (i<5) {
                [btn setFrame:CGRectMake(0+(ScreenWidth/5)*i, doLayout.frame.size.height-35*2, ScreenWidth/5, 35-1)];
            }else{
                [btn setFrame:CGRectMake(0+(ScreenWidth/(btnShowArr.count-5))*(i-5), doLayout.frame.size.height-35, ScreenWidth/(btnShowArr.count-5), 35)];
            }
        }
        [doLayout addSubview:btn];
    }
}
//菜单按钮点击触发事件
-(IBAction)showMenu:(CusButton *)sender{
    /* 开始动画 */
    [UIView animateWithDuration:.3f animations:^{
        /* 取出视图当前位置 */
        CGRect frame = doLayout.frame;
        CGRect getBtnFrame = getBtn.frame;
        if ([sender.titleLabel.text isEqualToString:@"菜单"]) {
            // 展开
            frame.origin.y = HeigtOfTop-(ScreenHeight-HeigtOfTop)/3+45;
            if (btnShowArr.count<6) {
                getBtnFrame.origin.y = 50;
            }else{
                getBtnFrame.origin.y = 85;
            }
            [sender setTitle:@"隐藏" forState:UIControlStateNormal];
            
        }else{
            // 收起
            [sender setTitle:@"菜单" forState:UIControlStateNormal];
            if (btnShowArr.count<6) {
                frame.origin.y = HeigtOfTop-(ScreenHeight-HeigtOfTop)/3;
            }else{
                frame.origin.y = HeigtOfTop-(ScreenHeight-HeigtOfTop)/3-(80-45);
            }
            getBtnFrame.origin.y = 5;
            if (showOrHideButton.isSelected) {
                [showOrHideButton setSelected:NO];
            }
        }
        
        doLayout.frame = frame;
        getBtn.frame = getBtnFrame;
    }];
}
//获取当前位置按钮点击触发事件
-(IBAction)nowLocation:(CusButton *)sender
{
    isLocationSelf = NO;
    isFirst = NO;
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
    _mapView.showsUserLocation = NO;//显示定位图层
    icm.hidden = NO;
}



// 获取附近标识
- (void) nearMarkStoneBtnClick {
    
 
    [YuanHUD HUDFullText:@"请稍等"];
//    return;
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
    
//    NSString *requestStr = [NSString stringWithFormat:@"{\"isAll\":\"1\",\"resLogicName\":\"pole\",\"lon\":\"%@\",\"lat\":\"%@\"}",lonStr,latStr];
    
    NSDictionary * jsonDict = @{
        @"isAll" : @"1" ,
        @"resLogicName" : @"markStone",
        @"lon" : lonStr,
        @"lat" : latStr
    };
    
    [self getNearMarkStoneData:jsonDict];
    
}

- (void) getNearMarkStoneData:(NSDictionary *) json_Dict {
    
    __weak typeof(self) wself = self;
//    [16]    (null)    @"resLogicName" : @"markStone"
    [[Http shareInstance] V2_POST:@"rm!getCommonData.interface"
                             dict:json_Dict
                          succeed:^(id data) {
       
        
        NSArray * result = data;
        
        if ([result obj_IsNull]) {
            [[Yuan_HUD shareInstance] HUDFullText:@"数据错误"];
            return ;
        }
        
        if (result.count == 0 || !result) {
            [[Yuan_HUD shareInstance] HUDFullText:@"暂无数据"];
            return;
        }
        
//        selectResourceIndex = 1000000;
        NSMutableArray *nearMarkStoneArray = [NSMutableArray arrayWithArray:result];
        for (NSDictionary *markStoneDict in nearMarkStoneArray) {
            BOOL isHave = NO;
            for (NSDictionary *pTemp in resourceLocationArray) {
                if (([pTemp[@"resLogicName"] isEqualToString:@"markStone"])&&[[markStoneDict objectForKey:@"GID"] isEqualToString:[pTemp objectForKey:@"GID"]]) {
                    isHave = YES;
                    continue;
                }
            }
            if (!isHave) {
                if (([markStoneDict objectForKey:@"lon"]!=nil)&&
                    (![[markStoneDict objectForKey:@"lon"] isEqualToString:@"\"\""])&&
                    (![[markStoneDict objectForKey:@"lon"] isEqualToString:@""])) {
                    [resourceLocationArray addObject:markStoneDict];
                }
            }
        }
        
        [[Yuan_HUD shareInstance] HUDFullText:@"获取标石成功"];
        
        
        [wself addOverlayView];
        [wself addLineView];
        if (isGuanlian) {
            [wself addTempLineView];
        }
        
    }];
    
}




//添加标石按钮点击触发事件
-(IBAction)addMarkStone:(CusButton *)sender
{
    if (isGLD) {
     
        [YuanHUD HUDFullText:@"请先退出关联光缆段"];
        return;
    }
    if (isGuanlian) {
        
        [YuanHUD HUDFullText:@"请先退出关联标石段"];

        return;
        
    }

    NSString * latStr, * lonStr;
    /**
     *
     */
    
    // MARK: 袁全 修改
    lonStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
    latStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
//    if (isLocationSelf) {
//        //手动定位下
//
//    }else{
//        lonStr = [NSString stringWithFormat:@"%f",lon];
//        latStr = [NSString stringWithFormat:@"%f",lat];
//    }
    if ([lonStr isEqualToString:@"0.000000"]||[latStr isEqualToString:@"0.000000"]) {
        [YuanHUD HUDFullText:@"请先进行位置获取操作"];
        return;
    }
    
    newMarkStone = [NSMutableDictionary dictionary];
    // 名称
    [newMarkStone setValue:[NSString stringWithFormat:@"%@_号标",markStonePath[@"markStonePName"]]
                    forKey:@"markName"];
    
    
    NSLog(@"markStonePath = %@", markStonePath);
    
    // 所属局站，局站ID
    
    if (markStonePath[@"areaname"] != nil) {
        [newMarkStone setValue:markStonePath[@"areaname"] forKey:@"areaname"];
    }
    
    if (markStonePath[@"areaname_Id"]) {
        [newMarkStone setValue:markStonePath[@"areaname_Id"] forKey:@"areaname_Id"];
    }
    
    
    // 2019年11月11日 新增：跟随标石路径信息。
    if (self.markStonePath[@"chanquanxz"] != nil){
        newMarkStone[@"chanquanxz"] = self.markStonePath[@"chanquanxz"];
    }
    
    if (self.markStonePath[@"prorertyBelong"] != nil){
        newMarkStone[@"prorertyBelong"] = self.markStonePath[@"prorertyBelong"];
    }
    
    
    
    // 所屬标石路径
    
    [newMarkStone setValue:markStonePath[@"markStonePName"] forKey:@"ssmarkStoneP"];
    
    /* 2017年03月02日 新增，工单内添加资源，需要带taskId */
    
    if (_taskId) {
        /* 说明这是在一个工单内添加的资源 */
        
        [newMarkStone setValue:_taskId forKey:@"taskId"];
    }
    
    if (markStonePath[@"taskId"] != nil && _taskId == nil) {
        /* 2017年03月03日 新增，在资源清查中，向属于某工单的杆路、管道、标石路径中添加新的电杆、撑点、井、标石 时，该资源同样处理为工单内资源*/
        
        [newMarkStone setValue:markStonePath[@"taskId"] forKey:@"taskId"];
        
    }
    
    /**
     *  离线
     */
    if (_isOffline) {
        [newMarkStone setValue:markStonePath[@"deviceId"] forKey:@"mainDeviceId"];
    }else{
        [newMarkStone setValue:markStonePath[@"markStonePathId"] forKey:@"ssmarkStoneP_Id"];
    }
    
    NSLog(@"%@",newMarkStone);
    // 所属维护区域
    
    if (markStonePath[@"retion"] != nil) {
        [newMarkStone setValue:markStonePath[@"retion"] forKey:@"retion"];
    }
    
    
    // 经纬度
    [newMarkStone setValue:latStr forKey:@"lat"];
    [newMarkStone setValue:lonStr forKey:@"lon"];
    
    
    NSNumber * code = [[NSUserDefaults standardUserDefaults] valueForKey:@"yuan_IsAutoAdd"];
    NSInteger yuan_IsAutoAdd = code.integerValue;
    
    // 手动 yuan_IsAutoAdd == 2
    if (yuan_IsAutoAdd == 2) {
        if (_isOffline) {
            TYKDeviceInfoMationViewController * addMarkStone = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListInsertRfid withMainModel:_model withViewModel:_viewModel withDataDict:newMarkStone withFileName:@"markStone"];
            isAdd = YES;
            addMarkStone.delegate = self;
            addMarkStone.isOffline = _isOffline;
            addMarkStone.taskId = _taskId;
            addMarkStone.isInWorkOrder = _isInWorkOrder;
            if (_isOffline) {
                addMarkStone.isSubDevice = YES;
                addMarkStone.devices = self.markStoneArray;
            }
            [self.navigationController pushViewController:addMarkStone animated:YES];
        }else{
            if (_isAutoSetAddr) {
                [self searchReGeocodeWithCoordinate:(CLLocationCoordinate2D){[latStr doubleValue],[lonStr doubleValue]}];
            }else{
                TYKDeviceInfoMationViewController * addMarkStone = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListInsertRfid withMainModel:_model withViewModel:_viewModel withDataDict:newMarkStone withFileName:@"markStone"];
                isAdd = YES;
                addMarkStone.delegate = self;
                addMarkStone.isOffline = NO;
                addMarkStone.taskId = _taskId;
                addMarkStone.isInWorkOrder = _isInWorkOrder;
                [self.navigationController pushViewController:addMarkStone animated:YES];
            }
        }
    }
    
    // 自动
    else {
        
        [self autoAdd];
        
    }
    
}




- (void) autoAdd {
    
    _isYuanAutoAdd = YES;
    
    NSString * latStr, * lonStr;

    // MARK: 袁全 修改
    lonStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
    latStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
    
    
    if (resourceLocationArray.count == 0 ) {
        
        _isYuanAutoAdd = NO;
        [self searchReGeocodeWithCoordinate:(CLLocationCoordinate2D){[latStr doubleValue],[lonStr doubleValue]}];
        return;
    }
    else {
        [self searchReGeocodeWithCoordinate:(CLLocationCoordinate2D){[latStr doubleValue],[lonStr doubleValue]}];
    }
    NSDictionary * lastDict = resourceLocationArray.lastObject;
    
    // newMarkStone
    
    
    
    NSInteger large = 0;
    
    for (NSDictionary * dict in resourceLocationArray) {
//        @"文昌公坡水北民视机房-文昌公坡水北农商行杆路"
//        @"文昌公坡水北民视机房-文昌公坡水北农商行杆路P"
        NSString * markStoneCode = dict[@"markName"];
        
        NSArray * codeArr = [markStoneCode componentsSeparatedByString:@"_"];
        
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
        newMarkStone[@"markStoneCode"] = [NSString stringWithFormat:@"%@_%ld",newMarkStone[@"markName"],large];
        newMarkStone[@"markName"] = [NSString stringWithFormat:@"%@_%ld",newMarkStone[@"markName"],large];
    }
    else {
        
        newMarkStone[@"markStoneCode"] = [NSString stringWithFormat:@"%@_%ld",newMarkStone[@"markName"],large];
        newMarkStone[@"markName"] = [NSString stringWithFormat:@"%@_%ld",newMarkStone[@"markName"],large];
    }
    
    for (NSString * key in lastDict.allKeys) {
        
        if (![newMarkStone.allKeys containsObject:key] &&
            ![key isEqualToString:@"GID"] &&
            ![key isEqualToString:@"rfid"]) {
            
            newMarkStone[key] = lastDict[key];
        }
    }
    
    
    
    // 走保存接口
    
    [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Insert
                             dict:newMarkStone
                          succeed:^(id data) {
            
        NSArray * arr = data;
        
        if (arr.count > 0) {
            
            isAdd = YES;
            NSDictionary * dict = arr.firstObject;
            [self newMarkStoneWithDict:dict];
        }
        else {
            [[Yuan_HUD shareInstance] HUDFullText:@"自动添加标石失败"];
        }
    }];
    
    
}








//关联标石段按钮点击触发事件
-(IBAction)guanlian:(CusButton *)sender
{
    if (_isOffline) {

        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    if (isGLD) {
      
        [YuanHUD HUDFullText:@"请先退出关联光缆段"];
        return;
    }
    
    if (!isGuanlian) {
        [sender setTitle:@"确定关联" forState:UIControlStateNormal];
        isGuanlian = YES;
        markStoneSegInfoList = [[NSMutableArray alloc] init];
    }else{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确定要关联当前选择标石段吗"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (markStoneSegInfoList.count == 0) {
                return ;
            }
            [self addMarkStoneSegDate];
        }];
        UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            isGuanlian = NO;
            [sender setTitle:@"关联标石段" forState:UIControlStateNormal];
            //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
            for (int i = 0; i<resourceLocationArray.count; i++) {
                if (resourceLocationArray[i][@"doType"]!=nil) {
                    [resourceLocationArray[i] removeObjectForKey:@"doType"];
                }
            }
            markStoneSegInfoList = nil;
            [self addOverlayView];
            [self addLineView];
            
        }];
        
        [alert addAction:actionYES];
        [alert addAction:actionNO];
        Present(self, alert);
    }
}
//关联光缆段按钮点击触发事件
-(IBAction)guanlianCable:(id)sender{
    if (_isOffline) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];

        return;
    }
    if (isGuanlian) {
        [YuanHUD HUDFullText:@"请先退出关联标石段"];

      
        
        return;
        
    }
    if (isGLD == NO) {
        if (plGuanlanCable!=0 && plGuanlanCable.count>0) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择操作" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * one = [UIAlertAction actionWithTitle:@"直接穿缆" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                isGLD = YES;
                [guanlianCableBtn setTitle:@"确认" forState:UIControlStateNormal];
                markStoneCableInfoList = [[NSMutableArray alloc] init];
            }];
            UIAlertAction * two = [UIAlertAction actionWithTitle:@"选择缆段" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //进入光缆段选择界面
//                CableSelectResultViewController *cabelSelectResultVC = [[CableSelectResultViewController alloc] init];
//                cabelSelectResultVC.doType = @"";
//                if (isPLCable) {
//                    cabelSelectResultVC.isHavePl = YES;
//                }
//                [self.navigationController pushViewController:cabelSelectResultVC animated:YES];
            }];
            [alert addAction:one];
            [alert addAction:two];
            
            Present(self, alert);
        }else{
//            //进入光缆段选择界面
//            CableSelectResultViewController *cabelSelectResultVC = [[CableSelectResultViewController alloc] init];
//            cabelSelectResultVC.doType = @"";
//            if (isPLCable) {
//                cabelSelectResultVC.isHavePl = YES;
//            }
//            [self.navigationController pushViewController:cabelSelectResultVC animated:YES];
        }
    }else{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确定进行穿缆操作？"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //确认关联
            if (markStoneCableInfoList!=nil &&markStoneCableInfoList.count>0) {
                NSMutableArray *upList = [[NSMutableArray alloc] init];
                if (isPLCable) {
                    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
                    for (int i = 0; i<resourceLocationArray.count; i++) {
                        if (resourceLocationArray[i][@"doType"]!=nil) {
                            [resourceLocationArray[i] removeObjectForKey:@"doType"];
                        }
                    }
                    
                    //调用接口 上传标石穿缆信息
                    [self updatePlMarkStoneCable:upPlList];
                }else{
                    for (int i = 0; i<markStoneCableInfoList.count; i++) {
                        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:markStoneCableInfoList[i]];
                        if ([temp objectForKey:@"bearCableSegment"]!=nil) {
                            NSString *object = [NSString stringWithFormat:@"%@%@,",[temp objectForKey:@"bearCableSegment"],[markStoneCableInfo objectForKey:@"cableName"]];
                            [temp setObject:object forKey:@"bearCableSegment"];
                        }else{
                            [temp setObject:[NSString stringWithFormat:@"%@,",[markStoneCableInfo objectForKey:@"cableName"]] forKey:@"bearCableSegment"];
                        }
                        if ([temp objectForKey:@"bearCableSegmentId"]!=nil) {
                            NSString *object = [NSString stringWithFormat:@"%@%@,",[temp objectForKey:@"bearCableSegmentId"],[markStoneCableInfo objectForKey:@"cableId"]];
                            [temp setObject:object forKey:@"bearCableSegmentId"];
                        }else{
                            [temp setObject:[NSString stringWithFormat:@"%@,",[markStoneCableInfo objectForKey:@"cableId"]] forKey:@"bearCableSegmentId"];
                        }
                        if ([temp objectForKey:@"bearCableSegmentRFID"]!=nil) {
                            NSString *object = [NSString stringWithFormat:@"%@ ,",[temp objectForKey:@"bearCableSegmentRFID"]];
                            [temp setObject:object forKey:@"bearCableSegmentRFID"];
                        }else{
                            [temp setObject:@" ," forKey:@"bearCableSegmentRFID"];
                        }
                        
                        [upList addObject:temp];
                    }
                    
                    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
                    for (int i = 0; i<resourceLocationArray.count; i++) {
                        if (resourceLocationArray[i][@"doType"]!=nil) {
                            [resourceLocationArray[i] removeObjectForKey:@"doType"];
                        }
                    }
                    
                    //调用接口 上传标石穿缆信息
                    [self updateMarkStoneCable:upList];
                }
                
            }else{
                //未选择任何标石，直接取消关联
                isGLD = NO;
                cableTextView.text = @"";
                [guanlianCableBtn setTitle:@"关联光缆段" forState:UIControlStateNormal];
                [guanlianCableView setHidden:YES];
                //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
                for (int i = 0; i<resourceLocationArray.count; i++) {
                    if (resourceLocationArray[i][@"doType"]!=nil) {
                        [resourceLocationArray[i] removeObjectForKey:@"doType"];
                    }
                }
                markStoneCableInfoList = nil;
                [self addOverlayView];
                [self addLineView];
            }
        }];
        UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self cabelCancel:nil];
        }];
        
        [alert addAction:actionYES];
        [alert addAction:actionNO];
        Present(self, alert);
    }
}
//取消关联光缆段按钮点击触发事件
-(IBAction)cabelCancel:(id)sender{
    isGLD = NO;
    cableTextView.text = @"";
    [guanlianCableBtn setTitle:@"关联光缆段" forState:UIControlStateNormal];
    [guanlianCableView setHidden:YES];
    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
    for (int i = 0; i<resourceLocationArray.count; i++) {
        if (resourceLocationArray[i][@"doType"]!=nil) {
            [resourceLocationArray[i] removeObjectForKey:@"doType"];
        }
    }
    markStoneCableInfoList = nil;
    [self addOverlayView];
    [self addLineView];
}
//获取资源按钮点击触发事件
-(IBAction)getResource:(CusButton *)sender
{
    if (self.isOffline) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];

        return;
    }
    if (isGuanlian || isGLD) {

        [YuanHUD HUDFullText:@"请先退出关联操作"];

        return;
    }
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
    
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"lon\":\"%@\",\"lat\":\"%@\",\"radius\":\"%d\",\"resLogicName\":\"markStone\",\"ssmarkStoneP_Id\":%@}",lonStr,latStr,radius,[self.markStonePath objectForKey:@"markStonePathId"]]};
    [self getMarkStoneAndSegmentDate:param isStart:NO];
}
- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)location
{
    if (!_isOffline) {
        [self startTimeOutListen];
    }

    
    [YuanHUD HUDFullText:@"正在获取地址，请稍候……"];
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:location.latitude longitude:location.longitude];
    regeo.requireExtension = YES;
    
    [_search AMapReGoecodeSearch:regeo];
    
}
-(void)startTimeOutListen{
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10.f target:self selector:@selector(gCodeTimeOutHint) userInfo:nil repeats:NO];
        //        [[[NSRunLoop alloc] init] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
-(void)gCodeTimeOutHint{
    //    AlertShow([UIApplication sharedApplication].keyWindow, @"超时啦！", 2.f, @"");
    [HUD hideAnimated:YES];
    HUD = nil;
    
    [_search cancelAllRequests];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前网络不佳无法获取真实地址" message:@"是否不添加地址到新增标石中？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * sure = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 跳转详情页
        
        TYKDeviceInfoMationViewController * addMarkStone = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListInsertRfid withMainModel:_model withViewModel:_viewModel withDataDict:newMarkStone withFileName:@"markStone"];
        isAdd = YES;
        addMarkStone.delegate = self;
        addMarkStone.isOffline = _isOffline;
        
        [self.navigationController pushViewController:addMarkStone animated:YES];
    }];
    
    UIAlertAction * dont = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 重试与否？
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"是否重试？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * sure = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // 重试
            [self addMarkStone:nil];
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
        [newMarkStone setValue:response.regeocode.formattedAddress forKey:@"addr"];
        
        
        
        if (!_isYuanAutoAdd) {
            TYKDeviceListControlTypeRef mode = TYKDeviceListInsertRfid;
            
            TYKDeviceInfoMationViewController * addMarkStone =
            [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:mode
                                                                 withMainModel:_model
                                                                 withViewModel:_viewModel
                                                                  withDataDict:newMarkStone
                                                                  withFileName:@"markStone"];
            isAdd = YES;
            addMarkStone.delegate = self;
    //        addMarkStone.isOffline = NO;
            [self.navigationController pushViewController:addMarkStone animated:YES];
        }
        
        
        
    }
}
//初始化地图显示位置
- (void)initOverlay {
    if ([resourceLocationArray count]>0) {
        //当列表不为空且至少有一个资源有坐标时
        latIn = [resourceLocationArray[0] objectForKey:@"lat"];
        lonIn = [resourceLocationArray[0] objectForKey:@"lon"];
        
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
    resourceAnnotationIndex = 0;
    //加载资源信息
    for (int i = 0; i<[resourceLocationArray count]; i++) {
        resourceAnnotationIndex = i;
        pointAnnotation = [[CusMAPointAnnotation alloc] init];
        CLLocationCoordinate2D coor;
        coor.latitude = [resourceLocationArray[i][@"lat"] doubleValue];
        coor.longitude = [resourceLocationArray[i][@"lon"] doubleValue];
        pointAnnotation.tag = 100000+i;
        pointAnnotation.coordinate = coor;
        pointAnnotation.subtitle = [NSString stringWithFormat:@"%d",100000+i];
        [_mapView addAnnotation:pointAnnotation];
    }
}
//添加资源画线
-(void)addLineView
{
    
    if (_linesArray.count > 0) {
        [_mapView removeOverlays:_linesArray];
        _linesArray = NSMutableArray.array;
    }
    
    for (int i = 0; i<_markStoneSegmentArray.count; i++) {
        NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        NSMutableDictionary *seg = _markStoneSegmentArray[i];
        for (int j = 0; j<resourceLocationArray.count; j++) {
            NSMutableDictionary *resource = resourceLocationArray[j];
            if ([resource[@"resLogicName"] isEqualToString:@"markStone"]) {
                if ([[NSString stringWithFormat:@"%@",[resource objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"startmarkStone_Id"]]]) {
                    [p1 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [p1 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p1];
                }
                if ([[NSString stringWithFormat:@"%@",[resource objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"endmarkStone_Id"]]]) {
                    [p2 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [p2 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p2];
                }
            }
            if (p1!=nil && p2!=nil && [[p1 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p1 objectForKey:@"lon"] doubleValue]&& [[p2 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p2 objectForKey:@"lon"] doubleValue]) {
                CLLocationCoordinate2D coors[2] = {0};
                coors[0].latitude = [[p1 objectForKey:@"lat"] doubleValue];
                coors[0].longitude = [[p1 objectForKey:@"lon"] doubleValue];
                coors[1].latitude = [[p2 objectForKey:@"lat"] doubleValue];
                coors[1].longitude = [[p2 objectForKey:@"lon"] doubleValue];
                
                
                NSLog(@"coors:%f,%f,%f,%f",coors[0].latitude,coors[0].longitude,coors[1].latitude,coors[1].longitude);
                CusMAPolyline *polyline = [CusMAPolyline polylineWithCoordinates:coors count:2];
                [_mapView addOverlay:polyline];
                [_linesArray addObject:polyline];
                break;
            }
        }
    }
}
//添加资源画线
-(void)addTempLineView
{
    for (int i = 0; i<markStoneSegInfoList.count; i++) {
        NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        NSMutableDictionary *seg = markStoneSegInfoList[i];
        for (int j = 0; j<resourceLocationArray.count; j++) {
            NSMutableDictionary *resource = resourceLocationArray[j];
            if ([resource[@"resLogicName"] isEqualToString:@"markStone"]) {
                if ([[NSString stringWithFormat:@"%@",[resource objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"startmarkStone_Id"]]]) {
                    [p1 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [p1 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p1];
                }
                if ([[NSString stringWithFormat:@"%@",[resource objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"endmarkStone_Id"]]]) {
                    [p2 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [p2 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p2];
                }
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
//计算标石段长度
-(double)markStoneSegmentLengthWithLat1:(double)lat1 Lon1:(double)lon1 Lat2:(double)lat2 Lon2:(double)lon2
{
    //第一个坐标
    CLLocation *current=[[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
    //第二个坐标
    CLLocation *before=[[CLLocation alloc] initWithLatitude:lat2 longitude:lon2];
    // 计算距离
    CLLocationDistance meters=[current distanceFromLocation:before];
    return meters;
}
//获取当前标石路径下标石信息
-(void)getMarkStoneDate
{
    
    
    NSLog(@"getMarkStoneDate --");
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    
    //调用查询接口
    
    NSDictionary * param = nil;
    
    
    if (_taskId) {
        param =  @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"10000\",\"resLogicName\":\"markStone\",ssmarkStoneP_Id:%@,taskId:\"%@\"}",[self.markStonePath objectForKey:@"markStonePathId"], _taskId]};
    }else{
        param =  @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"10000\",\"resLogicName\":\"markStone\",ssmarkStoneP_Id:%@}",[self.markStonePath objectForKey:@"markStonePathId"]]};
    }
    
    
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * url = [NSString stringWithFormat:@"%@rm!getCommonData.interface",BaseURL];
#else
    NSString * url = [NSString stringWithFormat:@"%@rm!getCommonData.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    [Http.shareInstance POST:url parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {


        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {

        
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            
            for (NSDictionary * markStone in arr) {
                [self.markStoneArray addObject:markStone];
            }
            
            NSLog(@"markStoneArray.count:%lu",(unsigned long)markStoneArray.count);
            for (int i = 0; i<markStoneArray.count; i++) {
                if (([markStoneArray[i] objectForKey:@"lon"]!=nil)&&(![[markStoneArray[i] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[markStoneArray[i] objectForKey:@"lon"] isEqualToString:@""])) {
                    [resourceLocationArray addObject:markStoneArray[i]];
                    NSLog(@"add__________________");
                }
            }
            [markStoneTableView reloadData];
            
            [self initOverlay];
            [self getMarkStoneSegmentDate];
            [self addLineView];
            [self addOverlayView];
            
        }else{
            [YuanHUD HUDFullText:dic[@"info"]];
            [self initOverlay];
        }
        
        [[Yuan_HUD shareInstance] HUDHide];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
        [self initOverlay];
        
    }];
}

/// MARK: 获取当前标石路径下标石段信息 ---
-(void)getMarkStoneSegmentDate
{
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    
    //调用查询接口
    
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"10000\", \"resLogicName\":\"markStoneSegment\",ssmarkStoneP_Id:%@}",[self.markStonePath objectForKey:@"markStonePathId"]]};
    
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * url = [NSString stringWithFormat:@"%@rm!getCommonData.interface",BaseURL];
#else
    NSString * url = [NSString stringWithFormat:@"%@rm!getCommonData.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    [Http.shareInstance POST:url parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {


        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {

            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            _markStoneSegmentArray = [NSMutableArray arrayWithArray:arr];
            
            [self addOverlayView];
            [self addLineView];
        }else{
     
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];
            
        }
        
        [[Yuan_HUD shareInstance] HUDHide];

    }  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
                
        
    }];
}
//获取当前标石路径下默认添加的前100个标石的信息，方便标石路径地图初始化定位
-(void)getMarkStoneAndSegmentDate:(NSDictionary *)param isStart:(BOOL)isStart
{
    
    
    [self getMarkStoneDate];
    [self getMarkStoneSegmentDate];
    
    
    return;
    

}
//新建标石段线程
-(void)addMarkStoneSegDate
{
    NSLog(@"%@", markStoneSegInfoList);
    
    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
    for (int i = 0; i<resourceLocationArray.count; i++) {
        if (resourceLocationArray[i][@"doType"]!=nil) {
            [resourceLocationArray[i] removeObjectForKey:@"doType"];
        }
    }
    
    
    for (int i = 0; i<markStoneSegInfoList.count; i++) {
        NSMutableDictionary *markStoneSegInfo = markStoneSegInfoList[i];
        [markStoneSegInfo setObject:@"markStoneSegment" forKey:@"resLogicName"];
        [markStoneSegInfo setObject:[self.markStonePath objectForKey:@"markStonePathId"] forKey:@"ssmarkStoneP_Id"];
        // 2019年11月11日 新增：跟随标石路径信息。
                if (self.markStonePath[@"chanquanxz"] != nil){
                    markStoneSegInfo[@"chanquanxz"] = self.markStonePath[@"chanquanxz"];
                }
                
                if (self.markStonePath[@"prorertyBelong"] != nil){
                    markStoneSegInfo[@"prorertyBelong"] = self.markStonePath[@"prorertyBelong"];
                }
                
                // 2019年11月14日 新增：编号跟随名称
        //        markStoneSgNo  = markStoneSgName
                markStoneSegInfo[@"markStoneSgNo"] = markStoneSegInfo[@"markStoneSgName"];
        //去掉手机端为了方便判断自己添加的一些属性字段
        [markStoneSegInfoList[i] removeObjectForKey:@"qslat"];
        [markStoneSegInfoList[i] removeObjectForKey:@"qslon"];
        [markStoneSegInfoList[i] removeObjectForKey:@"qsmarkStoneP_Id"];
        [markStoneSegInfoList[i] removeObjectForKey:@"zzlat"];
        [markStoneSegInfoList[i] removeObjectForKey:@"zzlon"];
        [markStoneSegInfoList[i] removeObjectForKey:@"zzmarkStoneP_Id"];
    }
    //去掉重名标石段
    for (int i = 0; i<_markStoneSegmentArray.count; i++) {
        NSDictionary *markStoneSegment = _markStoneSegmentArray[i];
        for (int j = 0; j<markStoneSegInfoList.count; j++) {
            NSDictionary *temp = markStoneSegInfoList[j];
            if ([[markStoneSegment objectForKey:@"markStoneSgName"] isEqualToString:[temp objectForKey:@"markStoneSgName"]]) {
                [markStoneSegInfoList removeObjectAtIndex:j];
                j--;
            }
        }
    }
    //去掉可能会出现的只有起始没有终止资源的情况(最后一个资源)
    if (markStoneSegInfoList.count>0) {
        NSDictionary *lastMarkStoneSegDic = markStoneSegInfoList[markStoneSegInfoList.count-1];
        if ([lastMarkStoneSegDic objectForKey:@"startmarkStone_Id"]!=nil &&[lastMarkStoneSegDic objectForKey:@"endmarkStone_Id"]==nil ) {
            [markStoneSegInfoList removeObjectAtIndex:markStoneSegInfoList.count-1];
            if (markStoneSegInfoList.count == 0) {
               
                [YuanHUD HUDFullText:@"无需要关联的标石段"];
                
                isGuanlian = NO;
                [guanlianBtn setTitle:@"关联标石段" forState:UIControlStateNormal];
                markStoneSegInfoList = nil;
                [self addOverlayView];
                [self addLineView];
                return;
            }
        }
    }
    NSLog(@"------markStoneSegInfoList:%@",markStoneSegInfoList);
    if (markStoneSegInfoList.count == 0) {
        [YuanHUD HUDFullText:@"重复关联标石段"];
        
        isGuanlian = NO;
        [guanlianBtn setTitle:@"关联标石段" forState:UIControlStateNormal];
        markStoneSegInfoList = nil;
        [self addOverlayView];
        [self addLineView];
        return;
    }

    
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    NSString * request = @"[";
    
    
    
    
    for (NSDictionary * aaa in markStoneSegInfoList) {
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:aaa];
        
        [dict setValue:dict[@"markStoneSgName"] forKey:@"markStoneSgNo"];
        
        
        request = [request stringByAppendingString:[NSString stringWithFormat:@"%@,",DictToString(dict)]];
    }
    request = [request substringWithRange:NSMakeRange(0, request.length - 1)];
    request = [request stringByAppendingString:@"]"];
    
    NSLog(@"%@",request);
    
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":request};
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * url = [NSString stringWithFormat:@"%@%@",BaseURL,@"rm!insertCommonData.interface"];
#else
    NSString * url = [NSString stringWithFormat:@"%@%@",BaseURL_Auto(([IWPServerService sharedService].link)),@"rm!insertCommonData.interface"];
#endif
    
    [Http.shareInstance POST:url parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {


        NSDictionary *dic = responseObject;
        
        if([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
      
            [YuanHUD HUDFullText:@"关联操作成功"];
            //添加的数据告知标石段列表
            for (int i = 0; i<markStoneSegInfoList.count; i++) {
                [_markStoneSegmentArray addObject:markStoneSegInfoList[i]];
            }
            [guanlianBtn setTitle:@"关联标石段" forState:UIControlStateNormal];
            
            isGuanlian = NO;
            
            // 关联成功后 重新请求一遍数据
            [self getMarkStoneSegmentDate];
            
            
//            //关联成功，开始画线
//            [self addOverlayView];
//            [self addLineView];
            
        }else{
            [YuanHUD HUDFullText:@"操作失败，数据为空"];
        }
        
        [[Yuan_HUD shareInstance] HUDHide];

        
    }  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}
//todo:上传标石批量穿缆信息
-(void)updatePlMarkStoneCable:(NSMutableArray *) upList{
    NSString * request = @"[";
    for (NSDictionary * dict in upList) {
        request = [request stringByAppendingString:[NSString stringWithFormat:@"%@,",DictToString(dict)]];
    }
    request = [request substringWithRange:NSMakeRange(0, request.length - 1)];
    request = [request stringByAppendingString:@"]"];
    
    NSLog(@"%@",request);
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    
    //调用查询接口
    
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":request};
    
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * url = [NSString stringWithFormat:@"%@data!rm!updateCommonData.interface",BaseURL];
#else
    NSString * url = [NSString stringWithFormat:@"%@data!rm!updateCommonData.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    [Http.shareInstance POST:url parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {


        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
           
            
            for (int i = 0; i<markStoneArray.count; i++) {
                NSDictionary *markStone = markStoneArray[i];
                for (int j = 0; j<upList.count; j++) {
                    NSDictionary *temp = upList[j];
                    if ([[temp objectForKey:@"resLogicName"] isEqualToString:@"markStone"] && [[markStone objectForKey:@"GID"] isEqualToString:[temp objectForKey:@"GID"]]) {
                        [markStoneArray replaceObjectAtIndex:i withObject:temp];
                        break;
                    }
                }
            }
            for (int i = 0; i<resourceLocationArray.count; i++) {
                NSDictionary *resource = resourceLocationArray[i];
                for (int j = 0; j<upList.count; j++) {
                    NSDictionary *temp = upList[j];
                    if ([[temp objectForKey:@"resLogicName"] isEqualToString:@"markStone"] && [[resource objectForKey:@"GID"] isEqualToString:[temp objectForKey:@"GID"]]) {
                        [resourceLocationArray replaceObjectAtIndex:i withObject:temp];
                        break;
                    }
                }
            }
            isGLD = NO;
            cableTextView.text = @"";
            [guanlianCableBtn setTitle:@"关联光缆段" forState:UIControlStateNormal];
            [guanlianCableView setHidden:YES];
            markStoneCableInfoList = nil;
            upPlList = nil;
            [self addOverlayView];
            [self addLineView];
        }else{
          
            [YuanHUD HUDFullText:@"操作失败，数据为空"];
            
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
//上传标石穿缆信息
-(void)updateMarkStoneCable:(NSMutableArray *) upList{
    NSString * request = @"[";
    for (NSDictionary * dict in upList) {
        request = [request stringByAppendingString:[NSString stringWithFormat:@"%@,",DictToString(dict)]];
    }
    request = [request substringWithRange:NSMakeRange(0, request.length - 1)];
    request = [request stringByAppendingString:@"]"];
    
    NSLog(@"%@",request);
    
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    
    //调用查询接口
    
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":request};
    
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * url = [NSString stringWithFormat:@"%@data!rm!updateCommonData.interface",BaseURL];
#else
    NSString * url = [NSString stringWithFormat:@"%@data!rm!updateCommonData.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    
    [Http.shareInstance POST:url parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {

            
            for (int i = 0; i<markStoneArray.count; i++) {
                NSDictionary *markStone = markStoneArray[i];
                for (int j = 0; j<upList.count; j++) {
                    NSDictionary *temp = upList[j];
                    if ([[temp objectForKey:@"resLogicName"] isEqualToString:@"markStone"] && [[markStone objectForKey:@"GID"] isEqualToString:[temp objectForKey:@"GID"]]) {
                        [markStoneArray replaceObjectAtIndex:i withObject:temp];
                        break;
                    }
                }
            }
            for (int i = 0; i<resourceLocationArray.count; i++) {
                NSDictionary *resource = resourceLocationArray[i];
                for (int j = 0; j<upList.count; j++) {
                    NSDictionary *temp = upList[j];
                    if ([[temp objectForKey:@"resLogicName"] isEqualToString:@"markStone"] && [[resource objectForKey:@"GID"] isEqualToString:[temp objectForKey:@"GID"]]) {
                        [resourceLocationArray replaceObjectAtIndex:i withObject:temp];
                        break;
                    }
                }
            }
            isGLD = NO;
            cableTextView.text = @"";
            [guanlianCableBtn setTitle:@"关联光缆段" forState:UIControlStateNormal];
            [guanlianCableView setHidden:YES];
            markStoneCableInfoList = nil;
            [self addOverlayView];
            [self addLineView];
        }else{
        
            [YuanHUD HUDFullText:@"操作失败，数据为空"];
            
        }
        
        [[Yuan_HUD shareInstance] HUDHide];

    }  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}
#pragma mark tableviewdatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isPLCable) {
        return [plGuanlanCable count];
    }
    return [markStoneArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"identifier";
    UITableViewCell *cell=[markStoneTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (isPLCable) {
        cell.textLabel.text = [plGuanlanCable[indexPath.row] objectForKey:@"cableName"];
        cell.textLabel.textColor = [UIColor blackColor];
        
        // 当上下拉动的时候，因为cell的复用性，我们需要重新判断一下哪一行是打钩的
        if ([plGuanlanCableStateDic[plGuanlanCable[indexPath.row][@"cableId"]] isEqualToString:@"UITableViewCellAccessoryCheckmark"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.text = [markStoneArray[indexPath.row] objectForKey:@"markName"];
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingHead;//设置显示模式为省略开头
        
        
        
        if ([[markStoneArray[indexPath.row] valueForKey:@"deviceId"] integerValue] > 0) {
            cell.textLabel.textColor = [UIColor mainColor];
            
            UIImageView * accessoryView = [[UIImageView alloc] initWithImage:[UIImage Inc_imageNamed:@"offline_icon"]];
            
            accessoryView.frame = CGRectMake(0, 0, 24, 24);
            
            cell.accessoryView = accessoryView;
            
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.accessoryView = nil;
        }
    }
    
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingHead;//设置显示模式为省略开头
    cell.detailTextLabel.textColor = [UIColor grayColor];
    return cell;
}
//点击跳转到详细信息
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isPLCable) {
        //当前选择的打勾/去勾
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if ([plGuanlanCableStateDic[plGuanlanCable[indexPath.row][@"cableId"]] isEqualToString:@"UITableViewCellAccessoryCheckmark"]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [plGuanlanCableStateDic setObject:@"UITableViewCellAccessoryNone" forKey:plGuanlanCable[indexPath.row][@"cableId"]];
            for (int i = 0; i<plMarkStoneCableInfoList.count; i++) {
                NSDictionary *temp = plMarkStoneCableInfoList[i];
                if ([temp[@"cableId"] isEqualToString:plGuanlanCable[indexPath.row][@"cableId"]]) {
                    [plMarkStoneCableInfoList removeObjectAtIndex:i];
                    break;
                }
            }
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [plGuanlanCableStateDic setObject:@"UITableViewCellAccessoryCheckmark" forKey:plGuanlanCable[indexPath.row][@"cableId"]];
            [plMarkStoneCableInfoList addObject:plGuanlanCable[indexPath.row]];
        }
        return;
    }
    if (isGuanlian || isGLD) {
        [YuanHUD HUDFullText:@"请先退出关联操作"];
        return;
    }
    TYKDeviceInfoMationViewController * markStone = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_model withViewModel:_viewModel withDataDict:markStoneArray[indexPath.row] withFileName:@"markStone"];
    markStone.delegate = self;
    
    //暂时写死
    markStone.isOffline = NO;
    markStone.isSubDevice = markStone.isOffline;
    isAdd = NO;
    [self.navigationController pushViewController:markStone animated:YES];
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
    //
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
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
// Override
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    CusMAPointAnnotation *cusAnotation = (CusMAPointAnnotation *)annotation;
    if ([annotation isKindOfClass:[CusMAPointAnnotation class]]) {
        //设置覆盖物显示相关基本信息
        MAAnnotationView *annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        NSInteger tag = [annotation.subtitle intValue];
        //设置标注的图片
        NSDictionary * dict = resourceLocationArray[cusAnotation.tag-100000];
        
        NSString *doType = dict[@"doType"];
        
        if (selectIndex == tag) {
            if ([doType isEqualToString:@"isGuanlian"]) {
                //                annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse_new"];
                annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
            }else if ([doType isEqualToString:@"isGLD"]) {
                //                annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse_new"];
                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_tyk_nnew_gl"];
            }else{
                //                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_click_1"];
                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
            }
            //在大头针上绘制文字
            if ([dict[@"resLogicName"] isEqualToString:@"markStone"]){
                UILabel *lable=[strUtil makeAnnotationViewLabel:dict[@"markName"] :nil :@"":NO];
                
                if ([lable.text isEqualToString:@"无序号"]) {
                    lable.text = @"";
                }
                
                if ([[dict valueForKey:@"deviceId"] integerValue] > 0) {
                    // 离线设备
                    lable.textColor = [UIColor mainColor];
                    lable.font = [UIFont boldSystemFontOfSize:13.f];
                }
                [annotationView addSubview:lable];
            }
        }else if ([dict[@"resLogicName"] isEqualToString:@"markStone"]){
            if ([doType isEqualToString:@"isGuanlian"]) {
                //                annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse_new"];
                annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
            }else if ([doType isEqualToString:@"isGLD"]) {
                //                annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse_new"];
                annotationView.image = [UIImage Inc_imageNamed:@"icon_biaoshi_cable"];
            }else{
                //                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi"];
                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_tyk_nnew"];
#pragma warning iconfix
                if (dict[@"hasJoint"]!=nil &&([dict[@"hasJoint"] intValue] == 1)) {
                    annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_joint_tyk"];
                }
            }
            //在大头针上绘制文字
            UILabel *lable=[strUtil makeAnnotationViewLabel:dict[@"markName"] :nil :@"":NO];
            
            if ([lable.text isEqualToString:@"无序号"]) {
                lable.text = @"";
            }
            
            if ([[dict valueForKey:@"deviceId"] integerValue] > 0) {
                // 离线设备
                lable.textColor = [UIColor mainColor];
                lable.font = [UIFont boldSystemFontOfSize:13.f];
            }
            [annotationView addSubview:lable];
        }
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height*0.5));
        annotationView.draggable = YES;
        
        //        CGRect viewFrame = annotationView.frame;
        //        viewFrame.size.width = 30.f;
        //        viewFrame.size.height = 30.f;
        //        annotationView.frame = viewFrame;
        
        return annotationView;
        
    }
    return nil;
}
//当选中一个annotation views时，调用此接口
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    CusMAPointAnnotation *cusAnotation = (CusMAPointAnnotation *)view.annotation;
    if ([view.annotation isKindOfClass:[CusMAPointAnnotation class]]) {
        NSMutableDictionary * resourceDic = [[NSMutableDictionary alloc] initWithDictionary:resourceLocationArray[cusAnotation.tag-100000]];
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
        if (isGuanlian) {
            
            
            IWPPropertiesSourceModel * model = [[IWPPropertiesReader alloc] initWithFileName:resourceDic[kResLogicName] withFileDirectoryType:IWPPropertiesReadDirectoryDocuments].mainModel;
            
            if (resourceDic[model.list_sreach_name] == nil) {
                
                NSString * message = [NSString stringWithFormat:@"当前选择%@名称为空，无法进行关联。", model.name];
                
                AlertShow(self.view, @"无法选择", 2.f, (message));
                
                
                [mapView deselectAnnotation:cusAnotation animated:true];
                
                return;
            }
            
            
            //关联标石段模式
            if ([[resourceDic valueForKey:@"deviceId"] integerValue] > 0) {
                AlertShow([UIApplication sharedApplication].keyWindow, @"离线资源无法参与关联", 2.f, @"");
                return;
            }
            
            //再次点击去除当前批量关联标石段下末个资源
            NSString *clickResType = resourceDic[@"resLogicName"];
            NSString *clickResId;
            if ([clickResType isEqualToString:@"markStone"]) {
                clickResId = [resourceDic objectForKey:@"GID"];
            }
            if (markStoneSegInfoList.count>0) {
                NSMutableDictionary *lastMarkStoneSeg = markStoneSegInfoList[markStoneSegInfoList.count-1];
                NSLog(@"lastMarkStoneSeg%@",lastMarkStoneSeg);
                if ([lastMarkStoneSeg objectForKey:@"startmarkStone_Id"]!=nil &&([lastMarkStoneSeg objectForKey:@"endmarkStone_Id"]==nil) &&([lastMarkStoneSeg[@"startmarkStone_Id"] isEqualToString:clickResId])) {
                    //上一个标石段有起始但是无终止,最后一个点击的是起始资源
                    if ([resourceDic[@"resLogicName"] isEqualToString:@"markStone"]) {
                        //                        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi"];
                        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_tyk_nnew"];
#pragma warning iconfix
                        if (resourceDic[@"hasJoint"]!=nil &&([resourceDic[@"hasJoint"] intValue] == 1)) {
                            view.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_joint_tyk"];
                        }
                    }
                    [markStoneSegInfoList removeObject:lastMarkStoneSeg];
                    //当前标石段个数大于0，则说明这个起始标石也是上一段标石段的终止标石，需要将对应的终止标石也remove掉
                    if (markStoneSegInfoList.count>0) {
                        NSInteger index = markStoneSegInfoList.count-1;
                        [markStoneSegInfoList[index] removeObjectForKey:@"endmarkStone_Id"];
                        [markStoneSegInfoList[index] removeObjectForKey:@"endmarkStone"];
                        NSString *markStoneSegName = [NSString stringWithFormat:@"%@（%@_",[self.markStonePath objectForKey:@"markStonePName"],[markStoneSegInfoList[index] objectForKey:@"startmarkStone"]];
                        [markStoneSegInfoList[index] setObject:markStoneSegName forKey:@"markStoneSgName"];
                        [markStoneSegInfoList[index] removeObjectForKey:@"markStoneSgLength"];
                        [markStoneSegInfoList[index] removeObjectForKey:@"zzlat"];
                        [markStoneSegInfoList[index] removeObjectForKey:@"zzlon"];
                    }
                    [_mapView deselectAnnotation:view.annotation animated:YES];
                    [self overloadMarks];
                    
                    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
                    if (resourceLocationArray[cusAnotation.tag-100000][@"doType"]!=nil) {
                        [resourceLocationArray[cusAnotation.tag-100000] removeObjectForKey:@"doType"];
                    }
                    
                    return;
                }else if ([lastMarkStoneSeg objectForKey:@"startmarkStone_Id"]!=nil &&([lastMarkStoneSeg objectForKey:@"endmarkStone_Id"]!=nil) &&([lastMarkStoneSeg[@"endmarkStone_Id"] isEqualToString:clickResId])) {
                    //上一个标石段有起始且有终止,最后一个点击的是终止资源
                    if ([resourceDic[@"resLogicName"] isEqualToString:@"markStone"]) {
                        //                        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi"];
                        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_tyk_nnew"];
#pragma warning iconfix
                        if (resourceDic[@"hasJoint"]!=nil &&([resourceDic[@"hasJoint"] intValue] == 1)) {
                            view.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_joint_tyk"];
                        }
                    }
                    
                    [lastMarkStoneSeg removeObjectForKey:@"endmarkStone_Id"];
                    [lastMarkStoneSeg removeObjectForKey:@"endmarkStone"];
                    NSString *markStoneSegName = [NSString stringWithFormat:@"%@（%@_",[self.markStonePath objectForKey:@"markStonePName"],[lastMarkStoneSeg objectForKey:@"startmarkStone"]];
                    [lastMarkStoneSeg setObject:markStoneSegName forKey:@"markStoneSgName"];
                    [lastMarkStoneSeg removeObjectForKey:@"markStoneSgLength"];
                    [lastMarkStoneSeg removeObjectForKey:@"zzlat"];
                    [lastMarkStoneSeg removeObjectForKey:@"zzlon"];
                    [_mapView deselectAnnotation:view.annotation animated:YES];
                    [self overloadMarks];
                    
                    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
                    if (resourceLocationArray[cusAnotation.tag-100000][@"doType"]!=nil) {
                        [resourceLocationArray[cusAnotation.tag-100000] removeObjectForKey:@"doType"];
                    }
                    
                    return;
                }
            }
            
            //当点了虚拟标石段列表里已经有了的资源后，再点不做响应
            if (markStoneSegInfoList.count>0) {
                for (int i = 0; i<markStoneSegInfoList.count; i++) {
                    NSDictionary *markStoneSeg = markStoneSegInfoList[i];
                    if (([resourceDic[@"resLogicName"] isEqualToString:@"markStone"])&&[resourceDic[@"GID"] isEqualToString:markStoneSeg[@"startmarkStone_Id"]]) {
                        NSLog(@"起始相同");
                        return;
                    }
                    if (([resourceDic[@"resLogicName"] isEqualToString:@"markStone"])&&[resourceDic[@"GID"] isEqualToString:markStoneSeg[@"endmarkStone_Id"]]) {
                        NSLog(@"终止相同");
                        return;
                    }
                }
            }
            //判断所选择的两个标石是否都不在当前标石路径下，如果不是，不能让用户进行关联操作 2017.03.31日新增
            if ([resourceDic[@"resLogicName"] isEqualToString:@"markStone"] && (markStoneSegInfoList.count>0)) {
                NSDictionary *lastMarkStoneSeg = markStoneSegInfoList[markStoneSegInfoList.count-1];
                BOOL isCanGuanlian = YES;
                if ([lastMarkStoneSeg objectForKey:@"startmarkStone_Id"]!=nil &&([lastMarkStoneSeg objectForKey:@"endmarkStone_Id"]==nil)) {
                    //上一个标石段有起始但是无终止并且起始为标石时，进入到是否为两个附近标石进行关联操作判断
//                    if (![lastMarkStoneSeg[@"qsmarkStoneP_Id"] isEqualToString:self.markStonePath[@"unicomMarkStonePathId"]] && ![resourceDic[@"ssmarkStoneP_Id"] isEqualToString:self.markStonePath[@"unicomMarkStonePathId"]]) {
//                        isCanGuanlian = NO;
//                    }
                }else if ([lastMarkStoneSeg objectForKey:@"startmarkStone_Id"]!=nil &&([lastMarkStoneSeg objectForKey:@"endmarkStone_Id"]!=nil)){
                    //上一个标石段既有起始也有终止并且终止为标石时，进入到是否为两个附近标石进行关联操作判断
//                    if (![lastMarkStoneSeg[@"zzmarkStoneP_Id"] isEqualToString:self.markStonePath[@"unicomMarkStonePathId"]] && ![resourceDic[@"ssmarkStoneP_Id"] isEqualToString:self.markStonePath[@"unicomMarkStonePathId"]]) {
//                        isCanGuanlian = NO;
//                    }
                }
                if (!isCanGuanlian) {
                 
                    
                    [YuanHUD HUDFullText:@"当前关联的两个标石都不在此标石路径下!"];

                    [_mapView deselectAnnotation:view.annotation animated:YES];
                    return;
                }
                
            }
            //            view.image = [UIImage Inc_imageNamed:@"iconmarka_bianse_new"];
            view.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
            NSMutableDictionary *markStoneSegInfo;//当前待关联的标石段
            
            if (markStoneSegInfoList.count>0) {
                NSDictionary *lastMarkStoneSeg = markStoneSegInfoList[markStoneSegInfoList.count-1];
                
                if ([lastMarkStoneSeg objectForKey:@"startmarkStone_Id"]!=nil &&([lastMarkStoneSeg objectForKey:@"endmarkStone_Id"]==nil)) {
                    //上一个标石段有起始但是无终止
                    markStoneSegInfo = [[NSMutableDictionary alloc] initWithDictionary:markStoneSegInfoList[markStoneSegInfoList.count-1]];
                    if ([resourceDic[@"resLogicName"] isEqualToString:@"markStone"]) {
                        [markStoneSegInfo setObject:[resourceDic objectForKey:@"GID"] forKey:@"endmarkStone_Id"];
                        [markStoneSegInfo setObject:[resourceDic objectForKey:@"markName"] forKey:@"endmarkStone"];
                        NSString *markStoneSegName = [NSString stringWithFormat:@"%@%@）",[markStoneSegInfo objectForKey:@"markStoneSgName"],[resourceDic objectForKey:@"markName"]];
                        [markStoneSegInfo setObject:markStoneSegName forKey:@"markStoneSgName"];
                    }
                    [markStoneSegInfo setObject:[resourceDic objectForKey:@"lat"] forKey:@"zzlat"];
                    [markStoneSegInfo setObject:[resourceDic objectForKey:@"lon"] forKey:@"zzlon"];
                    if ([resourceDic objectForKey:@"ssmarkStoneP_Id"]!=nil) {
                        [markStoneSegInfo setObject:[resourceDic objectForKey:@"ssmarkStoneP_Id"] forKey:@"zzmarkStoneP_Id"];
                    }
                    markStoneSegInfoList[markStoneSegInfoList.count-1] = markStoneSegInfo;
                }else if ([lastMarkStoneSeg objectForKey:@"startmarkStone_Id"]!=nil &&([lastMarkStoneSeg objectForKey:@"endmarkStone_Id"]!=nil)){
                    //上一个标石段既有起始也有终止，此次点击需要将上一个标石段的终止设为当前起始，且此次点击的资源设为终止
                    markStoneSegInfo = [[NSMutableDictionary alloc] init];
                    [markStoneSegInfo setObject:[lastMarkStoneSeg objectForKey:@"endmarkStone_Id"] forKey:@"startmarkStone_Id"];
                    [markStoneSegInfo setObject:[lastMarkStoneSeg objectForKey:@"endmarkStone"] forKey:@"startmarkStone"];
                    NSString *markStoneSegName = [NSString stringWithFormat:@"（%@_",[lastMarkStoneSeg objectForKey:@"endmarkStone"]];
                    [markStoneSegInfo setObject:markStoneSegName forKey:@"markStoneSgName"];
                    [markStoneSegInfo setObject:[lastMarkStoneSeg objectForKey:@"zzlat"] forKey:@"qslat"];
                    [markStoneSegInfo setObject:[lastMarkStoneSeg objectForKey:@"zzlon"] forKey:@"qslon"];
                    if ([lastMarkStoneSeg objectForKey:@"zzmarkStoneP_Id"]!=nil) {
                        [markStoneSegInfo setObject:[lastMarkStoneSeg objectForKey:@"zzmarkStoneP_Id"] forKey:@"qsmarkStoneP_Id"];
                    }
                    
                    if ([resourceDic[@"resLogicName"] isEqualToString:@"markStone"]) {
                        [markStoneSegInfo setObject:[resourceDic objectForKey:@"GID"] forKey:@"endmarkStone_Id"];
                        [markStoneSegInfo setObject:[resourceDic objectForKey:@"markName"] forKey:@"endmarkStone"];
                        markStoneSegName = [NSString stringWithFormat:@"%@%@）",[markStoneSegInfo objectForKey:@"markStoneSgName"],[resourceDic objectForKey:@"markName"]];
                        [markStoneSegInfo setObject:markStoneSegName forKey:@"markStoneSgName"];
                    }
                    [markStoneSegInfo setObject:[resourceDic objectForKey:@"lat"] forKey:@"zzlat"];
                    [markStoneSegInfo setObject:[resourceDic objectForKey:@"lon"] forKey:@"zzlon"];
                    if ([resourceDic objectForKey:@"ssmarkStoneP_Id"]!=nil) {
                        [markStoneSegInfo setObject:[resourceDic objectForKey:@"ssmarkStoneP_Id"] forKey:@"zzmarkStoneP_Id"];
                    }
                    
                    [markStoneSegInfoList addObject:markStoneSegInfo];
                }
            }else{
                //进行关联标石段的首个资源
                markStoneSegInfo = [[NSMutableDictionary alloc] init];
                if ([resourceDic[@"resLogicName"] isEqualToString:@"markStone"]) {
                    [markStoneSegInfo setObject:[resourceDic objectForKey:@"GID"] forKey:@"startmarkStone_Id"];
                    [markStoneSegInfo setObject:[resourceDic objectForKey:@"markName"] forKey:@"startmarkStone"];
                    NSString *markStoneSegName = [NSString stringWithFormat:@"（%@_",[resourceDic objectForKey:@"markName"]];
                    [markStoneSegInfo setObject:markStoneSegName forKey:@"markStoneSgName"];
                }
                [markStoneSegInfo setObject:[resourceDic objectForKey:@"lat"] forKey:@"qslat"];
                [markStoneSegInfo setObject:[resourceDic objectForKey:@"lon"] forKey:@"qslon"];
                if ([resourceDic objectForKey:@"ssmarkStoneP_Id"]!=nil) {
                    [markStoneSegInfo setObject:[resourceDic objectForKey:@"ssmarkStoneP_Id"] forKey:@"qsmarkStoneP_Id"];
                }
                
                [markStoneSegInfoList addObject:markStoneSegInfo];
            }
            NSLog(@"markStoneSegInfoList:%@",markStoneSegInfoList);
            
            
            //添加自定义属性，规避高德地图回调重加在问题
            resourceLocationArray[cusAnotation.tag-100000] = [[NSMutableDictionary alloc] initWithDictionary:resourceDic];
            [resourceLocationArray[cusAnotation.tag-100000] setObject:@"isGuanlian" forKey:@"doType"];
            
            
            
            
            
            double qslat = [markStoneSegInfo[@"qslat"] doubleValue];
            double qslon = [markStoneSegInfo[@"qslon"] doubleValue];
            double zzlat = [markStoneSegInfo[@"zzlat"] doubleValue];
            double zzlon = [markStoneSegInfo[@"zzlon"] doubleValue];
            //计算标石段长度
            NSLog(@"qslat:%f,qslon:%f,zzlat:%f,zzlon:%f",qslat,qslon,zzlat,zzlon);
            if (qslat!=0.000000&&qslon!=0.000000&&zzlat!=0.000000&&zzlon!=0.000000) {
                float markStoneSegmentLength = [self markStoneSegmentLengthWithLat1:qslat Lon1:qslon Lat2:zzlat Lon2:zzlon];
                [markStoneSegInfo setObject:[NSString stringWithFormat:@"%f",markStoneSegmentLength] forKey:@"markStoneSgLength"];
                if (self.markStonePath[@"retion"]!=nil) {
                    [markStoneSegInfo setObject:self.markStonePath[@"retion"] forKey:@"retion"];
                }
                if (self.markStonePath[@"areaname"]!=nil) {
                    [markStoneSegInfo setObject:self.markStonePath[@"areaname"] forKey:@"areaname"];
                }
                if (self.markStonePath[@"areaname_Id"]!=nil) {
                    [markStoneSegInfo setObject:self.markStonePath[@"areaname_Id"] forKey:@"areaname_Id"];
                }
                
                [self addTempLineView];
                
                NSLog(@"%@", _taskId);
                
                if (_taskId != nil) {
                    [markStoneSegInfo setObject:_taskId forKey:@"taskId"];
                }else if ([markStonePath[@"taskId"] length] > 0 && !_taskId){
                    [markStoneSegInfo setObject:markStonePath[@"taskId"] forKey:@"taskId"];
                }
                
                
                NSLog(@"…………………………%@",markStoneSegInfoList);
            }
            //取消当前大头针的点击事件，方便用户再次点击时撤销关联标石段操作
            [_mapView deselectAnnotation:view.annotation animated:YES];
        }else if (isGLD){
            //关联光缆段模式
            if (isPLCable&&(plMarkStoneCableInfoList == nil || plMarkStoneCableInfoList.count == 0)) {
                [YuanHUD HUDFullText:@"请选择待穿的缆段"];
                //取消当前大头针的点击事件，方便用户再次点击时撤销关联标石段操作
                [_mapView deselectAnnotation:view.annotation animated:YES];
                return;
            }
            //如果当前点击的资源已经穿了缆，则需要判断当前选择的缆是否已经在当前资源下。
            if (resourceDic[@"bearCableSegmentId"]!=nil) {
                NSString *bearCableTemp = [resourceDic objectForKey:@"bearCableSegmentId"];
                if (bearCableTemp!=nil &&[bearCableTemp containsString:@","]) {
                    NSArray *temp = [bearCableTemp componentsSeparatedByString:@","];
                    if (isPLCable) {
                        NSMutableArray *hadCableListArr = [[NSMutableArray alloc] init];//重复穿缆列表，用户显示提示用户
                        for (int i = 0; i<temp.count; i++) {
                            for (NSDictionary *markStoneTempDic in plMarkStoneCableInfoList) {
                                if ([temp[i] isEqualToString:[markStoneTempDic objectForKey:@"cableId"]]) {
                                    [hadCableListArr addObject:markStoneTempDic[@"cableName"]];
                                }
                            }
                        }
                        if (hadCableListArr.count>0) {
                            NSString *resourceTypeStr = @"标石";
                            NSMutableString *messageStr = [[NSMutableString alloc] init];
                            for (NSString *name in hadCableListArr) {
                                [messageStr appendFormat:@"%@\n",name];
                            }
                            UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"该%@已关联了如下光缆",resourceTypeStr] message:messageStr preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction * sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
                            [alert addAction:sure];
                            
                            Present(self, alert);
                            //取消当前大头针的点击事件，方便用户再次点击时撤销关联标石段操作
                            [_mapView deselectAnnotation:view.annotation animated:YES];
                            return;
                        }
                    }else{
                        for (int i = 0; i<temp.count; i++) {
                            if ([temp[i] isEqualToString:[markStoneCableInfo objectForKey:@"cableId"]]) {
                             
                                
                                [YuanHUD HUDFullText:@"该标石已经关联了该光缆"];

                                //取消当前大头针的点击事件，方便用户再次点击时撤销关联标石段操作
                                [_mapView deselectAnnotation:view.annotation animated:YES];
                                return;
                            }
                        }
                    }
                }
            }
            BOOL isHave = NO;
            for (int i = 0; i<markStoneCableInfoList.count; i++) {
                if ([resourceDic[@"resLogicName"] isEqualToString:@"markStone"] && [[markStoneCableInfoList[i] objectForKey:@"GID"] isEqualToString:[resourceDic objectForKey:@"GID"]]) {
                    isHave = YES;
                    [markStoneCableInfoList removeObjectAtIndex:i];
                    
                    for (int j = 0; j<upPlList.count; j++) {
                        if ([[upPlList[j] objectForKey:@"GID"] isEqualToString:[resourceDic objectForKey:@"GID"]]) {
                            [upPlList removeObjectAtIndex:j];
                            break;
                        }
                    }
                    //                    view.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi"];
                    view.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_tyk_nnew"];
                    
#pragma warning iconfix
                    if (resourceLocationArray[cusAnotation.tag-100000][@"hasJoint"]!=nil &&([resourceLocationArray[cusAnotation.tag-100000][@"hasJoint"] intValue] == 1)) {
                        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_joint_tyk"];
                    }
                    
                    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
                    if (resourceLocationArray[cusAnotation.tag-100000][@"doType"]!=nil) {
                        [resourceLocationArray[cusAnotation.tag-100000] removeObjectForKey:@"doType"];
                    }
                    
                    break;
                }
            }
            if (!isHave) {
                [markStoneCableInfoList addObject:resourceDic];
                if ([resourceDic[@"resLogicName"] isEqualToString:@"markStone"]) {
                    //                    view.image = [UIImage Inc_imageNamed:@"iconmarka_bianse_new"];
                    view.image = [UIImage Inc_imageNamed:@"icon_biaoshi_cable"];
                    //添加自定义属性，规避高德地图回调重加在问题
                    resourceLocationArray[cusAnotation.tag-100000] = [[NSMutableDictionary alloc] initWithDictionary:resourceDic];
                    [resourceLocationArray[cusAnotation.tag-100000] setObject:@"isGLD" forKey:@"doType"];
                }
                if (isPLCable) {
                    if (upPlList == nil) {
                        upPlList = [[NSMutableArray alloc] init];
                    }
                    //todo:发送报文方式需要和中心定,目前还按照原来
                    for (NSDictionary *tempDic in plMarkStoneCableInfoList) {
                        if ([resourceDic objectForKey:@"bearCableSegment"]!=nil) {
                            NSString *object = [NSString stringWithFormat:@"%@%@,",[resourceDic objectForKey:@"bearCableSegment"],[tempDic objectForKey:@"cableName"]];
                            [resourceDic setObject:object forKey:@"bearCableSegment"];
                        }else{
                            [resourceDic setObject:[NSString stringWithFormat:@"%@,",[tempDic objectForKey:@"cableName"]] forKey:@"bearCableSegment"];
                        }
                        if ([resourceDic objectForKey:@"bearCableSegmentId"]!=nil) {
                            NSString *object = [NSString stringWithFormat:@"%@%@,",[resourceDic objectForKey:@"bearCableSegmentId"],[tempDic objectForKey:@"cableId"]];
                            [resourceDic setObject:object forKey:@"bearCableSegmentId"];
                        }else{
                            [resourceDic setObject:[NSString stringWithFormat:@"%@,",[tempDic objectForKey:@"cableId"]] forKey:@"bearCableSegmentId"];
                        }
                        if ([resourceDic objectForKey:@"bearCableSegmentRFID"]!=nil) {
                            NSString *object = [NSString stringWithFormat:@"%@ ,",[resourceDic objectForKey:@"bearCableSegmentRFID"]];
                            [resourceDic setObject:object forKey:@"bearCableSegmentRFID"];
                        }else{
                            [resourceDic setObject:@" ," forKey:@"bearCableSegmentRFID"];
                        }
                        if (![upPlList containsObject:resourceDic]) {
                            [upPlList addObject:resourceDic];
                        }
                    }
                    
                }
            }
            //取消当前大头针的点击事件，方便用户再次点击时撤销关联标石段操作
            [_mapView deselectAnnotation:view.annotation animated:YES];
        }else{
            //查看所选资源的详细信息
            //            获取地图的所有标注点 同时获取标注点的标注view
            for (CusMAPointAnnotation *cmpa in [mapView annotations]) {
                MAAnnotationView * maav = [_mapView viewForAnnotation:cmpa];
                if ([maav isKindOfClass:[MAPointAnnotation class]]) {
                    NSDictionary * dict = resourceLocationArray[maav.tag-100000];
                    if ([dict[@"resLogicName"] isEqualToString:@"markStone"]) {
                        //                        maav.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi"];
                        maav.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_tyk_nnew"];
#pragma warning iconfix
                        if (dict[@"hasJoint"]!=nil &&([dict[@"hasJoint"] intValue] == 1)) {
                            maav.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_joint_tyk"];
                        }
                    }
                    
                }
            }
            //            view.image = [UIImage Inc_imageNamed:@"icon_gcoding_click_1"];
            view.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
            
            // 设置当前地图的中心点 把选中的标注作为地图中心点
            [_mapView setCenterCoordinate:view.annotation.coordinate animated:YES] ;
            selectIndex = [view.annotation.subtitle intValue];
            
            //跳转到详细信息界面
            if ([resourceDic[@"resLogicName"] isEqualToString:@"markStone"]) {
                TYKDeviceInfoMationViewController * markStone = [[TYKDeviceInfoMationViewController alloc] initWithControlMode:TYKDeviceListUpdateRfid withMainModel:_model withViewModel:_viewModel withDataDict:resourceDic withFileName:@"markStone"];
                markStone.delegate = self;
                //暂时写死
                markStone.isOffline = NO;
                markStone.isSubDevice = markStone.isOffline;
                isAdd = NO;
                [self.navigationController pushViewController:markStone animated:YES];
            }
        }
        //
        //        CGRect viewFrame = view.frame;
        //        viewFrame.size.width = 30.f;
        //        viewFrame.size.height = 30.f;
        //        view.frame = viewFrame;
        //
        [_mapView selectAnnotation:nil animated:NO];
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
#pragma mark locationManager成员方法
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    //每次要重置view的位置，才能保证图片每次偏转量正常，而不是叠加，指针方向正确。
    arrowImageView.transform = CGAffineTransformIdentity;
    CGAffineTransform transform = CGAffineTransformMakeRotation(-1 * M_PI*newHeading.magneticHeading/180.0);
    
    arrowImageView.transform = transform;
}
//批量关联光缆段功能所选择的光缆段
-(void)getCable:(NSDictionary *)cable{
    isGLD = YES;
    //批量关联光缆段，选择光缆段后返回
    //显示光缆段名称 进入光缆段关联模式 关联光缆段按钮变成确认
    markStoneCableInfo = cable;
    cableTextView.text = [markStoneCableInfo objectForKey:@"cableName"];
    [guanlianCableBtn setTitle:@"确认" forState:UIControlStateNormal];
    [guanlianCableView setHidden:NO];
    markStoneCableInfoList = [[NSMutableArray alloc] init];
    if (isPLCable) {
        if (plGuanlanCableStateDic == nil) {
            plGuanlanCableStateDic = [[NSMutableDictionary alloc] init];
        }
        if (plGuanlanCable == nil) {
            plGuanlanCable = [[NSMutableArray alloc] init];
        }
        if (plMarkStoneCableInfoList == nil) {
            plMarkStoneCableInfoList = [[NSMutableArray alloc] init];//这个是实际要关联的一个数据列表
        }
        //要做个去重，如果界面上有就不显示
        if ([cable[@"isHavePl"] isEqualToString:@"true"]) {
            for (NSDictionary *cableDic in cable[@"cableArr"]) {
                BOOL isHave = NO;
                for (NSDictionary *dicTemp in plGuanlanCable) {
                    if ([dicTemp[@"cableId"] isEqualToString:cableDic[@"cableId"]]) {
                        //存在相同的，跳过
                        isHave = YES;
                        break;
                    }
                }
                if (!isHave) {
                    [plGuanlanCable addObject:cableDic];
                    [plGuanlanCableStateDic setValue: @"UITableViewCellAccessoryCheckmark" forKey:cableDic[@"cableId"]];
                    [plMarkStoneCableInfoList addObject:cableDic];
                }
            }
        }else{
            BOOL isHave = NO;
            for (NSDictionary *dicTemp in plGuanlanCable) {
                if ([dicTemp[@"cableId"] isEqualToString:cable[@"cableId"]]) {
                    //存在相同的，跳过
                    isHave = YES;
                    break;
                }
            }
            if (!isHave) {
                [plGuanlanCable addObject:cable];
                [plGuanlanCableStateDic setValue: @"UITableViewCellAccessoryCheckmark" forKey:cable[@"cableId"]];
                [plMarkStoneCableInfoList addObject:cable];
            }
        }
        [self.markStoneTableView reloadData];
    }
}
-(void)newMarkStoneWithDict:(NSDictionary *)dict{
    
    NSLog(@" ==== = == ===== == == ===== == =%@",dict);
    
    if (isAdd) {
        //新添加的标石一定在当前标石路径下，因此需要刷新当前标石路径下标石列表
        [self.markStoneArray addObject:dict];
        [self.markStoneTableView reloadData];
        //新添加的标石一定有经纬度，因此需要刷新地图数据
        [self.resourceLocationArray addObject:dict];
        //标记值恢复初始
        selectIndex = 1000000;
        isAdd = NO;
        [self addOverlayView];
        [self addLineView];
    }else{
        //在线情况下
        //1.循环当前标石路径下标石列表
        for (int i = 0; i<markStoneArray.count; i++) {
            if ([markStoneArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
                [markStoneArray replaceObjectAtIndex:i withObject:dict];
                break;
            }
        }
        [self.markStoneTableView reloadData];
        //2.循环地图上显示的资源列表，如果为标石类型时，判断修改的是哪个标石
        for (int i = 0; i<resourceLocationArray.count; i++) {
            if ([resourceLocationArray[i][@"resLogicName"] isEqualToString:@"markStone"] && [resourceLocationArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
                [resourceLocationArray replaceObjectAtIndex:i withObject:dict];
                break;
            }
        }
    }
}
-(void)deleteMarkStone:(NSDictionary *)dict class:(Class)class{
    selectIndex = 1000000;
    //在线情况下

    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    [Http.shareInstance POST:[NSString stringWithFormat:@"%@/rm!deleteCommonData.interface", BaseURL_Auto(([IWPServerService sharedService].link))] parameters:@{@"UID":UserModel.uid, @"jsonRequest":DictToString(dict)} success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                

        NSError * error = nil;
        NSDictionary * result = responseObject;
        
        if (error == nil) {
            if ([result[@"result"] integerValue] == 0) {
                
                
                //1.循环当前标石路径下标石列表
                for (int i = 0; i<markStoneArray.count; i++) {
                    if ([markStoneArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
                        [markStoneArray removeObjectAtIndex:i];
                        break;
                    }
                }
                [self.markStoneTableView reloadData];
                //2.循环地图上显示的资源列表，如果为标石类型时，判断删除的是哪个标石
                for (int i = 0; i<resourceLocationArray.count; i++) {
                    if ([resourceLocationArray[i][@"resLogicName"] isEqualToString:@"markStone"] && [resourceLocationArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
                        [resourceLocationArray removeObjectAtIndex:i];
                        break;
                    }
                }
                

                
                [self.navigationController popViewControllerAnimated:true];
            }else{
                
                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@", result[@"info"]]];
                
            }
        }else{
            
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@", error.localizedDescription]];

            
        }
        

        [[Yuan_HUD shareInstance] HUDHide];

        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        });
        
    }];
    
    
//    if ([dict[@"isOnlineSubdevice"] isEqualToNumber:@1]) {
//        if (class != self.class) {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    }else{
//        if ([self.delegate respondsToSelector:@selector(deleteMarkStoneWithDict:withClass:)]) {
//            [self.delegate deleteMarkStoneWithDict:dict withClass:class];
//        }
//    }
}

-(void)deleteDeviceWithDict:(NSDictionary *)dict withViewControllerClass:(__unsafe_unretained Class)vcClass{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确定要删除该%@?",@"标石"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self deleteMarkStone:dict class:vcClass];
        
    }];
    UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        return;
    }];
    
    [alert addAction:actionYES];
    [alert addAction:actionNO];
    Present(self, alert);
}
-(void)newDeciceWithDict:(NSDictionary<NSString *,NSString *> *)dict{
    NSLog(@"+++++++++++%@",dict);
    
    [self.navigationController popViewControllerAnimated:true];
    [self newMarkStoneWithDict:dict];
}
-(void)didReciveANewOnlineToOfflineSubDevice:(NSDictionary *)dict isAdd:(BOOL)isAdd{
    // 获取到在线设备加入的离线设备
    [self newMarkStoneWithDict:dict];
}
-(void)viewWillAppear:(BOOL)animated
{
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
    _search.delegate = self;
    
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
    [self addOverlayView];
    [self addLineView];
    [super viewDidAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
