//
//  GisTYKMainViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/12/13.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//
#import "GisTYKMainViewController.h"

#import "CusButton.h"


#import "StrUtil.h"
#import "Yuan_PointAnnotation.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

//#import "IWPPropertiesReader.h"
//#import "TYKDeviceInfoMationViewController.h"

#import "Yuan_PolyLine.h"
#import "CommonUtility.h"
#import  <QuartzCore/CoreAnimation.h>
#import "YKLListView.h"
#import "YKLListViewCell.h"
//#import "GisRegionSelectViewController.h"     //切换地区使用
//#import "HelpViewController.h"                //GIS定位帮助
#import "IWPGISSiftViewController.h"            //获取资源

#import "Inc_NewMB_VM.h"
#import "Inc_Push_MB.h"

#define kUID @"UID" // 用户唯一ID字段
#define kJsonRequest @"jsonRequest" // 数据请求
#define kInfo @"info" // 返回信息
#define kResult @"result" // 请求结果
@interface GisTYKMainViewController ()
<
    UIActionSheetDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    YKLListViewCellDelegate
>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic,strong) NSMutableDictionary *poiinfo;//资源列表
@property (nonatomic,strong) NSDictionary *poiclick;//选择的资源
@property(strong,nonatomic) NSMutableArray *nameArray;//资源名称列表

//@property (nonatomic, strong) IWPPropertiesReader * reader;
//@property (nonatomic, strong) IWPPropertiesSourceModel * mainModel;
//@property (nonatomic, strong) NSArray <IWPViewModel *>* viewModel;

@property (nonatomic, assign) CLLocationCoordinate2D selectedCoordinate;

@property (nonatomic, weak) YKLListView * shaiXuanListView;
@property (nonatomic, strong) NSArray * shaiXuanDataSource;
@property (nonatomic, weak) YKLListView * plusListView;
@property (nonatomic, strong) NSMutableArray * plusDataSource;

@property (nonatomic, strong) NSArray <NSDictionary *> * switcherDataSource;
@property (nonatomic, strong) NSArray <NSNumber *> * plusSwitcherDataSource;

@property (nonatomic, strong) NSArray <NSString *> * imageNames;



@property (nonatomic, weak) UIButton * guanlianBtn;
@property (nonatomic, weak) UIButton * gualanBtn;

/**
 正在关联资源
 */
@property (nonatomic, assign) BOOL isGuanlian;

/**
 正在挂缆
 */
@property (nonatomic, assign) BOOL isGualan;

@property (nonatomic, strong) NSMutableArray * guanlianList;
//@property (nonatomic, strong) NSMutableDictionary * tempGuanlianDict;

@property (nonatomic, strong) NSMutableArray * gualanList;

/**
 选中光缆信息
 */
@property (nonatomic, strong) NSDictionary * cableInfo;
/**
 选择光缆段名称显示label
 */
@property (nonatomic, weak) UILabel * cableNameLabel;

//@property (nonatomic, strong) NSMutableDictionary * tempGualanDict;

@end
@implementation GisTYKMainViewController
{
    MBProgressHUD *HUD;
    UIImageView *icm;//手动定位图标
    double lat,lon;//当前定位坐标
    BOOL isFirst;//是否是首次进来
    BOOL isLocationSelf;//是否手动定位
    NSString * latStr, * lonStr;
    
    NSInteger annotationIndex;
    NSArray *NameAndImageArray;//名称和图片界面数组
    NSMutableArray *images;//获取到的图片数组
    NSMutableDictionary *temp;//当前选择的资源;
    StrUtil *strUtil;
    int index;
    
    UIButton *guanlianBtn;
    BOOL isAddGuanlian;//当前是否为添加资源关联模式
    BOOL isDeleteGuanlan;//当前是否为删除资源关联模式
    NSMutableArray *guanlianArr;//资源关联操作数组
    BOOL isCusCallOutShow;//当前是否显示了自定义气泡界面
    
    NSArray *searchSelectArray;//查询类型选择页面数组
    NSArray *searchLabelArray;//查询类型选择页面下划线装饰数组
    
    NSMutableArray *shaixuanDArr,*shaixuanXArr;
    NSMutableArray *plusDataSourceMapData;//更多按钮滑动删除同步数据
    
    float dynamicLat ;
    float dynamicLog ;
    
    NSString * ID_res;
    
    Inc_UserModel * _userModel;
}
@synthesize coordinate;

//-(NSMutableDictionary *)tempGuanlianDict{
//
//    if (_tempGuanlianDict == nil) {
//        _tempGuanlianDict = [NSMutableDictionary dictionary];
//    }
//    return _tempGuanlianDict;
//}
//-(NSMutableDictionary *)tempGualanDict{
//
//    if (_tempGualanDict) {
//        _tempGualanDict = [NSMutableDictionary dictionary];
//    }
//    return _tempGualanDict;
//}

- (UILabel *)cableNameLabel{
    
    if (_cableNameLabel == nil) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.size.height - IphoneSize_Height(60.f), ScreenWidth, IphoneSize_Height(60.f))];
        _cableNameLabel = label;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        
    }
    
    return _cableNameLabel;
    
}


-(NSMutableArray *)guanlianList{
    if (_guanlianList == nil) {
        _guanlianList = [NSMutableArray array];
    }
    return _guanlianList;
}
-(NSMutableArray *)gualanList{
    if (_gualanList == nil) {
        _gualanList = [NSMutableArray array];
    }
    return _gualanList;
}

- (void)viewDidLoad {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"GIS定位";
    
    [self initNavigationBar];
    
    _userModel = UserModel;
    
    
    strUtil = [[StrUtil alloc] init];
    isFirst = YES;
    isLocationSelf = NO;
    index = -1;
    isAddGuanlian = NO;
    isDeleteGuanlan = NO;
    guanlianArr = [[NSMutableArray alloc] init];
    isCusCallOutShow = NO;
    self.plusDataSource = [[NSMutableArray alloc] init];
    plusDataSourceMapData = [[NSMutableArray alloc] init];
    
//    [self uiNewInit];
    [self configSubviews];
    //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
    _mapView.userTrackingMode=MAUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;//显示定位图层
    
    if (self.point !=nil) {
        //从端子进来看路由的
        NSString *fiberStationName = [self.point objectForKey:@"FIBERSTATIONNAME"];
        if (fiberStationName!=nil) {
            [self getPointData:fiberStationName];
        }
    }
    
    // 2018年05月27日 查看ODF路由
    if (_GID != nil && _resLogicName != nil) {
        [self showRoute];
    }
    
    [super viewDidLoad];
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
    UIButton * showOrHideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    /* 普通状态下显示打开 */
    [showOrHideButton setTitle:@"帮助" forState:UIControlStateNormal];
    
    [showOrHideButton sizeToFit];
    /* 添加点击事件 */
    [showOrHideButton addTarget:self action:@selector(showHelpView:) forControlEvents:UIControlEventTouchUpInside];
    
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
-(void)showHelpView:(UIButton *)sender{
    
    
//    HelpViewController *helpVC = [[HelpViewController alloc] init];
//    helpVC.titleStr = @"GIS定位帮助";
//    helpVC.url = [[NSBundle mainBundle] URLForResource:@"GisMainHelp" withExtension:@"html"];
//    [self.navigationController pushViewController:helpVC animated:YES];
}
#pragma mark 解析文件

-(void)propertiesReader:(NSString *)fileName{
    
    return;
    
//    MARK: 袁全添加 -- GIS里增加UNI_
    
    NSString * TYKFileName = [NSString stringWithFormat:@"UNI_%@",fileName];
    
//    self.mainModel = [[IWPPropertiesReader propertiesReaderWithFileName:TYKFileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] mainModel];
//    self.viewModel = [[IWPPropertiesReader propertiesReaderWithFileName:TYKFileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] viewModels];
    
}
- (void)configSubviews{
    
    NSArray * functions = @[
        @[
            @{@"normalTitle":@"资源查询", @"selectedTitle":@"", @"selector":@"ResSearch:"},
                    @{@"normalTitle":@"批量关联", @"selectedTitle":@"确认关联", @"selector":@"piliangguanlian:"},
                    @{@"normalTitle":@"批量挂缆", @"selectedTitle":@"确认挂缆", @"selector":@"pilianggualan:"},
                    @{@"normalTitle":@"获取资源", @"selectedTitle":@"", @"selector":@"getRes:"},
                    @{@"normalTitle":@"自动定位", @"selectedTitle":@"", @"selector":@"location:"},
                    @{@"normalTitle":@"手动定位", @"selectedTitle":@"", @"selector":@"locationSelf:"},
        ],
        @[
            @{@"normalTitle":@"资源筛选", @"selectedTitle":@"", @"selector":@"ResShaixuan:"},
                    @{@"normalTitle":@"资源列表", @"selectedTitle":@"", @"selector":@"more:"},
            // @{@"normalTitle":@"地区切换", @"selectedTitle":@"more:", @"selector":@"piliangguanlian:"},
        ],
    ];
    
    _mapView = [MAMapView.alloc initWithFrame:self.view.bounds];
    _mapView.scaleOrigin = CGPointMake(5, _mapView.frame.size.height-30);
    _mapView.logoCenter = CGPointMake(_mapView.frame.size.width-50, _mapView.frame.size.height-15);
    [self mapState:NO];
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    [self.view addSubview:_mapView];
    
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(HeigtOfTop);
        
    }];
    
    
    NSInteger time = 0;
    for (NSArray * group in functions) {
        UIButton * lastButton = nil;
        for (NSDictionary * function in group) {
                
            UIButton * btn = [UIButton.alloc init];
            
            [self.view addSubview:btn];
            
            [btn setTitle:function[@"normalTitle"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            if ([function[@"selectedTitle"] length] > 0){
                [btn setTitle:function[@"selectedTitle"] forState:UIControlStateSelected];
                [btn setTitleColor:[UIColor mainColor] forState:UIControlStateSelected];
            }
            
            SEL selector = NSSelectorFromString(function[@"selector"]);

            btn.titleLabel.font = Font_Yuan(14);
            btn.backgroundColor = UIColor.whiteColor;
            [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
            
            UILabel * label = nil;
            if (
                function != group.firstObject){
                
                label = [UILabel.alloc init];
                label.backgroundColor = UIColor.grayColor;
                [self.view addSubview:label];
                
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                   
                    make.left.right.equalTo(lastButton);
                    make.height.offset(1);
                    make.top.equalTo(lastButton.mas_bottom);
                    
                }];
                
            }
            
            if ([btn.currentTitle isEqualToString:@"批量关联"]){
                _guanlianBtn = btn;
            }
            if ([btn.currentTitle isEqualToString:@"批量挂缆"]){
                            _gualanBtn = btn;
                        }
            
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
               
                if (time == 0){
                    make.left.equalTo(self.view);
                }else{
                    make.right.equalTo(self.view);
                }
                
                make.top.equalTo(label.mas_bottom ? label.mas_bottom : _mapView);
                make.width.offset(ScreenWidth/4);
                make.height.offset(45);
                
            }];
            
            
            
            lastButton = btn;
                
        }
     
        time++;
    }
    UIImage *image = [UIImage Inc_imageNamed:@"nav_turn_via_2"];
        icm = [[UIImageView alloc] initWithImage:image];
    
    [self.view layoutIfNeeded];
        CGPoint loc = {_mapView.frame.size.width/2 ,_mapView.frame.size.height/2};
        icm.center = loc;
        icm.hidden = YES;
        [_mapView addSubview:icm];
    
    
    
}
-(void)uiNewInit{
    _mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, HeigtOfTop, ScreenWidth,ScreenHeight-HeigtOfTop)];
    _mapView.scaleOrigin = CGPointMake(5, _mapView.frame.size.height-30);
    _mapView.logoCenter = CGPointMake(_mapView.frame.size.width-50, _mapView.frame.size.height-15);
    [self mapState:NO];
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    [self.view addSubview:_mapView];
    
    UIButton *ResSearchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, HeigtOfTop, ScreenWidth/4, 45)];
    [ResSearchBtn setTitle:@"资源查询" forState:UIControlStateNormal];
    [ResSearchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [ResSearchBtn setBackgroundColor:[UIColor whiteColor]];
    [ResSearchBtn addTarget:self action:@selector(ResSearch:) forControlEvents:UIControlEventTouchUpInside];
    ResSearchBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    ResSearchBtn.titleLabel.numberOfLines = 0;
    [self.view addSubview:ResSearchBtn];
    
    UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(0, HeigtOfTop+45, ScreenWidth/4, 45)];
    [l1 setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:l1];
    
    
    UIButton *getResBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, HeigtOfTop+46, ScreenWidth/4, 45)];
    _guanlianBtn = getResBtn;
    [getResBtn setTitle:@"批量关联" forState:UIControlStateNormal];
    [getResBtn setTitle:@"确认关联" forState:UIControlStateSelected];
    [getResBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [getResBtn setTitleColor:[UIColor mainColor] forState:UIControlStateSelected];
    [getResBtn setBackgroundColor:[UIColor whiteColor]];
    [getResBtn addTarget:self action:@selector(piliangguanlian:) forControlEvents:UIControlEventTouchUpInside];
    getResBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    getResBtn.titleLabel.numberOfLines = 0;
    [self.view addSubview:getResBtn];
    
    UILabel *l2 = [[UILabel alloc] initWithFrame:CGRectMake(0, HeigtOfTop+45*2+1, ScreenWidth/4, 45)];
    [l2 setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:l2];
    
    UIButton *locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, HeigtOfTop+45*2+2, ScreenWidth/4, 45)];
    _gualanBtn = locationBtn;
    [locationBtn setTitle:@"批量挂缆" forState:UIControlStateNormal];
    [locationBtn setTitle:@"确认挂缆" forState:UIControlStateSelected];
    
    
    [locationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [locationBtn setTitleColor:[UIColor mainColor] forState:UIControlStateSelected];
    [locationBtn setBackgroundColor:[UIColor whiteColor]];
    [locationBtn addTarget:self action:@selector(pilianggualan:) forControlEvents:UIControlEventTouchUpInside];
    locationBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    locationBtn.titleLabel.numberOfLines = 0;
    
    [self.view addSubview:locationBtn];
    
    
    
    
    
    
    //
    //    UILabel *l3 = [[UILabel alloc] initWithFrame:CGRectMake(0, HeigtOfTop+45*/*3*/2+1, ScreenWidth/4, 45)];
    //    [l3 setBackgroundColor:[UIColor grayColor]];
    //    [self.view addSubview:l3];
    //
    //    UIButton *locationSelfBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, HeigtOfTop+45*/*3*/2+2, ScreenWidth/4, 45)];
    //    [locationSelfBtn setTitle:@"手动定位" forState:UIControlStateNormal];
    //    [locationSelfBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    [locationSelfBtn setBackgroundColor:[UIColor whiteColor]];
    //    [locationSelfBtn addTarget:self action:@selector(locationSelf:) forControlEvents:UIControlEventTouchUpInside];
    //    locationSelfBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    //    locationSelfBtn.titleLabel.numberOfLines = 0;
    //    [self.view addSubview:locationSelfBtn];
    
    //    UILabel *l4 = [[UILabel alloc] initWithFrame:CGRectMake(0, HeigtOfTop+45*4+1, ScreenWidth/4, 45)];
    //    [l4 setBackgroundColor:[UIColor grayColor]];
    //    [self.view addSubview:l4];
    
    //    guanlianBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, HeigtOfTop+45*4+2, ScreenWidth/4, 45)];
    //    [guanlianBtn setTitle:@"资源关联" forState:UIControlStateNormal];
    //    [guanlianBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    [guanlianBtn setBackgroundColor:[UIColor whiteColor]];
    //    [guanlianBtn addTarget:self action:@selector(guanlianRes:) forControlEvents:UIControlEventTouchUpInside];
    //    guanlianBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    //    guanlianBtn.titleLabel.numberOfLines = 0;
    //    [self.view addSubview:guanlianBtn];
    
    //    if ([_userModel.domainCode isEqualToString:@"0/"] ) {
    //        [l4 setHidden:YES];
    //        [guanlianBtn setHidden:YES];
    //    }
    
    
    UIButton *ResShaixuanBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/4*3-1, HeigtOfTop, ScreenWidth/4, 45)];
    [ResShaixuanBtn setTitle:@"资源筛选" forState:UIControlStateNormal];
    [ResShaixuanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [ResShaixuanBtn setBackgroundColor:[UIColor whiteColor]];
    [ResShaixuanBtn addTarget:self action:@selector(ResShaixuan:) forControlEvents:UIControlEventTouchUpInside];
    ResShaixuanBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    ResShaixuanBtn.titleLabel.numberOfLines = 0;
    [self.view addSubview:ResShaixuanBtn];
    
    UILabel *l5 = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/4*3-1, HeigtOfTop+45, ScreenWidth/4, 45)];
    [l5 setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:l5];
    
    UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/4*3-1, HeigtOfTop+46, ScreenWidth/4, 45)];
    [moreBtn setTitle:@"资源列表" forState:UIControlStateNormal];
    [moreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [moreBtn setBackgroundColor:[UIColor whiteColor]];
    [moreBtn addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    moreBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    moreBtn.titleLabel.numberOfLines = 0;
    [self.view addSubview:moreBtn];
    
    UILabel *l6 = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/4*3-1, HeigtOfTop+45*2+1, ScreenWidth/4, 45)];
    [l6 setBackgroundColor:[UIColor grayColor]];
    
    UIButton *regionBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/4*3-1, HeigtOfTop+45*2+2, ScreenWidth/4, 45)];
    [regionBtn setTitle:@"地区切换" forState:UIControlStateNormal];
    [regionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [regionBtn setBackgroundColor:[UIColor whiteColor]];
    [regionBtn addTarget:self action:@selector(regionChange:) forControlEvents:UIControlEventTouchUpInside];
    regionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    regionBtn.titleLabel.numberOfLines = 0;
    //    if ([_userModel.domainCode isEqualToString:@"0/"] ) {
    //        //只有集团用户才能使用地区切换功能
    //        [self.view addSubview:l6];
    //        [self.view addSubview:regionBtn];
    //    }
    
    UIImage *image = [UIImage Inc_imageNamed:@"nav_turn_via_2"];
    icm = [[UIImageView alloc] initWithImage:image];
    CGPoint loc = {_mapView.frame.size.width/2 ,_mapView.frame.size.height/2};
    icm.center = loc;
    icm.hidden = YES;
    [_mapView addSubview:icm];
    
    
    
    
    
}
-(UIButton *)searchselectBtn:(NSString *)titleText : (UIButton *)btn{
    
    if (btn == nil) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    
    [btn setTitle:titleText forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor whiteColor]];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn.titleLabel.numberOfLines = 0;
    return btn;
}
//搜索项界面初始化
-(void)searchSelectUiInit{
    UIView *fullView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [fullView setBackgroundColor:[UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:0.5]];
    fullView.tag = 5500000;
    [self.view addSubview:fullView];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehindSear:)];
