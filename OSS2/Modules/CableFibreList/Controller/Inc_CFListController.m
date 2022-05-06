//
//  Inc_CFListController.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//  

#import "Inc_CFListController.h"

#import "Inc_CFListHeader.h"       //头部视图
#import "Inc_CFListTableView.h"    //tableView
#import "Inc_CFListCollection.h"   //collectionView


#import "Yuan_CF_HttpModel.h"       // 网络请求 工具类

#import "Yuan_CFConfigVM.h"         // viewModel

#import "Yuan_CFConfigModel.h"      // 逻辑处理Model

// *** 用于模板跳转
#import "TYKDeviceInfoMationViewController.h"
#import "IWPPropertiesReader.h"

//zzc 2021-6-17
#import "MLMenuView.h"               // 下拉列表

#import "Inc_NewFL_HttpModel1.h"
#import "Inc_AlltermCell.h"
#import "Inc_headCell.h"
#import "Inc_Push_MB.h"


//点击单条光路显示
#import "Inc_CFListLightVC.h"

// 新模板跳转
#import "Inc_NewMB_Presenter.h"
#import "Inc_NewMB_DetailVC.h"


//纤芯编号变更
#import "Inc_PairNoChangeTipView.h"
#import "Inc_NewMB_HttpModel.h"


typedef NS_ENUM(NSUInteger, CFList_) {
    CFList_TableView,           //显示tableView
    CFList_CollectionView       //显示collectionView
};



@interface Inc_CFListController ()<MLMenuViewDelegate,UITableViewDelegate,UITableViewDataSource>



/** 初始化按钮 */
@property (nonatomic,strong) UIButton *InitBtn;

/** 头部视图 */
@property (nonatomic,strong) Inc_CFListHeader *headerView;

/** tableView */
@property (nonatomic,strong) Inc_CFListTableView *tableView;

/** collection */
@property (nonatomic,strong) Inc_CFListCollection *collection;

/** 警告 : ⚠️  */
@property (nonatomic,strong) UILabel *warningImg;

/** 警告 : ⚠️ 2020年11月9日 新增 缺少当前光缆段纤芯内 有端子缺少SuperResId */
@property (nonatomic,strong) UIImageView *warningImg_SuperResId;

/** 新增 重新初始化纤芯的按钮 */
@property (nonatomic , strong) UIButton * reInit_FibersBtn;


//zzc 2021-6-17
/**
 弹出菜单
 */
@property (nonatomic, strong) MLMenuView * menu;

/** tableView */
@property (nonatomic,strong) UITableView *lightTableView;
/** tableView */
@property (nonatomic,strong) NSMutableArray *dataArray;


//纤芯编号变更
@property (nonatomic, strong) Inc_PairNoChangeTipView *pairNoChangeView;


@end

@implementation Inc_CFListController

{
    
    NSString * _cableId;  //光缆段 ID
    
    // 枚举模式
    CFList_ _nowMode;
    
    // 导航栏 按钮
    UIButton * _mode_ChangeBtn;
    
    NSMutableArray * _httpDataSource;
    
    Yuan_CFConfigVM * _viewModel;
    
    
    // *** 2020年11月9日新增  给缺少superResId的成端纤芯 添加黄色边框
    NSMutableArray * _NoSuperResIdArray;
    
    
    
    // *** 用于模板跳转
    IWPPropertiesReader * _reader;
    IWPPropertiesSourceModel * _model;
    NSArray <IWPViewModel *>* _viewModel_muban;
    
    
    //zzc 2021-6-17
    //黑色透明背景view
    UIView *_windowBgView;
    
    //选中的dic
    NSDictionary *_selectDic;
    
    Inc_NewMB_HttpPort * _httpPortModel;

}



#pragma mark - 初始化构造方法
// 150007010000001467294917
- (instancetype) initWithCableId:(NSString *)cableId {
    
    if (self = [super init]) {
        _cableId = cableId;
        
        _httpDataSource = [NSMutableArray array];
        _NoSuperResIdArray = NSMutableArray.array;
        
        _viewModel = [Yuan_CFConfigVM shareInstance];
        
        // 当保存成功后 重新请求 httpList
        __typeof(self)wself = self;
        _viewModel.viewModel_Block_ReloadHttp = ^{
            [wself http_List];
        };
    }
    return self;
}



