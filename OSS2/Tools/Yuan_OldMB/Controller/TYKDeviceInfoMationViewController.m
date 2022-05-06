//
//  TYKDeviceInfoMationViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/8/15.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "TYKDeviceInfoMationViewController.h"
#import "IWPPropertiesReader.h"
//#import "IWPDeviceListViewController.h"

#import "MBProgressHUD.h"
#import "StrUtil.h"
//#import "INCString.h"
#import "IWPLabel.h"
#import "IWPButton.h"
#import "IWPTextView.h"
#import "IWPTextFiled.h"
//#import "FaceNewCodeAutoViewController.h"

#import "RegionSelectViewController.h"
#import "LocationNewGaoDeViewController.h"
#import <CoreLocation/CoreLocation.h>


#import "IWPTableViewRowAction.h"
#import "IWPUniversalTextView.h"

#import "IWPSaoMiaoViewController.h"
#import "IWPCableRFIDScannerViewController.h"

#import "IWPCleanCache.h"
#import "CusButton.h"
#import "PointViewCell.h"
#import "IWPRfidInfoTableViewCell.h"
#import "ResourceTYKListViewController.h"

//#import "BindTubeRfidUIViewController.h"
//#import "BuildingUnitNewListViewController.h"
//#import "InitBuildingViewController.h"
//#import "OpenLockViewController.h"
//#import "GridAndUnitViewController.h"
//#import "BuildingModelViewController.h"


#import "EquModelTYKViewController.h"
#import "GisTYKMainViewController.h"
// MARK: 1. 引用头文件

#import "IWPCleanCache.h"
#import "IWPTools.h"

#import "GeneratorTYKViewController.h"


#import "Yuan_New_ODFModelVC.h"             //yuan 新写的 ODFModel
#import "StationSelectResultTYKViewController.h"
#import "TYKPowerUtil.h"


#import "Inc_CFListController.h"       //光缆段纤芯配置  -- 袁全 2020.07.21
#import "Yuan_TYKPhotoVC.h"             //统一库拍照 -- 袁全 2020.08.25
#import "Yuan_bearingCablesList.h"      //管道 承载缆段 -- 袁全 2020.09.01
#import "Yuan_FL_ListVC.h"              //端子 光纤光路和局向光纤 -- 袁全 2020.12.02

//#import "Yuan_UseElectricityVC.h"       //发电管理 -- 袁全 2020.12.17
//#import "Yuan_GeneratorRackConfigVC.h"
//#import "Yuan_SiteMonitorListVC.h"      // 机房监控
//#import "ModelUIViewController.h"       // 统一库OLT 模板入口

#import "Yuan_DeleteCableVC.h"          // 光缆段下 Gis -- 安徽批量撤缆


#import "Inc_BS_SubGeneratorListVC.h"

#import "Yuan_MoreLevelDeleteVC.h"      //联级删除

#import "Yuan_TerminalSelectCableView.h"  // 端子查光缆段
#import "Yuan_NewFL_HttpModel.h"        // 光纤光路接口
#import "Yuan_NewFL_LinkVC.h"           // 光纤光路
#import "Yuan_NewFL_RouteVC.h"          // 局向光纤
#import "Inc_Push_MB.h"


#import "Inc_NewMB_ListVC.h"           // 新版模板
#import "Inc_NewMB_AssistDevCollectVC.h"  //新的所属设备


// zzc  2021-6-15  保存按钮 存在业务变更时添加接口判断
#import "Yuan_NewFL_HttpModel.h"
#import "Inc_NewFL_HttpModel1.h"

//业务变更tablecell
#import "Inc_SynchronousView.h"


//zzc 2021-7-1  导航
#import <AMapNaviKit/AMapNaviKit.h>


// 局站、机房  下属设备
//#import "Inc_NewMBEquipCollectVC.h"

// 新模板查询
#import "Inc_NewMB_Type9_AssistListVC.h"

//2021-8-19
#import "MLMenuView.h"               // 下拉列表
#import "Inc_DeviceInfoTipView.h"  //复制提示
#import "Yuan_ODF_HttpModel.h"


// 光路http
#import "Yuan_NewFL_HttpModel.h"



//#pragma mark - 静态全局变量

static NSUInteger const nDefaultNormalTag = 10000;
static NSUInteger const nDefaultType3Tag = 30000;
static NSUInteger const nDefaultHiddenTag = 40000;
static NSUInteger const nDefaultType9Tag = 90000;
static NSUInteger const nDefaultType11Tag = 110000;

// 电杆、标石穿缆相关Key
static NSString * const kCableMainName = @"bearCableSegment";
static NSString * const kCableMainId = @"bearCableSegmentId";
static NSString * const kCableMainRfid = @"bearCableSegmentRFID";

#pragma mark - 全局变量
// 批量穿缆的判断，如果是批量穿缆为yes，否则为no，默认为no
BOOL isDevicesTYK = NO;
// 是否为修改Rfid
BOOL isUpdateRfidTYK = NO;
// 是否为type2
BOOL isType2TYK = NO;
// 是否设置type10的编辑框文本。
bool isSetType10TextFieldTYK = NO;
// 当前的Rfid
NSString * currentRfidTYK = @"";
// 非取值赋值用Tag
NSUInteger tagTYK = nDefaultNormalTag;
// CGRect
CGFloat xTYK = 0,yTYK = 0,wTYK = 0,hTYK = 0,marginTYK = 16.f;
// 当前按钮所对应的数组下标(dataSource)
NSInteger kRowTYK = 0;
// type3专用, button.tag
NSInteger sp_indexTYK = nDefaultType3Tag;
// pickerView当前选中行,每次pickerView创建时清0
NSInteger selectedRowTYK = 0;
// 隱藏项tag
NSInteger hidenTagTYK = nDefaultHiddenTag;
// 当前buttonTag
NSUInteger currentButtonTagTYK = 0;
// 是否是选择日期
BOOL isDatePickerTYK = NO;
// deflautSize
CGSize contentSizeTYK;
// 是否加载默认size
BOOL isDeflautSizeTYK = YES;
// type9 textView tag;
NSInteger type9TagTYK = nDefaultType9Tag;

CGFloat keyBoardOffsetTYK = 0;
// 当前点按的按钮的Tag
NSInteger currentTagTYK = 0;
// 获取到的经纬度
CLLocationDegrees kLatTYK = 0;
CLLocationDegrees kLonTYK = 0;

// 起始设备选中行
NSInteger startDeviceRowTYK = 0;
// 终止设备选中行 Rot 通 Row
NSInteger endDeviceRotTYK = 0;

// 视图type
NSString * typeTYK;
// 是否保存
BOOL isSavedTYK = NO;
// 获取地址按钮的tag
NSInteger addrBtnTagTYK = 0;
// 也是获取地址按钮的Tag
NSInteger getAddrBtnTagTYK = 0;
// type11已选择的起始设备行
NSInteger type11AlreadySelectedStartRowTYK = 0;
// type11已选择的终止设备行
NSInteger type11AlreadySelectedEndRowTYK = 0;
// 是否为type11
BOOL isType11TYK = NO;
// 默认的type11的tag起始值
NSInteger type11TagTYK = nDefaultType11Tag;
// 经纬度编辑框tag
long latTagTYK,lonTagTYK;
long yuan_NewLatLonTag,yuan_AddrTag;
// 是否提示过超时提示
BOOL isHintedTimeOutTYK = NO;
BOOL isStartDeviceTYK;// 是否是起始设施，用于光缆段起止设施为接头盒时传RFID字段用



// zzc  2021-6-15
//是否业务状态变更使用
//进入页面oprStateId  用于对比是否修改了状态
NSString * oldOprStateId;



@interface TYKDeviceInfoMationViewController ()
<
UIPickerViewDataSource,
UIPickerViewDelegate,
UITextViewDelegate,
//IWPDeviceListDelegate,
ptotocolDelegate,
CLLocationManagerDelegate,
LocationDelegate,
AMapSearchDelegate,
UITableViewDataSource,
UITableViewDelegate,
TYKDeviceInfomationDelegate,
IWPCableRFIDScannerDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate,
UITextFieldDelegate,
StationSelectResultTYKViewControllerDelegate,
AMapNaviCompositeManagerDelegate,
MLMenuViewDelegate
>

{
    NSString * TYKNew_fileName;  //统一库新增了 UNI_前缀的 fileName ; 袁全添加--
    
    // 解耦抽离
    Yuan_MB_ViewModel * _MB_VM;

}


// 編輯預覽框
@property (nonatomic, strong) IWPUniversalTextView * universalTextView;
// 是否为rowAction
@property (nonatomic, assign) BOOL isRowAction;
// 当前选中的indexPath
@property (nonatomic, strong) NSIndexPath * indexPath;
// 存放所有rowActions， 用于3D Touch
@property (nonatomic, strong) NSMutableArray<IWPTableViewRowAction *> * actions;
// ？？？？？？
@property (nonatomic, strong) AMapSearchAPI * search;
/**
 *  數據源, pickerView
 */
@property (nonatomic, strong) NSMutableArray <NSArray *>* dataSource;
/**
 *  操作模式, insert添加, update更新
 */
@property (nonatomic, assign) TYKDeviceListControlTypeRef controlMode;
/**
 *  視圖模型
 */
@property (nonatomic, strong) NSMutableArray <IWPViewModel *>* viewModel;
/**
 *  總模型
 */
@property (nonatomic, strong) IWPPropertiesSourceModel * model;
/**
 *  服務器返回數據的字典
 */
//@property (nonatomic, strong) NSDictionary <NSString *,NSString *> * dict;
/**
 *  pickerView當前key
 */
@property (nonatomic, copy) NSString * currentKey;
/**
 *  resLogic字段value
 */
@property (nonatomic, copy) NSString * fileName;
/**
 *  定位
 */
@property (nonatomic, strong) CLLocationManager * locationManager;
/**
 *  当前选中的按钮
 */
@property (nonatomic, weak) IWPButton * currentButton;
/**
 *  传入的机房信息
 */

@property (nonatomic, copy) NSDictionary * generatorInfoIn;
// 电杆穿缆列表
@property (nonatomic, weak) UITableView * listView;
/**
 *  电杆穿蓝的数据源
 */
@property (nonatomic, strong) NSMutableArray * listDataSource;

@property (nonatomic, strong) NSMutableArray <IWPRfidInfoFrameModel *>* listDataFrameModel;
// 用来读 key
@property (nonatomic, strong) IWPViewModel * t51ViewModel;
/**
 *  配置文件解析工具
 */
@property (nonatomic, strong) IWPPropertiesReader * reader;

//cable视图模型
@property (nonatomic, strong) NSArray <IWPViewModel *>* cableViewModel;
/**
 *   cable總模型
 */
@property (nonatomic, strong) IWPPropertiesSourceModel * cableModel;


// type11
@property (nonatomic, strong) NSArray <NSDictionary *> * getFileNames;
/**
 *  是否是地址
 */
@property (nonatomic, assign) BOOL isAddr;
/**
 *  显示详情按钮
 */
@property (nonatomic, weak) IWPButton * otherInfoBtn;
/**
 *  是否是拍照
 */
@property (nonatomic, assign) BOOL isTakePhoto;

@property (nonatomic, strong) NSDictionary * ledUpWell;
@property (nonatomic, strong) NSDictionary * occWell;
@property (nonatomic, weak) MBProgressHUD * HUD;
@property (nonatomic, assign) BOOL isAutoSetAddr;
@property (nonatomic, strong) NSDictionary * tempCableInfoDict; // 用于通知中的跳转
/**
 年 月 日
 */
@property (nonatomic, strong) NSDate * date_Date;

/**
 时分秒
 */
@property (nonatomic, strong) NSDate * date_Time;


//MARK: 2. 创建实例变量

/**
 保存、加载、关闭按钮的视图
 */
@property (nonatomic, weak) UIView * modelView;

/**
 显示modelView的按钮
 */
@property (nonatomic, weak) UIButton * arrowViewButton;


/** 显示或隐藏详情的左侧箭头  2020.12.22 */
@property (nonatomic,strong) UIImageView *detailImage;

/** <#注释#> */
@property (nonatomic , strong) Yuan_TerminalSelectCableView * terminalSelectCableView;


//zzc 20221-6-15

//同步变更 数据
@property (nonatomic, strong) NSMutableArray *synchronousArray;
@property (nonatomic, strong) Inc_SynchronousView *synchronousView;

//zzc 2021-7-1  导航
@property (nonatomic, strong) AMapNaviCompositeManager *compositeManager;

//下拉按钮
@property (nonatomic , strong) MLMenuView * menu;
//复制提示
@property (nonatomic, strong) Inc_DeviceInfoTipView *deviceInfoTipView;


@end

@implementation TYKDeviceInfoMationViewController{
    
    NSInteger bcode;//大的CODE
    NSInteger scode;//小的CODE
    NSMutableDictionary *pointListMap;//端子list字典
    NSMutableDictionary *obdEqutDic;//分光器信息字典
    UIButton *upBtn;//上一页按钮
    UIButton *downBtn;//下一页按钮
    UILabel *panCodeLabel;//盘号
    MBProgressHUD *__HUD;
    UICollectionView *pointCollectionView;//端子面板图
    NSIndexPath *lastClickPointIndex;
    
    //type11非含有起止资源的选中行
    NSInteger deviceRow;
    NSString *startOREndDevice_Id;
    
    BOOL _isHaveRfid;
    
    //zzc 2021-6-15
    //黑色透明背景view
    UIView *_windowBgView;
    
    //业务变更cell高度
    CGFloat _synHeight;
    
    
    //接口返回数组，确认修改时使用，因synchronousArray 可能需要变化
    NSMutableArray *_httpSynchronousArray;
    
    
    
    //2021-8-19 不常用的按钮放置在右侧菜单栏内
    NSMutableArray * _newBtnTitles;
    // 按钮数量，默认为0，动态递增
    NSInteger _newBtnCount;
    
    // 存放按钮对应点击事件的数组，C的数组
    SEL _newSelectors[15];
    
    //复制后需要的
    NSDictionary *_copyDic;
    NSArray <IWPViewModel *>*_copyViewModel;
    IWPPropertiesSourceModel *_copyModel;
    
    //保存后成功数据
    NSArray *_successArr;
    
}
#pragma mark - 懒加载
-(NSMutableArray<IWPTableViewRowAction *> *)actions{
    if (_actions == nil) {
        _actions = [NSMutableArray array];
    }
    return _actions;
}

-(IWPPropertiesReader *)reader{
    if (_reader == nil) {
                
        _reader = [IWPPropertiesReader propertiesReaderWithFileName:@"cable" withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
    }
    return _reader;
}
-(NSMutableArray *)listDataSource{
    if (_listDataSource == nil) {
        _listDataSource = [NSMutableArray array];
    }
    return _listDataSource;
}
-(CLLocationManager *)locationManager{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        
    }
    return _locationManager;
}

-(NSMutableDictionary *)requestDict{
    if (_requestDict == nil) {
        _requestDict = [NSMutableDictionary dictionary];
    }
    return _requestDict;
}

-(NSMutableArray<NSArray *> *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}


-(NSMutableArray *)synchronousArray {
    if (!_synchronousArray) {
        _synchronousArray = [NSMutableArray array];
    }
    return _synchronousArray;
}


- (Inc_SynchronousView *)synchronousView {
    
    if (!_synchronousView) {
        WEAK_SELF;
        _synchronousView = [[Inc_SynchronousView alloc]initWithFrame:CGRectNull];
        _synchronousView.btnSureBlock = ^(UIButton * _Nonnull btn) {
            [wself sureBtnClick];
        };
        _synchronousView.btnCancelBlock = ^(UIButton * _Nonnull btn) {
            [wself cancelBtnClick];
        };
    }
    return _synchronousView;
}

- (Inc_DeviceInfoTipView *)deviceInfoTipView {
    if (!_deviceInfoTipView) {
        WEAK_SELF;

        _deviceInfoTipView = [[Inc_DeviceInfoTipView alloc]initWithFrame:CGRectNull];
        _deviceInfoTipView.btnSureBlock = ^{
            [wself cancelBtnClick];
        };
    }
    return _deviceInfoTipView;
}

// init
- (AMapNaviCompositeManager *)compositeManager {
    if (!_compositeManager) {
        _compositeManager = [[AMapNaviCompositeManager alloc] init];  // 初始化
        _compositeManager.delegate = self;  // 如果需要使用AMapNaviCompositeManagerDelegate的相关回调（如自定义语音、获取实时位置等），需要设置delegate
    }
    return _compositeManager;
}



#pragma mark - 构造方法

+(instancetype)deviceInfomationWithControlMode:(TYKDeviceListControlTypeRef)controlMode
                                 withMainModel:(IWPPropertiesSourceModel *)model
                                 withViewModel:(NSArray <IWPViewModel *> *)viewModel
                                  withDataDict:(NSDictionary *)dict
                                  withFileName:(NSString *)fileName{
    
    return [[self alloc] initWithControlMode:controlMode
                               withMainModel:model
                               withViewModel:viewModel
                                withDataDict:dict
                                withFileName:fileName];
    
    
}


-(instancetype)initWithControlMode:(TYKDeviceListControlTypeRef)controlMode
                     withMainModel:(IWPPropertiesSourceModel *)model
                     withViewModel:(NSArray <IWPViewModel *>*)viewModel
                      withDataDict:(NSDictionary *)dict
                      withFileName:(NSString *)fileName {
    
    
    if (self = [super init]) {
        

        _copyDic = dict;
        _copyViewModel = viewModel;
        _copyModel = model;
        
        TYKNew_fileName = [NSString stringWithFormat:@"UNI_%@",fileName];
        
        // 赋值操作模式
        _controlMode = controlMode;
        // 赋值model
        if (model) {
            _model = model;
        }else{

            self.reader = [IWPPropertiesReader propertiesReaderWithFileName:TYKNew_fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
            self.model = [IWPPropertiesSourceModel modelWithDict:self.reader.result];
        }
        
        
        _MB_VM = Yuan_MB_ViewModel.viewModel;
        _MB_VM.controlMode = controlMode;
        _MB_VM.fileName = fileName;
        _MB_VM.model = _model;
        
        // 初始化viewModel
        NSMutableArray * arr;
        if (viewModel) {
            arr = [NSMutableArray arrayWithArray:viewModel];
        }
        else  {
            
            arr = [NSMutableArray arrayWithArray:[[IWPPropertiesReader propertiesReaderWithFileName:TYKNew_fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] viewModels]];
        }
        
  
        // 特殊类型的模板调整
        _viewModel = [NSMutableArray arrayWithArray:[_MB_VM Special_MB_Config:arr]];
 
        // 获取文件名
        _fileName = fileName;
        
        // 初始化请求字典
        self.requestDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        
        
        //zzc 2021-6-15 进入页面标记原状态
        if ([self.fileName isEqualToString:@"optPair"]) {
            oldOprStateId = self.requestDict[@"oprStateId"]?:@"";
            
        }
        
        if (controlMode == TYKDeviceListUpdate) {
            _generatorInfoIn = [dict copy];
        }
    }
    
    return self;
}


#pragma mark - 重写
-(void)setTaskId:(NSString *)taskId{
    
    _taskId = taskId;
    
    NSLog(@"%@", taskId);
    
    if (taskId) {
        [self.requestDict setValue:taskId forKey:@"taskId"];
    }
    
}



#pragma mark - 生命周期

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // 注销键盘弹出/收起通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"YKLPushCableRFIDVCNotification" object:nil];
    
    // search置空
    _search.delegate = nil;
    _search = nil;
    isSavedTYK = NO;
    


}
- (void)viewWillAppear:(BOOL)animated{
    
    _isTakePhoto = NO;
    isSavedTYK = NO;
    // 注册键盘弹出/收起通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goQRCodeScanner:) name:@"YKLPushCableRFIDVCNotification" object:nil];
    
    // 初始化search
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    _isTakePhoto = NO;
    
    NSLog(@"requestDict = %@", self.requestDict);
    
    
    // 在这个界面的时候 一定是资源操作
    Http.shareInstance.statisticEnum = HttpStatistic_Resource;
    
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    
    
    //2021-8-19 菜单按钮
    _newBtnTitles = NSMutableArray.array;
    _newBtnCount = 0;
    
    
    // 当 稽核通过扫一扫跳转时
    if (_controlMode == TYKDevice_NewCheck) {
        
        // 先做一个网络请求
        
        [self Yuan_NewCheckPort:^(NSArray *result) {
                    
        }];
        
    }
    
    
    if (_search == nil) {
        _search = [[AMapSearchAPI alloc] init];
        _search.delegate = self;
    }
    
    NSLog(@"👌requestDict = %@👌", self.requestDict);
    
    
    if ([self.fileName isEqualToString:@"pole"]) {
        if (self.requestDict && [self.requestDict[@"addr"] length] > 0) {
            if ([self.requestDict[@"poleSubName"] hasPrefix:self.requestDict[@"addr"]]) {
                _isAddr = YES;
            }else{
                _isAddr = NO;
            }
        }
    }
    
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    _isAutoSetAddr = [[user valueForKey:@"isAutoSetAddr"] integerValue] == 2 ? NO : YES;
    
    {// 初始化全局变量
        startDeviceRowTYK = 0;
        endDeviceRotTYK = 0;
        typeTYK = @"";
        isSavedTYK = NO;
        addrBtnTagTYK = 0;
        
        getAddrBtnTagTYK = 0;
        
        type11AlreadySelectedStartRowTYK = 0;
        type11AlreadySelectedEndRowTYK = 0;
        isType11TYK = NO;
        
        tagTYK = nDefaultNormalTag;
        xTYK = yTYK = wTYK = hTYK = 0;
        marginTYK = 8.f;
        kRowTYK = 0;
        sp_indexTYK = nDefaultType3Tag;
        selectedRowTYK = 0;
        hidenTagTYK = nDefaultHiddenTag;
        currentButtonTagTYK = 0;
        isHintedTimeOutTYK = NO;
        
        deviceRow = 0;
    }
    
    
    //如果没有授权则请求用户授权
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        
        [self.locationManager requestWhenInUseAuthorization];
    }else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
             [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways){
        //设置代理
        self.locationManager.delegate = self;
        //设置定位精度
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    
    if ([_fileName isEqualToString:@"tube"]) {
        // 一级子孔的新建管孔时 , 移除掉 '所属父管孔'
        if (!_isNeed_isFather ) {
            [_viewModel enumerateObjectsUsingBlock:^(id  _Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL * _Nonnull stop) {
               
                IWPViewModel * vm = obj;
                // 移除掉所属父管孔
                if ([vm.tv1_Text isEqualToString:@"所属父管孔"]) {
                    [_viewModel removeObjectAtIndex:idx];
                }
            }];
        }
        
        //  二级及以下子孔的 详细信息模板时 , 要移除 '所属管道段'
        else  {
            
            [_viewModel enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               
                IWPViewModel * vm = obj;
                // 移除掉所属父管孔
                if ([vm.tv1_Text isEqualToString:@"所属管道段"]) {
                    [_viewModel removeObjectAtIndex:idx];
                }
            }];
            
        }
        
    }
    
 
    
    
    [self createSubViewsNew];


    
    //zzc 2021-6-16 进入页面标记原状态
    if ([_fileName isEqualToAnyString:@"opticTerm",@"optLogicPair", nil]){

        oldOprStateId = self.requestDict[@"oprStateId"]?:@"";

    }
    
    // zzc 2021-6-15  业务变更
    [self setWindowBgView];
    _windowBgView.hidden = YES;
    _synchronousView.hidden = YES;
    _deviceInfoTipView.hidden = YES;

    _httpSynchronousArray = [NSMutableArray array];

    
    //2021-8-20 内容复制
    if (_isCopy) {
        _windowBgView.hidden = NO;
        _deviceInfoTipView.hidden = NO;
    }

    
    // 监听 当端子列表请求 返回info @"统一库没有该资源!" 时的业务处理
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Http_InfoNotification:)
                                                 name:HttpSuccess_Error_Info_Notification
                                               object:nil];

    
    [super viewDidLoad];
}

/// 导航栏右侧按钮
- (void) naviBarSet {
    
    // 导航栏右侧按钮
    
    UIBarButtonItem * rightBarBtn =
    [UIView getBarButtonItemWithImageName:@"icon_pplist_gongneng"
                                      Sel:@selector(rightBarBtnClick)
                                       VC:self];
    
    self.navigationItem.rightBarButtonItems = @[rightBarBtn];
}



// 导航栏右侧按钮 点击事件
- (void) rightBarBtnClick {
    
    [self.menu showMenuEnterAnimation:MLAnimationStyleTop];
}

//黑色透明背景和异常table
-(void)setWindowBgView {
    _windowBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _windowBgView.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:0.4];
    _windowBgView.userInteractionEnabled = YES;
  

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [_windowBgView addGestureRecognizer:tap];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:_windowBgView];
    
    
    [_windowBgView addSubview:self.synchronousView];
    
    [_windowBgView addSubview:self.deviceInfoTipView];

    [_deviceInfoTipView YuanToSuper_Left:Vertical(30)];
    [_deviceInfoTipView YuanToSuper_Right:Vertical(30)];
    [_deviceInfoTipView autoSetDimension:ALDimensionHeight toSize:Vertical(200)];
    [_deviceInfoTipView YuanAttributeCenterToView:_windowBgView];

}

#pragma mark - 通知响应
#pragma mark 键盘弹出事件
- (void)keyBoardWillAppear:(NSNotification *)notification{
    // 取得信息
    NSDictionary *userInfo = [notification userInfo];
    // 取得键盘frame
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;
    
    // 获取通用对话框frame
    CGRect frame = self.universalTextView.frame;
    
    // 计算最终Y坐标
    frame.origin.y = keyBoardEndY - frame.size.height;
    // 取出键盘弹出动画时间
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    // 添加动画
    [UIView animateWithDuration:duration.doubleValue animations:^{
        self.universalTextView.frame = frame;
    }];
}
#pragma mark 键盘弹出收起事件
- (void)keyBoardWillDisappear:(NSNotification *)notification{
    
    // 跟上面差不多
    CGRect frame = self.universalTextView.frame;
    NSDictionary *userInfo = [notification userInfo];
    
    // 这里是讲y设为屏幕高，就是屏幕外
    frame.origin.y = ScreenHeight;
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:duration.doubleValue animations:^{
        self.universalTextView.frame = frame;
    } completion:^(BOOL finished) {
        [self.universalTextView removeFromSuperview];
        self.universalTextView = nil;
    }];
    
}

#pragma mark - 其它方法
#pragma mark 创建控件