//    tap.cancelsTouchesInView = NO;
//    [fullView addGestureRecognizer:tap];
    
    NSArray <NSDictionary *> * btnModels = @[@{@"title":@"杆路", @"fileName":@"poleline", @"selector":@"poleLineSec:"},
                            @{@"title":@"管道", @"fileName":@"pipe", @"selector":@"pipeSec:"},
//                            @{@"title":@"局站", @"fileName":@"stationBase", @"selector":@"stationSec:"},
                            @{@"title":@"标石路径", @"fileName":@"markStonePath", @"selector":@"markStoneLineSec:"},
                            @{@"title":@"光缆", @"fileName":@"route", @"selector":@"getCableroute:"},
                            @{@"title":@"光缆段", @"fileName":@"cable", @"selector":@"getCableBtn:"}
                            ];
    
    __block UIButton * lastButton = nil;
    
    UIView * bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor grayColor];
    [fullView addSubview:bgView];
    
    [btnModels enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
       
        UIButton * btn = [self searchselectBtn:dict[@"title"] :nil];
        btn.Id = dict[@"fileName"];
        [btn addTarget:self action:@selector(gotoSelect:) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.right.equalTo(bgView);
            make.top.equalTo(lastButton ? lastButton.mas_bottom : bgView).offset(lastButton ? 1 : 0);
            make.height.offset(IphoneSize_Height(45));
            
        }];
    
        
        lastButton = btn;
    }];
    
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.offset(ScreenWidth / 4.f);
        make.height.offset(IphoneSize_Height(45) * btnModels.count + btnModels.count - 1);
        make.center.equalTo(fullView);
        
    }];
    
    
    
//    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(ScreenWidth/3, HeigtOfTop+5, ScreenWidth/4, ScreenHeight-10-HeigtOfTop)];
//    scroll.userInteractionEnabled = YES;
//    scroll.showsHorizontalScrollIndicator=NO;
//    scroll.showsVerticalScrollIndicator=NO;
//    [scroll setBackgroundColor:[UIColor whiteColor]];
//    scroll.tag = 5600000;
//    [fullView addSubview:scroll];
//
//    int btnSize = scroll.frame.size.width;
//    UIButton *btn_1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnSize, 45)];
//    btn_1.tag = 5500001;
//    [[self searchselectBtn:@"杆路" :btn_1]addTarget:self action:@selector(poleLineSec:) forControlEvents:UIControlEventTouchUpInside];
//    [scroll addSubview:btn_1];
//
//    UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 45+1, ScreenWidth/4, 45)];
//    [l1 setBackgroundColor:[UIColor grayColor]];
//    [scroll addSubview:l1];
//
//    UIButton *btn_2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 45+2, btnSize, 45)];
//    btn_2.tag = 5500002;
//    [[self searchselectBtn:@"管道" :btn_2] addTarget:self action:@selector(pipeSec:) forControlEvents:UIControlEventTouchUpInside];
//    [scroll addSubview:btn_2];
//
//    UILabel *l2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 45*2+1, ScreenWidth/4, 45)];
//    [l2 setBackgroundColor:[UIColor grayColor]];
//    [scroll addSubview:l2];
//
//    UIButton *btn_3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 45*2+2, btnSize, 45)];
//    btn_3.tag = 5500003;
//    [[self searchselectBtn:@"局站" :btn_3] addTarget:self action:@selector(stationSec:) forControlEvents:UIControlEventTouchUpInside];
//    [scroll addSubview:btn_3];
//
//    UILabel *l3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 45*3+1, ScreenWidth/4, 45)];
//    [l3 setBackgroundColor:[UIColor grayColor]];
//    [scroll addSubview:l3];
//
//    UIButton *btn_4 = [[UIButton alloc] initWithFrame:CGRectMake(0, 45*3+2, btnSize, 45)];
//    btn_4.tag = 5500004;
//    [[self searchselectBtn:@"标石路径" :btn_4] addTarget:self action:@selector(markStoneLineSec:) forControlEvents:UIControlEventTouchUpInside];
//    [scroll addSubview:btn_4];
//
//    UILabel *l4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 45*43+1, ScreenWidth/4, 45)];
//    [l4 setBackgroundColor:[UIColor grayColor]];
//    [scroll addSubview:l4];
//
//    UIButton *btn_5 = [[UIButton alloc] initWithFrame:CGRectMake(0, 45*43+2, btnSize, 45)];
//    btn_5.tag = 5500005;
//    [[self searchselectBtn:@"光缆" :btn_5] addTarget:self action:@selector(getCableroute:) forControlEvents:UIControlEventTouchUpInside];
//    [scroll addSubview:btn_5];
//
//    UILabel *l5 = [[UILabel alloc] initWithFrame:CGRectMake(0, 45*54+1, ScreenWidth/4, 45)];
//    [l5 setBackgroundColor:[UIColor grayColor]];
//    [scroll addSubview:l5];
//
//    UIButton *btn_6 = [[UIButton alloc] initWithFrame:CGRectMake(0, 45*5*4+2, btnSize, 45)];
//    btn_6.tag = 5500006;
//    [[self searchselectBtn:@"光缆段" :btn_6] addTarget:self action:@selector(getCableBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [scroll addSubview:btn_6];
//
//    searchSelectArray = @[btn_1,btn_2,btn_3,btn_4,btn_5,btn_6/*,btn_7,btn_8*/];
//    searchLabelArray = @[l1,l2,l3,l4,l5/*,l6,l7*/];
//
//    [scroll setContentSize:CGSizeMake(btnSize, 45 * searchSelectArray.count)];
//    CGRect scrollFrame = scroll.frame;
//    scrollFrame.size.height = 45 * searchSelectArray.count;
//    scroll.frame = scrollFrame;
//
//    scroll.center = fullView.center;
}

- (void)gotoSelect:(UIButton *)sender{
    
    [self stationSelect:sender.Id];
    
}


-(void)handleTapBehindSear:(UITapGestureRecognizer *)sender{
    UIView *fullView = [self.view viewWithTag:5500000];
    CGPoint location = [sender locationInView:fullView];
    UIView *faceView = [fullView viewWithTag:5600000];
    if(![faceView pointInside:[faceView convertPoint:location fromView:faceView.window] withEvent:nil]){
        for (UIButton *searchSelectTemp in searchSelectArray) {
            [searchSelectTemp removeFromSuperview];
        }
        for (UILabel *searchLabelTemp in searchLabelArray) {
            [searchLabelTemp removeFromSuperview];
        }
        [faceView removeFromSuperview];
        [fullView removeFromSuperview];
    }
}
-(void)searchSelectUiDismiss{
    UIView *fullView = [self.view viewWithTag:5500000];
    UIView *faceView = [fullView viewWithTag:5600000];
    for (UIButton *searchSelectTemp in searchSelectArray) {
        [searchSelectTemp removeFromSuperview];
    }
    for (UILabel *searchLabelTemp in searchLabelArray) {
        [searchLabelTemp removeFromSuperview];
    }
    [faceView removeFromSuperview];
    [fullView removeFromSuperview];
}
-(void)mapState:(BOOL) boo{
    //_mapView.showsBuildings = boo;
    
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
//初始化地图显示位置
- (void)initOverlay {
    
    
    if ([[self.poiinfo objectForKey:@"list_d"] count]>0) {
        NSDictionary *tempMark1 = [self.poiinfo objectForKey:@"list_d"][0];
        CLLocationCoordinate2D coor;
        
        coor.latitude = [[tempMark1 objectForKey:@"markSLat"] doubleValue];
        coor.longitude = [[tempMark1 objectForKey:@"markSLon"] doubleValue];
        NSLog(@"markSLat:%f,markSLon:%f",coor.latitude,coor.longitude);
        MACoordinateRegion region ;//表示范围的结构体
        region.center = coor;//中心点
        region.span.latitudeDelta = 0.1;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
        region.span.longitudeDelta = 0.1;//纬度范围
        [_mapView setRegion:region animated:YES];
        _mapView.showsUserLocation = NO;
        [_mapView setZoomLevel:17 animated:NO];
    }else {

        [YuanHUD HUDFullText:@"暂无资源"];
        

    }
    
    
}
//显示资源
-(void)markShow{
    NSLog(@"显示资源");
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
    
    //显示线
    if ([self.poiinfo objectForKey:@"list_x"] !=nil) {
        for (int i = 0; i<[[self.poiinfo objectForKey:@"list_x"] count]; i++) {
            NSDictionary *tempmark = [self.poiinfo objectForKey:@"list_x"][i];
            NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
            NSMutableArray *points = [[NSMutableArray alloc] init];
            [p1 setObject:[tempmark objectForKey:@"markSLat"] forKey:@"lat"];
            [p1 setObject:[tempmark objectForKey:@"markSLon"] forKey:@"lon"];
            [points addObject:p1];
            [p2 setObject:[tempmark objectForKey:@"markELat"] forKey:@"lat"];
            [p2 setObject:[tempmark objectForKey:@"markELon"] forKey:@"lon"];
            [points addObject:p2];
            
            if (p1!=nil && p2!=nil && [[p1 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p1 objectForKey:@"lon"] doubleValue]&& [[p2 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p2 objectForKey:@"lon"] doubleValue]) {
                CLLocationCoordinate2D coors[2] = {0};
                coors[0].latitude = [[p1 objectForKey:@"lat"] doubleValue];
                coors[0].longitude = [[p1 objectForKey:@"lon"] doubleValue];
                coors[1].latitude = [[p2 objectForKey:@"lat"] doubleValue];
                coors[1].longitude = [[p2 objectForKey:@"lon"] doubleValue];
                
                
                NSLog(@"coors:%f,%f,%f,%f",coors[0].latitude,coors[0].longitude,coors[1].latitude,coors[1].longitude);
                Yuan_PolyLine *polyline = [Yuan_PolyLine polylineWithCoordinates:coors count:2];
                polyline.color = tempmark[@"color"];
                if ([tempmark[@"markResType"] isEqualToString:@"resRelation"]) {
                    polyline.type = 4;
                }
                [_mapView addOverlay:polyline];
                
            }
        }
    }
    //显示点
    if ([self.poiinfo objectForKey:@"list_d"] !=nil) {
        self.nameArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<[[self.poiinfo objectForKey:@"list_d"] count]; i++) {
            NSDictionary *tempmark = [self.poiinfo objectForKey:@"list_d"][i];
            annotationIndex = i;
            Yuan_PointAnnotation *pointAnnotation = [[Yuan_PointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            
            coor.latitude = [[tempmark objectForKey:@"markSLat"] doubleValue];
            coor.longitude = [[tempmark objectForKey:@"markSLon"] doubleValue];
            if ((tempmark!=nil) && ([tempmark objectForKey:@"markResType"]!=nil)) {
                if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"well"]) {
                    pointAnnotation.tag = 10000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"pole"]){
                    pointAnnotation.tag = 20000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"OCC_Equt"]){
                    pointAnnotation.tag = 30000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"stationBase"]){
                    pointAnnotation.tag = 40000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"ledUp"]){
                    pointAnnotation.tag = 50000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"markStone"]){
                    pointAnnotation.tag = 60000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"ODF_Equt"]){
                    pointAnnotation.tag = 70000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"generator"]){
                    pointAnnotation.tag = 80000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"ODB_Equt"]){
                    pointAnnotation.tag = 90000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"joint"]){
                    pointAnnotation.tag = 100000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"supportingPoints"]){
                    pointAnnotation.tag = 110000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"EquipmentPoint"]){
                    pointAnnotation.tag = 120000+i;
                }else{
                    pointAnnotation.tag = 130000+i;
                }
            }
            
            
            pointAnnotation.coordinate = coor;
            
            
            if ([tempmark objectForKey:@"markName"]!=nil) {
                [self.nameArray addObject:[tempmark objectForKey:@"markName"]];
                pointAnnotation.title = [tempmark objectForKey:@"markName"];
            }
             
            [_mapView addAnnotation:pointAnnotation];
            
        }
    }
}
//显示线
-(void)markLineShow{
    //清空
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (MAAnnotationView *view in _mapView.overlays) {
        if (![view isKindOfClass:[MACircle class]]) {
            [arr addObject:view];
        }
    }
    NSArray *array = [NSArray arrayWithArray:arr];
    [_mapView removeOverlays:array];
    
    
    //显示线
    if ([self.poiinfo objectForKey:@"list_x"] !=nil) {
        for (int i = 0; i<[[self.poiinfo objectForKey:@"list_x"] count]; i++) {
            NSDictionary *tempmark = [self.poiinfo objectForKey:@"list_x"][i];
            NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
            NSMutableArray *points = [[NSMutableArray alloc] init];
            [p1 setObject:[tempmark objectForKey:@"markSLat"] forKey:@"lat"];
            [p1 setObject:[tempmark objectForKey:@"markSLon"] forKey:@"lon"];
            [points addObject:p1];
            [p2 setObject:[tempmark objectForKey:@"markELat"] forKey:@"lat"];
            [p2 setObject:[tempmark objectForKey:@"markELon"] forKey:@"lon"];
            [points addObject:p2];
            
            if (p1!=nil && p2!=nil && [[p1 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p1 objectForKey:@"lon"] doubleValue]&& [[p2 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p2 objectForKey:@"lon"] doubleValue]) {
                CLLocationCoordinate2D coors[2] = {0};
                coors[0].latitude = [[p1 objectForKey:@"lat"] doubleValue];
                coors[0].longitude = [[p1 objectForKey:@"lon"] doubleValue];
                coors[1].latitude = [[p2 objectForKey:@"lat"] doubleValue];
                coors[1].longitude = [[p2 objectForKey:@"lon"] doubleValue];
                
                
                NSLog(@"coors:%f,%f,%f,%f",coors[0].latitude,coors[0].longitude,coors[1].latitude,coors[1].longitude);
                Yuan_PolyLine *polyline = [Yuan_PolyLine polylineWithCoordinates:coors count:2];
                polyline.color = tempmark[@"color"];
                if ([tempmark[@"markResType"] isEqualToString:@"resRelation"]) {
                    polyline.type = 4;
                }
                [_mapView addOverlay:polyline];
                
            }
        }
    }
}
//添加资源画线
-(void)addTempLineView
{
    NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
    NSMutableArray *points = [[NSMutableArray alloc] init];
    
    [p1 setObject:[guanlianArr[0] objectForKey:@"lat"] forKey:@"lat"];
    [p1 setObject:[guanlianArr[0] objectForKey:@"lon"] forKey:@"lon"];
    [points addObject:p1];
    [p2 setObject:[guanlianArr[1] objectForKey:@"lat"] forKey:@"lat"];
    [p2 setObject:[guanlianArr[1] objectForKey:@"lon"] forKey:@"lon"];
    [points addObject:p2];
    
    if (p1!=nil && p2!=nil && [[p1 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p1 objectForKey:@"lon"] doubleValue]&& [[p2 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p2 objectForKey:@"lon"] doubleValue]) {
        CLLocationCoordinate2D coors[2] = {0};
        coors[0].latitude = [[p1 objectForKey:@"lat"] doubleValue];
        coors[0].longitude = [[p1 objectForKey:@"lon"] doubleValue];
        coors[1].latitude = [[p2 objectForKey:@"lat"] doubleValue];
        coors[1].longitude = [[p2 objectForKey:@"lon"] doubleValue];
        
        
        NSLog(@"coors:%f,%f,%f,%f",coors[0].latitude,coors[0].longitude,coors[1].latitude,coors[1].longitude);
        Yuan_PolyLine *polyline = [Yuan_PolyLine polylineWithCoordinates:coors count:2];
        polyline.type = 1;//虚线
        [_mapView addOverlay:polyline];
        
    }
}
//删除资源画线
-(void)removeTempLineView
{
    NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
    NSMutableArray *points = [[NSMutableArray alloc] init];
    
    [p1 setObject:[guanlianArr[0] objectForKey:@"lat"] forKey:@"lat"];
    [p1 setObject:[guanlianArr[0] objectForKey:@"lon"] forKey:@"lon"];
    [points addObject:p1];
    [p2 setObject:[guanlianArr[1] objectForKey:@"lat"] forKey:@"lat"];
    [p2 setObject:[guanlianArr[1] objectForKey:@"lon"] forKey:@"lon"];
    [points addObject:p2];
    
    if (p1!=nil && p2!=nil && [[p1 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p1 objectForKey:@"lon"] doubleValue]&& [[p2 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p2 objectForKey:@"lon"] doubleValue]) {
        CLLocationCoordinate2D coors[2] = {0};
        coors[0].latitude = [[p1 objectForKey:@"lat"] doubleValue];
        coors[0].longitude = [[p1 objectForKey:@"lon"] doubleValue];
        coors[1].latitude = [[p2 objectForKey:@"lat"] doubleValue];
        coors[1].longitude = [[p2 objectForKey:@"lon"] doubleValue];
        
        
        NSLog(@"removeOverlay:coors:%f,%f,%f,%f",coors[0].latitude,coors[0].longitude,coors[1].latitude,coors[1].longitude);
        Yuan_PolyLine *polyline = [Yuan_PolyLine polylineWithCoordinates:coors count:2];
        polyline.type = 3;//透明线
        [_mapView addOverlay:polyline];
        
    }
}

