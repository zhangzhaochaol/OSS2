//
//  Inc_CFConfigController.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CFConfigController.h"

#import "Inc_CFListCollection.h"                   //上部分 端子的collectionView
#import "Inc_CFConfigFiber_ScrollCollectView.h"    // 下部 如果是成端入口进入 显示
#import "Inc_CFConfigCableCollectionView.h"        // 下部 如果是熔接入口进入 显示


#import "Yuan_ODF_HttpModel.h"      // 专门做网络请求的类   端子盘那块
#import "Yuan_CF_HttpModel.h"       // Http 请求         纤芯光缆段这块
#import "Yuan_CFConfigVM.h"         // viewModel

#import "Inc_CFConfigSwitchController.h"   //switch

#import "Yuan_SinglePicker.h"


@interface Inc_CFConfigController ()

<
    UIScrollViewDelegate ,       // scroll
    UIGestureRecognizerDelegate  // 禁止右滑手势
>


/** collection */
@property (nonatomic,strong) Inc_CFListCollection *collection;


/** 下部 如果是成端进入的话 显示端子 */
@property (nonatomic,strong) Inc_CFConfigFiber_ScrollCollectView *fiberScrollCollectionView;


/** 下部 如果是熔接进入的话 显示纤芯 */
@property (nonatomic,strong) Inc_CFConfigCableCollectionView *cableCollectionView;

// *** *** *** switchview 

/** blockView */
@property (nonatomic,strong) UIView *blockView;

/** 请选择 xxx */
@property (nonatomic,strong) UILabel *deviceName;

/** 选择按钮 */
@property (nonatomic,strong) UITextField * switchField;


@end

@implementation Inc_CFConfigController

{
    CF_HeaderCellType_ _type;
    
    
    // 上方 collection 的数据源 从上个页面传过来的
    NSMutableArray * _collectionDataSource;
    
    
    Yuan_CFConfigVM * _viewModel;
    
    Yuan_SinglePicker * _picker;
    
    
//  *** ***  成端所需要的成员变量 *** ***
    
    NSInteger _menuSelectRow;
    
    NSMutableArray * _pieDetailArray;  // 每个框对应的详细信息的array @{postion : array}结构
    
    NSDictionary * _pieMsgDict;
    
    NSMutableArray * _ODF_List_DataSource;   // 成端专用 数据源  来自网络请求
    
    NSMutableArray * _meunTitleArray;  // 来自 _ODF_List_DataSource
    
    NSString * _moduleRowQuantity;  // 模块行数
    
    NSString * _moduleColumnQuantity; //模块列数
    
    Important_ _importRule;   //行优 还是 列优  枚举值
    
    Direction_ _dire;  // 上左 上右 下左 下右
    
// *** *** *** *** *** *** *** *** *** *** *** ***
    
    
    
    /// 请求列表的数组  为光缆段请求列表 熔接 **   里面的数据应该和模板里的map是一样的 , 只不过是若干个
    /// 光缆段而已
    NSMutableArray * _list_http_Array;
    
    NSMutableArray * _connect_LazyLoad_DataSource; // 熔接专用 数据源 用于懒加载 来自网络请求
    
    
    
    
}


#pragma mark - 初始化构造方法