//新版详情，不常用按钮放入菜单中
- (void)createSubViewsNew {
    
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    // 创建正文视图
    
    if (_controlMode == TYKDeviceInfomationTypeDuanZiMianBan_Update) {
        
        
        xTYK = ScreenWidth / 5.f;
        
    }else{
        
        xTYK = 0.f;
        
    }
    
    if (/*[_fileName isEqualToString:@"port"]||*/[_fileName isEqualToString:@"OBDPoint"]) {
        _model.btn_Other = @"1";
        _model.btn_Other_Title = @"关联关系";
    }
    
    if ([_fileName isEqualToString:@"spcBuildings"]){
        _model.btn_Other = @"1";
        _model.btn_Other_Title = @"单元";
        _model.btn_Other2 = @"1";
        _model.btn_Other_Title2 = @"模板";
    }
    
    if ([_fileName isEqualToString:@"buildingUnit"]){
        _model.btn_Other = @"1";
        _model.btn_Other_Title = @"平面图";
    }
    
    if ([_fileName isEqualToString:@"ODF_Equt"]||
        [_fileName isEqualToString:@"OCC_Equt"]||
        [_fileName isEqualToString:@"ODB_Equt"] /*||
        [_fileName isEqualToString:@"joint"]*/){
        
        _model.btn_Other = @"1";
        _model.btn_Other_Title = @"列框";
    }
    if ([_fileName isEqualToString:@"ODF_Equt"]||[_fileName isEqualToString:@"OCC_Equt"]||[_fileName isEqualToString:@"ODB_Equt"]){
        _model.btn_Other2 = @"1";
        _model.btn_Other_Title2 = @"模板";
    }
    if ([_fileName isEqualToString:@"cnctShelf"]){
        _model.btn_Other = @"1";
        _model.btn_Other_Title = @"模块";
    }
    if ([_fileName isEqualToString:@"module"]){
        _model.btn_Other = @"1";
        _model.btn_Other_Title = @"端子";
    }
    
    if (self.isGenSSSB) {
        _model.btn_Other = @"1";
        _model.btn_Other_Title = @"模块";
        _model.btn_Other2 = @"1";
        _model.btn_Other_Title2 = @"板卡";
        _model.btn_Other3 = @"1";
        _model.btn_Other_Title3 = @"平面图";
    }
    
    // 2018年05月25日 OLT端子查看路由，目前仅支持OLT查看
    
    
    if ([_fileName isEqualToString:@"opticTerm"] &&
        [_sourceFileName isEqualToAnyString:@"ODF_Equt",  nil]) {
        
        _model.btn_Other = @"1";
        _model.btn_Other_Title = @"查看路由";
        
    }
    
    
    if (self.controlMode == TYKDeviceListInsert||
        self.controlMode == TYKDeviceListInsertRfid) {
        
        //MARK: 3. 创建模板信息View
        // 判断是否已经创建，未创建时再进行创建
        if (_modelView == nil ||
            _arrowViewButton == nil) {
            
            UIView * modelView = [[UIView alloc] init];
            
            //        modelView.backgroundColor = [UIColor getStochasticColor];
            
            [self.view addSubview:modelView];
            
            _modelView = modelView;
            
            NSArray * imageNames = @[@{@"normal":@"save2_normal", @"highlighted":@"save2_highlighted"},
                                     @{@"normal":@"load_normal", @"highlighted":@"load_highlighted"},
                                     @{@"normal":@"close2_normal", @"highlighted":@"close2_highlighted"}];
            
            UIButton * lastButton = nil;
            NSInteger index = 0;
            
            float limit = Horizontal(15);
            

            
            
            for (NSDictionary * imageD in imageNames) {
                
                
                UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
                
                
                [btn setImage:[UIImage Inc_imageNamed:imageD[@"normal"]] forState:UIControlStateNormal];
                [btn setImage:[UIImage Inc_imageNamed:imageD[@"highlighted"]] forState:UIControlStateHighlighted];
                
                
                btn.tag = 90100 + index;
                
                [modelView addSubview:btn];
                
                [btn addTarget:self action:@selector(modelButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
                
                if (index == imageNames.count - 1) {
                    
                    [btn YuanToSuper_Top:5];
                    [btn YuanToSuper_Right:20];
                    [btn YuanToSuper_Bottom:5];
                    [btn Yuan_EdgeWidth:50];
                    
//                    btn.sd_layout.rightSpaceToView(modelView, 20.f)
//                    .topSpaceToView(modelView, 5.f)
//                    .bottomSpaceToView(modelView, 5.f)
//                    .widthIs(50.f);
                    
                    
                }else{
                    
                    if (lastButton == nil) {
                        
                        [btn YuanToSuper_Top:5];
                        [btn YuanToSuper_Left:20];
                        [btn YuanToSuper_Bottom:5];
                        [btn Yuan_EdgeWidth:50];
                        
//                        btn.sd_layout.leftSpaceToView(modelView, 20.f)
//                        .topSpaceToView(modelView, 5.f)
//                        .bottomSpaceToView(modelView, 5.f)
//                        .widthIs(50.f);
                    }else{
                        
                        
                        [btn YuanToSuper_Top:5];
                        [btn YuanToSuper_Left:20 + 30 * index];
                        [btn YuanToSuper_Bottom:5];
                        [btn Yuan_EdgeWidth:50];
                        
//                        btn.sd_layout.leftSpaceToView(lastButton, 5.f)
//                        .topSpaceToView(modelView, 5.f)
//                        .bottomSpaceToView(modelView, 5.f)
//                        .widthIs(50.f);
                    }
                    
                    lastButton = btn;
                    
                }
                
                index++;
                
                
            }
            
            
            
            // MARK: 3.1. 箭头图片，用于指示向下拉来显示
            
            UIButton * arrowView = [UIButton buttonWithType:UIButtonTypeSystem];
            //        arrowView.backgroundColor = [UIColor getStochasticColor];
            [arrowView setImage:[[UIImage Inc_imageNamed:@"arrow_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            [arrowView setImage:[[UIImage Inc_imageNamed:@"arrow_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted];
            
            [arrowView addTarget:self action:@selector(showModelLoadView:) forControlEvents:UIControlEventTouchUpInside];
            
            arrowView.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.view addSubview:arrowView];
            
            _arrowViewButton = arrowView;
            
            
            arrowView.frame = CGRectMake(xTYK, HeigtOfTop, self.view.width - xTYK, 30.f);
            
            modelView.frame = CGRectMake(xTYK, HeigtOfTop, self.view.width - xTYK, 0.f);
            
            
        }
        
        
        // MARK: 4. 模板有存储时默认显示modelView
        NSString * documentsPath = [NSString stringWithFormat:@"%@/%@/%@.model", DOC_DIR, kDeviceModel, _fileName];
        // 有模板默认显示
        
        if ([[IWPCleanCache new] isExist:documentsPath]) {
            
            _modelView.frame = CGRectMake(xTYK, HeigtOfTop, self.view.width - xTYK, 40);

            _arrowViewButton.hidden = true;
            
        }
        
    }
    
    
    if (self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) {
        yTYK = CGRectGetMaxY(_modelView.frame);
    }else{
        yTYK = HeigtOfTop;
    }
    wTYK = ScreenWidth - xTYK;
    hTYK = ScreenHeight - 49.f;
    

    // 如果是端子 , 需要请求端子所属光缆段
    if ([_fileName isEqualToString:@"opticTerm"] &&
        [_requestDict.allKeys containsObject:@"GID"]) {
        //zzc 2021-7-12 增加了承载业务高度  50
        yTYK += Vertical(100);
        
        [self TerminalSelectCable];
    }
    
    // 正文视图
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(xTYK, yTYK, wTYK, hTYK)];
    self.contentView = scrollView;  //contentView 是 self.scrollview
    [self.view addSubview:scrollView];
    
    if (self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) {
        
        [scrollView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_modelView];
        [scrollView YuanToSuper_Left:xTYK];
        [scrollView YuanToSuper_Right:0];
        [scrollView YuanToSuper_Bottom:49];
        
//        scrollView.sd_layout.topSpaceToView(_modelView, 0.f)
//        .leftSpaceToView(self.view, xTYK)
//        .rightSpaceToView(self.view, 0.f)
//        .bottomSpaceToView(self.view, 49.f);
    }else{
        
        
        float height_Y = HeigtOfTop;
        
        if ([_fileName isEqualToString:@"opticTerm"] &&
            [_requestDict.allKeys containsObject:@"GID"]) {
            //zzc 2021-7-12 增加了承载业务高度  50
            height_Y += Vertical(100);
        }
        
        [scrollView YuanToSuper_Top:height_Y];
        [scrollView YuanToSuper_Left:xTYK];
        [scrollView YuanToSuper_Right:0];
        [scrollView YuanToSuper_Bottom:49];
        

//        scrollView.sd_layout.topSpaceToView(self.view, height_Y)
//        .leftSpaceToView(self.view, xTYK)
//        .rightSpaceToView(self.view, 0.f)
//        .bottomSpaceToView(self.view, 49.f);
    }
    
    // 隐藏滚动条，必须全部隐藏，否则“显示/隐藏详情”按钮会飘
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    
    
    // 设置窗体标题
    NSString * title = [NSString stringWithFormat:@"%@信息",_model.name];
    if (_controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) {
        // 若为添加状态，重设标题
        title = [NSString stringWithFormat:@"添加%@",_model.name];
    }
    
    if (_isOffline) {
        title = [title stringByAppendingString:@"(离线)"];
    }
    
    self.title = title;   //设置界面标题
    
    
    // 设置背景色
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 根据文件创建视图, 首先创建必要的视图
    // 根据 _viewModel 里的 IWPViewModel类 获取到界面相关的信息
    for (IWPViewModel * model in _viewModel) {

        // 2017年01月21日 要求跟随文件走
        
        
        if (model.tv1_Required.boolValue) {
            // 使用读取到的Model创建视图
            [self createSubViewWithViewModel:model];
        }
        
    }
    
    // 是否会有隐藏视图，默认为NO
    BOOL isHaveHiddenView = NO;
    
    
    // 再创建非必要视图
    for (IWPViewModel * model in _viewModel) {
        if (model.tv1_Required.intValue == 1 /* || [model.tv1_Text isEqualToString:@"扩充后缀"]*/) {
            // 2017年01月21日 要求跟随文件走
            continue;
        }else{
            // 仅赋值一次
            if (!isHaveHiddenView) {
                isHaveHiddenView = YES;
            }
            [self createSubViewWithViewModel:model];
        }
        
        
        
    }
    
    
    // 下方编辑按钮标题数组
    NSMutableArray * btnTitles = [NSMutableArray array];
    // 按钮数量，默认为0，动态递增
    NSInteger btnCount = 0;
    
    // 存放按钮对应点击事件的数组，C的数组
    SEL selectors[15];
    
    // 其它功能按钮
    if (_model.btn_Other2.intValue == 1) {
        
        if ([_model.btn_Other_Title2 isEqualToString:@"模板"]) {
            // 加入标题
            [btnTitles addObject:_model.btn_Other_Title2];
            // 添加点击事件
            
            if ([self.fileName isEqualToString:@"stationBase"]) {
                selectors[btnCount] = @selector(showDevicePoint:);
            }else if ([self.fileName isEqualToString:@"generator"]){
                
                
            }else if ([self.fileName isEqualToString:@"spcBuildings"]){
                
                selectors[btnCount] = @selector(spcBuildingModel:);
                
            }else if ([_fileName isEqualToString:@"ODF_Equt"]){
                selectors[btnCount] = @selector(showODFModel:);
            }else if([_fileName isEqualToString:@"OCC_Equt"]){
                selectors[btnCount] = @selector(showOCCModel:);
            }else if([_fileName isEqualToString:@"ODB_Equt"]){
                selectors[btnCount] = @selector(showODBModel:);
            }else{
                selectors[btnCount] = @selector(showRFIDInfo:);
            }
            if (self.isGenSSSB) {
                selectors[btnCount] = @selector(showBANKAInfo:);
            }
            
            // 按钮数更新
            btnCount++;
           
            
        }else{
            [_newBtnTitles addObject:_model.btn_Other_Title2];
            
            if ([self.fileName isEqualToString:@"stationBase"]) {
                _newSelectors[_newBtnCount] = @selector(showDevicePoint:);
            }else if ([self.fileName isEqualToString:@"generator"]){
                
                
            }else if ([self.fileName isEqualToString:@"spcBuildings"]){
                
                _newSelectors[_newBtnCount] = @selector(spcBuildingModel:);
                
            }else if ([_fileName isEqualToString:@"ODF_Equt"]){
                _newSelectors[_newBtnCount] = @selector(showODFModel:);
            }else if([_fileName isEqualToString:@"OCC_Equt"]){
                _newSelectors[_newBtnCount] = @selector(showOCCModel:);
            }else if([_fileName isEqualToString:@"ODB_Equt"]){
                _newSelectors[_newBtnCount] = @selector(showODBModel:);
            }else{
                _newSelectors[_newBtnCount] = @selector(showRFIDInfo:);
            }
            if (self.isGenSSSB) {
                _newSelectors[_newBtnCount] = @selector(showBANKAInfo:);
            }
            
            _newBtnCount++;
          
        }
        
    }
    
    // 其它功能按钮
    if (_model.btn_Other.intValue == 1) {
    
        if ([_fileName isEqualToString:@"module"]){
            
            [btnTitles addObject:_model.btn_Other_Title];
            selectors[btnCount] = @selector(opticTermInfoHandler:);
            btnCount++;

        }else{
            // 依据文件名加入点击事件
            if ([_fileName isEqualToString:@"well"]) {
                _newSelectors[_newBtnCount] = @selector(faceHoleHandler:);
            }
        
            if ([_fileName isEqualToString:@"ODF_Equt"]||
                [_fileName isEqualToString:@"OCC_Equt"]||
                [_fileName isEqualToString:@"ODB_Equt"]||
                [_fileName isEqualToString:@"joint"]) {
                _newSelectors[_newBtnCount] = @selector(showODFMianBanHandler:);
            }
       
            if ([_fileName isEqualToString:@"generator"]) {
                
                if ([_newBtnTitles containsObject:@"所属设备"]) {
                    [_newBtnTitles replaceObjectAtIndex:_newBtnTitles.count - 1 withObject:@"设备"];
                }
                
                NSArray *array = [self.navigationController viewControllers];
                if (array.count>1&&[[array objectAtIndex:array.count-2] isKindOfClass:[ResourceTYKListViewController class]]) {
                    //从统一库资源信息列表页面进来
                    _newSelectors[_newBtnCount] = @selector(generatorTYKDevices:);
                    
                }else if (array.count>0&&[[array objectAtIndex:array.count-1] isKindOfClass:[GeneratorTYKViewController class]]) {
                    //从统一库扫描二维码页面进来
                    _newSelectors[_newBtnCount] = @selector(generatorTYKDevices:);
                    
                }
                
            }
            if ([_fileName isEqualToString:@"cable"]) {
                _newSelectors[_newBtnCount] = @selector(showPeizhiDuankouHandler:);
            }
            //        if ([_fileName isEqualToString:@"ODB_Equt"]) {
            //
            //            selectors[btnCount] = @selector(showODBMianBanHandler:);
            //        }
            if ([_fileName isEqualToString:@"OLT_Equt"]) {
                
                _newSelectors[_newBtnCount] = @selector(showOLTMianBanHandler:);
            }
            if (/*[_fileName isEqualToString:@"port"]||*/[_fileName isEqualToString:@"OBDPoint"]) {
                _newSelectors[_newBtnCount] = @selector(showOPPOMainBanHandler:);
            }
            if ([_fileName isEqualToString:@"spcBuildings"]){
                _newSelectors[_newBtnCount] = @selector(showBuildingUnitMainBanHandler:);
            }
            if ([_fileName isEqualToString:@"buildingUnit"]){
                _newSelectors[_newBtnCount] = @selector(showBuildingUnitPingmianTuBanHandler:);
            }
            if ([_fileName isEqualToString:@"card"]){
                _newSelectors[_newBtnCount] = @selector(doSomethingHandler:);
            }
            if ([_fileName isEqualToString:@"cnctShelf"]){
                _newSelectors[_newBtnCount] = @selector(moduleInfoHandler:);
            }
            if (self.isGenSSSB) {
                _newSelectors[_newBtnCount] = @selector(showMOKUAIInfo:);
            }
            
            if ([_fileName isEqualToString:@"opticTerm"] && [_sourceFileName isEqualToAnyString:@"ODF_Equt",  nil]) {
                
                _newSelectors[_newBtnCount] = @selector(showRouteInfo:);
            }

            // 加入标题
            
            [_newBtnTitles addObject:_model.btn_Other_Title];
            
            // 更新按钮数量
            _newBtnCount++;
        }
      
        
    }
    
        //MARK: 2 ~加入按钮到界面~
    
    if (_model.btn_Other3.intValue == 1){
        // MARK: 3 ~加入按钮标题~
        [_newBtnTitles addObject:_model.btn_Other_Title3];
        if (self.isGenSSSB) {
            _newSelectors[_newBtnCount] = @selector(showEquModel:);
        }
        _newBtnCount++;
        
    }
    
    
    /// MARK: 保存权限 --- ---
    if (_model.btnVi_Save.intValue == 1) {
        /*if (![UserModel.domainCode isEqualToString:@"0/"]) {*/
            BOOL ishaveSaveBtn = NO;
            if(_isOffline && ([_fileName isEqualToString:@"poleline"]||[_fileName isEqualToString:@"pole"])){
                //离线杆路始终都有保存按钮
                ishaveSaveBtn = YES;
            }else if([_fileName isEqualToString:@"opticTerm"] && ([self.equType isEqualToString:@"OCC_Equt"]||[self.equType isEqualToString:@"ODF_Equt"]||[self.equType isEqualToString:@"ODB_Equt"])){
                //OCC/ODB/ODF设备端子信息跟着设备信息走
                if ([[UserModel.powersTYKDic[self.equType] substringFromIndex:2] integerValue]==1) {
                    ishaveSaveBtn = YES;
                }
            }
            
            else if([_fileName isEqualToString:@"optPair"]){
                // 当 optPair 时 取得是 光缆段的权限
                if ([[UserModel.powersTYKDic[@"cable"] substringFromIndex:2] integerValue]==1) {
                    ishaveSaveBtn = YES;
                }
            }
            //袁全 在管孔的配置 使用的是管道段的权限  *** ***
            else if([_fileName isEqualToString:@"tube"]){
                // 当 tube 时 取得是 管道段的权限
                if ([[UserModel.powersTYKDic[@"pipeSegment"] substringFromIndex:2] integerValue]==1) {
                    ishaveSaveBtn = YES;
                }
            }
            
            else{
                if ([[UserModel.powersTYKDic[self.fileName] substringToIndex:1] integerValue] == 1 &&(self.controlMode == TYKDeviceListInsert||self.controlMode == TYKDeviceListInsertRfid || self.controlMode == TYKDeviceListNoDelete)) {
                    ishaveSaveBtn = YES;
                }
                if ([[UserModel.powersTYKDic[self.fileName] substringFromIndex:2] integerValue]==1 &&(self.controlMode == TYKDeviceListUpdate ||self.controlMode == TYKDeviceListUpdateRfid||self.controlMode == TYKDeviceInfomationTypeDuanZiMianBan_Update || self.controlMode == TYKDeviceListNoDelete)){
                    ishaveSaveBtn = YES;
                }
                
            }
            
            if (ishaveSaveBtn/*||self.isGenSSSB*/) {
                //有修改权限，需要给保存按钮
                // 如果按钮存在, 向 方法数组中添加selector
                // 加入标题
                [btnTitles addObject:@"保存"];
                // 加入点击事件
                selectors[btnCount] = @selector(saveButtonHandler:);
                // 更新按钮数量
                btnCount++;
            }else{
                NSLog(@"_viewModel:%@",_viewModel);
                BOOL isHaveRfid = NO;
                _isHaveRfid = NO;   //全局变量赋值
                for (int i = 0; i<_viewModel.count; i++) {
                    if ([_viewModel[i].type intValue] == 52) {
                        isHaveRfid = YES;
                        _isHaveRfid = YES;
                    }
                }
                if (isHaveRfid) {
                    if ([_fileName isEqualToString:@"opticTerm"]||[_fileName isEqualToString:@"shelf"]) {

                    }else{
                        //没有修改权限，需要给保存标签按钮
                        // 如果按钮存在, 向 方法数组中添加selector
                        // 加入标题
                        [btnTitles addObject:@"保存标签"];
                        // 加入点击事件
                        selectors[btnCount] = @selector(saveRFIDButtonHandler:);
                        // 更新按钮数量
                        btnCount++;
                    }
                }
                
            }

    }
    
    //MARK:  拍照权限 -- 袁
    
    if (_model.btnVi_Photo.intValue == 1 &&
        _requestDict.count != 0 &&
        [_requestDict.allKeys containsObject:@"GID"]) {
        
        
        
        [btnTitles addObject:@"拍照"];
        // 加入点击事件
        selectors[btnCount] = @selector(Yuan_PhtotClick);
        // 更新按钮数量
        btnCount++;
    }
    
    
    
  
    
    //MARK: 对于光缆段的新增按钮 -- 袁
    
    if ([_fileName isEqualToString:@"cable"] && _requestDict.count != 0) {
        
        [btnTitles addObject:@"纤芯配置"];
        selectors[btnCount] = @selector(cableFiberConfigClick);
        btnCount++;
        
        [_newBtnTitles addObject:@"GIS"];
        _newSelectors[_newBtnCount] = @selector(cableDeleteCableClick);
        _newBtnCount++;
        
//        [_newBtnTitles addObject:@"光缆段合并"];
//        _newSelectors[_newBtnCount] = @selector(cableMergeClick);
//        _newBtnCount++;
//
//        [_newBtnTitles addObject:@"光缆段拆分"];
//        _newSelectors[_newBtnCount] = @selector(cableSplitClick);
//        _newBtnCount++;
        
        
        
    }
    
    
    // MARK: 综合箱
    if ([_fileName isEqualToString:@"integratedBox"] && _requestDict.count != 0) {
        
        [btnTitles addObject:@"模板"];
        selectors[btnCount] = @selector(showIntegratedBoxModel);
        btnCount++;
    }
    
    
    //MARK:  管道 判断承载缆段 -- 袁
    if ([_fileName isEqualToString:@"tube"] &&
        _requestDict.count != 0 &&
        [_requestDict.allKeys containsObject:@"GID"]) {
        
        [_newBtnTitles addObject:@"承载缆段"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(Yuan_ChengZ_CableClick);
        // 更新按钮数量
        _newBtnCount++;
        
        // 二级子孔 不再显示子孔按钮
        if (!_isNeed_isFather) {
            [btnTitles addObject:@"子孔"];
            // 加入点击事件
            selectors[btnCount] = @selector(Yuan_subHoleClick);
            // 更新按钮数量
            btnCount++;
        }
        
        
    }
    
    
    //MARK: 局向光纤 2021.03.01 Yuan_NewFL_ConfigVC
    if ([_fileName isEqualToString:@"optLogicPair"]&&
        _requestDict.count != 0 &&
        [_requestDict.allKeys containsObject:@"GID"]) {
        
        [btnTitles addObject:@"路由"];
        // 加入点击事件
        selectors[btnCount] = @selector(New2021_OpticalRoute);
        // 更新按钮数量
        btnCount++;

        
    }
    
    //MARK: 光纤光路 2021.03.01
    if ([_fileName isEqualToString:@"opticalPath"]&&
        _requestDict.count != 0 &&
        [_requestDict.allKeys containsObject:@"GID"]) {
        
        [btnTitles addObject:@"路由"];
        // 加入点击事件
        selectors[btnCount] = @selector(New2021_OpticalLink);
        // 更新按钮数量
        btnCount++;
    }
    
    //MARK: 分光器入口
    
    // OCC ODB ODF 综合箱
    if ([_fileName isEqualToAnyString:@"OCC_Equt",@"ODB_Equt",@"ODF_Equt",@"integratedBox", nil] &&
        _requestDict.count != 0 &&
        [_requestDict.allKeys containsObject:@"GID"]) {
        
        [_newBtnTitles addObject:@"分光器"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(New2021_OBD_Equt);
        // 更新按钮数量
        _newBtnCount++;
        
        
    }
    
    // *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
    
    
    
    /// 引上点 标石 撑点 电杆  增加 '承载缆段'按钮
    if (([_fileName isEqualToString:@"markStone"] ||
         [_fileName isEqualToString:@"pole"] ||
         [_fileName isEqualToString:@"supportingPoints"] ||
         [_fileName isEqualToString:@"ledUp"])  &&
        _requestDict.count != 0 &&
        [_requestDict.allKeys containsObject:@"GID"]) {
        
        [_newBtnTitles addObject:@"承载缆段"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(Yuan_ChengZ_CableClick);
        // 更新按钮数量
        _newBtnCount++;
        
    }
    
    
    ///纤芯  optPair
    if ([_fileName isEqualToString:@"optPair"] &&
        _requestDict.count != 0 &&
        [_requestDict.allKeys containsObject:@"GID"]) {
        
        //zzc 2021-6-18  查看光路
        [_newBtnTitles addObject:@"查看光路"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(zhang_OpticalPair);
        // 更新按钮数量
        _newBtnCount++;
        
    }
    
    /// 端子 opticTerm
    if ([_fileName isEqualToString:@"opticTerm"] &&
        _requestDict.count != 0 &&
        [_requestDict.allKeys containsObject:@"GID"]) {
        
        [_newBtnTitles addObject:@"光纤光路"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(New2021_LinkFromTerminalId);
        // 更新按钮数量
        _newBtnCount++;
        
        
        [_newBtnTitles addObject:@"局向光纤"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(New2022_RouteFromTerminalId);
        // 更新按钮数量
        _newBtnCount++;
        
        
        /*
         [_newBtnTitles addObject:@"局向光纤"];
         // 加入点击事件
         _newSelectors[_newBtnCount] = @selector(yuan_OpticalFiber);
         // 更新按钮数量
         _newBtnCount++;
         */
        
        /*
         //zzc 2021-6-18  查看光路
         [_newBtnTitles addObject:@"查看光路"];
         // 加入点击事件
         _newSelectors[_newBtnCount] = @selector(zhang_Opticallight);
         // 更新按钮数量
         _newBtnCount++;
         
         */
    }
    
    if ([_fileName isEqualToString:@"EquipmentPoint"] &&
        ([btnTitles containsObject:@"保存"] ||
         [btnTitles containsObject:@"保存标签"]) &&
        [_requestDict.allKeys containsObject:@"GID"] ) {
        
        [_newBtnTitles addObject:@"所属设备"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(EquipmentPointBtnClick);
        // 更新按钮数量
        _newBtnCount++;
        
        
        [_newBtnTitles addObject:@"下属设备"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(stationBase_Equipment);
        // 更新按钮数量
        _newBtnCount++;
    }
    
    
    if ([_fileName isEqualToString:@"stationBase"] &&
        
        [_requestDict.allKeys containsObject:@"GID"]) {
        
        [_newBtnTitles addObject:@"下属机房"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(stationBase_SelectSubGenerator);
        // 更新按钮数量
        _newBtnCount++;
        
        // zzc 2021 -7-12 局站添加下属设备
        [_newBtnTitles addObject:@"下属设备"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(stationBase_Equipment);
        // 更新按钮数量
        _newBtnCount++;
        
        
    }
    
    
    // 机房增加 用电 -- 袁全
    if ([_fileName isEqualToString:@"generator"] &&
        [_requestDict.allKeys containsObject:@"GID"]) {
        
        [_newBtnTitles addObject:@"用电管理"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(UseElectClick);
        // 更新按钮数量
        _newBtnCount++;
        
        [_newBtnTitles addObject:@"平面图"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(GeneratorRackConfig);
        // 更新按钮数量
        _newBtnCount++;
        
        
        [_newBtnTitles addObject:@"监控"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(SiteMonitorList);
        // 更新按钮数量
        _newBtnCount++;
        
        // zzc 2021 -7-12 局站添加下属设备
        [_newBtnTitles addObject:@"下属设备"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(stationBase_Equipment);
        // 更新按钮数量
        _newBtnCount++;
        
    }
    
    if ([_fileName isEqualToString:@"OLT_Equt"] &&
        [_requestDict.allKeys containsObject:@"GID"]) {
        
        [btnTitles addObject:@"模板"];
        // 加入点击事件
        selectors[btnCount] = @selector(MB_OLT);
        // 更新按钮数量
        btnCount++;
    }
    
    //机房，局站，设备放置点,光分纤箱和光终端盒，综合箱，光交接箱添加导航
    if (([_fileName isEqualToString:@"OCC_Equt"] ||
         [_fileName isEqualToString:@"ODB_Equt"] ||
         [_fileName isEqualToString:@"integratedBox"] ||
         [_fileName isEqualToString:@"stationBase"] ||
         [_fileName isEqualToString:@"generator"] ||
         [_fileName isEqualToString:@"EquipmentPoint"]) && [_requestDict.allKeys containsObject:@"GID"]) {
        
        [_newBtnTitles addObject:@"导航"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(zhang_Navi);
        // 更新按钮数量
        _newBtnCount++;
        
    }
    
    /// MARK: 删除权限
    if (_model.btnVi_Delete.intValue == 1 && _controlMode != TYKDeviceListNoDelete) {
        
        if (![UserModel.domainCode isEqualToString:@"0/"]&&([[[UserModel.powersTYKDic[self.fileName] substringFromIndex:1] substringToIndex:1] integerValue]==1) ) {
            [_newBtnTitles addObject:@"删除"];
            _newSelectors[_newBtnCount] = @selector(deleteStationButtonHandler:);
            _newBtnCount++;
        }
        if (_isOffline &&([[[UserModel.powersTYKDic[self.fileName] substringFromIndex:1] substringToIndex:1] integerValue]==0)){
            [_newBtnTitles addObject:@"删除"];
            _newSelectors[_newBtnCount] = @selector(deleteStationButtonHandler:);
            _newBtnCount++;
        }
        
        //  袁全新增 当 filename optPair 光缆段纤芯配置的时候 查的是统一库资源
        if([_fileName isEqualToString:@"optPair"]){
            // 当 optPair 时 取得是 光缆段的权限  如果有光缆段权限 那么就有删除权限
            if ([[UserModel.powersTYKDic[@"cable"] substringFromIndex:2] integerValue]==1) {
                
                [_newBtnTitles addObject:@"删除"];
                _newSelectors[_newBtnCount] = @selector(Yuan_NormalDelete);
                _newBtnCount++;
            }
        }
        
        // 管孔的删除权限 根据管道段的权限使用
        if ([_fileName isEqualToString:@"tube"]) {
            
            if ([[UserModel.powersTYKDic[@"pipeSegment"] substringFromIndex:2] integerValue]==1) {
                
                [_newBtnTitles addObject:@"删除"];
                _newSelectors[_newBtnCount] = @selector(Yuan_NormalDelete);
                _newBtnCount++;
            }
        }
        
    }
    
    //光交、ODF、分纤箱、综合箱  添加复制功能
    if (([_fileName isEqualToString:@"OCC_Equt"] ||
         [_fileName isEqualToString:@"ODF_Equt"]  ||
         [_fileName isEqualToString:@"ODB_Equt"] ||
         [_fileName isEqualToString:@"integratedBox"]) && [_requestDict.allKeys containsObject:@"GID"]) {
        
        [_newBtnTitles addObject:@"复制"];
        // 加入点击事件
        _newSelectors[_newBtnCount] = @selector(zhang_copy);
        // 更新按钮数量
        _newBtnCount++;
    }
    
    if ( _isCopy) {
        
        btnCount = 0;
        [btnTitles removeAllObjects];
        
        [btnTitles addObject:@"保存"];
        // 加入点击事件
        selectors[btnCount] = @selector(zhang_copySave);
        // 更新按钮数量
        btnCount++;
     
    }
    
    
    if (_controlMode != TYKDeviceInfomationTypeDuanZiMianBan_Update) {
        xTYK = 0;
    }else{
        xTYK = ScreenWidth / 5.f;
    }
    
    hTYK = 49.f;
    yTYK = ScreenHeight - hTYK;
    wTYK = ScreenWidth - xTYK;
    tagTYK = 20000;
    
    float limit = 5;
    float btnHeight = 35;
    // 按钮被设置Corner，需要一个背景视图衬托
    UIView * controlView = [[UIView alloc] initWithFrame:CGRectMake(xTYK,yTYK,wTYK,hTYK)];
    controlView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:controlView];
    
    yTYK = (hTYK - btnHeight)/2;
    
    float btnWidth = (wTYK - (btnCount + 1) * limit) / btnCount;
    
    for (int i = 0; i < btnCount; i++) {
        xTYK = i * (btnWidth + limit) +limit;
        IWPButton * btn = [IWPButton buttonWithType:UIButtonTypeSystem];
        btn.tag = tagTYK++;
        btn.frame = CGRectMake(xTYK,yTYK,btnWidth,btnHeight);
        
        
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        // 从点击事件数组中取出对应的点击事件
        [btn addTarget:self action:selectors[i] forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:[UIColor mainColor]];
        btn.fileName = _model.btn_Other2_BeanName;
        
        btn.backgroundColor = UIColor.mainColor;
        btn.titleLabel.font = Font_Yuan(12);
        
        [btn cornerRadius:3 borderWidth:0 borderColor:UIColor.clearColor];
        
        btn.titleLabel.numberOfLines = 0;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [controlView addSubview:btn];
        
    }
    
    
    
    
    NSInteger tmpTag = tagTYK - 1;
    
    for (NSUInteger i = tmpTag; i > tmpTag - btnCount; i--) {
        
        UIButton * btn = (IWPButton *)[self.view viewWithTag:i];
        
        [btn setTitle:btnTitles[i - 20000] forState:UIControlStateNormal];
        
    }
    
    

    
    
    
    wTYK = self.contentView.bounds.size.width / 2.f;
    hTYK = 49.f;
    yTYK = [self getNewY] + marginTYK / 2.f;
    xTYK = (self.contentView.bounds.size.width - wTYK) / 2.f;
    
    IWPButton * otherInfoBtn = [IWPButton buttonWithType:UIButtonTypeCustom];
    otherInfoBtn.tag = tagTYK++;
    otherInfoBtn.frame = CGRectMake(xTYK,yTYK,wTYK,hTYK);
    self.otherInfoBtn = otherInfoBtn;
    
    [otherInfoBtn addTarget:self action:@selector(showBeizhu:) forControlEvents:UIControlEventTouchUpInside];
    [otherInfoBtn setTitle:@"显示详情" forState:UIControlStateNormal];
    [otherInfoBtn setTitle:@"隐藏详情" forState:UIControlStateSelected];
    [otherInfoBtn setBackgroundColor:[UIColor clearColor]];
    //        btn.backgroundColor = [UIColor getStochasticColor];
    [otherInfoBtn setTitleColor:ColorValue_RGB(0xb2b2b2) forState:UIControlStateNormal];
    
    otherInfoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.contentView addSubview:otherInfoBtn];
    otherInfoBtn.hidden = !isHaveHiddenView;
    
    
    
    _detailImage = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"yuanMB_Up"]
                                      frame:CGRectNull];
    
    [otherInfoBtn addSubview:_detailImage];
    
    // 添加箭头方向按钮
    [_detailImage YuanAttributeHorizontalToView:_otherInfoBtn];
    [_detailImage autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:marginTYK];
    
    //    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeOneBeizhuBtn)];
    //    [otherInfoBtn addGestureRecognizer:swipe];
    //    swipe.direction = UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp;
    //
    
    // 重置ScrollView的CONTENT_VIEW
    [self resetContentSize];
    
    if (_controlMode == TYKDeviceInfomationTypeDuanZiMianBan_Update) {
        if ([self.equType isEqualToString:@"OpticalSplitter"]) {
            //分光器面板图
            [self configOpticalSplitterView];
        }else{
            //OLT面板图
            [self configOLTView];
        }
        
    }
    
    
    [self.view bringSubviewToFront:_modelView];
    [self.view bringSubviewToFront:_arrowViewButton];
    
    //判断菜单是否有需要显示
    if (_newBtnCount > 0 && !_isCopy) {
        
//        [self naviBarSet];
        __typeof(self)weakSelf = self;
        weakSelf.moreBtnBlock = ^(UIButton * _Nonnull btn) {
            [self rightBarBtnClick];
        };
    }
    

}

#pragma mark - 重设contentView的contentSize
-(void)resetContentSize{
    
    CGFloat maxY = 0.f;
    // 遍历子视图，取出所有的未隐藏的视图，获取最大的Y
    for (__kindof UIView * view in self.contentView.subviews) {
        if (!view.hidden && view != self.otherInfoBtn) {
            CGFloat newY = CGRectGetMaxY(view.frame) + 5;
            if (maxY < newY) {
                maxY = newY + marginTYK / 2.f;
            }
        }
    }
    
    [UIView animateWithDuration:.3f animations:^{
        // 重设。
        CGRect frame = self.otherInfoBtn.frame;
        self.contentView.contentSize = CGSizeMake(0, maxY + marginTYK / 2.f + frame.size.height);
        frame.origin.y = maxY;
        self.otherInfoBtn.frame = frame;
        
    }];
}

#pragma mark 创建各typeView的入口方法
-(void)createSubViewWithViewModel:(IWPViewModel *)dict{
    // 创建pickerView数据源
    if (dict.sp_text.length > 0) {
        
        NSString * str = dict.sp_text;
        NSArray * titles = [str componentsSeparatedByString:@","];
        
        if (str.length > 0) {
            NSMutableArray * arr = [NSMutableArray array];
            for (NSString * title in titles) {
                if (title.length > 0) {
                    [arr addObject:title];
                }
            }
            [self.dataSource addObject:arr];
        }
    }
    

    // requestDict
    [self configContentViewsWithModel:dict];
}



#pragma mark 创建各typeView  -- 初始化view
-(void)configContentViewsWithModel:(IWPViewModel *)dict{
    
    
    switch (dict.type.intValue) {
        case 1:
            // 普通 1個label 1個texyFiled
            [self type1CreaterWithDict:dict];
            break;
        case 2:
            // 日期 1個label 1個textFiled 1個按鈕選擇日期
            [self type2CreaterWithDict:dict];
            break;
        case 3:
            // 下拉菜單 label PickerView
            [self type3CreaterWithDict:dict];
            break;
        case 4:
            // 獲取經緯度 label 兩個 textFiled , + /  /* 袁 .. 新版 一个label 一个textfield*/
            [self type4CreaterWithDict:dict];
            break;
        case 5:
            // 獲取地址 1個label 1個textFiled 1個按鈕
            [self type5CreaterWithDict:dict];
            break;
        case 6:
            // 獲取局站 1個label 1個textFiled 1個按鈕
            [self type6CreaterWithDict:dict];
            break;
        case 7:
            // 獲取機房 1個label 1個textFiled 1個按鈕
            [self type7CreaterWithDict:dict];
            break;
        case 8:
            // 獲取維護區域 1個label 1個textFiled 1個按鈕
            [self type8CreaterWithDict:dict];
            break;
        case 9:
            // 復合名稱 一個名稱 一個序號 合起來是sub名稱
            [self type9CreaterWithDict:dict];
            break;
        case 10:
            // 日期 , 時 分 秒
            [self type10CreaterWithDict:dict];
            break;
        case 11:
            // 起始设备、终止设备
            [self type11CreaterWithDict:dict];
            break;
        case 13:
            // 袁全新增 , 查询新模板接口 , 暂时用于维护单位
            [self type13CreaterWithDict:dict];
            break;
        case 50:
            // 命名
            [self type50CreaterWithDict:dict];
            break;
        case 51:
            // 穿缆
            [self type51CreaterWithDict:dict];
            break;
        case 52:
            // 扫描二维码
            [self type52CreaterWithDict:dict];
            break;
        default:
            break;
    }
}



#pragma mark 获取contentView的最大Y坐标 -- 更新Y坐标
-(CGFloat)getNewY{
    // 初始化变量
    CGFloat maxY = 0.0;
    for (__kindof UIView * tmpView in self.contentView.subviews) {
        // 遍历子视图，获取最大的Y
        if (tmpView.tag >= nDefaultNormalTag) {
            if (CGRectGetMaxY(tmpView.frame) > maxY) {
                maxY = CGRectGetMaxY(tmpView.frame) + 5;
            }
        }
    }
    return maxY;
}
#pragma mark 以字体及文本获取view的size
-(CGSize)sizeWithString:(NSString *)string withFont:(UIFont *)font{
    return [string boundingRectWithSize:CGSizeMake(self.contentView.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}
#pragma mark 创建type11的标签
-(void)createAType11Label:(NSString *)title withMode:(IWPViewModel *)model{
    xTYK = marginTYK / 2.f;
    wTYK = self.contentView.frame.size.width - marginTYK;
    hTYK = 30.f;
    yTYK = [self getNewY];
    IWPLabel * label = [[IWPLabel alloc] initWithFrame:CGRectMake(xTYK,yTYK,wTYK,hTYK)];
    label.tag = tagTYK++;
    label.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    label.text = model.tv1_Required.integerValue > 0 ? [NSString stringWithFormat:@"*%@",title] : title;
    label.textColor = model.tv1_Required.integerValue > 0 ? Color_V2Red:[UIColor blackColor];
    label.font = [UIFont systemFontOfSize:18.f];
    label.backgroundColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    label.key = model.name1;
    
    CGRect frame = label.frame;
    frame.size = CGSizeMake(wTYK, [label.text boundingRectWithSize:CGSizeMake(wTYK, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil].size.height);
    label.frame = frame;
    [self.contentView addSubview:label];
    if (model.tv1_Required.intValue < 1) {
        label.hidden = YES;
    }
    //如果中心不给发这个字段，则不显示
//    if (self.requestDict[model.name1] == nil&& (self.controlMode != TYKDeviceListInsert) && (self.controlMode != TYKDeviceListInsertRfid)) {
//        [label removeFromSuperview];
//    }
}
#pragma mark 创建普通typeView的标签
-(void)createALabel:(IWPViewModel *)model{
    xTYK = marginTYK / 2.f;
    wTYK = self.contentView.frame.size.width - marginTYK;
    hTYK = 30.f;
    yTYK = [self getNewY];
    
    IWPLabel * label = [[IWPLabel alloc] initWithFrame:CGRectMake(xTYK,yTYK,wTYK,hTYK)];
    label.tag = tagTYK++;
    label.hiddenTag = model.tv1_Required.integerValue > 0 || [model.tv1_Text isEqualToString:@"扩充后缀"] ? 0 : hidenTagTYK++;
    label.font = [UIFont systemFontOfSize:18.f];
    label.backgroundColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    label.key = model.name1;
    
    if (model.tv1_Required.intValue > 0) {
        label.text = [NSString stringWithFormat:@"*%@",model.tv1_Text];
        label.textColor = Color_V2Red;
    }else{
        label.text = model.tv1_Text;
        label.textColor = [UIColor blackColor];
    }
    
    
    if (model.tv1_Required.intValue == 0 && ![model.tv1_Text isEqualToString:@"扩充后缀"]) {
        label.hidden = YES;
    }
    
    
    
    CGRect frame = label.frame;
    frame.size = CGSizeMake(wTYK, [label.text boundingRectWithSize:CGSizeMake(wTYK, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil].size.height);
    label.frame = frame;
    if ([model.tv1_Text isEqualToString:@"管道名称"]||[model.tv1_Text isEqualToString:@"杆路名称"]) {
        return;
    }
    [self.contentView addSubview:label];
    //如果中心不给发这个字段，则不显示
//    if ((self.requestDict[model.name1] == nil)&&(![model.name1 isEqualToString:@"rfid"]) && (self.controlMode != TYKDeviceListInsert)&& (self.controlMode != TYKDeviceListInsertRfid)) {
//        [label removeFromSuperview];
//    }
}
#pragma mark 创建普通typeView的标签
-(void)createBLabel:(IWPViewModel *)model{
    xTYK = marginTYK / 2.f;
    wTYK = self.contentView.frame.size.width - marginTYK;
    hTYK = 30.f;
    yTYK = [self getNewY];
    
    IWPLabel * label = [[IWPLabel alloc] initWithFrame:CGRectMake(xTYK,yTYK,wTYK,hTYK)];
    label.tag = tagTYK++;
    label.hiddenTag = model.tv1_Required.integerValue > 0 || [model.tv1_Text isEqualToString:@"扩充后缀"] ? 0 : hidenTagTYK++;
    label.font = [UIFont systemFontOfSize:18.f];
    label.backgroundColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    label.key = model.name1;
    
    if (model.tv1_Required.intValue > 0) {
        label.text = [NSString stringWithFormat:@"*%@",model.tv1_Text];
        label.textColor = Color_V2Red;
    }else{
        label.text = model.tv1_Text;
        label.textColor = [UIColor blackColor];
    }
    
    
    if (model.tv1_Required.intValue == 0 && ![model.tv1_Text isEqualToString:@"扩充后缀"]) {
        label.hidden = YES;
    }
    
    
    
    CGRect frame = label.frame;
    frame.size = CGSizeMake(wTYK, [label.text boundingRectWithSize:CGSizeMake(wTYK, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil].size.height);
    label.frame = frame;
    if ([model.tv1_Text isEqualToString:@"管道名称"]||[model.tv1_Text isEqualToString:@"杆路名称"]) {
        return;
    }
    [self.contentView addSubview:label];
}
#pragma mark 获取最小x坐标
-(CGFloat)getMinXWithTag:(NSUInteger)tag{
    return CGRectGetMinX([[self.contentView viewWithTag:tag] frame]);
}
#pragma mark 内存警告
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 创建穿缆数据源
-(void)createListDataSource{
    [self.listDataSource removeAllObjects];
    [self.listDataFrameModel removeAllObjects];
    
    
    NSArray * names = [self.requestDict[kCableMainName] componentsSeparatedByString:@","];
    NSArray * ids = [self.requestDict[kCableMainId] componentsSeparatedByString:@","];
    NSArray * rfids = [self.requestDict[kCableMainRfid] componentsSeparatedByString:@","];
    
    if (rfids.count == 0 && ids.count > 0) {
        // 舊資源可能會有未綁定rfid
        NSMutableArray * reCreateRfidArr = [NSMutableArray array];
        for (int i = 0; i < ids.count; i++) {
            if ([ids[i] length] > 0) {
                [reCreateRfidArr addObject:@" "];
            }
        }
        rfids = nil;
        rfids = [NSArray arrayWithArray:reCreateRfidArr];
        NSString * str = [self pieceTogetherObjectsWithArray:rfids];
        [self.requestDict setValue:str forKey:kCableMainRfid];
    }
    
    
    NSMutableArray * listFrameModel = [NSMutableArray array];
    
    for (int i = 0; i < names.count; i++ ) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        if ([names[i] length] > 0) {
            [dict setValue:names[i] forKey:kCableName];
            [dict setValue:ids[i] forKey:kCableId];
            [dict setValue:rfids[i] forKey:kCableRfid];
            [self.listDataSource addObject:dict];
            
            IWPRfidInfoModel * model = [IWPRfidInfoModel modelWithDict:dict];
            IWPRfidInfoFrameModel * frameModel = [[IWPRfidInfoFrameModel alloc] init];
            frameModel.model = model;
            
            [listFrameModel addObject:frameModel];
            
            
        }
        
    }
    
    self.listDataFrameModel = [NSMutableArray arrayWithArray:listFrameModel];
    
    [self.listView reloadData];
    
    
}
#pragma mark - typeView实际创建方法
#pragma mark type1View
-(void)type1CreaterWithDict:(IWPViewModel *)model{
    // 是名称前缀则不创建
    if ([model.tv1_Text isEqualToString:@"名称前缀"] && [model.name1 isEqualToString:@"preName"]) {
        return;
    }
    
    // 默认格式创建label
    [self createALabel:model];
    
    
    yTYK = [self getNewY];
    wTYK = self.contentView.frame.size.width - marginTYK;
    hTYK = 40.f;
    
    IWPTextView * textView = [[IWPTextView alloc] initWithFrame:CGRectMake(xTYK,yTYK,wTYK,hTYK)];
    // 設置代理
    textView.delegate = self;
    textView.tag = tagTYK++;
    textView.placeholder = model.tv1_Text;
    textView.hintString = model.ed1_Hint;
    textView.hiddenTag = model.tv1_Required.integerValue > 0 || [model.tv1_Text isEqualToString:@"扩充后缀"] ? 0 : hidenTagTYK++;
    textView.backgroundColor = [UIColor whiteColor];

    textView.text = [Yuan_Foundation fromObject:self.requestDict[model.name1] ?: @""];
    textView.key = model.name1;
    textView.returnKeyType = UIReturnKeyDone;
    
    textView.shouldEdit = model.ed1_Ed.intValue == 1;
    
    textView.font = [UIFont systemFontOfSize:17];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = .5f;
    textView.layer.cornerRadius = 5.f;
    textView.layer.masksToBounds = YES;
    
    if (model.tv1_Required.intValue < 1 && ![model.tv1_Text isEqualToString:@"扩充后缀"]) {
        textView.hidden = YES;
    }
    if ([model.tv1_Text isEqualToString:@"管道名称"]||[model.tv1_Text isEqualToString:@"杆路名称"]) {
        return;
    }
    [self.contentView addSubview:textView];
//    //如果中心不给发这个字段，则不显示
//    if (self.requestDict[model.name1] == nil && (self.controlMode != TYKDeviceListInsert) && (self.controlMode != TYKDeviceListInsertRfid)) {
//        textView.hidden = YES;
//        [textView removeFromSuperview];
//    }
}
#pragma mark type2View
-(void)type2CreaterWithDict:(IWPViewModel *)model{
    
    [self createALabel:model];
    
    yTYK = [self getNewY];
    hTYK = 40.f;
    IWPButton * button = [IWPButton buttonWithType:UIButtonTypeCustom];
    button.buttontype = IWPButtonTypeSpecial;
    button.frame = CGRectMake(xTYK, yTYK, wTYK, hTYK);
    button.tag = tagTYK++;
    button.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    // button 暫時處理為默認顯示當前日期;
    // button和textFiled設為同一外觀
    button.layer.borderColor = [UIColor grayColor].CGColor;
    button.layer.borderWidth = .5f;
    button.layer.cornerRadius = 5.f;
    button.layer.masksToBounds = YES;
    button.userInteractionEnabled = model.ed1_Ed.integerValue == 1;
    NSString * btnTitle = [[StrUtil new] GMTToLocal:self.requestDict[model.name1]];
    
    if (btnTitle.length == 0) {
        btnTitle = @"请选择";
    }
    
    [button setTitle:btnTitle forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.key = model.name1;
    
    [button addTarget:self action:@selector(type2ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    if (model.tv1_Required.intValue < 1) {
        button.hidden = YES;
    }
    //如果中心不给发这个字段，则不显示
//    if (self.requestDict[model.name1] == nil && (self.controlMode != TYKDeviceListInsert) && (self.controlMode != TYKDeviceListInsertRfid)) {
//        button.hidden = YES;
//        [button removeFromSuperview];
//    }
}
#pragma mark type3View
-(void)type3CreaterWithDict:(IWPViewModel *)model{
    
    [self createALabel:model];
    yTYK = [self getNewY];
    hTYK = 40.f;
    IWPButton * button = [IWPButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(xTYK,yTYK,wTYK,hTYK);
    button.buttontype = IWPButtonTypeSpecial;
    // button和textFiled設為同一外觀
    button.tag = sp_indexTYK++;
    button.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    button.layer.borderColor = [UIColor grayColor].CGColor;
    button.layer.borderWidth = .5f;
    button.layer.cornerRadius = 5.f;
    button.layer.masksToBounds = YES;
    button.key = model.name1;
    
//    button.userInteractionEnabled = model.ed1_Ed.integerValue == 1;
    
    //    button.fileName = model.name3; // ??????????????
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(type3ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    // mntStateId 维护状态 oprStateId 业务状态  prorertyBelong产权归属   chanquanxz 产权性质
    button.titleLabel.font = Font_Yuan(14);
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    NSInteger sp_index = button.tag - 30000;
    NSInteger ro_index = [self.requestDict[model.name1] intValue];
    // selectedRow = ro_index;
    NSString * btnTitle = nil;
    @try {
        btnTitle = self.dataSource[sp_index][ro_index];
    } @catch (NSException *exception) {
        btnTitle = [NSString stringWithFormat:@"未知(%ld)", (long)ro_index];
    } @finally {
        
    }
    
    [button setTitle:btnTitle forState:UIControlStateNormal];
    if (model.tv1_Required.intValue < 1) {
        button.hidden = YES;
    }
    [self.contentView addSubview:button];
    
    NSLog(@"self.fileName:%@",self.fileName);
    NSLog(@"button.key:%@",button.key);
    if ([self.fileName isEqualToString:@"OBD_Equt"] && [button.key isEqualToString:@"lightFLThan"]) {
        button.userInteractionEnabled = NO;
    }
    
    
    
    UIImageView * img = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"yuanMB_xiala"]
                                           frame:CGRectNull];
    
    [button addSubview:img];
    
    [img YuanAttributeHorizontalToView:button];
    [img autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:marginTYK];
    
    
    
    
    //如果中心不给发这个字段，则不显示
//    if (self.requestDict[model.name1] == nil&& (self.controlMode != TYKDeviceListInsert) && (self.controlMode != TYKDeviceListInsertRfid)) {
//        button.hidden = YES;
//        [button removeFromSuperview];
//    }
}

#pragma mark type4View
-(void)type4CreaterWithDict:(IWPViewModel *)model{
    
    [self createALabel:model];
    yTYK = [self getNewY];
    hTYK = 40.f;
    CGFloat tmpW,tmpX;
    //    原来的
    //    tmpW = (ScreenWidth - 5 * margin - 5.f) / 2.f;
    //    tmpX = x;
    
    tmpW = self.contentView.frame.size.width - marginTYK;
    tmpX = xTYK;
    
    
    IWPTextView * lat_lonView = [[IWPTextView alloc] initWithFrame:CGRectMake(tmpX, yTYK, tmpW, hTYK)];
    lat_lonView.tag = tagTYK++;
    lonTagTYK = lat_lonView.tag;
    // 给新的赋值tag
    yuan_NewLatLonTag = lat_lonView.tag;
    
    lat_lonView.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    lat_lonView.hintString = @"经纬度";
    lat_lonView.backgroundColor = [UIColor whiteColor];
    lat_lonView.font = [UIFont systemFontOfSize:17];
    lat_lonView.layer.borderColor = [UIColor grayColor].CGColor;
    lat_lonView.layer.borderWidth = .5f;
    lat_lonView.layer.cornerRadius = 5.f;
    lat_lonView.delegate = self;
    lat_lonView.layer.masksToBounds = YES;
    lat_lonView.shouldEdit = model.ed1_Ed.intValue == 1 ? YES : NO;
    lat_lonView.returnKeyType = UIReturnKeyDone;
    [self.contentView addSubview:lat_lonView];
    
    // 有经纬度  才去
    if ([self.requestDict.allKeys containsObject:@"lat"] &&
        [self.requestDict.allKeys containsObject:@"lon"]) {
        
        // 顯示默認值  经纬度  lat / lon
        lat_lonView.text = [NSString stringWithFormat:@"%@/%@",
                            self.requestDict[model.name2],
                            self.requestDict[model.name1]];
    }
    
    
    lat_lonView.layer.borderColor = [UIColor grayColor].CGColor;
    lat_lonView.layer.borderWidth = .5f;
    lat_lonView.layer.cornerRadius = 5.f;
    lat_lonView.layer.masksToBounds = YES;
    
    
    //    latitudeTV.userInteractionEnabled = NO;
    //    longitudeTV.userInteractionEnabled = NO;
    lat_lonView.type = model.type.integerValue;
    
    
    
    
    
    IWPButton * getButton = [IWPButton buttonWithType:UIButtonTypeSystem];
    getButton.tag = tagTYK++;
    getButton.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    getButton.fileName = model.name3;
    [getButton addTarget:self action:@selector(type4ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [getButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getButton setTitle:model.btn1_text forState:UIControlStateNormal];
    [getButton setBackgroundColor:[UIColor mainColor]];
    [lat_lonView addSubview:getButton];
    
    CGRect getBtnFrame =  CGRectMake(CGRectGetMaxX(lat_lonView.frame) - Horizontal(50) - marginTYK, 5, Horizontal(50), Vertical(30));
    
    getButton.frame = getBtnFrame;
    
    
//    [getButton YuanAttributeHorizontalToView:getButton.superview];
//    [getButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:50];
//    [getButton autoSetDimension:ALDimensionWidth toSize:Horizontal(50)];
    
    
    if (model.tv1_Required.intValue != 1) {
//        latitudeTV.hidden = YES;
        lat_lonView.hidden = YES;
//        getButton.hidden = YES;
    }

}
#pragma mark type5View
-(void)type5CreaterWithDict:(IWPViewModel *)model{
    
    [self createALabel:model];
    
    CGFloat tmpW,tmpX,tmpH,tmpY;
    hTYK = 40.f;
    
    tmpW = self.contentView.frame.size.width - marginTYK;
    tmpX = xTYK;
    yTYK = [self getNewY];
    IWPTextView * textView = [[IWPTextView alloc] initWithFrame:CGRectMake(tmpX, yTYK, tmpW, hTYK)];
    textView.tag = tagTYK++;
    yuan_AddrTag = textView.tag;
    textView.delegate = self;
    textView.placeholder = model.tv1_Text;
    textView.hintString = model.ed1_Hint;
    textView.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    textView.font = [UIFont systemFontOfSize:17];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = .5f;
    textView.layer.cornerRadius = 5.f;
    textView.layer.masksToBounds = YES;
    textView.returnKeyType = UIReturnKeyDone;
    textView.text = self.requestDict[model.name1];
    textView.key = model.name1;
    textView.shouldEdit = model.ed1_Ed.intValue == 1;
    
    [self.contentView addSubview:textView];
    
    
    if (textView.text.length > 20) {
        NSMutableString * newStr = [NSMutableString stringWithString:textView.text];
        [newStr insertString:@"\n" atIndex:18];
        textView.text = newStr;
    }
    
    IWPButton * getButton = [IWPButton buttonWithType:UIButtonTypeSystem];
    getButton.tag = tagTYK++;
    addrBtnTagTYK = getButton.tag;
    getButton.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    getButton.fileName = model.name3;
    [getButton addTarget:self action:@selector(type5ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect getBtnFrame =  CGRectMake(CGRectGetMaxX(textView.frame) - Horizontal(50) - marginTYK, 5, Horizontal(50), Vertical(30));
    
    getButton.frame = getBtnFrame;
    
    [getButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getButton setTitle:model.btn1_text forState:UIControlStateNormal];
    [getButton setBackgroundColor:[UIColor mainColor]];
    [textView addSubview:getButton];
    getButton.key = model.name1;
    
    if (model.tv1_Required.intValue < 1) {
        textView.hidden = YES;
//        getButton.hidden = YES;
    }
    
    
    //如果中心不给发这个字段，则不显示
//    if (self.requestDict[model.name1] == nil&& (self.controlMode != TYKDeviceListInsert) && (self.controlMode != TYKDeviceListInsertRfid)) {
//        [textView removeFromSuperview];
//        [getButton removeFromSuperview];
//    }
}
#pragma mark type6View
-(void)type6CreaterWithDict:(IWPViewModel *)model{
    
    
    if ([_fileName isEqualToString:@"OBDPoint"] && [self.equDic[@"parentEType"] isEqualToString:@"OCC_Equt"]) {
        if ([model.name1 isEqualToString:@"ssRoom"]) {
            return;
        }
    }
    
    [self createALabel:model];
    CGFloat tmpW,tmpX;
    hTYK = 40.f;
    
    tmpW = self.contentView.frame.size.width - marginTYK;
    tmpX = xTYK;
    yTYK = [self getNewY];
    IWPTextView * textView = [[IWPTextView alloc] initWithFrame:CGRectMake(tmpX, yTYK, tmpW, hTYK)];
    textView.tag = tagTYK++;
    textView.delegate = self;
    textView.hintString = model.ed1_Hint.length > 0?model.tv1_Text:@"请获取";
    textView.placeholder = model.tv1_Text;
    
    textView.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    textView.font = [UIFont systemFontOfSize:17];
    textView.backgroundColor = [UIColor whiteColor];
    textView.text = self.requestDict[model.name1];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = .5f;
    textView.layer.cornerRadius = 5.f;
    textView.layer.masksToBounds = YES;
    textView.returnKeyType = UIReturnKeyDone;
    
    
    if ([model.name1 isEqualToString:@"ssmarkStoneP"] &&
        [model.name2 isEqualToString:@"markStonePathId"] &&
        [model.name3 isEqualToString:@"markStonePath"] &&
        [model.name4 isEqualToString:@"markStonePName"]) {
        
        model.name2 = @"markStonePathId";
        model.name3 = @"markStonePath";

    }
    
    textView.key = model.name1;
    textView.name2 = model.name2;
    textView.name3 = model.name3;
    textView.name4 = model.name4;
    //    textView.shouldEdit = model.ed1_Ed.intValue == 1 ? YES : NO;
    textView.shouldEdit = NO;
    [self.contentView addSubview:textView];
    
    tmpX = CGRectGetMaxX(textView.frame) + marginTYK / 2.f;
    tmpW = self.contentView.frame.size.width - tmpX - marginTYK / 2.f;
    
    
    IWPButton * getButton = [IWPButton buttonWithType:UIButtonTypeSystem];
    getButton.tag = tagTYK++;
    getButton.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    [getButton addTarget:self action:@selector(type6ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    getButton.fileName = model.name3;
    getButton.key = model.name4;
    getButton.idKey = [NSString stringWithFormat:@"%@_Id",model.name1];
    getButton.name2 = model.name2;
//    getButton.frame = CGRectMake(tmpX, tmpY, tmpW, tmpH);
    
    CGRect getBtnFrame =  CGRectMake(CGRectGetMaxX(textView.frame) - Horizontal(50) - marginTYK, 5, Horizontal(50), Vertical(30));
    
    getButton.frame = getBtnFrame;
    
    [getButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getButton setTitle:model.btn1_text forState:UIControlStateNormal];
    [getButton setBackgroundColor:[UIColor mainColor]];
    [textView addSubview:getButton];
    if (model.tv1_Required.intValue < 1) {
        textView.hidden = YES;
//        getButton.hidden = YES;
    }
    //如果中心不给发这个字段，则不显示
//    if (self.requestDict[model.name1] == nil&& (self.controlMode != TYKDeviceListInsert) && (self.controlMode != TYKDeviceListInsertRfid)) {
//        [textView removeFromSuperview];
//        [getButton removeFromSuperview];
//    }
}
#pragma mark type7View
-(void)type7CreaterWithDict:(IWPViewModel *)model{
    [self createALabel:model];
    CGFloat tmpW,tmpX;
    hTYK = 40.f;
    tmpW = (self.contentView.frame.size.width - 10 * marginTYK - 5.f) ;
    tmpX = xTYK;
    yTYK = [self getNewY];
    IWPTextView * textView = [[IWPTextView alloc] initWithFrame:CGRectMake(tmpX, yTYK, tmpW, hTYK)];
    textView.tag = tagTYK++;
    textView.delegate = self;
    textView.placeholder = model.tv1_Text;
    textView.hintString = model.ed1_Hint;
    textView.font = [UIFont systemFontOfSize:17.f];
    textView.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    textView.backgroundColor = [UIColor whiteColor];
    textView.text = self.requestDict[model.name1];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = .5f;
    textView.layer.cornerRadius = 5.f;
    textView.layer.masksToBounds = YES;
    textView.returnKeyType = UIReturnKeyDone;
    textView.key = model.name1;
    textView.shouldEdit = NO;
    [self.contentView addSubview:textView];
    
    tmpX = CGRectGetMaxX(textView.frame) + marginTYK / 2.f;
    tmpW = self.contentView.frame.size.width - tmpX - marginTYK;
    IWPButton * getButton = [IWPButton buttonWithType:UIButtonTypeSystem];
    getButton.tag = tagTYK++;
    getButton.fileName = model.name3;
    getButton.key = model.name1;
    getButton.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    getButton.frame = CGRectMake(tmpX, yTYK, tmpW, hTYK);
    [getButton addTarget:self action:@selector(type7ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [getButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getButton setTitle:model.btn1_text forState:UIControlStateNormal];
    [getButton setBackgroundColor:[UIColor mainColor]];
    [self.contentView addSubview:getButton];
    if (model.tv1_Required.intValue < 1) {
        textView.hidden = YES;
        getButton.hidden = YES;
    }
    //如果中心不给发这个字段，则不显示
//    if (self.requestDict[model.name1] == nil&& (self.controlMode != TYKDeviceListInsert) && (self.controlMode != TYKDeviceListInsertRfid)) {
//        [textView removeFromSuperview];
//        [getButton removeFromSuperview];
//    }
}
#pragma mark type8View
-(void)type8CreaterWithDict:(IWPViewModel *)model{
    [self createALabel:model];
    CGFloat tmpW,tmpX;
    hTYK = 40.f;
    tmpW = self.contentView.frame.size.width - marginTYK;
    tmpX = xTYK;
    yTYK = [self getNewY];
    IWPTextView * textView = [[IWPTextView alloc] initWithFrame:CGRectMake(tmpX, yTYK, tmpW, hTYK)];
    textView.tag = tagTYK++;
    textView.delegate = self;
    textView.key = model.name1;
    textView.hintString = @"请选择";
    textView.placeholder = model.tv1_Text;
    textView.font = [UIFont systemFontOfSize:17];
    textView.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = .5f;
    textView.layer.cornerRadius = 5.f;
    textView.layer.masksToBounds = YES;
    textView.text = self.requestDict[model.name1];
    textView.returnKeyType = UIReturnKeyDone;
    textView.shouldEdit = model.ed1_Ed.integerValue == 1;
    [self.contentView addSubview:textView];
    
    
    
    IWPButton * getButton = [IWPButton buttonWithType:UIButtonTypeSystem];
    getButton.tag = tagTYK++;
    getButton.fileName = model.name3;
    getButton.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    
    CGRect getBtnFrame =  CGRectMake(CGRectGetMaxX(textView.frame) - Horizontal(50) - marginTYK, 5, Horizontal(50), Vertical(30));
    
    getButton.frame = getBtnFrame;
    
    [getButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getButton setTitle:model.btn1_text forState:UIControlStateNormal];
    [getButton setBackgroundColor:[UIColor mainColor]];
    [getButton addTarget:self action:@selector(type8ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [textView addSubview:getButton];
    
    if (model.tv1_Required.intValue < 1) {
        textView.hidden = YES;
//        getButton.hidden = YES;
    }
    //如果中心不给发这个字段，则不显示
//    if (self.requestDict[model.name1] == nil&& (self.controlMode != TYKDeviceListInsert) && (self.controlMode != TYKDeviceListInsertRfid)) {
//        [textView removeFromSuperview];
//        [getButton removeFromSuperview];
//    }
}
#pragma mark type9View
-(void)type9CreaterWithDict:(IWPViewModel *)model{
    
    NSLog(@"=-=-=-=-%@-=-=-=-=",self.viewModel[self.viewModel.count - 2]);
    
    //    [self type1CreaterWithDict:dict]; // 临时调用type1测试
    [self createBLabel:model];
    xTYK = marginTYK / 2.f;
    yTYK = [self getNewY];
    wTYK = self.contentView.frame.size.width - marginTYK;
    hTYK = 40.f;
    IWPTextView * textView = [[IWPTextView alloc] initWithFrame:CGRectMake(xTYK,yTYK,wTYK,hTYK)];
    textView.tag = ++type9TagTYK;
    //    textView.userInteractionEnabled = NO;
    textView.hintString = model.ed1_Hint;
    textView.delegate = self;
    textView.placeholder = model.tv1_Text;
    textView.key = model.name1;
    textView.isType9 = YES;
    textView.font = [UIFont systemFontOfSize:17];
    //    textView.tag = tag++;
    textView.hintString = model.ed1_Hint;
    textView.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = .5f;
    textView.layer.cornerRadius = 5.f;
    textView.layer.masksToBounds = YES;
    textView.returnKeyType = UIReturnKeyDone;
    textView.text = self.requestDict[model.name1];
    textView.shouldEdit = model.ed1_Ed.intValue == 1 ? YES : NO;
    
    
    
    [self.contentView addSubview:textView];
    
    NSInteger index = 0;
    yTYK = [self getNewY] + marginTYK / 2.F;
    hTYK = 30;
    wTYK /= 4.f;
    NSInteger tag = 938000;
    if ([self.fileName isEqualToString:@"pole"]) {
        // MARK: 袁全修改 -- 把'获取'注释掉 原因是 模板改为 UNI_ 后数据不全
  
    }

}
#pragma mark type10View
-(void)type10CreaterWithDict:(IWPViewModel *)model{
    
    [self createALabel:model];
    
    yTYK = [self getNewY];
    hTYK = 40.f;
    IWPButton * button = [IWPButton buttonWithType:UIButtonTypeCustom];
    button.buttontype = IWPButtonTypeSpecial;
    button.frame = CGRectMake(xTYK, yTYK, wTYK, hTYK);
    button.tag = tagTYK++;
    button.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    // button 暫時處理為默認顯示當前日期;
    // button和textFiled設為同一外觀
    button.layer.borderColor = [UIColor grayColor].CGColor;
    button.layer.borderWidth = .5f;
    button.layer.cornerRadius = 5.f;
    button.layer.masksToBounds = YES;
    button.userInteractionEnabled = model.ed1_Ed.integerValue == 1;
    NSString * btnTitle = [[StrUtil new] GMTToLocalWithSecond:self.requestDict[model.name1]];
    if (btnTitle.length == 0) {
        btnTitle = @"请选择";
    }
    
    button.titleLabel.font = Font_Yuan(14);
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    [button setTitle:btnTitle forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.key = model.name1;
    
    [button addTarget:self action:@selector(type10ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    if (model.tv1_Required.intValue < 1) {
        button.hidden = YES;
    }
    
    
    UIImageView * img = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"yuanMB_xiala"]
                                           frame:CGRectNull];
    
    [button addSubview:img];
    
    [img YuanAttributeHorizontalToView:button];
    [img autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:marginTYK];
    
}


#pragma mark type11View
-(void)type11CreaterWithDict:(IWPViewModel *)model{
    
    [self createAType11Label:model.text1 withMode:model];
    
    // type11, 獲取起始、終止設備後，讀取傳回字典所需字段的key
    
    // "temp_text":"||,ODF_Equt|ODF_EqutId|rackName,joint|jointId|jointName,OCC_Equt|OCC_EqutId|occName,ODB_Equt|ODB_EqutId|odbName,markStone|markStoneId|markName"
    NSMutableArray * temp = [[model.temp_text componentsSeparatedByString:@","] mutableCopy];
    [temp removeObjectAtIndex:0]; // 把｜｜去掉
    
    NSMutableArray * keys = [NSMutableArray array];
    
    for (NSString * str in temp) {
        if (str.length == 0) {
            continue;
        }
        NSArray * arr = [str componentsSeparatedByString:@"|"];
        [keys addObject:arr];
    }
    
    NSArray * dictKeys = @[@"type",@"deviceId",@"deviceName"];
    
    NSMutableArray * type11Name4 = [NSMutableArray array];
    for (NSArray * arr in keys) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        NSInteger index = 0;
        for (NSString * str in arr) {
            [dict setValue:str forKey:dictKeys[index]];
            index++;
        }
        [type11Name4 addObject:dict];
    }
    
    //    NSLog(@"%@",type11Name4);
    self.getFileNames = type11Name4;
    
    yTYK = [self getNewY];
    hTYK = 40.f;
    IWPButton * button = [IWPButton buttonWithType:UIButtonTypeCustom];
    button.buttontype = IWPButtonTypeSpecial;
    button.frame = CGRectMake(xTYK,yTYK,wTYK,hTYK);
    
    // button和textFiled設為同一外觀
    button.tag = sp_indexTYK++;
    button.t11Tag = tagTYK++;
    button.type11Tag = type11TagTYK++;
    button.hiddenTag = model.tv1_Required.intValue > 0 ? 0 : hidenTagTYK++;
    button.layer.borderColor = [UIColor grayColor].CGColor;
    button.layer.borderWidth = .5f;
    button.layer.cornerRadius = 5.f;
    button.layer.masksToBounds = YES;
    button.key = model.name1;
    button.type = model.type;
    button.userInteractionEnabled = model.ed1_Ed.integerValue == 1;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(type3ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    NSInteger sp_index = button.tag - 30000;
    
    NSInteger ro_index = [self.requestDict[model.name1] intValue];
    
    if ([model.name1 rangeOfString:@"End"].length > 0 || [model.name1 rangeOfString:@"end"].length > 0) {
        endDeviceRotTYK = ro_index;
        type11AlreadySelectedEndRowTYK = ro_index;
    }
    
    if ([model.name1 rangeOfString:@"Start"].length > 0 || [model.name1 rangeOfString:@"start"].length > 0) {
        startDeviceRowTYK = ro_index;
        type11AlreadySelectedStartRowTYK = ro_index;
    }
    if ([model.name1 rangeOfString:@"Start"].length == 0 && [model.name1 rangeOfString:@"start"].length == 0) {
        deviceRow = ro_index;
    }
    
    [button setTitle:self.dataSource[sp_index][ro_index] forState:UIControlStateNormal];
    if (model.tv1_Required.intValue < 1) {
        button.hidden = YES;
    }
    [self.contentView addSubview:button];
    
    
    // 新增
    button.titleLabel.font = Font_Yuan(14);
    UIImageView * img = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"yuanMB_xiala"]
                                           frame:CGRectNull];
    
    [button addSubview:img];
    
    [img YuanAttributeHorizontalToView:button];
    [img autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:marginTYK];
    
    
    
    
    [self createAType11Label:model.text2 withMode:model];
    
    yTYK = [self getNewY];
    
    CGFloat tmpW,tmpX;
    hTYK = 40.f;
    tmpW = self.contentView.frame.size.width - marginTYK;
    tmpX = xTYK;
    yTYK = [self getNewY];
    IWPTextView * textView = [[IWPTextView alloc] initWithFrame:CGRectMake(tmpX, yTYK, tmpW, hTYK)];
    textView.tag = tagTYK++;
    textView.delegate = self;
    textView.hintString = @"请选择类型后获取";
    textView.placeholder = model.text2;
    textView.key = model.name1;
    textView.type11Tag = type11TagTYK++;
    textView.font = [UIFont systemFontOfSize:17];
    textView.hiddenTag = model.tv1_Required.intValue > 0 ? 0 : hidenTagTYK++;
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = .5f;
    textView.layer.cornerRadius = 5.f;
    textView.layer.masksToBounds = YES;
    textView.text = self.requestDict[model.name2];
    textView.returnKeyType = UIReturnKeyDone;
    textView.isType11 = YES;
    textView.shouldEdit = NO;
    textView.name2 = model.name2;
    textView.name3 = model.name3;
    textView.name4 = model.name4;
    //    textView.shouldEdit = model.ed1_Ed.intValue == 1 ? YES : NO;
    [self.contentView addSubview:textView];
    
    CGFloat tmpH = hTYK - marginTYK / 2.f, tmpY = CGRectGetMinY(textView.frame) + marginTYK / 4.f;
    tmpX = CGRectGetMaxX(textView.frame) + marginTYK / 2.f;
    tmpW = ScreenWidth - tmpX - marginTYK / 2.f;
    IWPButton * getButton = [IWPButton buttonWithType:UIButtonTypeSystem];
    getButton.tag = tagTYK++;
    
    
    
    NSMutableArray * arr = [[model.temp_text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"|,"]] mutableCopy];
    
    NSInteger index = 0;
    
    for (int i = 0 ; i < 2; i++) {
        for (index = 0; index < arr.count; index++) {
            if ([arr[index] isEqualToString:@"(null)"] || [arr[index] isEqualToString:@""]) {
                [arr removeObjectAtIndex:index];
            }
        }
    }
    //    NSLog(@"%@",arr);
    
//    if (arr.count == 0 ) {
//        alert(@"模板数据缺少 _temp_text");
//        return;
//    }
    getButton.fileName = arr.count > 0 ? arr[0] : @"";
    getButton.name2 = arr.count > 1 ? arr[1] : @"";
    getButton.idKey = model.name3;
    getButton.key = arr.count > 2 ? arr[2] : @"";
    getButton.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
//    getButton.frame = CGRectMake(tmpX, tmpY, tmpW, tmpH);
    
    CGRect getBtnFrame =  CGRectMake(CGRectGetMaxX(textView.frame) - Horizontal(50) - marginTYK, 5, Horizontal(50), Vertical(30));
    
    getButton.frame = getBtnFrame;
    
    [getButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getButton setTitle:model.btn1_text forState:UIControlStateNormal];
    [getButton setBackgroundColor:[UIColor mainColor]];
    [getButton addTarget:self action:@selector(type11ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [textView addSubview:getButton];
    
    if (model.tv1_Required.intValue < 1) {
        textView.hidden = YES;
//        getButton.hidden = YES;
    }
    
    
    if ([self.fileName isEqualToString:@"OBD_Equt"]) {
        //分光器信息(不允许用户进行所属设施类型和所属设施的变更)
        if ([model.name1 isEqualToString:@"OBDssEqut_Type"]) {
            button.userInteractionEnabled = NO;
        }
        if ([model.name2 isEqualToString:@"OBDssEqut"]) {
            getButton.hidden = YES;
            [textView setFrame:CGRectMake(marginTYK/2, yTYK, ScreenWidth-marginTYK, hTYK)];
        }
    }
    //如果中心不给发这个字段，则不显示
//    if (self.requestDict[model.name1] == nil&& (self.controlMode != TYKDeviceListInsert) && (self.controlMode != TYKDeviceListInsertRfid)) {
//        [button removeFromSuperview];
//        [textView removeFromSuperview];
//        [getButton removeFromSuperview];
//    }
    
    
}


#pragma mark type13View
-(void)type13CreaterWithDict:(IWPViewModel *)model{
    [self createALabel:model];
    CGFloat tmpW,tmpX;
    hTYK = 40.f;
    tmpW = self.contentView.frame.size.width - marginTYK;
    tmpX = xTYK;
    yTYK = [self getNewY];
    IWPTextView * textView = [[IWPTextView alloc] initWithFrame:CGRectMake(tmpX, yTYK, tmpW, hTYK)];
    textView.tag = tagTYK++;
    textView.delegate = self;
    textView.key = model.name1;
    textView.hintString = @"请选择";
    textView.placeholder = model.tv1_Text;
    textView.font = [UIFont systemFontOfSize:17];
    textView.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = .5f;
    textView.layer.cornerRadius = 5.f;
    textView.layer.masksToBounds = YES;
    textView.text = self.requestDict[model.name1];
    textView.returnKeyType = UIReturnKeyDone;
    textView.shouldEdit = model.ed1_Ed.integerValue == 1;
    [self.contentView addSubview:textView];
    
    
    
    IWPButton * getButton = [IWPButton buttonWithType:UIButtonTypeSystem];
    getButton.tag = tagTYK++;
    getButton.fileName = model.name3;
    getButton.hiddenTag = model.tv1_Required.integerValue > 0 ? 0 : hidenTagTYK++;
    
    CGRect getBtnFrame =  CGRectMake(CGRectGetMaxX(textView.frame) - Horizontal(50) - marginTYK, 5, Horizontal(50), Vertical(30));
    
    getButton.frame = getBtnFrame;
    
    [getButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getButton setTitle:model.btn1_text forState:UIControlStateNormal];
    [getButton setBackgroundColor:[UIColor mainColor]];
    [getButton addTarget:self action:@selector(type13ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [textView addSubview:getButton];
    
    if (model.tv1_Required.intValue < 1) {
        textView.hidden = YES;
//        getButton.hidden = YES;
    }
    //如果中心不给发这个字段，则不显示
//    if (self.requestDict[model.name1] == nil&& (self.controlMode != TYKDeviceListInsert) && (self.controlMode != TYKDeviceListInsertRfid)) {
//        [textView removeFromSuperview];
//        [getButton removeFromSuperview];
//    }
}


#pragma mark type50View
-(void)type50CreaterWithDict:(IWPViewModel *)dict{
    [self createALabel:dict];
    CGFloat tmpW,tmpX;
    hTYK = 40.f;
    tmpW = ScreenWidth * .75f;
    tmpX = xTYK;
    yTYK = [self getNewY];
    IWPTextView * textView = [[IWPTextView alloc] initWithFrame:CGRectMake(tmpX, yTYK, tmpW, hTYK)];
    textView.tag = tagTYK++;
    textView.delegate = self;
    textView.placeholder = dict.tv1_Text;
    textView.hintString = dict.ed1_Hint;
    textView.key = dict.name1;
    textView.type = 11;
    textView.font = [UIFont systemFontOfSize:17];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = .5f;
    textView.layer.cornerRadius = 5.f;
    textView.layer.masksToBounds = YES;
    textView.text = self.requestDict[dict.name1];
    textView.returnKeyType = UIReturnKeyDone;
    textView.shouldEdit = YES;
    
    [self.contentView addSubview:textView];
    
    CGFloat tmpH = hTYK - marginTYK / 2.f, tmpY = CGRectGetMinY(textView.frame) + marginTYK / 4.f;
    tmpX = CGRectGetMaxX(textView.frame) + marginTYK / 2.f;
    tmpW = ScreenWidth - tmpX - marginTYK / 2.f;
    IWPButton * getButton = [IWPButton buttonWithType:UIButtonTypeSystem];
    getButton.tag = tagTYK++;
    getButton.frame = CGRectMake(tmpX, tmpY, tmpW, tmpH);
    
    [getButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getButton setTitle:dict.btn1_text forState:UIControlStateNormal];
    [getButton setBackgroundColor:[UIColor mainColor]];
    [getButton addTarget:self action:@selector(type50ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:getButton];
    //如果中心不给发这个字段，则不显示
//    if (self.requestDict[dict.name1] == nil&& (self.controlMode != TYKDeviceListInsert) && (self.controlMode != TYKDeviceListInsertRfid)) {
//        [textView removeFromSuperview];
//        [getButton removeFromSuperview];
//    }
}
#pragma mark type51View
-(void)type51CreaterWithDict:(IWPViewModel *)model{
    
    
    //    NSLog(@"self.list = %@",self.listDataSource);
    [self createListDataSource];
    
    [self createALabel:model];
    xTYK = marginTYK / 2.f;
    wTYK = ScreenWidth - marginTYK;
    hTYK = ScreenHeight / 4.f;
    yTYK = [self getNewY];
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(xTYK,yTYK,wTYK,hTYK) style:UITableViewStylePlain];
    //    tableView.hiddenTag = model.tv1_Required.intValue > 0 ? 0 : hidenTag++;
    self.listView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    [self.contentView addSubview:tableView];
    tableView.layer.borderWidth = .5f;
    tableView.layer.borderColor = [UIColor mainColor].CGColor;
    //    [tableView setSeparatorColor:[UIColor clearColor]];
    
    wTYK = ScreenWidth - marginTYK;
    hTYK = 49.f;
    yTYK = CGRectGetMaxY(tableView.frame) + marginTYK / 2.f;
    xTYK = (self.contentView.bounds.size.width - wTYK ) / 2.f;
    
    IWPButton * getButton = [IWPButton buttonWithType:UIButtonTypeSystem];
    getButton.tag = tagTYK++;
    getButton.frame = CGRectMake(xTYK,yTYK,wTYK,hTYK);
    getButton.hiddenTag = model.tv1_Required.intValue > 0 ? 0 : hidenTagTYK++;
    getButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [getButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getButton setTitle:model.btn1_text forState:UIControlStateNormal];
    [getButton setBackgroundColor:[UIColor mainColor]];
    [getButton addTarget:self action:@selector(type51ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:getButton];
    if (model.tv1_Required.intValue < 1) {
        tableView.hidden = YES;
        getButton.hidden = YES;
    }
    //如果中心不给发这个字段，则不显示
//    if (self.requestDict[model.name1] == nil&& (self.controlMode != TYKDeviceListInsert) && (self.controlMode != TYKDeviceListInsertRfid)) {
//        [tableView removeFromSuperview];
//        [getButton removeFromSuperview];
//    }
    //    [self.listView reloadData];
}
#pragma mark type52View
-(void)type52CreaterWithDict:(IWPViewModel *)dict{
    
    [self createALabel:dict];
    CGFloat x = 0, y = 0, w = 0, h = 0;
    
    x = marginTYK / 2.f;
    y = [self getNewY];
//    w = self.contentView.frame.size.width * .75f;
    w = self.contentView.frame.size.width - marginTYK;
    h = Vertical(60);
    
    // 底图
    UIView * interContentView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [self.contentView addSubview:interContentView];
    interContentView.tag = 981273987;
    interContentView.layer.borderColor = [UIColor grayColor].CGColor;
    interContentView.layer.borderWidth = .5f;
    interContentView.layer.cornerRadius = 5.f;
    interContentView.layer.masksToBounds = YES;
    //    interContentView.backgroundColor = [UIColor getStochasticColor];
    
    
    
    x = y = 0;
    w -= 100.f;
    
    IWPTextView * textView = [[IWPTextView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [interContentView addSubview:textView];
    
    
    textView.tag = 9817278;
    textView.delegate = self;
    textView.font = [UIFont systemFontOfSize:18.f];
    textView.key = dict.name1;
    textView.hintString = dict.ed1_Hint;
    textView.placeholder = dict.tv1_Text;
    textView.backgroundColor = [UIColor whiteColor];
    textView.text = [self.requestDict[dict.name1] deleteZeroString];
    textView.returnKeyType = UIReturnKeyDone;
    textView.showsVerticalScrollIndicator = YES;
    textView.showsHorizontalScrollIndicator = NO;
    //    textView.shouldEdit = dict.ed1_Ed.intValue == 1 ? YES : NO;
    //由于目前需求为所有标签都能手填，暂时写死可以手动编辑
    textView.shouldEdit = YES;
    
    
    float saoBtnWidth = 50;
    
    /* 2017年03月10日 新增，二维码动态 */
    
    // 50 是给按钮留的
    w = h = interContentView.width - CGRectGetMaxX(textView.frame) - marginTYK  - 50;
    x = CGRectGetMaxX(textView.frame) + marginTYK / 4.f;
    y = (interContentView.height - h) / 2.f;
    
    UIButton * showZero = [UIButton buttonWithType:UIButtonTypeCustom];
    [interContentView addSubview:showZero];
    showZero.tag = 0xffff;
    showZero.backgroundColor = [UIColor whiteColor];
    showZero.layer.cornerRadius = h / 2.f;
    showZero.layer.masksToBounds = YES;
    //    showZero.layer.borderColor = [UIColor mainColor].CGColor;
    //    showZero.layer.borderWidth = .7f;
    
    showZero.frame = CGRectMake(x, y, w, h);
    
    //    [showZero setTitle:@"显示" forState:UIControlStateNormal];
    //    [showZero setTitle:@"隐藏" forState:UIControlStateSelected];
    
    [showZero setImage:[UIImage Inc_imageNamed:@"eye_1_new"] forState:UIControlStateNormal];
    [showZero setImage:[UIImage Inc_imageNamed:@"eye_2_new"] forState:UIControlStateSelected];
    
    
    [showZero addTarget:self action:@selector(showZeroButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    

    
    IWPButton * getButton = [IWPButton buttonWithType:UIButtonTypeSystem];
    [interContentView addSubview:getButton];
    
    x = CGRectGetMaxX(showZero.frame) + marginTYK / 4.f;
    
    
    getButton.tag = tagTYK++;
    [getButton YuanAttributeHorizontalToView:textView];
    [getButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:marginTYK];
    [getButton autoSetDimension:ALDimensionWidth toSize:saoBtnWidth];
    
    //    getButton.sd_layout.leftEqualToView(showZero)
    //    .rightEqualToView(showZero)
    //    .topSpaceToView(showZero, margin / 4.f)
    //    .heightIs(40.f - margin / 2.f);
    //
    [getButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getButton setTitle:dict.btn1_text forState:UIControlStateNormal];
    getButton.backgroundColor = UIColor.mainColor;
    
    [getButton addTarget:self action:@selector(type52ButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - 按钮点击事件
#pragma mark 电杆选择拼名前缀
-(void)preNameChoice:(IWPButton *)sender{
    //MARK: 获取按钮的点击事件  暂时先注释掉 注释原因是 模板切换 UNI_后数据不全
   
    
//    IWPTextView * tv = [self.contentView viewWithTag:++type9TagTYK];
    
    if (sender.tag % 2 == 0) {
      // 地址
        self.isAddr = YES;
        
        NSString * addr = self.requestDict[@"addr"];
        
        [self.requestDict setValue:addr forKey:@"preName"];
        
//        tv.text = @"123";
        
    }else{
        //获取按钮的点击事件 杆路按钮的点击事件
        // 杆路段
        self.isAddr = NO;
        
        NSString * ssMainDeviceName = self.requestDict[@"poleLine"];
        
        [self.requestDict setValue:ssMainDeviceName forKey:@"preName"];
        
//        tv.text = @"456";
    }

    
    self.isAddr = NO;
           
    NSString * ssMainDeviceName = self.requestDict[@"poleLine"];
           
    [self.requestDict setValue:ssMainDeviceName forKey:@"preName"];
    
    
    
    
    
    
    [self subNameCreate];
    
}





#pragma mark 隐藏/显示二维码尾部0字符串
-(void)showZeroButtonHandler:(UIButton *)button{
    
    IWPTextView * textView = [[self.contentView viewWithTag:981273987] viewWithTag:9817278];
    
    if (!button.selected) {
        /* 显示零 */
        textView.text = self.requestDict[textView.key];
    }else{
        /* 隐藏零 */
        textView.text = [textView.text deleteZeroString];
    }
    
    
    button.selected = !button.selected;
}

#pragma mark type2按钮点击事件
-(void)type2ButtonHandler:(IWPButton *)sender{
    isType2TYK = YES;
    // 如果已存在一个 datePicker, 本次点击无效
    for (__kindof UIView * view in self.view.subviews) {
        if ([view isKindOfClass:[UIDatePicker class]]) {
            return;
        }
    }
    
    
    [self dismisView];
    [self cancleButtonHandler:nil];
    
    self.currentButton = sender;
    isDatePickerTYK = YES;
    
    CGFloat x,y,w,h;
    x = 0;
    h = ScreenHeight / 3.f;
    y = ScreenHeight - h;
    w = ScreenWidth;
    
    UIDatePicker * datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(x,y,w,h)];
    datePicker.backgroundColor = [UIColor whiteColor];
    datePicker.tag = 196399;
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    w = ScreenWidth;
    h = datePicker.frame.size.height;
    x = 0;
    y = ScreenHeight + 17.f;
    datePicker.frame = CGRectMake(x,y,w,h);
    [self.view addSubview:datePicker];
    
    x = 0;
    y = ScreenHeight;
    h = 40.f;
    w = ScreenWidth;
    
    
    
    
    UIView * controlView = [[UIView alloc] initWithFrame:CGRectMake(x,y,w,h)];
    [self.view addSubview:controlView];
    controlView.backgroundColor = [UIColor colorWithHexString:@"#f3f3f3"];
    controlView.tag = 894256;
    controlView.alpha = 0;
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    UIButton * button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button2 setTitle:@"确定" forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor clearColor];
    
    x = 0;
    y = 0;
    w = 80.f;
    h = 40.f;
    
    [button2 addTarget:self action:@selector(commitValue) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(dismisView) forControlEvents:UIControlEventTouchUpInside];
    
    button2.frame = CGRectMake(x,y,w,h);
    //    button.titleLabel.font = button2.titleLabel.font = [UIFont systemFontOfSize:20.f];
    [controlView addSubview:button2];
    
    x = ScreenWidth - w;
    button.frame = CGRectMake(x,y,w,h);
    [controlView addSubview:button];
    
    CGRect frame = controlView.frame;
    CGRect frame2 = datePicker.frame;
    frame.origin.y = ScreenHeight - datePicker.frame.size.height - controlView.frame.size.height;
    frame2.origin.y = ScreenHeight - datePicker.frame.size.height;
    
    [UIView animateWithDuration:.3f animations:^{
        datePicker.frame = frame2;
        datePicker.alpha = 1;
        controlView.frame = frame;
        controlView.alpha = 1;
    } completion:^(BOOL finished) {
        
        NSDate * date = [self dateFromStringWithoutTime:[[StrUtil new] GMTToLocal:_requestDict[sender.key]]];
        
        if (date == nil) {
            date = [NSDate dateWithTimeIntervalSinceNow:0];
        }
        
        [datePicker setDate:date animated:YES];
        
    }];
    
}
#pragma mark type3按钮点击事件
-(void)type3ButtonHandler:(IWPButton *)sender{
    
    
    // MARK:  袁全新增 去 * 判断
    NSMutableArray * yuan_NewArray = NSMutableArray.array;
    
    for (NSArray * titleArray in self.dataSource) {
        
        NSMutableArray * mtArr = [NSMutableArray arrayWithArray:titleArray];
        
        [mtArr enumerateObjectsWithOptions:NSEnumerationReverse
                                usingBlock:^(id  _Nonnull obj,
                                             NSUInteger idx,
                                             BOOL * _Nonnull stop) {
            
            if ([obj rangeOfString:@"*"].location !=NSNotFound) {
                [mtArr removeObject:obj];
            }
        }];
        
        [yuan_NewArray addObject:mtArr];
        
    }
    
    self.dataSource = yuan_NewArray;
    
    isType11TYK = NO;// type11使用相同的方法创建PickerView
    for (__kindof UIView * view in self.view.subviews) {
        if ([view isKindOfClass:[UIPickerView class]]) {
            return;
        }
    }
    
    for (__kindof UIView * tv in self.contentView.subviews) {
        // 将通用编辑框取消显示
        if ([tv isKindOfClass:[IWPTextView class]] && [tv isFirstResponder]) {
            [tv resignFirstResponder];
        }
    }
    
    
    [self cancleButtonHandler:nil];
    
    
    isDatePickerTYK = NO;
    
    typeTYK = [sender.type copy];
    
    if (typeTYK.integerValue == 11) {
        isType11TYK = YES; // 这里判断究竟是不是type11发出的事件
    }else{
        isType11TYK = NO;
    }
    CGFloat x,y,w,h;
    currentButtonTagTYK = sender.tag;
    currentTagTYK = sender.t11Tag;// 用于查找Label，限type11
    selectedRowTYK = 0;
    kRowTYK = sender.tag - 30000;
    
    
    x = 0;
    h = ScreenHeight / 3.f;
    y = ScreenHeight - h;
    w = ScreenWidth;
    UIPickerView * pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(x,y,w,h)];
    pickerView.backgroundColor = [UIColor whiteColor];
    
    //    pickerView.alpha = 0;
    
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    w = ScreenWidth;
    h = pickerView.frame.size.height;
    x = 0;
    y = ScreenHeight + 17.f;
    pickerView.frame = CGRectMake(x, y, w, h);
    [self.view addSubview:pickerView];
    
    
    
    x = 0;
    y = ScreenHeight;
    h = 40.f;
    w = ScreenWidth;
    
    UIView * controlView = [[UIView alloc] initWithFrame:CGRectMake(x,y,w,h)];
    [self.view addSubview:controlView];
    controlView.tag = 894256;
    controlView.backgroundColor = [UIColor colorWithHexString:@"#f3f3f3"];
    //    controlView.alpha = 0;
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    
    UIButton * button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    button2.backgroundColor = [UIColor clearColor];
    [button2 setTitle:@"确定" forState:UIControlStateNormal];
    
    x = 0;
    y = 0;
    w = 80.f;
    h = 40.f;
    
    [button2 addTarget:self action:@selector(commitValue) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(dismisView) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    button2.frame = CGRectMake(x,y,w,h);
    //    button.titleLabel.font = button2.titleLabel.font = [UIFont systemFontOfSize:20.f];
    [controlView addSubview:button2];
    
    x = ScreenWidth - w;
    button.frame = CGRectMake(x,y,w,h);
    [controlView addSubview:button];
    
    CGRect frame = controlView.frame;
    CGRect frame2 = pickerView.frame;
    frame.origin.y = ScreenHeight - pickerView.frame.size.height - controlView.frame.size.height;
    frame2.origin.y = ScreenHeight - pickerView.frame.size.height;
    
    [UIView animateWithDuration:.25f animations:^{
        pickerView.frame = frame2;
        //    pickerView.alpha = 1;
        controlView.frame = frame;
        //    controlView.alpha = 1;
    } completion:^(BOOL finished) {
        [pickerView selectRow:[_requestDict[sender.key] integerValue] inComponent:0 animated:YES];
        selectedRowTYK = [_requestDict[sender.key] integerValue];
    }];
    
    _currentKey = sender.key;
    
}
#pragma mark type4按钮点击事件
-(void)type4ButtonHandler:(IWPButton *)sender{
   
    // 袁全注释  之前是 kLatTYK kLonTYK  = 0;
//    kLatTYK = 0;
//    kLonTYK = 0;
    
    currentTagTYK = sender.tag;
    LocationNewGaoDeViewController * locationService = [[LocationNewGaoDeViewController alloc] initWithLocation:CLLocationCoordinate2DMake(kLatTYK, kLonTYK)];
    locationService.delegate = self;
    locationService.fileName = _fileName;
    locationService.isOffline = _isOffline;
    if ([_fileName isEqualToString:@"ledUp"]) {
        if (_ledUpWell == nil) {
            if (([self.requestDict objectForKey:@"well_Id"])!=nil && ([self.requestDict objectForKey:@"well_Id"]!=0)) {
                locationService.wellId = [[self.requestDict objectForKey:@"well_Id"] intValue];
            }
        }else{
            locationService.well =_ledUpWell;
        }
    }else if ([_fileName isEqualToString:@"OCC_Equt"]){
        if (_occWell == nil) {
            if (([self.requestDict objectForKey:@"well_Id"])!=nil && ([self.requestDict objectForKey:@"well_Id"]!=0)) {
                locationService.wellId = [[self.requestDict objectForKey:@"well_Id"] intValue];
            }
        }else{
            locationService.well =_occWell;
        }
    }
    
    
    [self.navigationController pushViewController:locationService animated:YES];
}
#pragma mark type5按钮点击事件
-(void)type5ButtonHandler:(IWPButton *)sender{
    if (_isOffline) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];

        return;
    }
    // 获取地址吧？？？？
    if ([self.requestDict[@"lon"] length] == 0 || [self.requestDict[@"lat"] length] == 0) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"请先获取经纬度" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        Present(self, alert);
        return;
    }
    getAddrBtnTagTYK = sender.tag;
    //    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(kLat, kLon);
    
    NSString * lat = self.requestDict[@"lat"];
    NSString * lon = self.requestDict[@"lon"];
    
    if (lat.doubleValue > 0 && lon.doubleValue > 0) {
        [self searchReGeocodeWithCoordinate:CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue)];
    }
    else {
        
        [self searchReGeocodeWithCoordinate:CLLocationCoordinate2DMake(kLatTYK, kLonTYK)];
    }
}
#pragma mark type6按钮点击事件
-(void)type6ButtonHandler:(IWPButton *)sender{
    
    IWPTextView * textView = [self.contentView viewWithTag:sender.tag - 1];
    
    
    if ([textView.key isEqualToString:@"startPoleCode"] ||
        [textView.key isEqualToString:@"endPoleCode"]) {
        if ((self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            
            [alert addAction:action];
            Present(self, alert);
            return;
        }
    }
    
    
    
    
    if (_isOffline) {

        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    
    
    StationSelectResultTYKViewController * deviceListVC = [[StationSelectResultTYKViewController alloc] init];

    deviceListVC.fileName = sender.fileName;
    deviceListVC.delegate = self;
    deviceListVC.senderTag = sender.tag;





    NSLog(@"%@ - %@ - %@ - %@", textView.key, textView.name2, textView.name3, textView.name4);
    NSLog(@"%@ - %@", sender.key, sender.name2);
    
    
    if ([textView.key isEqualToString:@"startPoleCode"] ||
        [textView.key isEqualToString:@"endPoleCode"]) {

        deviceListVC.startOREndDevice_Key = @"poleLine_Id";
        deviceListVC.startOREndDevice_Id = self.requestDict[@"polelineId"];

    }else if ([textView.key isEqualToString:@"startmarkStone"] || [textView.key isEqualToString:@"endmarkStone"]){

        deviceListVC.startOREndDevice_Key = @"ssmarkStoneP_Id";
        deviceListVC.startOREndDevice_Id = self.requestDict[@"ssmarkStoneP_Id"];
    }
    
    NSLog(@"textView.key:%@",textView.key);
    if ([textView.key isEqualToString:@"ssBuilding"]) {
        for (int i = 0; i < self.contentView.subviews.count; i++) {
            if ([self.contentView.subviews[i] isKindOfClass:[IWPTextView class]]) {
                IWPTextView * textView = self.contentView.subviews[i];
                if ([textView.name2 isEqualToString:@"spcGridId"] && [textView.text isEqualToString:@""]) {
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"请先选择所属网格。" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];

                    [alert addAction:action];
                    Present(self, alert);

                    return;
                }
            }
        }
        //所属建筑需要根据网格的id进行查询
        deviceListVC.startOREndDevice_Key = @"ssSpcGrid_Id";
        deviceListVC.startOREndDevice_Id = self.requestDict[@"ssSpcGrid_Id"];
    }
    if ([textView.key isEqualToString:@"ssBuildingUnit"]) {
        for (int i = 0; i < self.contentView.subviews.count; i++) {
            if ([self.contentView.subviews[i] isKindOfClass:[IWPTextView class]]) {
                IWPTextView * textView = self.contentView.subviews[i];
                if ([textView.name2 isEqualToString:@"spcBuildingsId"] && [textView.text isEqualToString:@""]) {
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"请先选择所属建筑物。" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];

                    [alert addAction:action];
                    Present(self, alert);

                    return;
                }
            }
        }
        //所属单元需要根据建筑物的id进行查询
        deviceListVC.startOREndDevice_Key = @"ssBuilding_Id";
        deviceListVC.startOREndDevice_Id = self.requestDict[@"ssBuilding_Id"];
    }
    if ([textView.key isEqualToString:@"ssBuildingFloor"]) {
        for (int i = 0; i < self.contentView.subviews.count; i++) {
            if ([self.contentView.subviews[i] isKindOfClass:[IWPTextView class]]) {
                IWPTextView * textView = self.contentView.subviews[i];
                if ([textView.name2 isEqualToString:@"buildingUnitId"] && [textView.text isEqualToString:@""]) {
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"请先选择所属单元。" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];

                    [alert addAction:action];
                    Present(self, alert);

                    return;
                }
            }
        }
        //所属楼层需要根据单元的id进行查询
        deviceListVC.startOREndDevice_Key = @"ssBuildingUnit_Id";
        deviceListVC.startOREndDevice_Id = self.requestDict[@"ssBuildingUnit_Id"];
    }
    if ([_fileName isEqualToString:@"OBDPoint"]&&[textView.key isEqualToString:@"ssRoom"]) {
        NSLog(@"ssBuildingUnit_Id:%@",self.equDic[@"ssBuildingUnit_Id"]);
        if ([self.equDic[@"ssBuildingUnit_Id"] integerValue] == 0) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"请先选择分光器所在ODB的所属单元。" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];

            [alert addAction:action];
            Present(self, alert);

            return;
        }
        //用户门牌号需要根据楼层的id进行查询
        deviceListVC.startOREndDevice_Key = @"ssBuildingUnit_Id";
        deviceListVC.startOREndDevice_Id = self.equDic[@"ssBuildingUnit_Id"];
    }
    
    [self.navigationController pushViewController:deviceListVC animated:YES];
}
#pragma mark type7按钮点击事件
-(void)type7ButtonHandler:(IWPButton *)sender{
    NSLog(@"%s",__func__);
}
#pragma mark type8按钮点击事件
-(void)type8ButtonHandler:(IWPButton *)sender{
    
    RegionSelectViewController * region = [[RegionSelectViewController alloc] init];
    
    region.delegate = self;
    currentTagTYK = sender.tag;
    [self.navigationController pushViewController:region animated:YES];
    
}
#pragma mark type11按钮点击事件
-(void)type11ButtonHandler:(IWPButton *)sender{
    
    // "temp_text":"||,ODF_Equt|ODF_EqutId|rackName,joint|jointId|jointName,OCC_Equt|OCC_EqutId|occName,ODB_Equt|ODB_EqutId|odbName,markStone|markStoneId|markName"
    
    if (_isOffline) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];

        return;
    }
    isType11TYK = YES;
    __weak IWPLabel * label = [self.contentView viewWithTag:sender.tag - 2];
    NSInteger flag = 0;
    
    NSRange range = [label.text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"起始"]];
    
    if (range.length != 0) {
        flag = startDeviceRowTYK;
    }else{
        flag = endDeviceRotTYK;
    }
    
    if ([self.fileName isEqualToString:@"OBD_Equt"]) {
        flag = deviceRow;
    }
    
    
    if (flag == 0) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"请先选择类型" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        Present(self, alert);
        return;
    }
    
    NSLog(@"%@",self.getFileNames);
    
    NSString * fileName = [self.getFileNames[flag - 1] valueForKey:@"type"];
    
    
    if ((self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) &&
        isSavedTYK == NO &&
        [fileName isEqualToString:@"well"] &&
        [self.fileName isEqualToString:@"pipe"]) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
    StationSelectResultTYKViewController * deviceList = [[StationSelectResultTYKViewController alloc] init];
    if ([self.fileName isEqualToString:@"cable"]&&[fileName isEqualToString:@"joint"]) {
        deviceList.doType = @"GetCableJoint";
    }else{
        
        if ([self.fileName isEqualToAnyString:@"pipeSegment", @"poleLineSegment", @"markStoneSegment", nil] && [fileName isEqualToAnyString:@"well", @"pole", @"markStone", nil]) {
            
            deviceList.doType = @"GetInterStart_EndDevice";
            
            if ([self.fileName isEqualToString:@"pipeSegment"]) {
                
                deviceList.ssDeviceId = self.requestDict[@"pipe_Id"];
                deviceList.ssDeviceKey = @"pipe_Id";
                
            }else if ([self.fileName isEqualToString:@"poleLineSegment"]){
                
                deviceList.ssDeviceId = self.requestDict[@"poleLine_Id"];
                deviceList.ssDeviceKey = @"poleLine_Id";
                
            }else if([self.fileName isEqualToString:@"markStoneSegment"]){
                
                deviceList.ssDeviceId = self.requestDict[@"ssmarkStoneP_Id"];
                deviceList.ssDeviceKey = @"ssmarkStoneP_Id";
                
            }
            
            
            
            
        }else{
             deviceList.doType = @"Get";
        }
        
    }
    deviceList.fileName = fileName;
    deviceList.delegate = self;
    deviceList.senderTag = sender.tag;
    
    
    if ([fileName isEqualToString:@"well"] &&
        [self.fileName isEqualToString:@"pipe"]) {
        
        deviceList.startOREndDevice_Key = @"pipe_Id";
        deviceList.startOREndDevice_Id = self.requestDict[@"pipeId"];
        
    }
    
    
    
    currentTagTYK = sender.tag;
    [self.navigationController pushViewController:deviceList animated:YES];
}
#pragma mark type10按钮点击事件
-(void)type10ButtonHandler:(IWPButton *)sender{
    
    
    
    // 如果已存在一个 datePicker, 本次点击无效
    isType2TYK = NO;
    self.currentButton = sender;
    UIScrollView * temp = [self.view viewWithTag:0xABD];
    
    if (temp) {
        return;
    }
    
    [self dismisView];
    UIView * textEditor = [self getFirstResponder];
    if (textEditor) {
        [textEditor resignFirstResponder];
    }
    
    CGFloat x = 0, y = 0, w = 0, h = 0;
    
    x = 0;
    h = self.view.bounds.size.height / 3.f;
    w = ScreenWidth;
    y = ScreenHeight + 40.f;
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    scrollView.pagingEnabled = true;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor whiteColor];
    UIDatePickerMode modes[2] = {UIDatePickerModeDate, UIDatePickerModeTime};
    scrollView.tag = 0xABD;
    
    scrollView.contentSize = CGSizeMake(scrollView.width * 2, 0);
    
    
    
    UIView * controlView = [[UIView alloc] init];
    [self.view addSubview:controlView];
    controlView.backgroundColor = [UIColor colorWithHexString:@"#f3f3f3"];
    controlView.tag = 0xABD + 1;
    
    x = 0;
    h = 40.f;
    y = ScreenHeight;
    w = ScreenWidth;
    
    controlView.frame = CGRectMake(x, y, w, h);
    
    
    UIButton * sureButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIButton * cancleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    sureButton.tag = 0xABEF;
    cancleButton.tag = 0xABFF;
    [sureButton setTitle:@"确定" forState:UIControlStateSelected];
    [sureButton setTitle:@"下一步" forState:UIControlStateNormal];
    [cancleButton setTitle:@"关闭" forState:UIControlStateNormal];
    
    
    [sureButton addTarget:self action:@selector(commitValue:) forControlEvents:UIControlEventTouchUpInside];
    [cancleButton addTarget:self action:@selector(cancleButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [controlView addSubview:sureButton];
    [controlView addSubview:cancleButton];
    
    

    [sureButton YuanToSuper_Top:0];
    [sureButton YuanToSuper_Left:0];
    [sureButton YuanToSuper_Bottom:0];
    [sureButton autoSetDimension:ALDimensionWidth toSize:80];

    [cancleButton YuanToSuper_Top:0];
    [cancleButton YuanToSuper_Right:0];
    [cancleButton YuanToSuper_Bottom:0];
    [cancleButton autoSetDimension:ALDimensionWidth toSize:80];
//    sureButton.sd_layout.leftSpaceToView(controlView, 0.f)
//    .topSpaceToView(controlView, 0.f)
//    .bottomSpaceToView(controlView, 0.f)
//    .widthIs(80.f);
    
//    cancleButton.sd_layout.rightSpaceToView(controlView, 0.f)
//    .topSpaceToView(controlView, 0.f)
//    .bottomSpaceToView(controlView, 0.f)
//    .widthIs(80.f);
    
    
    IWPTextView * textField = [[IWPTextView alloc] init];
    [controlView addSubview:textField];
    
    textField.delegate = self;
    textField.hidden = YES;
    textField.tag = 0xABD + 2;
    textField.shouldEdit = YES;
    textField.backgroundColor = [UIColor whiteColor];
    textField.placeholder = @"请填写秒数（0 ~ 59）";
    textField.hintString = @"秒数（0 ~ 59）";
    textField.font = [UIFont systemFontOfSize:14];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    
    [textField autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:sureButton];
    [textField autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:cancleButton];
    [textField autoSetDimension:ALDimensionHeight toSize:30];
    [textField autoCenterInSuperview];
    
//    textField.sd_layout.leftSpaceToView(sureButton, 0.f)
//    .rightSpaceToView(cancleButton, 0.f)
//    .heightIs(30.f)
//    .centerYEqualToView(controlView);
    
    x = 0;
    y = 0;
    w = ScreenWidth;
    h = ScreenHeight / 3.f;
    
    // 设置
    
    
    for (int i = 0; i < 2; i++) {
        
        x = i * w;
        UIDatePicker * datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [scrollView addSubview:datePicker];
        datePicker.tag = 0xCBD + i;
        
        datePicker.datePickerMode = modes[i];
        
        
    }
    
    
    [UIView animateWithDuration:.3f animations:^{
        
        CGRect frame = scrollView.frame;
        frame.origin.y = ScreenHeight - frame.size.height;
        scrollView.frame = frame;
        
        CGRect frame2 = controlView.frame;
        frame2.origin.y = frame.origin.y - 40.f;
        controlView.frame = frame2;
        
        
        
        
        
    } completion:^(BOOL finished) {
        UIDatePicker * datePicker = [scrollView viewWithTag:0xCBD];
        [datePicker setDate:[self type10Date:sender.key] animated:YES];
    }];
      
}

-(NSDate *)type10Date:(NSString *)key{
    NSString * dateStr = _requestDict[key];
    NSDate * date = [self dateFromStringWithTime:[[StrUtil new] GMTToLocalWithSecond:dateStr]];
    
    isSetType10TextFieldTYK = true;
    if (date == nil) {
        date = [NSDate dateWithTimeIntervalSinceNow:0];
        isSetType10TextFieldTYK = false;
    }
    
    return date;
}

#pragma mark type13按钮点击事件
-(void)type13ButtonHandler:(IWPButton *)sender{
    
    currentTagTYK = sender.tag;
    
    Inc_NewMB_Type9_AssistListVC * type9_VC =
    [[Inc_NewMB_Type9_AssistListVC alloc] initWithPostDict:@{@"type":@"pubUnit"}];
    
    [type9_VC configTitle:@"维护单位"];
    
    Push(self, type9_VC);
    
    // 回调
    type9_VC.Type9_Choose_ResBlock = ^(NSDictionary * _Nonnull dict) {
        
        NSString * name = dict[@"name"];
        
        // 所属维护区域
        // 取得所属维护区域编辑框
        __weak IWPTextView * tv = [self.contentView viewWithTag:currentTagTYK-1];
        // 将值写入
        tv.text = name;
        // 写到请求字典中
        [self.requestDict setValue:tv.text forKey:tv.key];
        
    };
}


#pragma mark type50按钮点击事件
-(void)type50ButtonHandler:(IWPButton *)sender{
    if (_isOffline) {
    
        [YuanHUD HUDFullText:@"离线模式下不可用"];

        
        return;
    }
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"确定要使用道路命名吗？\n如果不是，请人工输入" message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) wself = self;
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        __weak IWPTextView * tv = [wself.contentView viewWithTag:sender.tag - 1];
        tv.text = @"";
        [tv becomeFirstResponder];
    }];
    
    getAddrBtnTagTYK = sender.tag;
    
    UIAlertAction * yes = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        getAddrBtnTagTYK = sender.tag;
        [wself setRoadName:sender];
    }];
    
    [alert addAction:cancle];
    [alert addAction:yes];
    
    Present(self, alert);
}
#pragma mark type51按钮点击事件
-(void)type51ButtonHandler:(IWPButton *)sender{
    [UIAlert alertSmallTitle:@"这里出问题了？IWPDeviceListViewController"];
//    if (_isOffline) {
//        MBProgressHUD * alert = [MBProgressHUD showHUDAddedTo:(self.keyWindow) animated:YES];alert.label.text = (@"离线模式下不可用");alert.mode = MBProgressHUDModeText;alert.animationType = MBProgressHUDAnimationZoomIn;[alert hideAnimated:YES afterDelay:((float)2.f)];
//        return;
//    }
//    IWPDeviceListViewController * cable = [IWPDeviceListViewController deviceListWithFileName:@"cable" isShowEditButton:NO withReadType:IWPDeviceListControlTypeGetCable offlineSwitch:(BOOL)NO];
//    cable.delegate = self;
//    //    cable.isNeedEdit = YES;
//    [self.navigationController pushViewController:cable animated:YES];
}
#pragma mark type52按钮点击事件
-(void)type52ButtonHandler:(IWPButton *)sender{
    
    IWPSaoMiaoViewController * saomiao = [[IWPSaoMiaoViewController alloc] init];
    saomiao.delegate = self;
    saomiao.isGet = YES;
    [self.navigationController pushViewController:saomiao animated:YES];

    // 绑定二维码
    Http.shareInstance.statisticEnum = HttpStatistic_ResourceBindQR;
}

-(void)removeHintLabel{
    MBProgressHUD * hint = [self.view viewWithTag:89129038];
    [hint removeFromSuperview];
}

#pragma mark - 代理方法
#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    // 定位后调用该方法
    // 取出数据
    CLLocation * location= [locations firstObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    // 向全局变量赋值
    kLatTYK = coordinate.latitude;
    kLonTYK = coordinate.longitude;
    
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    
    
    __weak typeof(self) wself = self;
    // 反地理编码
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        [geocoder cancelGeocode];
        // 拿到反地理编码的数据
        NSString * result = [placemarks firstObject].name;
        // 剔除国家信息
        NSArray * arr = [result componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"国"]];
        // 将剔除国家信息后的字符串赋值给result
        result = [arr lastObject];
        // 取出获取名称的编辑框
        __weak IWPTextView * textView = [wself.contentView viewWithTag:getAddrBtnTagTYK - 1];
        
        [_HUD hideAnimated:YES];
        // [_HUD removeFromSuperview];
        _HUD = nil;
        
        
        if (result == nil) {
            if (isHintedTimeOutTYK) {
                return;
            }
        
            [YuanHUD HUDFullText:@"当前网络状态不佳，获取地址失败"];
            
            return;
        }
        
        // 特殊判断
        if ([_fileName isEqualToString:@"poleline"]) {
            textView.text = [NSString stringWithFormat:@"%@杆路",result];
        }else if ([_fileName isEqualToString:@"pipe"]) {
            textView.text = [NSString stringWithFormat:@"%@管道",result];
        }else{
            textView.text = result;
        }
        // 重置全局变量
        kLonTYK = 0;
        kLatTYK = 0;
        // 将结果写入请求字典
        [wself.requestDict setValue:textView.text forKey:textView.key];
        // location停止操作
        [wself.locationManager stopUpdatingLocation];
        // 拼名
        NSRange range = [_model.subName rangeOfString:textView.key];
        if (range.length > 0) {
            [wself subNameCreate];
        }
    }];
}
#pragma mark 高德地图代理方法
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    // 高德反地理编码
    NSLog(@"response = %@",response);
    if (!response) {
      
        [YuanHUD HUDFullText:@"当前网络状态较差，获取失败"];
        
        return;
    }
    
    
    if (response.regeocode != nil){
        
        __weak IWPTextView * textView = [self.contentView viewWithTag:getAddrBtnTagTYK - 1];
        
        textView.text = response.regeocode.formattedAddress;
        
        [self.requestDict setValue:textView.text forKey:textView.key];
        
        
        
        NSRange range = [_model.subName rangeOfString:textView.key];
        // 地址拼名
        if (range.length > 0) {
            [self subNameCreate];
        }else{
            if ([_model.subName rangeOfString:@"preName"].length > 0) {
                [self subNameCreate];
            }
        }
    }
    
}

- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)location
{
    
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:location.latitude longitude:location.longitude];
    regeo.requireExtension = YES;
    
    [_search AMapReGoecodeSearch:regeo];
}
#pragma mark scrollView 代理方法

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (![scrollView isKindOfClass:[IWPTextView class]]) {
        UIDatePicker * pickerView_date = [scrollView viewWithTag:0xCBD];
        if (self.date_Date == nil || ![self.date_Time isEqualToDate:pickerView_date.date]) {
            /* 说明直接滑动 或 改变了日期 */
            
            self.date_Date = pickerView_date.date;
            
        }
        
        
        UIButton * button = [[self.view viewWithTag:(0xABD + 1)] viewWithTag:0xABEF];
        UITextField * textField = [[self.view viewWithTag:(0xABD + 1)] viewWithTag:(0xABD + 2)];
        
        button.selected = scrollView.contentOffset.x > 0;
        textField.hidden = scrollView.contentOffset.x == 0;
        
        UIDatePicker * pickerView = [scrollView viewWithTag:0xCBD+1];
        
        [pickerView setDate:self.date_Date animated:YES];
        
        if (isSetType10TextFieldTYK) {
            textField.text = [[[self timeStringFromDate:self.date_Date] componentsSeparatedByString:@":"] lastObject];
            
        }
    }
    
    
}

-(UIView *)getFirstResponder{
    
    for (UIView * textEditor in self.contentView.subviews) {
        if ([textEditor isKindOfClass:[IWPTextView class]] ||
            [textEditor isKindOfClass:[UITextField class]]) {
            
            if ([textEditor isFirstResponder]) {
                return textEditor;
            }
            
        }
    }
    
    return nil;
    
}


- (NSString *)dateStringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}
- (NSString *)timeStringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

- (NSDate *)dateFromStringWithTime:(NSString *)dateString{
    
    NSLog(@"%@", dateString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}

- (NSDate *)dateFromStringWithoutTime:(NSString *)dateString{
    
    NSLog(@"%@", dateString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}

#pragma mark type10下一步/确定按钮点击事件
-(void)commitValue:(UIButton *)sender{
    UIScrollView * scrollView = [self.view viewWithTag:0xABD];
    
    UITextField * textField = [[self.view viewWithTag:(0xABD + 1)] viewWithTag:(0xABD + 2)];
    
    
    
    if (sender.selected) {
        
        if (textField.text.integerValue >= 0 && textField.text.integerValue < 60) {
            
            /* 提交 */
            /* 取出datePicker */
            UIDatePicker * datePicker = [scrollView viewWithTag:(0xCBD + 1)];
            /* 存储timeDate */
            self.date_Time = datePicker.date;
            
            /* 转为字符串 */
            NSString * dateStr = [self dateStringFromDate:self.date_Date];
            
            
            /* 从time中减掉秒数 */
            /* 取出时分 */
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents * components = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self.date_Time];
            
            NSInteger hour = components.hour;
            NSInteger minute = components.minute;
            NSInteger second = textField.text.integerValue;
            
            /* 取出结束 */
            
            /* 拼接时分秒 */
            NSString * timeStr = [NSString stringWithFormat:@"%2ld:%2ld:%2ld", (long)hour,(long)minute,(long)second];
            
            /* 拼接年月日时分秒并转为服务器要求的格式 */
            NSString * value = [[StrUtil new] LocalToGMTWithSecond:[NSString stringWithFormat:@"%@ %@", dateStr, timeStr]];
            
            NSLog(@"%@", value);
            
            /* 赋值显示 */
            [self.requestDict setValue:value forKey:self.currentButton.key];
            [self.currentButton setTitle:[[StrUtil new] GMTToLocalWithSecond:value] forState:UIControlStateNormal];
            
            self.requestDict = [_MB_VM Special_MB_KeyConfig:self.requestDict
                                                        key:self.currentButton.key];
            
            /* 完成关闭 */
            [self cancleButtonHandler:nil];
            
        }else{
            [YuanHUD HUDFullText:@"秒数填写不正确(0~59)"];
        }
        
        
        
    }else{
        /* 下一步 */
        textField.hidden = NO;
        
        UIDatePicker * datePicker = [scrollView viewWithTag:0xCBD];
        
        self.date_Date = datePicker.date;
        
        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width, 0) animated:YES];
        
        NSLog(@"date_Date = %@", self.date_Date);
        
        sender.selected = YES;
    }
    
    
}
#pragma mark type10取消按钮点击事件
-(void)cancleButtonHandler:(UIButton *)sender{
    
    /* 关闭时，全局置空 */
    
    self.date_Date = nil;
    self.date_Time = nil;
    
    isSetType10TextFieldTYK = false;
    
    UIScrollView * scrollView = [self.view viewWithTag:0xABD];
    UIView * controlView = [self.view viewWithTag:0xABD + 1];
    [UIView animateWithDuration:.3f animations:^{
        CGRect frame = scrollView.frame;
        frame.origin.y = ScreenHeight + 40.f;
        scrollView.frame = frame;
        
        CGRect frame2 = controlView.frame;
        frame2.origin.y = ScreenHeight;
        controlView.frame = frame2;
        
    } completion:^(BOOL finished) {
        [scrollView removeFromSuperview];
        [controlView removeFromSuperview];
    }];
}

//#pragma mark 创建地址
//-(void)createAddr{
//    __weak IWPTextView * tv = [self.contentView viewWithTag:getAddrBtnTag - 1];
//    if (tv != nil) {
//        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(kLat, kLon);
//
//        [self searchReGeocodeWithCoordinate:coordinate];
//    }
//}

#pragma mark 以道路命名
-(void)setRoadName:(IWPButton *)sender{
    
    
    
    isHintedTimeOutTYK = NO;

    [Yuan_HUD.shareInstance HUDStartText:@"正在取得您的位置，请稍候……"];
    
    [self.locationManager startUpdatingLocation];
    
}
#pragma mark 拼名创建
-(NSString *)getSubNameWithFormat:(NSString *)format{
    
    NSMutableArray * fixedStrs = [NSMutableArray array];
    
    NSMutableString * myStr = [format mutableCopy];
    
    for (int i = 0; i < myStr.length; i++) {
        
        NSRange rangeS = [myStr rangeOfString:@"<"];
        NSRange rangeE = [myStr rangeOfString:@">"];
        
        NSInteger trueLocation = rangeS.length + rangeS.location; // 起始标识符长度 + 起始标识符起点位置，是目标值的起始位置
        
        NSInteger trueLength = rangeE.location - trueLocation; // 终止标识符起点位置 - 目标值起点位置， 是目标值的长度
        
        NSRange trueRange = NSMakeRange(trueLocation, trueLength);
        
        if (trueRange.location < myStr.length &&
            trueRange.length < myStr.length) { // 该起点位置只在小于字符串长度时执行
            NSString * fixedStr = [myStr substringWithRange:trueRange];
            
            
            // 剔除特征
            [myStr replaceCharactersInRange:rangeS withString:@"+"];
            [myStr replaceCharactersInRange:rangeE withString:@"+"];
            
            [fixedStrs addObject:fixedStr];
        }else{
            break;
        }
        
    }
    
    NSLog(@"%@", fixedStrs);
    
    
    
    
    
    NSArray * direction = @[@"",@"东",@"南",@"西",@"北"];
    NSMutableString * ret = [NSMutableString string];
    
    //拆格式字符串
    /**
     *  addr+direction+<#>+wellNo+<_>+wellSubNo
     */
    
    NSMutableArray * formatArr = [NSMutableArray arrayWithArray:[format componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+<>"]]];
    
    
    NSRange range = [format rangeOfString:@"preName"];
    NSString * preName = nil;
    if (range.length > 0) {
        // 说明是需要选择前缀类别的
        
        if (_isAddr) {
            // 用地址作为前缀
            preName = @"addr";
        }else{
            // 用杆路作为前缀
            preName = @"poleLine";
        }
    }
    
    
    [formatArr removeObject:@""];
    
    for (int i = 0; i < formatArr.count; i++) {
        if ([[formatArr objectAtIndex:i] isEqualToString:@"preName"]) {
            [formatArr replaceObjectAtIndex:i withObject:preName];
        }
    }
    
    NSLog(@"formatArr：%@",formatArr);
    NSLog(@"self.requestDict:%@",self.requestDict);
    for (NSString * key in formatArr) {
        NSString * value = self.requestDict[key];
        
        
        NSLog(@"%@", fixedStrs);
        
        for (NSString * str in fixedStrs) {
            NSLog(@"%@", str);
            if ([key isEqualToString:str]) {
                value = key;
                break;
            }
            
        }
        
        if (value == nil) {
            continue;
        }
        
        if ([key isEqualToString:@"direction"]) {
            value = direction[value.integerValue];
        }
        
        [ret insertString:value atIndex:ret.length];
        NSLog(@"ret：%@",ret);
    }
    if ([ret isEqualToString:@""]) {
        return @"";
    }
    NSString * testStr = self.requestDict[[formatArr lastObject]];
    
    NSRange rg = {ret.length - 1, 1};
    NSString * ch = [ret substringWithRange:rg];
    
    
    
    if ([testStr length] == 0 && [ch isEqualToString:@"_"]) {
        NSRange range = {0, ret.length - 1};
        NSString * tmp = [ret substringWithRange:range];
        return tmp;
    }
    
    return ret;
}

#pragma mark 拼名入口
-(void)subNameCreate{
    
    __weak IWPTextView * textV = [self.contentView viewWithTag:type9TagTYK];
    if (textV == nil) {
        return;
    }
    
    return;
    
    // 此段代码会导致 扫一扫时 修改经纬度  导致名称改变
    textV.text = [self getSubNameWithFormat:_model.subName];
    [self.requestDict setValue:textV.text forKey:textV.key];
    
}

#pragma mark IWPDeviceListDelegate
-(void)devicesWithArray:(NSArray<NSDictionary *> *)devices{
    isDevicesTYK = YES;
    for (NSDictionary * dict in devices) {
        [self returnCable:dict[@"cableName"] :dict[@"cableId"]];
    }
}
-(void)returnCabelInfomationWithDict:(NSDictionary *)dict{
    isDevicesTYK = NO;
    [self returnCable:dict[@"cableName"] :dict[@"cableId"]];
    //    NSLog(@"GETCABLE = %@", dict);
}

#pragma mark ptotocolDelegate
#pragma mark 二维码扫描回调
-(void)makeRfidText:(NSString *)rfidText{
    // 取出rfid的编辑框
    IWPTextView * textView = [[self.contentView viewWithTag:981273987] viewWithTag:9817278];
    UIButton * showZeroButton = [[self.contentView viewWithTag:981273987] viewWithTag:0xffff];
    
    if (textView) {
        // 将扫描到的rfid填入编辑框
        if (showZeroButton.selected) {
            textView.text = rfidText;
        }else{
            textView.text = [rfidText deleteZeroString];
        }
        // 写入请求字典
        [self.requestDict setValue:rfidText forKey:textView.key];
        
        id vc = self.navigationController.viewControllers.lastObject;
        
        if (!([vc class] ==  [self class])) {
            // 是否跳转
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark pickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    // 创建一个 指针tmp，用来接收选中行数，使其可以准确地向需要的数组中赋值。
    NSInteger * tmp = NULL;
    // 是否为type11,
    if (typeTYK.intValue == 11) {
        
        // 取出激活此pickerView的button在哪个label下
        __weak IWPLabel * label = [self.contentView viewWithTag:currentTagTYK - 1];
        
        // 以 起始 二字创建range
        NSRange range = [label.text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"起始"]];
        
        // 若长度大于0，说明是激活的起始设备选择
        if (range.length > 0) {
            tmp = &startDeviceRowTYK;
        }else if (range.length == 0){
            // 否则说明是激活的终止设备选择明
            tmp = &endDeviceRotTYK;
        }
        // 向该地址赋值
        *tmp = row;
    }
    
    // 当前选中行数赋值。
    selectedRowTYK = row;
    // 向请求字典中赋值
    
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    NSLog(@"%@", self.dataSource);
    
    return self.dataSource[kRowTYK].count;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.dataSource[kRowTYK][row];
}
#pragma mark type2/type3/type11确认按钮点击事件
-(void)commitValue{
    // 把值顯示了
    if (isDatePickerTYK) {
        // 日期选择
        
        UIDatePicker * view = [self.view viewWithTag:196399];
        
        if (view.tag == 196399) {
            
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString * str = [dateFormatter stringFromDate:view.date];
            
            
            NSString * date = nil;
            
            if (isType2TYK) {
                date = [[StrUtil new] LocalToGMT:str];
            }else{
                
                UITextField * textField = [[self.view viewWithTag:894256] viewWithTag:0xcbd];
                
                /* 转时间戳 */
                NSTimeInterval time = [view.date timeIntervalSince1970] + textField.text.doubleValue;
                
                NSDate * newDate = [NSDate dateWithTimeIntervalSince1970:time];
                
                
                
                NSLog(@"%f -- %@ -- %@",time,newDate,view.date);
                
            }
            
            NSLog(@"%@", date);
            
            [self.requestDict setValue:[[StrUtil new] LocalToGMT:str] forKey:self.currentButton.key];
            [self.currentButton setTitle:str forState:UIControlStateNormal];
            [self dismisView];
            return;
            
        }
        
    }
    
    NSInteger * tmp;
    BOOL isStartDevice = NO;
    if (typeTYK.intValue == 11) {
        __weak IWPLabel * label = [self.contentView viewWithTag:currentTagTYK - 1];
        //        NSLog(@"%@",label.text);
        
        NSRange range = [label.text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"起始"]];
        
        if (range.length > 0) {
            tmp = &type11AlreadySelectedStartRowTYK;
            isStartDevice = YES;
        }else {
            tmp = &type11AlreadySelectedEndRowTYK;
        }
        *tmp = selectedRowTYK;
    }
    
    //用户需要清除其之前选择数据的功能，所以屏蔽
    
    //    if (selectedRow == 0) {
    //        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"请选择一项" message:@"请选择一项有效的值或直接关闭选择栏" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    //        [alert show];
    //        return;
    //    }
    
    IWPButton * button = [self.contentView viewWithTag:kRowTYK + 30000];
    NSString * currentTitle = button.titleLabel.text;
    if (button == nil) {
        return;
    }
    button.selected = NO;
    [button setTitle:self.dataSource[kRowTYK][selectedRowTYK] forState:UIControlStateNormal];
    
    
    
    NSLog(@"button.tag11 = %ld",(long)button.type11Tag);
    
    if(isType11TYK){
        if (![currentTitle isEqualToString:self.dataSource[kRowTYK][selectedRowTYK]]) {
            
            for (int i = 0; i < self.contentView.subviews.count; i++) {
                if ([self.contentView.subviews[i] isKindOfClass:[IWPTextView class]]) {
                    IWPTextView * textView = self.contentView.subviews[i];
                    NSLog(@"textView = %ld",(long)textView.type11Tag);
                    if (textView.isType11 && textView.type11Tag == button.type11Tag + 1) {
                        textView.text = @"";
                        [self.requestDict setValue:@"" forKey:textView.name2];
                        [self.requestDict setValue:@"" forKey:textView.name3];
                    }
                    
                    NSRange range = [_model.subName rangeOfString:textView.key ?: @""];
                    if (range.length > 0) {
                        [self subNameCreate];
                    }
                }
                
            }
            NSLog(@"%@",_requestDict);
        }
    }
    
    NSString * select_Value = self.dataSource[kRowTYK][selectedRowTYK];
    
    if (selectedRowTYK == 0) {
        // 向请求字典中赋值
        [self.requestDict setValue:[NSString stringWithFormat:@"%@",select_Value]
                            forKey:_currentKey];
    }
    
    [self.requestDict setValue:[NSString stringWithFormat:@"%@",select_Value]
                        forKey:_currentKey];
    
    
    NSLog(@"%@", button.key);
    
    NSRange range = [_model.subName rangeOfString:button.key];
    if (range.length > 0) {
        [self subNameCreate];
    }
    
    
    [self dismisView];
}
#pragma mark type2/type3/type11取消按钮点击事件
-(void)dismisView{
    
    for (__kindof UIView * pView in self.view.subviews) {
        if ([pView isKindOfClass:[UIPickerView class]]) {
            UIView * cView = [self.view viewWithTag:894256];
            [UIView animateWithDuration:.25f animations:^{
                CGRect cFrame = cView.frame;
                cFrame.origin.y = ScreenHeight;
                cView.frame = cFrame;
                
                
                CGRect pFrame = pView.frame;
                pFrame.origin.y = cFrame.origin.y + cFrame.size.height;
                pView.frame = pFrame;
                
            } completion:^(BOOL finished) {
                [pView removeFromSuperview];
                [cView removeFromSuperview];
            }];
        }
        
        if ([pView isKindOfClass:[UIDatePicker class]]) {
            UIView * cView = [self.view viewWithTag:894256];
            [UIView animateWithDuration:.25f animations:^{
                CGRect cFrame = cView.frame;
                cFrame.origin.y = ScreenHeight;
                cView.frame = cFrame;
                
                
                CGRect pFrame = pView.frame;
                pFrame.origin.y = cFrame.origin.y + cFrame.size.height;
                pView.frame = pFrame;
                
            } completion:^(BOOL finished) {
                [pView removeFromSuperview];
                [cView removeFromSuperview];
            }];
            return;
        }
    }
    
    // 判断一下是不是 type11;
    if (isType11TYK) {
        NSInteger * tmp = NULL, * tmp2 = NULL;
        __weak IWPLabel * label = [self.contentView viewWithTag:currentTagTYK - 1];
        //        NSLog(@"%@",label.text);
        
        NSRange range = [label.text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"起始"]];
        
        if (range.length > 0) {
            tmp = &startDeviceRowTYK;
            tmp2 = &type11AlreadySelectedStartRowTYK;
        }else if (range.length == 0){
            tmp = &endDeviceRotTYK;
            tmp2 = &type11AlreadySelectedEndRowTYK;
        }
        
        *tmp = *tmp2;
        
    }
}
#pragma mark 判断是否为离线资源并加入标记
-(void)isOnlineDevice{
    // 是否为在线设备
    NSString * key = [NSString stringWithFormat:@"%@Id",_fileName];
    if ([self.requestDict[key] integerValue] > 0 &&
        [self.requestDict[@"isOnlineDevice"] integerValue] == 0) { // 如果标记过就不重复标记了~
        // 打个标记，上传时使用不同的请求方式
        [self.requestDict setValue:@1 forKey:@"isOnlineDevice"];
        
        //        if ([self.fileName isEqualToString:@"cable"]) {
        //            [self.requestDict setValue:@1 forKey:@"isOnlineSubdevice"];
        //        }
    }
    
}

#pragma mark 更新子资源
-(void)updateSubDivices:(NSDictionary *)dict{
    NSArray * arr = dict[@"info"];
    for (int j = 0; j<arr.count; j++) {
        if([[arr[j] objectForKey:@"deviceId"] intValue]==[[self.requestDict objectForKey:@"deviceId"] intValue]){
            NSMutableArray *subDevicesArr = [[NSMutableArray alloc] initWithArray:[arr[j] objectForKey:@"subDevices"]];
            for (int i = 0; i< subDevicesArr.count; i++) {
                NSMutableDictionary *subDevice = [[NSMutableDictionary alloc] initWithDictionary:subDevicesArr[i]];
                subDevicesArr[i] = subDevice;
                
                [subDevicesArr[i] setObject:[self.requestDict objectForKey:@"poleLineName"] forKey:@"poleLine"];
            }
            [self.requestDict setValue:subDevicesArr forKey:@"subDevices"];
            break;
        }
    }
    
}


/**
 定位界面中进入详情页点击保存后，如果是离线资源的话会跳转到该方法执行
 */
#pragma mark 离线资源保存到本地
-(void)saveLocationDevice{
    
    // 保存到文件
    
    // 取出文件名
    NSString * fileName = self.requestDict[@"resLogicName"];
    // 拼接文件地址
    NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@.data", DOC_DIR, kOffilineData, fileName];
    // 读取文件到data
    NSData * jsonData = [NSData dataWithContentsOfFile:filePath];
    // 取出数组
    NSArray * devices = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil] objectForKey:@"info"];
    
    // 创建保存用数组
    NSMutableArray * saveArr = [NSMutableArray array];
    
    // 遍历资源数组，向保存用数组中添加资源
    
    for (NSDictionary * dict in devices) {
        if ([dict[@"deviceId"] integerValue] ==
            [self.requestDict[@"deviceId"] integerValue]) {
            [saveArr addObject:self.requestDict];
        }else{
            [saveArr addObject:dict];
        }
    }
    // 创建保存字典
    NSDictionary * dict = @{@"info":saveArr};
    
    NSData * data = [DictToString(dict) dataUsingEncoding:NSUTF8StringEncoding];
    
    [data writeToFile:filePath atomically:NO];
    
    
    // 更新地图显示：
    if ([self.delegate respondsToSelector:@selector(didReciveANewDeviceOnMap:isTakePhoto:)]) {
        [self.delegate didReciveANewDeviceOnMap:self.requestDict isTakePhoto:_isTakePhoto];
    }
    
    
    
}

#pragma mark 保存标签按钮点击事件
-(void)saveRFIDButtonHandler:(IWPButton *)sender{
    
    NSString * resLogicName = _fileName;
    
    if ([resLogicName isEqualToString:@"GIDandRFIDrelation"] ||
        [resLogicName isEqualToString:@"rfidInfo"]) {
        [self saveTYKInfoData:YES];
    }else {
        [self saveTYKInfoData:NO];
    }
    
}


//MARK: 袁全新增 所属设备点击事件 暂时只有在放置点(EquipmentPoint)下 才会使用
- (void) EquipmentPointBtnClick {
    
    
    Inc_NewMB_AssistDevCollectVC * assDev = [[Inc_NewMB_AssistDevCollectVC alloc] init];
    
//    assDev.model = _model;
    assDev.requestDict = _requestDict;
    
    Push(self, assDev);
    

}



#pragma mark -  袁全新增 用电管理  ---


- (void) UseElectClick {
    
//    Yuan_UseElectricityVC * useElect = Yuan_UseElectricityVC.alloc.init;
//    useElect.moban_Dict = self.requestDict;
//    Push(self, useElect);
}


#pragma mark -  袁全新增 机房机架  ---

- (void) GeneratorRackConfig {
    
    // 横屏处理
    
//    [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft]
//                                forKey:@"orientation"];
//
//    Yuan_GeneratorRackConfigVC * config = [[Yuan_GeneratorRackConfigVC alloc] init];
//    config.mb_Dict = self.requestDict;
//    Push(self, config);
    
    
    
}



/// 监控

- (void) SiteMonitorList {
    
//    Yuan_SiteMonitorListVC * list = Yuan_SiteMonitorListVC.alloc.init;
//
//    Push(self, list);
}


#pragma mark - 保存按钮点击事件  保存保存保存保存 **** **** **** *** ***

-(void)saveButtonHandler:(IWPButton *)sender {
    
  
    //zzc 2021-6-15  光缆段 纤芯配置   业务状态修改  需要添加接口判断
    if ([self.fileName isEqualToString:@"optPair"] ) {
        
        if (![oldOprStateId isEqualToString:self.requestDict[@"oprStateId"]]) {
            [self Http_UpdateOprState:@{
                @"gid":self.requestDict[@"GID"],
                @"resType":@"pair",
                @"oprStateId":[self getOprStateId:self.requestDict[@"oprStateId"]]
            }];
        }else {
            if (self.isGenSSSB) {
                [self saveTYKInfoData:NO];
                return;
            }// 2006-01-06 22:01:00
            
            
            [self saveTYKInfoData:NO];
        }
        
    }
    /// 袁全 2022.3.3新增 局向光纤业务状态修改时的判断
    else if ([self.fileName isEqualToString:@"optLogicPair"]) {
        if (![oldOprStateId isEqualToString:self.requestDict[@"oprStateId"]]) {
            [self Http_UpdateOprState:@{
                @"gid":self.requestDict[@"GID"],
                @"resType":@"logicOptPair",
                @"oprStateId":[self getOprStateId:self.requestDict[@"oprStateId"]]
            }];
        }else {
            if (self.isGenSSSB) {
                [self saveTYKInfoData:NO];
                return;
            }// 2006-01-06 22:01:00
            
            
            [self saveTYKInfoData:NO];
        }
        
    }
    
    
    //zzc 2021-6-16 ODF、OCC和ODB 模版端子面板详情  业务状态修改  需要添加接口判断
    else if ([self.fileName isEqualToString:@"opticTerm"]) {
        if (![oldOprStateId isEqualToString:self.requestDict[@"oprStateId"]]) {
            [self Http_UpdateOprState:@{
                @"gid":self.requestDict[@"GID"],
                @"resType":@"optTerm",
                @"oprStateId":[self getOprStateId:self.requestDict[@"oprStateId"]]
            }];
        }else {
            if (self.isGenSSSB) {

                [self saveTYKInfoData:NO];
                return;
            }// 2006-01-06 22:01:00
            
            
            [self saveTYKInfoData:NO];
        }
        
    }
    //其他
    else {
        if (self.isGenSSSB) {
            [self saveTYKInfoData:NO];
            return;
        }// 2006-01-06 22:01:00
        
        
        [self saveTYKInfoData:NO];
    }
    
}

#pragma mark 转离线保存入口
-(void)showOfflineHint{
    
    
    
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前网络状态较差，是否将该设备的信息保存到本地？" message:@"您可以在网络通畅时手动上传\n离线保存时不会保存该资源在线的图片\n进入详情页中您也不会看到任何在线图片\n新增的离线图片可以正常显示\n新增的离线图片会随着离线资源一起上传。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * sure = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.isOffline = YES;
        if ([self.fileName isEqualToString:@"well"] ||
            [self.fileName isEqualToString:@"pole"] ||
            [self.fileName isEqualToString:@"markStone"]) {
            [self.requestDict setValue:@1 forKey:@"isOnlineSubdevice"];
        }
        [self saveButtonHandler:nil];
        
        // 这里判断是否为电杆、井、标石转离线
        
        
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:sure];
    [alert addAction:cancel];
    
    Present(self, alert);
    
}
#pragma mark 判断某资源是否为离线资源
-(BOOL)isOfflineDevice:(NSDictionary *)dict{
    // 判断该设备是否为离线设备
    if ([dict[@"deviceId"] integerValue] > 0) {
        return YES;
    }
    return NO;
}
#pragma mark 判断请求用字典是否为离线资源
-(BOOL)isOfflineDevice{
    return [self.requestDict[@"deviceId"] integerValue] > 0;
}


#pragma mark OLT面板按钮点击事件
-(void)showOLTMianBanHandler:(IWPButton *)sender{
    
    [YuanHUD HUDFullText:@"到这了showOLTMianBanHandler"];
    if ([self isOfflineDevice]) {

        [YuanHUD HUDFullText:@"离线模式下不可用"];

        return;
    }
    
    if ((_controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
    }else{
//        ModelUIViewController *oltEquModelVC = [[ModelUIViewController alloc] init];
//        oltEquModelVC.equId = [NSString stringWithFormat:@"%@",self.requestDict[[NSString stringWithFormat:@"%@Id",_fileName]]];
//        oltEquModelVC.equtName = [NSString stringWithFormat:@"%@",self.requestDict[@"mixEqutName"]];
//        [self.navigationController pushViewController:oltEquModelVC animated:YES];
        
    }
}
#pragma mark ODF面板按钮点击事件
-(void)showODFMianBanHandler:(IWPButton *)sender{
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    
    if ((self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前ODF信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
    
    
    ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
    resourceTYKListVC.dicIn = [self.requestDict mutableCopy];
    resourceTYKListVC.fileName = @"cnctShelf";
    resourceTYKListVC.sourceFileName = self.fileName;
    resourceTYKListVC.showName = @"列/框";
    [self.navigationController pushViewController:resourceTYKListVC animated:YES];
}
#pragma mark 列框下模块按钮点击事件
-(void)moduleInfoHandler:(IWPButton *)sender{
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    
    if ((self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前列框信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
    ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
    resourceTYKListVC.dicIn = [self.requestDict mutableCopy];
    resourceTYKListVC.fileName = @"module";
    resourceTYKListVC.showName = @"模块";
    resourceTYKListVC.sourceFileName = self.sourceFileName;
    [self.navigationController pushViewController:resourceTYKListVC animated:YES];
}
#pragma mark模块下端子按钮点击事件
-(void)opticTermInfoHandler:(IWPButton *)sender{
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    
    if ((self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前列框信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
    ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
    resourceTYKListVC.dicIn = [self.requestDict mutableCopy];
    resourceTYKListVC.fileName = @"opticTerm";
    resourceTYKListVC.showName = @"端子";
    resourceTYKListVC.sourceFileName = self.sourceFileName;
    [self.navigationController pushViewController:resourceTYKListVC animated:YES];
}
#pragma mark 配置端口按钮点击事件
-(void)showPeizhiDuankouHandler:(IWPButton *)sender{
    
    UIView * cover = [[UIView alloc] initWithFrame:self.view.bounds];
    cover.tag = 918029830;
    cover.backgroundColor = [UIColor colorWithHexString:@"#7a000000"];
    cover.alpha = 0.f;
    [self.view addSubview:cover];
    [UIView animateWithDuration:.2f animations:^{
        cover.alpha = 1.f;
    }];
    
    
    CGFloat tmpX,tmpY,tmpW,tmpH, paddingHo = ScreenWidth / 6.f, paddingVe = ScreenHeight / 4.f;
    
    
    tmpY = ScreenHeight;
    tmpW = ScreenWidth - 2 * paddingHo;
    tmpX = paddingHo;
    tmpH = 0;
    
    
    UIView * window = [[UIView alloc] initWithFrame:CGRectMake(tmpX, tmpY, tmpW, tmpH)];
    [self.view addSubview:window];
    
    window.layer.cornerRadius = 10.f;
    window.layer.masksToBounds = YES;
    window.layer.borderColor = [UIColor mainColor].CGColor;
    window.layer.borderWidth = 2.f;
    
    window.layer.shadowColor = [UIColor colorWithHexString:@"#eee"].CGColor;
    window.layer.shadowOpacity = 1.f;
    window.layer.shadowOffset = CGSizeMake(10, 10);
    
    window.backgroundColor = [UIColor colorWithHexString:@"#ccc"];
    window.tag = 99282222;
    NSArray * titles = @[@"*起始纤芯序组",@"*终止纤芯序组",@"*起始设备起始端口",@"*终止设备起始端口"];
    NSArray * keys = @[@"startCoreSequenceGroup",@"endCoreSequenceGroup",@"cableStartStartPoint",@"cableEndStartPoint"];
    NSArray * placeholders = @[@"起始纤芯序组",@"终止纤芯序组",@"起始设备起始端口",@"终止设备起始端口"];
    
    for (int i = 0; i < titles.count; i++) {
        [self createANewLabel:titles[i] withSuperView:window];
        [self createATextViewWithSuperView:window withKey:keys[i] withPlaceholder:placeholders[i]];
    }
    
    
    tmpX = 0;
    tmpY = [self getAY:window] + 5.f;
    tmpW = window.frame.size.width / 2.f;
    tmpH = 40.f;
    
    IWPButton * save = [IWPButton buttonWithType:UIButtonTypeSystem];
    save.frame = CGRectMake(tmpX, tmpY, tmpW, tmpH);
    
    save.titleLabel.font = [UIFont systemFontOfSize:14];
    [save addTarget:self action:@selector(mianbanSaveButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [save setBackgroundColor:[UIColor mainColor]];
    [save setTitle:@"保存" forState: UIControlStateNormal];
    [save setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:save];
    
    
    tmpX = CGRectGetMaxX(save.frame);
    
    IWPButton * cancle = [IWPButton buttonWithType:UIButtonTypeSystem];
    cancle.frame = CGRectMake(tmpX, tmpY, tmpW, tmpH);
    
    cancle.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancle addTarget:self action:@selector(mianbanCancleButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [cancle setBackgroundColor:[UIColor mainColor]];
    [cancle setTitle:@"取消" forState:UIControlStateNormal];
    [cancle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:cancle];
    
    [window addSubview:save];
    [window addSubview:cancle];
    
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(save.frame) - .7f/2.f, save.frame.origin.y, .7f, save.bounds.size.height)];
    
    line.backgroundColor = [UIColor colorWithHexString:@"#ccc"];
    
    [window addSubview:line];
    
    
    tmpH = CGRectGetMaxY(save.frame);
    
    CGPoint center = window.center;
    center.y = self.view.center.y;
    
    
    
    CGRect frame = window.frame;
    
    frame.size.height = tmpH;
    window.frame = frame;
    
    frame = window.frame;
    frame.origin.y = paddingVe;
    [UIView animateWithDuration:.5f animations:^{
        window.frame = frame;
        window.center = center;
    }];
}

#pragma mark 在某个视图中获取最大Y坐标
-(CGFloat)getAY:(UIView *)superView{
    
    CGFloat maxY = 0.0;
    for (__kindof UIView * tmpView in superView.subviews) {
        if (tmpView.tag >= 10000) {
            if (CGRectGetMaxY(tmpView.frame) > maxY) {
                maxY = CGRectGetMaxY(tmpView.frame);
            }
        }
    }
    return maxY;
}
#pragma mark 光缆段端口号创建标签
-(void)createANewLabel:(NSString *)title withSuperView:(UIView *)superView{
    xTYK = marginTYK / 2.f;
    hTYK = 25.f;
    yTYK = [self getAY:superView];
    IWPLabel * label = [[IWPLabel alloc] initWithFrame:CGRectMake(xTYK,yTYK,wTYK,hTYK)];
    label.tag = tagTYK++;
    
    label.text = title;
    label.textColor = [UIColor mainColor];
    label.font = [UIFont systemFontOfSize:13];
    label.backgroundColor = [UIColor clearColor];
    
    
    CGRect frame = label.frame;
    frame.size.width = [self sizeWithString:label.text withFont:label.font].width + 2.f;
    frame.size.height = [self sizeWithString:label.text withFont:label.font].height + 4.f;
    label.frame = frame;
    [superView addSubview:label];
    
}
#pragma mark 光缆断端口号创建编辑框
-(void)createATextViewWithSuperView:(UIView *)superView withKey:(NSString *)key  withPlaceholder:(NSString *)placeholder{
    xTYK = 5.f;
    yTYK = [self getAY:superView];
    hTYK = 30;
    wTYK = superView.bounds.size.width - 10.f;
    
    IWPTextView * textView = [[IWPTextView alloc] initWithFrame:CGRectMake(xTYK,yTYK,wTYK,hTYK)];
    textView.key = key;
    textView.shouldEdit = YES;
    textView.placeholder = placeholder;
    textView.tag = tagTYK++;
    textView.delegate = self;
    textView.font = [UIFont systemFontOfSize:13];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = .5f;
    textView.layer.cornerRadius = 5.f;
    textView.layer.masksToBounds = YES;
    textView.text = _requestDict[key];
    textView.returnKeyType = UIReturnKeyDone;
    textView.keyboardType = UIKeyboardTypeNumberPad;
    
    
    [superView addSubview:textView];
}


#pragma mark 光缆段端口号关闭键盘
-(void)mianbanKeyboardClose{
    __weak UIView * view = [self.view viewWithTag:99282222];
    IWPTextView * qsxx;
    IWPTextView * zzxx;
    IWPTextView * qssbqsdk;
    IWPTextView * zzsbqsdk;
    
    for (__kindof UIView * textView in view.subviews) {
        if ([textView isKindOfClass:[IWPTextView class]]) {
            IWPTextView * tv = textView;
            if ([tv.key isEqualToString:@"startCoreSequenceGroup"]) {
                qsxx = tv;
            }
            if ([tv.key isEqualToString:@"endCoreSequenceGroup"]) {
                zzxx = tv;
            }
            if ([tv.key isEqualToString:@"cableStartStartPoint"]) {
                qssbqsdk = tv;
            }
            if ([tv.key isEqualToString:@"cableEndStartPoint"]) {
                zzsbqsdk = tv;
            }
        }
    }
    [qsxx resignFirstResponder];
    [zzxx resignFirstResponder];
    [qssbqsdk resignFirstResponder];
    [zzsbqsdk resignFirstResponder];
}
#pragma mark 光缆段端口号保存按钮点击事件
-(void)mianbanSaveButtonHandler:(IWPButton *)sender{
    __weak UIView * view = [self.view viewWithTag:99282222];
    IWPTextView * qsxx;
    IWPTextView * zzxx;
    
    for (__kindof UIView * textView in view.subviews) {
        if ([textView isKindOfClass:[IWPTextView class]]) {
            IWPTextView * tv = textView;
            if ([tv.key isEqualToString:@"startCoreSequenceGroup"]) {
                qsxx = tv;
            }
            if ([tv.key isEqualToString:@"endCoreSequenceGroup"]) {
                zzxx = tv;
            }
            
            [self.requestDict setValue:tv.text forKey:tv.key];
        }
    }
    if (qsxx!=nil && zzxx!=nil) {
        if ([qsxx.text isEqualToString:@""]||[zzxx.text isEqualToString:@""]) {
         
            [YuanHUD HUDFullText:@"请填写起始或终止纤芯序组"];
            
            return;
        }else{
            int qsnum = [qsxx.text intValue];
            int zznum = [zzxx.text intValue];
            if (qsnum>zznum) {
                
                [YuanHUD HUDFullText:@"起始纤芯序组不可以大于终止纤芯序组"];

                return;
            }
        }
    }
    
    [self mianbanCancleButtonHandler:nil];
}
#pragma mark 光缆段端口号取消按钮点击事件
-(void)mianbanCancleButtonHandler:(IWPButton *)sender{
    
    __weak UIView * view = [self.view viewWithTag:99282222];
    __weak UIView * cover = [self.view viewWithTag:918029830];
    [UIView animateWithDuration:.5f animations:^{
        CGRect frame = view.frame;
        frame.origin.x /= 2.f;
        view.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3f animations:^{
            CGRect frame = view.frame;
            frame.origin.x = ScreenWidth;
            view.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.2f animations:^{
                cover.alpha = 0.f;
            } completion:^(BOOL finished) {
                [cover removeFromSuperview];
                [view removeFromSuperview];
            }];
        }];
    }];
    
}

#pragma mark 机房下属设备板卡按钮点击事件
-(void)showBANKAInfo:(IWPButton *)sender{
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    if ((_controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
    ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
    resourceTYKListVC.dicIn = self.requestDict;
    resourceTYKListVC.fileName = @"card";
    resourceTYKListVC.showName = @"板卡";
    [self.navigationController pushViewController:resourceTYKListVC animated:YES];
}
#pragma mark 机房下属设备模块按钮点击事件
-(void)showMOKUAIInfo:(IWPButton *)sender{
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    if ((_controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
    ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
    resourceTYKListVC.dicIn = self.requestDict;
    resourceTYKListVC.fileName = @"shelf";
    resourceTYKListVC.showName = @"机框";
    [self.navigationController pushViewController:resourceTYKListVC animated:YES];
}
#pragma mark 机房下属设备平面图按钮点击事件
-(void)showEquModel:(IWPButton *)sender{
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    if ((_controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
    EquModelTYKViewController *equModelTYKListVC = [[EquModelTYKViewController alloc] init];
    equModelTYKListVC.dicIn = self.requestDict;
    [self.navigationController pushViewController:equModelTYKListVC animated:YES];
}


#pragma mark 面/孔按钮点击事件
-(void)faceHoleHandler:(IWPButton *)sender{
    
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    
    if ((_controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
    }else{
        [UIAlert alertSmallTitle:@"这里出问题了？FaceNewCodeAutoViewController"];

//        FaceNewCodeAutoViewController * faceNew = [[FaceNewCodeAutoViewController alloc] init];
//        faceNew.wellInDic = [self.requestDict mutableCopy];
//        [self.navigationController pushViewController:faceNew animated:YES];
    }
}
#pragma mark 删除按钮点击事件
-(void)deleteDeviceWithDict:(NSDictionary *)dict{
    if ((self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"请在保存后再进行删除操作" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
    }else{
        // 删除该ODF设备
        [self deleteODFWithDict:dict withClass:self.class];
    }
}
#pragma mark 删除ODF
-(void)deleteODFWithDict:(NSDictionary *)dict withClass:(Class)class{
    // 删除事件
#ifdef BaseURL
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL, _model.delete_name];
#else
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL_Auto(([IWPServerService sharedService].link)), _model.delete_name];
#endif
    //    NSLog(@"%@",requestURL);
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
//
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
//
//    NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [param setValue:UserModel.uid forKey:@"UID"];
//    [param setValue:str forKey:@"jsonRequest"];
    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"删除成功" message:nil preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
                [self.navigationController popViewControllerAnimated:YES];

            }];
        
        [alert addAction:action];
        Present(self.navigationController, alert);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
    
    
}

-(void)deleteStationButtonHandler:(IWPButton *)sender{
    // 調用代理方法
    
    
    NSLog(@"%@", self.delegate);
    
    
    
    
    
    if ((self.controlMode == TYKDeviceListInsert||
         self.controlMode == TYKDeviceListInsertRfid) &&
        isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"请在保存后再进行删除操作" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
    }else if ([self.delegate respondsToSelector:@selector(deleteDeviceWithDict:withViewControllerClass:)] == YES) {
        
        [self.delegate deleteDeviceWithDict:self.requestDict withViewControllerClass:[self class]];
        NSArray *array = [self.navigationController viewControllers];
        [self.navigationController popViewControllerAnimated:YES];

//
//        if (![[array objectAtIndex:array.count-2] isKindOfClass:[OpenLockViewController class]]){
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        if (![[array objectAtIndex:array.count-2] isKindOfClass:[GridAndUnitViewController class]]){
//            [self.navigationController popViewControllerAnimated:YES];
//        }
    }
    
    
    if (self.delegate == nil) {
        
        
        //        [self deleteDevice:self.requestDict withClass:self.class];
        
//        [self deleteDevice:self.requestDict];
        
        [self noDelegate_Delete];
        
    }
    
}

- (void) noDelegate_Delete {
    
    
    [UIAlert alertSmallTitle:@"是否删除?" agreeBtnBlock:^(UIAlertAction *action) {
    
        [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Delete dict:_requestDict succeed:^(id data) {
            
            [YuanHUD HUDFullText:@"删除成功"];
        
            //odf 删除  没有走代理的情况  目前Zhang_ODFListVC使用
            if ([self.fileName isEqualToString:@"ODF_Equt"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ODFSuccessful" object:nil];

            }
            
            Pop(self);
        }];
        
    }] ;
    
    
}


-(void)showBeizhu:(IWPButton *)sender{
    
    
    sender.selected = !sender.selected;
    for (int i = 0; i < self.contentView.subviews.count; i++) {
        id view = self.contentView.subviews[i];
        if ([view isKindOfClass:[UILabel class]]) {
            IWPLabel * label = view;
            if (label.hiddenTag > 0) {
                label.hidden = !label.hidden;
            }
        }
        
        if ([view isKindOfClass:[UIButton class]]) {
            IWPButton * button = view;
            if (button.hiddenTag > 0) {
                button.hidden = !button.hidden;
            }
        }
        
        if ([view isKindOfClass:[IWPTextView class]]) {
            IWPTextView * textView = view;
            if (textView.hiddenTag > 0) {
                textView.hidden = !textView.hidden;
            }
        }
        
    }
    
    [self resetContentSize];
}





#pragma mark -   yuan 通用的删除事件 ---

- (void) Yuan_NormalDelete {
    
    
    if (_controlMode == TYKDeviceListInsert || _controlMode == TYKDeviceListInsertRfid) {
        // 新建状态
        
        [[Yuan_HUD shareInstance] HUDFullText:@"当前是新建模式,请不要进行删除操作"];
        return;
    }
    
    
    // 删除光缆段内的纤芯事件
    [[Yuan_HUD shareInstance] HUDFullText:@"正在删除，请稍候……"];


    NSString * deleteUrl = @"rm!deleteCommonData.interface";

    // 删除事件
    #ifdef BaseURL
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL, deleteUrl];
    #else
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL_Auto(([IWPServerService sharedService].link)), deleteUrl];
    #endif
    NSLog(@"%@",requestURL);

    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setValue:UserModel.uid forKey:@"UID"];

    __weak typeof(self) wself = self;

    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        NSDictionary * dict = responseObject;
                
        if (![dict[@"result"] boolValue]) {
            /* 删除成功 */
            
            [wself dismisSelf];

            [YuanHUD HUDFullText:@"删除成功"];
            
            // 当光缆段纤芯时回调
            if (_Yuan_CFBlock) {
                [wself.navigationController popViewControllerAnimated:YES];
                
                _Yuan_CFBlock(@{});
            }
            
        }else{
            [YuanHUD HUDFullText:@"删除失败"];
            
        }
        
        
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
        
    
    
}


#pragma mark -  光缆段纤芯配置 袁全添加 2020.07.21 ---

- (void) cableFiberConfigClick{
    
    
    // GID 和 CableId 相同
    NSString * cableId = [self.requestDict objectForKey:@"GID"];
    
    if (!cableId || [cableId isEqual:[NSNull null]]) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"请先保存光缆段,再进行纤芯配置"];
        return;
    }
    
    
    NSString * cableStart_Id = [self.requestDict objectForKey:@"cableStart_Id"];
    NSString * cableEnd_Id = [self.requestDict objectForKey:@"cableEnd_Id"];

    
    if (!cableStart_Id || !cableEnd_Id) {
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少光缆段起始或终止设备Id"];
//        return;
    }
    
    
    
    Inc_CFListController * cf_list = [[Inc_CFListController alloc] initWithCableId:cableId];
    
    NSLog(@"%@",self.requestDict);
    
    cf_list.moban_Dict = self.requestDict;
    
    Push(self, cf_list);
    
}


#pragma mark - 批量撤缆 袁全添加 2021.01.13 ---

- (void) cableDeleteCableClick {
    
    Yuan_DeleteCableVC * deleteCable_Gis =  [[Yuan_DeleteCableVC alloc] init];
    
    deleteCable_Gis.mb_Dict = _requestDict;
    
    
    Push(self, deleteCable_Gis);
}


#pragma mark -  统一库拍照 袁全添加 2020.08.25  ---

- (void) Yuan_PhtotClick {
    
    
    Yuan_TYKPhotoVC * vc = Yuan_TYKPhotoVC.alloc.init;
    
    vc.moban_Dict = self.requestDict;
    
    Push(self, vc);
}


#pragma mark - 管道段 承载缆段和子孔   ---

// 承载缆段 点击事件
- (void) Yuan_ChengZ_CableClick {
    
    Yuan_bearingCablesList * list = Yuan_bearingCablesList.alloc.init;
    list.requestDict = self.requestDict;
    list.isNeed_isFather = _isNeed_isFather;
    Push(self, list);
}



// 子孔点击事件
- (void) Yuan_subHoleClick {
    
    ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
    resourceTYKListVC.dicIn = self.requestDict;
    resourceTYKListVC.fileName = @"tube";
    resourceTYKListVC.showName = @"管孔";
    resourceTYKListVC.isNeed_isFather = YES;
    resourceTYKListVC.fatherPore_Id = self.requestDict[@"GID"];
    [self.navigationController pushViewController:resourceTYKListVC animated:YES];
    
}




#pragma mark -  端子 光纤光路和局向光纤  ---

// 光纤光路 入口   *** 已废弃  Yuan 2021.7.6
- (void) yuan_Opticalink {
    
    if (!_requestDict[@"GID"]) {
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少必要的GID"];
        return;
    }
    
    Yuan_FL_ListVC * list = [[Yuan_FL_ListVC alloc] initWithEnum:FL_InitType_OpticalLink];
    list.opticTermId = _requestDict[@"GID"];
    Push(self, list);
}



// 局向光纤 入口   *** 已废弃  Yuan 2021.7.6
- (void) yuan_OpticalFiber {
    
    if (!_requestDict[@"GID"]) {
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少必要的GID"];
        return;
    }
    
    Yuan_FL_ListVC * list = [[Yuan_FL_ListVC alloc] initWithEnum:FL_InitType_OpticalFiber];
    list.opticTermId = _requestDict[@"GID"];
    Push(self, list);
}


// 端子查看光路 入口
- (void) zhang_Opticallight {
    
    if (!_requestDict[@"GID"]) {
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少必要的GID"];
        return;
    }

    //
    [self Http_SelectRoadInfoByTermPairId:@{
        @"type":@"optTerm",
        @"id":_requestDict[@"GID"]
    }];

    
}

// 纤芯查看光路 入口
- (void) zhang_OpticalPair {
    
    if (!_requestDict[@"GID"]) {
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少必要的GID"];
        return;
    }

    //
    [self Http_SelectRoadInfoByTermPairId:@{
        @"type":@"optPair",
        @"id":_requestDict[@"GID"]
    }];

    
}

//导航
- (void) zhang_Navi {
    
    if ([_requestDict[@"lat"] doubleValue] != 0 && [_requestDict[@"lon"] doubleValue] != 0) {
        AMapNaviCompositeUserConfig *config = [[AMapNaviCompositeUserConfig alloc] init];

        [config setRoutePlanPOIType:AMapNaviRoutePlanPOITypeEnd location:[AMapNaviPoint locationWithLatitude:[_requestDict[@"lat"] doubleValue] longitude:[_requestDict[@"lon"] doubleValue]] name:@"目标位置" POIId:nil];  //传入终点
        [self.compositeManager presentRoutePlanViewControllerWithOptions:config];
    }else{
        [YuanHUD HUDFullText:@"请先获取经纬度"];
    }
    
 
}


//复制
- (void) zhang_copy{
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_copyDic];
    
    NSArray *array = @[@"GID",@"intBoxCode",@"intBoxName",@"odbName",@"jntBoxNo",@"rackName",@"rackNo",@"occName",@"occCode",@"lat",@"lon",@"addr",@"rfid"];
    
    for (NSString *str in array) {
        if ([dict.allKeys containsObject:str]) {
            [dict removeObjectForKey:str];
        }
    }
    

    TYKDeviceInfoMationViewController *device = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListInsertRfid withMainModel:_copyModel withViewModel:_copyViewModel withDataDict:dict withFileName:self.fileName];
    device.isCopy = YES;
    device.delegate = self;
    device.gId = _requestDict[@"GID"];
    device.sourceFileName = self.sourceFileName;
    [self.navigationController pushViewController:device animated:YES];
    
}
//复制保存
- (void)zhang_copySave {
    
    [self saveButtonHandler:nil];

}

#pragma mark - 新版局向光纤 和 光纤光路 ---

// 通过端子Id 查询所属光路路由
- (void) New2021_LinkFromTerminalId {
    
    [Yuan_NewFL_HttpModel Http_SearchLinkRouteFromTerminalId:_requestDict[@"GID"]
                                                     success:^(id  _Nonnull result) {
            
        
        NSDictionary * dict = result;
        
        if (!dict || dict.count == 0) {
            [YuanHUD HUDFullText:@"未查询到所属光路"];
            return;
        }
        
        
        Yuan_NewFL_LinkVC * vc = [[Yuan_NewFL_LinkVC alloc] initFromTerminalId_SelectFiberLinkDatas:dict];
        
        Push(self, vc);
        vc.MB_Dict = _requestDict;
        
    }];
    
}


/// 根据端子Id 查询所属局向光纤.
- (void) New2022_RouteFromTerminalId {
  
    [Yuan_NewFL_HttpModel Http3_SelectRouteFromTerFibDict:@{@"nodeId" : _requestDict[@"GID"]}
                                                  success:^(id result) {
            
        NSDictionary * resDic = result;
        NSDictionary * optLogicOptPair = resDic[@"optLogicOptPair"];
        NSString * pairId = optLogicOptPair[@"pairId"];
        
        if (!pairId) {
            [YuanHUD HUDFullText:@"未找到所属局向光纤"];
            return;
        }
        
        Yuan_NewFL_RouteVC * route = [[Yuan_NewFL_RouteVC alloc] init];
        route.routeId = pairId;
        Push(self, route);
        
    }];
    
}



// 光路
- (void) New2021_OpticalLink {
    
    Yuan_NewFL_LinkVC * vc = [[Yuan_NewFL_LinkVC alloc] init];
    Push(self, vc);
    vc.MB_Dict = _requestDict;
}

/// 局向光纤
- (void) New2021_OpticalRoute {
    
    Yuan_NewFL_RouteVC * vc = [[Yuan_NewFL_RouteVC alloc] init];
    Push(self, vc);
    vc.MB_Dict = _requestDict;
    vc.routeId = _requestDict[@"GID"];
}


#pragma mark - 分光器入口 2021.4.14---


- (void) New2021_OBD_Equt {
    
    Inc_NewMB_ListVC * list = [[Inc_NewMB_ListVC alloc] initWithModelEnum:Yuan_NewMB_ModelEnum_obd];
    
    NSString * resTypeId = @"";
    
    NSString * resLogicName = _requestDict[@"resLogicName"];
    
    if ([resLogicName isEqualToString:@"OCC_Equt"]) {
        resTypeId = @"703";      // 703
    }
    
    else if ([resLogicName isEqualToString:@"ODB_Equt"]) {
        resTypeId = @"704";      //704
    }
    
    else if ([resLogicName isEqualToString:@"ODF_Equt"]) {
        resTypeId = @"302";      //302
    }
    
    else {
        return;
    }
    
    NSDictionary * insertDict = @{
        
        @"positId" : _requestDict[@"GID"],
        @"positTypeId" : resTypeId,
        @"positName" : _requestDict[_model.list_sreach_name]
    };
    
    list.insertDict = insertDict;
    
    //zzc 2021-9-16 根据positTypeId 对应查询分光器列表
    NSDictionary * selectDict = @{
        @"positTypeId" : resTypeId
    };
    list.selectDict = selectDict;

    Push(self, list);
}



// OLT 模板
- (void) MB_OLT {
    
//    ModelUIViewController *oltEquModelVC = [[ModelUIViewController alloc] init];
//    oltEquModelVC.equId = _requestDict[@"GID"];
//    oltEquModelVC.equtName = [NSString stringWithFormat:@"%@",self.requestDict[@"mixEqutName"]];
//    [self.navigationController pushViewController:oltEquModelVC animated:YES];
    
}


// 局站下属机房
- (void) stationBase_SelectSubGenerator {
    
    
    Inc_BS_SubGeneratorListVC * vc = [[Inc_BS_SubGeneratorListVC alloc] init];
    
    vc.GID = _requestDict[@"GID"];
    
    Push(self, vc);
}


// 局站、机房、设备放置点下属设备
- (void) stationBase_Equipment {
    [YuanHUD HUDFullText:@"到这了Inc_NewMBEquipCollectVC"];
//    Inc_NewMBEquipCollectVC * equip = [[Inc_NewMBEquipCollectVC alloc] init];
//    equip.title = @"下属设备";
//    equip.gid = _requestDict[@"GID"];
//    equip.requestDict = _requestDict;
//
//    [self.navigationController pushViewController:equip animated:true];
  
}


#pragma mark IWPTextViewDelegate

-(void)textViewDidEndEditing:(UITextView *)textView{
    // 辞去第一响应者
    [textView resignFirstResponder];
    UIButton * showZeroButton = [[self.contentView viewWithTag:981273987] viewWithTag:0xffff];
    IWPTextView * textView2 = [[self.contentView viewWithTag:981273987] viewWithTag:9817278];
    if (textView.tag == textView2.tag) {
        showZeroButton.hidden = NO;
        showZeroButton.selected = NO;
        /* 结束编辑时，自动隐藏0 */
        //         IWPTextView * textView2 = [[self.contentView viewWithTag:981273987] viewWithTag:9817278];
        textView.text = [textView.text deleteZeroString];
        
    }
    
}

-(void)textViewDidChange:(IWPTextView *)textView{
    // 当值发生改变时，将改变的数据实时写入请求字典
    if (textView.key) {
        [self.requestDict setValue:textView.text forKey:textView.key];
    }
    
    NSLog(@"self.requestDict[%@] = %@", textView.key,self.requestDict[textView.key]);
    
    // 编辑时, 使通用编辑框的内容随之改变
    self.universalTextView.text = textView.text;
    
    if (textView.key) {
        NSRange range = [_model.subName rangeOfString:textView.key];
        
        if (type9TagTYK > nDefaultType9Tag && !textView.isType9 && range.length > 0) {
            // 拼名
            [self subNameCreate];
        }else{
            if ([_model.subName rangeOfString:@"preName"].length > 0 && !textView.isType9) {
                [self subNameCreate];
            }
        }
    }
    
    
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        // 辞去第一响应者
        [textView resignFirstResponder];
        return NO;
    }
    
    if ([textView isKindOfClass:[IWPTextView class]]) {
        IWPTextView * tv = (IWPTextView *)textView;
        if ([tv.key isEqualToString:@"startCoreSequenceGroup"]||[tv.key isEqualToString:@"endCoreSequenceGroup"]||[tv.key isEqualToString:@"cableStartStartPoint"]||[tv.key isEqualToString:@"cableEndStartPoint"]) {
            return [self validateNumber:text];
        }
        
    }
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    // 类型转换
    __weak IWPTextView * tv = (IWPTextView *)textView;
    
    IWPTextView * textView2 = [[self.contentView viewWithTag:981273987] viewWithTag:9817278];
    UIButton * showZeroButton = [[self.contentView viewWithTag:981273987] viewWithTag:0xffff];
    
    /* 判断激活的编辑框是否为二维码扫描，如果是，需要先显示带有0的内容 */
    
    if (textView == textView2) {
        /* 编辑过程中禁止改变 */
        showZeroButton.hidden = YES;
        
        if (!showZeroButton.selected) {
            /* 当用户没有点击显示0按钮时进行原值显示 */
            textView2.text = self.requestDict[textView2.key];
            /* 并选中按钮 */
            showZeroButton.selected = YES;
        }
        
    }
    
    
    // 若tv允许被编辑
    if (tv.shouldEdit) {
        // 隐藏激活的picker
        [self dismisView];
        if (textView.tag != (0xABD + 2)) {
            [self cancleButtonHandler:nil];
        }
        
        
        // 创建通用编辑框
        if (self.universalTextView == nil) {
            // 为空则创建
            self.universalTextView = [[IWPUniversalTextView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 50)];
            
            //            if (textView.tag == (0xABD + 2)) {
            self.universalTextView.textEditor = textView;
            //            }
            
            // 使其内容等于即将被编辑的编辑框的内容
            self.universalTextView.text = textView.text;
            self.universalTextView.placeHolder = tv.placeholder;
            [self.view addSubview:self.universalTextView];
        }else{
            // 不为空则改变值
            self.universalTextView.text = textView.text;
            self.universalTextView.placeHolder = tv.placeholder;
            self.universalTextView.textEditor = textView;
        }
        return YES;
    }
    
    return NO;
}

#pragma mark IWPDeviceListDelegate


-(void)deviceWithDict:(NSDictionary *)dict withSenderTag:(NSInteger)senderTag{
    // 取出按钮和编辑框
    __weak IWPTextView * textView = [self.contentView viewWithTag:senderTag - 1];
    __weak IWPButton * button = [self.contentView viewWithTag:senderTag];
    textView.text = dict[button.key]; // 取內容
    
    if (textView.isType11) {
        // 意味著這是type11
        NSInteger index = 0;
        // 取出sender所属的label
        __weak IWPLabel * label = [self.contentView viewWithTag:currentTagTYK - 2];
        
        
        // 判断是起始设备还是终止设备
        NSRange range = [label.text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"起始"]];
        
        if (range.length != 0) {
            index = startDeviceRowTYK;
            isStartDeviceTYK = YES;
        }else{
            if ([self.fileName isEqualToString:@"OBD_Equt"]) {
                index = deviceRow;
            }else{
                index = endDeviceRotTYK;
                isStartDeviceTYK = NO;
            }
            
        }
        
        NSDictionary * name4 = self.getFileNames[index - 1]; //依據picker當前選中項取出對應字典
        
        // 設備名
        textView.text = (NSString *)dict[name4[@"deviceName"]];
        [self.requestDict setValue:dict[name4[@"deviceName"]] forKey:textView.name2];
        // 設備ID
        [self.requestDict setValue:dict[@"GID"] forKey:textView.name3];
        
        //光缆段起止设施为接头盒时，弹出扫描二维码界面供用户进行扫码（类似穿缆绑标签）
        if ([self.fileName isEqualToString:@"cable"]) {
            NSString * fileName = [self.getFileNames[index - 1] valueForKey:@"type"];
            NSLog(@"fileName:%@",fileName);
            if ([fileName isEqualToString:@"joint"]) {
                
                [UIAlert alertSmallTitle:@"到这了?BindTubeRfidUIViewController"];
//                BindTubeRfidUIViewController *bindTubeRfidVC = [[BindTubeRfidUIViewController alloc] init];
//                [self.navigationController pushViewController:bindTubeRfidVC animated:YES];
            }
        }
        
    }else{
        if ([self.fileName isEqualToString:@"ODB_Equt"]) {
            NSLog(@"----%@",dict);
            NSLog(@"1:%@,2:%@",textView.key,dict[textView.name4]);
            NSLog(@"3:%@,4:%@",dict[@"spcGridId"],self.requestDict[@"ssSpcGrid_Id"]);
            if ([textView.key isEqualToString:@"ssSpcGrid"] &&!([dict[@"spcGridId"] isEqualToString:self.requestDict[@"ssSpcGrid_Id"]])) {
                //如果odb的所属网格有变更，下面的所属建筑/单元/楼层全要为空
                for (int i = 0; i < self.contentView.subviews.count; i++) {
                    if ([self.contentView.subviews[i] isKindOfClass:[IWPTextView class]]) {
                        IWPTextView * textView = self.contentView.subviews[i];
                        if ([textView.name2 isEqualToString:@"spcBuildingsId"]) {
                            textView.text = @"";
                            [self.requestDict setValue:@"" forKey:@"ssBuilding"];
                            [self.requestDict setValue:@"" forKey:@"ssBuilding_Id"];
                        }else if ([textView.name2 isEqualToString:@"buildingUnitId"]) {
                            textView.text = @"";
                            [self.requestDict setValue:@"" forKey:@"ssBuildingUnit"];
                            [self.requestDict setValue:@"" forKey:@"ssBuildingUnit_Id"];
                        }else if ([textView.name2 isEqualToString:@"buildingFloorId"]) {
                            textView.text = @"";
                            [self.requestDict setValue:@"" forKey:@"ssBuildingFloor"];
                            [self.requestDict setValue:@"" forKey:@"ssBuildingFloor_Id"];
                        }
                    }
                }
                
            }else if ([textView.key isEqualToString:@"ssBuilding"] &&!([dict[@"spcBuildingsId"] isEqualToString:self.requestDict[@"ssBuilding_Id"]])) {
                //如果odb的所属建筑有变更，下面的所属单元/楼层全要为空
                for (int i = 0; i < self.contentView.subviews.count; i++) {
                    if ([self.contentView.subviews[i] isKindOfClass:[IWPTextView class]]) {
                        IWPTextView * textView = self.contentView.subviews[i];
                        if ([textView.name2 isEqualToString:@"buildingUnitId"]) {
                            textView.text = @"";
                            [self.requestDict setValue:@"" forKey:@"ssBuildingUnit"];
                            [self.requestDict setValue:@"" forKey:@"ssBuildingUnit_Id"];
                        }else if ([textView.name2 isEqualToString:@"buildingFloorId"]) {
                            textView.text = @"";
                            [self.requestDict setValue:@"" forKey:@"ssBuildingFloor"];
                            [self.requestDict setValue:@"" forKey:@"ssBuildingFloor_Id"];
                        }
                    }
                }
            }else if ([textView.key isEqualToString:@"ssBuildingUnit"] &&!([dict[@"buildingUnitId"] isEqualToString:self.requestDict[@"ssBuildingUnit_Id"]])) {
                //如果odb的所属单元有变更，下面的楼层要为空
                for (int i = 0; i < self.contentView.subviews.count; i++) {
                    if ([self.contentView.subviews[i] isKindOfClass:[IWPTextView class]]) {
                        IWPTextView * textView = self.contentView.subviews[i];
                        if ([textView.name2 isEqualToString:@"buildingFloorId"]) {
                            textView.text = @"";
                            [self.requestDict setValue:@"" forKey:@"ssBuildingFloor"];
                            [self.requestDict setValue:@"" forKey:@"ssBuildingFloor_Id"];
                        }
                    }
                }
            }
            
            // 否则，正常读取textView存储的内容和key向请求字典赋值
            [self.requestDict setValue:dict[textView.name4] forKey:textView.key];
            [self.requestDict setValue:dict[@"GID"] forKey:[NSString stringWithFormat:@"%@_Id",textView.key]];
            
            return;
        }
        
        
//        // 所属标石路径处理
//
        if ([self.fileName isEqualToString:@"markStone"] ||
            [self.fileName isEqualToString:@"markStoneSegment"]) {

            [self.requestDict setValue:dict[textView.name4] forKey:@"ssmarkStoneP"];
            [self.requestDict setValue:dict[textView.name2] forKey:@"ssmarkStoneP_Id"];
            return;

        }
//
        
        
        
        // 否则，正常读取textView存储的内容和key向请求字典赋值
        [self.requestDict setValue:dict[textView.name4] forKey:textView.key];
        
        
        
        
        // 判断文件，依据不同的文件名，向该文件相应的位置赋值
        if ([_fileName isEqualToString:@"ODF_Equt"]&&[dict[@"resLogicName"] isEqualToString:@"generator"]) {
            // odf，获取机房后，将机房的经纬度赋值
            __weak IWPTextView * latTextView = [self.contentView viewWithTag:latTagTYK];
            __weak IWPTextView * lonTextView = [self.contentView viewWithTag:lonTagTYK];
            
            if ((dict[@"lon"] != nil) && (dict[@"lat"] != nil)) {
                [self.requestDict setValue:dict[@"lon"] forKey:@"lon"];
                [self.requestDict setValue:dict[@"lat"] forKey:@"lat"];
                latTextView.text = dict[@"lat"];
                lonTextView.text = dict[@"lon"];
            }else{
                [self.requestDict setValue:@"" forKey:@"lon"];
                [self.requestDict setValue:@"" forKey:@"lat"];
                latTextView.text = @"";
                lonTextView.text = @"";
            }
            
        }else if ([_fileName isEqualToString:@"generator"] && [dict[@"resLogicName"] isEqualToString:@"stationBase"]){
            // 机房获取所属局站时，将局站的经纬度和地址赋值给机房
            
            // 新的合并后的View
            __weak IWPTextView * lat_lonView = [self.contentView viewWithTag:yuan_NewLatLonTag];
            
            __weak IWPTextView * latTextView = [self.contentView viewWithTag:latTagTYK];
            __weak IWPTextView * lonTextView = [self.contentView viewWithTag:lonTagTYK];
            __weak IWPTextView * addrTextView = [self.contentView viewWithTag:yuan_AddrTag];
            
            if (_isAutoSetAddr) {
                
                if ((dict[@"lon"] != nil) && (dict[@"lat"] != nil)) {
                    [self.requestDict setValue:dict[@"lon"] forKey:@"lon"];
                    [self.requestDict setValue:dict[@"lat"] forKey:@"lat"];
                    
                    
//                    latTextView.text = dict[@"lat"];
//                    lonTextView.text = dict[@"lon"];
                    lat_lonView.text = [NSString stringWithFormat:@"%@/%@",dict[@"lat"],dict[@"lon"]];
                    
                }else{
                    [self.requestDict setValue:@"" forKey:@"lon"];
                    [self.requestDict setValue:@"" forKey:@"lat"];
                    
                    lat_lonView.text = @"";
                }
                return;
            }
            
            // 仅当机房未填写此信息时赋值
            if (latTextView.text.length == 0 ||
                lonTextView.text.length == 0 ||
                lat_lonView.text.length == 0) {
                if ((dict[@"lon"] != nil) && (dict[@"lat"] != nil)) {
                    [self.requestDict setValue:dict[@"lon"] forKey:@"lon"];
                    [self.requestDict setValue:dict[@"lat"] forKey:@"lat"];
                    [self.requestDict setValue:dict[@"addr"] forKey:@"addr"];
//                    latTextView.text = dict[@"lat"];
//                    lonTextView.text = dict[@"lon"];
                    
                    lat_lonView.text = [NSString stringWithFormat:@"%@/%@",dict[@"lat"],dict[@"lon"]];
                    addrTextView.text = dict[@"addr"];
                    
                }else{
                    [self.requestDict setValue:@"" forKey:@"lon"];
                    [self.requestDict setValue:@"" forKey:@"lat"];
                    lat_lonView.text = @"";
                }
                
            }
        }
        else if ([_fileName isEqualToString:@"ledUp"]&&[dict[@"resLogicName"] isEqualToString:@"well"]){
            _ledUpWell = dict;
        }else if ([_fileName isEqualToString:@"OCC_Equt"]&&[dict[@"resLogicName"] isEqualToString:@"well"]){
            _occWell = dict;
        }
    }
    
    
    if ([dict[kResLogicName] isEqualToString:@"markStonePath"]) {
        
        textView.text = dict[@"markStonePathName"];
        
        //markStonePath
        [self.requestDict setValue:textView.text forKey:@"ssmarkStoneP"];
        // unicomMarkStonePathId 改为 GID
        [self.requestDict setValue:dict[@"GID"] forKey:[NSString stringWithFormat:@"%@_Id",textView.key]];
        
        [self subNameCreate];
        
    }else{
        [self.requestDict setValue:dict[@"GID"] forKey:[NSString stringWithFormat:@"%@_Id",textView.key]];
    }
    
    
    // 拼名
    if (textView.isType11) {
        if ([_model.subName rangeOfString:textView.name2].length > 0) {
            [self subNameCreate];
        }
    }
    if ([_model.subName rangeOfString:textView.key].length > 0) {
        [self subNameCreate];
    }else{
        if ([_model.subName rangeOfString:@"preName"].length > 0) {
            [self subNameCreate];
        }
    }
    
    
    NSLog(@"%@", self.requestDict);
}
-(void)returnRfid:(NSString *)rfidStr{
    NSLog(@"返回来的RFID：%@",rfidStr);
    //区分是起始还是终止设施
    if (isStartDeviceTYK) {
        NSLog(@"起始设施");
        [self.requestDict setObject:rfidStr forKey:@"cableStart_Rfid"];
    }else{
        NSLog(@"终止设施");
        [self.requestDict setObject:rfidStr forKey:@"cableEnd_Rfid"];
    }
}

#pragma mark ptotocolDelegate
-(void)makeImageNames:(NSString *)imageNames{
    // 写入请求字典
    [self.requestDict setValue:[NSString stringWithFormat:@"%@,",imageNames] forKey:@"imageNames"];
    // 向前传值
    if ([self.delegate respondsToSelector:@selector(newDeciceWithDict:)]) {
        [self.delegate newDeciceWithDict:self.requestDict];
    }
}
-(void)returnRegion:(NSString *)regionName{
    // 所属维护区域
    // 取得所属维护区域编辑框
    __weak IWPTextView * tv = [self.contentView viewWithTag:currentTagTYK-1];
    // 将值写入
    tv.text = regionName;
    // 写到请求字典中
    [self.requestDict setValue:tv.text forKey:tv.key];
}



-(void)saveCoordinate:(CLLocationCoordinate2D)coordinate withAddr:(NSString *)addr{
    
    // 取得经纬度
    kLonTYK = coordinate.longitude;
    kLatTYK = coordinate.latitude;
    
    // 获取经纬度编辑框
    __weak IWPTextView * lat_lon = [self.contentView viewWithTag:currentTagTYK - 1];
    
//    __weak IWPTextView * lat = [self.contentView viewWithTag:currentTagTYK - 1];
//    __weak IWPTextView * lon = [self.contentView viewWithTag:currentTagTYK - 2];
    
    
    if (lat_lon == nil) {
        
        NSLog(@"啊哦~~~~");
        
        return; // 反地理编码可能会多次调用该代理方法，如果在非首次调用前，更改了 currentTag (此更改是由于点击了其它按钮) 就无法取得这两个编辑框，这将导致程序崩溃。2017年01月13日14:26:17，by HSKW
    }
    
    // 赋值
    lat_lon.text = [NSString stringWithFormat:@"%.6lf/%.6lf",kLatTYK,kLonTYK];
    
    //    NSLog(@"%@,%@",lat.text,lon.text);
    
    // 将值写入请求字典
    [self.requestDict setValue:[NSString stringWithFormat:@"%.6lf",kLatTYK] forKey:@"lat"];
    [self.requestDict setValue:[NSString stringWithFormat:@"%.6lf",kLonTYK] forKey:@"lon"];
    
    // 获取地址编辑框
    __weak IWPTextView * tv = [self.contentView viewWithTag:addrBtnTagTYK - 1];
    
    if ([_fileName isEqualToString:@"joint"] && !_isOffline) {
        //在线光缆接头盒要单独判断
        for (int i = 0; i < self.contentView.subviews.count; i++) {
            if ([self.contentView.subviews[i] isKindOfClass:[IWPTextView class]]) {
                __weak IWPTextView * temp = self.contentView.subviews[i];
                if ([temp.key isEqualToString:@"addr"]) {
                    tv = temp;
                }
            }
        }
    }else{
        // 如果 tv.key 不是 addr 的话 或 处于离线模式下, 就返回, 不对编辑框赋值
        if (![tv.key isEqualToString:@"addr"] || _isOffline || !_isAutoSetAddr) {
            return;
        }
    }
    
    
    // 向编辑框中写入地址
    tv.text = addr == nil ? @"" : addr;
    
    if (tv.text.length > 20) {
        NSMutableString * newStr = [NSMutableString stringWithString:tv.text];
        [newStr insertString:@"\n" atIndex:18];
        tv.text = newStr;
    }
    
    
    // 将地址写入请求字典
    if(tv.key!=nil){
        [self.requestDict setValue:tv.text forKey:tv.key];
    }
    
    // 拼名
    if ([self.model.subName rangeOfString:@"preName"].length > 0 ||
        [self.model.subName rangeOfString:@"addr"].length > 0) {
        
        [self subNameCreate];
        
    }
}

- (void)configDatas{
    // 取解析结果
    self.cableModel = [IWPPropertiesSourceModel modelWithDict:self.reader.result];
    
    // 创建viewModel
    NSMutableArray * arrr = [NSMutableArray array];
    for (NSDictionary * dict in self.cableModel.view) {
        IWPViewModel * viewModel = [IWPViewModel modelWithDict:dict];
        [arrr addObject:viewModel];
    }
    
    
    
    self.cableViewModel = arrr;
}


-(void)newGeneratorInfo:(NSDictionary *)dict{
    
    self.requestDict = [dict mutableCopy];
    self.generatorInfoIn = dict;
    //    self.requestDict = [dict mutableCopy];
    
    // 将拿到的机房信息传回列表界面
    if ([self.delegate respondsToSelector:@selector(newDeciceWithDict:)]) {
        [self.delegate newDeciceWithDict:dict];
    }
}
#pragma mark tableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
      
    return self.listDataFrameModel[indexPath.row].rowHeight;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.listDataSource.count;
}

-(void)sppecialRowActionWithSender:(IWPButton *)sender{
    //890000
    NSUInteger index = sender.tag - 890000;
    
    [self dismisIOS8View];
    [self rowActionIOS8WithIndex:index];
}
-(void)rowActionIOS8WithIndex:(NSInteger)index{
    NSLog(@"%ld",(long)index);
    
    IWPTableViewRowAction * action = self.actions[index];
    
    NSLog(@"%@",action);
    
    [self rowAction:action withIndexPath:self.indexPath];
}

-(void)dismisIOS8View{
    //8942670 8942671
    UIView * cover = [self.view viewWithTag:8942670];
    UIView * controlView = [self.view viewWithTag:8942671];
    if (cover && controlView) {
        [UIView animateWithDuration:.4f animations:^{
            cover.alpha = 0.f;
        } completion:^(BOOL finished) {
            
            
            [UIView animateWithDuration:.1f animations:^{
                for (IWPButton * btn in controlView.subviews) {
                    btn.alpha = 0.f;
                }
            } completion:^(BOOL finished) {
                CGRect frame = controlView.frame;
                frame.size.width = 0;
                frame.size.height = ScreenHeight/3.f;
                CGPoint center = controlView.center;
                [UIView animateWithDuration:.4f animations:^{
                    controlView.frame = frame;
                    controlView.backgroundColor = [UIColor whiteColor];
                    controlView.center = center;
                } completion:^(BOOL finished) {
                    [cover removeFromSuperview];
                    [controlView removeFromSuperview];
                }];
            }];
        }];
    }
}
-(void)createActionsWithIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    
    NSInteger tag = 1000000;
    // 默认均添加删除操作
    IWPTableViewRowAction * actionDelete = [IWPTableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf rowAction:(IWPTableViewRowAction *)action withIndexPath:indexPath];
    }];
    actionDelete.tag = tag++;
    
    IWPTableViewRowAction * actionRFID = [IWPTableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"标签" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf rowAction:(IWPTableViewRowAction *)action withIndexPath:indexPath];
    }];
    actionRFID.backgroundColor = [UIColor colorWithHexString:@"#eac100"];
    actionRFID.tag = tag++;
    
    [self.actions addObject:actionDelete];
    [self.actions addObject:actionRFID];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * kCellID = @"cell";
    
    IWPRfidInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
        cell = [[IWPRfidInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        
        UIImageView * imageV = [[UIImageView alloc] initWithImage:[UIImage Inc_imageNamed:@"infoIcon"]];
        imageV.bounds = CGRectMake(0, 0, 24, 24);
        cell.accessoryView = imageV;
        cell.textLabel.numberOfLines = 0;
    }
    
    cell.model = self.listDataFrameModel[indexPath.row];
    
    return cell;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    return nil;
}




- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleNone;
}
-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.actions.count > 0) {
        return self.actions;
    }
    [self createActionsWithIndexPath:indexPath];
    return self.actions;
    
}
-(void)rowAction:(IWPTableViewRowAction *)action withIndexPath:(NSIndexPath *)indexPath{
    
    if (action.tag == 1000000) {
        // 删除
        [self removeCableInfoWithIndexPath:indexPath];
    }else if(action.tag == 1000001){
        // 标签
        // 取出字典
        NSDictionary * dict = self.listDataSource[indexPath.row];
        
        // 創建控制器
        IWPCableRFIDScannerViewController * cabelRfid = [[IWPCableRFIDScannerViewController alloc] init];
        cabelRfid.cableInfo = dict;
        cabelRfid.delegate = self;
        self.isRowAction = YES;
        [self.navigationController pushViewController:cabelRfid animated:YES];
        //        NSLog(@"dataSource = %@",self.listDataSource[indexPath.row]);
    }
    
    
}

-(void)cableWithDict:(NSDictionary *)dict{
    
    
    
    
    
    // 取出既有內容
    NSMutableString * currentNames = [self.requestDict[kCableMainName] mutableCopy];
    NSMutableString * currentIds = [self.requestDict[kCableMainId] mutableCopy];
    NSMutableString * currentRfids = [self.requestDict[kCableMainRfid] mutableCopy];
    
    
    
    
    
    
    // 將既有內容轉換為數組
    NSMutableArray * names = [NSMutableArray arrayWithArray:[currentNames componentsSeparatedByString:@","]];
    NSMutableArray * ids = [NSMutableArray arrayWithArray:[currentIds componentsSeparatedByString:@","]];
    NSMutableArray * rfids = [NSMutableArray arrayWithArray:[currentRfids componentsSeparatedByString:@","]];
    
    
    
    // 從 rowAction 按鈕點擊進去, 修改/返回
    // 添加纜段 點擊進去, 獲取纜段後跳轉, 修改/返回
    NSInteger index = 0;
    if (self.isRowAction /*從 tableViewcell 的 rowAction 進入返回*/) {
        // 肯定是修改 , 肯定有已存在
        
        for (NSString * ID  in ids) {
            if ([dict[kCableId] isEqualToString:ID]) {
                if (rfids.count == 0) {
                    [rfids addObject:dict[kCableRfid]];
                }else{
                    [rfids replaceObjectAtIndex:index withObject:dict[kCableRfid]];
                }
            }
            index++;
        }
    }else{
        // 肯定是添加, 肯定沒有已存在
        [names addObject:dict[kCableName]];
        [ids addObject:dict[kCableId]];
        [rfids addObject:dict[kCableRfid]];
        
        NSLog(@"names = %@", names);
        NSLog(@"ids = %@", ids);
        NSLog(@"rfids = %@", rfids);
        
    }
    
    // 轉換字符串
    NSString * nameStr = [self pieceTogetherObjectsWithArray:names];
    NSString * idStr = [self pieceTogetherObjectsWithArray:ids];
    NSString * rfidStr = [self pieceTogetherObjectsWithArray:rfids];
    
    NSLog(@"nameStr = %@",nameStr);
    NSLog(@"idStr = %@",idStr);
    NSLog(@"rfidStr = %@",rfidStr);
    
    // 賦值
    [self.requestDict setValue:nameStr forKey:kCableMainName];
    [self.requestDict setValue:idStr forKey:kCableMainId];
    [self.requestDict setValue:rfidStr forKey:kCableMainRfid];
    
    
    NSLog(@"%@", self.requestDict);
    
    // 重新設置 listDataSource
    [self createListDataSource];
    
    // 重載 tableView
    [self.listView reloadData];
}

-(NSString *)pieceTogetherObjectsWithArray:(NSArray *)array{
    NSString * ret = @"";
    for (NSString * str in array) {
        if (str.length > 0) {
            ret = [ret stringByAppendingString:[NSString stringWithFormat:@"%@,",str]];
        }
    }
    return ret;
}


-(void)removeCableInfoWithIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"%@", self.listDataSource);
    
    
    [self.listDataSource removeObjectAtIndex:indexPath.row]; // 从数组中移除该项
    // 重置请求字典;
    NSString * valueNames = @"";
    NSString * valueIds = @"";
    NSString * valueRfids = @"";
    for (NSDictionary * dict in self.listDataSource) {
        valueNames = [valueNames stringByAppendingString:[NSString stringWithFormat:@"%@,",dict[kCableName]]];
        valueIds = [valueIds stringByAppendingString:[NSString stringWithFormat:@"%@,",dict[kCableId]]];
        valueRfids = [valueRfids stringByAppendingString:[NSString stringWithFormat:@"%@,",dict[kCableRfid]]];
    }
    [self.requestDict setValue:valueNames forKey:kCableMainName];
    [self.requestDict setValue:valueIds forKey:kCableMainId];
    [self.requestDict setValue:valueRfids forKey:kCableMainRfid];
    //    [self.listView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self createListDataSource];
    
    //
}

#pragma mark- self delegate
-(void)deleteDeviceWithDict:(NSDictionary *)dict withViewControllerClass:(Class)vcClass{
    // 重载 listTableView, 更新 ListDataSource, 重设 requestDict
    NSLog(@"调用了");
    if (_controlMode == TYKDeviceInfomationTypeDuanZiMianBan_Update) {
        if ([self.equType isEqualToString:@"OpticalSplitter"]) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"确定要删除该分光器?" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self deleteDeviceOpticalSplitter];
            }];
            UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                return;
            }];
            
            [alert addAction:actionYES];
            [alert addAction:actionNO];
            Present(self, alert);
            
        }
    }
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"确定要删除该光缆?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteDevice:dict withClass:vcClass];
    }];
    UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        return;
    }];
    
    [alert addAction:actionYES];
    [alert addAction:actionNO];
    Present(self, alert);
}
-(void)newDeciceWithDict:(NSDictionary<NSString *,NSString *> *)dict{
    
    NSLog(@"%@", dict);
    if (_controlMode == TYKDeviceInfomationTypeDuanZiMianBan_Update &&([self.equType isEqualToString:@"OpticalSplitter"])) {
        //分光器核查
        obdEqutDic = [[NSMutableDictionary alloc] initWithDictionary:dict];
        
        return;
        
    }
    // 这里实际带回的是整个 cable 的字典
    // 修改后保存
    if (self.listDataSource.count == 0) {
        [self.listDataSource addObject:dict];
        [self.listView reloadData];
        return;
    }
    
    NSString * deviceKey = @"cableId";
    NSInteger index = 0;
    BOOL isAdd = YES;
    for (NSDictionary * device in self.dataSource) {
        if ([device[deviceKey] isEqualToString:dict[deviceKey]]) {
            isAdd = NO;
            break;
        }
        index++;
    }
    
    if (isAdd) {
        [self.listDataSource addObject:dict];
    }else{
        [self.listDataSource replaceObjectAtIndex:index withObject:dict];
    }
    
    [self.listView reloadData];
}
-(void)deleteDevice:(NSDictionary *)dict withClass:(Class)class{
    // 删除事件
#ifdef BaseURL
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL, _model.delete_name];
#else
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL_Auto(([IWPServerService sharedService].link)), _model.delete_name];
#endif
    NSLog(@"%@",requestURL);
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.requestDict options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [param setValue:UserModel.uid forKey:@"UID"];
    [param setValue:str forKey:@"jsonRequest"];
    
    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"删除成功" message:nil preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (class == self.class) { // 判断控制器类型
                [self reloadTableViewWithDict:dict];
                return;
            }else{
                [self reloadTableViewWithDict:dict];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        
        [alert addAction:action];
        Present(self.navigationController, alert);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}