//显示名称和图片
-(void)showNameAndImage{
    UIView *fullView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [fullView setBackgroundColor:[UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:0.5]];
    fullView.tag = 500000;
    [self.view addSubview:fullView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    tap.cancelsTouchesInView = NO;
    [fullView addGestureRecognizer:tap];
    
    UIView *nameImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth-10, ScreenHeight/2)];
    [nameImageView setCenter:fullView.center];
    [nameImageView setBackgroundColor:[UIColor whiteColor]];
    nameImageView.tag = 600000;
    [fullView addSubview:nameImageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, nameImageView.frame.size.width/3*2, nameImageView.frame.size.height/3)];
    nameLabel.text = @"名称";
    nameLabel.textColor = [UIColor grayColor];
    [nameLabel setFont:[UIFont systemFontOfSize:12]];
    nameLabel.numberOfLines  = 0;
    [nameImageView addSubview:nameLabel];
    nameLabel.tag = 500001;
    
    UIButton *infoBtn = [[UIButton alloc] initWithFrame:CGRectMake(nameImageView.frame.size.width/3*2+2, 2, nameImageView.frame.size.width/3-2, nameImageView.frame.size.height/3)];
    [infoBtn setTitle:@"详细信息>>" forState:UIControlStateNormal];
    [infoBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [infoBtn setBackgroundImage:[UIImage Inc_imageNamed:@"a.png"] forState:UIControlStateNormal];
    [infoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [infoBtn addTarget:self action:@selector(jumpToMB) forControlEvents:UIControlEventTouchUpInside];
    [nameImageView addSubview:infoBtn];
    infoBtn.tag = 500002;
    
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, nameLabel.frame.size.height, nameImageView.frame.size.width, nameImageView.frame.size.height/3)];
    noteLabel.text = @"内容";
    noteLabel.textColor = [UIColor grayColor];
    [noteLabel setFont:[UIFont systemFontOfSize:12]];
    noteLabel.numberOfLines  = 0;
    [nameImageView addSubview:noteLabel];
    noteLabel.tag = 500003;
    
    UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(2, nameLabel.frame.size.height+noteLabel.frame.size.height,nameImageView.frame.size.width-4, nameImageView.frame.size.height/3)];
    imageView.tag = 500004;
    [nameImageView addSubview:imageView];
    
    UIImageView *image1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 60, 60)];
    image1.tag = 501;
    [image1 setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagepress:)];
    [image1 addGestureRecognizer:singleTap1];
    [imageView addSubview:image1];
    
    UIImageView *image2 = [[UIImageView alloc] initWithFrame:CGRectMake(5+60+5, 5, 60, 60)];
    image2.tag = 502;
    [image2 setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagepress:)];
    [image2 addGestureRecognizer:singleTap2];
    [imageView addSubview:image2];
    
    UIImageView *image3 = [[UIImageView alloc] initWithFrame:CGRectMake(5+60*2+5*2, 5, 60, 60)];
    image3.tag = 503;
    [image3 setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagepress:)];
    [image3 addGestureRecognizer:singleTap3];
    [imageView addSubview:image3];
    
    UIImageView *image4 = [[UIImageView alloc] initWithFrame:CGRectMake(5+60*3+5*3, 5, 60, 60)];
    //    [image4 setImage:[UIImage Inc_imageNamed:@"wait"]];
    image4.tag = 504;
    [image4 setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagepress:)];
    [image4 addGestureRecognizer:singleTap4];
    [imageView addSubview:image4];
    
    NameAndImageArray = @[nameLabel,infoBtn,noteLabel,imageView,image1,image2,image3,image4];
    
    [self NameAndImageDataInit];
}
//显示数据
-(void)NameAndImageDataInit{
    if (self.poiclick == nil) {
        return;
    }
    ((UILabel *)[self.view viewWithTag:500001]).text = [NSString stringWithFormat:@"%@",[self.poiclick objectForKey:@"markName"]];
    
    //更改内容显示
    NSArray *tempArr = [(NSString *)[self.poiclick objectForKey:@"markContent"] componentsSeparatedByString:@","];
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    [tempStr setString:@""];
    for (int i = 0; i<tempArr.count; i++) {
        if (i%2 == 0) {
            [tempStr appendString:[NSString stringWithFormat:@"%@:",tempArr[i]]];
        }else{
            [tempStr appendString:[NSString stringWithFormat:@"%@\n",[tempArr[i] isEqualToString:@"null"]?@"":tempArr[i]]];
        }
    }
    ((UILabel *)[self.view viewWithTag:500003]).text = tempStr;
    
    //    ((UILabel *)[self.view viewWithTag:500003]).text = [NSString stringWithFormat:@"%@",[self.poiclick objectForKey:@"markContent"]];
    
    if (images == nil) {
        images = [[NSMutableArray alloc] init];
    }else{
        [images removeAllObjects];
    }
    NSLog(@"%@",self.poiclick);
    
    
#ifdef BaseURL
    NSString * basePhotoURL = BasePhotoURL;
#else
    NSString * basePhotoURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
#endif
    
    NSString *imageNames1 = [NSString stringWithFormat:@"%@/%@_%@_1.jpg",_userModel.domainCode,[self.poiclick objectForKey:@"markResType"],[self.poiclick objectForKey:@"markResId"]];
    [(UIImageView *)[self.view viewWithTag:501] sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",basePhotoURL,imageNames1]] placeholderImage:[UIImage Inc_imageNamed:@"wait.png"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        [images removeAllObjects];
        
        if (image == nil) {
            [(UIImageView *)[self.view viewWithTag:501] setImage:[UIImage Inc_imageNamed:@"error1.png"]];
            [images addObject:[UIImage Inc_imageNamed:@"error1.png"]];
        }
        else {
            
            [images addObject:[UIImage imageWithData:UIImageJPEGRepresentation(image, .4)]];
        }
        
        NSString *imageNames2 = [NSString stringWithFormat:@"%@/%@_%@_2.jpg",_userModel.domainCode,[self.poiclick objectForKey:@"markResType"],[self.poiclick objectForKey:@"markResId"]];
        
        [(UIImageView *)[self.view viewWithTag:502] sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",basePhotoURL,imageNames2]] placeholderImage:[UIImage Inc_imageNamed:@"wait.png"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image == nil) {
                [(UIImageView *)[self.view viewWithTag:502] setImage:[UIImage Inc_imageNamed:@"error1.png"]];
                [images addObject:[UIImage Inc_imageNamed:@"error1.png"]];
            }
            else {
                [images addObject:image];
            }
            NSString *imageNames3 = [NSString stringWithFormat:@"%@/%@_%@_3.jpg",_userModel.domainCode,[self.poiclick objectForKey:@"markResType"],[self.poiclick objectForKey:@"markResId"]];
            
            [(UIImageView *)[self.view viewWithTag:503] sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",basePhotoURL,imageNames3]] placeholderImage:[UIImage Inc_imageNamed:@"wait.png"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image == nil) {
                    [(UIImageView *)[self.view viewWithTag:503] setImage:[UIImage Inc_imageNamed:@"error1.png"]];
                    [images addObject:[UIImage Inc_imageNamed:@"error1.png"]];
                }
                else {
                    [images addObject:image];
                }
                NSString *imageNames4 = [NSString stringWithFormat:@"%@/%@_%@_4.jpg",_userModel.domainCode,[self.poiclick objectForKey:@"markResType"],[self.poiclick objectForKey:@"markResId"]];
                
                [(UIImageView *)[self.view viewWithTag:504] sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",basePhotoURL,imageNames4]] placeholderImage:[UIImage Inc_imageNamed:@"wait.png"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (image == nil) {
                        [(UIImageView *)[self.view viewWithTag:504] setImage:[UIImage Inc_imageNamed:@"error1.png"]];
                        [images addObject:[UIImage Inc_imageNamed:@"error1.png"]];
                    }
                    else {
                        [images addObject:image];
                    }
                }];
            }];
        }];
    }];
    
    
    
    
}
//查看照片大图
-(void)imagepress:(UITapGestureRecognizer *)sender{
    
    return;
    
//    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:sender.view.tag-500-1 photoModelBlock:^NSArray *{
//
//        NSArray *localImages = images;
//
//        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:localImages.count];
//        for (NSUInteger i = 0; i< localImages.count; i++) {
//
//            PhotoModel *pbModel=[[PhotoModel alloc] init];
//            pbModel.mid = i + 1;
//            pbModel.image = localImages[i];
//
//            //源frame
//            UIImageView *imageV =(UIImageView *)sender.view;
//            pbModel.sourceImageView = imageV;
//            [modelsM addObject:pbModel];
//        }
//        return modelsM;
//    }];
}
//图片页面查看详细信息按钮点击触发事件
-(IBAction)jumpToMB{
    if (temp!=nil) {
        [self getOneData];
    }
    UIView *fullView = [self.view viewWithTag:500000];
    UIView *faceView = [fullView viewWithTag:600000];
    
    for (UIView *tempView in [faceView subviews]) {
        [tempView removeFromSuperview];
    }
    [faceView removeFromSuperview];
    [fullView removeFromSuperview];
}
-(void)handleTapBehind:(UITapGestureRecognizer *)sender{
    UIView *fullView = [self.view viewWithTag:500000];
    CGPoint location = [sender locationInView:fullView];
    UIView *faceView = [fullView viewWithTag:600000];
    if(![faceView pointInside:[faceView convertPoint:location fromView:faceView.window] withEvent:nil]){
        for (UIView *tempView in [faceView subviews]) {
            [tempView removeFromSuperview];
        }
        [faceView removeFromSuperview];
        [fullView removeFromSuperview];
    }
}
//地区切换按钮点击触发事件
-(IBAction)regionChange:(id)sender{
//    GisRegionSelectViewController *gisRegionSelectVC = [[GisRegionSelectViewController alloc] init];
//
//    CATransition *transition = [CATransition animation];
//    transition.duration = .3;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    transition.type = kCATransitionMoveIn;
//    transition.subtype = kCATransitionFromTop;
//    //    transition.delegate = self;
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
//    self.navigationController.navigationBarHidden = NO;
//
//
//
//    [self.navigationController pushViewController:gisRegionSelectVC animated:NO];
}
//获取杆路按钮点击触发事件
-(IBAction)poleLineSec:(id)sender{
    
    [self stationSelect:@"poleline"];
    
 
}
//获取管道按钮点击触发事件
-(IBAction)pipeSec:(id)sender{
    
    [self stationSelect:@"pipe"];

}
//获取局站按钮点击触发事件
-(IBAction)stationSec:(id)sender{
    
    [self stationSelect:@"stationBase"];
    

}
//获取标石路径按钮点击触发事件
-(IBAction)markStoneLineSec:(id)sender{
    
    [self stationSelect:@"markStonePath"];
    

}
//获取光缆按钮点击触发事件
-(IBAction)getCableroute:(id)sender{
    
    [self stationSelect:@"route"];
    

}
//获取缆段按钮点击触发事件
-(IBAction)getCableBtn:(id)sender{
    
    [self stationSelect:@"cable"];
    

}
//资源查询按钮点击触发事件
-(IBAction)ResSearch:(UIButton *)sender{
    NSLog(@"资源查询");
    [self searchSelectUiInit];
}
//资源筛选按钮点击触发事件
-(IBAction)ResShaixuan:(UIButton *)sender{
    NSLog(@"资源筛选");
    
    [self.plusListView hideListViewNOAnimation:NO];
    
    if (self.shaiXuanListView == nil) {
        // 创建
        
        CGFloat x, y, w, h;
        
        x = y = w = h = 0;
        w = self.view.bounds.size.width * (1.f / 2.f);
        h = 40.f;
        
        // 创建隐藏按钮
        UIButton * hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [hideButton setTitle:@"关闭" forState:UIControlStateNormal];
        hideButton.frame = CGRectMake(0, 0, w, h);
        hideButton.backgroundColor = [UIColor mainColor];
        hideButton.tintColor = [UIColor whiteColor];
        
        
        
        x = 0 - w;
        y = HeigtOfTop;
        h = self.view.frame.size.height - y;
        
        
        // 创建列表视图，隐藏方向：左侧
        YKLListView * listView = [[YKLListView alloc] initWithFrame:CGRectMake(x, y, w, h) animateStyle:YKLListAnimationDirectionLeft];
        self.shaiXuanListView = listView;
        
        [self.view addSubview:listView];
        
        
        // 将隐藏按钮放在listView的headerView中。
        listView.tableHeaderView = hideButton;
        
        listView.dataSource = self;
        listView.delegate = self;
        
        
        
        self.shaiXuanDataSource = [NSArray arrayWithArray:[@"管道段,井,杆路段,杆,标石段,标石,ODF,OCC,局站,机房,引上点,ODB,撑点,光缆接头,管孔,设备放置点" componentsSeparatedByString:@","]];
        
        NSMutableArray * dataSource = [NSMutableArray array];
        for (int i = 0; i < self.shaiXuanDataSource.count; i++) {
            
            NSString * key = [NSString stringWithFormat:@"%d", i];
            
            NSDictionary * dict = @{key:@YES};
            
            [dataSource addObject:dict];
        }
        
        self.switcherDataSource = dataSource;
        
        
        // 显示和隐藏的点击事件
        [hideButton addTarget:listView action:@selector(hideListViewNOAnimation:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    [self.shaiXuanListView showListViewNOAnimation:NO];
    
    
}
//更多按钮点击触发事件
-(IBAction)more:(UIButton *)sender{
    
    NSArray * mapSource = self.poiinfo[@"list_d"];
    
    
    if (_plusDataSource.count == 0  || mapSource.count == 0 ) {
        
        [YuanHUD HUDFullText:@"暂无获取资源记录"];
        
        return;
    }
    
    
    
    
    [self.shaiXuanListView hideListViewNOAnimation:NO];
    
    if (self.plusListView == nil) {
        // 创建
        
        CGFloat x, y, w, h;
        
        x = y = w = h = 0;
        w = self.view.bounds.size.width * .7f;
        h = 40.f;
        
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        
        // 创建隐藏按钮
        UIButton * hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [hideButton setTitle:@"关闭" forState:UIControlStateNormal];
        hideButton.frame = CGRectMake(0, 0, w , h);
        hideButton.backgroundColor = [UIColor mainColor];
        [headerView addSubview:hideButton];
        hideButton.tintColor = [UIColor whiteColor];
        
        //        UIButton * editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [editButton setTitle:@"编辑" forState:UIControlStateNormal];
        //        [editButton setTitle:@"取消" forState:UIControlStateSelected];
        //        editButton.frame = CGRectMake(w / 2.f, 0, w / 2.f, h);
        //        editButton.backgroundColor = [UIColor mainColor];
        //        [headerView addSubview:editButton];
        //        editButton.tintColor = [UIColor whiteColor];
        
        
        
        
        x = self.view.frame.size.width;
        y = HeigtOfTop;
        h = self.view.frame.size.height - y;
        
        
        // 创建列表视图，隐藏方向：左侧
        YKLListView * listView = [[YKLListView alloc] initWithFrame:CGRectMake(x, y, w, h) animateStyle:YKLListAnimationDirectionRight];
        self.plusListView = listView;
        
        
        [self.view addSubview:listView];
        
        
        // 将隐藏按钮放在listView的headerView中。
        listView.tableHeaderView = headerView;
        
        listView.dataSource = self;
        listView.delegate = self;
        
        
        NSLog(@"self.plusDataSource:%@",self.plusDataSource);
        //        self.plusDataSource = @[@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除",@"滑动删除"];
        
        
        // 显示和隐藏的点击事件
        [hideButton addTarget:listView action:@selector(hideListViewNOAnimation:) forControlEvents:UIControlEventTouchUpInside];
        
        //        [editButton addTarget:self action:@selector(editButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    
    
    
    [self.plusListView showListViewNOAnimation:NO];
    
    NSLog(@"+");
}
//资源关联按钮点击触发事件
-(IBAction)guanlianRes:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"资源关联"]) {
        UIActionSheet *myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加关联关系", @"删除关联关系", nil];
        [myActionSheet showInView:self.view];
    }else{
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确定要%@关联当前选择资源吗",isDeleteGuanlan?@"取消":@""] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (guanlianArr.count!=2) {
                //查询失败，提示用户
                [YuanHUD HUDFullText:@"请选择两个资源进行关联操作"];
                
                
                return;
            }
            
            [self guanlianResData];
        }];
        UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [guanlianBtn setTitle:@"资源关联" forState:UIControlStateNormal];
            isAddGuanlian = NO;
            isDeleteGuanlan = NO;
            [guanlianArr removeAllObjects];
            [self markShow];
        }];
        
        [alert addAction:actionYES];
        [alert addAction:actionNO];
        Present(self, alert);
    }
}
//自动定位按钮点击触发事件
-(IBAction)location:(id)sender{
    isLocationSelf = NO;
    icm.hidden = YES;
    //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
    _mapView.userTrackingMode=MAUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;//显示定位图层
}
//手动定位按钮点击触发事件
-(IBAction)locationSelf:(id)sender{
    isLocationSelf = YES;
    //停止定位监听
    _mapView.showsUserLocation = NO;//显示定位图层
    icm.hidden = NO;
}
//获取资源按钮点击触发事件
//-(IBAction)getRes:(id)sender{
////    if (isLocationSelf) {
////        //手动定位下
////        lonStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
////        latStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
////    }else{
////        lonStr = [NSString stringWithFormat:@"%f",lon];
////        latStr = [NSString stringWithFormat:@"%f",lat];
////    }
////    [self getData];
//}
-(void)setMapSelectRegion:(NSString *)selectRegion andDomainCode:(NSString *)domainCode{
    [self getDataWithProvince:selectRegion andDomainCode:domainCode];
}
-(void)getCable:(NSDictionary *)cable{
    if (cable!=nil&&[cable objectForKey:@"GID"]!=nil) {
        [self getResData:@"cable" :[cable objectForKey:@"GID"]:@"光缆段":cable];
    }
}
-(void)getRoute:(NSDictionary *)route{
    if (route!=nil&&[route objectForKey:@"GID"]!=nil) {
        [self getResData:@"route" :[route objectForKey:@"GID"]:@"光缆":route];
    }
}

#pragma mark - 资源查询 点击后回调

