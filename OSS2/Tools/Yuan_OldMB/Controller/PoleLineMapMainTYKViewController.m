//
//  PoleLineMapMainTYKViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/10/9.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "PoleLineMapMainTYKViewController.h"

#import "CusButton.h"
#import "MBProgressHUD.h"

#import "StrUtil.h"
#import "CusMAPointAnnotation.h"
#import "CusMAPolyline.h"
#import "TYKDeviceInfoMationViewController.h"
#import "IWPPropertiesReader.h"
//#import "CableSelectResultViewController.h"
#import "IWPCleanCache.h"

@interface PoleLineMapMainTYKViewController ()<TYKDeviceInfomationDelegate>
@property (strong, nonatomic) NSMutableArray * polelineSegmentArray;//获取到的杆路段信息列表
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSMutableArray * poleArray;//获取到的当前杆路下电杆信息列表
@property (strong,nonatomic) NSMutableArray *resourceLocationArray;//获取到的所有含有经纬度的资源列表，用于显示在地图上
@property (strong,nonatomic)UITableView *poleTableView;
@property (nonatomic, strong) IWPPropertiesReader * poleReader;
@property (nonatomic, strong) IWPPropertiesSourceModel * poleModel;
@property (nonatomic, strong) NSArray <IWPViewModel *>* poleViewModel;
@property (nonatomic, strong) IWPPropertiesReader * spReader;
@property (nonatomic, strong) IWPPropertiesSourceModel * spModel;
@property (nonatomic, strong) NSArray <IWPViewModel *>* spViewModel;
@property (nonatomic,assign) long selectResourceIndex;//当前点击的覆盖物
@property (nonatomic, strong) NSTimer * timer; // 反地理编码超时计时器
@property (nonatomic, assign) BOOL isAutoSetAddr;//是否开启自动填入地址
@property (nonatomic, assign) BOOL isAddSP;
@property (nonatomic, strong) NSArray * offlineSPs; //离线撑点
@end

@implementation PoleLineMapMainTYKViewController
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
    BOOL isGuanlian;//是否是关联杆路段模式
    
    StrUtil *strUtil;
    double lat,lon;//当前定位坐标
    
    CusButton *guanlianBtn;//关联杆路段按钮
    NSMutableArray *poleSegInfoList;//关联的杆路段列表
    
    BOOL isGLD;//是否是关联光缆段模式
    NSDictionary *poleSpCableInfo;//关联的光缆段
    NSMutableArray *poleSpCableInfoList;//关联光缆段的资源列表
    CusButton *guanlianCableBtn;//关联光缆段按钮
    UITextView *cableTextView;//光缆段显示信息
    UIView *guanlianCableView; //批量关联光缆段缆段显示操作域
    
    NSMutableDictionary * newPole;//新增电杆
    NSMutableDictionary *newSp;//新增撑点
    BOOL isFirst;//是否是第一次进来
    BOOL isSetLevel;
    
    BOOL isAdd;
    
    int limit;
    int radius;
    
    NSString *addType;//新增资源类,逆地理编码回调区分添加的资源地址用
    CLLocationManager *locationManager;
    
    //传感器图片
    UIImageView *arrowImageView;
    NSMutableArray *btnShowArr;//显示的按钮数组
    
    BOOL isShowMenu;//是否默认显示操作菜单
    CusButton *showMenuBtn;//显示操作按钮的菜单按钮
    NSMutableArray *plGuanlanCable;/*用来显示的批量关联的光缆段列表*/
    NSMutableArray *plPoleSpCableInfoList;/*实际的关联光缆段的资源列表*/
    NSMutableDictionary *plGuanlanCableStateDic;//批量关联的光缆段是否选中状态(光缆段ID作为字典key值)
    NSMutableArray *upPlList;
    BOOL isPLCable;//todo:是否是批量穿缆(临时，正式确定后这个变量可以删了)
    
    BOOL _isYuanAutoAdd;
}
@synthesize coordinate;
@synthesize poleArray;
@synthesize poleTableView;
@synthesize resourceLocationArray;
@synthesize selectResourceIndex;
@synthesize poleLine;

