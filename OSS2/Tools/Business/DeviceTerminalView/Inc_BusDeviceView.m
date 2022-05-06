//
//  Inc_BusDeviceView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BusDeviceView.h"


#import "Yuan_ODF_HttpModel.h"

#import "Yuan_SinglePicker.h"
#import "Yuan_CFConfigVM.h"


#import "Yuan_NewFL_HttpModel.h"


typedef NS_ENUM(NSUInteger , BusDevice_HttpPort_) {
    BusDevice_HttpPort_Old,     //走龙哥老接口查询端子详细信息
    BusDevice_HttpPort_New,     //走大为新接口查询端子详细信息
};


typedef NS_ENUM(NSUInteger , BusDevice_InitType_) {
    BusDevice_InitType_1,   //构造器1 -- 最原始的构造器 , 有切换
    BusDevice_InitType_2,   //构造器2 -- 根据端子盘数据 , 初始化指定端子盘的构造器 , 无切换
    BusDevice_InitType_3,   //构造器3 -- 根据设备Id 和 端子盘id , 查询并展示指定的端子盘 , 有切换
    BusDevice_InitType_4,   //直接根据数据初始化端子盘 , 跳过网络请求
};



//MARK:  是使用老接口查询 还是 新接口查询 **** ****
static BusDevice_HttpPort_ _httpType = BusDevice_HttpPort_Old;


@interface Inc_BusDeviceView () <UIScrollViewDelegate>

/** 下半部 collection -- 成端*/
@property (nonatomic,strong) Inc_BusODFScrollView *fiberScrollCollectionView;

/** 选择按钮 */
@property (nonatomic,strong) UITextField * switchField;

@end

@implementation Inc_BusDeviceView

{
    
    UIViewController * _vc;
    
    Yuan_SinglePicker * _picker;
    Yuan_CFConfigVM * _viewModel;
    
    
    //  *** ***  成端所需要的成员变量 *** ***
        
    // 设备Id
    NSString * _deviceId;
    NSDictionary * _deviceDict;
    
    // 指定的端子盘id -- 构造器3使用
    NSString * _appointPieId;
    
    NSInteger _menuSelectRow;
    
    NSMutableArray * _pieDetailArray;  // 每个框对应的详细信息的array @{postion : array}结构
    
    NSDictionary * _pieMsgDict;
    
    NSMutableArray * _device_List_DataSource;   // 成端专用 数据源  来自网络请求
    
    NSMutableArray * _meunTitleArray;  // 来自 _device_List_DataSource
    
    NSString * _moduleRowQuantity;  // 模块行数
    
    NSString * _moduleColumnQuantity; //模块列数
    
    Important_ _importRule;   //行优 还是 列优  枚举值
    
    Direction_ _dire;  // 上左 上右 下左 下右
    
    NSDictionary * _nowShowPieDict;
    
    // 构造器
    BusDevice_InitType_ _EnumInitType;
    
}



#pragma mark - 初始化构造方法

/// 根据设备Id 请求下属端子盘 , 再根据第一个端子盘请求下属端子信息
- (instancetype)initWithDeviceId:(NSString *)deviceId
                      deviceDict:(NSDictionary *)deviceDict
                              VC:(UIViewController *)vc{
    
    if (self = [super init]) {
        
        _EnumInitType = BusDevice_InitType_1;
        
        _viewModel = Yuan_CFConfigVM.shareInstance;
        _deviceDict = deviceDict;
        _deviceId = deviceId;
        _vc = vc;
        
        [self UI_init];
        [self http_Port_FiberPie];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(terminalLongPress:)
                                                     name:BusScrollItemLongPressNotification
                                                   object:nil];
        
    }
    return self;
}




/// 根据端子盘信息 , 查询下属端子
- (instancetype)initWithPieDict:(NSDictionary *)pieDict
                             VC:(UIViewController *)vc {
    
    if (self = [super init]) {
        
        _EnumInitType = BusDevice_InitType_2;
        
        _viewModel = Yuan_CFConfigVM.shareInstance;
        _vc = vc;
        _pieMsgDict = pieDict;
        
        [self UI_init];
        [self httpGetPieDetailWithDict:pieDict isFirstTime:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(terminalLongPress:)
                                                     name:BusScrollItemLongPressNotification
                                                   object:nil];
        
    }
    return self;
    
}