-(void)deviceWithDict:(NSDictionary *)dict withSenderTag:(NSInteger)senderTag{
    if ([dict[@"resLogicName"] isEqualToString:@"poleline"]) {
        if (dict!=nil&&[dict objectForKey:@"GID"]!=nil) {
            [self getResData:@"poleline" :[dict objectForKey:@"GID"]:@"杆路":dict];
        }
    }else if ([dict[@"resLogicName"] isEqualToString:@"pipe"]) {
        if (dict!=nil&&[dict objectForKey:@"GID"]!=nil) {
            [self getResData:@"pipe" :[dict objectForKey:@"GID"]:@"管道":dict];
        }
    }else if ([dict[@"resLogicName"] isEqualToString:@"stationBase"]) {
        if (dict!=nil&&[dict objectForKey:@"GID"]!=nil) {
            [self getResData:@"stationBase" :[dict objectForKey:@"GID"]:@"局站":dict];
        }
    }else if ([dict[@"resLogicName"] isEqualToString:@"markStonePath"]) {
        if (dict!=nil&&[dict objectForKey:@"GID"]!=nil) {
            [self getResData:@"markStonePath" :[dict objectForKey:@"GID"]:@"标石路径":dict];
        }
    }else if ([dict[@"resLogicName"] isEqualToString:@"route"]) {
        if (dict!=nil&&[dict objectForKey:@"GID"]!=nil) {
            [self getResData:@"route" :[dict objectForKey:@"GID"]:@"光缆":dict];
        }
    }else if ([dict[@"resLogicName"] isEqualToString:@"cable"]) {
        if (dict!=nil&&[dict objectForKey:@"GID"]!=nil) {
            if (_isGualan) {
                self.cableInfo = dict;
                self.cableNameLabel.hidden = false;
                self.cableNameLabel.text = dict[@"cableName"];
                
            }else{
                [self getResData:@"cable" :[dict objectForKey:@"GID"]:@"光缆段":dict];
            }
        }
    }
}
//获取各类型资源信息
-(void)getResData:(NSString *)type : (NSString *)resId :(NSString *)typeChineseName :(NSDictionary *)selectRes{
    
//    static NSString * ID_res;
    
    if ([ID_res isEqualToString:resId]) {
        
        //MARK: 袁全添加 , 当没有搜索到资源时 , 提示暂无资源
        [YuanHUD HUDFullText:@"当前资源已加载"];

        
        return;
        
    } else {
        
        ID_res = resId;
    }
    
    [YuanHUD HUDStartText:[NSString stringWithFormat:@"正在获取%@资源信息......",typeChineseName]];
    
    
    //调用查询接口
    NSDictionary *param = @{@"UID":_userModel.uid};
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
#endif
    
    
    NSString * URL = [NSString stringWithFormat:@"%@rm!getSpecialMarks.interface?markRequest.markResType=%@&markRequest.markContent=%@",baseURL,type,resId];
    
    

    
    
    [Http.shareInstance POST:URL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        
        NSDictionary *dic = responseObject;
        
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            [YuanHUD HUDHide];
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:tempData options:kNilOptions error:nil];
            
            NSLog(@"%@",tempDic);
            
            if (self.poiinfo == nil) {
                self.poiinfo = [[NSMutableDictionary alloc] initWithDictionary:tempDic];
                [self initOverlay];
            }else{
                NSMutableArray *listd = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_d"]];
                NSArray *tempListD = (NSArray *)[tempDic objectForKey:@"list_d"];
                //进行资源累加操作
                if (tempListD != nil &&tempListD.count>0) {
                    for (int i = 0; i<tempListD.count; i++) {
                        BOOL isHave = NO;
                        for (int j = 0; j<listd.count; j++) {
                            if ([tempListD[i][@"markResType"] isEqualToString:listd[j][@"markResType"]]&&
                                [[NSString stringWithFormat:@"%@",tempListD[i][@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",listd[j][@"markResId"]]]) {
                                isHave = YES;
                                break;
                            }
                        }
                        if (!isHave) {
                            NSLog(@"add~~~~~~~~~");
                            [listd addObject:tempListD[i]];
                        }
                    }
                } else {
                    
                    //MARK: 袁全添加 , 当没有搜索到资源时 , 提示暂无资源
                    [YuanHUD HUDFullText:@"暂无资源"];
                }
                
                [self.poiinfo removeObjectForKey:@"list_d"];
                [self.poiinfo setObject:listd forKey:@"list_d"];
                
                
                
                NSMutableArray *listx = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_x"]];
                NSArray *tempListX = (NSArray *)[tempDic objectForKey:@"list_x"];
                //进行资源累加操作
                if (tempListX != nil &&tempListX.count>0) {
                    for (int i = 0; i<tempListX.count; i++) {
                        if ([tempListX[i][@"markResType"] isEqualToString:@"resRelation"]) {
                            NSLog(@"addx~~~~~~~~~res");
                            [listx addObject:tempListX[i]];
                        }else{
                            BOOL isHave = NO;
                            for (int j = 0; j<listx.count; j++) {
                                if ([tempListX[i][@"markResType"] isEqualToString:listx[j][@"markResType"]]&&
                                    [[NSString stringWithFormat:@"%@",tempListX[i][@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",listx[j][@"markResId"]]]) {
                                    NSLog(@"isHaveX");
                                    isHave = YES;
                                    break;
                                }
                            }
                            if (!isHave) {
                                NSLog(@"addx~~~~~~~~~");
                                [listx addObject:tempListX[i]];
                            }
                        }
                    }
                }
                [self.poiinfo removeObjectForKey:@"list_x"];
                [self.poiinfo setObject:listx forKey:@"list_x"];
            }
            
            if (self.poiinfo != nil) {
                [self markShow];
                shaixuanDArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_d"]];
                shaixuanXArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_x"]];
                //查询数据之后重新初始化显示
                NSMutableArray * dataSource = [NSMutableArray array];
                for (int i = 0; i < self.shaiXuanDataSource.count; i++) {
                    
                    NSString * key = [NSString stringWithFormat:@"%d", i];
                    
                    NSDictionary * dict = @{key:@YES};
                    
                    [dataSource addObject:dict];
                }
                self.switcherDataSource = dataSource;
                [self.shaiXuanListView reloadData];
                
                [self searchSelectUiDismiss];
                BOOL isAdd = NO;
                NSLog(@"传过来的type:%@",type);
                
                if ([type isEqualToString:@"poleline"]&&![self.plusDataSource containsObject:selectRes[@"poleLineName"]]) {
                    //杆路
                    [self.plusDataSource addObject:selectRes[@"poleLineName"]];
                    isAdd = YES;
                }else if ([type isEqualToString:@"pipe"]&&![self.plusDataSource containsObject:selectRes[@"pipeName"]]){
                    //管道
                    [self.plusDataSource addObject:selectRes[@"pipeName"]];
                    isAdd = YES;
                }else if ([type isEqualToString:@"stationBase"]&&![self.plusDataSource containsObject:selectRes[@"stationName"]]){
                    //局站
                    [self.plusDataSource addObject:selectRes[@"stationName"]];
                    isAdd = YES;
                }else if ([type isEqualToString:@"markStonePath"]&&![self.plusDataSource containsObject:selectRes[@"markStonePName"]]){
                    //标石路径
                    [self.plusDataSource addObject:selectRes[@"markStonePName"]];
                    isAdd = YES;
                }else if ([type isEqualToString:@"route"]&&![self.plusDataSource containsObject:selectRes[@"routename"]]){
                    //光缆
                    [self.plusDataSource addObject:selectRes[@"routename"]];
                    isAdd = YES;
                }else if ([type isEqualToString:@"cable"]&&![self.plusDataSource containsObject:selectRes[@"cableName"]]){
                    //光缆段
                    [self.plusDataSource addObject:selectRes[@"cableName"]];
                    isAdd = YES;
                }
                
                /// >>>>>>>>>>>
                
                // 默认选中
                //查询数据之后重新初始化显示
                NSMutableArray * dataSource2 = [NSMutableArray array];
                for (int i = 0; i < self.plusDataSource.count; i++) {
                    
                    [dataSource2 addObject:@YES];
                }
                self.plusSwitcherDataSource = nil;
                
                self.plusSwitcherDataSource = [NSArray arrayWithArray:dataSource2];
                
                /// <<<<<<<<<<<
                if (isAdd) {
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setObject:[[NSMutableDictionary alloc] initWithDictionary:tempDic] forKey:selectRes];
                    [plusDataSourceMapData addObject:dic];
                    
                    NSMutableArray * imageNames = [NSMutableArray arrayWithArray:self.imageNames];
                    [imageNames addObject:type];
                    self.imageNames = imageNames;
                }
                
                [self.plusListView reloadData];
                
                if (_isGualan && _cableInfo != nil) {
                    [self showShaixuanMarkResult];
                }
                
                NSLog(@"self.plusDataSource:%@",self.plusDataSource);
                NSLog(@"plusDataSourceMapData:%@",plusDataSourceMapData);
            }
        }else{
            //操作执行完后取消对话框
            [YuanHUD HUDHide];
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [YuanHUD HUDHide];
        [YuanHUD HUDFullText:@"请求出错"];
        
    }];
}
//根据选择的省份获取地图资源信息todo
-(void)getDataWithProvince:(NSString *)provinceStr andDomainCode:(NSString *)domainCodeStr{
    NSLog(@"provinceStr:%@,domainCodeStr:%@",provinceStr,domainCodeStr);
    //弹出进度框
    [YuanHUD HUDStartText:@"正在切换"];
    //调用查询接口
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setValue:_userModel.uid forKey:@"UID"];
    NSDictionary * request = @{@"areano":domainCodeStr};
    [param setValue:request.json forKey:@"jsonRequest"];
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
#endif
    
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@pdaLogin!changeAreano.interface",baseURL] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
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
            self.poiinfo = nil;
            
            AMapDistrictSearchRequest *dist = [[AMapDistrictSearchRequest alloc] init];
            dist.keywords = provinceStr;
            dist.requireExtension = YES;
            [self.search AMapDistrictSearch:dist];
            
        }else{
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            //查询失败，提示用户
            [YuanHUD HUDFullText:REPLACE_HHF([dic objectForKey:@"info"])];
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [HUD removeFromSuperview];
        HUD = nil;
        
        [YuanHUD HUDFullText:@"亲，网络请求出错了"];
    
        
    }];
}
//获取地图资源信息
-(void)getData{
    
    
    
    //弹出进度框
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    //如果设置此属性则当前的view置于后台
    
    //设置对话框文字
    HUD.label.text = @"正在获取地图资源......";
    //显示对话框
    [HUD showAnimated:YES];
    //调用查询接口
    NSDictionary *param = @{@"UID":_userModel.uid};
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
#endif
    
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@GIS!showMarks.interface?markGrid.markSLat=%@&markGrid.markSLon=%@",baseURL,latStr,lonStr] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:tempData options:kNilOptions error:nil];
            //            self.poiinfo = [[NSMutableDictionary alloc] initWithDictionary:tempDic];
            //            if (self.poiinfo != nil) {
            //                [self markShow];
            //                [self initOverlay];
            //            }
            if (self.poiinfo == nil) {
                self.poiinfo = [[NSMutableDictionary alloc] initWithDictionary:tempDic];
                [self initOverlay];
            }else{
                NSMutableArray *listd = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_d"]];
                NSArray *tempListD = (NSArray *)[tempDic objectForKey:@"list_d"];
                //进行资源累加操作
                if (tempListD != nil &&tempListD.count>0) {
                    for (int i = 0; i<tempListD.count; i++) {
                        BOOL isHave = NO;
                        for (int j = 0; j<listd.count; j++) {
                            if ([tempListD[i][@"markResType"] isEqualToString:listd[j][@"markResType"]]&&
                                [[NSString stringWithFormat:@"%@",tempListD[i][@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",listd[j][@"markResId"]]]) {
                                isHave = YES;
                                break;
                            }
                        }
                        if (!isHave) {
                            NSLog(@"add~~~~~~~~~");
                            [listd addObject:tempListD[i]];
                        }
                    }
                }
                
                [self.poiinfo removeObjectForKey:@"list_d"];
                [self.poiinfo setObject:listd forKey:@"list_d"];
                
                
                
                NSMutableArray *listx = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_x"]];
                NSArray *tempListX = (NSArray *)[tempDic objectForKey:@"list_x"];
                //进行资源累加操作
                if (tempListX != nil &&tempListX.count>0) {
                    for (int i = 0; i<tempListX.count; i++) {
                        if ([tempListX[i][@"markResType"] isEqualToString:@"resRelation"]) {
                            NSLog(@"addx~~~~~~~~~res");
                            [listx addObject:tempListX[i]];
                        }else{
                            BOOL isHave = NO;
                            for (int j = 0; j<listx.count; j++) {
                                if ([tempListX[i][@"markResType"] isEqualToString:listx[j][@"markResType"]]&&
                                    [[NSString stringWithFormat:@"%@",tempListX[i][@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",listx[j][@"markResId"]]]) {
                                    NSLog(@"isHaveX");
                                    isHave = YES;
                                    break;
                                }
                            }
                            if (!isHave) {
                                NSLog(@"addx~~~~~~~~~");
                                [listx addObject:tempListX[i]];
                            }
                        }
                    }
                }
                [self.poiinfo removeObjectForKey:@"list_x"];
                [self.poiinfo setObject:listx forKey:@"list_x"];
            }
            
            if (self.poiinfo != nil) {
                [self markShow];
                shaixuanDArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_d"]];
                shaixuanXArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_x"]];
                //查询数据之后重新初始化显示
                NSMutableArray * dataSource = [NSMutableArray array];
                for (int i = 0; i < self.shaiXuanDataSource.count; i++) {
                    
                    NSString * key = [NSString stringWithFormat:@"%d", i];
                    
                    NSDictionary * dict = @{key:@YES};
                    
                    [dataSource addObject:dict];
                }
                self.switcherDataSource = dataSource;
                [self.shaiXuanListView reloadData];
                
                [self searchSelectUiDismiss];
            }
        }else{
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            //查询失败，提示用户
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.label.text = [NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])];
            HUD.mode = MBProgressHUDModeText;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                HUD.mode = MBProgressHUDModeText ;
                
                [HUD hideAnimated:YES afterDelay:2];
                
                HUD = nil;
            });
            

            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [HUD removeFromSuperview];
        HUD = nil;
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
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

//MARK: 获取单个资源信息
-(void)getOneData{
    
    NSLog(@"%@", temp);
    
    Inc_NewMB_VM * vm = Inc_NewMB_VM.viewModel;
    
    NSString * type = [vm getNewTypeFromOldResLogicName:temp[@"resLogicName"]];
    
    Yuan_NewMB_ModelEnum_ jumpEnum = [vm EnumFromFileName:type];
    if (jumpEnum == Yuan_NewMB_ModelEnum_None) {
        [YuanHUD HUDFullText:@"未找到json文件"];
        return;
    }
    
    [Inc_Push_MB NewMB_PushDetailsFromId:temp[@"GID"]
                                    Enum:jumpEnum
                                      vc:self
                               saveBlock:^(id  _Nonnull result) {
        
    }];
    
    
    return;
    
    /* 非自己工单 */
    
    NSString * TASKID = [temp valueForKey:@"taskId"];
    
    
    NSLog(@"%@", temp);
    if (![StrUtil isMyOrderWithTaskId:TASKID] && TASKID != nil && TASKID.length > 0) {
        
        /* 取出工单 */
        NSString * taskId = [StrUtil taskIdWithTaskId:TASKID];
        /* 工单接收人 */
        NSString * reciverName = [StrUtil reciverWithTaskId:TASKID];
        /* 提示 */
        [YuanHUD HUDFullText:@"无权操作该工单资源"];
        return;
    }
    
    
    
    //弹出进度框todo
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    //如果设置此属性则当前的view置于后台
    
    //设置对话框文字
    HUD.label.text = @"正在获取资源信息......";
    //显示对话框
    [HUD showAnimated:YES];
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
#endif
    
    //调用查询接口
    NSDictionary *param = @{@"UID":_userModel.uid,@"jsonRequest":[strUtil dicToJSon:temp]};
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@rm!getCommonData.interface",baseURL] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:arr];
            if (tempArray == nil || [tempArray count] == 0) {
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                HUD.detailsLabel.text = @"对不起，您没有查看该资源详细信息的权限";
                HUD.mode = MBProgressHUDModeText;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    HUD.mode = MBProgressHUDModeText ;
                    
                    [HUD hideAnimated:YES afterDelay:2];
                    
                    HUD = nil;
                });
                return;
            }
//            if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"well"]) {
//                //跳转到井
//                [self propertiesReader:@"well"];
//                TYKDeviceInfoMationViewController * well = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:@"well"];
//                well.delegate = self;
//                [self.navigationController pushViewController:well animated:YES];
//            }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"pole"]){
//                //跳转到电杆
//                [self propertiesReader:@"pole"];
//                TYKDeviceInfoMationViewController * pole = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:@"pole"];
//                pole.delegate = self;
//                [self.navigationController pushViewController:pole animated:YES];
//            }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"OCC_Equt"]){
//                //跳转到OCC
//                [self propertiesReader:@"OCC_Equt"];
//                TYKDeviceInfoMationViewController * occ = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:@"OCC_Equt"];
//                occ.delegate = self;
//                [self.navigationController pushViewController:occ animated:YES];
//            }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"ODF_Equt"]){
//                //跳转到ODF
//                [self propertiesReader:@"ODF_Equt"];
//                TYKDeviceInfoMationViewController * odf = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:@"ODF_Equt"];
//                odf.delegate = self;
//                [self.navigationController pushViewController:odf animated:YES];
//            }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"ODB_Equt"]){
//                //跳转到ODB
//                [self propertiesReader:@"ODB_Equt"];
//                TYKDeviceInfoMationViewController * odb = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:@"ODB_Equt"];
//                odb.delegate = self;
//                [self.navigationController pushViewController:odb animated:YES];
//            }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"generator"]){
//                //跳转到机房
//                [self propertiesReader:@"generator"];
//                TYKDeviceInfoMationViewController * geo =[TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:@"generator"];
//                geo.delegate = self;
//                [self.navigationController pushViewController:geo animated:YES];
//            }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"stationBase"]){
//                //跳转到局站
//                [self propertiesReader:@"stationBase"];
//                TYKDeviceInfoMationViewController * station = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:@"stationBase"];
//                station.delegate = self;
//                [self.navigationController pushViewController:station animated:YES];
//
//            }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"ledUp"]){
//                //跳转到引上点
//                [self propertiesReader:@"ledUp"];
//                TYKDeviceInfoMationViewController * ledUP = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:@"ledUp"];
//                ledUP.delegate = self;
//                [self.navigationController pushViewController:ledUP animated:YES];
//            }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"markStone"]){
//                //跳转到标石
//                [self propertiesReader:@"markStone"];
//                TYKDeviceInfoMationViewController * markStone = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:@"markStone"];
//                markStone.delegate = self;
//                [self.navigationController pushViewController:markStone animated:YES];
//            }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"joint"]){
//                //跳转到接头盒
//                [self propertiesReader:@"joint"];
//                TYKDeviceInfoMationViewController * joint = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:@"joint"];
//                joint.delegate = self;
//                [self.navigationController pushViewController:joint animated:YES];
//            }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"supportingPoints"]){
//                //跳转到撑点
//                [self propertiesReader:@"supportingPoints"];
//                TYKDeviceInfoMationViewController * sup = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:@"supportingPoints"];
//                sup.delegate = self;
//                [self.navigationController pushViewController:sup animated:YES];
//            }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"EquipmentPoint"]){
//                //跳转到设备放置点
//                [self propertiesReader:@"EquipmentPoint"];
//                TYKDeviceInfoMationViewController * ep = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:@"EquipmentPoint"];
//                ep.delegate = self;
//                [self.navigationController pushViewController:ep animated:YES];
//            }else{
//                [self propertiesReader:[self.poiclick objectForKey:@"markResType"]];
//                TYKDeviceInfoMationViewController * ep = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_mainModel withViewModel:_viewModel withDataDict:tempArray[0] withFileName:[self.poiclick objectForKey:@"markResType"]];
//                ep.delegate = self;
//                [self.navigationController pushViewController:ep animated:YES];
//            }
        }else{
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            //查询失败，提示用户
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.label.text = [NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])];
            HUD.mode = MBProgressHUDModeText;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                HUD.mode = MBProgressHUDModeText ;
                
                
                
                [HUD hideAnimated:YES afterDelay:2];
                
                HUD = nil;
            });
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [HUD removeFromSuperview];
        HUD = nil;
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
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
//获取端子路由资源信息