#pragma mark -  viewDidLoad  ---

- (void)viewWillAppear:(BOOL)animated {
    // 一进来就做一个网络请求  , 去查询下属纤芯的个数 如果是0 要去进行初始化
    [self http_List];
    
    // 设置导航栏
    [self navSet];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"光缆纤芯列表";
    
    // 默认当前是 列表
    _nowMode = CFList_TableView;

    _httpPortModel = [Inc_NewMB_HttpPort ModelEnum:Yuan_NewMB_ModelEnum_optPair];

    
    // 把模板传过来的map  传给 viewModel , 因为大家都要使用它
    _viewModel.moBan_Dict = _moban_Dict;
    

    
    //zzc 2021-6-17
 
    //window 黑色
    [self setWindowBgView];
    
    _windowBgView.hidden = YES;
    _tableView.hidden = YES;
    _pairNoChangeView.hidden = YES;
    
    _dataArray = [NSMutableArray array];

}


#pragma mark -  Http 请求  ---


- (void) http_List {
    
    [Yuan_CF_HttpModel Http_CableFilberListRequestWithCableId:_cableId
                                                      Success:^(NSArray * _Nonnull data) {
        
        NSArray * dataArr = data;
        
        
        if (dataArr.count == 0) {
            
            // 为0 需要初始化
            [self UI_Load:true];
        }else {
            
            
            [_viewModel.allStartDeviceArray removeAllObjects];
            [_viewModel.allEndDeviceArray removeAllObjects];
            [_viewModel.allXianXinArray removeAllObjects];
            
            _httpDataSource = [NSMutableArray array];
            
            for (NSDictionary * dict in dataArr) {
                
                // 王大为的接口 无法返回 resLogicName 需要手动拼接
                NSMutableDictionary * dicttt = [NSMutableDictionary dictionaryWithDictionary:dict];
                
                dicttt[@"resLogicName"] = @"optPair";
                dicttt[@"GID"] = dict[@"pairId"];
                [_httpDataSource addObject:dicttt];
            }
            
            // 给viewModel 保存数据  保存王大为接口数据
            _viewModel.WDW_Port_Array = [_httpDataSource copy];
            // 给viewModel 拆分数据
            [_viewModel clearUpToArrays:_httpDataSource];
            [self UI_Load:false];
            
            
            // 新增 *** 获取当前光缆段内 全部的纤芯Id  *** 2020-11-03
            
            NSMutableArray * fiberIds_Arr = NSMutableArray.array;
            
            for (NSDictionary * dict_t in _httpDataSource) {
                NSString * GID = dict_t[@"GID"];
                [fiberIds_Arr addObject:GID];
            }
            
            _viewModel.fiberIds_Arr = fiberIds_Arr;
            
        }
        
    }];
    
}


//重置按钮点击
- (void) http_ResetFiber:(CFHeaderReset_) resetEnum {

    //重置资源需要的参数list
    NSMutableArray *postArr = [NSMutableArray array];

    //遍历纤芯列表
    for (NSDictionary *dict in _httpDataSource) {

        //需要参数字典
        NSMutableDictionary *postDic = [NSMutableDictionary dictionary];

        //起始设备id 用于和superResId（设备id）或者tieInId（接头）比对
        NSString * beginId = dict[@"beginId"];
        //终止设备id 用于和superResId（设备id）或者tieInId（接头）比对
        NSString * endId = dict[@"endId"];

        //纤芯id
        NSString * pairId = dict[@"pairId"];

        //成端熔接关系列表
        NSArray *connectList = dict[@"connectList"];

        if (connectList.count == 0) {
            continue;
        }

        for (NSDictionary *dic in connectList) {

            //起始设备重置
            if (resetEnum == CFHeaderReset_Start) {
                //设备id（superResId）、接头id（tieInId）等于起始设施id
                if ([beginId isEqualToString:dic[@"superResId"]] || [beginId isEqualToString:dic[@"tieInId"]]) {

                    //取和当前纤芯id不相等的资源Id、资源type 放入字典中
                    if ([pairId isEqualToString:dic[@"resAId"]]) {

                        [postDic setValue:pairId forKey:@"resId"];
                        [postDic setValue:dic[@"resBTypeId"] forKey:@"conjunctionResTypeId"];
                        [postDic setValue:dic[@"resBId"] forKey:@"conjunctionResId"];
                    }else{
                        [postDic setValue:pairId forKey:@"resId"];
                        [postDic setValue:dic[@"resATypeId"] forKey:@"conjunctionResTypeId"];
                        [postDic setValue:dic[@"resAId"] forKey:@"conjunctionResId"];
                    }

                    [postArr addObject:postDic];

                }
            }
            //终止设备重置
            else{
                if ([endId isEqualToString:dic[@"superResId"]] || [endId isEqualToString:dic[@"tieInId"]]) {

                    if ([pairId isEqualToString:dic[@"resAId"]]) {

                        [postDic setValue:pairId forKey:@"resId"];
                        [postDic setValue:dic[@"resBTypeId"] forKey:@"conjunctionResTypeId"];
                        [postDic setValue:dic[@"resBId"] forKey:@"conjunctionResId"];
                    }else{
                        [postDic setValue:pairId forKey:@"resId"];
                        [postDic setValue:dic[@"resATypeId"] forKey:@"conjunctionResTypeId"];
                        [postDic setValue:dic[@"resAId"] forKey:@"conjunctionResId"];
                    }

                    [postArr addObject:postDic];

                }
            }


        }
    }

    [Yuan_CF_HttpModel HttpBatchDeleteReleationShips:postArr
                                             success:^(id result) {
        [self http_List];

    }];

}