/// 根据已知的设备Id 和 端子盘Id , 查询对应的端子盘信息  -- 构造器3
/// 目前支持的设备类型 : OCC_Equt(光交箱) ODB_Equt(光分箱) ODF_Equt(机架)
- (instancetype)initWithDeviceId:(NSString *)deviceId
              deviceResLogicName:(NSString *)deviceResLogicName
                           pieId:( NSString * _Nullable )pieId
                              VC:(UIViewController *)vc {
    
    if (self = [super init]) {
        
        _EnumInitType = BusDevice_InitType_3;
        
        _viewModel = Yuan_CFConfigVM.shareInstance;
        _vc = vc;
        _deviceId = deviceId;

        [self UI_init];
        
        // 根据pieId 和 设备resLogicName 进行请求
        [self http_DetailFromPieId:pieId
                deviceResLogicName:deviceResLogicName];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(terminalLongPress:)
                                                     name:BusScrollItemLongPressNotification
                                                   object:nil];
        
    }
    return self;
    
}



/// 直接跳过网络请求初始化端子盘 -- 构造器4
- (instancetype) initWithLineCount:(int)lineCount
                          rowCount:(int)rowCount
                         Important:(Important_)import
                         Direction:(Direction_)dire
                        dataSource:(NSArray *)dataSource
                           PieDict:(NSDictionary *)pieDict
                                VC:(UIViewController *)VC {
    
    
    
        
    if (self = [super init]) {
    
        
        _EnumInitType = BusDevice_InitType_4;
        
        _viewModel = Yuan_CFConfigVM.shareInstance;
        _viewModel.isInitType_4_Mode = YES;
        _vc = VC;
        
        
        _fiberScrollCollectionView =
        [[Inc_BusODFScrollView alloc] initWithLineCount:lineCount
                                                rowCount:rowCount
                                               Important:import
                                               Direction:dire
                                              dataSource:dataSource
                                                 PieDict:pieDict
                                                      VC:_vc];
        
        
        _fiberScrollCollectionView.delegate = self;
        _fiberScrollCollectionView.scrollEnabled = YES;
        
        _fiberScrollCollectionView.backgroundColor = [UIColor whiteColor];
        _fiberScrollCollectionView.showsVerticalScrollIndicator = NO;
        _fiberScrollCollectionView.showsHorizontalScrollIndicator = NO;
        _fiberScrollCollectionView.bounces = NO;
        
        __typeof(self)weakSelf = self;
        
        _fiberScrollCollectionView.itemSelectBlock = ^(Inc_BusScrollItem * _Nonnull selectItem) {
          
            [weakSelf itemSelectBlock:selectItem];
        };
        
        [self addSubview:_fiberScrollCollectionView];
        
        [_fiberScrollCollectionView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:Vertical(10)];
        
        [_fiberScrollCollectionView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [_fiberScrollCollectionView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [_fiberScrollCollectionView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:Vertical(10)];
        
    }
    return self;
    
    
}


#pragma mark - Http ---

///MARK: 通过 设备查端子盘信息
- (void) http_Port_FiberPie {
    
    NSString * initType = @"";
    
    //ODF : 1 ,OCC : 2 , ODB : 3
    NSNumber * resTypeId = _deviceDict[@"resTypeId"] ?: @0;
    
    // inittype == 1 传1 ODF
    if (resTypeId.integerValue == 3 ||
        resTypeId.integerValue == 703) {  //OCC 光交接箱 传2
        
        initType = @"2";
    }
    
    else if (resTypeId.integerValue == 4 ||
             resTypeId.integerValue == 704) { //ODB 光分纤箱和光终端盒 传3
        
        initType = @"3";
    }
    
    else {                                      //ODF 传1
        initType = @"1";
    }
    
    
    // 首先 要请求 所有端子盘的列表
    
    [Yuan_ODF_HttpModel ODF_HttpGetLimitDataWithID:_deviceId ?: @""
                                          InitType:initType
                                      successBlock:^(id  _Nonnull requestData) {
        
        
        // 一共有多少个端子盘 ?
        _device_List_DataSource = [requestData mutableCopy];
        
        if (_device_List_DataSource.count == 0 || !_device_List_DataSource) {
            [[Yuan_HUD shareInstance] HUDFullText:@"暂无ODF端子盘"];
            return ;
        }
        
        else {
            
            // 更新下拉框内容
            
            // 默认请求列表的第一个数据
            _meunTitleArray = [NSMutableArray array];
            NSMutableArray * pieIdsArr = NSMutableArray.array;
            for (NSDictionary * dict in _device_List_DataSource) {
                
                NSString * faceInverse = @"反面";
                NSString * position = [NSString stringWithFormat:@"列框-%@",dict[@"position"] ?:@""];
                
                // 2020.08.28新增 当 faceInverse = 3 ,'无'
                if ([dict[@"faceInverse"] isEqualToString:@"1"] ||
                    [dict[@"faceInverse"] isEqualToString:@"3"]) {
                    // 正面
                    faceInverse = @"正面";
                }
                
                
                // 举例  正面-1框
                [_meunTitleArray addObject:[faceInverse stringByAppendingString:position]];
                
                // 所有端子盘Id的数组
                [pieIdsArr addObject:dict[@"GID"]];
            }
            
        
            // 配置单选的数据源
            [self configPickerData];
            
            
            // 如果有指定查看的端子盘id , 则查看该端子盘id
            if (_appointPieId) {
                
                if ([pieIdsArr containsObject:_appointPieId]) {
                    
                    NSInteger index = [pieIdsArr indexOfObject:_appointPieId];
                    
                    _switchField.text = _meunTitleArray[index];
                    
                    _menuSelectRow = index;
                    
                    // 取指定索引的数据
                    [self httpGetPieDetailWithDict:_device_List_DataSource[index]
                                       isFirstTime:YES];
                    
                }
                
                // 数组中 不存在该端子盘Id
                else {
                    [YuanHUD HUDFullText:@"未查询到该端子盘Id"];
                    return;
                }
            }
            
            // 没有指定的端子盘Id 则走正常的请求
            else {
                // 发起默认第一个请求
                [self httpGetPieDetailWithDict:[_device_List_DataSource firstObject]
                                   isFirstTime:YES];
            }
            
        }
        
    }];
    
}



///MARK: 需要根据不同的dict(端子盘) 请求不同的端子盘详情 并刷新界面
- (void) httpGetPieDetailWithDict:(NSDictionary *) dict
                      isFirstTime:(BOOL)isFirstTime{
    
    _pieDetailArray = NSMutableArray.array;  //每次进这个请求都初始化一次这个数组
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),  ^{
        
        // 旧版接口
        if (_busHttp_Enum == Yuan_BusHttpPortEnum_Old) {
            
            [self old_Port_Dict:dict isFirstTime:isFirstTime];
        }
        
        
        // 新版接口
        if (_busHttp_Enum == Yuan_BusHttpPortEnum_New) {
        
            [self new_Port_Dict:dict isFirstTime:isFirstTime];
        }
        
    });
    

    
}