-(void)returnCable:(NSString *)cableName :(NSString *)cableId{
    // 创建成字典
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:cableName,kCableName,cableId,kCableId, nil];
    self.tempCableInfoDict = dict;
    
    _isRowAction = NO;
    BOOL isSave = YES;
    
    // 遍历tableView的dataSource
    for (NSDictionary * dic in self.listDataSource) {
        // 若该光缆已经存在
        if ([dict[kCableName] isEqualToString:dic[kCableName]]) {
            if (!isDevicesTYK) {
                // 弹出重复提示
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前缆段被重复添加\n请核对后再试" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style: UIAlertActionStyleDefault handler:nil];
                [alert addAction:action];
                Present(self.navigationController, alert);
                return;
            }else{
                isSave = NO;
                break;
            }
        }
    }
    
    
    if (isDevicesTYK && isSave) {
        NSMutableDictionary * newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [newDict setValue:@" " forKey:kCableRfid];
        [self cableWithDict:newDict];
    }

   
}

-(void)goQRCodeScanner:(NSDictionary *)dict{
    
    IWPCableRFIDScannerViewController * bind = [[IWPCableRFIDScannerViewController alloc] init];
    // 将字典写入
    bind.cableInfo = self.tempCableInfoDict;
    bind.delegate = self;
    
    [self.navigationController pushViewController:bind animated:YES];
    
}