#pragma mark -  method  ---

/// 初始化纤芯的点击事件
- (void) InitFiberClick {
    
    if (!_moban_Dict) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"数据源获取失败"];
        return;
    }
    
    
    NSString * capacity = _moban_Dict[@"capacity"];
    
    // 不是数字 或者 为空
    if (!capacity ||
        ![Yuan_Foundation isNumber:capacity] ||
        [capacity isEqual:[NSNull null]]) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"光缆段内纤芯数量不正确"];
        
        // 把警告显示出来
        _warningImg.hidden = NO;
        return;
    }
    
    
    // 大于1000 或者 小于1 都要给警告提示
    if ([capacity integerValue] < 1 || [capacity integerValue] > 1000) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"光缆段内纤芯数量不正确"];
        
        _warningImg.hidden = NO;
        return;
    }
    
    
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    /*
     
     cableSeg_Id 所属光缆段ID
     cableSeg 所属光缆段名称
     capacity 纤芯总数
     */
    
    
//    //原龙哥初始化接口入参
//    dict[@"cableSeg_Id"] = [_moban_Dict objectForKey:@"GID"];
//    dict[@"cableSeg"] = [_moban_Dict objectForKey:@"cableName"];
//    dict[@"capacity"] = [_moban_Dict objectForKey:@"capacity"];
//    dict[@"resLogicName"] = @"optPair";
    
    
    //新的重新初始化接口入参
        
    dict[@"capacity"] = _moban_Dict[@"capacity"];
    dict[@"resId"] = _cableId;
    dict[@"reqDb"] = Yuan_WebService.webServiceGetDomainCode;

    
    
    [Yuan_CF_HttpModel HttpFiberWithDict:dict
                                 success:^(NSArray * _Nonnull data) {
       
        
        
        if (data) {
            [self http_List];
        }
        
    }];
    
}


/// 重新初始化按钮
- (void) reInitFibersClick {
    

    [UIAlert alertSmallTitle:@"是否需要在原有纤芯数据的基础上进行根据纤芯总数字段进行初始化?"
               agreeBtnBlock:^(UIAlertAction *action) {
            
        [Yuan_CF_HttpModel HttpReInit_Fibers:@{@"resId":_cableId ,
                                               @"capacity" : _moban_Dict[@"capacity"],
                                               @"reqDb" : Yuan_WebService.webServiceGetDomainCode
        }
                                     Success:^(id  _Nonnull result) {
            
            Pop(self);
        }];
        
    }];
    
}



#pragma mark -  UI ---

//光路table
- (UITableView *)lightTableView {
    if (!_lightTableView) {
        _lightTableView = [[UITableView alloc]initWithFrame:CGRectNull style:UITableViewStyleGrouped];
        _lightTableView.backgroundColor = UIColor.whiteColor;
        _lightTableView.rowHeight = 44;
        _lightTableView.delegate = self;
        _lightTableView.dataSource = self;
        _lightTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [_lightTableView setCornerRadius:10 borderColor:UIColor.clearColor borderWidth:1];
    }
    return _lightTableView;
}