/// 新接口
- (void) new_Port_Dict:(NSDictionary *) dict
           isFirstTime:(BOOL)isFirstTime {
    
    // 通过模块id 查询
    [Yuan_ODF_HttpModel http_NewPort_SelectTerminalsFromDict:@{@"id" : dict[@"GID"]}
                                                successBlock:^(id  _Nonnull requestData) {
            
        
        NSArray * result = requestData;
        
        if (result.count == 0) {
            [YuanHUD HUDFullText:@"未查询到该列框的下属端子"];
            return;
        }
        
        NSDictionary * columnDict = result.firstObject;
        
        NSArray * rmeModuleList = columnDict[@"rmeModuleList"];
        
        for (NSDictionary * dict in rmeModuleList) {
            [_pieDetailArray addObject:@{dict[@"position"]:dict}];
        }
        
        if (_pieDetailArray.count == 0) {
            [[Yuan_HUD shareInstance] HUDFullText:@"未获取到模块数据"];
            return ;
        }
        
        // 初始化 odf端子盘详情必要的参数
        [self initColumWithDict:dict isNewPort:YES] ;
        
        
        // 第一次初始化时
        if (isFirstTime) {

            // 初始化view
            [self addSubview:self.fiberScrollCollectionView];
            [self layout_ChengDuan_ScrollCollection];

        }
        
        // 选择picker 刷新时
        else {

            // 先移除 再重新加载一遍 , 避免切换数据以后的UI混乱
            [_fiberScrollCollectionView removeFromSuperview];
            _fiberScrollCollectionView = nil;


            [self addSubview:self.fiberScrollCollectionView];
            [self layout_ChengDuan_ScrollCollection];
        }
        
        // 新版光纤光路
        if (_busDevice_Enum == Yuan_BusDeviceEnum_NewFL) {
            [self NewFL_SelectTerminalState:dict];
        }
        
        // 网络请求成功的回调
        if (_httpSuccessBlock) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(1 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(),  ^{

                _httpSuccessBlock();
            });
        }
        
    }];
    
}