- (void)showRoute{
    
    //弹出进度框
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    //如果设置此属性则当前的view置于后台
    
    //设置对话框文字
    HUD.label.text = @"正在获取路由信息，请稍候……";
    //显示对话框
    [HUD showAnimated:YES];
    //调用查询接口
    NSDictionary *param = @{@"UID":_userModel.uid};
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
#endif
    
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@/GIS!showMarks.interface?markRequest.markResType=%@&markRequest.markContent=%@",baseURL,_resLogicName,_GID] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:tempData options:kNilOptions error:nil];
            //            self.poiinfo = [[NSMutableDictionary alloc] initWithDictionary:tempDic];
            //            if (self.poiinfo != nil) {
            //                [self markShow];
            //                [self initOverlay];
            //            }
            if (self.poiinfo == nil) {
                self.poiinfo = [[NSMutableDictionary alloc] initWithDictionary:tempDic];
                [self initOverlay];
            }else{
                NSMutableArray *listd = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_d"]];
                NSArray *tempListD = (NSArray *)[tempDic objectForKey:@"list_d"];
                //进行资源累加操作
                if (tempListD != nil &&tempListD.count>0) {
                    for (int i = 0; i<tempListD.count; i++) {
                        BOOL isHave = NO;
                        for (int j = 0; j<listd.count; j++) {
                            if ([tempListD[i][@"markResType"] isEqualToString:listd[j][@"markResType"]]&&
                                [[NSString stringWithFormat:@"%@",tempListD[i][@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",listd[j][@"markResId"]]]) {
                                isHave = YES;
                                break;
                            }
                        }
                        if (!isHave) {
                            NSLog(@"add~~~~~~~~~");
                            [listd addObject:tempListD[i]];
                        }
                    }
                }
                
                [self.poiinfo removeObjectForKey:@"list_d"];
                [self.poiinfo setObject:listd forKey:@"list_d"];
                
                
                
                NSMutableArray *listx = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_x"]];
                NSArray *tempListX = (NSArray *)[tempDic objectForKey:@"list_x"];
                //进行资源累加操作
                if (tempListX != nil &&tempListX.count>0) {
                    for (int i = 0; i<tempListX.count; i++) {
                        if ([tempListX[i][@"markResType"] isEqualToString:@"resRelation"]) {
                            NSLog(@"addx~~~~~~~~~res");
                            [listx addObject:tempListX[i]];
                        }else{
                            BOOL isHave = NO;
                            for (int j = 0; j<listx.count; j++) {
                                if ([tempListX[i][@"markResType"] isEqualToString:listx[j][@"markResType"]]&&
                                    [[NSString stringWithFormat:@"%@",tempListX[i][@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",listx[j][@"markResId"]]]) {
                                    NSLog(@"isHaveX");
                                    isHave = YES;
                                    break;
                                }
                            }
                            if (!isHave) {
                                NSLog(@"addx~~~~~~~~~");
                                [listx addObject:tempListX[i]];
                            }
                        }
                    }
                }
                [self.poiinfo removeObjectForKey:@"list_x"];
                [self.poiinfo setObject:listx forKey:@"list_x"];
            }
            
            if (self.poiinfo != nil) {
                [self markShow];
                shaixuanDArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_d"]];
                shaixuanXArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_x"]];
                //查询数据之后重新初始化显示
                NSMutableArray * dataSource = [NSMutableArray array];
                for (int i = 0; i < self.shaiXuanDataSource.count; i++) {
                    
                    NSString * key = [NSString stringWithFormat:@"%d", i];
                    
                    NSDictionary * dict = @{key:@YES};
                    
                    [dataSource addObject:dict];
                }
                self.switcherDataSource = dataSource;
                [self.shaiXuanListView reloadData];
                
                [self searchSelectUiDismiss];
            }
        }else{
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            //查询失败，提示用户
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.label.text = [NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])];
            HUD.mode = MBProgressHUDModeText;
            
                        dispatch_async(dispatch_get_main_queue(), ^{
                
                HUD.mode = MBProgressHUDModeText ;
                
                
                
                [HUD hideAnimated:YES afterDelay:2];
                
                HUD = nil;
            });
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [HUD removeFromSuperview];
        HUD = nil;
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
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

-(void)getPointData:(NSString *)fiberstationname{
    NSLog(@"fiberstationname:%@",fiberstationname);
    NSString *fiberStr = [fiberstationname stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"fiberStr:%@",fiberStr);
    //弹出进度框
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    //如果设置此属性则当前的view置于后台
    
    //设置对话框文字
    HUD.label.text = @"正在获取路由信息......";
    //显示对话框
    [HUD showAnimated:YES];
    //调用查询接口
    NSDictionary *param = @{@"UID":_userModel.uid};
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
#endif
    
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@GIS!showMarks.interface?markRequest.markResType=cable_fiberStationName&markRequest.markContent=%@",baseURL,fiberStr] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:tempData options:kNilOptions error:nil];
            //            self.poiinfo = [[NSMutableDictionary alloc] initWithDictionary:tempDic];
            //            if (self.poiinfo != nil) {
            //                [self markShow];
            //                [self initOverlay];
            //            }
            if (self.poiinfo == nil) {
                self.poiinfo = [[NSMutableDictionary alloc] initWithDictionary:tempDic];
                [self initOverlay];
            }else{
                NSMutableArray *listd = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_d"]];
                NSArray *tempListD = (NSArray *)[tempDic objectForKey:@"list_d"];
                //进行资源累加操作
                if (tempListD != nil &&tempListD.count>0) {
                    for (int i = 0; i<tempListD.count; i++) {
                        BOOL isHave = NO;
                        for (int j = 0; j<listd.count; j++) {
                            if ([tempListD[i][@"markResType"] isEqualToString:listd[j][@"markResType"]]&&
                                [[NSString stringWithFormat:@"%@",tempListD[i][@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",listd[j][@"markResId"]]]) {
                                isHave = YES;
                                break;
                            }
                        }
                        if (!isHave) {
                            NSLog(@"add~~~~~~~~~");
                            [listd addObject:tempListD[i]];
                        }
                    }
                }
                
                [self.poiinfo removeObjectForKey:@"list_d"];
                [self.poiinfo setObject:listd forKey:@"list_d"];
                
                
                
                NSMutableArray *listx = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_x"]];
                NSArray *tempListX = (NSArray *)[tempDic objectForKey:@"list_x"];
                //进行资源累加操作
                if (tempListX != nil &&tempListX.count>0) {
                    for (int i = 0; i<tempListX.count; i++) {
                        if ([tempListX[i][@"markResType"] isEqualToString:@"resRelation"]) {
                            NSLog(@"addx~~~~~~~~~res");
                            [listx addObject:tempListX[i]];
                        }else{
                            BOOL isHave = NO;
                            for (int j = 0; j<listx.count; j++) {
                                if ([tempListX[i][@"markResType"] isEqualToString:listx[j][@"markResType"]]&&
                                    [[NSString stringWithFormat:@"%@",tempListX[i][@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",listx[j][@"markResId"]]]) {
                                    NSLog(@"isHaveX");
                                    isHave = YES;
                                    break;
                                }
                            }
                            if (!isHave) {
                                NSLog(@"addx~~~~~~~~~");
                                [listx addObject:tempListX[i]];
                            }
                        }
                    }
                }
                [self.poiinfo removeObjectForKey:@"list_x"];
                [self.poiinfo setObject:listx forKey:@"list_x"];
            }
            
            if (self.poiinfo != nil) {
                [self markShow];
                shaixuanDArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_d"]];
                shaixuanXArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_x"]];
                //查询数据之后重新初始化显示
                NSMutableArray * dataSource = [NSMutableArray array];
                for (int i = 0; i < self.shaiXuanDataSource.count; i++) {
                    
                    NSString * key = [NSString stringWithFormat:@"%d", i];
                    
                    NSDictionary * dict = @{key:@YES};
                    
                    [dataSource addObject:dict];
                }
                self.switcherDataSource = dataSource;
                [self.shaiXuanListView reloadData];
                
                [self searchSelectUiDismiss];
            }
        }else{
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            //查询失败，提示用户
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.label.text = [NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])];
            HUD.mode = MBProgressHUDModeText;
            
                        dispatch_async(dispatch_get_main_queue(), ^{
                
                HUD.mode = MBProgressHUDModeText ;
                
                
                
                [HUD hideAnimated:YES afterDelay:2];
                
                HUD = nil;
            });
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [HUD removeFromSuperview];
        HUD = nil;
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
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
//关联资源关系
-(void)guanlianResData{
    //弹出进度框
    
    [YuanHUD HUDStartText:@"正在保存关联信息..."];
    
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:guanlianArr[0][@"startObjectId"] forKey:@"startObjectId"];
    [requestDic setObject:guanlianArr[0][@"startObjectType"] forKey:@"startObjectType"];
    [requestDic setObject:guanlianArr[1][@"endObjectId"] forKey:@"endObjectId"];
    [requestDic setObject:guanlianArr[1][@"endObjectType"] forKey:@"endObjectType"];
    [requestDic setObject:@"resRelation" forKey:@"resLogicName"];
    NSString *postUrlStr;
    
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
#endif
    
    if (isAddGuanlian) {
        NSLog(@"insertData.interface");
        postUrlStr = [NSString stringWithFormat:@"%@data!insertData.interface",baseURL];
    }else if(isDeleteGuanlan){NSLog(@"deleteData.interface");
        postUrlStr = [NSString stringWithFormat:@"%@data!deleteData.interface",baseURL];
    }
    
    
    NSDictionary *param = @{@"UID":_userModel.uid,@"jsonRequest":[strUtil dicToJSon:requestDic]};
    NSLog(@"param %@",param);
    [Http.shareInstance POST:postUrlStr parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        
        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            [YuanHUD HUDHide];
            [guanlianBtn setTitle:@"资源关联" forState:UIControlStateNormal];
            
            NSMutableArray *listx = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_x"]];
            [self.poiinfo removeObjectForKey:@"list_x"];
            [self.poiinfo setObject:listx forKey:@"list_x"];
            if (isAddGuanlian) {
                NSLog(@"添加");
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:guanlianArr[0][@"lat"] forKey:@"markSLat"];
                [tempDic setObject:guanlianArr[0][@"lon"] forKey:@"markSLon"];
                [tempDic setObject:guanlianArr[1][@"lat"] forKey:@"markELat"];
                [tempDic setObject:guanlianArr[1][@"lon"] forKey:@"markELon"];
                [tempDic setObject:@"resRelation" forKey:@"markResType"];
                
                [[self.poiinfo objectForKey:@"list_x"] addObject:tempDic];
                
            }else if (isDeleteGuanlan){
                NSLog(@"删除");
                for (int i = 0; i<[[self.poiinfo objectForKey:@"list_x"] count]; i++) {
                    NSDictionary *tempmark = [self.poiinfo objectForKey:@"list_x"][i];
                    if (([guanlianArr[0][@"lat"] isEqualToString:tempmark[@"markSLat"]]&&
                         [guanlianArr[0][@"lon"] isEqualToString:tempmark[@"markSLon"]]&&
                         [guanlianArr[1][@"lat"] isEqualToString:tempmark[@"markELat"]]&&
                         [guanlianArr[1][@"lon"] isEqualToString:tempmark[@"markELon"]])||
                        ([guanlianArr[0][@"lat"] isEqualToString:tempmark[@"markELat"]]&&
                         [guanlianArr[0][@"lon"] isEqualToString:tempmark[@"markELon"]]&&
                         [guanlianArr[1][@"lat"] isEqualToString:tempmark[@"markSLat"]]&&
                         [guanlianArr[1][@"lon"] isEqualToString:tempmark[@"markSLon"]])) {
                            NSLog(@"走了吗");
                            [[self.poiinfo objectForKey:@"list_x"] removeObjectAtIndex:i];
                        }
                }
            }
            shaixuanXArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_x"]];
            
            [self markShow];
            [guanlianArr removeAllObjects];
            isAddGuanlian = NO;
            isDeleteGuanlan = NO;
            
            //查询数据之后重新初始化显示
            NSMutableArray * dataSource = [NSMutableArray array];
            for (int i = 0; i < self.shaiXuanDataSource.count; i++) {
                
                NSString * key = [NSString stringWithFormat:@"%d", i];
                
                NSDictionary * dict = @{key:@YES};
                
                [dataSource addObject:dict];
            }
            self.switcherDataSource = dataSource;
            [self.shaiXuanListView reloadData];
        }else{
            //操作执行完后取消对话框
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            //操作失败，提示用户
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.label.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"info"]];
            HUD.mode = MBProgressHUDModeText;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                HUD.mode = MBProgressHUDModeText ;
                
                [HUD hideAnimated:YES afterDelay:2];
                
                HUD = nil;
            });
            
            [guanlianBtn setTitle:@"资源关联" forState:UIControlStateNormal];
            isAddGuanlian = NO;
            isDeleteGuanlan = NO;
            [guanlianArr removeAllObjects];
            [self markShow];
            
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
-(void)viewWillAppear:(BOOL)animated
{
    //[_mapView viewWillAppear];
    
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
    _search.delegate = self;
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    //[_mapView viewWillDisappear];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.view.layer removeAllAnimations];
    _mapView.delegate = nil; // 不用时，置nil
    _search.delegate = nil;
    if (self.isPushedBy3DTouch) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
    if (self.plusListView) {
        [self.plusListView hideListViewNOAnimation:YES];
    }
    
    if (self.shaiXuanListView) {
        [self.plusListView hideListViewNOAnimation:YES];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    if (_isGualan && _cableInfo == nil) {
        _gualanBtn.selected = false;
        _isGualan = false;
        
        // 放在前方，以刷新管道段图标
    }
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [self markShow];
    [self showShaixuanMarkResult];
    
    
    
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - 袁全添加 时刻获取地图中心点的位置 , 如果选择自动定位 , 使用block回调的经纬度 , 手动定位选择这个代理方法返回的经纬度

#pragma mark - MAMapDeleagte

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    
    /*
        当手动定位时 , 会用到这个经纬度
     */
    dynamicLat = mapView.region.center.latitude;
    dynamicLog = mapView.region.center.longitude;

    NSLog(@"%f -- %f",dynamicLat , dynamicLog);
}






/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if (updatingLocation)
    {
        if (isFirst) {
            isFirst = NO;
            NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
            
            coordinate = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
            MACoordinateRegion region ;//表示范围的结构体
            region.center = coordinate;//中心点
            region.span.latitudeDelta = 0.1;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
            region.span.longitudeDelta = 0.1;//纬度范围
            [_mapView setRegion:region animated:YES];
            [_mapView setZoomLevel:17 animated:NO];
            
            
            
            lon = coordinate.longitude;
            lat = coordinate.latitude;
        }
    }
    
}
// Override
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    
    
    Yuan_PointAnnotation *cusAnotation = (Yuan_PointAnnotation *)annotation;
    if ([annotation isKindOfClass:[Yuan_PointAnnotation class]]) {
        
        if (cusAnotation.isSegCenter) {
            
            MAAnnotationView *annotationView = [[MAAnnotationView alloc] initWithAnnotation:cusAnotation reuseIdentifier:@"segAnno"];
            
            annotationView.annotation = cusAnotation;
            
            annotationView.image = [UIImage Inc_imageNamed:@"icon_anno_pipesegment_normal"];
            annotationView.centerOffset = CGPointMake(0, annotationView.height / -2.f);
            
            
            
            return annotationView;
        }
        
        
        //设置覆盖物显示相关基本信息
        //        CustomAnnotationView *annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        MAAnnotationView *annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        if (cusAnotation.tag>=10000&&cusAnotation.tag<20000) {
            //当为井类型时
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_well_tyk"];
        }else if(cusAnotation.tag>=20000&&cusAnotation.tag<30000){
            //当为电杆类型时
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_pole_tyk"];
        }else if(cusAnotation.tag>=30000&&cusAnotation.tag<40000){
            //当为OCC类型时
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_occ_tyk"];
        }else if(cusAnotation.tag>=40000&&cusAnotation.tag<50000){
            //当为局站类型时
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_station_tyk"];
        }else if(cusAnotation.tag>=50000&&cusAnotation.tag<60000){
            //当为引上点类型时
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_2_tyk"];
        }else if(cusAnotation.tag>=60000&&cusAnotation.tag<70000){
            //当为标石类型时
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_tyk_nnew"];
        }else if(cusAnotation.tag>=70000&&cusAnotation.tag<80000){
            //当为ODF类型时
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_odf_tyk"];
        }else if(cusAnotation.tag>=80000&&cusAnotation.tag<90000){
            //当为机房类型时
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_generator_tyk"];
        }else if(cusAnotation.tag>=90000&&cusAnotation.tag<100000){
            //当为ODB类型时
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_odb_tyk"];
        }else if(cusAnotation.tag>=100000&&cusAnotation.tag<110000){
            //当为接头盒类型时
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_joint_tyk"];
        }else if(cusAnotation.tag>=110000&&cusAnotation.tag<120000){
            //当为撑点类型时
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_sp_tyk"];
        }else if(cusAnotation.tag>=120000&&cusAnotation.tag<130000){
            //当为放置点类型时
            annotationView.image = [UIImage Inc_imageNamed:@"icon_gcoding_equpoint_tyk"];
        }else{
            annotationView.image = [UIImage Inc_imageNamed:@"red_point"];
        }
        annotationView.canShowCallout = NO;
        //        annotationView.canShowCallout = YES;
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height*0.5));
        annotationView.draggable = YES;
        
        
        
        
        
     //MARK: 袁全新增 , 给大头针 增加了一个 title描述 是个label
        
        
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
            
        
        [annotationView addSubview:label];
        
//        [label autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:-2];
        
        [label autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:annotationView withOffset:2];
        [label autoSetDimensionsToSize:CGSizeMake(expectSize.width, expectSize.height)];
        [label autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:annotationView withMultiplier:1.0];
        
        
        return annotationView;
        
    }
    return nil;
    
}




//当选中一个annotation views时，调用此接口
-(void) mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    //    if ([view.annotation isKindOfClass:[MAPointAnnotation class]]) {
    //         view.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
    //    }
    Yuan_PointAnnotation *pointAnnotation = (Yuan_PointAnnotation *)view.annotation;
    
    if (![pointAnnotation isKindOfClass:[MAUserLocation class]]) {
        
        if (_isGuanlian || _isGualan) {
            NSLog(@"进入了资源关联模式");
            if (pointAnnotation.tag>=10000&&pointAnnotation.tag<20000) {
                //当为井类型时
                view.image = [UIImage Inc_imageNamed:@"icon_gcoding_well_tyk"];
            }else if(pointAnnotation.tag>=20000&&pointAnnotation.tag<30000){
                //当为电杆类型时
                view.image = [UIImage Inc_imageNamed:@"icon_gcoding_pole_tyk"];
            }else if(pointAnnotation.tag>=30000&&pointAnnotation.tag<40000){
                //当为OCC类型时
                view.image = [UIImage Inc_imageNamed:@"icon_gcoding_occ_tyk"];
            }else if(pointAnnotation.tag>=40000&&pointAnnotation.tag<50000){
                //当为局站类型时
                view.image = [UIImage Inc_imageNamed:@"icon_gcoding_station_tyk"];
            }else if(pointAnnotation.tag>=50000&&pointAnnotation.tag<60000){
                //当为引上点类型时
                view.image = [UIImage Inc_imageNamed:@"icon_gcoding_2_tyk"];
            }else if(pointAnnotation.tag>=60000&&pointAnnotation.tag<70000){
                //当为标石类型时
                view.image = [UIImage Inc_imageNamed:@"icon_gcoding_biaoshi_tyk_nnew"];
            }else if(pointAnnotation.tag>=70000&&pointAnnotation.tag<80000){
                //当为ODF类型时
                view.image = [UIImage Inc_imageNamed:@"icon_gcoding_odf_tyk"];
            }else if(pointAnnotation.tag>=80000&&pointAnnotation.tag<90000){
                //当为机房类型时
                view.image = [UIImage Inc_imageNamed:@"icon_gcoding_generator_tyk"];
            }else if(pointAnnotation.tag>=90000&&pointAnnotation.tag<100000){
                //当为ODB类型时
                view.image = [UIImage Inc_imageNamed:@"icon_gcoding_odb_tyk"];
            }else if(pointAnnotation.tag>=100000&&pointAnnotation.tag<110000){
                //当为接头盒类型时
                view.image = [UIImage Inc_imageNamed:@"icon_gcoding_joint_tyk"];
            }else if(pointAnnotation.tag>=110000&&pointAnnotation.tag<120000){
                //当为撑点类型时
                view.image = [UIImage Inc_imageNamed:@"icon_gcoding_sp_tyk"];
            }else if(pointAnnotation.tag>=120000&&pointAnnotation.tag<130000){
                //当为放置点类型时
                view.image = [UIImage Inc_imageNamed:@"icon_gcoding_equpoint_tyk"];
            }else{
                view.image = [UIImage Inc_imageNamed:@"red_point"];
            }
            
            NSDictionary *tempDic = [[NSDictionary alloc] init];
            
            
            for (int i = 0; i<[[self.poiinfo objectForKey:@"list_d"] count]; i++) {
                NSDictionary *tempmark = [self.poiinfo objectForKey:@"list_d"][i];
                if ([[tempmark objectForKey:@"markName"] isEqualToString:pointAnnotation.title]) {
                    tempDic = tempmark;
                    break;
                }
            }
            
            NSLog(@"%@", tempDic);
            
            
            
            if (_isGuanlian) {
                // 关联相关操作
                
                NSMutableArray * arr = [NSMutableArray arrayWithArray:self.guanlianList];
                
                BOOL isIn = false;
                
                NSInteger index = 0;
                
                for (NSDictionary * tempDic2 in arr) {
                    if ([tempDic2[@"GID"] isEqualToString:tempDic[@"markResId"]]) {
                        isIn = true;
                        break;
                        
                    }
                    index++;
                }
                
                // 在开头或结尾
                if ((index == 0 || index == arr.count - 1) && isIn) {
                    
                    [self.guanlianList removeObjectAtIndex:index];
                    [_mapView deselectAnnotation:view.annotation animated:YES];
                    [self reloadLines];
                    return;
                }else{
                    if (isIn) {
                        
                        // 不在开头或结尾改回选中图片，返回不处理
                        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
                        [_mapView deselectAnnotation:view.annotation animated:YES];
                        return;
                    }
                }
                
                
                
                NSMutableDictionary * tempDict = [NSMutableDictionary dictionary];
                
                // 新增点处理
                [tempDict setValue:tempDic[@"markResType"] forKey:@"type"];
                [tempDict setValue:tempDic[@"markResId"] forKey:@"GID"];
                [tempDict setValue:tempDic[@"markName"] forKey:@"name"];
                [tempDict setValue:tempDic[@"markSLat"] forKey:@"lat"];
                [tempDict setValue:tempDic[@"markSLon"] forKey:@"lon"];
                
                [self addThisDevice:tempDict];
            }else{
                Yuan_PointAnnotation * anno = (Yuan_PointAnnotation *)view.annotation;
                NSDictionary * tempMark = anno.segMark;
                
                if (tempMark == nil) {
                    tempMark = tempDic;
                }
                
                NSLog(@"%@", tempMark);
                
                if ([tempMark[@"markResType"] isEqualToAnyString:@"pipeSegment", @"pole", @"markStone", @"ledUp", @"supportingPoints", nil]) {
                    
                    BOOL isIn = false;
                    
                    NSInteger index = 0;
                    
                    for (NSDictionary * tempDic2 in self.gualanList) {
                        if ([tempDic2[@"GID"] isEqualToString:tempMark[@"markResId"]]) {
                            isIn = true;
                            break;
                            
                        }
                        index++;
                    }
                    
                    
                    if (isIn) {
                        [self.gualanList removeObjectAtIndex:index];
                        
                        if ([tempMark[@"markResType"] isEqualToString:@"pipeSegment"]) {
                            view.image = [UIImage Inc_imageNamed:@"icon_anno_pipesegment_normal"];
                        }
                        
                        
                        [_mapView deselectAnnotation:view.annotation animated:true];
                        return;
                    }
                    
                    
                    
                    NSMutableDictionary * tempDict = [NSMutableDictionary dictionary];
    
                    [tempDict setValue:tempMark[@"markResType"] forKey:@"type"];
                    [tempDict setValue:tempMark[@"markResId"] forKey:@"GID"];
                    [tempDict setValue:tempMark[@"markName"] forKey:@"name"];
         
                    
                    [self addThisDevice:tempDict];
                  
                    if ([tempMark[@"markResType"] isEqualToString:@"pipeSegment"]) {
                        view.image = [UIImage Inc_imageNamed:@"icon_anno_pipesegment_selected"];
                    }else{
                        view.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
                    }
                    
                    
                    
                    
                }else{
                    
                    
                    [YuanHUD HUDFullText:@"正在批量挂缆，请选择管道段、电杆、撑点、引上点或标石"];
                    [_mapView deselectAnnotation:view.annotation animated:true];
                    return;
                }
                
                
                [_mapView deselectAnnotation:view.annotation animated:YES];
                
                
                
                
                return;
            }
            
            
            
            view.image = [UIImage Inc_imageNamed:@"icon_gcoding_click"];
            [_mapView deselectAnnotation:view.annotation animated:YES];
            
            
        }
        else{
            for (int i = 0; i<[[self.poiinfo objectForKey:@"list_d"] count]; i++) {
                NSDictionary *tempmark = [self.poiinfo objectForKey:@"list_d"][i];
                NSLog(@"--tempmark:%@",[tempmark objectForKey:@"markName"]);
                NSLog(@"---)))):%@",pointAnnotation.title);
                if ([[tempmark objectForKey:@"markName"] isEqualToString:pointAnnotation.title]) {
                    self.poiclick = tempmark;
                    index = i;
                    if (temp == nil) {
                        temp = [[NSMutableDictionary alloc] init];
                    }
                    [temp setObject:[tempmark objectForKey:@"markResId"] forKey:@"GID"];
                    [temp setObject:[tempmark objectForKey:@"markResType"] forKey:@"resLogicName"];
                    
                    
                    if (tempmark[@"taskId"]) {
                        
                        [temp setValue:tempmark[@"taskId"] forKey:@"taskId"];
                    }else{
                        
                        [temp setValue:@"" forKey:@"taskId"];
                        
                    }
                    
                }
            }
//            [self showNameAndImage];
            
            [self jumpToMB];
            [_mapView deselectAnnotation:view.annotation animated:YES];
        }
    }
}
//根据overlay生成对应的View
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    
    if ([overlay isKindOfClass:[Yuan_PolyLine class]])
    {
        MAPolylineRenderer* polylineView = [[MAPolylineRenderer alloc] initWithOverlay:overlay];
        Yuan_PolyLine *tempP = (Yuan_PolyLine *)overlay;
        polylineView.lineWidth = 6.0;
        if (tempP.type == 1 || tempP.type == 3) {
            polylineView.lineDashType = kMALineDashTypeSquare;
            NSLog(@"删除/添加资源关联关系画线");
            polylineView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:1];
        }else if (tempP.type == 4){
            NSLog(@"关联关系");
            polylineView.strokeColor = [[UIColor grayColor] colorWithAlphaComponent:1];
        }else if (tempP.type == 5){
            NSLog(@"行政区域描边");
            polylineView.lineWidth = 4.0;
            polylineView.strokeColor = [[UIColor colorWithHexString:@"#e63f00"] colorWithAlphaComponent:1];
        }else{
            //中心发过来的各种资源信息
            if ([tempP.color containsString:@"#"]) {
                polylineView.strokeColor = [[UIColor colorWithHexString:tempP.color] colorWithAlphaComponent:1];
            }else{
                if ([tempP.color isEqualToString:@"red"]) {
                    polylineView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:1];
                }else if ([tempP.color isEqualToString:@"blue"]){
                    polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:1];
                }else if ([tempP.color isEqualToString:@"black"]){
                    polylineView.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:1];
                }else if ([tempP.color isEqualToString:@"green"]){
                    polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:1];
                }else if ([tempP.color isEqualToString:@"grey"]){
                    polylineView.strokeColor = [[UIColor grayColor] colorWithAlphaComponent:1];
                }else{
                    polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:1];
                }
            }
        }
        
        return polylineView;
    }
    return nil;
}
//行政区划查询回调
-(void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response{
    if (response == nil)
    {
        return;
    }
    
    //解析response获取行政区划，具体解析见 Demo
    for (AMapDistrict *dist in response.districts)
    {
        if (dist.polylines.count > 0)
        {
            MAMapRect bounds = MAMapRectZero;
            
            for (NSString *polylineStr in dist.polylines)
            {
                Yuan_PolyLine *polyline = [CommonUtility polylineForCoordinateString:polylineStr];
                polyline.type = 5;
                [_mapView addOverlay:polyline];
                
                bounds = MAMapRectUnion(bounds, polyline.boundingMapRect);
            }
            
            [_mapView setVisibleMapRect:bounds animated:YES];
        }
    }
}
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}
//核查根据返回数据修改显示
-(void)updateBackList:(NSDictionary<NSString *,NSString *> *)dict{
    
//    if (self.navigationController.viewControllers.count>0) {
//        if ([self.navigationController.viewControllers[self.navigationController.viewControllers.count-1] isKindOfClass:[TYKDeviceInfoMationViewController class]]) {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    }
    
    NSLog(@"修改返回的字典:%@",dict);
    if (self.poiclick != nil && dict !=nil && index!=-1) {
        NSMutableDictionary *bean = [[NSMutableDictionary alloc] initWithDictionary:self.poiclick];
        [bean setObject:[dict objectForKey:@"lon"] forKey:@"markSLon"];
        [bean setObject:[dict objectForKey:@"lat"] forKey:@"markSLat"];
        if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"well"]) {
            [bean setObject:[dict objectForKey:@"wellSubName"] forKey:@"markName"];
        }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"pole"]){
            [bean setObject:[dict objectForKey:@"poleSubName"] forKey:@"markName"];
        }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"OCC_Equt"]){
            [bean setObject:[dict objectForKey:@"occName"] forKey:@"markName"];
        }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"ODF_Equt"]){
            [bean setObject:[dict objectForKey:@"rackName"] forKey:@"markName"];
        }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"ODB_Equt"]){
            [bean setObject:[dict objectForKey:@"odbName"] forKey:@"markName"];
        }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"generator"]){
            [bean setObject:[dict objectForKey:@"generatorName"] forKey:@"markName"];
        }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"stationBase"]){
            [bean setObject:[dict objectForKey:@"stationName"] forKey:@"markName"];
        }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"ledUp"]){
            [bean setObject:[dict objectForKey:@"ledupName"] forKey:@"markName"];
        }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"markStone"]){
            [bean setObject:[dict objectForKey:@"markName"] forKey:@"markName"];
        }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"joint"]){
            [bean setObject:[dict objectForKey:@"jointName"] forKey:@"markName"];
        }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"supportingPoints"]){
            [bean setObject:[dict objectForKey:@"supportPSubName"] forKey:@"markName"];
        }else if ([[self.poiclick objectForKey:@"markResType"] isEqualToString:@"EquipmentPoint"]){
            [bean setObject:[dict objectForKey:@"EquipmentPointName"] forKey:@"markName"];
        }else{
            [bean setObject:[dict objectForKey:[NSString stringWithFormat:@"%@Name",[self.poiclick objectForKey:@"markResType"]]] forKey:@"markName"];
        }
        
        NSMutableArray *listd = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_d"]];
        //        [listd replaceObjectAtIndex:index withObject:bean];
        [listd removeObjectAtIndex:index];
        [listd addObject:bean];
        
        //变更筛选点显示列表
        for (int i = 0; i<shaixuanDArr.count; i++) {
            if ([shaixuanDArr[i][@"markResType"] isEqualToString:bean[@"markResType"]]&&
                [[NSString stringWithFormat:@"%@",shaixuanDArr[i][@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",bean[@"markResId"]]]) {
                //                [shaixuanDArr replaceObjectAtIndex:i withObject:bean];
                [shaixuanDArr removeObjectAtIndex:i];
                NSLog(@"走了修改了吗:%@",bean);
                break;
            }
        }
        [shaixuanDArr addObject:bean];
        
        [self.poiinfo removeObjectForKey:@"list_d"];
        [self.poiinfo setObject:listd forKey:@"list_d"];
        
        NSLog(@"%@",[self.poiinfo objectForKey:@"list_d"]);
        NSLog(@"修改后的筛选:%@",shaixuanDArr);
        
        //plusDataSourceMapData数据与实际数据动态更新
        
        
        for (NSDictionary *deleteFatherResDic in plusDataSourceMapData) {
            NSDictionary *key;
            for (NSDictionary *k in deleteFatherResDic) {
                key = k;
                break;
            }
            NSMutableArray *listd = [[NSMutableArray alloc] initWithArray:deleteFatherResDic[key][@"list_d"]];
            for (NSDictionary *dic in deleteFatherResDic[key][@"list_d"]) {
                if ([dic[@"markResType"] isEqualToString:self.poiclick[@"markResType"]]&&
                    [[NSString stringWithFormat:@"%@",dic[@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",self.poiclick[@"markResId"]]]) {
                    [listd removeObject:dic];
                    [listd addObject:bean];
                    NSLog(@"走了plusDataSourceMapData修改了吗:%@",listd);
                    break;
                }
                
            }
            deleteFatherResDic[key][@"list_d"] = listd;
        }
    }
}
-(void)newWellWithDict:(NSDictionary<NSString *,NSString *> *)dict{
    
    [self updateBackList:dict];
}
-(void)newPoleWithDict:(NSDictionary <NSString *,NSString *> *)dict{
    [self updateBackList:dict];
}
-(void)newDeciceWithDict:(NSDictionary<NSString *,NSString *> *)dict{
    [self updateBackList:dict];
}



-(void)deleteDeviceWithDict:(NSDictionary *)dict withViewControllerClass:(__unsafe_unretained Class)vcClass{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确定要删除该资源?"] preferredStyle:UIAlertControllerStyleAlert];
    
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


-(void)deleteDevice:(NSDictionary *)dict{
    
    NSMutableArray *listd = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_d"]];
    [self.poiinfo removeObjectForKey:@"list_d"];
    [self.poiinfo setObject:listd forKey:@"list_d"];
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
#endif
    
    // 删除事件
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", baseURL, @"rm!deleteCommonData.interface"];
    NSLog(@"%@",requestURL);
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setValue:_userModel.uid forKey:@"UID"];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [param setValue:str forKey:@"jsonRequest"];
    NSLog(@"param:%@",param);
    
    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        NSDictionary *dic = responseObject;
        if([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除成功" preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                if (self.poiclick!=nil&&[self.poiinfo objectForKey:@"list_d"]!=nil) {
                    
                    [[self.poiinfo objectForKey:@"list_d"] removeObjectAtIndex:index];
                    [self.nameArray removeObjectAtIndex:index];
                    
                    //变更筛选点显示列表
                    for (int i = 0; i<shaixuanDArr.count; i++) {
                        if ([shaixuanDArr[i][@"markResType"] isEqualToString:self.poiclick[@"markResType"]]&&
                            [[NSString stringWithFormat:@"%@",shaixuanDArr[i][@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",self.poiclick[@"markResId"]]]) {
                            [shaixuanDArr removeObjectAtIndex:i];
                            NSLog(@"走了删除了吗");
                            break;
                        }
                    }
                    
                    //plusDataSourceMapData数据与实际数据动态更新
                    
                    
                    for (NSDictionary *deleteFatherResDic in plusDataSourceMapData) {
                        NSDictionary *key;
                        for (NSDictionary *k in deleteFatherResDic) {
                            key = k;
                            break;
                        }
                        NSMutableArray *listd = [[NSMutableArray alloc] initWithArray:deleteFatherResDic[key][@"list_d"]];
                        for (NSDictionary *dic in deleteFatherResDic[key][@"list_d"]) {
                            if ([dic[@"markResType"] isEqualToString:self.poiclick[@"markResType"]]&&
                                [[NSString stringWithFormat:@"%@",dic[@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",self.poiclick[@"markResId"]]]) {
                                [listd removeObject:dic];
                                NSLog(@"走了plusDataSourceMapData删除了吗");
                                break;
                            }
                            
                        }
                        deleteFatherResDic[key][@"list_d"] = listd;
                    }
                }
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            [alert addAction:action];
            Present(self.navigationController, alert);
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
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            NSLog(@"添加");
            [guanlianBtn setTitle:@"确定" forState:UIControlStateNormal];
            isAddGuanlian = YES;
            break;
            
        case 1:
            NSLog(@"删除");
            [guanlianBtn setTitle:@"确定" forState:UIControlStateNormal];
            isDeleteGuanlan = YES;
            break;
            
        default:
            break;
    }
}

#pragma mark - dataSource&Delegate
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (tableView == self.shaiXuanListView) {
        
        if (self.shaiXuanDataSource.count > 0) {
            return @"关闭开关可以隐藏相应资源";
        }else{
            return @"";
        }
        
    }else{
        
        if (self.plusDataSource.count > 0) {
            return @"关闭开关可以隐藏相应资源\n向左滑动可以删除获取记录";
        }else{
            return @"";
        }
        
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.shaiXuanListView) {
        return self.shaiXuanDataSource.count;
    }else{
        return self.plusDataSource.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    YKLListViewCell * cell = nil;
    
    if (tableView == self.shaiXuanListView) {
        
        static NSString * kCellId = @"shaixuanCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
        
        if (cell == nil) {
            cell = [[YKLListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellId];
            
            // 设置cell的代理，在关闭/打开按钮点击时需要调用代理方法
            cell.delegate = self;
            
            
        }
        
        cell.textLabel.text = self.shaiXuanDataSource[indexPath.row];
        cell.indexPath = indexPath;
        cell.isPlus = NO;
        NSDictionary * dict = self.switcherDataSource[indexPath.row];
        
        BOOL isOn = [dict[[NSString stringWithFormat:@"%ld", (long)indexPath.row]] boolValue];
        
        [cell.switcher setOn:isOn animated:YES];
        
        
        
    }else{
        
        static NSString * kCellId = @"plusCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
        
        if (cell == nil) {
            cell = [[YKLListViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellId];
            
            // 设置cell的代理，在关闭/打开按钮点击时需要调用代理方法
            cell.delegate = self;
        }
        
        cell.textLabel.text = self.plusDataSource[indexPath.row];
        
        UIImage * image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@.png",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"ResourceMainData", self.imageNames[indexPath.row]]];
        
        
        if (image == nil) {
            image = [UIImage Inc_imageNamed:@"icon"];
        }
        
//        NSString * sourceName = [[IWPPropertiesReader propertiesReaderWithFileName:self.imageNames[indexPath.row] withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] mainModel].name;
        
        NSString * sourceName = @"";
        
        cell.detailTextLabel.text = sourceName;
        cell.imageView.image = image;
        cell.indexPath = indexPath;
        cell.isPlus = YES;
        
        
        //        cell.imageView.image = [UIImage Inc_imageNamed:@"icon"];
        if (self.plusSwitcherDataSource.count > 0) {
            BOOL isOn = [self.plusSwitcherDataSource[indexPath.row] boolValue];
            [cell.switcher setOn:isOn animated:YES];
        }
        
    }
    
    
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 编辑事件
    if (tableView.isEditing) {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return tableView == self.plusListView;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray * dataSource = [self.plusDataSource mutableCopy];
        
        [dataSource removeObjectAtIndex:indexPath.row];
        
        self.plusDataSource = dataSource;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        NSLog(@"删除了");
        NSLog(@"要删除的资源:%@",plusDataSourceMapData[indexPath.row]);
        NSDictionary *deleteFatherResDic = plusDataSourceMapData[indexPath.row];
        
        //删除点
        NSMutableArray *listd = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_d"]];
        NSDictionary *key;
        for (NSDictionary *k in deleteFatherResDic) {
            key = k;
            break;
        }
        for (NSDictionary *dic in deleteFatherResDic[key][@"list_d"]) {
            [listd removeObject:dic];
            [shaixuanDArr removeObject:dic];
        }
        [self.poiinfo removeObjectForKey:@"list_d"];
        [self.poiinfo setObject:listd forKey:@"list_d"];
        
        //删除线
        NSMutableArray *listx = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_x"]];
        for (NSDictionary *dic in deleteFatherResDic[key][@"list_x"]) {
            [listx removeObject:dic];
            [shaixuanXArr removeObject:dic];
        }
        [self.poiinfo removeObjectForKey:@"list_x"];
        [self.poiinfo setObject:listx forKey:@"list_x"];
        
        
        [self markShow];
        
        
        
        [plusDataSourceMapData removeObjectAtIndex:indexPath.row];
        
        NSMutableArray * imageNames = [NSMutableArray arrayWithArray:self.imageNames];
        [imageNames removeObjectAtIndex:indexPath.row];
        self.imageNames = imageNames;
    }
    
}

-(void)editButtonHandler:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    // 进入/\
    / 退出编辑模式
    self.plusListView.editing = sender.selected;
    
}

-(void)didSwitchSwitcher:(BOOL)isOn indexPath:(NSIndexPath *)indexPath isPlus:(BOOL)isPlus{
    
    
    if (isPlus == NO) {
        // 筛选
        
        // 点击开关的方法
        NSMutableArray *listd = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_d"]];
        NSMutableArray *listx = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_x"]];
        
        // 更新switcherDataSource
        
        NSMutableArray * dataSource = [NSMutableArray arrayWithArray:self.switcherDataSource];
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:dataSource[indexPath.row]];
        
        [dict setObject:[NSNumber numberWithBool:isOn] forKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
        
        
        [dataSource replaceObjectAtIndex:indexPath.row withObject:dict];
        
        self.switcherDataSource = dataSource;
        
        // 数据源更新结束
        
        switch (indexPath.row) {
            case 0:
                //管道段
                for (int i = 0; i<listx.count; i++) {
                    if ([listx[i][@"markResType"] isEqualToString:@"pipeSegment"]) {
                        if (isOn) {
                            if (![shaixuanXArr containsObject:listx[i]]) {
                                [shaixuanXArr addObject:listx[i]];
                            }
                        }else{
                            [shaixuanXArr removeObject:listx[i]];
                        }
                    }
                }
                break;
            case 1:
                //井
                for (int i = 0; i<listd.count; i++) {
                    if ([listd[i][@"markResType"] isEqualToString:@"well"]) {
                        if (isOn) {
                            if (![shaixuanDArr containsObject:listd[i]]) {
                                [shaixuanDArr addObject:listd[i]];
                            }
                        }else{
                            [shaixuanDArr removeObject:listd[i]];
                        }
                    }
                }
                
                break;
            case 2:
                //杆路段
                for (int i = 0; i<listx.count; i++) {
                    if ([listx[i][@"markResType"] isEqualToString:@"poleLineSegment"]) {
                        if (isOn) {
                            if (![shaixuanXArr containsObject:listx[i]]) {
                                [shaixuanXArr addObject:listx[i]];
                            }
                        }else{
                            [shaixuanXArr removeObject:listx[i]];
                        }
                    }
                }
                break;
            case 3:
                //杆
                for (int i = 0; i<listd.count; i++) {
                    if ([listd[i][@"markResType"] isEqualToString:@"pole"]) {
                        if (isOn) {
                            if (![shaixuanDArr containsObject:listd[i]]) {
                                [shaixuanDArr addObject:listd[i]];
                            }
                        }else{
                            [shaixuanDArr removeObject:listd[i]];
                        }
                    }
                }
                break;
            case 4:
                //标石段
                for (int i = 0; i<listx.count; i++) {
                    if ([listx[i][@"markResType"] isEqualToString:@"markStoneSegment"]) {
                        if (isOn) {
                            if (![shaixuanXArr containsObject:listx[i]]) {
                                [shaixuanXArr addObject:listx[i]];
                            }
                        }else{
                            [shaixuanXArr removeObject:listx[i]];
                        }
                    }
                }
                
                break;
            case 5:
                //标石
                for (int i = 0; i<listd.count; i++) {
                    if ([listd[i][@"markResType"] isEqualToString:@"markStone"]) {
                        if (isOn) {
                            if (![shaixuanDArr containsObject:listd[i]]) {
                                [shaixuanDArr addObject:listd[i]];
                            }
                        }else{
                            [shaixuanDArr removeObject:listd[i]];
                        }
                    }
                }
                break;
            case 6:
                //ODF
                
                for (int i = 0; i<listd.count; i++) {
                    if ([listd[i][@"markResType"] isEqualToString:@"ODF_Equt"]) {
                        if (isOn) {
                            if (![shaixuanDArr containsObject:listd[i]]) {
                                [shaixuanDArr addObject:listd[i]];
                            }
                        }else{
                            [shaixuanDArr removeObject:listd[i]];
                        }
                    }
                }
                break;
            case 7:
                //OCC
                for (int i = 0; i<listd.count; i++) {
                    if ([listd[i][@"markResType"] isEqualToString:@"OCC_Equt"]) {
                        if (isOn) {
                            if (![shaixuanDArr containsObject:listd[i]]) {
                                [shaixuanDArr addObject:listd[i]];
                            }
                        }else{
                            [shaixuanDArr removeObject:listd[i]];
                        }
                    }
                }
                break;
            case 8:
                //局站
                for (int i = 0; i<listd.count; i++) {
                    if ([listd[i][@"markResType"] isEqualToString:@"stationBase"]) {
                        if (isOn) {
                            if (![shaixuanDArr containsObject:listd[i]]) {
                                [shaixuanDArr addObject:listd[i]];
                            }
                        }else{
                            [shaixuanDArr removeObject:listd[i]];
                        }
                    }
                }
                break;
            case 9:
                //机房
                for (int i = 0; i<listd.count; i++) {
                    if ([listd[i][@"markResType"] isEqualToString:@"generator"]) {
                        if (isOn) {
                            if (![shaixuanDArr containsObject:listd[i]]) {
                                [shaixuanDArr addObject:listd[i]];
                            }
                        }else{
                            [shaixuanDArr removeObject:listd[i]];
                        }
                    }
                }
                break;
            case 10:
                //引上点
                for (int i = 0; i<listd.count; i++) {
                    if ([listd[i][@"markResType"] isEqualToString:@"ledUp"]) {
                        if (isOn) {
                            if (![shaixuanDArr containsObject:listd[i]]) {
                                [shaixuanDArr addObject:listd[i]];
                            }
                        }else{
                            [shaixuanDArr removeObject:listd[i]];
                        }
                    }
                }
                break;
            case 11:
                //ODB
                for (int i = 0; i<listd.count; i++) {
                    if ([listd[i][@"markResType"] isEqualToString:@"ODB_Equt"]) {
                        if (isOn) {
                            if (![shaixuanDArr containsObject:listd[i]]) {
                                [shaixuanDArr addObject:listd[i]];
                            }
                        }else{
                            [shaixuanDArr removeObject:listd[i]];
                        }
                    }
                }
                break;
            case 12:
                //撑点
                for (int i = 0; i<listd.count; i++) {
                    if ([listd[i][@"markResType"] isEqualToString:@"supportingPoints"]) {
                        if (isOn) {
                            if (![shaixuanDArr containsObject:listd[i]]) {
                                [shaixuanDArr addObject:listd[i]];
                            }
                        }else{
                            [shaixuanDArr removeObject:listd[i]];
                        }
                    }
                }
                break;
            case 13:
                //光缆接头
                for (int i = 0; i<listd.count; i++) {
                    if ([listd[i][@"markResType"] isEqualToString:@"joint"]) {
                        if (isOn) {
                            if (![shaixuanDArr containsObject:listd[i]]) {
                                [shaixuanDArr addObject:listd[i]];
                            }
                        }else{
                            [shaixuanDArr removeObject:listd[i]];
                        }
                    }
                }
                break;
            case 14:
                //管孔
                for (int i = 0; i<listx.count; i++) {
                    if ([listx[i][@"markResType"] isEqualToString:@"tube"]) {
                        if (isOn) {
                            if (![shaixuanXArr containsObject:listx[i]]) {
                                [shaixuanXArr addObject:listx[i]];
                            }
                        }else{
                            [shaixuanXArr removeObject:listx[i]];
                        }
                    }
                }
                break;
            case 15:
                //放置点
                for (int i = 0; i<listd.count; i++) {
                    if ([listd[i][@"markResType"] isEqualToString:@"EquipmentPoint"]) {
                        if (isOn) {
                            if (![shaixuanDArr containsObject:listd[i]]) {
                                [shaixuanDArr addObject:listd[i]];
                            }
                        }else{
                            [shaixuanDArr removeObject:listd[i]];
                        }
                    }
                }
                break;
            default:
                break;
        }
        
        [self showShaixuanMarkResult];
        
    }else{
        // +
        
        NSMutableArray * arr = [NSMutableArray arrayWithArray:self.plusSwitcherDataSource];
        
        [arr replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:isOn]];
        
        self.plusSwitcherDataSource = arr;
        
        
        if (isOn) {
            // 打开，selected
            NSLog(@"选中");
            NSLog(@"要显示的资源:%@",plusDataSourceMapData[indexPath.row]);
            NSDictionary *deleteFatherResDic = plusDataSourceMapData[indexPath.row];
            
            //显示点
            NSDictionary *key;
            for (NSDictionary *k in deleteFatherResDic) {
                key = k;
                break;
            }
            for (NSDictionary *dic in deleteFatherResDic[key][@"list_d"]) {
                if (![shaixuanDArr containsObject:dic]) {
                    [shaixuanDArr addObject:dic];
                }
            }
            NSLog(@"shaixuanDArr：%@",shaixuanDArr);
            //显示线
            for (NSDictionary *dic in deleteFatherResDic[key][@"list_x"]) {
                if (![shaixuanXArr containsObject:dic]) {
                    [shaixuanXArr addObject:dic];
                }
            }
            NSLog(@"shaixuanXArr：%@",shaixuanXArr);
            
            [self showShaixuanMarkResult];
            
        }else{
            // 关闭，deSelected
            NSLog(@"取消选中");
            NSLog(@"要隐藏的资源:%@",plusDataSourceMapData[indexPath.row]);
            NSDictionary *deleteFatherResDic = plusDataSourceMapData[indexPath.row];
            
            //隐藏点
            NSDictionary *key;
            for (NSDictionary *k in deleteFatherResDic) {
                key = k;
                break;
            }
            for (NSDictionary *dic in deleteFatherResDic[key][@"list_d"]) {
                [shaixuanDArr removeObject:dic];
            }
            NSLog(@"shaixuanDArr：%@",shaixuanDArr);
            //隐藏线
            for (NSDictionary *dic in deleteFatherResDic[key][@"list_x"]) {
                [shaixuanXArr removeObject:dic];
            }
            NSLog(@"shaixuanXArr：%@",shaixuanXArr);
            
            [self showShaixuanMarkResult];
        }
        
    }
    
    
    
    
    
}
//显示筛选结果
-(void)showShaixuanMarkResult{
    NSLog(@"筛选结果");
    //点资源
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (MAAnnotationView *view in _mapView.annotations) {
        if (![view isKindOfClass:[MAUserLocation class]]) {
            [arr addObject:view];
        }
    }
    NSArray *array = [NSArray arrayWithArray:arr];
    [_mapView removeAnnotations:array];
    
    //显示点
    if (shaixuanDArr !=nil) {
        self.nameArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<[shaixuanDArr count]; i++) {
            NSDictionary *tempmark = shaixuanDArr[i];
            annotationIndex = i;
            Yuan_PointAnnotation *pointAnnotation = [[Yuan_PointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            
            coor.latitude = [[tempmark objectForKey:@"markSLat"] doubleValue];
            coor.longitude = [[tempmark objectForKey:@"markSLon"] doubleValue];
            if ((tempmark!=nil) && ([tempmark objectForKey:@"markResType"]!=nil)) {
                if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"well"]) {
                    pointAnnotation.tag = 10000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"pole"]){
                    pointAnnotation.tag = 20000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"OCC_Equt"]){
                    pointAnnotation.tag = 30000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"stationBase"]){
                    pointAnnotation.tag = 40000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"ledUp"]){
                    pointAnnotation.tag = 50000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"markStone"]){
                    pointAnnotation.tag = 60000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"ODF_Equt"]){
                    pointAnnotation.tag = 70000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"generator"]){
                    pointAnnotation.tag = 80000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"ODB_Equt"]){
                    pointAnnotation.tag = 90000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"joint"]){
                    pointAnnotation.tag = 100000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"supportingPoints"]){
                    pointAnnotation.tag = 110000+i;
                }else if ([[tempmark objectForKey:@"markResType"] isEqualToString:@"EquipmentPoint"]){
                    pointAnnotation.tag = 120000+i;
                }else{
                    pointAnnotation.tag = 130000+i;
                }
            }
            
            
            pointAnnotation.coordinate = coor;
            [self.nameArray addObject:[tempmark objectForKey:@"markName"]];
            pointAnnotation.title = [tempmark objectForKey:@"markName"];
            
            [_mapView addAnnotation:pointAnnotation];
            
        }
    }
    //线资源
    /* NSMutableArray **/arr = [[NSMutableArray alloc] init];
    for (MAAnnotationView *view in _mapView.overlays) {
        if ([view isKindOfClass:[Yuan_PolyLine class]]) {
            [arr addObject:view];
        }
    }
    /*NSArray **/array = [NSArray arrayWithArray:arr];
    [_mapView removeOverlays:array];
    
    
    if (shaixuanXArr !=nil) {
        for (int i = 0; i<[shaixuanXArr count]; i++) {
            NSDictionary *tempmark = shaixuanXArr[i];
            NSMutableDictionary *p1 = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *p2 = [[NSMutableDictionary alloc] init];
            NSMutableArray *points = [[NSMutableArray alloc] init];
            [p1 setObject:[tempmark objectForKey:@"markSLat"] forKey:@"lat"];
            [p1 setObject:[tempmark objectForKey:@"markSLon"] forKey:@"lon"];
            [points addObject:p1];
            [p2 setObject:[tempmark objectForKey:@"markELat"] forKey:@"lat"];
            [p2 setObject:[tempmark objectForKey:@"markELon"] forKey:@"lon"];
            [points addObject:p2];
            
            if (p1!=nil && p2!=nil && [[p1 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p1 objectForKey:@"lon"] doubleValue]&& [[p2 objectForKey:@"lat"] doubleValue]!=0.000000 && [[p2 objectForKey:@"lon"] doubleValue]) {
                CLLocationCoordinate2D coors[2] = {0};
                coors[0].latitude = [[p1 objectForKey:@"lat"] doubleValue];
                coors[0].longitude = [[p1 objectForKey:@"lon"] doubleValue];
                coors[1].latitude = [[p2 objectForKey:@"lat"] doubleValue];
                coors[1].longitude = [[p2 objectForKey:@"lon"] doubleValue];
                
                
                NSLog(@"coors:%f,%f,%f,%f",coors[0].latitude,coors[0].longitude,coors[1].latitude,coors[1].longitude);
                Yuan_PolyLine *polyline = [Yuan_PolyLine polylineWithCoordinates:coors count:2];
                polyline.color = tempmark[@"color"];
                if ([tempmark[@"markResType"] isEqualToString:@"resRelation"]) {
                    polyline.type = 4;
                }
                
                if (_isGualan && [tempmark[@"markResType"] isEqualToAnyString:@"pipeSegment", @"pole", @"markStone", @"ledUp", @"supportingPoints", nil]) {
                    
                   CLLocationCoordinate2D coordinate = [self centerCoordinateForStart:coors[0] end:coors[1]];
                    
                    Yuan_PointAnnotation * anno = [[Yuan_PointAnnotation alloc] init];
                    anno.coordinate = coordinate;
                    anno.isSegCenter = true;
                    anno.segMark = tempmark;
                    [_mapView addAnnotation:anno];
                    
                    
                }
                
                
                [_mapView addOverlay:polyline];
            }
        }
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.plusListView hideListViewNOAnimation:NO];
    [self.shaiXuanListView hideListViewNOAnimation:NO];
    UIView *fullView = [self.view viewWithTag:5500000];
        [fullView removeFromSuperview];
}