-(void)reloadTableViewWithDict:(NSDictionary *)dict{
    NSString * deviceKey = @"cableId";
    NSInteger index = 0;
    
    for (NSDictionary * device in self.dataSource) {
        if ([device[deviceKey] isEqualToString:dict[deviceKey]]) {
            break;
        }
        index++;
    }
    
    NSMutableArray * arr = [self.listDataSource mutableCopy];
    
    [arr removeObjectAtIndex:index];
    self.listDataSource = arr;
    [self.listView reloadData];
}

-(void)dismisSelf{
    
    if ([self isLaunched]) {
        
        if (_isCopy){
            NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-2]animated:YES];

        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (BOOL)isLaunched{
    
    if (!self.navigationController) {
         return NO;
    }
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    if (viewcontrollers.count>=1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count-1] == self
            && viewcontrollers[0] != self ) {
            
            return YES;
        }
    }
    return NO;
}



-(NSArray<id<UIPreviewActionItem>> *)previewActionItems{
    
    NSMutableArray * arr = [NSMutableArray array];
    
    NSMutableArray * btnTitles = [NSMutableArray arrayWithArray:self.btnTitles];
    
    if (_isOffline) {
        for (int i = 0; i < btnTitles.count; i++) {
            if ([btnTitles[i] isEqualToString:@"杆路段"]) {
                [btnTitles replaceObjectAtIndex:i withObject:@"上传"];
            }
        }
    }
    NSInteger i = 0;
    //    NSLog(@"%@",self.btnTitles);
    for (NSString * titles in btnTitles) {
        
        UIPreviewActionStyle style = UIPreviewActionStyleDestructive;
        if (i > 0) {
            style = UIPreviewActionStyleDefault;
        }
        
        UIPreviewAction * action = [UIPreviewAction actionWithTitle:titles style:style handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            if ([self.delegate respondsToSelector:@selector(rowActionWithIndex:)]) {
                [self.delegate rowActionWithIndex:i];
            }
        }];
        i++;
        [arr addObject:action];
    }
    
    return arr;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self dismisIOS8View];
    [self mianbanKeyboardClose];
    
}
- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