/// 老接口
- (void) old_Port_Dict:(NSDictionary *) dict
           isFirstTime:(BOOL)isFirstTime {
    
    
    [Yuan_ODF_HttpModel ODF_HttpDetail_Dict:dict
                               successBlock:^(id  _Nonnull requestData) {
        NSLog(@"requestData:%@",requestData);
        
        NSDictionary * req = requestData;
        
        NSArray * data = req[@"modules"];   // 所有模块的数组
        
        for (NSDictionary * dict in data) {
            [_pieDetailArray addObject:@{dict[@"position"]:dict}];
        }

        
        if (_pieDetailArray.count == 0) {
            [[Yuan_HUD shareInstance] HUDFullText:@"未获取到模块数据"];
            return ;
        }
        
        // 初始化 odf端子盘详情必要的参数
        [self initColumWithDict:dict isNewPort:NO];
        
        // 第一次初始化时
        if (isFirstTime) {

            // 初始化view
            [self addSubview:self.fiberScrollCollectionView];
            [self layout_ChengDuan_ScrollCollection];

        }
        
        // 选择picker 刷新时
        else {

            // 先移除 再重新加载一遍 , 避免切换数据以后的UI混乱
            [_fiberScrollCollectionView removeFromSuperview];
            _fiberScrollCollectionView = nil;


            [self addSubview:self.fiberScrollCollectionView];
            [self layout_ChengDuan_ScrollCollection];
        }
        
        // 新版光纤光路
        if (_busDevice_Enum == Yuan_BusDeviceEnum_NewFL) {
            [self NewFL_SelectTerminalState:dict];
        }
        
        // 网络请求成功的回调
        if (_httpSuccessBlock) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(1 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(),  ^{

                _httpSuccessBlock();
            });
        }
        
    }];
}



///MARK: 根据端子盘Id 设备Id 和 设备的resLogicName 查询对应的数据
- (void) http_DetailFromPieId:(NSString *) pieId
           deviceResLogicName:(NSString *) resLogicName {
    
    if (!resLogicName || !_deviceId) {
        [YuanHUD HUDFullText:@"缺少对应的id数据"];
        return;
    }
    
    
    NSDictionary * devicePostDict = @{
        
        @"GID" :_deviceId,
        @"resLogicName" : resLogicName
    };
    
    [Http.shareInstance V2_POST:HTTP_TYK_Normal_Get
                           dict:devicePostDict
                        succeed:^(id data) {
            
        
        
        NSArray * deviceDatas = data;
        if (deviceDatas.count == 0) {
            [YuanHUD HUDFullText:@"未查询到设备信息"];
            return;
        }
        
        
        NSDictionary * deviceDict = deviceDatas.firstObject;
        _deviceDict = deviceDict;
        
        // 如果存在 pieId
        if (pieId) {
            _appointPieId = pieId;
        }
        
        [self http_Port_FiberPie];
        
    }];
    
}
















#pragma mark - picker ---

- (void) configPickerData {
    
    _switchField.text = [_meunTitleArray firstObject];
    
    CGRect pickerFrame = CGRectMake(0, 0, ScreenWidth, Vertical(250));
      
      
    _picker =
        [[Yuan_SinglePicker alloc] initWithFrame:pickerFrame
                                  dataSource:_meunTitleArray
                                 PickerBlock:^(NSString * _Nonnull select) {}];
      
      
    _picker.backgroundColor = [UIColor whiteColor];
    _switchField.inputView = _picker;


    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, ScreenW, IphoneSize_Height(44))];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.clipsToBounds = YES;
    toolBar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *doneButton =  [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain  target:self action:@selector(commit)];
    doneButton.tintColor = [UIColor blueColor];

    doneButton.mainView = _switchField;

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain  target:self action:@selector(cancel)];
    cancelButton.mainView = _switchField;
    cancelButton.tintColor = [UIColor blueColor];


    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];

    _switchField.inputAccessoryView = toolBar;

    _switchField.backgroundColor = ColorValue_RGB(0xf2f2f2);
    
    
}