//纤芯编号
- (Inc_PairNoChangeTipView *)pairNoChangeView {
    WEAK_SELF;
    if (!_pairNoChangeView) {
        _pairNoChangeView = [[Inc_PairNoChangeTipView alloc]initWithFrame:CGRectMake(Horizontal(40), 0, ScreenWidth - 2*Horizontal(40), 200)];
        _pairNoChangeView.heightBlock = ^(CGFloat height) {
            wself.pairNoChangeView.frame = CGRectMake(Horizontal(40), 0, ScreenWidth - 2*Horizontal(40), height);
            wself.pairNoChangeView.center = wself.view.center;
        };
        _pairNoChangeView.btnBlock = ^(UIButton *btn, NSArray *postArr) {
            
            if ([btn.titleLabel.text isEqualToString:@"确定"]) {
                
                if (postArr.count == 0) {
                    [YuanHUD HUDFullText:@"请先关闭键盘，完成赋值"];
                    return;
                }
                
                [wself Http_PairNoChanged:@{
                    @"resType":@"pair",
                    @"datas":postArr
                }];
             
            }else{
                [wself hiddenPairView];
                [wself.pairNoChangeView cleareData];
            }
      
        };
        
    }
    return _pairNoChangeView;
}

/// 初始化按钮
- (UIButton *)InitBtn {
    
    if (!_InitBtn) {
        _InitBtn = [UIView buttonWithTitle:@"初始化纤芯"
                                 responder:self
                                       SEL:@selector(InitFiberClick)
                                     frame:CGRectMake(0, 0, 130, 35)];
        
        _InitBtn.center = self.view.center;
        _InitBtn.backgroundColor = Color_V2Red;
        [_InitBtn setTitleColor:UIColor.whiteColor
                  forState:UIControlStateNormal];
        _InitBtn.layer.cornerRadius = 5;
        _InitBtn.layer.masksToBounds = YES;
        
        _InitBtn.titleLabel.font = Font_Yuan(14);
        
    }
    return _InitBtn;
}

/// 顶部视图
- (Inc_CFListHeader *)headerView {
    
    if (!_headerView) {
        
        __typeof(self)weakSelf = self;
        
        _headerView = [[Inc_CFListHeader alloc] initWithVC:self];
        
        
        
//        // 重置事件
        _headerView.headerResetBlock = ^(CFHeaderReset_ resetEnum) {
            
            NSString * msg = @"是否要批量删除起始设备成端熔接关系?";
            
            if (resetEnum != CFHeaderReset_Start) {
                msg = @"是否要批量删除终止设备成端熔接关系?";
            }
            
            
            [UIAlert alertSmallTitle:msg
                       agreeBtnBlock:^(UIAlertAction *action) {
                
                [weakSelf http_ResetFiber:resetEnum];
            }];
            
        };
    }
    return _headerView;
}


- (Inc_CFListTableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[Inc_CFListTableView alloc] init];
        _tableView.vc = self;
        
        __typeof(self)wself = self;
        
        // 点击事件
        _tableView.tableView_SelectCellBlock = ^(NSDictionary * _Nonnull dict) {
          
            // 跳转模板界面
            [wself push_NewMB:dict];
        };
        
        
        _tableView.PressGestureBlock = ^(int index) {
            
            if (V2_Red) {
                [wself.pairNoChangeView setDataSource:_httpDataSource index:index];
                [wself showPairView];
            }

        };
        // 删除绑定成功 刷新列表
        _tableView.tableView_DeleteSuccessBlock = ^{
            [wself http_List];
        };
        
        
    }
    return _tableView;
}


- (Inc_CFListCollection *)collection {
    
    if (!_collection) {
        
        _collection = [[Inc_CFListCollection alloc] initWithEnter:CF_EnterType_List];
        _collection.hidden = YES;
        _collection.vc = self;
        
        __typeof(self)wself = self;
        
        _collection.collection_SelectItemBlock = ^(NSDictionary * _Nonnull dict) {
            // 跳转模板界面
//            [wself muBan_Push:dict typeRef:TYKDeviceListUpdateRfid];
            [wself push_NewMB:dict];
        };
    }
    return _collection;
}