//变更当前选择的井面信息
// MRAK: 新·详情
-(void)wellFaceRefreshWithDict:(NSDictionary *)dict :(NSString *)locationNo{
    NSLog(@"变更当前选择的井面信息");
    NSLog(@"111~~~---:%@",dict);
    NSLog(@"222~~~---%@",locationNo);
    if ([self.requestDict[@"wellId"] isEqualToString:dict[locationNo][@"well_Id"]]) {
        NSMutableArray *faceArr = [[NSMutableArray alloc] initWithArray:self.requestDict[@"faces"]];
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:self.requestDict];
        self.requestDict = temp;
        [self.requestDict setObject:faceArr forKey:@"faces"];
        for (int j = 0; j<faceArr.count; j++) {
            if ([faceArr[j][@"locationNo"] isEqualToString:locationNo]) {
                NSLog(@"333~~~----%@",self.requestDict[@"faces"][j]);
                self.requestDict[@"faces"][j] = dict[locationNo];
                NSLog(@"444~~----%@",self.requestDict[@"faces"][j]);
            }
        }
    }
}

#pragma mark - 分光器新
-(void)configOpticalSplitterView{
    NSLog(@"%@",self.requestDict);
    if (pointListMap == nil) {
        pointListMap = [[NSMutableDictionary alloc] init];
    }
    [pointListMap setObject:self.requestDict[@"dataDic"] forKey:@"0"];
    obdEqutDic = self.requestDict[@"equDic"];
    
    CGFloat x = 0, y = HeigtOfTop, w = 0, h = 0;
    
    w = ScreenWidth / 5.f;
    h = self.view.bounds.size.height - y;
    
    UIView * opticalSplitterView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    opticalSplitterView.layer.borderWidth = 1;
    opticalSplitterView.layer.borderColor = [UIColor mainColor].CGColor;
    opticalSplitterView.layer.cornerRadius = 5;
    opticalSplitterView.userInteractionEnabled = YES;
    [self.view addSubview:opticalSplitterView];
    
    w = opticalSplitterView.bounds.size.width;
    y = x = 0;
    
    CusButton *opticalSplitterShowBtn = [[CusButton alloc] initWithFrame:CGRectMake(x+3, y+3, w-6, 40)];
    [opticalSplitterShowBtn setTitle:@"分光器\n信息" forState:UIControlStateNormal];
    opticalSplitterShowBtn.titleLabel.numberOfLines = 0;
    opticalSplitterShowBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [opticalSplitterShowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [opticalSplitterShowBtn setBackgroundColor:[UIColor mainColor]];
    opticalSplitterShowBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [opticalSplitterShowBtn addTarget:self action:@selector(opticalSplitterShow:) forControlEvents:UIControlEventTouchUpInside];
    [opticalSplitterView addSubview:opticalSplitterShowBtn];
    
    y = 46;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    pointCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(x, 76, w, h - 122) collectionViewLayout:flowLayout];
    pointCollectionView.dataSource = self;
    pointCollectionView.delegate = self;
    pointCollectionView.userInteractionEnabled = YES;
    pointCollectionView.backgroundColor = [UIColor clearColor];
    [pointCollectionView registerClass:[PointViewCell class] forCellWithReuseIdentifier:@"cell"];
    pointCollectionView.tag = 101;
    // 设置item之间的间隔
    flowLayout.minimumInteritemSpacing = 0;
    // 设置行之间间隔
    flowLayout.minimumLineSpacing = 5;
    [opticalSplitterView addSubview:pointCollectionView];
    
    
    self.requestDict = [[NSMutableDictionary alloc] initWithDictionary:pointListMap[@"0"][0]];
    
    //显示当前数据
    [self showPortInfomation];
    lastClickPointIndex = nil;
    [pointCollectionView reloadData];
}
#pragma mark - OLT新
-(void)configOLTView{
    NSLog(@"%@",self.requestDict);
    if (pointListMap == nil) {
        pointListMap = [[NSMutableDictionary alloc] init];
    }
    [pointListMap setObject:self.requestDict[@"dataDic"] forKey:[NSString stringWithFormat:@"%ld",(long)self.card_code]];
    
    CGFloat x = 0, y = HeigtOfTop, w = 0, h = 0;
    
    w = ScreenWidth / 5.f;
    h = self.view.bounds.size.height - y;
    
    UIView * oltView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    oltView.layer.borderWidth = 1;
    oltView.layer.borderColor = [UIColor mainColor].CGColor;
    oltView.layer.cornerRadius = 5;
    oltView.userInteractionEnabled = YES;
    [self.view addSubview:oltView];
    
    w = oltView.bounds.size.width;
    y = x = 0;
    
//    upBtn = [[UIButton alloc] initWithFrame:CGRectMake(x+3, y+3, w-6, 40)];
//    [upBtn setTitle:@"1" forState:UIControlStateNormal];
//    [upBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [upBtn setBackgroundImage:[UIImage Inc_imageNamed:@"up"] forState:UIControlStateNormal];
//    [upBtn addTarget:self action:@selector(up_onc:) forControlEvents:UIControlEventTouchUpInside];
//    [oltView addSubview:upBtn];
    
    y = 46;
    
    panCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+10, y, w-20, 30)];
    [panCodeLabel setBackgroundColor:[UIColor mainColor]];
    [panCodeLabel setText:[NSString stringWithFormat:@"%ld",(long)self.card_code]];
    [panCodeLabel setTextColor:[UIColor whiteColor]];
    panCodeLabel.textAlignment = NSTextAlignmentCenter;
    [oltView addSubview:panCodeLabel];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    pointCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(x, 76, w, h - 122) collectionViewLayout:flowLayout];
    pointCollectionView.dataSource = self;
    pointCollectionView.delegate = self;
    pointCollectionView.userInteractionEnabled = YES;
    pointCollectionView.backgroundColor = [UIColor clearColor];
    [pointCollectionView registerClass:[PointViewCell class] forCellWithReuseIdentifier:@"cell"];
    pointCollectionView.tag = 100;
    // 设置item之间的间隔
    flowLayout.minimumInteritemSpacing = 0;
    // 设置行之间间隔
    flowLayout.minimumLineSpacing = 5;
    [oltView addSubview:pointCollectionView];
    