- (void) commit {
    
    
    [self endEditing:YES];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        NSString * key = _picker.selectRowTxt;
        
        _switchField.text =  key;
        
        
        // 获取当前滚动到了第几行
        
        NSInteger nowSelect = [_meunTitleArray indexOfObject:key];
        
        if (nowSelect == _menuSelectRow) {
            [[Yuan_HUD shareInstance] HUDFullText:@"和刚才选择的是一样的"];
            return ;
        }
        
        // 切换时 把所有的端子清空 , 等待重新给端子赋值
        [_viewModel.terminalBtnArray removeAllObjects];
        
        
        // 请求对应的端子盘信息 *** *** ***
        
        _menuSelectRow = nowSelect;
        
        NSDictionary * dict = [_device_List_DataSource objectAtIndex:_menuSelectRow];
        
        // 请求不同的端子盘信息喽
        [self httpGetPieDetailWithDict:dict isFirstTime:NO];
    
    });
    
}


- (void) cancel {
    [self endEditing:YES];
}



#pragma mark - 必要的配置 ---


#pragma mark -  初始化成端 scrollCollectionView 的必要数据  ---

- (void) initColumWithDict:(NSDictionary *) dict
                 isNewPort:(BOOL)isNewPort {
    
    // 当前选中的端子盘
    _nowShowPieDict = dict;
    
    
        
    // 获取模块行数
    _moduleRowQuantity = dict[@"moduleRowQuantity"];
    
    // 获取模块列数
    _moduleColumnQuantity = dict[@"moduleColumnQuantity"];
    
    
    /// 判断行优 还是 列优
    NSString * noRule = dict[@"noRule"];
    
    if ([noRule isEqualToString:@"1"]) {
        _importRule = Important_Line;  //行优
    }else if([noRule isEqualToString:@"2"]){
        _importRule = Important_row;   //列优
    } else{
        _importRule = Important_Line;  // 默认 行优
    }
    
    
    /// 判断方向
    NSString * noDire = dict[@"noDire"];
    
    if ([noDire isEqualToString:@"1"]) {
        //上左
        _dire = Direction_UpLeft;
    }else if ([noDire isEqualToString:@"2"]){
        //上右
        _dire = Direction_UpRight;
    }else if ([noDire isEqualToString:@"3"]){
        //下左
        _dire = Direction_DownLeft;
    }else if ([noDire isEqualToString:@"4"]){
        //下右
        _dire = Direction_DownRight;
    }else {
        // 默认 上左
        _dire = Direction_UpLeft;
    }
    
    
    
}


#pragma mark - UI ---

- (void) UI_init {
    
    
   
    
    _switchField = [UIView textFieldFrame:CGRectNull];
    [_switchField cornerRadius:3 borderWidth:1 borderColor:UIColor.lightGrayColor];
    // 居中
    _switchField.textAlignment = NSTextAlignmentCenter;
    
    
    [self addSubviews:@[_switchField]];
    
    [self yuan_LayoutSubViews];
}



- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(10);
    
    [_switchField YuanToSuper_Top:limit];
    [_switchField YuanToSuper_Right:limit];
    
    if (_EnumInitType == BusDevice_InitType_2) {
        [_switchField Yuan_EdgeSize:CGSizeMake(0, 0)];
    }
    else {
        [_switchField autoSetDimensionsToSize:CGSizeMake(Horizontal(100), Vertical(30))];
    }
}