- (instancetype) initWithType:(CF_HeaderCellType_)type
                   dataSource:(NSMutableArray *)collectionDataSource{
    
    if (self = [super init]) {
        
        
        
        _viewModel = [Yuan_CFConfigVM shareInstance];
        
        
        
        _viewModel.configVC_type = type;
        
        _menuSelectRow = 0;
        
        // 熔接 -- 光缆段的懒加载数组 来自网络请求
        _connect_LazyLoad_DataSource = [NSMutableArray array];
        
        // 初始化ODF列表的数据源
        _ODF_List_DataSource = [NSMutableArray array];
        
        
        if (collectionDataSource) {
            _collectionDataSource = collectionDataSource;
        }else {
            _collectionDataSource = [NSMutableArray array];
        }
        
        // 成端还是熔接
        _type = type;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"纤芯配置";
    
    [self.view addSubview:self.collection];
    [self layoutCollectionView];
    [self navSet]; //导航栏配置
    
    // 初始化 collection 的数据源
    [_collection dataSource:_collectionDataSource];
    
    // 配置长按循环次数 , 默认为 _collectionDataSource.count
    _viewModel.for_Circle_Count = _collectionDataSource.count;
    
    // 创建中间部分的搜索框
    [self configSearchBar_UI];
    
    // 成端状态下 的操作
    if (_type == CF_HeaderCellType_ChengDuan) {
        [self http_Port_ODF];
        
    }else {
        // 当熔接状态 _switchField 选择按钮隐藏掉
        _switchField.hidden = YES;
        // 设备名称也隐藏掉 , 等选择后把名字赋值上去
        _deviceName.text = @"请选择光缆段";
        
        
        [self http_port_Connect];
    }
    
    
}


- (void) configSearchBar_UI {
    
    _blockView = [UIView viewWithColor:Color_V2Red];
    
    _deviceName = [UIView labelWithTitle:_deviceName_txt frame:CGRectNull];
    
    _deviceName.numberOfLines = 0;//根据最大行数需求来设置
    _deviceName.lineBreakMode = NSLineBreakByTruncatingTail;
    _deviceName.font = Font_Yuan(13);
    
    
    [self.view addSubviews:@[self.switchField,_blockView,_deviceName]];
    [self layoutswitchField];
    
}




#pragma mark -  http Port   ---



#pragma mark -  当成端时 , 请求ODF端子盘信息的接口  ---

- (void) http_Port_ODF {
    
    NSString * initType = @"";
    
//    cableEnd_Type  cableStart_Type
    /*
        ODF : 1
        OCC : 2
        ODB : 3
     */
    
    if (_viewModel.startOrEnd == CF_VC_StartOrEndType_Start) {
        initType = _viewModel.moBan_Dict[@"cableStart_Type"] ?: @"";
    }else {
        initType = _viewModel.moBan_Dict[@"cableEnd_Type"] ?: @"";
    }
    
    
    if (initType.integerValue > 4) {
        [[Yuan_HUD shareInstance] HUDFullText:@"当前设备暂无资源"];
        return;
    }
    
    
    // inittype == 1 传1 ODF
    if ([initType isEqualToString:@"3"]) {  //OCC 传2
        initType = @"2";
    }
    
    else if ([initType isEqualToString:@"4"]) {  //ODB 传3
        initType = @"3";
    }
    
    else {
        initType = @"1";
    }
    
    
    // 首先 要请求 所有端子盘的列表
    
    [Yuan_ODF_HttpModel ODF_HttpGetLimitDataWithID:_deviceId ?: @""
                                          InitType:initType
                                      successBlock:^(id  _Nonnull requestData) {
        
        
        // 一共有多少个端子盘 ?
        _ODF_List_DataSource = [requestData mutableCopy];
        
        if (_ODF_List_DataSource.count == 0 || !_ODF_List_DataSource) {
            [[Yuan_HUD shareInstance] HUDFullText:@"暂无ODF端子盘"];
            return ;
        }
        
        else {
            
            // 更新下拉框内容
            
            // 默认请求列表的第一个数据
            _meunTitleArray = [NSMutableArray array];
            
            for (NSDictionary * dict in _ODF_List_DataSource) {
                
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
                
            }
            
        
            // 配置单选的数据源
            [self configPickerData];
            
            // 发起默认第一个请求
            [self httpGetPieDetailWithDict:[_ODF_List_DataSource firstObject]
                               isFirstTime:YES];
            
        }
        
    }];
    
}


// 需要根据不同的dict(端子盘) 请求不同的端子盘详情 并刷新界面
- (void) httpGetPieDetailWithDict:(NSDictionary *) dict
                      isFirstTime:(BOOL)isFirstTime{
    
    
    
    _pieDetailArray = NSMutableArray.array;  //每次进这个请求都初始化一次这个数组
    
    [Yuan_ODF_HttpModel ODF_HttpDetail_Dict:dict
                               successBlock:^(id  _Nonnull requestData) {
        NSLog(@"requestData:%@",requestData);
        
        NSDictionary * req = requestData;
        
        NSArray * data = req[@"modules"];   // 所有模块的数组
        
        for (NSDictionary * dict in data) {
            [_pieDetailArray addObject:@{dict[@"position"]:dict}];
            
            if ([dict[@"position"] isEqualToString:@"12"]) {
                NSLog(@"----aaaa %@",dict);
            }
        }

        
        
        
        if (_pieDetailArray.count == 0) {
            [[Yuan_HUD shareInstance] HUDFullText:@"未获取到模块数据"];
            return ;
        }
        
        // 初始化 odf端子盘详情必要的参数
        [self initColumWithDict:dict];
        
        if (isFirstTime) {
            
            
            [_switchField setText:[_meunTitleArray firstObject]];
            
            // 初始化view
            [self.view addSubview:self.fiberScrollCollectionView];
            [self layout_ChengDuan_ScrollCollection];
            
            // 给viewModel的 懒加载数据 增加该数据源 key: 正面-1框  value : 数组
            [_viewModel.ODF_LazyLoad_DataSource addObject:@{[_meunTitleArray firstObject] : _pieDetailArray}];
            
            
        }else {
            
            // 先移除 再重新加载一遍 , 避免切换数据以后的UI混乱
            [_fiberScrollCollectionView removeFromSuperview];
            _fiberScrollCollectionView = nil;
            
            
            [self.view addSubview:self.fiberScrollCollectionView];
            [self layout_ChengDuan_ScrollCollection];
            
            
            // 给viewModel的 懒加载数据 增加该数据源 key: 正面-1框  value : 数组
            [_viewModel.ODF_LazyLoad_DataSource addObject:@{[_meunTitleArray objectAtIndex:_menuSelectRow] : _pieDetailArray}];
        }
        
        
        
        
        
    }];
    
}



#pragma mark -  当熔接时 , 请求光缆接头 对应的光缆段列表时  !!! 列表   ---

// 做一个判断 , 如果 _list_http_Array 里有和当前模板光缆段Id 是一样的map , 给移除掉
// 接头是不可以同时循环连接同一个光缆段的

- (void) http_port_Connect {
    
    
    NSDictionary * dict = _viewModel.moBan_Dict;
    
    NSString * start_type = @"";
    NSString * start_id = @"";
    
    if (_viewModel.startOrEnd == CF_VC_StartOrEndType_Start) {
        start_type = dict[@"cableStart_Type"];
        start_id = dict[@"cableStart_Id"];
    }
    if (_viewModel.startOrEnd == CF_VC_StartOrEndType_End) {
        start_type = dict[@"cableEnd_Type"];
        start_id = dict[@"cableEnd_Id"];
    }
    
    
    
    [Yuan_CF_HttpModel HttpCableStart_Type:start_type ?: @""
                                  Start_Id:start_id ?: @""
                                   success:^(NSArray * _Nonnull data) {
        
        
        NSMutableArray * requestArr = [data mutableCopy];
        // 当前光缆段的ID
        NSString * mobanDict_GID = _viewModel.moBan_Dict[@"GID"];
        
        [requestArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            NSDictionary * singleDict_Cable = obj;
            
            NSString * singleDict_GID = singleDict_Cable[@"GID"] ?: @"";
            
            if ([mobanDict_GID isEqualToString:singleDict_GID]) {
                // 证明他俩重复了 , 要移除掉
                [requestArr removeObject:obj];
            }
            
        }];
        
        
        
        _list_http_Array = [requestArr mutableCopy];
        
        // 只有有数据返回 , 才去创建UI 并且让用户选择资源
        if (_list_http_Array && _list_http_Array.count > 0) {
            [self create_RongJieUI];
        }else {
            
            [[Yuan_HUD shareInstance] HUDFullText:@"该设备暂无对应的光缆段资源"];
        }
    }];
}