-(NSMutableArray *)poleArray{
    if (poleArray == nil) {
        poleArray = [NSMutableArray array];
    }
    return poleArray;
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
    
    self.title = @"杆路定位";
    
    isPLCable = NO;
    
    [self initNavigationBar];
    
    resourceLocationArray = [[NSMutableArray alloc] init];
    _polelineSegmentArray = NSMutableArray.array;

    
    isLocationSelf = NO;
    isGuanlian = NO;
    isGLD = NO;
    isFirst = YES;
    isSetLevel = NO;
    isAdd = NO;
    strUtil = [[StrUtil alloc]init];
    btnShowArr = [NSMutableArray array];
    
    selectResourceIndex = 1000000;
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
//    if ([user valueForKey:@"isLocationPages"]!=nil&&[[user valueForKey:@"isLocationPages"] intValue]==2) {
//        //关闭定位分页
//        [self getPoleDate];
//    }
//    else{
//        //开启定位分页
//        NSDictionary *param = nil;
//
//        param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"%d\",\"resLogicName\":\"pole\",\"id\":%@}",limit,[self.poleLine objectForKey:@"GID"]]};
//        [self getPoleAndSegmentDate:param :YES];
//    }
    [self getPoleDate];
    
    [super viewDidLoad];
}
#pragma mark 解析文件
- (void)createPropertiesReader{
  
    
    // MARK: 袁全修改 , 这是杆路定位  添加电杆 , 错误原因也是添加UNI_模板 , 由于原先这个类里filename: pole 是写死的 , 所以有错误 , 新版统一库改为 UNI_pole
    
    NSString * filename = @"UNI_pole";
    
    self.poleReader = [IWPPropertiesReader propertiesReaderWithFileName:filename withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
    
    self.poleModel = [IWPPropertiesSourceModel modelWithDict:self.poleReader.result];
    NSLog(@"self.poleModel.subName = %@",self.poleModel.subName);
    // 创建viewModel
    NSMutableArray * poleArrr = [NSMutableArray array];
    for (NSDictionary * dict in self.poleModel.view) {
        IWPViewModel * viewModel = [IWPViewModel modelWithDict:dict];
        [poleArrr addObject:viewModel];
    }
    self.poleViewModel = poleArrr;
    
    self.spReader = [IWPPropertiesReader propertiesReaderWithFileName:@"supportingPoints" withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
    
    self.spModel = [IWPPropertiesSourceModel modelWithDict:self.spReader.result];
    NSLog(@"self.spModel.subName = %@",self.spModel.subName);
    // 创建viewModel
    NSMutableArray * spArrr = [NSMutableArray array];
    for (NSDictionary * dict in self.spModel.view) {
        IWPViewModel * viewModel = [IWPViewModel modelWithDict:dict];
        [spArrr addObject:viewModel];
    }
    self.spViewModel = spArrr;
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
    
    poleTableView=[[UITableView alloc] initWithFrame:CGRectMake(2, 2, doLayout.frame.size.width-4,doLayout.frame.size.height-4-45) style:UITableViewStyleGrouped];
    poleTableView.backgroundColor=[UIColor whiteColor];
    [poleTableView setEditing:NO];
    poleTableView.delegate=self;
    poleTableView.dataSource=self;
    [doLayout addSubview:poleTableView];
    
    CusButton *nowLocationBtn = [self btnInit:@"当前位置"];
    [nowLocationBtn addTarget:self action:@selector(nowLocation:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowArr addObject:nowLocationBtn];
    CusButton *selfLocationBtn = [self btnInit:@"手动定位"];
    [selfLocationBtn addTarget:self action:@selector(selfLocation:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowArr addObject:selfLocationBtn];
    CusButton *nearPoleBtn = [self btnInit:@"附近电杆"];
    [nearPoleBtn addTarget:self action:@selector(nearPole:) forControlEvents:UIControlEventTouchUpInside];
//    [nearPoleBtn setBackgroundColor:[UIColor grayColor]];
    [btnShowArr addObject:nearPoleBtn];
    CusButton *addPoleBtn = [self btnInit:@"添加电杆"];
    [addPoleBtn addTarget:self action:@selector(addPole:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowArr addObject:addPoleBtn];
//    CusButton *nearSPBtn = [self btnInit:@"附近撑点"];
//    [nearSPBtn addTarget:self action:@selector(nearSP:) forControlEvents:UIControlEventTouchUpInside];
//    [btnShowArr addObject:nearSPBtn];
//    CusButton *addSPBtn = [self btnInit:@"添加撑点"];
//    [addSPBtn addTarget:self action:@selector(addSP:) forControlEvents:UIControlEventTouchUpInside];
//    [btnShowArr addObject:addSPBtn];
    guanlianBtn = [self btnInit:@"关联杆路段"];
    [guanlianBtn addTarget:self action:@selector(guanlian:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowArr addObject:guanlianBtn];
//    guanlianCableBtn = [self btnInit:@"关联光缆段"];
//    [guanlianCableBtn addTarget:self action:@selector(guanlianCable:) forControlEvents:UIControlEventTouchUpInside];
//    [guanlianCableBtn setBackgroundColor:[UIColor grayColor]];
//    [btnShowArr addObject:guanlianCableBtn];
    
    //根据权限显示
    if ([UserModel.domainCode isEqualToString:@"0/"] ) {
        [btnShowArr removeObject:addPoleBtn];
        [btnShowArr removeObject:guanlianBtn];
        [btnShowArr removeObject:guanlianCableBtn];
//        [btnShowArr removeObject:addSPBtn];
    }
    if (([[UserModel.powersTYKDic[@"pole"] substringToIndex:1] integerValue] == 0)){
        //无添加电杆权限
        [btnShowArr removeObject:addPoleBtn];
    }
    if (([[UserModel.powersTYKDic[@"poleLineSegment"] substringToIndex:1] integerValue] == 0)){
        //无添加杆路段权限
        [btnShowArr removeObject:guanlianBtn];
    }
    if (([[UserModel.powersTYKDic[@"pole"] substringFromIndex:2] integerValue] == 0)){
        //无核查电杆权限
        [btnShowArr removeObject:guanlianCableBtn];
    }
    if (([[UserModel.powersTYKDic[@"supportingPoints"] substringToIndex:1] integerValue] == 0)){
        //无添加撑点权限
//        [btnShowArr removeObject:addSPBtn];
    }
    [self showBtn];
    
    //分页模式下显示获取按钮
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//    if ([[user objectForKey:@"isLocationPages"] integerValue] != 2) {
//        int y = 0;
//        if (btnShowArr.count<6) {
//            y = 45;
//        }else{
//            y = 80;
//        }
//        if (!isShowMenu) {
//            y = 5;
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
            [doLayout setFrame:CGRectMake(0,HeigtOfTop-(ScreenHeight-HeigtOfTop)/3+45,ScreenWidth,(ScreenHeight-HeigtOfTop)/3+(80-45))];
            if (!isShowMenu) {
                [doLayout setFrame:CGRectMake(0,HeigtOfTop-(ScreenHeight-HeigtOfTop)/3-(80-45),ScreenWidth,(ScreenHeight-HeigtOfTop)/3+(80-45))];
            }
            if (i<5) {
                [btn setFrame:CGRectMake(0+(ScreenWidth/5)*i, doLayout.frame.size.height-40*2, ScreenWidth/5, 40-1)];
            }else{
                [btn setFrame:CGRectMake(0+(ScreenWidth/(btnShowArr.count-5))*(i-5), doLayout.frame.size.height-40, ScreenWidth/(btnShowArr.count-5), 40)];
            }
        }
        [doLayout addSubview:btn];
    }
}
//获取资源按钮点击触发事件
-(IBAction)getResource:(CusButton *)sender
{
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
    
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"lon\":\"%@\",\"lat\":\"%@\",\"radius\":\"%d\",\"resLogicName\":\"pole\",\"id\":%@}",lonStr,latStr,radius,[self.poleLine objectForKey:@"GID"]]};
    [self getPoleAndSegmentDate:param :NO];
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
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
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
//附近电杆按钮点击触发事件
-(IBAction)nearPole:(id)sender{

    [YuanHUD HUDFullText:@"请稍等"];
    
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
    
    NSString *requestStr = [NSString stringWithFormat:@"{\"isAll\":\"1\",\"resLogicName\":\"pole\",\"lon\":\"%@\",\"lat\":\"%@\"}",lonStr,latStr];
    [self getNeaPoleData:requestStr];
    
}
//添加电杆按钮点击触发事件
-(IBAction)addPole:(CusButton *)sender
{
    _isAddSP = NO;
    if (isGLD) {

        
        [YuanHUD HUDFullText:@"请先退出关联光缆段"];

        return;
    }
    if (isGuanlian) {
        [YuanHUD HUDFullText:@"请先退出关联杆路段"];

        
        return;
        
    }
    
    addType = @"pole";
    NSString * latStr = nil;
    NSString * lonStr = nil;

    
    /**
     *
     */
    
    lonStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
    latStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
    

    
    newPole = [NSMutableDictionary dictionary];
    // 名称
    [newPole setValue:[NSString stringWithFormat:@"%@P",poleLine[@"poleLineName"]] forKey:@"poleSubName"];
    
    /* 2017年03月01日 修复 */
    
    [newPole setValue:poleLine[@"poleLineName"] forKey:@"preName"];
    
    NSLog(@"poleLine = %@", poleLine);
    
    // 2019年11月11日 新增：跟随杆路信息。
    if (self.poleLine[@"chanquanxz"] != nil){
        newPole[@"chanquanxz"] = self.poleLine[@"chanquanxz"];
    }
    
    if (self.poleLine[@"prorertyBelong"] != nil){
        newPole[@"prorertyBelong"] = self.poleLine[@"prorertyBelong"];
    }
    
    // 所属局站，局站ID
    
    [newPole setValue:poleLine[@"areaname"] forKey:@"areaname"];
    [newPole setValue:poleLine[@"areaname_Id"] forKey:@"areaname_Id"];
    
    // 所屬桿路
    
    [newPole setValue:poleLine[@"poleLineName"] forKey:@"poleLine"];
    
    
    [newPole setValue:poleLine[@"GID"] forKey:@"poleLine_Id"];
    
    
    NSLog(@"%@",newPole);
    // 所属维护区域
    [newPole setValue:poleLine[@"retion"] forKey:@"retion"];
    // 经纬度
    [newPole setValue:latStr forKey:@"lat"];
    [newPole setValue:lonStr forKey:@"lon"];
    
    NSNumber * code = [[NSUserDefaults standardUserDefaults] valueForKey:@"yuan_IsAutoAdd"];
    NSInteger yuan_IsAutoAdd = code.integerValue;
    
    // 手动 yuan_IsAutoAdd == 2
    if (yuan_IsAutoAdd == 2) {
        
        if (_isAutoSetAddr) {
            [self searchReGeocodeWithCoordinate:(CLLocationCoordinate2D){[latStr doubleValue],[lonStr doubleValue]}];
        }else{
            TYKDeviceInfoMationViewController *addPole = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_poleModel withViewModel:_poleViewModel withDataDict:newPole withFileName:@"pole"];
            isAdd = YES;
            addPole.delegate = self;
            [self.navigationController pushViewController:addPole animated:YES];
            
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
    
    NSString * latStr = nil;
    NSString * lonStr = nil;
    
    lonStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
    latStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
    
    
    
    // 如果没有数据 暂时走手动
    if (resourceLocationArray.count == 0 ) {
        _isYuanAutoAdd = NO;
        [self searchReGeocodeWithCoordinate:(CLLocationCoordinate2D){[latStr doubleValue],[lonStr doubleValue]}];
        return;
    }
    else {
        [self searchReGeocodeWithCoordinate:(CLLocationCoordinate2D){[latStr doubleValue],[lonStr doubleValue]}];
    }
    NSDictionary * lastDict = resourceLocationArray.lastObject;
    
    // newPole
    
    
    
    NSInteger large = 0;
    
    for (NSDictionary * dict in resourceLocationArray) {

        NSString * poleCode = dict[@"poleSubName"];
        
        NSArray * codeArr = [poleCode componentsSeparatedByString:@"P"];
        
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
        newPole[@"poleCode"] = [NSString stringWithFormat:@"%@%ld",newPole[@"poleSubName"],large];
        newPole[@"poleSubName"] = [NSString stringWithFormat:@"%@%ld",newPole[@"poleSubName"],large];
    }
    else {
        newPole[@"poleCode"] = [NSString stringWithFormat:@"%@%ld",newPole[@"poleSubName"],large];
        newPole[@"poleSubName"] = [NSString stringWithFormat:@"%@%ld",newPole[@"poleSubName"],large];
    }
    
    
    for (NSString * key in lastDict.allKeys) {
        
        if (![newPole.allKeys containsObject:key] &&
            ![key isEqualToString:@"GID"] &&
            ![key isEqualToString:@"rfid"]) {
            newPole[key] = lastDict[key];
        }
    }
    
    // 走保存接口
    
    
    [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Insert
                             dict:newPole
                          succeed:^(id data) {
            
        NSArray * arr = data;
        
        if (arr.count > 0) {
            
            isAdd = YES;
            NSDictionary * dict = arr.firstObject;
            [self newPoleWithDict:dict];
        }
        else {
            [[Yuan_HUD shareInstance] HUDFullText:@"自动添加电杆失败"];
        }
    }];
}





//附近撑点按钮点击触发事件
-(IBAction)nearSP:(id)sender{
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
    
    NSString *requestStr = [NSString stringWithFormat:@"{\"isAll\":\"1\",\"resLogicName\":\"supportingPoints\",\"lon\":\"%@\",\"lat\":\"%@\"}",lonStr,latStr];
    [self getNeaSPData:requestStr];
}

//关联杆路段按钮点击触发事件
-(IBAction)guanlian:(CusButton *)sender
{
    if (isGLD) {
     
        [YuanHUD HUDFullText:@"请先退出关联光缆段"];
        
        return;
    }
    
    if (!isGuanlian) {
        [sender setTitle:@"确定关联" forState:UIControlStateNormal];
        isGuanlian = YES;
        poleSegInfoList = [[NSMutableArray alloc] init];
    }else{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确定要关联当前选择杆路段吗"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (poleSegInfoList.count == 0) {
                return ;
            }
            [self addPoleSegDate];
        }];
        UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            isGuanlian = NO;
            [sender setTitle:@"关联杆路段" forState:UIControlStateNormal];
            //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
            for (int i = 0; i<resourceLocationArray.count; i++) {
                if (resourceLocationArray[i][@"doType"]!=nil) {
                    [resourceLocationArray[i] removeObjectForKey:@"doType"];
                }
            }
            poleSegInfoList = nil;
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

    
    [YuanHUD HUDFullText:@"当前功能尚未开放"];

}
//取消关联光缆段按钮点击触发事件
-(IBAction)cabelCancel:(id)sender{
    isGLD = NO;
    cableTextView.text = @"";
    [guanlianCableBtn setTitle:@"关联光缆段" forState:UIControlStateNormal];
    [guanlianCableView setHidden:YES];
    for (int i = 0; i<resourceLocationArray.count; i++) {
        if (resourceLocationArray[i][@"doType"]!=nil) {
            [resourceLocationArray[i] removeObjectForKey:@"doType"];
        }
    }
    poleSpCableInfoList = nil;
    
    [self addOverlayView];
    [self addLineView];
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
        region.span.latitudeDelta = 0.1;//经度范围(设置为0.1表示显示范围为0.2的纬度范围)
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

        [YuanHUD HUDFullText:@"没有电杆记录，无法获取电杆经纬度"];

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
    for (int i = 0; i<_polelineSegmentArray.count; i++) {
        NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        NSMutableDictionary *seg = _polelineSegmentArray[i];
        for (int j = 0; j<resourceLocationArray.count; j++) {
            NSMutableDictionary *resource = resourceLocationArray[j];
            
            ///*新版*/
//            NSString * currendResourceId = resource[@"GID"];
//            NSString * segStartId = seg[@"startPole_Id"];
//            NSString * segEndId = seg[@"endPole_Id"];
//
//            if ([currendResourceId isEqualToString:segStartId]) {
//                [p1 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
//                [p1 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
//                [points addObject:p1];
//            }else if ([currendResourceId isEqualToString:segEndId]){
//                [p2 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
//                [p2 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
//                [points addObject:p2];
//            }
            
            
            /// * 旧版 * /
            
            if ([resource[@"resLogicName"] isEqualToString:@"pole"]) {
                if ((seg[@"startPole_Type"]==nil||[seg[@"startPole_Type"] isEqualToString:@"1"]) && [[NSString stringWithFormat:@"%@",[resource objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"startPole_Id"]]]) {
                    [p1 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [p1 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p1];
                }
                if ((seg[@"endPole_Type"]==nil||[seg[@"endPole_Type"] isEqualToString:@"1"]) && [[NSString stringWithFormat:@"%@",[resource objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"endPole_Id"]]]) {
                    [p2 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [p2 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p2];
                }
            }else if ([resource[@"resLogicName"] isEqualToString:@"supportingPoints"]) {
                if (([seg[@"startPole_Type"] isEqualToString:@"2"]) && [[NSString stringWithFormat:@"%@",[resource objectForKey:@"supportingPointsId"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"startPole_Id"]]]) {
                    [p1 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [p1 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p1];
                }
                if (([seg[@"endPole_Type"] isEqualToString:@"2"]) && [[NSString stringWithFormat:@"%@",[resource objectForKey:@"supportingPointsId"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"endPole_Id"]]]) {
                    [p2 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [p2 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p2];
                }
            }
            
            
            /// * 通用 * /
            if (p1!=nil && p2!=nil && [[p1 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p1 objectForKey:@"lon"] doubleValue]&& [[p2 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p2 objectForKey:@"lon"] doubleValue]) {
                CLLocationCoordinate2D coors[2] = {0};
                coors[0].latitude = [[p1 objectForKey:@"lat"] doubleValue];
                coors[0].longitude = [[p1 objectForKey:@"lon"] doubleValue];
                coors[1].latitude = [[p2 objectForKey:@"lat"] doubleValue];
                coors[1].longitude = [[p2 objectForKey:@"lon"] doubleValue];
                
                
                NSLog(@"coors:%f,%f,%f,%f",coors[0].latitude,coors[0].longitude,coors[1].latitude,coors[1].longitude);
                CusMAPolyline *polyline = [CusMAPolyline polylineWithCoordinates:coors count:2];
                [_mapView addOverlay:polyline];
                break;
            }
        }
    }
}
//添加资源画线(虚线)
-(void)addTempLineView
{
    for (int i = 0; i<poleSegInfoList.count; i++) {
        NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        NSMutableDictionary *seg = poleSegInfoList[i];
        for (int j = 0; j<resourceLocationArray.count; j++) {
            NSMutableDictionary *resource = resourceLocationArray[j];
            if ([resource[@"resLogicName"] isEqualToString:@"pole"]) {
                if ((seg[@"startPole_Type"]==nil||[seg[@"startPole_Type"] isEqualToString:@"1"]) && [[NSString stringWithFormat:@"%@",[resource objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"startPole_Id"]]]) {
                    [p1 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [p1 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p1];
                }
                if ((seg[@"endPole_Type"]==nil||[seg[@"endPole_Type"] isEqualToString:@"1"]) && [[NSString stringWithFormat:@"%@",[resource objectForKey:@"GID"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"endPole_Id"]]]) {
                    [p2 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [p2 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p2];
                }
            }else if ([resource[@"resLogicName"] isEqualToString:@"supportingPoints"]) {
                if (([seg[@"startPole_Type"] isEqualToString:@"2"]) && [[NSString stringWithFormat:@"%@",[resource objectForKey:@"supportingPointsId"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"startPole_Id"]]]) {
                    [p1 setObject:[resource objectForKey:@"lat"] forKey:@"lat"];
                    [p1 setObject:[resource objectForKey:@"lon"] forKey:@"lon"];
                    [points addObject:p1];
                }
                if (([seg[@"endPole_Type"] isEqualToString:@"2"]) && [[NSString stringWithFormat:@"%@",[resource objectForKey:@"supportingPointsId"]] isEqualToString:[NSString stringWithFormat:@"%@",[seg objectForKey:@"endPole_Id"]]]) {
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


- (void) yuan_ReloadMapSource {
    
    
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
    [self addOverlayView];
}


//计算杆路段长度
-(double)poleLineSegmentLengthWithLat1:(double)lat1 Lon1:(double)lon1 Lat2:(double)lat2 Lon2:(double)lon2
{
    //第一个坐标
    CLLocation *current=[[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
    //第二个坐标
    CLLocation *before=[[CLLocation alloc] initWithLatitude:lat2 longitude:lon2];
    // 计算距离
    CLLocationDistance meters=[current distanceFromLocation:before];
    return meters;
}
-(BOOL)isInRegion:(NSDictionary *)dict{
    
    /* 获取当前定位点的坐标 */
    CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake(0, 0);
    /* 是否为手动定位 */
    if (isLocationSelf) {
        coordinate2 = _mapView.centerCoordinate;
    }else{
        coordinate2 = CLLocationCoordinate2DMake(lat, lon);
    }
    
    double latitude = coordinate2.latitude;
    double longitude = coordinate2.longitude;
    
    
    /* 从这里开始内容内容来自服务器端获取附近撑点中的内容 */
    double degree = (24901.f * 1609.f) / 360.f;
    
    /* 获取定位范围半径 */
    double raidusMile = 0.f;
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([user valueForKey:@"locationRadius"] != nil) {
        raidusMile = [[user valueForKey:@"locationRadius"] intValue];
    }else if ([user valueForKey:@"locationRadius"] == nil){
        raidusMile = 500.f;
    }
    
    
    double dpmLat = 1.f / degree;
    double radiusLat = dpmLat * raidusMile;
    double minLat = latitude - radiusLat;
    double maxLat = latitude + radiusLat;
    
    double mpdLng = degree * cos(latitude * (M_PI / 180.f));
    double dpmLng = 1 / mpdLng;
    double radiusLng = dpmLng * raidusMile;
    double minLng = longitude - radiusLng;
    double maxLng = longitude + radiusLng;
    
    
    double deviceLat = [dict[@"lat"] doubleValue];
    double deviceLon = [dict[@"lon"] doubleValue];
    
    NSLog(@"#########:%f,%f",deviceLat,maxLat);
    NSLog(@"#########:%f,%f",deviceLat,minLat);
    NSLog(@"#########:%f,%f",deviceLon,maxLng);
    NSLog(@"#########:%f,%f",deviceLon,minLng);
    if (deviceLat <= maxLat &&
        deviceLat >= minLat &&
        deviceLon <= maxLng &&
        deviceLon >= minLng) {
        return YES;
    }
    return NO;
}
//获取当前杆路下电杆信息
-(void)getPoleDate
{
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    //调用查询接口
    

    NSDictionary * param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"10000\",\"resLogicName\":\"pole\",poleLine_Id:%@}",[self.poleLine objectForKey:@"GID"]]};
    
    
    NSLog(@"param %@", param);
    
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
            
            
            for (NSDictionary * pole in arr) {
                [self.poleArray addObject:pole];
            }
            
            NSLog(@"poleArray.count:%lu",(unsigned long)poleArray.count);
            for (int i = 0; i<poleArray.count; i++) {
                if (([poleArray[i] objectForKey:@"lon"]!=nil)&&(![[poleArray[i] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[poleArray[i] objectForKey:@"lon"] isEqualToString:@""])) {
                    [self.resourceLocationArray addObject:poleArray[i]];
                    NSLog(@"add__________________");
                }
            }
            [poleTableView reloadData];
        
            [YuanHUD HUDFullText:@"获取电杆成功"];
            
            
            
            [self initOverlay];
            [self addOverlayView];
            [self getPolelineSegmentDate];
        }else{


            if ([[dic objectForKey:@"info"] isEqual:[NSNull null]]) {
                [YuanHUD HUDFullText:@"操作失败，数据为空"];
            }else{

                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];

            }
            
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
//获取当前杆路下杆路段信息
-(void)getPolelineSegmentDate
{
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    
    //调用查询接口
    
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"1\",\"limit\":\"10000\",\"resLogicName\":\"poleLineSegment\",poleLine_Id:%@}",[self.poleLine objectForKey:@"GID"]]};
    
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
            _polelineSegmentArray = [NSMutableArray arrayWithArray:arr];
            //从杆路段中提取关联的撑点
            for (int i = 0; i<_polelineSegmentArray.count; i++) {
                if ([_polelineSegmentArray[i] objectForKey:@"supportingPointss"] != nil&&[[_polelineSegmentArray[i] objectForKey:@"supportingPointss"] count]>0) {
                    NSArray *supportingPoints = [NSArray arrayWithArray:[_polelineSegmentArray[i] objectForKey:@"supportingPointss"]];
                    for (int j = 0; j<supportingPoints.count; j++) {
                        if (([supportingPoints[j] objectForKey:@"lon"]!=nil)&&(![[supportingPoints[j] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[supportingPoints[j] objectForKey:@"lon"] isEqualToString:@""])) {
                            BOOL isHave = NO;
                            for (int k = 0; k <resourceLocationArray.count; k++) {
                                if (([resourceLocationArray[k][@"resLogicName"] isEqualToString:@"supportingPoints"])&&[supportingPoints[j][@"supportingPointsId"] isEqualToString:resourceLocationArray[k][@"supportingPointsId"]]) {
                                    isHave = YES;
                                    break;
                                }
                            }
                            if (!isHave) {
                                [resourceLocationArray addObject:supportingPoints[j]];
                            }
                        }
                    }
                }
            }
            //从杆路段中提取关联的附近电杆,这个只显示在地图上，列表内不做显示
            for (int i = 0; i<_polelineSegmentArray.count; i++) {
                if ([_polelineSegmentArray[i] objectForKey:@"poles"] != nil&&[[_polelineSegmentArray[i] objectForKey:@"poles"] count]>0) {
                    NSArray *poles = [NSArray arrayWithArray:[_polelineSegmentArray[i] objectForKey:@"poles"]];
                    for (int j = 0; j<poles.count; j++) {
                        BOOL isHave = NO;
                        for (int k = 0; k <resourceLocationArray.count; k++) {
                            if (([resourceLocationArray[k][@"resLogicName"] isEqualToString:@"pole"])&&[poles[j][@"GID"] isEqualToString:resourceLocationArray[k][@"GID"]]) {
                                isHave = YES;
                                break;
                            }
                        }
                        if (!isHave) {
                            if (([poles[j] objectForKey:@"lon"]!=nil)&&(![[poles[j] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[poles[j] objectForKey:@"lon"] isEqualToString:@""])) {
                                [resourceLocationArray addObject:poles[j]];
                            }
                        }
                        
                    }
                }
            }
            
           
            [self addLineView];
        }else{
     
            if ([[dic objectForKey:@"info"] isEqual:[NSNull null]]) {

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
//获取当前杆路下默认添加的前100个杆的信息，方便杆路地图初始化定位
-(void)getPoleAndSegmentDate:(NSDictionary *)param :(BOOL)isStart
{
    //从中心获取对应的信息
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    
    //调用查询接口
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * url = [NSString stringWithFormat:@"%@GIS!getResByPageAndLatLon.interface",BaseURL];
#else
    NSString * url = [NSString stringWithFormat:@"%@GIS!getResByPageAndLatLon.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    
    [Http.shareInstance POST:url parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
          
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            
            
            NSArray *poleArr = [[NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil] objectForKey:@"poleList"];
            
            if (self.poleArray.count > 0) {
                [self.poleArray removeAllObjects];
            }
            [resourceLocationArray removeAllObjects];
            
            //加载当前杆路下电杆信息
            for (NSDictionary * pole in poleArr) {
                if ([pole[@"poleLine_Id"] isEqualToString:self.poleLine[@"GID"]]) {
                    [self.poleArray addObject:pole];
                }
                
            }
            NSLog(@"poleArray.count:%lu",(unsigned long)poleArray.count);
            //加载到地图显示
            for (int i = 0; i<poleArr.count; i++) {
                if (([poleArr[i] objectForKey:@"lon"]!=nil)&&(![[poleArr[i] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[poleArr[i] objectForKey:@"lon"] isEqualToString:@""])) {
                    [resourceLocationArray addObject:poleArr[i]];
                    NSLog(@"add__________________");
                }
            }
            
            [poleTableView reloadData];
            
            NSArray *poleSegArr = [[NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil] objectForKey:@"polelineSegmentList"];
            _polelineSegmentArray = [NSMutableArray arrayWithArray:poleSegArr];
            NSLog(@"_polelineSegmentArray:%lu",(unsigned long)_polelineSegmentArray.count);
            //从杆路段中提取关联的撑点
            for (int i = 0; i<_polelineSegmentArray.count; i++) {
                if ([_polelineSegmentArray[i] objectForKey:@"supportingPointss"] != nil&&[[_polelineSegmentArray[i] objectForKey:@"supportingPointss"] count]>0) {
                    NSArray *supportingPoints = [NSArray arrayWithArray:[_polelineSegmentArray[i] objectForKey:@"supportingPointss"]];
                    for (int j = 0; j<supportingPoints.count; j++) {
                        if (([supportingPoints[j] objectForKey:@"lon"]!=nil)&&(![[supportingPoints[j] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[supportingPoints[j] objectForKey:@"lon"] isEqualToString:@""])) {
                            BOOL isHave = NO;
                            for (int k = 0; k <resourceLocationArray.count; k++) {
                                if (([resourceLocationArray[k][@"resLogicName"] isEqualToString:@"supportingPoints"])&&[supportingPoints[j][@"supportingPointsId"] isEqualToString:resourceLocationArray[k][@"supportingPointsId"]]) {
                                    isHave = YES;
                                    break;
                                }
                            }
                            if (!isHave) {
                                [resourceLocationArray addObject:supportingPoints[j]];
                            }
                        }
                    }
                }
            }
            
            //从杆路段中提取关联的附近电杆,这个只显示在地图上，列表内不做显示
            for (int i = 0; i<_polelineSegmentArray.count; i++) {
                if ([_polelineSegmentArray[i] objectForKey:@"poles"] != nil&&[[_polelineSegmentArray[i] objectForKey:@"poles"] count]>0) {
                    NSArray *poles = [NSArray arrayWithArray:[_polelineSegmentArray[i] objectForKey:@"poles"]];
                    for (int j = 0; j<poles.count; j++) {
                        BOOL isHave = NO;
                        for (int k = 0; k <resourceLocationArray.count; k++) {
                            if (([resourceLocationArray[k][@"resLogicName"] isEqualToString:@"pole"])&&[poles[j][@"GID"] isEqualToString:resourceLocationArray[k][@"GID"]]) {
                                isHave = YES;
                                break;
                            }
                        }
                        if (!isHave) {
                            if (([poles[j] objectForKey:@"lon"]!=nil)&&(![[poles[j] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[poles[j] objectForKey:@"lon"] isEqualToString:@""])) {
                                [resourceLocationArray addObject:poles[j]];
                            }
                        }
                        
                    }
                }
            }
            
            
            [YuanHUD HUDFullText:@"获取资源成功"];
            
            if (isStart) {
                [self initOverlay];
            }
            [self addOverlayView];
            [self addLineView];
            
        }else{
            //操作执行完后取消对话框
            if ([[dic objectForKey:@"info"] isEqual:[NSNull null]]) {

                [YuanHUD HUDFullText:@"操作失败，数据为空"];
            }else{

                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];

            }
            
        }
        
        [[Yuan_HUD shareInstance] HUDHide];

    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}
//获取附近电杆线程//todo
-(void)getNeaPoleData:(NSString *) jsonRequest{
    //弹出进度框
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    //调用查询接口
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":jsonRequest};
    NSLog(@"param %@",param);
    
    __weak typeof(self) wself = self;
    
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
            
            selectResourceIndex = 1000000;
            NSMutableArray *nearPoleArray = [NSMutableArray arrayWithArray:arr];
            for (NSDictionary *pole in nearPoleArray) {
                BOOL isHave = NO;
                for (NSDictionary *pTemp in resourceLocationArray) {
                    if (([pTemp[@"resLogicName"] isEqualToString:@"pole"])&&
                        [[pole objectForKey:@"GID"] isEqualToString:[pTemp objectForKey:@"GID"]]) {
                        isHave = YES;
                        continue;
                    }
                }
                if (!isHave) {
                    if (([pole objectForKey:@"lon"]!=nil)&&
                        (![[pole objectForKey:@"lon"] isEqualToString:@"\"\""])&&
                        (![[pole objectForKey:@"lon"] isEqualToString:@""])) {
                        [resourceLocationArray addObject:pole];
                    }
                }
            }
            [wself addOverlayView];
            [wself addLineView];
            if (isGuanlian) {
                [wself addTempLineView];
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
//获取附近撑点线程
-(void)getNeaSPData:(NSString *) jsonRequest{
  
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    
    //调用查询接口
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":jsonRequest};
    NSLog(@"param %@",param);
    
    __weak typeof(self) wself = self;
    
#ifdef BaseURL
    NSString * url = [NSString stringWithFormat:@"%@data!getData.interface",BaseURL];
#else
    NSString * url = [NSString stringWithFormat:@"%@data!getData.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    [Http.shareInstance POST:url parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            
            selectResourceIndex = 1000000;
            
            if (arr != nil&&[arr count]>0) {
                NSArray *supportingPoints = [NSArray arrayWithArray:arr];
                for (int j = 0; j<supportingPoints.count; j++) {
                    if (([supportingPoints[j] objectForKey:@"lon"]!=nil)&&(![[supportingPoints[j] objectForKey:@"lon"] isEqualToString:@"\"\""])&&(![[supportingPoints[j] objectForKey:@"lon"] isEqualToString:@""])) {
                        BOOL isHave = NO;
                        for (int k = 0; k < resourceLocationArray.count; k++) {
                            if (([resourceLocationArray[k][@"resLogicName"] isEqualToString:@"supportingPoints"])&&[supportingPoints[j][@"supportingPointsId"] isEqualToString:resourceLocationArray[k][@"supportingPointsId"]]) {
                                isHave = YES;
                                break;
                            }
                        }
                        if (!isHave) {
                            NSLog(@"add~~~~~~~~~");
                            [resourceLocationArray addObject:supportingPoints[j]];
                        }
                    }
                }
            }
            
            [wself addOverlayView];
            [wself addLineView];
            if (isGuanlian) {
                [wself addTempLineView];
            }
        }else{

            if ([[dic objectForKey:@"info"] isEqual:[NSNull null]]) {

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
//新建杆路段线程
-(void)addPoleSegDate
{
    NSLog(@"%@", poleSegInfoList);
    
    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
    for (int i = 0; i<resourceLocationArray.count; i++) {
        if (resourceLocationArray[i][@"doType"]!=nil) {
            [resourceLocationArray[i] removeObjectForKey:@"doType"];
        }
    }
    
    for (int i = 0; i<poleSegInfoList.count; i++) {
        NSMutableDictionary *poleSegInfo = poleSegInfoList[i];
        [poleSegInfo setObject:@"poleLineSegment" forKey:@"resLogicName"];
        [poleSegInfo setObject:[self.poleLine objectForKey:@"GID"] forKey:@"poleLine_Id"];
        
        // 2019年11月11日 新增：跟随杆路信息。
             if (self.poleLine[@"chanquanxz"] != nil){
                 poleSegInfo[@"chanquanxz"] = self.poleLine[@"chanquanxz"];
             }
             if (self.poleLine[@"prorertyBelong"] != nil){
                 poleSegInfo[@"prorertyBelong"] = self.poleLine[@"prorertyBelong"];
             }
        
             // 2019年11月14日 新增：编号跟随名称
             poleSegInfo[@"poleLineSegmentCode"] = poleSegInfo[@"poleLineSegmentName"];
        
        //去掉手机端为了方便判断自己添加的一些属性字段
        [poleSegInfoList[i] removeObjectForKey:@"qslat"];
        [poleSegInfoList[i] removeObjectForKey:@"qslon"];
        [poleSegInfoList[i] removeObjectForKey:@"qspoleLine_Id"];
        [poleSegInfoList[i] removeObjectForKey:@"zzlat"];
        [poleSegInfoList[i] removeObjectForKey:@"zzlon"];
        [poleSegInfoList[i] removeObjectForKey:@"zzpoleLine_Id"];
    }
    //去掉重名杆路段
    for (int i = 0; i<_polelineSegmentArray.count; i++) {
        NSDictionary *polelineSegment = _polelineSegmentArray[i];
        for (int j = 0; j<poleSegInfoList.count; j++) {
            NSDictionary *temp = poleSegInfoList[j];
            if ([[polelineSegment objectForKey:@"poleLineSegmentName"] isEqualToString:[temp objectForKey:@"poleLineSegmentName"]]) {
                [poleSegInfoList removeObjectAtIndex:j];
                j--;
            }
        }
    }
    //去掉可能会出现的只有起始没有终止资源的情况(最后一个资源)
    if (poleSegInfoList.count>0) {
        NSDictionary *lastpoleSegDic = poleSegInfoList[poleSegInfoList.count-1];
        if ([lastpoleSegDic objectForKey:@"startPole_Id"]!=nil &&[lastpoleSegDic objectForKey:@"endPole_Id"]==nil ) {
            [poleSegInfoList removeObjectAtIndex:poleSegInfoList.count-1];
            if (poleSegInfoList.count == 0) {

                [YuanHUD HUDFullText:@"无需要关联的杆路段"];

                
                isGuanlian = NO;
                [guanlianBtn setTitle:@"关联杆路段" forState:UIControlStateNormal];
                poleSegInfoList = nil;
                [self addOverlayView];
                [self addLineView];
                return;
            }
        }
    }
    
    NSLog(@"------poleSegInfoList:%@",poleSegInfoList);
    if (poleSegInfoList.count == 0) {

        
        [YuanHUD HUDFullText:@"重复关联杆路段"];

        
        isGuanlian = NO;
        [guanlianBtn setTitle:@"关联杆路段" forState:UIControlStateNormal];
        poleSegInfoList = nil;
        [self addOverlayView];
        [self addLineView];
        return;
    }
    //弹出进度框
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    NSString * request = @"[";
    for (NSDictionary * dict in poleSegInfoList) {
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

            //添加的数据告知杆路段列表
            
            for (int i = 0; i<poleSegInfoList.count; i++) {
                [_polelineSegmentArray addObject:poleSegInfoList[i]];
            }
            
            [guanlianBtn setTitle:@"关联杆路段" forState:UIControlStateNormal];
            
            isGuanlian = NO;
            //关联成功，开始画线
            [self addOverlayView];
            [self addLineView];
            
        }else{
           
            NSLog(@"!!!!%@",[dic objectForKey:@"info"]);//[m_result isEqual：[NSNUll null]]
            if ([[dic objectForKey:@"info"] isEqual:[NSNull null]]) {

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
//todo:上传电杆撑点批量穿缆信息
-(void)updatePlPoleSpCable:(NSMutableArray *) upList{
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
    NSString * url = [NSString stringWithFormat:@"%@data!updateData.interface",BaseURL];
#else
    NSString * url = [NSString stringWithFormat:@"%@data!updateData.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    
    [Http.shareInstance POST:url parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            for (int i = 0; i<poleArray.count; i++) {
                NSDictionary *pole = poleArray[i];
                for (int j = 0; j<upList.count; j++) {
                    NSDictionary *temp = upList[j];
                    if ([[temp objectForKey:@"resLogicName"] isEqualToString:@"pole"] && [[pole objectForKey:@"GID"] isEqualToString:[temp objectForKey:@"GID"]]) {
                        [poleArray replaceObjectAtIndex:i withObject:temp];
                        break;
                    }
                }
            }
            for (int i = 0; i<resourceLocationArray.count; i++) {
                NSDictionary *resource = resourceLocationArray[i];
                for (int j = 0; j<upList.count; j++) {
                    NSDictionary *temp = upList[j];
                    if ([[temp objectForKey:@"resLogicName"] isEqualToString:@"pole"] && [[resource objectForKey:@"GID"] isEqualToString:[temp objectForKey:@"GID"]]) {
                        //电杆穿缆
                        [resourceLocationArray replaceObjectAtIndex:i withObject:temp];
                        break;
                    }else if ([[temp objectForKey:@"resLogicName"] isEqualToString:@"supportingPoints"] && [[resource objectForKey:@"supportingPointsId"] isEqualToString:[temp objectForKey:@"supportingPointsId"]]) {
                        //撑点穿缆
                        [resourceLocationArray replaceObjectAtIndex:i withObject:temp];
                        break;
                    }
                }
            }
            
            isGLD = NO;
            cableTextView.text = @"";
            [guanlianCableBtn setTitle:@"关联光缆段" forState:UIControlStateNormal];
            [guanlianCableView setHidden:YES];
            poleSpCableInfoList = nil;
            upPlList = nil;
            [self addOverlayView];
            [self addLineView];
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
//上传电杆撑点穿缆信息
-(void)updatePoleSpCable:(NSMutableArray *) upList{
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
    NSString * url = [NSString stringWithFormat:@"%@data!updateData.interface",BaseURL];
#else
    NSString * url = [NSString stringWithFormat:@"%@data!updateData.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    
    [Http.shareInstance POST:url parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
           
            
            for (int i = 0; i<poleArray.count; i++) {
                NSDictionary *pole = poleArray[i];
                for (int j = 0; j<upList.count; j++) {
                    NSDictionary *temp = upList[j];
                    if ([[temp objectForKey:@"resLogicName"] isEqualToString:@"pole"] && [[pole objectForKey:@"GID"] isEqualToString:[temp objectForKey:@"GID"]]) {
                        [poleArray replaceObjectAtIndex:i withObject:temp];
                        break;
                    }
                }
            }
            for (int i = 0; i<resourceLocationArray.count; i++) {
                NSDictionary *resource = resourceLocationArray[i];
                for (int j = 0; j<upList.count; j++) {
                    NSDictionary *temp = upList[j];
                    if ([[temp objectForKey:@"resLogicName"] isEqualToString:@"pole"] && [[resource objectForKey:@"GID"] isEqualToString:[temp objectForKey:@"GID"]]) {
                        //电杆穿缆
                        [resourceLocationArray replaceObjectAtIndex:i withObject:temp];
                        break;
                    }else if ([[temp objectForKey:@"resLogicName"] isEqualToString:@"supportingPoints"] && [[resource objectForKey:@"supportingPointsId"] isEqualToString:[temp objectForKey:@"supportingPointsId"]]) {
                        //撑点穿缆
                        [resourceLocationArray replaceObjectAtIndex:i withObject:temp];
                        break;
                    }
                }
            }
            
            isGLD = NO;
            cableTextView.text = @"";
            [guanlianCableBtn setTitle:@"关联光缆段" forState:UIControlStateNormal];
            [guanlianCableView setHidden:YES];
            poleSpCableInfoList = nil;
            [self addOverlayView];
            [self addLineView];
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
        region.span.latitudeDelta = 0.1;//经度范围(设置为0.1表示显示范围为0.2的纬度范围)
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
#pragma mark tableviewdatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isPLCable) {
        return [plGuanlanCable count];
    }
    return [poleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"identifier";
    UITableViewCell *cell=[poleTableView dequeueReusableCellWithIdentifier:identifier];
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
        cell.textLabel.text = [poleArray[indexPath.row] objectForKey:@"poleSubName"];
        
//        NSLog(@"🐘CELL deviceId = %d",[[poleArray[indexPath.row] valueForKey:@"deviceId"] integerValue]);
        
        /* 2017年03月02日 新增，工单内资源颜色显示 */
        //    cell.textLabel.textColor = [UIColor colorWithHexString:[StrUtil textColorWithDevice:[poleArray[indexPath.row] valueForKey:@"taskId"]]];
        
        if ([[poleArray[indexPath.row] valueForKey:@"deviceId"] integerValue] > 0) {
            /* 离线颜色优先级高于工单颜色：当某工单资源被转为离线时，优先显示离线颜色：
             问题：1. 是否禁止将工单资源转为离线
             2. 若保存，可能会覆盖掉工单修改后的在线资源
             3. 若不保存，可能会在无网络时遇到无法保存的情况
             */
            cell.textLabel.textColor = [UIColor mainColor];
            
            /* 由于离线颜色于自身工单的颜色相近，这里为离线添加图标标记 */
            
            UIImageView * accessoryView = [[UIImageView alloc] initWithImage:[UIImage Inc_imageNamed:@"offline_icon"]];
            
            accessoryView.frame = CGRectMake(0, 0, 24, 24);
            
            cell.accessoryView = accessoryView;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = nil;
            
            cell.textLabel.textColor = [UIColor blackColor];
            
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
            for (int i = 0; i<plPoleSpCableInfoList.count; i++) {
                NSDictionary *temp = plPoleSpCableInfoList[i];
                if ([temp[@"cableId"] isEqualToString:plGuanlanCable[indexPath.row][@"cableId"]]) {
                    [plPoleSpCableInfoList removeObjectAtIndex:i];
                    break;
                }
            }
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [plGuanlanCableStateDic setObject:@"UITableViewCellAccessoryCheckmark" forKey:plGuanlanCable[indexPath.row][@"cableId"]];
            [plPoleSpCableInfoList addObject:plGuanlanCable[indexPath.row]];
        }
        return;
    }
    if (isGuanlian ||isGLD ) {

        [YuanHUD HUDFullText:@"请先退出关联操作"];

        return;
    }
    TYKDeviceInfoMationViewController * pole = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_poleModel withViewModel:_poleViewModel withDataDict:poleArray[indexPath.row] withFileName:@"pole"];
    pole.delegate = self;
    
    //先写死，加离线再改
    pole.isOffline = NO;
    pole.isSubDevice = NO;
    
    isAdd = NO;
    
    [self.navigationController pushViewController:pole animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
-(void)startTimeOutListen{
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10.f target:self selector:@selector(gCodeTimeOutHint) userInfo:nil repeats:NO];
    }
}

-(void)gCodeTimeOutHint{
    [HUD hideAnimated:YES];
    HUD = nil;
    
    [_search cancelAllRequests];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前网络不佳无法获取真实地址" message:@"是否不添加地址到新增电杆中？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * sure = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 跳转详情页
        
        if (_isAddSP) {
            
            TYKDeviceInfoMationViewController * sp = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListInsertRfid withMainModel:_spModel withViewModel:_spViewModel withDataDict:newSp withFileName:@"supportingPoints"];
            isAdd = YES;
            sp.delegate = self;
            sp.isOffline = NO;

            [self.navigationController pushViewController:sp animated:YES];
            
        }else{
            TYKDeviceInfoMationViewController * addPole = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListInsertRfid withMainModel:_poleModel withViewModel:_poleViewModel withDataDict:newPole withFileName:@"pole"];
            isAdd = YES;
            addPole.delegate = self;
            addPole.isOffline = NO;
            
            [self.navigationController pushViewController:addPole animated:YES];
        }
    }];
    
    UIAlertAction * dont = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 重试与否？
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"是否重试？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * sure = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // 重试
            [self addPole:nil];
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
- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)location
{
    
    // 监听超时：30秒
    [self startTimeOutListen];
    [YuanHUD HUDFullText:@"正在获取地址，请稍候……"];

    
    HUD.animationType = MBProgressHUDAnimationZoomIn;
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:location.latitude longitude:location.longitude];
    regeo.requireExtension = YES;
    
    [_search AMapReGoecodeSearch:regeo];
}
/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    // 停止timer
    [self.timer invalidate];
    self.timer = nil;
    [HUD hideAnimated:YES];
    HUD = nil;
    
    if (response.regeocode != nil)
    {
        if ([addType isEqualToString:@"pole"]) {
            // 地址
            [newPole setValue:response.regeocode.formattedAddress forKey:@"addr"];
            
            //        [newPole setValue:[NSString stringWithFormat:@"%@P",poleLine[@"poleLineName"]] forKey:@"poleSubName"];
            
            NSLog(@"%@",newPole);
            
            if (!_isYuanAutoAdd) {
                
                TYKDeviceInfoMationViewController * addPole = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListInsertRfid withMainModel:_poleModel withViewModel:_poleViewModel withDataDict:newPole withFileName:@"pole"];
                isAdd = YES;
                addPole.delegate = self;
                addPole.isOffline = NO;
                
                [self.navigationController pushViewController:addPole animated:YES];
            }
            
        }else if ([addType isEqualToString:@"sp"]){
            // 地址
            [newSp setValue:response.regeocode.formattedAddress forKey:@"addr"];
            [newSp setValue:[NSString stringWithFormat:@"%@CD",response.regeocode.formattedAddress] forKey:@"supportPSubName"];

            TYKDeviceInfoMationViewController * sp = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListInsertRfid withMainModel:_spModel withViewModel:_spViewModel withDataDict:newSp withFileName:@"supportingPoints"];
            sp.delegate = self;
            sp.isOffline = NO;
            isAdd = YES;
            [self.navigationController pushViewController:sp animated:YES];
        }
        
    }
}
#pragma mark locationManager成员方法
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    //每次要重置view的位置，才能保证图片每次偏转量正常，而不是叠加，指针方向正确。
    arrowImageView.transform = CGAffineTransformIdentity;
    CGAffineTransform transform = CGAffineTransformMakeRotation(-1 * M_PI*newHeading.magneticHeading/180.0);
    
    arrowImageView.transform = transform;
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
        
        if (selectResourceIndex == tag) {
            if ([doType isEqualToString:@"isGuanlian"]) {
                annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
            }else if ([doType isEqualToString:@"isGLD"]) {
                if ([dict[@"resLogicName"] isEqualToString:@"pole"]){
                    annotationView.image = [UIImage Inc_imageNamed:@"icon_pole_cable"];
                }else if ([dict[@"resLogicName"] isEqualToString:@"supportingPoints"]){
                    annotationView.image = [UIImage Inc_imageNamed:@"icon_sp_cable"];
                }
            }else{
                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
            }
            
            //在大头针上绘制文字
            if ([dict[@"resLogicName"] isEqualToString:@"pole"]){
                UILabel *lable=[strUtil makeAnnotationViewLabel:dict[@"poleNo"] :dict[@"poleSubNo"] :@"P":YES];
               
                
                NSString * poleName = dict[@"poleSubName"];

                if ([poleName.lowercaseString rangeOfString:@"p"].length > 0) {
                    
                    poleName = [NSString stringWithFormat:@"P%@", [poleName componentsSeparatedByString:@"P"].lastObject];
                    
                }
                
                lable.text = poleName;
                [lable sizeToFit];
                
//                if ([lable.text isEqualToString:@"无序号"]) {
//                    lable.text = @"";
//                }
//
                
                if ([[dict valueForKey:@"deviceId"] integerValue] > 0) {
                    // 离线设备
                    lable.textColor = [UIColor mainColor];
                    lable.font = [UIFont boldSystemFontOfSize:13.f];
                }
                [annotationView addSubview:lable];
            }else if ([dict[@"resLogicName"] isEqualToString:@"supportingPoints"]){
                UILabel *lable=[strUtil makeAnnotationViewLabel:dict[@"supportNo"] :nil :@"CD":YES];
                
                if ([lable.text isEqualToString:@"无序号"]) {
                    lable.text = @"";
                }
                
                if ([[dict valueForKey:@"deviceId"] integerValue] > 0) {
                    // 离线设备
                    lable.textColor = [UIColor colorWithHexString:@"#dfc200"];
                    lable.font = [UIFont boldSystemFontOfSize:13.f];
                }
                [annotationView addSubview:lable];
            }
            
        }else if ([dict[@"resLogicName"] isEqualToString:@"pole"]){
            if ([doType isEqualToString:@"isGuanlian"]) {
                annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
            }else if ([doType isEqualToString:@"isGLD"]) {
                annotationView.image = [UIImage Inc_imageNamed:@"icon_pole_cable"];
            }else{
                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_3"];
            }
            
            //在大头针上绘制文字
            UILabel *lable=[strUtil makeAnnotationViewLabel:dict[@"poleNo"] :dict[@"poleSubNo"] :@"P":YES];
            
            NSString * poleName = dict[@"poleSubName"];
            
            if ([poleName.lowercaseString rangeOfString:@"p"].length > 0) {
                
                poleName = [NSString stringWithFormat:@"P%@", [poleName componentsSeparatedByString:@"P"].lastObject];
                
            }
            
            lable.text = poleName;
            [lable sizeToFit];
            
            
            
            if ([lable.text isEqualToString:@"无序号"]) {
                lable.text = @"";
            }
            if ([[dict valueForKey:@"deviceId"] integerValue] > 0) {
                // 离线设备
                lable.textColor = [UIColor mainColor];
                lable.font = [UIFont boldSystemFontOfSize:13.f];
            }
            [annotationView addSubview:lable];
        }else if ([dict[@"resLogicName"] isEqualToString:@"supportingPoints"]){
            if ([doType isEqualToString:@"isGuanlian"]) {
                annotationView.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];
            }else if ([doType isEqualToString:@"isGLD"]) {
                annotationView.image = [UIImage Inc_imageNamed:@"icon_sp_cable"];
            }else{
                annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_sp_tyk"];
            }
            
            //在大头针上绘制文字
            UILabel *lable=[strUtil makeAnnotationViewLabel:dict[@"supportNo"] :nil :@"CD":YES];
            
            if ([lable.text isEqualToString:@"无序号"]) {
                lable.text = @"";
            }
            if ([[dict valueForKey:@"deviceId"] integerValue] > 0) {
                // 离线设备
                lable.textColor = [UIColor colorWithHexString:@"#dfc200"];
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


// 显示当前地图中心点
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    

}



//-(void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState{
//
//    CGPoint point = CGPointMake(view.annotation.coordinate.latitude, view.annotation.coordinate.longitude);
//
//    NSLog(@"%@", NSStringFromCGPoint(point));
//
//}
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
            //关联杆路段模式
            if ([[resourceDic valueForKey:@"deviceId"] integerValue] > 0) {

                [YuanHUD HUDFullText:@"离线资源无法参与关联"];
                return;
            }
            
            //再次点击去除当前批量关联杆路段下末个资源
            NSString *clickResType = resourceDic[@"resLogicName"];
            NSString *clickResId;
            if ([clickResType isEqualToString:@"pole"]) {
                clickResId = [resourceDic objectForKey:@"GID"];
            }else if ([clickResType isEqualToString:@"supportingPoints"]){
                clickResId = [resourceDic objectForKey:@"supportingPointsId"];
            }
            if (poleSegInfoList.count>0) {
                NSMutableDictionary *lastPoleSeg = poleSegInfoList[poleSegInfoList.count-1];
                NSLog(@"lastPoleSeg%@",lastPoleSeg);
                if ([lastPoleSeg objectForKey:@"startPole_Id"]!=nil &&([lastPoleSeg objectForKey:@"endPole_Id"]==nil) &&([lastPoleSeg[@"startPole_Id"] isEqualToString:clickResId])) {
                    //上一个杆路段有起始但是无终止,最后一个点击的是起始资源
                    if ([resourceDic[@"resLogicName"] isEqualToString:@"pole"]) {
                        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_3"];
                    }else if ([resourceDic[@"resLogicName"] isEqualToString:@"supportingPoints"]){
                        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_sp_tyk"];
                    }
                    [poleSegInfoList removeObject:lastPoleSeg];
                    //当前杆路段个数大于0，则说明这个起始电杆也是上一段杆路段的终止电杆，需要将对应的终止电杆也remove掉
                    if (poleSegInfoList.count>0) {
                        int index = poleSegInfoList.count-1;
                        [poleSegInfoList[index] removeObjectForKey:@"endPole_Id"];
                        [poleSegInfoList[index] removeObjectForKey:@"endPole"];
                        NSString *poleSegName = [NSString stringWithFormat:@"%@（%@_",[self.poleLine objectForKey:@"poleLineName"],[poleSegInfoList[index] objectForKey:@"startPole"]];
                        [poleSegInfoList[index] setObject:poleSegName forKey:@"poleLineSegmentName"];
                        [poleSegInfoList[index] removeObjectForKey:@"endPole_Type"];
                        [poleSegInfoList[index] removeObjectForKey:@"poleLineSegmentLength"];
                        [poleSegInfoList[index] removeObjectForKey:@"zzlat"];
                        [poleSegInfoList[index] removeObjectForKey:@"zzlon"];
                    }
                    [_mapView deselectAnnotation:view.annotation animated:YES];
                    [self overloadMarks];
                    
                    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
                    if (resourceLocationArray[cusAnotation.tag-100000][@"doType"]!=nil) {
                        [resourceLocationArray[cusAnotation.tag-100000] removeObjectForKey:@"doType"];
                    }
                    
                    return;
                }else if ([lastPoleSeg objectForKey:@"startPole_Id"]!=nil &&([lastPoleSeg objectForKey:@"endPole_Id"]!=nil) &&([lastPoleSeg[@"endPole_Id"] isEqualToString:clickResId])) {
                    //上一个杆路段有起始且有终止,最后一个点击的是终止资源
                    if ([resourceDic[@"resLogicName"] isEqualToString:@"pole"]) {
                        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_3"];
                    }else if ([resourceDic[@"resLogicName"] isEqualToString:@"supportingPoints"]){
                        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_sp_tyk"];
                    }
                    
                    [lastPoleSeg removeObjectForKey:@"endPole_Id"];
                    [lastPoleSeg removeObjectForKey:@"endPole"];
                    NSString *poleSegName = [NSString stringWithFormat:@"%@（%@_",[self.poleLine objectForKey:@"poleLineName"],[lastPoleSeg objectForKey:@"startPole"]];
                    [lastPoleSeg setObject:poleSegName forKey:@"poleLineSegmentName"];
                    [lastPoleSeg removeObjectForKey:@"endPole_Type"];
                    [lastPoleSeg removeObjectForKey:@"poleLineSegmentLength"];
                    [lastPoleSeg removeObjectForKey:@"zzlat"];
                    [lastPoleSeg removeObjectForKey:@"zzlon"];
                    [_mapView deselectAnnotation:view.annotation animated:YES];
                    [self overloadMarks];
                    
                    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
                    if (resourceLocationArray[cusAnotation.tag-100000][@"doType"]!=nil) {
                        [resourceLocationArray[cusAnotation.tag-100000] removeObjectForKey:@"doType"];
                    }
                    
                    return;
                }
            }
            
            //当点了虚拟杆路段列表里已经有了的资源后，再点不做响应
            if (poleSegInfoList.count>0) {
                for (int i = 0; i<poleSegInfoList.count; i++) {
                    NSDictionary *poleSeg = poleSegInfoList[i];
                    if (([poleSeg[@"startPole_Type"] isEqualToString:@"1"]&&[resourceDic[@"resLogicName"] isEqualToString:@"pole"])&&[resourceDic[@"GID"] isEqualToString:poleSeg[@"startPole_Id"]]) {
                        NSLog(@"起始相同");
                        return;
                    }else if (([poleSeg[@"startPole_Type"] isEqualToString:@"2"]&&[resourceDic[@"resLogicName"] isEqualToString:@"supportingPoints"])&&[resourceDic[@"supportingPointsId"] isEqualToString:poleSeg[@"startPole_Id"]]){
                        NSLog(@"起始相同");
                        return;
                    }
                    if (([poleSeg[@"startPole_Type"] isEqualToString:@"1"]&&[resourceDic[@"resLogicName"] isEqualToString:@"pole"])&&[resourceDic[@"GID"] isEqualToString:poleSeg[@"endPole_Id"]]) {
                        NSLog(@"终止相同");
                        return;
                    }else if([poleSeg[@"startPole_Type"] isEqualToString:@"2"]&&[resourceDic[@"resLogicName"] isEqualToString:@"supportingPoints"] && [resourceDic[@"supportingPointsId"] isEqualToString:poleSeg[@"endPole_Id"]]){
                        NSLog(@"终止相同");
                        return;
                    }
                }
            }
            //判断所选择的两个电杆是否都不在当前杆路下，如果不是，不能让用户进行关联操作 2017.03.31日新增
            if ([resourceDic[@"resLogicName"] isEqualToString:@"pole"] && (poleSegInfoList.count>0)) {
                NSDictionary *lastPoleSeg = poleSegInfoList[poleSegInfoList.count-1];
                BOOL isCanGuanlian = YES;
                if ([lastPoleSeg objectForKey:@"startPole_Id"]!=nil &&([lastPoleSeg objectForKey:@"endPole_Id"]==nil) && (lastPoleSeg[@"startPole_Type"]==nil||[lastPoleSeg[@"startPole_Type"] isEqualToString:@"1"]) ) {
                    //上一个杆路段有起始但是无终止并且起始为电杆时，进入到是否为两个附近杆进行关联操作判断
                    if (![lastPoleSeg[@"qspoleLine_Id"] isEqualToString:self.poleLine[@"GID"]] && ![resourceDic[@"poleLine_Id"] isEqualToString:self.poleLine[@"GID"]]) {
                        isCanGuanlian = NO;
                    }
                }else if ([lastPoleSeg objectForKey:@"startPole_Id"]!=nil &&([lastPoleSeg objectForKey:@"endPole_Id"]!=nil) &&
                          (lastPoleSeg[@"endPole_Type"]==nil||[lastPoleSeg[@"endPole_Type"] isEqualToString:@"1"])){
                    //上一个杆路段既有起始也有终止并且终止为电杆时，进入到是否为两个附近杆进行关联操作判断
                    if (![lastPoleSeg[@"zzpoleLine_Id"] isEqualToString:self.poleLine[@"GID"]] && ![resourceDic[@"poleLine_Id"] isEqualToString:self.poleLine[@"GID"]]) {
                        isCanGuanlian = NO;
                    }
                }
                if (!isCanGuanlian) {
                
                    [YuanHUD HUDFullText:@"当前关联的两个电杆都不在此杆路下!"];
                    
                    [_mapView deselectAnnotation:view.annotation animated:YES];
                    return;
                }
                
            }
            view.image = [UIImage Inc_imageNamed:@"iconmarka_bianse"];//startPole_Type 1,2
            NSMutableDictionary *poleSegInfo;//当前待关联的杆路段
            
            if (poleSegInfoList.count>0) {
                NSDictionary *lastPoleSeg = poleSegInfoList[poleSegInfoList.count-1];
                
                if ([lastPoleSeg objectForKey:@"startPole_Id"]!=nil &&([lastPoleSeg objectForKey:@"endPole_Id"]==nil)) {
                    //上一个杆路段有起始但是无终止
                    poleSegInfo = [[NSMutableDictionary alloc] initWithDictionary:poleSegInfoList[poleSegInfoList.count-1]];
                    if ([resourceDic[@"resLogicName"] isEqualToString:@"pole"]) {
                        [poleSegInfo setObject:[resourceDic objectForKey:@"GID"] forKey:@"endPole_Id"];
                        [poleSegInfo setObject:[resourceDic objectForKey:@"poleSubName"] forKey:@"endPole"];
                        NSString *poleSegName = [NSString stringWithFormat:@"%@%@）",[poleSegInfo objectForKey:@"poleLineSegmentName"],[resourceDic objectForKey:@"poleSubName"]];
                        [poleSegInfo setObject:poleSegName forKey:@"poleLineSegmentName"];
                        [poleSegInfo setObject:@"1" forKey:@"endPole_Type"];
                    }else if ([resourceDic[@"resLogicName"] isEqualToString:@"supportingPoints"]){
                        poleSegInfo = [[NSMutableDictionary alloc] initWithDictionary:poleSegInfoList[poleSegInfoList.count-1]];
                        [poleSegInfo setObject:[resourceDic objectForKey:@"supportingPointsId"] forKey:@"endPole_Id"];
                        [poleSegInfo setObject:[resourceDic objectForKey:@"supportPSubName"] forKey:@"endPole"];
                        NSString *poleSegName = [NSString stringWithFormat:@"%@%@）",[poleSegInfo objectForKey:@"poleLineSegmentName"],[resourceDic objectForKey:@"supportPSubName"]];
                        [poleSegInfo setObject:poleSegName forKey:@"poleLineSegmentName"];
                        [poleSegInfo setObject:@"2" forKey:@"endPole_Type"];
                    }
                    [poleSegInfo setObject:[resourceDic objectForKey:@"lat"] forKey:@"zzlat"];
                    [poleSegInfo setObject:[resourceDic objectForKey:@"lon"] forKey:@"zzlon"];
                    if ([resourceDic objectForKey:@"poleLine_Id"]!=nil) {
                        [poleSegInfo setObject:[resourceDic objectForKey:@"poleLine_Id"] forKey:@"zzpoleLine_Id"];
                    }
                    poleSegInfoList[poleSegInfoList.count-1] = poleSegInfo;
                }else if ([lastPoleSeg objectForKey:@"startPole_Id"]!=nil &&([lastPoleSeg objectForKey:@"endPole_Id"]!=nil)){
                    //上一个杆路段既有起始也有终止，此次点击需要将上一个杆路段的终止设为当前起始，且此次点击的资源设为终止
                    poleSegInfo = [[NSMutableDictionary alloc] init];
                    [poleSegInfo setObject:[lastPoleSeg objectForKey:@"endPole_Id"] forKey:@"startPole_Id"];
                    [poleSegInfo setObject:[lastPoleSeg objectForKey:@"endPole"] forKey:@"startPole"];
                    NSString *poleSegName = [NSString stringWithFormat:@"%@（%@_",[self.poleLine objectForKey:@"poleLineName"],[lastPoleSeg objectForKey:@"endPole"]];
                    [poleSegInfo setObject:poleSegName forKey:@"poleLineSegmentName"];
                    [poleSegInfo setObject:[lastPoleSeg objectForKey:@"endPole_Type"] forKey:@"startPole_Type"];
                    [poleSegInfo setObject:[lastPoleSeg objectForKey:@"zzlat"] forKey:@"qslat"];
                    [poleSegInfo setObject:[lastPoleSeg objectForKey:@"zzlon"] forKey:@"qslon"];
                    if ([lastPoleSeg objectForKey:@"zzpoleLine_Id"]!=nil) {
                        [poleSegInfo setObject:[lastPoleSeg objectForKey:@"zzpoleLine_Id"] forKey:@"qspoleLine_Id"];
                    }
                    
                    if ([resourceDic[@"resLogicName"] isEqualToString:@"pole"]) {
                        [poleSegInfo setObject:[resourceDic objectForKey:@"GID"] forKey:@"endPole_Id"];
                        [poleSegInfo setObject:[resourceDic objectForKey:@"poleSubName"] forKey:@"endPole"];
                        poleSegName = [NSString stringWithFormat:@"%@%@）",[poleSegInfo objectForKey:@"poleLineSegmentName"],[resourceDic objectForKey:@"poleSubName"]];
                        [poleSegInfo setObject:poleSegName forKey:@"poleLineSegmentName"];
                        [poleSegInfo setObject:@"1" forKey:@"endPole_Type"];
                    }else if ([resourceDic[@"resLogicName"] isEqualToString:@"supportingPoints"]){
                        [poleSegInfo setObject:[resourceDic objectForKey:@"supportingPointsId"] forKey:@"endPole_Id"];
                        [poleSegInfo setObject:[resourceDic objectForKey:@"supportPSubName"] forKey:@"endPole"];
                        poleSegName = [NSString stringWithFormat:@"%@%@）",[poleSegInfo objectForKey:@"poleLineSegmentName"],[resourceDic objectForKey:@"supportPSubName"]];
                        [poleSegInfo setObject:poleSegName forKey:@"poleLineSegmentName"];
                        [poleSegInfo setObject:@"2" forKey:@"endPole_Type"];
                    }
                    
                    [poleSegInfo setObject:[resourceDic objectForKey:@"lat"] forKey:@"zzlat"];
                    [poleSegInfo setObject:[resourceDic objectForKey:@"lon"] forKey:@"zzlon"];
                    if ([resourceDic objectForKey:@"poleLine_Id"]!=nil) {
                        [poleSegInfo setObject:[resourceDic objectForKey:@"poleLine_Id"] forKey:@"zzpoleLine_Id"];
                    }
                    
                    [poleSegInfoList addObject:poleSegInfo];
                }
            }else{
                //进行关联杆路段的首个资源
                poleSegInfo = [[NSMutableDictionary alloc] init];
                if ([resourceDic[@"resLogicName"] isEqualToString:@"pole"]) {
                    [poleSegInfo setObject:[resourceDic objectForKey:@"GID"] forKey:@"startPole_Id"];
                    [poleSegInfo setObject:[resourceDic objectForKey:@"poleSubName"] forKey:@"startPole"];
                    NSString *poleSegName = [NSString stringWithFormat:@"%@（%@_",[self.poleLine objectForKey:@"poleLineName"],[resourceDic objectForKey:@"poleSubName"]];
                    [poleSegInfo setObject:poleSegName forKey:@"poleLineSegmentName"];
                    [poleSegInfo setObject:@"1" forKey:@"startPole_Type"];
                }else if ([resourceDic[@"resLogicName"] isEqualToString:@"supportingPoints"]){
                    [poleSegInfo setObject:[resourceDic objectForKey:@"supportingPointsId"] forKey:@"startPole_Id"];
                    [poleSegInfo setObject:[resourceDic objectForKey:@"supportPSubName"] forKey:@"startPole"];
                    NSString *poleSegName = [NSString stringWithFormat:@"%@（%@_",[self.poleLine objectForKey:@"poleLineName"],[resourceDic objectForKey:@"supportPSubName"]];
                    [poleSegInfo setObject:poleSegName forKey:@"poleLineSegmentName"];
                    [poleSegInfo setObject:@"2" forKey:@"startPole_Type"];
                }
                [poleSegInfo setObject:[resourceDic objectForKey:@"lat"] forKey:@"qslat"];
                [poleSegInfo setObject:[resourceDic objectForKey:@"lon"] forKey:@"qslon"];
                if ([resourceDic objectForKey:@"poleLine_Id"]!=nil) {
                    [poleSegInfo setObject:[resourceDic objectForKey:@"poleLine_Id"] forKey:@"qspoleLine_Id"];
                }
                
                [poleSegInfoList addObject:poleSegInfo];
            }
            NSLog(@"poleSegInfoList:%@",poleSegInfoList);
            
            
            //添加自定义属性，规避高德地图回调重加在问题
            resourceLocationArray[cusAnotation.tag-100000] = [[NSMutableDictionary alloc] initWithDictionary:resourceDic];
            [resourceLocationArray[cusAnotation.tag-100000] setObject:@"isGuanlian" forKey:@"doType"];
            
            double qslat = [poleSegInfo[@"qslat"] doubleValue];
            double qslon = [poleSegInfo[@"qslon"] doubleValue];
            double zzlat = [poleSegInfo[@"zzlat"] doubleValue];
            double zzlon = [poleSegInfo[@"zzlon"] doubleValue];
            //计算杆路段长度
            NSLog(@"qslat:%f,qslon:%f,zzlat:%f,zzlon:%f",qslat,qslon,zzlat,zzlon);
            if (qslat!=0.000000&&qslon!=0.000000&&zzlat!=0.000000&&zzlon!=0.000000) {
                float poleLineSegmentLength = [self poleLineSegmentLengthWithLat1:qslat Lon1:qslon Lat2:zzlat Lon2:zzlon];
                [poleSegInfo setObject:[NSString stringWithFormat:@"%f",poleLineSegmentLength] forKey:@"poleLineSegmentLength"];
                if (self.poleLine[@"retion"]!=nil) {
                    [poleSegInfo setObject:self.poleLine[@"retion"] forKey:@"retion"];
                }
                if (self.poleLine[@"areaname"]!=nil) {
                    [poleSegInfo setObject:self.poleLine[@"areaname"] forKey:@"areaname"];
                }
                if (self.poleLine[@"areaname_Id"]!=nil) {
                    [poleSegInfo setObject:self.poleLine[@"areaname_Id"] forKey:@"areaname_Id"];
                }
                if (poleSegInfo[@"poleLineSegmentName"]!=nil) {
                    [poleSegInfo setObject:poleSegInfo[@"poleLineSegmentName"] forKey:@"poleLineSegmentCode"];
                }
                
                [self addTempLineView];
                
                
                
                NSLog(@"…………………………%@",poleSegInfoList);
            }
            //取消当前大头针的点击事件，方便用户再次点击时撤销关联杆路段操作
            [_mapView deselectAnnotation:view.annotation animated:YES];
        }else if (isGLD){
            //关联光缆段模式
            if (isPLCable&&(plPoleSpCableInfoList == nil || plPoleSpCableInfoList.count == 0)) {

                [YuanHUD HUDFullText:@"请选择待穿的缆段"];

                //取消当前大头针的点击事件，方便用户再次点击时撤销关联杆路段操作
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
                            for (NSDictionary *poleSpTempDic in plPoleSpCableInfoList) {
                                if ([temp[i] isEqualToString:[poleSpTempDic objectForKey:@"cableId"]]) {
                                    [hadCableListArr addObject:poleSpTempDic[@"cableName"]];
                                }
                            }
                        }
                        if (hadCableListArr.count>0) {
                            NSString *resourceTypeStr;
                            if ([resourceDic[@"resLogicName"] isEqualToString:@"pole"]) {
                                resourceTypeStr = @"电杆";
                            }else if ([resourceDic[@"resLogicName"] isEqualToString:@"supportingPoints"]){
                                resourceTypeStr = @"撑点";
                            }
                            NSMutableString *messageStr = [[NSMutableString alloc] init];
                            for (NSString *name in hadCableListArr) {
                                [messageStr appendFormat:@"%@\n",name];
                            }
                            UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"该%@已关联了如下光缆",resourceTypeStr] message:messageStr preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction * sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
                            [alert addAction:sure];
                            
                            Present(self, alert);
                            //取消当前大头针的点击事件，方便用户再次点击时撤销关联杆路段操作
                            [_mapView deselectAnnotation:view.annotation animated:YES];
                            return;
                        }
                    }else{
                        for (int i = 0; i<temp.count; i++) {
                            if ([temp[i] isEqualToString:[poleSpCableInfo objectForKey:@"cableId"]]) {

                                if ([resourceDic[@"resLogicName"] isEqualToString:@"pole"]) {

                                    [YuanHUD HUDFullText:@"该电杆已经关联了该光缆"];

                                }else if ([resourceDic[@"resLogicName"] isEqualToString:@"supportingPoints"]){

                                    [YuanHUD HUDFullText:@"该撑点已经关联了该光缆"];
                                }
                                
                                //取消当前大头针的点击事件，方便用户再次点击时撤销关联杆路段操作
                                [_mapView deselectAnnotation:view.annotation animated:YES];
                                return;
                            }
                        }
                    }
                }
            }
            BOOL isHave = NO;
            for (int i = 0; i<poleSpCableInfoList.count; i++) {
                if ([resourceDic[@"resLogicName"] isEqualToString:@"pole"] && [[poleSpCableInfoList[i] objectForKey:@"GID"] isEqualToString:[resourceDic objectForKey:@"GID"]]) {
                    //电杆的场合
                    isHave = YES;
                    [poleSpCableInfoList removeObjectAtIndex:i];
                    
                    for (int j = 0; j<upPlList.count; j++) {
                        if ([[upPlList[j] objectForKey:@"GID"] isEqualToString:[resourceDic objectForKey:@"GID"]]) {
                            [upPlList removeObjectAtIndex:j];
                            break;
                        }
                    }
                    view.image = [UIImage Inc_imageNamed:@"icon_gcoding_3"];
                    
                    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
                    if (resourceLocationArray[cusAnotation.tag-100000][@"doType"]!=nil) {
                        [resourceLocationArray[cusAnotation.tag-100000] removeObjectForKey:@"doType"];
                    }
                    
                    break;
                }else if ([resourceDic[@"resLogicName"] isEqualToString:@"supportingPoints"] && [[poleSpCableInfoList[i] objectForKey:@"supportingPointsId"] isEqualToString:[resourceDic objectForKey:@"supportingPointsId"]]) {
                    //撑点的场合
                    isHave = YES;
                    [poleSpCableInfoList removeObjectAtIndex:i];
                    
                    for (int j = 0; j<upPlList.count; j++) {
                        if ([[upPlList[j] objectForKey:@"supportingPointsId"] isEqualToString:[resourceDic objectForKey:@"supportingPointsId"]]) {
                            [upPlList removeObjectAtIndex:j];
                            break;
                        }
                    }
                    view.image = [UIImage Inc_imageNamed:@"icon_gcoding_sp_tyk"];
                    
                    //去掉手机端为了规避高德地图回调显示所添加的自定义属性字段
                    if (resourceLocationArray[cusAnotation.tag-100000][@"doType"]!=nil) {
                        [resourceLocationArray[cusAnotation.tag-100000] removeObjectForKey:@"doType"];
                    }
                    
                    break;
                }
            }
            if (!isHave) {
                [poleSpCableInfoList addObject:resourceDic];
                if ([resourceDic[@"resLogicName"] isEqualToString:@"pole"]) {
                    view.image = [UIImage Inc_imageNamed:@"icon_pole_cable"];
                }else if ([resourceDic[@"resLogicName"] isEqualToString:@"supportingPoints"]){
                    view.image = [UIImage Inc_imageNamed:@"icon_sp_cable"];
                }
                //添加自定义属性，规避高德地图回调重加在问题
                resourceLocationArray[cusAnotation.tag-100000] = [[NSMutableDictionary alloc] initWithDictionary:resourceDic];
                [resourceLocationArray[cusAnotation.tag-100000] setObject:@"isGLD" forKey:@"doType"];
                
                if (isPLCable) {
                    if (upPlList == nil) {
                        upPlList = [[NSMutableArray alloc] init];
                    }
                    //todo:发送报文方式需要和中心定,目前还按照原来
                    for (NSDictionary *tempDic in plPoleSpCableInfoList) {
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
            //取消当前大头针的点击事件，方便用户再次点击时撤销关联杆路段操作
            [_mapView deselectAnnotation:view.annotation animated:YES];
        }else{
            //查看所选资源的详细信息
            //            获取地图的所有标注点 同时获取标注点的标注view
            for (CusMAPointAnnotation *cmpa in [mapView annotations]) {
                MAAnnotationView * maav = [_mapView viewForAnnotation:cmpa];
                if ([maav isKindOfClass:[MAPointAnnotation class]]) {
                    NSDictionary * dict = resourceLocationArray[maav.tag-100000];
                    if ([dict[@"resLogicName"] isEqualToString:@"pole"]) {
                        maav.image = [UIImage Inc_imageNamed:@"icon_gcoding_3"];
                    }else if ([dict[@"resLogicName"] isEqualToString:@"supportingPoints"]){
                        maav.image = [UIImage Inc_imageNamed:@"icon_gcoding_2"];
                    }
                    
                }
            }
            view.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
            // 设置当前地图的中心点 把选中的标注作为地图中心点
            [_mapView setCenterCoordinate:view.annotation.coordinate animated:YES] ;
            selectResourceIndex = [view.annotation.subtitle intValue];
            //跳转到详细信息界面
            if ([resourceDic[@"resLogicName"] isEqualToString:@"pole"]) {
                TYKDeviceInfoMationViewController * pole = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_poleModel withViewModel:_poleViewModel withDataDict:resourceDic withFileName:@"pole"];
                pole.delegate = self;
                
                //先写死
                pole.isOffline = NO;
                pole.isSubDevice = NO;
                
                isAdd = NO;
                [self.navigationController pushViewController:pole animated:YES];
            }else if ([resourceDic[@"resLogicName"] isEqualToString:@"supportingPoints"]){
                //跳转到详细信息界面
                TYKDeviceInfoMationViewController * sp = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_spModel withViewModel:_spViewModel withDataDict:resourceDic withFileName:@"supportingPoints"];
                sp.delegate = self;
                //先写死
                sp.isOffline = NO;

                isAdd = NO;
                [self.navigationController pushViewController:sp animated:YES];
            }
        }
        [_mapView selectAnnotation:nil animated:NO];
    }
}
//根据overlay生成对应的View
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[CusMAPolyline class]])
    {
        MAPolylineRenderer* polylineView = [[MAPolylineRenderer alloc] initWithOverlay:overlay];
        CusMAPolyline *temp = (CusMAPolyline * )overlay;
        if (temp.type == 1) {
//            polylineView.lineDash     = YES;
        }
        polylineView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:1];
        polylineView.lineWidth = 5.0;
        
        return polylineView;
    }
    return nil;
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
}
//批量关联光缆段功能所选择的光缆段回调代理方法
-(void)getCable:(NSDictionary *)cable{
    isGLD = YES;
    //批量关联光缆段，选择光缆段后返回
    //显示光缆段名称 进入光缆段关联模式 关联光缆段按钮变成确认
    poleSpCableInfo = cable;
    cableTextView.text = [poleSpCableInfo objectForKey:@"cableName"];
    [guanlianCableBtn setTitle:@"确认" forState:UIControlStateNormal];
    [guanlianCableView setHidden:NO];
    poleSpCableInfoList = [[NSMutableArray alloc] init];
    if (isPLCable) {
        if (plGuanlanCableStateDic == nil) {
            plGuanlanCableStateDic = [[NSMutableDictionary alloc] init];
        }
        if (plGuanlanCable == nil) {
            plGuanlanCable = [[NSMutableArray alloc] init];
        }
        if (plPoleSpCableInfoList == nil) {
            plPoleSpCableInfoList = [[NSMutableArray alloc] init];//这个是实际要关联的一个数据列表
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
                    [plPoleSpCableInfoList addObject:cableDic];
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
                [plPoleSpCableInfoList addObject:cable];
            }
        }
        [self.poleTableView reloadData];
    }
}
-(void)newSpWithDict:(NSDictionary *)dict{
    NSLog(@" ==== = == ===== == == ===== == =%@",dict);
    if (isAdd) {
        //新添加的撑点一定有经纬度，因此需要刷新地图数据
        [self.resourceLocationArray addObject:dict];
        //标记值恢复初始
        selectResourceIndex = 1000000;
        isAdd = NO;
    }else{
        //循环地图上显示的资源列表，如果为撑点类型时，判断修改的是哪个撑点
        for (int i = 0; i<resourceLocationArray.count; i++) {
            if ([resourceLocationArray[i][@"resLogicName"] isEqualToString:@"supportingPoints"] && [resourceLocationArray[i][@"supportingPointsId"] isEqualToString:dict[@"supportingPointsId"]]) {
                [resourceLocationArray replaceObjectAtIndex:i withObject:dict];
                break;
            }
        }
    }
}

-(void)newPoleWithDict:(NSDictionary *)dict{
    NSLog(@" ==== = == ===== == == ===== == =%@",dict);
    NSLog(@"😝%@", resourceLocationArray);
    if (isAdd) {
        //新添加的电杆一定在当前杆路下，因此需要刷新当前杆路下电杆列表
        [self.poleArray addObject:dict];
        [self.poleTableView reloadData];
        //新添加的电杆一定有经纬度，因此需要刷新地图数据
        [self.resourceLocationArray addObject:dict];
        //标记值恢复初始
        selectResourceIndex = 1000000;
        isAdd = NO;
        
        [self addOverlayView];
        [self addLineView];
        
    }else{
        //在线情况下
        //1.循环当前杆路下电杆列表
        for (int i = 0; i<poleArray.count; i++) {
            if ([poleArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
                [poleArray replaceObjectAtIndex:i withObject:dict];
                break;
            }
        }
        [self.poleTableView reloadData];
        //2.循环地图上显示的资源列表，如果为电杆类型时，判断修改的是哪根电杆
        for (int i = 0; i<resourceLocationArray.count; i++) {
            if ([resourceLocationArray[i][@"resLogicName"] isEqualToString:@"pole"] && [resourceLocationArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
                [resourceLocationArray replaceObjectAtIndex:i withObject:dict];
                break;
            }
        }
        
        
    }
//    [self.navigationController popViewControllerAnimated:YES];
}
-(void)newSupportingPoints:(NSDictionary<NSString *,NSString *> *)dict{
    NSLog(@" ==== = == ===== == == ===== == =%@",dict);
    if (isAdd) {
        //新添加的撑点一定有经纬度，因此需要刷新地图数据
        [self.resourceLocationArray addObject:dict];
        //标记值恢复初始
        selectResourceIndex = 1000000;
        isAdd = NO;
    }else{
        //循环地图上显示的资源列表，如果为撑点类型时，判断修改的是哪个撑点
        for (int i = 0; i<resourceLocationArray.count; i++) {
            if ([resourceLocationArray[i][@"resLogicName"] isEqualToString:@"supportingPoints"] && [resourceLocationArray[i][@"supportingPointsId"] isEqualToString:dict[@"supportingPointsId"]]) {
                [resourceLocationArray replaceObjectAtIndex:i withObject:dict];
                break;
            }
        }
    }
}
-(void)deleteSpWithDict:(NSDictionary *)dict{
    // 删除事件
    
#ifdef BaseURL
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL, _spModel.delete_name];
#else
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL_Auto(([IWPServerService sharedService].link)), _spModel.delete_name];
#endif
    
    NSLog(@"%@",requestURL);
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setValue:UserModel.uid forKey:@"UID"];
    
    [param setValue:DictToString(dict) forKey:@"jsonRequest"];
    __weak typeof(self) wself = self;
    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除成功" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [wself.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert addAction:action];
        Present(self.navigationController, alert);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}

-(void)deleteSp:(NSDictionary *)dict class:(Class)class{
    selectResourceIndex = 1000000;
    //循环地图上显示的资源列表，如果为撑点类型时，判断删除的是哪个撑点
    for (int i = 0; i<resourceLocationArray.count; i++) {
        if ([resourceLocationArray[i][@"resLogicName"] isEqualToString:@"supportingPoints"] && [resourceLocationArray[i][@"supportingPointsId"] isEqualToString:dict[@"supportingPointsId"]]) {
            [resourceLocationArray removeObjectAtIndex:i];
            break;
        }
    }
    
    [self deleteSpWithDict:dict];
    
    NSLog(@"删除撑点");
}
-(void)deletePole:(NSDictionary *)dict class:(Class)class{
   
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    
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
            [YuanHUD HUDHide];
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除成功" preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                selectResourceIndex = 1000000;
                //在线情况下
                //1.循环当前杆路下电杆列表
                for (int i = 0; i<poleArray.count; i++) {
                    if ([poleArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
                        [poleArray removeObjectAtIndex:i];
                        break;
                    }
                }
                [self.poleTableView reloadData];
                //2.循环地图上显示的资源列表，如果为电杆类型时，判断删除的是哪根电杆
                for (int i = 0; i<resourceLocationArray.count; i++) {
                    if ([resourceLocationArray[i][@"resLogicName"] isEqualToString:@"pole"] && [resourceLocationArray[i][@"GID"] isEqualToString:dict[@"GID"]]) {
                        [resourceLocationArray removeObjectAtIndex:i];
                        break;
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

                [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",[dic objectForKey:@"info"]]];

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

-(void)deleteDeviceWithDict:(NSDictionary *)dict withViewControllerClass:(__unsafe_unretained Class)vcClass{
    NSLog(@"----dict:%@",dict);
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确定要删除该%@?",[dict[@"resLogicName"] isEqualToString:@"pole"]?@"电杆":@"撑点"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([dict[@"resLogicName"] isEqualToString:@"pole"]) {
            [self deletePole:dict class:vcClass];
        }else if ([dict[@"resLogicName"] isEqualToString:@"supportingPoints"]){
            [self deleteSp:dict class:vcClass];
        }
        
        
    }];
    UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        return;
    }];
    
    [alert addAction:actionYES];
    [alert addAction:actionNO];
    Present(self, alert);
}
-(void)newDeciceWithDict:(NSDictionary<NSString *,NSString *> *)dict{
    NSLog(@"dict:%@",dict);
    if ([dict[@"resLogicName"] isEqualToString:@"pole"]) {
        //电杆
        [self newPoleWithDict:dict];
        
    }else if ([dict[@"resLogicName"] isEqualToString:@"supportingPoints"]){
        //撑点
        [self newSpWithDict:dict];
    }
}
-(void)didReciveANewOnlineToOfflineSubDevice:(NSDictionary *)dict isAdd:(BOOL)isAdd{
    // 获取到在线设备加入的离线设备
    [self newPoleWithDict:dict];
}
@end