- (void)piliangguanlian:(UIButton *)sender{
    
    if (!_isGualan) {
        if (sender.selected) {
            // 保存
            sender.selected = false;
            _isGuanlian = false;
            
            [self removeTempLines];
            
            [self showShaixuanMarkResult];
            
            
            [self saveGuanlianCompleted:^(NSArray *arr) {
                
                if (arr) {
                    
                    
                    arr = [self.guanlianList copy];
                    
                    [self.guanlianList removeAllObjects];
                                        
                    /*
                     
                     GID = 023007030000000022563211;
                      lat = "41.8150978628";
                      lon = "123.4338963032";
                      name = "\U6c88\U6cb3\U533a\U65b0\U5317\U7ad9\U8857\U9053\U5317\U7ad9\U8def61\U53f7\U8d22\U5bcc\U4e2d\U5fc3GJ1213";
                      type = "OCC_Equt";
                     
                     */
                    
                    // MARK: 袁全 修改 批量关联
                    CLLocationCoordinate2D commonPolylineCoords[arr.count];
                    
                    
                    NSDictionary * dict;
                    
                    for (int i = 0  ; i < arr.count ; i++) {
                        
                        dict = arr[i];
                        
                        double lat = [dict[@"lat"] doubleValue];
                        double lon = [dict[@"lon"] doubleValue];
                        
                        commonPolylineCoords[i].latitude = lat;
                        commonPolylineCoords[i].longitude = lon;
                    }
                
                    Yuan_PolyLine *commonPolyline = [Yuan_PolyLine polylineWithCoordinates:commonPolylineCoords count:arr.count];
                    
                    commonPolyline.color = @"redColor";
                    
                    [_mapView addOverlay: commonPolyline];
                    
                    
                  /*
                    
                    for (NSDictionary * mark in arr) {
                        
                        
                        NSString * startCoorStr = [NSString stringWithFormat:@"{%@,%@}", mark[@"markSLat"], mark[@"markSLon"]];
                        
                        
                        NSString * endCoorStr = [NSString stringWithFormat:@"{%@,%@}", mark[@"markELat"], mark[@"markELon"]];
                        
                        CLLocationCoordinate2D coors[2] = {CoordinateFromNSString(startCoorStr), CoordinateFromNSString(endCoorStr)};
                        
                        
                        Yuan_PolyLine *polyline = [Yuan_PolyLine polylineWithCoordinates:coors count:2];
                        polyline.color = mark[@"color"];
                        if ([mark[@"markResType"] isEqualToString:@"resRelation"]) {
                            polyline.type = 4;
                        }
                        [_mapView addOverlay:polyline];
                    }
                    
                    
                }
                
                
                 Yuan_PolyLine *polyline = [Yuan_PolyLine polylineWithCoordinates:coors count:2];
                 polyline.color = tempmark[@"color"];
                 if ([tempmark[@"markResType"] isEqualToString:@"resRelation"]) {
                 polyline.type = 4;
                 }
                 [_mapView addOverlay:polyline];
                 
                 */
                    
                }
            }];
            
        }else{
            // 进入关联模式
            sender.selected = true;
            _isGuanlian = true;
        }
        
        
    }else{
        
        
        [YuanHUD HUDFullText:@"请先退出批量挂缆模式"];
    }
}