#pragma mark -   去查询光缆段 这个事件应该在 http_port_Connect 回调成功后 触发 (熔接 !!) ---

- (void) switch_RongJie_CableList_Click {
    
    Inc_CFConfigSwitchController * switchVc = [[Inc_CFConfigSwitchController alloc] initWithDataSource:_list_http_Array block:^(id  _Nonnull cableDict){
        
        // 选中了 某个名称的回调
        
        if (!cableDict) {

            [[Yuan_HUD shareInstance] HUDFullText:@"请求对应光缆段资源失败 , 为获取到数据"];
            return ;
        }
        
        
        if ([cableDict isEqual:[NSString string]]) {
            // 空字符串时  默认他是点击了返回按钮  返回到上一界面
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        
        // ***  拿到已经经过懒加载处理过的 dict : @{cableId : Array}
        
        // 刷新数据源
        
        NSDictionary * dataDict = cableDict;
        
        /*
            GID : @[@{},@{}]; 的结果
            取出Gid 并赋值
         */
        
        
        NSArray * cableCollectionDataSource = dataDict.allValues.firstObject;
        
        // 让下部熔接collection 刷新数据源
        [_cableCollectionView dataSource:[cableCollectionDataSource mutableCopy]];
        
    }];
    
    
    // 点击完之后 修改对应的光缆段名称
    switchVc.cableName_Block = ^(NSString * _Nonnull name) {
        _deviceName.text = name;
    };
    
    
    /// ***** switchVc Config *** *** ***  不用改
    
    switchVc.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    self.definesPresentationContext = YES;
    switchVc.modalPresentationStyle = UIModalPresentationPopover;
    switchVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    switchVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;//关键语句，必须有 ios8 later
    // 动画关闭 不然会有个半透明背景跟着动画 很丑..
    [self presentViewController:switchVc animated:NO completion:^{
    // 根据 colorWithAlphaComponent:设置透明度，如果直接使用alpha属性设置，会出现Vc里面的子视图也透明.
       switchVc.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }];
        
}




- (void) create_RongJieUI {
    
    _cableCollectionView = [[Inc_CFConfigCableCollectionView alloc] init];
    [self.view addSubview:_cableCollectionView];
    [self layout_RongJie_Collection];
    
    
    // 让用户选择下属光缆段资源
    [self switch_RongJie_CableList_Click];
    
}



#pragma mark -  初始化成端 scrollCollectionView 的必要数据  ---

- (void) initColumWithDict:(NSDictionary *) dict {
    
    
    
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













#pragma mark -  UI  ---
// 上方collection
- (Inc_CFListCollection *)collection {
    
    if (!_collection) {
        
        _collection = [[Inc_CFListCollection alloc] initWithEnter:CF_EnterType_Config];
        _collection.backgroundColor = UIColor.yellowColor;
    }
    return _collection;
}



// 成端状态下的 scrollcollectionView
- (Inc_CFConfigFiber_ScrollCollectView *)fiberScrollCollectionView {
    
    
    if (!_fiberScrollCollectionView) {
        
        int line = [_moduleRowQuantity intValue];  // 行数
        int row = [_moduleColumnQuantity intValue]; //列数
        
        _fiberScrollCollectionView =
        [[Inc_CFConfigFiber_ScrollCollectView alloc] initWithLineCount:line
                                                               rowCount:row
                                                              Important:_importRule
                                                              Direction:_dire
                                                             dataSource:_pieDetailArray
                                                                PieDict:_pieMsgDict
                                                                     VC:self];
        
        
        _fiberScrollCollectionView.delegate = self;
        _fiberScrollCollectionView.scrollEnabled = YES;
        
        _fiberScrollCollectionView.backgroundColor = [UIColor whiteColor];
        _fiberScrollCollectionView.showsVerticalScrollIndicator = NO;
        _fiberScrollCollectionView.showsHorizontalScrollIndicator = NO;
        _fiberScrollCollectionView.bounces = NO;
        
    }
    return _fiberScrollCollectionView;
    
}


- (UITextField *)switchField{
    
    if (!_switchField) {
        
        _switchField = [[UITextField alloc] initWithFrame:CGRectNull];
        
        
        _switchField.layer.cornerRadius = 3;
        _switchField.layer.masksToBounds = YES;
        _switchField.layer.borderColor = [ColorValue_RGB(0xf2f2f2) CGColor];
        _switchField.layer.borderWidth = 1;
        
        _switchField.placeholder = @"请选择";
        
        _switchField.font = [UIFont systemFontOfSize:12];
        _switchField.textAlignment = NSTextAlignmentCenter;
        
        UILabel *paddingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 25)];

        paddingView.text = @"  ";

        paddingView.textColor = [UIColor darkGrayColor];

        paddingView.backgroundColor = [UIColor clearColor];

        _switchField.leftView = paddingView;

        _switchField.leftViewMode = UITextFieldViewModeAlways;
        
    }
    return _switchField;
}