- (void) UI_Load:(BOOL)isInit {
    
    // 先给他干掉 再初始化 , 用于跳转模板后 刷新界面时使用 , 如果请求成功了 就移除界面 重新加载一次
    [self remove_UI];
    
    // 不需要初始化
    if (!isInit) {
        
        // 判断 connectList里的map 既没有tieInName 也没有ResName的时候 , 其实就是双成端顶掉了
        
        BOOL isNeedHUD = NO;
        
        for (NSDictionary * dict in _httpDataSource) {
            
            NSArray * connectList = dict[@"connectList"];
            
            if (connectList.count == 0 || !connectList) {
                continue;
            }
            
            for (NSDictionary * subDict in connectList) {
                    
                if (![subDict.allKeys containsObject:@"tieInName"] &&
                    ![subDict.allKeys containsObject:@"tieInId"] &&
                    ![subDict.allKeys containsObject:@"superResId"] &&
                    ![subDict.allKeys containsObject:@"superResName"] ) {
                    
                    // 啥都没有 ~ 给提示
                    isNeedHUD = YES;
                    
                    // 把问题纤芯的pairId 放入数组中
                    [_NoSuperResIdArray addObject:dict[@"pairId"]];
                }
            }
        }
        
        
        if (isNeedHUD) {
            
            _warningImg_SuperResId =
            [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"cf_warning_superResId"]
                               frame:CGRectNull];
            
            [self.view addSubview:_warningImg_SuperResId];
        }
        

        
        _warningImg = [UIView labelWithTitle:@"⚠️ 检测到光缆段纤芯数量与实际不符 \n   是否重新初始化?" frame:CGRectNull];
        _warningImg.backgroundColor = UIColor.yellowColor;
        
        
        // 警告 默认是隐藏的
        _warningImg.hidden = YES;
        _warningImg.font = Font_Yuan(12);
        
        
        
        _reInit_FibersBtn = [UIView buttonWithTitle:@"重新初始化"
                                          responder:self
                                                SEL:@selector(reInitFibersClick)
                                              frame:CGRectNull];
        
        _reInit_FibersBtn.backgroundColor = UIColor.mainColor;
        _reInit_FibersBtn.titleLabel.font = Font_Yuan(12);
        [_reInit_FibersBtn setTitleColor:UIColor.whiteColor
                                forState:UIControlStateNormal];
        
        [_warningImg addSubview:_reInit_FibersBtn];
        _warningImg.userInteractionEnabled = YES;
        
        
        // 判断
        
        NSString * capacity = _moban_Dict[@"capacity"];
        
        if (!capacity || [capacity isEqual:[NSNull null]]) {
            
            _warningImg.hidden = NO;
            return;
        }
        
        if (_httpDataSource.count != [capacity integerValue]) {
            // 如果 数组的个数 和 模板的 capacity 光缆段个数 不等的话 一样会显示警告
            _warningImg.hidden = NO;
        }else {
            _warningImg.hidden = YES;
        }
        
        
        [self.view addSubviews:@[_warningImg,
                                 self.headerView,
                                 self.tableView,
                                 self.collection]];
        
        [self layoutAllSubViews];
        
        // 赋值
        [_headerView dataSource:_httpDataSource];
        [_tableView dataSource:_httpDataSource];
        [_collection dataSource:_httpDataSource];
        
        
        
        // 当有纤芯成端的端子 缺少superResId的时候 执行 边框变黄色
        if (_NoSuperResIdArray.count > 0) {
            
            [_tableView noSuperResIdSource:_NoSuperResIdArray];
            [_collection noSuperResIdSource:_NoSuperResIdArray];
        }
        
        
        
        if (_InitBtn) {
            [_InitBtn removeFromSuperview];
            _InitBtn = nil;
        }
        
    }else {
        // 需要初始化
        [self.view addSubview:self.InitBtn];
    }
    
    
    
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    // 警告
    [_warningImg autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:NaviBarHeight];
    [_warningImg autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(5)];
    [_warningImg autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(5)];
    [_warningImg Yuan_EdgeHeight:Vertical(35)];
    
    [_reInit_FibersBtn YuanAttributeHorizontalToView:_warningImg];
    [_reInit_FibersBtn YuanToSuper_Right:5];
    
    
    
    // 如果存在 警告 缺少superResId
    if ([self.view.subviews containsObject:_warningImg_SuperResId]) {
        
        [_warningImg_SuperResId autoPinEdge:ALEdgeTop
                                     toEdge:ALEdgeBottom
                                     ofView:_warningImg
                                 withOffset:0];
        
        [_warningImg_SuperResId autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [_warningImg_SuperResId autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        
        [_headerView autoPinEdge:ALEdgeTop
                          toEdge:ALEdgeBottom
                          ofView:_warningImg_SuperResId
                      withOffset:0];
    }
    
    else {
        [_headerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_warningImg withOffset:0];
    }
    
    
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(5)];
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(5)];
    [_headerView autoSetDimension:ALDimensionHeight toSize:Vertical(135)];
    
    [_tableView autoPinEdge:ALEdgeTop
                     toEdge:ALEdgeBottom
                     ofView:_headerView
                 withOffset:Vertical(5)];
    
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(5)];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(5)];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
    
    [_collection autoPinEdge:ALEdgeTop
                     toEdge:ALEdgeBottom
                     ofView:_headerView
                 withOffset:Vertical(5)];
    
    [_collection autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(5)];
    [_collection autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(5)];
    [_collection autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
    
    
}