// 成端状态下的 scrollcollectionView
- (Inc_BusODFScrollView *)fiberScrollCollectionView {
    
    
    if (!_fiberScrollCollectionView) {
        
        int line = [_moduleRowQuantity intValue];  // 行数
        int row = [_moduleColumnQuantity intValue]; //列数
        
        _fiberScrollCollectionView =
        [[Inc_BusODFScrollView alloc] initWithLineCount:line
                                                rowCount:row
                                               Important:_importRule
                                               Direction:_dire
                                              dataSource:_pieDetailArray
                                                 PieDict:_pieMsgDict
                                                      VC:_vc];
        
        
        _fiberScrollCollectionView.delegate = self;
        _fiberScrollCollectionView.scrollEnabled = YES;
        
        _fiberScrollCollectionView.backgroundColor = [UIColor whiteColor];
        _fiberScrollCollectionView.showsVerticalScrollIndicator = NO;
        _fiberScrollCollectionView.showsHorizontalScrollIndicator = NO;
        _fiberScrollCollectionView.bounces = NO;
        
        __typeof(self)weakSelf = self;
        
        _fiberScrollCollectionView.itemSelectBlock = ^(Inc_BusScrollItem * _Nonnull selectItem) {
          
            [weakSelf itemSelectBlock:selectItem];
        };
        
        
    }
    return _fiberScrollCollectionView;
    
}


- (void) layout_ChengDuan_ScrollCollection {
    
    [_fiberScrollCollectionView autoPinEdge:ALEdgeTop
                                     toEdge:ALEdgeBottom
                                     ofView:_switchField
                                 withOffset:Vertical(10)];
    
    
    [_fiberScrollCollectionView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_fiberScrollCollectionView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_fiberScrollCollectionView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:Vertical(10)];
    

}


// 当前选中的盘的名字  例如 正面一框
- (NSString *) nowSelectPieName {
    return _switchField.text;
}



- (NSArray <Inc_BusScrollItem *> * ) getBtns {
    
    return [_fiberScrollCollectionView getBtns];
}


- (NSArray <Inc_BusScrollItem *> * ) getArrangementBtn {
    
    return [_fiberScrollCollectionView getArrangementBtn];
}

// 获取所有端子GID
- (NSArray *) getAllTerminalIds {
    
    return [_fiberScrollCollectionView getAllTerminalIds];
}


/// 获取当前的端子盘(列框) 信息
- (NSDictionary *) getPieDict {
    
    
    return _nowShowPieDict;
}


#pragma mark - 业务判断 ---


- (void) NewFL_SelectTerminalState:(NSDictionary *) dict {
    
     
    NSMutableArray * allDatas = NSMutableArray.array;
    
    for (NSDictionary * singleBanK_Dict in _pieDetailArray) {
        
        NSArray * values = singleBanK_Dict.allValues;
        
        [allDatas addObject:values.firstObject];
    }
    
    
    
    NSMutableArray * allTerminalsArr = NSMutableArray.array;
    
    for (NSDictionary * dict in allDatas) {
        
        NSArray * opticTerms = dict[@"opticTerms"];
        
        if (opticTerms && opticTerms.count > 0) {
            [allTerminalsArr addObjectsFromArray:opticTerms];
        }
    }
    
    
    
    NSMutableArray * allIds_Arr = NSMutableArray.array;
    for (NSDictionary * singleDict in allTerminalsArr) {
        [allIds_Arr addObject:singleDict[@"GID"]];
    }
    
    
    
    
    [Yuan_NewFL_HttpModel Http_SelectTerminalsStateFromIds:allIds_Arr
                                                   success:^(id  _Nonnull result) {
       
            
        NSArray * arr = [self getBtns];

        
        NSMutableDictionary * mt_Dict = NSMutableDictionary.dictionary;
        
        NSArray * list = result;
        if (!list || list.count == 0) {
            return;
        }
        
        for (NSDictionary * myDict in list) {
            mt_Dict[myDict[@"termId"] ?: @""] = [NSString stringWithFormat:@"%@",myDict[@"conCount"]];
        }
        
        
        for (Inc_BusScrollItem * item in arr) {
            
            NSDictionary * item_Dict = item.dict;
            NSString * GID = item_Dict[@"GID"];
            
            // 不等于0 禁用
            if (![mt_Dict[GID] isEqualToString:@"0"]) {
                item.canSelect = NO;
                [item configColor:UIColor.greenColor];
            }
            
        }

    }];
    
}



#pragma mark - 点击事件的代理回调 ---