#pragma mark -  关于 ODF 下拉框 数据与事件的配置  ---

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
    
    
    [self.view endEditing:YES];
    
    
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
        
        
        _menuSelectRow = nowSelect;
        
        NSDictionary * dict = [_ODF_List_DataSource objectAtIndex:_menuSelectRow];
        
        NSLog(@"%@",dict);
        
        bool isAlreadyGetHttp = NO;
        
        // 遍历懒加载数组 , 看当前的 ODF 端子盘之前是否已经请求过了?
        
        for (NSDictionary * dictionary in _viewModel.ODF_LazyLoad_DataSource) {
            if ([dictionary.allKeys.firstObject isEqualToString:key]) {
                
                
                // 证明这个已经请求过了  直接拿缓存取刷新数据源就可以了
                isAlreadyGetHttp = YES;
                _pieDetailArray = dictionary.allValues.firstObject;
                
                // 初始化 odf端子盘详情必要的参数 重新加载UI
                [self initColumWithDict:dict];
                
                [_fiberScrollCollectionView removeFromSuperview];
                _fiberScrollCollectionView = nil;
                
                
                [self.view addSubview:self.fiberScrollCollectionView];
                [self layout_ChengDuan_ScrollCollection];
                

                
                break;
            }
        }
        
        // 未请求过的 才去再次请求
        if (!isAlreadyGetHttp) {
            // 请求不同的端子盘信息喽
            [self httpGetPieDetailWithDict:dict isFirstTime:NO];
        }
        
        
        
    });
    
}