- (void)pilianggualan:(UIButton *)sender{
    
    if (!_isGuanlian) {
        if (sender.selected) {
            // 保存
            
            [self saveGualan];
            
            
        }else{
            // 进入挂缆模式
            
            _isGualan = true;
            
            [self stationSelect:@"cable"];
            
            
            sender.selected = true;
            [self showShaixuanMarkResult];
            
        }
        
        
    }else{
        
        
        [YuanHUD HUDFullText:@"请先退出批量关联模式"];
    }
}


- (void)addThisDevice:(NSDictionary *)dict{
    
    if (_isGuanlian) {

        [self.guanlianList addObject:dict];
        
        [self reloadLines];
        
    }else{
        [self.gualanList addObject:dict];
    }
    
}

- (NSDictionary *)buildGuanLianDictWithStart:(NSDictionary *)start end:(NSDictionary *)end{


    NSMutableDictionary * dict = [NSMutableDictionary dictionary];

    [dict setValue:@"pipeSegment" forKey:@"resLogicName"];

    [dict setValue:start[@"type"] forKey:@"startType"];
    [dict setValue:start[@"GID"] forKey:@"startGid"];
    [dict setValue:start[@"name"] forKey:@"startName"];


    [dict setValue:end[@"type"] forKey:@"endType"];
    [dict setValue:end[@"GID"] forKey:@"endGid"];
    [dict setValue:end[@"name"] forKey:@"endName"];



    return dict;

}