- (void) itemSelectBlock:(Inc_BusScrollItem *) selectItem {

    
    NSLog(@"-- terminalDict: \n %@" , selectItem.dict.json);
    
    // 因为是新数据源 需要重新查询一遍龙哥的老接口的  **** ****
    if (selectItem.isNewDict) {
        
        NSDictionary * postDict = @{@"GID" : selectItem.dict[@"GID"],
                                    @"resLogicName" : @"opticTerm"};
        
        [Http.shareInstance V2_POST:HTTP_TYK_Normal_Get
                               dict:postDict
                            succeed:^(id data) {
            
            NSArray * datas = data;
            if (datas.count == 0) {
                [YuanHUD HUDFullText:@"未查询到该端子的数据"];
                return;
            }
            
            NSMutableDictionary * mt_BlockDict = [NSMutableDictionary dictionaryWithDictionary:datas.firstObject];
            
            mt_BlockDict[@"opticTermList"] = selectItem.opticTermList ?: @[];
            mt_BlockDict[@"optLineRelationList"] = selectItem.optLineRelationList ?: @[];
            mt_BlockDict[@"optPairRouterList"] = selectItem.optPairRouterList ?: @[];
            
            if (_terminalBtnClickBlock) {
                _terminalBtnClickBlock(mt_BlockDict);
            }
            
            
            if (self.delegate != NULL &&
                [self.delegate respondsToSelector:@selector(Yuan_BusDeviceSelectItems:
                                                            nowSelectItem:
                                                            BusODFScrollView:)]) {
                // 重置一下数据源
                selectItem.dict = mt_BlockDict;
                
                [_delegate Yuan_BusDeviceSelectItems:[_fiberScrollCollectionView getBtns]
                                       nowSelectItem:selectItem
                                    BusODFScrollView:self];
            }
            
        }];
        
        
    }
    
    
    
    
    
    
    // 不需要查询接口的 , 直接进行回调 **** ****
    else {
        
        if (_terminalBtnClickBlock) {
            _terminalBtnClickBlock(selectItem.dict);
        }
        
        if (self.delegate != NULL &&
            [self.delegate respondsToSelector:@selector(Yuan_BusDeviceSelectItems:
                                                        nowSelectItem:
                                                        BusODFScrollView:)]) {
            
            [_delegate Yuan_BusDeviceSelectItems:[_fiberScrollCollectionView getBtns]
                                   nowSelectItem:selectItem
                                BusODFScrollView:self];
        }
        
    }
    
}



#pragma mark - 端子长按通知 ---

- (void) terminalLongPress:(NSNotification *) noti {
    
    // 现在只支持 设备端子和分光端口绑定模块才支持 长按
    if (_busDevice_Enum != Yuan_BusDeviceEnum_OBD_Bind) {
        return;
    }
    
    NSDictionary * btnDict = noti.userInfo;
    
    if (_terminalLongPressBlock) {
        _terminalLongPressBlock(btnDict);
    }
}


#pragma mark - 2021.6.17 新增 ---


/// 控制传入的端子 高亮或取消高亮
- (void) letTerminal_Ids:(NSArray *) TerminalIdsArr isHighLight:(BOOL)isHighLight {
    
    NSArray * btns = _fiberScrollCollectionView.getBtns;
    
    for (Inc_BusScrollItem * item in btns) {
        
        NSString * gid = item.terminalId;
        
        if ([TerminalIdsArr containsObject:gid]) {
            if (isHighLight) {
                [item borderColor:ColorR_G_B(254, 124, 124)];
            }
            else {
                [item borderColor:UIColor.whiteColor];
            }
        }
    }
    
}


/// 控制传入的端子 高亮或取消高亮   目前光缆段和承载业务共同端子使用
- (void) letTerminal_IdsCableAndBear:(NSArray *) TerminalIdsArr isHighLight:(BOOL)isHighLight {
    
    NSArray * btns = _fiberScrollCollectionView.getBtns;
    
    for (Inc_BusScrollItem * item in btns) {
        
        NSString * gid = item.terminalId;
        
        if ([TerminalIdsArr containsObject:gid]) {
            if (isHighLight) {
                [item borderColor:ColorR_G_B(156, 191, 151)];
            }
            else {
                [item borderColor:UIColor.whiteColor];
            }
        }
    }
    
}

// 根据传入的端子id , 让该端子移动到用户可视区域.
- (void) show_theTerminal_inBusDevice:(NSString *) terminalId {
    
    if (![_fiberScrollCollectionView.getAllTerminalIds containsObject:terminalId]) {
        
        [YuanHUD HUDFullText:@"未检测到传入的端子"];
        return;
    }
    
    
    
}

@end