//    downBtn = [[UIButton alloc] initWithFrame:CGRectMake(x+3, oltView.bounds.size.height-43, w-6, 40)];
//    [downBtn setTitle:@"3" forState:UIControlStateNormal];
//    [downBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [downBtn setBackgroundImage:[UIImage Inc_imageNamed:@"down"] forState:UIControlStateNormal];
//    [downBtn addTarget:self action:@selector(down_onc:) forControlEvents:UIControlEventTouchUpInside];
//    [oltView addSubview:downBtn];
    
//    [self sun_B_S];
    if (((NSArray *)(pointListMap[[NSString stringWithFormat:@"%ld",(long)self.card_code]])).count>0) {
        self.requestDict = [[NSMutableDictionary alloc] initWithDictionary:pointListMap[[NSString stringWithFormat:@"%ld",(long)self.card_code]][0]];
    }
    
    NSLog(@"self.requestDict:%@",self.requestDict);
    //显示当前数据
    [self showPortInfomation];
    lastClickPointIndex = nil;
    [pointCollectionView reloadData];
}
//计算是否有比当前大/小的盘
-(void)sun_B_S{
    bcode = 0;
    scode = 0;
    NSInteger b_t = 1000;//因为是取最小值 所以初始要最大
    NSInteger s_t = 1000;
    for (NSString *key in [self.cardIDMap keyEnumerator]) {
        NSInteger ky = [key integerValue];
        if (ky>self.card_code) {
            NSInteger b_k = ky-self.card_code;
            if (b_k<b_t) {
                b_t = b_k;
                bcode = ky;
            }
        }else if (ky<self.card_code){
            NSInteger s_k = self.card_code-ky;
            if (s_k<s_t) {
                s_t = s_k;
                scode = ky;
            }
        }
    }
    if (scode == 0) {
        //说明前面没有了，up按钮不可用
        [upBtn setHidden:YES];
    }else{
        [upBtn setHidden:NO];
        [upBtn setTitle:[NSString stringWithFormat:@"%ld",(long)scode] forState:UIControlStateNormal];
    }
    if (bcode == 0) {
        //说明后面没有了，down按钮不可用
        [downBtn setHidden:YES];
    }else{
        [downBtn setHidden:NO];
        [downBtn setTitle:[NSString stringWithFormat:@"%ld",(long)bcode] forState:UIControlStateNormal];
    }
}
//上一页按钮点击触发事件
-(IBAction)up_onc:(id)sender{
    self.card_code = scode;
    [panCodeLabel setText:[NSString stringWithFormat:@"%ld",(long)self.card_code]];
    [self get_S_Data];
}
//下一页按钮点击触发事件
-(IBAction)down_onc:(id)sender{
    self.card_code = bcode;
    [panCodeLabel setText:[NSString stringWithFormat:@"%ld",(long)self.card_code]];
    [self get_S_Data];
}
-(void)get_S_Data{
    if (pointListMap[[NSString stringWithFormat:@"%ld",(long)self.card_code]]!=nil) {
        [self sun_B_S];
        //修改当前的数据为第一条
        self.requestDict = [[NSMutableDictionary alloc] initWithDictionary:pointListMap[[NSString stringWithFormat:@"%ld",(long)self.card_code]][0]];
        //显示当前数据
        [self showPortInfomation];
        lastClickPointIndex = nil;
        [pointCollectionView reloadData];
    }else{
        NSMutableDictionary *td = [[NSMutableDictionary alloc] init];
        [td setObject:self.cardIDMap[[NSString stringWithFormat:@"%ld",(long)self.card_code]] forKey:@"cardId_Id"];
        [td setObject:@"card" forKey:@"cardId_Type"];
        [td setObject:@"port" forKey:@"resLogicName"];
        [self getPointData:td];
    }
}