- (void)addLineWithStart:(CLLocationCoordinate2D)start end:(CLLocationCoordinate2D)end{
    
    CLLocationCoordinate2D coordinates[2] = {start, end};
    
    Yuan_PolyLine *polyline = [Yuan_PolyLine polylineWithCoordinates:coordinates count:2];
    polyline.type = 1;//虚线
    polyline.isGuanLianLine = true;
    [_mapView addOverlay:polyline];
    
    
    
}
- (void)removeTempLines{
    for (id lineTemp in _mapView.overlays) {
        
        if ([lineTemp isKindOfClass:[Yuan_PolyLine class]]) {
            Yuan_PolyLine * line = lineTemp;
            
            if (line.isGuanLianLine) {
                [_mapView removeOverlay:line];
            }
            
        }
        
    }
}
- (void)reloadLines{
    
    [self removeTempLines];
    
    
    if(self.guanlianList.count > 1){
        for(int i = 0; i < self.guanlianList.count; i++)
        {
            if(i < self.guanlianList.count -1){
                
                //画线
                
                NSDictionary * qspole = self.guanlianList[i];
                NSDictionary * zzpole = self.guanlianList[i + 1];
                
                NSString * qsstr = [NSString stringWithFormat:@"{%@,%@}", qspole[@"lat"], qspole[@"lon"]];
                NSString * zzstr = [NSString stringWithFormat:@"{%@,%@}", zzpole[@"lat"], zzpole[@"lon"]];
                CLLocationCoordinate2D p1 = CoordinateFromNSString(qsstr);
                CLLocationCoordinate2D p2 = CoordinateFromNSString(zzstr);
                
                [self addLineWithStart:p1 end:p2];
            }
        }
    }
        
}

- (void)saveGuanlianCompleted:(void(^)(NSArray * arr))completed{
    if (self.guanlianList.count > 1) {
        
        NSMutableArray * param = [NSMutableArray array];
        
        for(int i = 0; i < self.guanlianList.count; i++)
        {
            if(i < self.guanlianList.count -1){
                
                NSDictionary * start = self.guanlianList[i];
                NSDictionary * end = self.guanlianList[i + 1];
              
                NSDictionary * dic = [self buildGuanLianDictWithStart:start end:end];
                [param addObject:dic];
              
            }
        }
        
        
        MBProgressHUD * alert = [MBProgressHUD showHUDAddedTo:self.view animated:true];
        alert.label.text = @"正在保存，请稍候……";
        
        [Http.shareInstance POST:[NSString stringWithFormat:@"http://%@/rm!insertSeg.interface",Http.zbl_BaseUrl]
                      parameters:@{kUID:_userModel.uid, kJsonRequest:[param json]} success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
            
            [alert hideAnimated:true];
            if ([responseObject[kResult] integerValue] == 0) {
                NSDictionary * mark = [responseObject[kInfo] object];
                
                if (mark[@"error"] == nil) {
                    
                    NSArray * arr = mark[@"list_x"];
                    [YuanHUD HUDFullText:@"关联成功"];
                    completed(arr);
                    
                }else{
                    [YuanHUD HUDFullText:@"JSON数据解析错误"];
                    
                    completed(nil);
                }
                
            }else{
                
                NSString * content = [NSString stringWithFormat:@"%@", responseObject[kInfo]];
                
                
                [YuanHUD HUDFullText:content];
                completed(nil);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
            
            [YuanHUD HUDFullText:error.localizedDescription];
            
            completed(nil);
            
        }];
        
    }else{
        
        [YuanHUD HUDFullText:@"请至少选择两个资源进行该操作"];
    }
    
    
}

- (CLLocationCoordinate2D)centerCoordinateForStart:(CLLocationCoordinate2D)start end:(CLLocationCoordinate2D)end{
    
    double lat1 = start.latitude;
    double lon1 = start.longitude;
    
    double lat2 = end.latitude;
    double lon2 = end.longitude;
    
    double lat = 0.0;
    double lon = 0.0;
    if (lat2 > lat1) {
        double temp = lat2 - lat1;
        lat = lat1 + temp / 2;
    } else {
        double temp = lat1 - lat2;
        lat = lat2 + temp / 2;
    }
    
    if (lon2 > lon1) {
        double temp = lon2 - lon1;
        lon = lon1 + temp / 2;
    } else {
        double temp = lon1 - lon2;
        lon = lon2 + temp / 2;
    }
//    LatLng p3 = new LatLng(lat, lon);
    
    CLLocationCoordinate2D p3 = CLLocationCoordinate2DMake(lat, lon);
    
    return p3;
    
}

- (NSArray *)buildGualanParam{
    
    NSString * gids = @"";
    NSString * names = @"";
    NSString * types = @"";
    
    for (NSDictionary * dict in self.gualanList) {
        
        gids = [gids stringByAppendingString:[NSString stringWithFormat:@"%@,", dict[@"GID"]]];
        names = [names stringByAppendingString:[NSString stringWithFormat:@"%@,", dict[@"name"]]];
        types = [types stringByAppendingString:[NSString stringWithFormat:@"%@,", dict[@"type"]]];
        
    }
    
    gids = [gids substringToIndex:gids.length - 1];
    names = [names substringToIndex:names.length - 1];
    types = [types substringToIndex:types.length - 1];
    
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setValue:gids forKey:@"resGid"];
    [dict setValue:names forKey:@"resName"];
    [dict setValue:types forKey:@"resType"];
    
    [dict setValue:self.cableInfo[@"GID"] forKey:@"cableGid"];
    [dict setValue:self.cableInfo[@"cableName"] forKey:@"cableName"];
    
    [dict setValue:@"cableRouteSubmit" forKey:@"resLogicName"];
    
    return @[dict];
    
    
}

- (void)saveGualan{
    
    
    
    if (self.gualanList.count > 0) {
        
        
        for (id tempAnno in _mapView.annotations) {
            
            if ([tempAnno isKindOfClass:[Yuan_PointAnnotation class]]) {
                
                Yuan_PointAnnotation * anno = tempAnno;
                
                if (anno.isSegCenter) {
                    [_mapView removeAnnotation:anno];
                }
                
            }
            
        }
        
        NSArray * param = [self buildGualanParam];
        
        NSLog(@"%@", [param json]);
        
        MBProgressHUD * alert = [MBProgressHUD showHUDAddedTo:self.view animated:true];
        alert.label.text = @"正在保存，请稍候……";
        
        [Http.shareInstance POST:[NSString stringWithFormat:@"http://%@/rm!insertOptoccupy.interface",Http.zbl_BaseUrl] parameters:@{kUID:_userModel.uid, kJsonRequest:[param json]}
                         success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
            
            [alert hideAnimated:true];
            if ([responseObject[kResult] integerValue] == 0) {
                
                _isGualan = false;
                
                [self.gualanList removeAllObjects];
                self.cableInfo = nil;
                self.gualanBtn.selected = false;
                self.cableNameLabel.hidden = true;
                
                
                [YuanHUD HUDFullText:@"保存成功"];
            }else{
                
                NSString * content = [NSString stringWithFormat:@"%@", responseObject[kInfo]];
                
                
                [YuanHUD HUDFullText:content];
                
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
            
            
            [YuanHUD HUDFullText:error.localizedDescription];
            
        }];
        
        
        
    }else{
        [self.gualanList removeAllObjects];
        self.cableInfo = nil;
        self.gualanBtn.selected = false;
        self.cableNameLabel.hidden = true;
    }
    
}
-(IBAction)getRes:(id)sender{
    
    IWPGISSiftViewController * sift = IWPGISSiftViewController.new;
    sift.isUnionLibrary = true;
    WEAK_SELF;
    sift.selectedNew = ^(NSString *types, CLLocationCoordinate2D coordinate) {

        wself.poiinfo = nil;//!< 2018年11月17日 获取前清空

        if (coordinate.latitude != 0 && coordinate.longitude !=0) {

            wself.selectedCoordinate = coordinate;
        }else {
            wself.selectedCoordinate = CLLocationCoordinate2DMake(lat, lon);
        }

        [wself getResDataWithType:types typeName:nil showdingName:@"选择的" selectedRes:nil];

    };

    if (isLocationSelf) {
        //手动定位下
        sift.coordinate =  _mapView.centerCoordinate;
        lonStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
        latStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
    }else{

        sift.coordinate = CLLocationCoordinate2DMake(lat, lon);

        lonStr = [NSString stringWithFormat:@"%f",lon];
        latStr = [NSString stringWithFormat:@"%f",lat];
    }


    sift.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:sift animated:true completion:nil];
}
-(void)getResDataWithType:(NSString *)type typeName:(NSString *)resId showdingName:(NSString *)typeChineseName selectedRes:(NSDictionary *)selectRes{
    //弹出进度框
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    //如果设置此属性则当前的view置于后台
    
    //设置对话框文字
    HUD.label.text = [NSString stringWithFormat:@"正在获取%@资源信息......",typeChineseName];
    //显示对话框
    [HUD showAnimated:YES];
    //调用查询接口
    NSMutableDictionary *param = nil;
    if (resId) {
        param = [@{@"UID":_userModel.uid, @"markRequest.markResType":type, @"markRequest.markContent":resId } mutableCopy];
    }else{
        
        //MARK: yuan -- 当手动定位和自动定位时 , 修改他的经纬度.
        
        NSString * tempLat;
        NSString * tempLon;
        if (self.selectedCoordinate.latitude != 0 && self
            .selectedCoordinate.longitude != 0) {
            
            if (isLocationSelf) {
                    //手动定位下
                    lonStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.longitude];
                    latStr = [NSString stringWithFormat:@"%f",_mapView.centerCoordinate.latitude];
                NSLog(@"手动定位");
                }else{
                    lonStr = [NSString stringWithFormat:@"%f",lon];
                    latStr = [NSString stringWithFormat:@"%f",lat];
                    NSLog(@"自动定位");
                }
                
                tempLat = latStr;
                tempLon = lonStr;
                
            
//            tempLat = [NSString stringWithFormat:@"%.6f", self.selectedCoordinate.latitude];
//            tempLon = [NSString stringWithFormat:@"%.6f", self.selectedCoordinate.longitude];
        }
        param = NSMutableDictionary.dictionary;
        
        param[kUID] = _userModel.uid;
        
        param[@"markRequest.lat"] =  tempLat;
        param[@"markRequest.lon"] =  tempLon;
#if DEBUG
        param[@"markRequest.radius"] = @"300";
#else
        param[@"markRequest.radius"] = @"500";
#endif
        if ([type isEqualToString:@"NONE"] == false){
            param[@"markRequest.markResType"] = type;
        }
        
        
//        param = @{@"UID":_userModel.uid, @"markGrid.markResType":type, @"markGrid.markSLat":tempLat, @"markGrid.markSLon":tempLon};
    }
    // 41.814156  123.432525
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
#endif
    NSLog(@"%@", param.json);
    NSLog(@"%@", [NSString stringWithFormat:@"%@GIS!showMarks.interface?markRequest.markResType=%@&markRequest.markContent=%@",baseURL,type,resId]);

    NSString * URL = nil;
    if (resId) {
        URL = [NSString stringWithFormat:@"%@GIS!showMarks.interface",baseURL];
    }else{
        URL = [NSString stringWithFormat:@"%@rm!getAroundMarks.interface", baseURL];
    }
    
//    URL = [URL stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
    // {"UID":"B5FEC58EC58673542C88B9EF4826FF85","markRequest.radius":"300","markRequest.lat":"41.814203","markRequest.lon":"123.432626"}
    [Http.shareInstance POST:URL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        NSDictionary *dic = responseObject;
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:tempData options:kNilOptions error:nil];
            
            NSLog(@"%@", tempDic[@"pservs"]);
            // self.businessVC.businessList = tempDic[@"pservs"];
            
            if (self.poiinfo == nil) {
                self.poiinfo = [[NSMutableDictionary alloc] initWithDictionary:tempDic];
                shaixuanDArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_d"]];
                [self initOverlay];
            }else{
                NSMutableArray *listd = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_d"]];
                NSArray *tempListD = (NSArray *)[tempDic objectForKey:@"list_d"];
                //进行资源累加操作
                if (tempListD != nil &&tempListD.count>0) {
                    for (int i = 0; i<tempListD.count; i++) {
                        BOOL isHave = NO;
                        for (int j = 0; j<listd.count; j++) {
                            if ([tempListD[i][@"markResType"] isEqualToString:listd[j][@"markResType"]]&&
                                [[NSString stringWithFormat:@"%@",tempListD[i][@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",listd[j][@"markResId"]]]) {
                                isHave = YES;
                                break;
                            }
                        }
                        if (!isHave) {
                            NSLog(@"add~~~~~~~~~");
                            [listd addObject:tempListD[i]];
                        }
                    }
                }
                
                [self.poiinfo removeObjectForKey:@"list_d"];
                [self.poiinfo setObject:listd forKey:@"list_d"];
                shaixuanDArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_d"]];
                
                
                
                NSMutableArray *listx = [[NSMutableArray alloc] initWithArray:(NSArray *)[self.poiinfo objectForKey:@"list_x"]];
                NSArray *tempListX = (NSArray *)[tempDic objectForKey:@"list_x"];
                //进行资源累加操作
                if (tempListX != nil &&tempListX.count>0) {
                    for (int i = 0; i<tempListX.count; i++) {
                        if ([tempListX[i][@"markResType"] isEqualToString:@"resRelation"]) {
                            NSLog(@"addx~~~~~~~~~res");
                            [listx addObject:tempListX[i]];
                        }else{
                            BOOL isHave = NO;
                            for (int j = 0; j<listx.count; j++) {
                                if ([tempListX[i][@"markResType"] isEqualToString:listx[j][@"markResType"]]&&
                                    [[NSString stringWithFormat:@"%@",tempListX[i][@"markResId"]] isEqualToString:[NSString stringWithFormat:@"%@",listx[j][@"markResId"]]]) {
                                    NSLog(@"isHaveX");
                                    isHave = YES;
                                    break;
                                }
                            }
                            if (!isHave) {
                                NSLog(@"addx~~~~~~~~~");
                                [listx addObject:tempListX[i]];
                            }
                        }
                    }
                }
                [self.poiinfo removeObjectForKey:@"list_x"];
                [self.poiinfo setObject:listx forKey:@"list_x"];
                
            }

            if (self.poiinfo != nil) {
                [self markShow];
                shaixuanDArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_d"]];
                shaixuanXArr = [[NSMutableArray alloc] initWithArray:self.poiinfo[@"list_x"]];
                //查询数据之后重新初始化显示
                NSMutableArray * dataSource = [NSMutableArray array];
                for (int i = 0; i < self.shaiXuanDataSource.count; i++) {
                    
                    NSString * key = [NSString stringWithFormat:@"%d", i];
                    
                    NSDictionary * dict = @{key:@YES};
                    
                    [dataSource addObject:dict];
                }
                self.switcherDataSource = dataSource;
                [self.shaiXuanListView reloadData];
                
                [self searchSelectUiDismiss];
                BOOL isAdd = NO;
                NSLog(@"传过来的type:%@",type);
                
                if (selectRes) {
                    if ([type isEqualToString:@"poleline"]&&![self.plusDataSource containsObject:selectRes[@"poleLineName"]]) {
                        //杆路
                        [self.plusDataSource addObject:selectRes[@"poleLineName"]];
                        isAdd = YES;
                    }else if ([type isEqualToString:@"pipe"]&&![self.plusDataSource containsObject:selectRes[@"pipeName"]]){
                        //管道
                        [self.plusDataSource addObject:selectRes[@"pipeName"]];
                        isAdd = YES;
                    }else if ([type isEqualToString:@"stationBase"]&&![self.plusDataSource containsObject:selectRes[@"stationName"]]){
                        //局站
                        [self.plusDataSource addObject:selectRes[@"stationName"]];
                        isAdd = YES;
                    }else if ([type isEqualToString:@"markStonePath"]&&![self.plusDataSource containsObject:selectRes[@"markStonePName"]]){
                        //标石路径
                        [self.plusDataSource addObject:selectRes[@"markStonePName"]];
                        isAdd = YES;
                    }else if ([type isEqualToString:@"route"]&&![self.plusDataSource containsObject:selectRes[@"routename"]]){
                        //光缆
                        [self.plusDataSource addObject:selectRes[@"routename"]];
                        isAdd = YES;
                    }else if ([type isEqualToString:@"cable"]&&![self.plusDataSource containsObject:selectRes[@"cableName"]]){
                        //光缆段
                        [self.plusDataSource addObject:selectRes[@"cableName"]];
                        isAdd = YES;
                    }
                }
                
                /// >>>>>>>>>>>
                
                // 默认选中
                //查询数据之后重新初始化显示
                NSMutableArray * dataSource2 = [NSMutableArray array];
                for (int i = 0; i < self.plusDataSource.count; i++) {
                    
                    [dataSource2 addObject:@YES];
                }
                self.plusSwitcherDataSource = nil;
                
                self.plusSwitcherDataSource = [NSArray arrayWithArray:dataSource2];

                /// <<<<<<<<<<<
                if (isAdd && selectRes) {
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setObject:[[NSMutableDictionary alloc] initWithDictionary:tempDic] forKey:selectRes];
                    [plusDataSourceMapData addObject:dic];
                    
                    NSMutableArray * imageNames = [NSMutableArray arrayWithArray:self.imageNames];
                    [imageNames addObject:type];
                    self.imageNames = imageNames;
                }
                
                [self.plusListView reloadData];
                
                NSLog(@"self.plusDataSource:%@",self.plusDataSource);
                NSLog(@"plusDataSourceMapData:%@",plusDataSourceMapData);
            }
        }else{
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            //查询失败，提示用户
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.label.text = [NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])];
            HUD.mode = MBProgressHUDModeText;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                HUD.mode = MBProgressHUDModeText ;
                
                [HUD hideAnimated:YES afterDelay:2];
                
                HUD = nil;
            });
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [HUD removeFromSuperview];
        HUD = nil;
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
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

//-(IBAction)location:(id)sender{
//    isLocationSelf = NO;
//    icm.hidden = YES;
//    //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
//    _mapView.userTrackingMode=MAUserTrackingModeFollow;
//    _mapView.showsUserLocation = YES;//显示定位图层
//}
////手动定位按钮点击触发事件
//-(IBAction)locationSelf:(id)sender{
//    isLocationSelf = YES;
//    //停止定位监听
//    _mapView.showsUserLocation = NO;//显示定位图层
//    icm.hidden = NO;
//}

- (void) stationSelect:(NSString *)fileName {
    
    [YuanHUD HUDFullText:@"过去需要跳转的类 StationSelectResultTYKViewController"];
}
@end