#pragma mark -  NavSet  ---

- (void) navSet {
    
    _mode_ChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_mode_ChangeBtn setBackgroundImage:[UIImage Inc_imageNamed:@"cf_jiugongge"] forState:UIControlStateNormal];
    
    [_mode_ChangeBtn addTarget:self
                        action:@selector(mode_ChangeClick)
              forControlEvents:UIControlEventTouchUpInside];
    
    
    [self rightBarButtonItems:NO];

    
}


///  顶部导航栏按钮的点击事件
- (void) mode_ChangeClick {
    
    
    if (_nowMode == CFList_TableView) {
        
        _nowMode = CFList_CollectionView;  //切换模式
        
        [_mode_ChangeBtn setBackgroundImage:[UIImage Inc_imageNamed:@"icon_pplist_gongneng"]
                                   forState:UIControlStateNormal];
        
        // 隐藏 tableview
        _tableView.hidden = YES;
        // 显示 collection
        _collection.hidden = NO;
        
        [self rightBarButtonItems:YES];

        
    }else {
        
        _nowMode = CFList_TableView;  //切换模式
        
        [_mode_ChangeBtn setBackgroundImage:[UIImage Inc_imageNamed:@"cf_jiugongge"]
                                   forState:UIControlStateNormal];
        
        // 显示 tableview
        _tableView.hidden = NO;
        // 隐藏 collection
        _collection.hidden = YES;
        
     
        [self rightBarButtonItems:NO];
        
    }
    
}

//设置rightBarButtonItems是否显示光路查看按钮
- (void)rightBarButtonItems:(BOOL)isShow {
    
    if (!isShow) {
        // 模式切换按钮
        UIBarButtonItem *modeChangeItem = [[UIBarButtonItem alloc] initWithCustomView:_mode_ChangeBtn];
        
        self.navigationItem.rightBarButtonItems = @[modeChangeItem];
    }else{
        if (v_HLJ) {
            // 模式切换按钮
            UIBarButtonItem *modeChangeItem = [[UIBarButtonItem alloc] initWithCustomView:_mode_ChangeBtn];
            
            self.navigationItem.rightBarButtonItems = @[modeChangeItem];
        }else{
            
            UIBarButtonItem *modeChangeItem = [[UIBarButtonItem alloc] initWithCustomView:_mode_ChangeBtn];

            UIBarButtonItem * menuItem =
            [UIView getBarButtonItemWithImageName:@"icon_pplist_gongneng"
                                              Sel:@selector(menuClick)
                                               VC:self];
            
            self.navigationItem.rightBarButtonItems = @[menuItem,modeChangeItem];
        }
    }
    
    
}

///  顶部纤芯添加按钮的点击事件
- (void) addFiberClick {
    
//    [self muBan_Push:@{} typeRef:TYKDeviceListInsert];
    [self push_NewMB:@{}];
}