//分光器信息按钮点击触发事件
-(IBAction)opticalSplitterShow:(id)sender{
    NSLog(@"obdEqutDic:%@",obdEqutDic);
    TYKDeviceInfoMationViewController * device = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:nil withViewModel:nil withDataDict:obdEqutDic withFileName:@"OBD_Equt"];
    device.delegate = self;
    [self.navigationController pushViewController:device animated:YES];
}
//获取端子数据
-(void)getPointData:(NSMutableDictionary *) td{
   
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

        
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":DictToString(td)};
    NSLog(@"param %@",param);
    
    
#ifdef BaseURL
    NSString * url = [NSString stringWithFormat:@"%@data!getData.interface",BaseURL];
#else
    NSString * url = [NSString stringWithFormat:@"%@data!getData.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    
    [Http.shareInstance POST:url parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        NSDictionary *dic = responseObject;
        if ([dic objectForKey:@"info"] == [NSNull null]) {
            
           
            [YuanHUD HUDFullText:@"数据异常"];
            
            return ;
        }
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {

                        
            NSData *tempData=[[[NSMutableDictionary dictionaryWithDictionary:dic] objectForKey:@"info"] dataUsingEncoding:NSUTF8StringEncoding];
            
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            if (pointListMap == nil) {
                pointListMap = [[NSMutableDictionary alloc] init];
            }
            [pointListMap setObject:arr forKey:[NSString stringWithFormat:@"%ld",(long)self.card_code]];
            [self sun_B_S];
            //修改当前的数据为第一条
            self.requestDict = [[NSMutableDictionary alloc] initWithDictionary:pointListMap[[NSString stringWithFormat:@"%ld",(long)self.card_code]][0]];
            NSLog(@"self.requestDict:%@",self.requestDict);
            //显示当前数据
            [self showPortInfomation];
            lastClickPointIndex = nil;
            [pointCollectionView reloadData];
        }else{
        
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];
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
#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView.tag == 100) {
        if (pointListMap[[NSString stringWithFormat:@"%ld",(long)self.card_code]]!=nil) {
            return ((NSArray *)pointListMap[[NSString stringWithFormat:@"%ld",(long)self.card_code]]).count;
        }
    }else if (collectionView.tag == 101){
        return ((NSArray *)pointListMap[@"0"]).count;
    }
    
    return 0;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    PointViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImage *image;
    int pstate;
    NSLog(@"pointListMap:%@",pointListMap);
    if (collectionView.tag == 101) {
        //分光器
        pstate = [[((NSArray *)pointListMap[@"0"])[indexPath.row] objectForKey:@"oprStateId"] intValue];
    }else{
        //OLT
        pstate = [[((NSArray *)pointListMap[[NSString stringWithFormat:@"%ld",(long)self.card_code]])[indexPath.row] objectForKey:@"oprStateId"] intValue];
    }
    
    if (pstate == 3) {
        //占用
        image = [UIImage Inc_imageNamed:@"port_3"];
    }else if (pstate == 10) {
        //损坏
        image = [UIImage Inc_imageNamed:@"port_10"];
    }else{
        image = [UIImage Inc_imageNamed:@"port_0"];
    }
    if (collectionView.tag == 101) {
        //分光器
        cell.textLabel.text = ((NSArray *)pointListMap[@"0"])[indexPath.row][@"termNum"];
    }else{
        //OLT
        cell.textLabel.text = ((NSArray *)pointListMap[[NSString stringWithFormat:@"%ld",(long)self.card_code]])[indexPath.row][@"csportNumber"];
    }
    
    cell.imageView.image = image;
    cell.backgroundColor = [UIColor whiteColor];
    cell.imageView.layer.borderWidth = 5;
    cell.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    if (lastClickPointIndex!=nil) {
        PointViewCell * lastCell = (PointViewCell *)[collectionView cellForItemAtIndexPath:lastClickPointIndex];
        lastCell.backgroundColor = [UIColor whiteColor];
        lastCell.imageView.layer.borderWidth = 5;
        lastCell.imageView.layer.borderColor = [UIColor blueColor].CGColor;
    }
    
    [cell sizeToFit];
    
    
    return cell;
}
#pragma mark UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(40, 40);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(5, 5, 5, 5);
    
}

#pragma mark UIColletionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PointViewCell * cell = (PointViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //端子点击事件
    if (collectionView.tag == 101) {
        //分光器
        NSArray *list_c = pointListMap[@"0"];
        for (NSDictionary *tt in list_c) {
            if ([tt[@"termNum"] isEqualToString:cell.textLabel.text]) {
                self.requestDict = [[NSMutableDictionary alloc] initWithDictionary:tt];
                //显示当前数据
                [self showPortInfomation];
            }
        }
    }else{
        //OLT
        NSArray *list_c = pointListMap[[NSString stringWithFormat:@"%ld",(long)self.card_code]];
        BOOL isNull = YES;
        for (NSDictionary *tt in list_c) {
            if (tt[@"csportNumber"]!=nil) {
                if ([tt[@"csportNumber"] isEqualToString:cell.textLabel.text]) {
                    self.requestDict = [[NSMutableDictionary alloc] initWithDictionary:tt];
                    //显示当前数据
                    [self showPortInfomation];
                    isNull = NO;
                    break;
                }
            }
        }
        if (isNull) {
            self.requestDict = [[NSMutableDictionary alloc] initWithDictionary:list_c[indexPath.row]];
            [self showPortInfomation];
        }
    }
    
    //还原上一个点击的端子
    if (lastClickPointIndex!=nil) {
        PointViewCell * lastCell = (PointViewCell *)[collectionView cellForItemAtIndexPath:lastClickPointIndex];
        lastCell.backgroundColor = [UIColor whiteColor];
        lastCell.imageView.layer.borderWidth = 5;
        lastCell.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    }else{
        lastClickPointIndex = [NSIndexPath new];
        
    }
    lastClickPointIndex = indexPath;
    //添加点击效果
    cell.backgroundColor = [UIColor redColor];
    cell.imageView.layer.borderWidth = 5;
    cell.imageView.layer.borderColor = [UIColor blueColor].CGColor;
    
    
    
    [self.contentView setContentOffset:CGPointMake(0, -HeigtOfTop) animated:YES];
    
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)showPortInfomation{
    
    sp_indexTYK = nDefaultType3Tag;
    
    for (UIView * view in _contentView.subviews) {
        [view removeFromSuperview];
    }
    // 根据文件创建视图, 首先创建必要的视图
    for (IWPViewModel * model in _viewModel) {
        
        if (model.tv1_Required.intValue == 0) {
            continue;
        }
        
        // 使用读取到的Model创建视图
        [self createSubViewWithViewModel:model];
        
    }
    
    // 是否会有隐藏视图，默认为NO
    BOOL isHaveHiddenView = NO;
    
    
    // 再创建非必要视图
    for (IWPViewModel * model in _viewModel) {
        if (model.tv1_Required.intValue == 1 /* || [model.tv1_Text isEqualToString:@"扩充后缀"]*/) {
            // 2017年01月21日 要求跟随文件走
            continue;
        }
        [self createSubViewWithViewModel:model];
        
        // 仅赋值一次
        if (!isHaveHiddenView) {
            isHaveHiddenView = YES;
        }
    }
    
    CGFloat x = 0, y = 0, w = 0, h = 0;
    
    w = self.contentView.bounds.size.width / 2.f;
    h = 49.f;
    y = [self getNewY] + marginTYK / 2.f;
    x = (self.contentView.bounds.size.width - w ) / 2.f;
    
    IWPButton * otherInfoBtn = [IWPButton buttonWithType:UIButtonTypeCustom];
    otherInfoBtn.tag = tagTYK++;
    otherInfoBtn.frame = CGRectMake(x,y,w,h);
    self.otherInfoBtn = otherInfoBtn;
    
    [otherInfoBtn addTarget:self action:@selector(showBeizhu:) forControlEvents:UIControlEventTouchUpInside];
    [otherInfoBtn setTitle:@"显示详情" forState:UIControlStateNormal];
    [otherInfoBtn setTitle:@"隐藏详情" forState:UIControlStateSelected];
    [otherInfoBtn setBackgroundColor:[UIColor mainColor]];
    //        btn.backgroundColor = [UIColor getStochasticColor];
    [otherInfoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    otherInfoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
    [self.contentView addSubview:otherInfoBtn];
    otherInfoBtn.hidden = !isHaveHiddenView;
    

    
    
    
    [self resetContentSize];
}
#pragma mark OLT端子面板添加对端\跳接关系按钮点击事件
-(void)showOPPOMainBanHandler:(IWPButton *)sender{
    
    NSLog(@"%@ = self.equDic \n %@ = self.requestDict", self.equDic, self.requestDict);
    [YuanHUD HUDFullText:@"到这了啊showOPPOMainBanHandler"];

}
#pragma mark 建筑物单元按钮点击事件
-(void)showBuildingUnitMainBanHandler:(IWPButton *)sender{
    
    [YuanHUD HUDFullText:@"到这了BuildingUnitNewListViewController"];
    
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    
    if ((self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前建筑物信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
    
//    BuildingUnitNewListViewController * device = [[BuildingUnitNewListViewController alloc] init];
//    device.buildingInfoIn = [self.requestDict mutableCopy];
//    device.delegate = self.delegate;
//    [self.navigationController pushViewController:device animated:YES];
}
#pragma mark 单元平面图按钮点击事件
-(void)showBuildingUnitPingmianTuBanHandler:(IWPButton *)sender{
    
    [YuanHUD HUDFullText:@"到这了InitBuildingViewController"];

    
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    
    if ((self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前建筑物单元信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
//
//    InitBuildingViewController * device = [[InitBuildingViewController alloc] init];
//    device.buildingUnitInfoIn = [self.requestDict mutableCopy];
//    [self.navigationController pushViewController:device animated:YES];
}
#pragma mark - 子类继承重写该方法用于个性化操作
-(void)doSomethingHandler:(IWPButton *)sender{
}
#pragma mark - 二维码扫描的删除事件
-(void)deleteDevice:(NSDictionary *)dict{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"确定要删除该%@?",_model.name] preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) wself = self;
    UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [wself deleteDeviceOnline:dict];
        
    }];
    UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    
    [alert addAction:actionYES];
    [alert addAction:actionNO];
    Present(self, alert);
}
-(void)deleteDeviceOnline:(NSDictionary *)dict {
    
    
    [[Yuan_HUD shareInstance] HUDStartText:@"正在删除，请稍候……"];

    // 删除事件
#ifdef BaseURL
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL, _model.delete_name];
#else
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL_Auto(([IWPServerService sharedService].link)), _model.delete_name];
#endif
    NSLog(@"%@",requestURL);
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setValue:UserModel.uid forKey:@"UID"];
   
    [param setValue:DictToString(dict) forKey:@"jsonRequest"];
    __weak typeof(self) wself = self;
    
    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        NSDictionary * dict = responseObject;
                
        if (![dict[@"result"] boolValue]) {
            /* 删除成功 */
            
            [wself dismisSelf];
            
            [YuanHUD HUDFullText:@"删除成功"];
            
            
        }else{
            /* 删除失败 */
            [YuanHUD HUDFullText:@"删除失败"];

        }
        
        [[Yuan_HUD shareInstance] HUDHide];

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
       
        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{

            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
    }];

}

//删除分光器事件
-(void)deleteDeviceOpticalSplitter{
    // 删除事件
#ifdef BaseURL
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL, _model.delete_name];
#else
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL_Auto(([IWPServerService sharedService].link)), _model.delete_name];
#endif
    NSLog(@"%@",requestURL);
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obdEqutDic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [param setValue:UserModel.uid forKey:@"UID"];
    [param setValue:str forKey:@"jsonRequest"];
    
    NSLog(@"param:%@",param);
    
    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"删除成功" message:nil preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //删除分光器后，要关闭当前分光器信息界面，关闭分光器端子信息界面，从模板界面中删除当前的分光器模板
            [self.navigationController popViewControllerAnimated:NO];
        
        }];
        
        [alert addAction:action];
        Present(self.navigationController, alert);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}