- (void) cancel {
    [self.view endEditing:YES];
}


#pragma mark - 屏幕适配

- (void)layoutCollectionView {
 
    [_collection autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:NaviBarHeight + Vertical(5)];
    [_collection autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(5)];
    [_collection autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(5)];
    
    
    
    
    float limit = Horizontal(13);        // 间距
    float sideLength = Horizontal(40);   // 边距
    float height ;
    NSInteger count = _collectionDataSource.count;
    NSInteger rows = 0;
    // 当 count >= 42个 的时候 , 恒定高度
    if (count >= 42) {
        // 每行7个item  共6行
        rows = 6;
        height = limit * (rows + 1) + sideLength * rows;
        
    }else {
        // 如果小于 42个的时候
        if (_collectionDataSource.count % 7 == 0) {
            // 当能被7 整除没有余数的时候
            rows = count / 7;
        }else {
            // 不能被7整除 有余数的时候  还要多出一行 显示多出来的个数
            rows = (count / 7) + 1;
        }
        height = limit * (rows + 1) + sideLength * rows;
    }
    
    [_collection autoSetDimension:ALDimensionHeight toSize:height];
    
}


- (void) layout_ChengDuan_ScrollCollection {
    
    [_fiberScrollCollectionView autoPinEdge:ALEdgeTop
                                     toEdge:ALEdgeBottom
                                     ofView:_blockView
                                 withOffset:Vertical(30)];
    
    
    [_fiberScrollCollectionView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(5)];
    [_fiberScrollCollectionView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(5)];
    [_fiberScrollCollectionView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
}


- (void) layout_RongJie_Collection {
    
    [_cableCollectionView autoPinEdge:ALEdgeTop
                               toEdge:ALEdgeBottom
                               ofView:_blockView
                           withOffset:Vertical(30)];
    
    [_cableCollectionView autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                           withInset:Horizontal(5)];
    
    [_cableCollectionView autoPinEdgeToSuperviewEdge:ALEdgeRight
                                           withInset:Horizontal(5)];
    
    [_cableCollectionView autoPinEdgeToSuperviewEdge:ALEdgeBottom
                                           withInset:0];
    
}



- (void) layoutswitchField {
    
    float limit = Horizontal(15);
    
    // 方块
    [_blockView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(5)];
    [_blockView autoPinEdge:ALEdgeTop
                     toEdge:ALEdgeBottom
                     ofView:_collection
                 withOffset:limit];
    
    [_blockView autoSetDimensionsToSize:CGSizeMake(Horizontal(5), limit)];
    
    // 请选择
    [_deviceName autoConstrainAttribute:ALAttributeHorizontal
                            toAttribute:ALAttributeHorizontal
                                 ofView:_blockView
                         withMultiplier:1.0];
    
    [_deviceName autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_blockView withOffset:5];
    [_deviceName autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(90)];
    
    
    [_switchField autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_switchField autoConstrainAttribute:ALAttributeHorizontal
                      toAttribute:ALAttributeHorizontal
                           ofView:_blockView
                   withMultiplier:1.0];
    
    [_switchField autoSetDimensionsToSize:CGSizeMake(Horizontal(85), Vertical(25))];
    
}




#pragma mark -  save click 保存  ---

- (void) navSet {
    
    UIBarButtonItem * save = [UIView getBarButtonItemWithTitleStr:@"保存" Sel:@selector(saveClick) VC:self];
    
    
    self.navigationItem.rightBarButtonItems = @[save];
    
}


- (void) saveClick {
    
    
    if (_viewModel.linkSaveHttpArray.count == 0) {
        [[Yuan_HUD shareInstance] HUDFullText:@"您并没有做任何关联操作"];
        return;
    }
    
    NSMutableArray * new_Arr = NSMutableArray.array;
    
    for (NSDictionary * postDict in _viewModel.linkSaveHttpArray) {
        
        NSString * fiberId = postDict[@"GID"];
        
        NSArray * optConjunctions = postDict[@"optConjunctions"];
        
        for (NSDictionary * opt_Dict in optConjunctions) {
            if ([opt_Dict[@"resA_Id"] isEqualToString:fiberId]) {
                [new_Arr addObject:opt_Dict[@"resB_Id"]];
            }
            
            if ([opt_Dict[@"resB_Id"] isEqualToString:fiberId]) {
                [new_Arr addObject:opt_Dict[@"resA_Id"]];
            }
        }
    }
    
    BOOL isBindAnother = NO;
    
    for (NSString * Id in new_Arr) {
        // 证明有绑定过
        if ([_viewModel.AnotherCableConfigTermIds_Arr containsObject:Id]) {
            isBindAnother = YES;
            break;
        }
        
    }
    
    
    NSString * msg = @"当前关联关系中含有被其他纤芯关联的端子，保存后将会覆盖关联关系，确认保存吗？";
    
    // 如果存在过其他光缆段内绑定的关系 , 请先确认
    if (isBindAnother) {
        
        
        [UIAlert alertSmallTitle:msg
                   agreeBtnBlock:^(UIAlertAction *action) {
            
            __typeof(self)wself = self;
            [Yuan_CF_HttpModel HttpCableFiberSaveSuccess:^(NSArray * _Nonnull data) {
                    
                [wself.navigationController popViewControllerAnimated:YES];
                [_viewModel.linkSaveHttpArray removeAllObjects];
                
                // 通知 我已经保存成功了 , 请重新加载一遍数据源吧回调吧
                [_viewModel viewModel_NotiListControllerReloadHttp];
            }];
        }];
        
    }
    
    
    
    // 如果没有 那么 直接保存就可以了
    else {
        
        __typeof(self)wself = self;
        [Yuan_CF_HttpModel HttpCableFiberSaveSuccess:^(NSArray * _Nonnull data) {
                
            [wself.navigationController popViewControllerAnimated:YES];
            [_viewModel.linkSaveHttpArray removeAllObjects];
            
            // 通知 我已经保存成功了 , 请重新加载一遍数据源吧回调吧
            [_viewModel viewModel_NotiListControllerReloadHttp];
        }];
        
    }
    
    
    
    
}





- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    // 当退出控制器时 清空保存数组
    [_viewModel.linkSaveHttpArray removeAllObjects];
    
    
    // 退出控制器时 , 清空UI数组
    [_viewModel.terminalBtnArray removeAllObjects];
    [_viewModel.connectionItemArray removeAllObjects];
    
    // 退出控制器时 , 把记录长按手动配置的状态清为None
    _viewModel.handleConfig_State = CF_ConfigHandle_None;
    
}

@end