/// 新增 走大为新模板的接口 2021.6.23
- (void) push_NewMB:(NSDictionary *) dict {
    
    if (dict.allKeys.count == 0) {
        
        Inc_NewMB_Presenter * presenter = Inc_NewMB_Presenter.presenter;
        presenter.cableLength = _moban_Dict[@"cableSectionLength"];
        
        Inc_NewMB_DetailVC * vc = [[Inc_NewMB_DetailVC alloc] initWithDict:@{} Yuan_NewMB_ModelEnum:Yuan_NewMB_ModelEnum_optPair];
        
        Push(self, vc);
        
        return;
    }
    
    // 根据id 请求详细信息
    [Inc_Push_MB NewMB_GetDetailDictFromGid:dict[@"pairId"]
                                        Enum:Yuan_NewMB_ModelEnum_optPair
                                     success:^(NSDictionary * _Nonnull dict) {
       
        Inc_NewMB_Presenter * presenter = Inc_NewMB_Presenter.presenter;
        presenter.cableLength = _moban_Dict[@"cableSectionLength"];
        
        Inc_NewMB_DetailVC * vc = [[Inc_NewMB_DetailVC alloc] initWithDict:dict Yuan_NewMB_ModelEnum:Yuan_NewMB_ModelEnum_optPair];
        
        Push(self, vc);
    }];
}



/// 过去 走龙哥模板的接口  2020年时
- (void) muBan_Push:(NSDictionary *)dict typeRef:(TYKDeviceListControlTypeRef)type{
    
    NSLog(@"--- %@",dict);
    
    
    _reader = [IWPPropertiesReader propertiesReaderWithFileName:@"UNI_optPair"
                                          withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
    
    _model = [IWPPropertiesSourceModel modelWithDict:_reader.result];
    
    // 创建viewModel
    NSMutableArray * arrr = [NSMutableArray array];
    for (NSDictionary * model_dict in _model.view) {
        IWPViewModel * viewModel = [IWPViewModel modelWithDict:model_dict];
        [arrr addObject:viewModel];
    }
    _viewModel_muban = arrr;
        
    // 王大为模板转型 后的dict
    NSDictionary * moban_newDict = [[[Yuan_CFConfigModel alloc] init] wangDavieToLonggeMoBanDictChange:dict];
        
    
    // TODO : 智网通模板跳转
     TYKDeviceInfoMationViewController *device =
     [Inc_Push_MB pushFrom:self resLogicName:@"optPair" dict:moban_newDict type:type];
     
     
     device.Yuan_CFBlock = ^(NSDictionary *changeDict) {
       
         // changeDict 可能不需要
         
         // 重新请求列表资源
         [self http_List];
     };
    
}


- (void) remove_UI {
    
    [_headerView removeFromSuperview];
    [_tableView removeFromSuperview];
    [_collection removeFromSuperview];
    [_InitBtn removeFromSuperview];
    
    
    _headerView = nil;
    _tableView = nil;
    _collection = nil;
    _InitBtn = nil;
    
}

//zzc 2021-6-17
//黑色透明背景和异常table
-(void)setWindowBgView {
    _windowBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _windowBgView.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:0.4];
    _windowBgView.userInteractionEnabled = YES;
  
//
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
//    [_windowBgView addGestureRecognizer:tap];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:_windowBgView];
    
    
    [_windowBgView addSubview:self.lightTableView];
    [_windowBgView addSubview:self.pairNoChangeView];
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
 
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *cellIdentifier = @"Zhang_AbnormalCell";
    
    Inc_AlltermCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[Inc_AlltermCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    WEAK_SELF;
    cell.labelBlock = ^(UILabel * _Nonnull label) {
        label.textColor = UIColor.redColor;
        _selectDic = wself.dataArray[indexPath.row];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself closeBtnClick];
            [wself pushZhang_CFListLightVC];
        });
    };
    cell.dic = self.dataArray[indexPath.row];
    
    return cell;
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 44)];
    sectionHeadView.backgroundColor = UIColor.whiteColor;
    
    UIView *lineLabel = [UIView viewWithColor:Color_V2Red];
    lineLabel.frame = CGRectMake(10, 14, 3, 16);
    
    [sectionHeadView addSubview:lineLabel];
    
    UILabel *contentLabel = [UIView labelWithTitle:@"光路列表" frame:CGRectMake(20, 0, 200 , sectionHeadView.frame.size.height)];
    contentLabel.textColor = UIColor.blackColor;
    contentLabel.font = Font_Bold_Yuan(15);
    
    [sectionHeadView addSubview:contentLabel];
    
    UIButton *coloseBtn = [UIView buttonWithImage:@"icon_guanbi" responder:self SEL_Click:@selector(closeBtnClick) frame:CGRectMake(sectionHeadView.frame.size.width - 44, 0, 44, 44)];
    
    [sectionHeadView addSubview:coloseBtn];
    
    
    return sectionHeadView;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}