//ODF模板按钮点击触发事件
-(void)showODFModel:(IWPButton *)sender{
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    if ((_controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
    // 从 ODF 进入 袁全新写的
    
    NSString * GID = self.requestDict[@"GID"];
    Yuan_New_ODFModelVC *ODF =
    [[Yuan_New_ODFModelVC alloc] initWithType:InitType_ODF
                                          Gid:GID
                                         name:_requestDict[@"rackName"]];
    
    
    [self.navigationController pushViewController:ODF animated:YES];
    
    
    ODF.mb_Dict = _requestDict;
    
}
//OCC模板按钮点击触发事件
-(void)showOCCModel:(IWPButton *)sender{
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    if ((_controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
    
    
    
    
    // 从光交接箱进入
    
    NSString * GID = self.requestDict[@"GID"];
    Yuan_New_ODFModelVC *OCC =
    [[Yuan_New_ODFModelVC alloc] initWithType:InitType_OCC
                                          Gid:GID
                                         name:_requestDict[@"occName"]];
    

    
    [self.navigationController pushViewController:OCC animated:YES];
    
    OCC.mb_Dict = _requestDict;
}

//ODB模板按钮点击触发事件
-(void)showODBModel:(IWPButton *)sender{
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    if ((_controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
    

    /// MARK: --- --- ODF OCC ODB 之间的区分
    
    NSString * GID = self.requestDict[@"GID"];
    Yuan_New_ODFModelVC *ODB =
    [[Yuan_New_ODFModelVC alloc] initWithType:InitType_ODB
                                          Gid:GID
                                         name:_requestDict[@"odbName"]];
    
    [self.navigationController pushViewController:ODB animated:YES];
    
    ODB.mb_Dict = _requestDict;
}



// 综合箱 模板
- (void) showIntegratedBoxModel {
    
    NSString * GID = self.requestDict[@"GID"];
    Yuan_New_ODFModelVC *IntegratedBox =
    [[Yuan_New_ODFModelVC alloc] initWithType:InitType_OBD
                                          Gid:GID
                                         name:_requestDict[@"intBoxName"]];
    
    [self.navigationController pushViewController:IntegratedBox animated:YES];
}






//建筑物详细信息内模板按钮点击触发事件
-(void)spcBuildingModel:(IWPButton *)sender{
    [YuanHUD HUDFullText:@"到这了BuildingModelViewController"];
    if ([self isOfflineDevice]) {
        [YuanHUD HUDFullText:@"离线模式下不可用"];
        return;
    }
    
    if ((self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) && isSavedTYK == NO) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"当前建筑物信息未保存\n请在保存后进行相关操作。" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
        return;
    }
//    BuildingModelViewController *buildingModelVC = [[BuildingModelViewController alloc] init];
//    buildingModelVC.buildingInfoIn = [self.requestDict mutableCopy];
//    [self.navigationController pushViewController:buildingModelVC animated:YES];
}



// MARK: 6. 显示modelView的按钮点击事件
-(void)showModelLoadView:(UIButton *)sender{
    

    _modelView.frame = CGRectMake(xTYK, HeigtOfTop, self.view.width - xTYK, 40.f);

    _arrowViewButton.hidden = true;
    
    
    [UIView animateWithDuration:1.f animations:^{
        sender.transform = CGAffineTransformMakeRotation(2*M_PI);
    }];
    
}

// MARK: 7. modelView中按钮的点击事件
- (void)modelButtonHandler:(UIButton *)sender{
    
    switch (sender.tag - 90100) {
        case 0:
            // 保存
            [self saveModel];
            break;
        case 1:
            // 加载
            [self loadModel];
            break;
        default:
            // 关闭
            [self closeWindow];
            break;
    }
    
    
}
// MARK: 8. 保存
-(void)saveModel{
    
    // 文件保存路径 - 以当前资源文件名命名的*.model的文件
    NSString * documentsPath = [NSString stringWithFormat:@"%@/%@/%@.model", DOC_DIR, kDeviceModel, _fileName];
    
    
    MBProgressHUD * alert = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    alert.mode = MBProgressHUDModeText;
    
    
    
    
    NSMutableArray * pinmingArr = [[self.model.subName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<+>"]] mutableCopy];
    
    [pinmingArr removeObject:@""];
    
    NSLog(@"%@", pinmingArr);
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    for (NSString * key in self.requestDict.allKeys) {
        
        // MARK: 商议后决定不保存哪些字段的内容，将其填入参数列表中
        
        
        if (!([key isEqualToString:self.model.list_sreach_name] ||
              [key isEqualToString:[self.fileName makeIdkey]] ||
              [key isEqualToString:@"startCoreSequenceGroup"] ||
              [key isEqualToString:@"endCoreSequenceGroup"] ||
              [key isEqualToString:@"cableStartStartPoint"] ||
              [key isEqualToString:@"cableEndStartPoint"] ||
              [key isEqualToString:@"bearCableSegmentRFID"]) && ![key isEqualToAnyStringInArr:pinmingArr]) {
            
            
            [dict setValue:self.requestDict[key] forKey:key];
            
        }
        
        
    }
    
    
    
    
    // 将request的对象导出到文件
    
    if ([NSKeyedArchiver archiveRootObject:dict toFile:documentsPath]) {
        
        alert.label.text = @"模板导出成功！";
        
    }else{
        
        alert.label.text = @"模板导出失败！";
        
        
    }
    
    [alert hideAnimated:true afterDelay:2.f];
    
    // 关闭
    [self closeWindow];
    
    
    
}

// MARK: 9. 加载
-(void)loadModel{
    // 文件目录
    NSString * documentsPath = [NSString stringWithFormat:@"%@/%@/%@.model", DOC_DIR, kDeviceModel, _fileName];
    
    // 取出model文件到字典
    NSDictionary * model = [NSKeyedUnarchiver unarchiveObjectWithFile:documentsPath];
    
    
    MBProgressHUD * alert = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    
    
    if (model != nil) {
        
        alert.mode = MBProgressHUDModeText;
        
        alert.label.text = @"模板加载成功！";
        
        // 当模板载入成功时，在进行赋值
        
        //        self.requestDict = [NSMutableDictionary dictionaryWithDictionary:model];
        for (NSString * key in model.allKeys) {
            
            if (self.requestDict[key] == nil) {
                [self.requestDict setObject:model[key] forKey:key];
            }
            
        }
        
        NSLog(@"%@", self.requestDict);
        
        // 并重新创建子视图
        [self showPortInfomation];
    }else{
        
        alert.mode = MBProgressHUDModeText;
        
        alert.label.text = @"模板加载失败！";
        alert.detailsLabel.text = @"可能是未保存任何模板或数据读取错误";
        
    }
    [alert hideAnimated:true afterDelay:2.f];
    
    // 关闭
    [self closeWindow];
    
    
    
}
// MARK: 10. 关闭窗口
-(void)closeWindow{
    
    _modelView.frame = CGRectMake(xTYK, HeigtOfTop, self.view.width - xTYK, 0);
    _arrowViewButton.hidden = false;
    
}
-(void)generatorTYKDevices:(IWPButton *)sender{
    
    
    if (![_requestDict.allKeys containsObject:@"GID"]) {
        // 未检测到 GID
        [YuanHUD HUDFullText:@"无GID"];
        return;
    }
    //2080001 机房 2080004放置点
    Inc_NewMB_AssistDevCollectVC * assDev = [[Inc_NewMB_AssistDevCollectVC alloc] init];
    
    assDev.requestDict = _requestDict;
//    assDev.model = _model;
    
    Push(self, assDev);
    
    
    return;

}


//MARK:  保存统一库资源信息 保存按钮点击事件   ---- yuan
//MARK:  保存 *******
//MARK:  保存 *******
//MARK:  保存 *******
//MARK:  保存 *******
//MARK:  保存 *******
//MARK:  保存 *******
//MARK:  保存 *******

-(void)saveTYKInfoData:(BOOL)isOnlyRfid{
    
  // 2021-11-29 18:16:23
    NSLog(@"self.requestDict:%@",self.requestDict);
    if (self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) {
        [self.requestDict setObject:self.fileName forKey:@"resLogicName"];
        if ([self.fileName isEqualToString:@"supportingPoints"]) {
            
            if (self.requestDict[@"supportPSubName"]!=nil) {
                
                if(self.requestDict[@"supportPointCode"]==nil||([self.requestDict[@"supportPointCode"] isEqualToString:@""])) {
                    
                    [self.requestDict setObject:self.requestDict[@"supportPSubName"] forKey:@"supportPointCode"];
                    
                }
            }
            
        }else if ([self.fileName isEqualToString:@"ledUp"]) {
            
            if (self.requestDict[@"ledupName"]!=nil) {
                
                if (self.requestDict[@"ledupPointCode"]==nil||([self.requestDict[@"ledupPointCode"] isEqualToString:@""])) {
                    
                    [self.requestDict setObject:self.requestDict[@"ledupName"] forKey:@"ledupPointCode"];
                    
                }
                
            }
            
        }else if ([self.fileName isEqualToString:@"well"]) {
            
            if (self.requestDict[@"wellSubName"]!=nil) {
                
                if (self.requestDict[@"wellCode"]==nil||([self.requestDict[@"wellCode"] isEqualToString:@""])) {
                    
                    [self.requestDict setObject:self.requestDict[@"wellSubName"] forKey:@"wellCode"];
                    
                }
            }
            
        }else if ([self.fileName isEqualToString:@"pole"]) {
            
            if (self.requestDict[@"poleSubName"]!=nil) {
                
                if (self.requestDict[@"poleCode"]==nil||([self.requestDict[@"poleCode"] isEqualToString:@""])) {
                    
                    [self.requestDict setObject:self.requestDict[@"poleSubName"] forKey:@"poleCode"];
                    
                }
            }
            
        }else if ([self.fileName isEqualToString:@"poleline"]) {
            
            if (self.requestDict[@"poleLineName"]!=nil) {
                
                if (self.requestDict[@"polelLineNo"]==nil||([self.requestDict[@"polelLineNo"] isEqualToString:@""])) {
                    //这句话 会导致 杆路编号
                    //                    [self.requestDict setObject:self.requestDict[@"poleLineName"] forKey:@"polelLineNo"];
                }
                
            }
            
        }else if ([self.fileName isEqualToString:@"markStoneSegment"]) {
            
            if (self.requestDict[@"markStoneSgName"]!=nil) {
                
                if (self.requestDict[@"markStoneSgNo"]==nil||([self.requestDict[@"markStoneSgNo"] isEqualToString:@""])) {
                    
                    [self.requestDict setObject:self.requestDict[@"markStoneSgName"] forKey:@"markStoneSgNo"];
                    
                }
            }
            
        }else if ([self.fileName isEqualToString:@"markStone"]) {
            if (self.requestDict[@"markName"]!=nil) {
                if (self.requestDict[@"markStoneCode"]==nil||([self.requestDict[@"markStoneCode"] isEqualToString:@""])) {
                    [self.requestDict setObject:self.requestDict[@"markName"] forKey:@"markStoneCode"];
                }
            }
        }
        if (_isGenSSSB == YES) {
            if (self.requestDict[@"equipmentName"]!=nil) {
                if (self.requestDict[@"eqpNo"]==nil||([self.requestDict[@"eqpNo"] isEqualToString:@""])) {
                    [self.requestDict setObject:self.requestDict[@"equipmentName"] forKey:@"eqpNo"];
                }
            }
        }
    }
    
    BOOL isInsert = NO;
    if (self.controlMode == TYKDeviceListInsert||(self.controlMode == TYKDeviceListInsertRfid)) {
        isInsert = YES;
    }
    
    NSString * keyTitle = nil;
    for (IWPViewModel * model in self.viewModel) {
        
        if (model.tv1_Required.integerValue == 1 && [self strpos:model.tv1_Text needle:@"承载的缆段"] == false && [self strpos:model.name1.lowercaseString needle:@"rfid"] == false ){
            
            if (model.type.integerValue == 3 || model.type.integerValue == 11){
                if (model.type.integerValue == 3){
                    if (![self.requestDict.allKeys containsObject:model.name1] || [self.requestDict[model.name1] isEqualToString:@"请选择"] ||
                        [self.requestDict[model.name1] isEqualToString:@"0"]){
                        keyTitle = model.tv1_Text;
                        break;
                    }
                }else{
                    
                    if (![self.requestDict.allKeys containsObject:model.name1] || [self.requestDict[model.name1] isEqualToString:@"请选择"] ||
                        [self.requestDict[model.name1] isEqualToString:@"0"]){
                        keyTitle = model.text1;
                        break;
                    }else if (self.requestDict[model.name2] == nil ||
                              [(NSString *)self.requestDict[model.name2] length] == 0){
                        keyTitle = model.text2;
                        break;
                    }
                    
                    
                    
                }
                
                
            }else{
                if (([self.requestDict[model.name1] length] == 0)){
                    
                    keyTitle = model.tv1_Text;
                    break;
                }
                
                
                
            }
            
        }
        
        
    }
    
    
    if (keyTitle != nil && !_isHaveRfid){  //非保存标签的状态 才进行这个判断
//        Present(self, SystemAlert(NSString.format(@"“%@”为必填内容，请填写后再保存",keyTitle), nil, nil, @"确定", nil, nil, nil));
        [UIAlert alertSmallTitle:[NSString stringWithFormat:@"“%@”为必填内容，请填写后再保存",keyTitle]];
        return;
    }
    
    
    // 针对时间格式做出的调整
    NSString * installDate = _requestDict[@"installDate"];
    if ([_requestDict.allKeys containsObject:@"installDate"] &&
        [installDate containsString:@"-"]) {
        NSString * value = [[StrUtil new] LocalToGMTWithSecond:_requestDict[@"installDate"]];
        _requestDict[@"installDate"] = value;
    }
    
    
    
#ifdef BaseURL
    NSString * requestURL = [NSString stringWithFormat:@"%@%@",BaseURL,isInsert?@"rm!insertCommonData.interface":@"rm!updateCommonData.interface"];
#else
    NSString * requestURL = [NSString stringWithFormat:@"%@%@",BaseURL_Auto(([IWPServerService sharedService].link)),isInsert?@"rm!insertCommonData.interface":@"rm!updateCommonData.interface"];
#endif
    
    
    
    // MARK: 袁全添加 -- 之前的是通用接口 , 并不适用于添加RDF信息表 (扫一扫) , requestURL改为适用 RDF增删改查的接口
    
    if (isOnlyRfid) {
        
        
        
        
        if (![self.requestDict.allKeys containsObject:@"rfid"]) {
            // 并没有扫描任何二维码 获得标签的情况 !
            [UIAlert alertSmallTitle:@"请添加一个标签"];
            return;
        }
        
        
        // 如果不存在 resTypeId
        if (![self.requestDict.allKeys containsObject:@"resTypeId"]) {
            // MARK: 袁全添加 需要有一个 701 要不然标签保存不上
            [self.requestDict setObject:@"701" forKey:@"resTypeId"];
        }
        
        
        
        
#ifdef BaseURL
        requestURL = [NSString stringWithFormat:@"%@%@",BaseURL,isInsert?@"rm!insertGIDandRFID.interface":@"rm!updateRfidAndGidRelation.interface"];
#else
        requestURL = [NSString stringWithFormat:@"%@%@",BaseURL_Auto(([IWPServerService sharedService].link)),isInsert?@"rm!insertGIDandRFID.interface":@"rm!updateRfidAndGidRelation.interface"];
#endif
        
        
    }
    
    
    if (_isHaveRfid) {  //只有在按钮叫 保存标签的时候 才传这个
        //不再修改资源信息 只修改绑定的标签  -- 之前注释掉了 , 但在'动力设备信息'的时候又解开了
        [self.requestDict setObject:@"1" forKey:@"onlyUpdateRfid"];
    }
    
    
    if ([self.fileName isEqualToAnyString:@"markStonePath", @"markStone", @"markStoneSegment", nil]) {
        
        NSString * interface = @"";
        
        if ([self.fileName isEqualToString:@"markStonePath"]) {
            //rm!updateCommonData.interface
            if (isInsert) {
                interface = @"insertCommonData";
            }else{
                interface = @"updateCommonData";
            }
            
        }else if ([self.fileName isEqualToString:@"markStone"]){
            
            if (isInsert) {
                interface = @"insertCommonData";
            }else{
                interface = @"updateCommonData";
            }
            
        }else{
            
            if (isInsert) {
                interface = @"insertMarkStoneSeg";
            }else{
                interface = @"updateMarkStoneSeg";
            }
            
        }
        
        interface = [NSString stringWithFormat:@"rm!%@.interface", interface];
        
        requestURL = [NSString stringWithFormat:@"%@%@",BaseURL_Auto(([IWPServerService sharedService].link)), interface];
        
    }
    
    
    NSLog(@"requestURL---%@",requestURL);
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    // 这里拦截UserModel.uid为空时

    if (UserModel.uid == nil) {
    
        [YuanHUD HUDFullText:@"登录信息失效，请重新登录"];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
        
    }
    [param setValue:UserModel.uid forKey:@"UID"];
    

    
    if (![self.requestDict.allKeys containsObject:@"resLogicName"]) {
        self.requestDict[@"resLogicName"] = self.fileName;
    }
    
    
    // 只有二级子孔 , 才需要传 isFather 字段
    if ([_fileName isEqualToString:@"tube"] && _isNeed_isFather) {
        self.requestDict[@"isFather"] = @"2";
    }
    
    
    
    // 避免某些版本会自动 +8 时区 , 所有新增了去除 8时区的方法
    for (IWPViewModel * model in _viewModel) {
        if ([[Yuan_Foundation fromObject:model.type] isEqualToString:@"10"]) {
            _requestDict = [_MB_VM Special_MB_KeyConfig:self.requestDict key:model.name1];
        }
    }
    
    
    
    NSError * err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.requestDict options:NSJSONWritingPrettyPrinted error:&err];
    // 这里拦截解析字典出错
    if (err) {
      
        [YuanHUD HUDFullText:err.localizedDescription];
        
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    // jsonData有内容时，str一定不为空
    NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"jsonStr = %@",str);
    
    // "startUseDate" : "Mar 08, 2020 21:01:00"
    
    [param setValue:str forKey:@"jsonRequest"];
    
    NSLog(@"param = %@",param);
    

    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    
    ////  http://120.52.12.11:8080/im/service/rm!updateRfidAndGidRelation.interface
    //http://120.52.12.11:8080/im/service/rm!updateCommonData.interface
    // 保存的网络请求
    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];

        NSLog(@"%@", dict);
        
        NSNumber * num = dict[@"success"];


        if (num.intValue == 1) {
                        
            NSLog(@"%@", dict[@"info"]);
        
            NSData *tempData=[REPLACE_HHF(dict[@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            _successArr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            
            if (_isCopy) {
                [self  http_getLimitData];

                return;
            }
            
            [self saveSuccess];
            
            
        }else{
            
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@的资源保存失败",_model.name]];
        }
        
        [[Yuan_HUD shareInstance] HUDHide];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {

        
        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}

//查询列框无数据回调
- (void) Http_InfoNotification:(NSNotification *) noti_Dict {
    
    NSDictionary * dict = noti_Dict.userInfo;
    
    if ([dict[@"info"] isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString * info = dict[@"info"];
    
    if (info && [info rangeOfString:@"统一库没有该资源"].location != NSNotFound) {
        // 当有info 并且info包含子字符串 '统一库没有该资源' 时
        if (_isCopy) {
            [self saveSuccess];
        }
        
    }
    
}

//正常保存使用
- (void)saveSuccess{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",@"操作成功"] message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.delegate respondsToSelector:@selector(newDeciceWithDict:)]) {
            if (_successArr.count>0) {
                if (_isCopy) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"copySuccessful" object:nil];
                }else{
                    [self.delegate newDeciceWithDict:[[NSMutableDictionary alloc] initWithDictionary:_successArr[0]]];
                }
            }
            
        }else {
            //odf 增加  没有走代理的情况  目前Zhang_ODFListVC使用
            if ([self.fileName isEqualToString:@"ODF_Equt"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ODFSuccessful" object:nil];

            }
            
            //端子 增加  没有走代理的情况  目前Yuan_ScrollVC点击端子保存后使用
            if ([self.fileName isEqualToString:@"opticTerm"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OpticTermSuccessful" object:nil];

            }
            
        }
        isSavedTYK = YES;
        if (self.controlMode == TYKDeviceInfomationTypeDuanZiMianBan_Update) {
            //更新端子面板左面端子状态显示以及刷新数据
            NSMutableArray *list_p = [[NSMutableArray alloc] initWithArray:pointListMap[[NSString stringWithFormat:@"%ld",(long)self.card_code]]];
            for (int i = 0;i<list_p.count;i++) {
                NSDictionary *tt = list_p[i];
                if ([tt[@"GID"] isEqualToString:self.requestDict[@"GID"]]) {
                    list_p[i] = self.requestDict;
                    break;
                }
            }
            [pointListMap setObject:list_p forKey:[NSString stringWithFormat:@"%ld",(long)self.card_code]];
            [pointCollectionView reloadData];
            
        }
        
        [self dismisSelf];
        
        /// MARK: 袁全添加 --- 点击保存后 , 返回上一个界面 并且 回调让端子变化
        if (_successArr.count>0) {
            _requestDict = _successArr.firstObject;
        }

        if (_Yuan_ODFOCC_Block) {   //如果实现了block 则 保存后 返回 并且带回数据 改变端子状态
            // 回调端子状态  , 让按钮 发生改变  // 把请求成功的request 替换 按钮的dict
            _Yuan_ODFOCC_Block(_requestDict);
            
        }
        
        
        // 光缆段纤芯配置模块
        if (_Yuan_CFBlock) {
            _Yuan_CFBlock(_requestDict);
            
        }
        
        
        // 保存成功的通用回调
        if (_savSuccessBlock) {
            _savSuccessBlock();
        }
        
        
    }];
    [alert addAction:action];
    Present(self, alert);
    isSavedTYK = YES;
    
}


- (void)showRouteInfo:(UIButton *)sender{
    // 查看路由
    
    
    GisTYKMainViewController * gis = [[GisTYKMainViewController alloc] init];
    gis.GID = self.requestDict[@"GID"];
    gis.resLogicName = @"opticTerm";
    
//    GisMainViewController *gisMainVC = [[GisMainViewController alloc] init];
//    gisMainVC.point = _list_1[pointIndex];
    [self.navigationController pushViewController:gis animated:YES];
    
}



#pragma mark - 端子查光缆段 ---
- (void) TerminalSelectCable {
    
    [self TerminalSelectCableView:@""
                         cableGID:@""];
    

//    NSString * URL = [NSString stringWithFormat:@"http://120.52.12.12:8951/increase-res-search/optRes/findOptSectByTermId"];
    
    NSDictionary * dict = @{
        
        @"reqDb" : [Yuan_WebService webServiceGetDomainCode],
        @"id" : _requestDict[@"GID"]
    };
    
    [[Http shareInstance] DavidJson_NOHUD_PostURL:David_SelectUrl(@"optRes/findOptSectByTermId") Parma:dict success:^(id result) {
           
        if (result) {
            [self TerminalSelectCableView:[NSString stringWithFormat:@"%@  %@芯",result[@"resName"]?:@"",result[@"pairNo"]?:@""]
                                 cableGID:result[@"resId"]];
        }
    }];
    
    [self Http_GetRouterAndCircuitInfo:@{@"id":_requestDict[@"GID"]}];

}


- (void) TerminalSelectCableView:(NSString *) name
                        cableGID:(NSString *)cableGID {
    
    
    if (_terminalSelectCableView) {
        
        [_terminalSelectCableView removeFromSuperview];
        _terminalSelectCableView = nil;
    }
    
    _terminalSelectCableView =
    [[Yuan_TerminalSelectCableView alloc] initWithCableName:name
                                                      block:^{
    
        [self selectGidWithCable:cableGID];
    }];

    _terminalSelectCableView.backgroundColor = ColorValue_RGB(0xf2f2f2);
    
    [self.view addSubview:_terminalSelectCableView];

    
    [_terminalSelectCableView YuanToSuper_Left:0];
    [_terminalSelectCableView YuanToSuper_Right:0];
    [_terminalSelectCableView YuanToSuper_Top:NaviBarHeight];
    [_terminalSelectCableView autoSetDimension:ALDimensionHeight toSize:Vertical(100)];
        
}


- (void) selectGidWithCable : (NSString *) cableId {
    
    
    if (!cableId || cableId.length == 0) {
        
        [YuanHUD HUDFullText:@"该端子未成端"];
        return;
    }
    
    NSDictionary * dict = @{
        
        @"resLogicName" : @"cable",
        @"GID" : cableId
        
    };
    
    
    
    [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Get
                             dict:dict
                          succeed:^(id data) {
       
        NSArray * arr = data;
        
        if (!arr || arr.count == 0) {
            return;
        }
        [Inc_Push_MB push_NewMB_Detail_RequestDict:arr.firstObject Enum:Yuan_NewMB_ModelEnum_optSect vc:self];

    }];
    
}



#pragma mark - 稽核校验接口 ---

- (void) Yuan_NewCheckPort:(void(^)(NSArray * result))block {
    
    
    NSDictionary * dict = @{
        @"resId":_requestDict[@"GID"],
        @"numType" : _Yuan_NewCheckId,
        @"provinceCode" : Yuan_WebService.webServiceGetDomainCode
    };
    
    //1 合格 0 不合格
    [Http.shareInstance DavidJsonPostURL:@"http://120.52.12.12:8951/increase-res-operation/resStat/findToResStateCheck"
                                   Parma:dict
                                 success:^(id result) {
        
        
        
    }];
    
    
}



//zzc 2021-6-15  业务状态同步变更查询
- (void)Http_UpdateOprState:(NSDictionary *)param {
    
    [Inc_NewFL_HttpModel1 Http_UpdateOprState:param success:^(id  _Nonnull result) {
       
        if (result) {
            NSString *msg  = result[@"MESS"]?:@"";
            if (msg.length == 0) {
                //optPairRouterList 没有值走原方法
                NSArray *array = result[@"optPairRouterList"];
                if (array.count > 0) {
                    
                    [_httpSynchronousArray addObjectsFromArray:array];
                    [self.synchronousArray removeAllObjects];

                    NSDictionary *dic = array[0];
                    
                    if (dic[@"eptName"]) {
                        // 调用数据
                        [_synchronousArray addObjectsFromArray:array];
                        
                    }else{
                        
                        
                        NSArray *linkRelationList = dic[@"linkRelationList"];

                        if (linkRelationList.count > 0) {
                            [_synchronousArray addObjectsFromArray:linkRelationList];
                        }
                        
                    }
                    
                    _windowBgView.hidden = NO;
                    _synchronousView.hidden = NO;
                    
                    CGFloat height = 0.0;
                    //计算table高度
                    for (NSDictionary *dic in self.synchronousArray) {
                        
                        CGFloat title1Hight1 = [dic[@"relateResName"] boundingRectWithSize:CGSizeMake(ScreenWidth - 120, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font(15)} context:nil].size.height;
                        
                        CGFloat title1Hight2 = [dic[@"eptName"] boundingRectWithSize:CGSizeMake(ScreenWidth - 120, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font(15)} context:nil].size.height;
                      
                        height += MAX(30, title1Hight1+1) + MAX(30, title1Hight2+1) + 10;

                    }
                    
                    
                    _synchronousView.frame = CGRectMake(20,100, ScreenWidth - 50, MIN(height + 80 + 64, ScreenHeight - NaviBarHeight - 150));
                    _synchronousView.center = self.view.center;
                    _synchronousView.dataArray = _synchronousArray;
                    
                    [_synchronousView reloadData];
                    
                }else{
                    
                    if (self.isGenSSSB) {
                        [self saveTYKInfoData:NO];
                        return;
                    }
                    
                    // 2006-01-06 22:01:00
                    
                    [self saveTYKInfoData:NO];
                }
                
            }else{
                
                if ([msg containsString:@"已有光路占用"]) {
                    [YuanHUD HUDFullText:msg];
                    return;
                }
                
                
                if (self.isGenSSSB) {
                    [self saveTYKInfoData:NO];
                    return;
                }
                
                // 2006-01-06 22:01:00
                
                [self saveTYKInfoData:NO];
            }
            
        }
        
    }];
    
}


- (void) Http_ConfirmUpdateOprState:(NSDictionary *)param {
    
    [Inc_NewFL_HttpModel1 Http_ConfirmUpdateOprState:param success:^(id  _Nonnull result) {
        if (result) {
            if (self.isGenSSSB) {
                [self saveTYKInfoData:NO];
                return;
            }
            
            // 2006-01-06 22:01:00
            
            [self saveTYKInfoData:NO];
        }
        
        _windowBgView.hidden = YES;
        _synchronousView.hidden  = YES;
    }];
}


- (void) Http_SelectRoadInfoByTermPairId:(NSDictionary *)param {
    [Inc_NewFL_HttpModel1 Http_SelectRoadInfoByTermPairId:param success:^(id  _Nonnull result) {
        
        if (result) {
            NSArray *array = result;
            
            if (array.count == 0) {
                
                [YuanHUD HUDFullText:@"没有关联的光路"];

            }else {
                NSDictionary *dic = array[0];
                
                //push详情
                [self GetDetailWithGID:dic[@"optRoadId"] block:^(NSDictionary *dict) {

                    // 跳转模板
                    [Inc_Push_MB pushFrom:self
                              resLogicName:@"opticalPath"
                                      dict:dict
                                      type:TYKDeviceListUpdate];
                }];
                
            }
        }
        
    }];
}

// 根据 Gid 和 reslogicName 获取 详细信息
- (void) GetDetailWithGID:(NSString *)GID
                    block:(void(^)(NSDictionary * dict))block{
    
    NSDictionary * dict = @{
        @"resLogicName" : @"opticalPath",
        @"GID":GID
    };
    
    [Http.shareInstance V2_POST:HTTP_TYK_Normal_Get
                           dict:dict
                        succeed:^(id data) {
            
        NSArray * arr = data;
        
        if (arr.count > 0) {
            block(arr.firstObject);
        }
        
    }];
    
}


//zzc 2021-7-13  通过端子id查询承载业务
- (void) Http_GetRouterAndCircuitInfo:(NSDictionary *)param {
    
    [Inc_NewFL_HttpModel1 Http_GetRouterAndCircuitInfo:param success:^(id result) {
        if (result) {
            NSArray *arr = result;
            if (arr.count > 0) {
                NSDictionary *dic = arr.firstObject;
                [_terminalSelectCableView updateCarryName:dic[@"circuitName"]?:@"无"];
            }else{
                [_terminalSelectCableView updateCarryName:@"无"];
            }
            
        }else{
            [_terminalSelectCableView updateCarryName:@"获取失败"];
        }
    }];
}


//通过设备id获取端子盘数据
- (void) http_getLimitData{
    
    if (_successArr.count > 0) {
        NSDictionary *copyDic = _successArr.firstObject;

        NSString *postType;
        NSString *eqpName;
        if ([_fileName isEqualToString:@"ODF_Equt"]){
         
            postType = @"1";
            eqpName = copyDic[@"rackName"];
            
        }else if([_fileName isEqualToString:@"OCC_Equt"]){
           
            postType = @"2";
            eqpName = copyDic[@"occName"];

        }else if([_fileName isEqualToString:@"ODB_Equt"]){
           
            postType = @"3";
            eqpName = copyDic[@"odbName"];

        }
      
        //查询复制设备所有列框信息
        [Yuan_ODF_HttpModel ODF_HttpGetLimitDataWithID:_gId
                                              InitType:postType
                                          successBlock:^(id  _Nonnull requestData) {
            
            NSArray * resultArray = requestData;
            
            if (resultArray.count == 0) {
                [[Yuan_HUD shareInstance] HUDFullText:@"暂无数据"];
                return ;
            }
          
            NSMutableArray *successArray = NSMutableArray.array;
            
            __block  int i = 0;
            
            for (NSDictionary *dic in resultArray) {
                
                NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
                dictionary[@"resLogicName"] = @"cnctShelf";
                dictionary[@"moduleTubeRow"] = @"1";                            //固定 1
                
                dictionary[@"eqpId"] = eqpName;                               // 虽然参数叫 Id  但 传的是name
                dictionary[@"eqpId_Type"] = dic[@"eqpId_Type"];
                dictionary[@"eqpId_Id"] = copyDic[@"GID"];                              //设备Id
                dictionary[@"position"] = dic[@"position"];
                dictionary[@"moduleRowQuantity"] = dic[@"moduleRowQuantity"];         //模块行数
                dictionary[@"moduleColumnQuantity"] = dic[@"moduleColumnQuantity"];   //模块列数
                dictionary[@"faceInverse"] = dic[@"faceInverse"];              //1 正面 2 反面
                dictionary[@"noRule"] = dic[@"noRule"];
                dictionary[@"noDire"] = dic[@"noDire"];
                
                NSDictionary *dict = @{
                    @"resLogicName":@"module",
                    @"shelfName_Id":dic[@"cnctShelfId"],
                    @"start":@"1",
                    @"limit":@"1"
                };
                
                //根据列框查询模块端子数目
                [[Http shareInstance] V2_POST:ODFModel_GetLimitData
                                         dict:dict
                                      succeed:^(id data) {
                                        
                    NSArray *array = data;
                    NSDictionary *tempDic = array.firstObject;
                    
                    // TODO: 端子数目目前返回固定值12，后续需要调试
                    
                    dictionary[@"moduleTubeColumn"] = tempDic[@"moduleTubeColumn"];           //模块端子数量
                    
                    //添加模块
                    [[Http shareInstance] V2_POST:ODFModel_InitPie
                                             dict:dictionary
                                          succeed:^(id data) {
                        
                        //成功添加
                        [successArray addObject:dic];
                        
                        NSArray * dataSource = data;
                        
                        if ([dataSource isEqual:[NSNull null]]) {
                            
                            [[Yuan_HUD shareInstance] HUDFullText:@"数据格式错误 NULL"];
                        }
                        
                        i++;
                        
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        
                        if (i == resultArray.count) {
                            
                            [MBProgressHUD hideHUDForView:self.view animated:YES];

                            if (successArray.count != resultArray.count) {
                                if (successArray.count > 0) {
                                    NSMutableArray *countArr = NSMutableArray.array;
                                    
                                    for  (NSDictionary *dicRes in resultArray){
                                        
                                        if (![successArray containsObject:dicRes]) {
                                            NSString *str = [NSString stringWithFormat:@"%@%@框复制失败",[self getFace:dicRes[@"faceInverse"]] ,dicRes[@"position"]];
                                            [countArr addObject:str];
                                        }
                                    }
                                    
                                    [UIAlert alertSingle_SmallTitle:[countArr componentsJoinedByString:@"\n"] agreeBtnBlock:^(UIAlertAction *action) {
                                       
                                        [self saveSuccess];
                                    }];
                                }
                                
                            }else{
                                
                                [self saveSuccess];
                            }
                        }
                    }];
                    
                }];
                
            }
                    
        }];
    }else{
        [self saveSuccess];
    }
}

- (NSString *)getFace:(NSString *)str {
    
    if ([str isEqualToString:@"1"]) {
        return @"正面";
    }else{
        return @"反面";
    }
    
}

#pragma mark -zzc  btnClick

//需要点击背景隐藏 打开
-(void)tapEvent:(UITapGestureRecognizer *)gesture {
    _windowBgView.hidden = YES;
    _synchronousView.hidden  = YES;
}

- (void)sureBtnClick {
    
    // state  1  列表显示的全部修改   2 只修改当前
    NSDictionary *parm;
    
    if ([self.fileName isEqualToString:@"optPair"]) {
        parm = @{
            @"gid":self.requestDict[@"GID"],
            @"resType":@"pair",
            @"oprStateId":[self getOprStateId:self.requestDict[@"oprStateId"]],
            @"status":@"1",
            @"optPairRouterList":_httpSynchronousArray
        };
    }else{
        parm = @{
            @"gid":self.requestDict[@"GID"],
            @"resType":@"optTerm",
            @"oprStateId":[self getOprStateId:self.requestDict[@"oprStateId"]],
            @"status":@"1",
            @"optPairRouterList":_httpSynchronousArray
        };
    }
    
    
    [self Http_ConfirmUpdateOprState:parm];
}

- (void)cancelBtnClick {
    _windowBgView.hidden = YES;
    _synchronousView.hidden  = YES;
    _deviceInfoTipView.hidden = YES;

}

// 字符串转换
- (NSString *)getOprStateId:(NSString *)optStr{
    
    NSDictionary *dic =
                      @{@"空闲":@"170001",
                        @"预占":@"170002",
                        @"占用":@"170003",
                        @"预释放":@"170005",
                        @"预留":@"170007",
                        @"预选":@"170014",
                        @"备用":@"170015",
                        @"停用":@"160014",
                        @"闲置":@"160065",
                        @"损坏":@"170147",
                        @"测试":@"170046",
                        @"临时占用":@"170187",
                        @"部分占用":@"81004360",
                        @"置满":@"81004361" };
    return dic[optStr];
    
    
}


#pragma mark - AMapNaviCompositeManagerDelegate

// 发生错误时,会调用代理的此方法
- (void)compositeManager:(AMapNaviCompositeManager *)compositeManager error:(NSError *)error {
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

// 算路失败后的回调函数,路径规划页面的算路、导航页面的重算等失败后均会调用此方法
- (void)compositeManager:(AMapNaviCompositeManager *)compositeManager onCalculateRouteFailure:(NSError *)error {
    NSLog(@"onCalculateRouteFailure error:{%ld - %@}", (long)error.code, error.localizedDescription);
}



#pragma mark - menu ---
// 下拉菜单
-(MLMenuView *)menu {
    
    if (_menu == nil) {
        

        float menuWidth = ScreenWidth / 4;
        
        CGRect menuRect =  CGRectMake(ScreenWidth - menuWidth - 10,
                                      0,
                                      menuWidth,
                                      0);
        
        MLMenuView * menuView =
        [[MLMenuView alloc] initWithFrame:menuRect
                               WithTitles:_newBtnTitles
                           WithImageNames:nil
                    WithMenuViewOffsetTop:NaviBarHeight
                   WithTriangleOffsetLeft:menuWidth - 10
                            triangleColor:UIColor.whiteColor
                               cellHeight:Vertical(45)];
        
        
        _menu = menuView;
        
        menuView.separatorOffSet = 0;
        menuView.separatorColor = HexColor(@"#eee");
        [menuView brightColor:UIColor.lightGrayColor radius:10 offset:CGSizeMake(2, 2) opacity:1.f];
        [menuView setMenuViewBackgroundColor:[UIColor whiteColor]];
        menuView.titleColor = [UIColor colorWithHexString:@"#333"];
        menuView.font = [UIFont systemFontOfSize:12];
        
        [menuView setCoverViewBackgroundColor:UIColor.clearColor];
        menuView.delegate = self;
    }
    
    return _menu;
    
}


- (void)menuView:(MLMenuView *)menu didselectItemIndex:(NSInteger)index {
    
    SEL selector = _newSelectors[index];
    
    [self performSelector:selector withObject:nil afterDelay:0.0];

}

-(BOOL) strpos:(NSString * )str  needle:(NSString * )needle{
    if (str == nil || needle == nil || [str isEqualToString:@"null"] || [needle isEqualToString:@"null"]) {
        return false;
    }
    return [str rangeOfString:needle].length > 0;
    
}

@end