//菜单点击
- (void) menuClick {
    
    if (_nowMode == CFList_TableView) {
        
        [YuanHUD HUDFullText:@"请切换显示模式"];
        return;
    }
    
    [self.menu showMenuEnterAnimation:MLAnimationStyleTop];
}

#pragma mark ---  下拉列表代理  ---

- (void)menuView:(MLMenuView *)menu didselectItemIndex:(NSInteger)index {
    
    // 根据不同的index 跳转到不同的控制器
    switch (index) {
        case 0:
            
            [self Http_SelectRoadInfoByEqpId:@{
                @"id":_cableId,
                @"type":@"optSect"
            }];
            break;
        
        case 1:
          
            break;
            
            
        case 2:
            
            break;
       
                        
        default:
            break;
    }
    
    
    
}



// 下拉菜单
-(MLMenuView *)menu {
    
    if (_menu == nil) {
      
        NSArray * menuItems = @[
                                @"查看光路"];
        
        
        NSArray * photoArryas = @[
                                  @"zzc_guanglu"];
        
        
        float menuWidth = IphoneSize_Width(100);
        
        CGRect menuRect =  CGRectMake(ScreenWidth - menuWidth - 10,
                                      0,
                                      menuWidth,
                                      0);
        
        MLMenuView * menuView =
        [[MLMenuView alloc] initWithFrame:menuRect
                               WithTitles:menuItems
                           WithImageNames:photoArryas
                    WithMenuViewOffsetTop:NaviBarHeight
                   WithTriangleOffsetLeft:menuWidth - 10
                            triangleColor:UIColor.whiteColor];
        
        
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

//关闭异常table  清理数组
- (void)closeBtnClick{
    [self.dataArray removeAllObjects];
    _windowBgView.hidden = YES;
    _lightTableView.hidden  = YES;
}

////需要点击背景隐藏 打开
//-(void)tapEvent:(UITapGestureRecognizer *)gesture {
////    [self.dataArray removeAllObjects];
////    _windowBgView.hidden = YES;
////    _lightTableView.hidden  = YES;
//}

-(void)showPairView {
    _windowBgView.hidden = NO;
    _pairNoChangeView.hidden  = NO;
}

- (void)hiddenPairView {
    _windowBgView.hidden = YES;
    _pairNoChangeView.hidden  = YES;
}

#pragma mark -http

- (void)Http_SelectRoadInfoByEqpId:(NSDictionary *)param {
    
    [Inc_NewFL_HttpModel1 Http_SelectRoadInfoByEqpId:param success:^(id  _Nonnull result) {
        
        if (result) {
            NSArray *array = result;
            if (array.count == 0) {
                [[Yuan_HUD shareInstance] HUDFullText:@"没有关联的光路"];
                return;
            }else{
                
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:array];

                _windowBgView.hidden = NO;
                _lightTableView.hidden = NO;
                [_lightTableView reloadData];


                [_lightTableView YuanToSuper_Bottom:0];
                [_lightTableView YuanToSuper_Left:0];
                [_lightTableView YuanToSuper_Right:0];
                [_lightTableView autoSetDimension:ALDimensionHeight toSize:MIN(44 * _dataArray.count + 44 + 20, ScreenHeight - NaviBarHeight)];
                
            }
        }
    }];
    
    
}


- (void)Http_PairNoChanged:(NSDictionary *)param {
    
    [Inc_NewMB_HttpModel HTTP_NewMB_ModifiWithURL:_httpPortModel.Modifi
                                              Dict:param
                                           success:^(id  _Nonnull result) {
         
        
        [self http_List];
    }];
    
    
    [self hiddenPairView];
    [self.pairNoChangeView cleareData];
    
}

#pragma mark -push

- (void)pushZhang_CFListLightVC {
    
    Inc_CFListLightVC *vc = [Inc_CFListLightVC new];
    vc.selectDic = _selectDic;
    vc.moban_Dict = _moban_Dict;
    vc.cableId = _cableId;
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

@end
