//
//  Inc_NewMB_DetailVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/10.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewMB_DetailVC.h"


/// **** 业务类
#import "Inc_NewMB_HttpModel.h"
#import "Inc_NewMB_PushVM.h"           // 右侧导航栏相关的
#import "Inc_NewMB_Presenter.h"        // 抽离出来的特殊判断类


/// **** UI
#import "Inc_NewMB_Item.h"             // 每一词条的View
#import "MLMenuView.h"                 // 菜单

/// **** 相关控制器
#import "Yuan_OBD_PointVC.h"  // 分光器端子盘

#import "Yuan_New_ODFModelVC.h"




#pragma mark - 张兆超添加部分 ********  ---

// zzc  2021-6-15  保存按钮 存在业务变更时添加接口判断
#import "Inc_NewFL_HttpModel1.h"

//业务变更
#import "Inc_SynchronousView.h"



@interface Inc_NewMB_DetailVC ()
<
    UIScrollViewDelegate ,
    Yuan_NewMB_ItemDelegate,
    MLMenuViewDelegate
>

/** scroll */
@property (nonatomic , strong) UIScrollView * scrollView;

/** btnsView */
@property (nonatomic , strong) UIView * btnsView;

/** 展开与隐藏 非必选的部分 */
@property (nonatomic , strong) UIButton * notRequireBtn;


//zzc 20221-6-15

////同步变更 数据
@property (nonatomic, strong) NSMutableArray *synchronousArray;

//同步变更 view
@property (nonatomic, strong) Inc_SynchronousView *synchronousView;

/** 右侧菜单 */
@property (nonatomic , strong) MLMenuView * menu;

@end

@implementation Inc_NewMB_DetailVC
{
    
    Yuan_NewMB_ModelEnum_ _resLogicName_Enum; // 资源枚举
    
    NSArray <Yuan_NewMB_ModelItem * > * _MB_Array;  //模板的数据源
    
    NSMutableArray <Inc_NewMB_Item *> * _notRequireViewsArray;         //所有非必选项的集合 , 统一管理显示还是隐藏
    
    NSMutableArray <Inc_NewMB_Item *> * _allItemsViewArr;              //所有itemView 的集合
    
    Inc_NewMB_VM * _VM;
    Inc_NewMB_HttpPort * _httpPortModel;
    Inc_NewMB_Presenter * _presenter;
    Inc_NewMB_PushVM * _pushVM;
    
    // scrollView 滑动范围   必选和非必选的总高度
    float _scrollContentY;
    
    float _scrollRequiredContentY;
    
    BOOL _isShowNotRequire;  //当前是否显示非必选项 , 通过控制 scrollView的contentSize来操作 默认false
    
    NSLayoutConstraint * _notRequireBtnConstraint;
    
    
    // 是不是只引用view 不跳转
    BOOL _isJustImportView;
    
    
    // 待上传的模板Dict
    NSMutableDictionary * _requestDict;
 
    // zzc  2021-6-15

    //进入页面oprStateId  用于对比是否修改了状态
    NSString * _oldOprStateId;
    
    //zzc 2022-1-11 是否修改了产权字段
    NSString * _oldProperty;
    NSString * _oldPropCharId;
    
    //zzc 2021-6-15
    //黑色透明背景view
    UIView *_windowBgView;
    
    //接口返回数组，确认修改时使用，因synchronousArray 可能需要变化
    NSMutableArray *_httpSynchronousArray;
    
    float _nowScoll_Y;
    
    
    // digCode 接口是否需要调用?
    BOOL _digCode_IsChanged;
    
    // 本资源查询回来的数据 是否已经有了digCode
    BOOL _digCode_IsHaveAlready;
    
    // 该资源是否有 GID
    BOOL _isHaveResId;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithDict:(NSDictionary *) cellDict
        Yuan_NewMB_ModelEnum:(Yuan_NewMB_ModelEnum_) resLogicName_Enum {
    
    
    if (!cellDict) {
        
        [YuanHUD HUDFullText:@"无详细信息数据_Yuan"];
        return nil;
    }
    
    if (self = [super init]) {
        
        _requestDict = [NSMutableDictionary dictionaryWithDictionary:cellDict];
        
        // 记录该资源是否有 gid
        _isHaveResId =
        [_requestDict.allKeys containsObject:@"resId"] ||
        [_requestDict.allKeys containsObject:@"gid"];
        
        //zzc 2021-6-15 进入页面标记原状态   zzc适配后台返回long类型
        _oldOprStateId = [NSString stringWithFormat:@"%@",_requestDict[@"oprStateId"]]?:@"";
            
        _oldProperty = [NSString stringWithFormat:@"%@",_requestDict[@"property"]]?:@"";
        _oldPropCharId = [NSString stringWithFormat:@"%@",_requestDict[@"propCharId"]]?:@"";

        // 资源类型
        _resLogicName_Enum = resLogicName_Enum;
        
        // presenter
        _presenter = Inc_NewMB_Presenter.presenter;
        _presenter.detailVC = self;
        [self presenter_Blocks];
        
        // viewModel
        _VM = Inc_NewMB_VM.viewModel;
        _VM.vc = self;
        
        _pushVM = [[Inc_NewMB_PushVM alloc] initWithEnum:resLogicName_Enum
                                                  MbDict:cellDict
                                                      vc:self];
        
        Inc_NewMB_Model * model = [[Inc_NewMB_Model alloc] initWithEnum:_resLogicName_Enum];
        _MB_Array = model.model;
        
        _scrollContentY = 0;
        
        // 此时证明已经有了 digCode
        if ([_requestDict.allKeys containsObject:@"digCode"]) {
            _digCode_IsHaveAlready = YES;
        }
        
    }
    return self;
}


#pragma mark - 生命周期 ---
- (void)viewDidLoad {
    
    [super viewDidLoad];
       
    self.title = @"详细信息";
    _httpPortModel = [Inc_NewMB_HttpPort ModelEnum:_resLogicName_Enum];
    
    if (!_MB_Array || _MB_Array.count == 0) {
        return;
    }
    
    _nowScoll_Y = 0;
    
    // scrollView
    [self UI_Init];
    
    // 加载subView 数据部分
    [self Item_UI_Init];
    
    
    // zzc 2021-6-15  业务变更
    [self setWindowBgView];
    _windowBgView.hidden = YES;
//    _synchronousView.hidden = YES;

    _synchronousArray = [NSMutableArray array];
    _httpSynchronousArray = [NSMutableArray array];
    
    
    // 如果当前资源需要显示 导航栏右侧按钮 , 则显示出来
    if ([_pushVM isHaveRightNaviMenu] &&
        [_requestDict.allKeys containsObject:@"gid"]) {
        
//        [self naviBarSet];
        __typeof(self)weakSelf = self;
        weakSelf.moreBtnBlock = ^(UIButton * _Nonnull btn) {
            [self rightBarBtnClick];
        };
    }
    

}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    Http.shareInstance.statisticEnum = HttpStatistic_Resource;
    _presenter.detailVC = self;
}


//黑色透明背景
-(void)setWindowBgView {
    _windowBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _windowBgView.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:0.4];
    _windowBgView.userInteractionEnabled = YES;
  

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [_windowBgView addGestureRecognizer:tap];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:_windowBgView];
    
//    [_windowBgView addSubview:self.synchronousView];
    
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


#pragma mark - ItemUI_Init  ---

- (void) Item_UI_Init {
    
    // 如果初始化阶段 , 检测到有新增注入字段 , 需要直接显示在模板上  -- yuanq 2021.7.22
    if (_insertDict) {
        [_requestDict setValuesForKeysWithDictionary:_insertDict];
    }
    
    _notRequireViewsArray = NSMutableArray.array;
    _allItemsViewArr = NSMutableArray.array;
    
    // MARK: 对模板资源进行排序 ---
    
    NSMutableArray * mt_MBArr = NSMutableArray.array;
    
    // 先将必填部分 写入
    for (Yuan_NewMB_ModelItem * modelItem in _MB_Array) {
        if (![modelItem.required isEqualToString:@"0"]) {
            [mt_MBArr addObject:modelItem];
        }
    }
    
    // 先将非必填部分 写入
    for (Yuan_NewMB_ModelItem * modelItem in _MB_Array) {
        if ([modelItem.required isEqualToString:@"0"]) {
            [mt_MBArr addObject:modelItem];
        }
    }
    
    _MB_Array = mt_MBArr;
    
    
    // MARK: 将模板资源初始化在ScrollView上 ---
    
    for (Yuan_NewMB_ModelItem * modelItem in _MB_Array) {
        
        // View
        Inc_NewMB_Item * item = [[Inc_NewMB_Item alloc] initItemWithModel:modelItem
                                                                         vc:self
                                                                     mbDict:_requestDict];
        
        item.fileName = _httpPortModel.type;
        
        [_scrollView addSubview:item];
        
        //getHeight 方法中 ,封装了对应type的高度
        [item autoSetDimension:ALDimensionHeight toSize:item.getHeight];
        [item autoSetDimension:ALDimensionWidth toSize:ScreenWidth];
        [item YuanToSuper_Top:_scrollContentY];
        
        _scrollContentY += item.getHeight;

        if (![modelItem.required isEqualToString:@"0"]) {
            
            // 当他是动态字段时
            if ([modelItem.required isEqualToString:@"3"]) {
             
                // 验证字段为真时
                if ([_requestDict.allKeys containsObject:modelItem.relateKey] &&
                    [_requestDict[modelItem.relateKey] isEqualToString:modelItem.relateValue]) {
                    _scrollRequiredContentY += item.getHeight;
                    [item changeTitleColor:YES];
                }
                else {
                    [_notRequireViewsArray addObject:item];
                    item.hidden = YES;
                    [item changeTitleColor:NO];
                }
                
            }
            else {
                _scrollRequiredContentY += item.getHeight;
            }
        }
        // 非必选项 默认隐藏
        else {
            [_notRequireViewsArray addObject:item];
            item.hidden = YES;
        }
        
        // 所有itemView的集合
        [_allItemsViewArr addObject:item];
        
        item.delegate = self;
        
        NSLog(@"--- %f  ---%f",_scrollContentY,_scrollRequiredContentY);
        
    }
    
    
    _notRequireBtn = [UIView buttonWithTitle:@"显示详情"
                                   responder:self
                                         SEL:@selector(notRequireClick)
                                       frame:CGRectNull];
    
    _notRequireBtn.titleLabel.font = Font_Bold_Yuan(16);
    
    
    [_scrollView addSubview:_notRequireBtn];
    
    [_notRequireBtn YuanAttributeVerticalToView:_scrollView];
    [_notRequireBtn autoSetDimension:ALDimensionHeight toSize:Vertical(50)];
    _notRequireBtnConstraint = [_notRequireBtn YuanToSuper_Top:_scrollRequiredContentY];
    
    
    float bottomZero = 0;
    
    if (NaviBarHeight == 88) {
        bottomZero = Vertical(50);
    }
    
    float contentSizeY = _scrollRequiredContentY + Vertical(50) + bottomZero;
    
    _scrollView.contentSize = CGSizeMake(ScreenWidth,contentSizeY);
}




/// 清空所有Item
- (void) item_ClearAllItem {
    
    _scrollContentY = 0;
    _scrollRequiredContentY = 0;
    
    for (Inc_NewMB_Item * item in _allItemsViewArr) {
        [item removeFromSuperview];
    }
    
    [_notRequireBtn removeFromSuperview];
    
    
    // 重新初始化 items
    [self Item_UI_Init];
}



#pragma mark - BaseUI ---
- (void) UI_Init {
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectNull];
    _scrollView.userInteractionEnabled = YES;
    _scrollView.bounces = YES;
    _scrollView.delegate = self;
    
    
    
    _btnsView = [UIView viewWithColor:UIColor.whiteColor];
    
    [self.view addSubviews:@[_scrollView,_btnsView]];
    [self yuan_LayoutSubViews];
    
    // 底部按钮
    [self bottomBtns_UI_Init];
}


// 显示或隐藏 非必选字段
- (void) notRequireClick {
    
    _isShowNotRequire = !_isShowNotRequire;
    
    _notRequireBtnConstraint.active = NO;
    
    // 展开 展示全部
    if (_isShowNotRequire) {
        _notRequireBtnConstraint = [_notRequireBtn YuanToSuper_Top:_scrollContentY];
        _scrollView.contentSize = CGSizeMake(ScreenWidth, _scrollContentY + Vertical(50) + Vertical(50));
        [_notRequireBtn setTitle:@"隐藏详情" forState:UIControlStateNormal];
    }
    // 隐藏 只展示必选部分
    else {
        _notRequireBtnConstraint = [_notRequireBtn YuanToSuper_Top:_scrollRequiredContentY];
        _scrollView.contentSize = CGSizeMake(ScreenWidth, _scrollRequiredContentY + Vertical(50) +  Vertical(50));
        [_notRequireBtn setTitle:@"显示详情" forState:UIControlStateNormal];
    }
    
    
    // 非必须项的隐藏于显示
    for (UIView * view in _notRequireViewsArray) {
        view.hidden = !_isShowNotRequire;
    }
    
    
}


- (void) yuan_LayoutSubViews {
    
    
    [_scrollView YuanToSuper_Top:_isJustImportView ? 0 : NaviBarHeight];
    [_scrollView YuanToSuper_Left:0];
    [_scrollView YuanToSuper_Right:0];
    [_scrollView YuanToSuper_Bottom:BottomZero + Vertical(50)];
    
    [_btnsView YuanToSuper_Left:0];
    [_btnsView YuanToSuper_Right:0];
    [_btnsView YuanToSuper_Bottom:BottomZero];
    [_btnsView autoSetDimension:ALDimensionHeight toSize:Vertical(50)];
}



#pragma mark - method ---


// 根据新数据 刷新页面
- (void) reloadItemWithDict:(NSDictionary *) newDict {
    
    // 在reload
    for (Inc_NewMB_Item * item in _allItemsViewArr) {
        
        [item reloadWithDict:newDict];
    }
}




#pragma mark - Delegate ---


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}



- (void)Yuan_NewMB_Item:(Inc_NewMB_Item *)item
                newDict:(NSDictionary *)newDict {
    
    
    for (NSString * key in newDict.allKeys) {
        
        // 如果清空了 , 就从里面移除 而不是保存 key : @""  , 如果是digCode的话 可以为空字符串 @""
        // 如果老 requestDict中该字段key 为空 , 新赋值时还是空的话 , 那么就移除该字段
        // [NSString stringWithFormat:@"%@",_requestDict[key]] zzc适配后台返回long类型 目前电表使用
        if ([[NSString stringWithFormat:@"%@",_requestDict[key]] isEqualToString:@""] && ![key isEqualToString:@"digCode"]) {
            
            if ([newDict[key] isEqualToString:@""] ||
                [newDict[key] obj_IsNull]) {
                
                [_requestDict removeObjectForKey:key];
                continue;
            }
        }
        
        _requestDict[key] = newDict[key];
        
        // 验证 digCode 是否修改过
        if ([key isEqualToString:@"digCode"]) {
            _digCode_IsChanged = YES;
        }
        
    }
    
    NSLog(@"%@" , _requestDict.json);
}



- (void)Yuan_NewMB_Item:(Inc_NewMB_Item *)item
                newDict:(NSDictionary *)newDict
               isReload:(BOOL)isReload {
    
    // 一定是yes
    
    for (NSString * key in newDict.allKeys) {
        
        // 如果清空了 , 就从里面移除 而不是保存 key : @""
        // zzc适配后台返回long类型 目前电表使用
        if ([[NSString stringWithFormat:@"%@",_requestDict[key]] isEqualToString:@""]) {
            [_requestDict removeObjectForKey:key];
            continue;
        }
        
        _requestDict[key] = newDict[key];
        
        // 验证 digCode 是否修改过
        if ([key isEqualToString:@"digCode"]) {
            _digCode_IsChanged = YES;
        }
    }
    
    // 需要重新刷新界面
    [self reloadItemWithDict:_requestDict];
    
    NSLog(@"%@" , _requestDict.json);
    
}



- (void)Yuan_NewMB_ReLoadAllItems {
    
    [self item_ClearAllItem];
    
}


#pragma mark - 底部按钮 UI ---


- (void) bottomBtns_UI_Init {
    
    NSArray * btnsArr = [_VM bottomBtns_Enum:_resLogicName_Enum mbDict:_requestDict];
    
    // 间隔
    float limit = Horizontal(10);
    float btnWidth = (ScreenWidth - (limit * (btnsArr.count + 1))) / btnsArr.count;
    
    for (int i = 0; i < btnsArr.count; i++) {
        
        UIButton * btn = btnsArr[i];
        [btn cornerRadius:3 borderWidth:0 borderColor:nil];
        btn.backgroundColor = UIColor.mainColor;
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        
        btn.titleLabel.font = Font_Yuan(13);
        
        [_btnsView addSubview:btn];
        
        [btn YuanAttributeHorizontalToView:_btnsView];
        [btn YuanToSuper_Left:limit + (limit + btnWidth) * i];
        [btn autoSetDimensionsToSize:CGSizeMake(btnWidth, Vertical(40))];
        
    }
    
}


#pragma mark - 基本资源的按钮 点击事件 ---


// 保存
- (void) saveClick {
    
    
    // 1. 首先校验必填字段
    
    for (Yuan_NewMB_ModelItem * item in _MB_Array) {
        
        // 对应字段的Key
        NSString * key = item.key;
        
        NSString * required = item.required;
        
        // 非必填字段和扫一扫 我不验证
        if (required.intValue == 0 || [item.type isEqualToString:@"52"]) {
            continue;
        }
        
        // 动态字段
        if (required.intValue == 3) {
            
            // 如果 动态字段的主动字段并没有被选中 , 也不需要判断
            if (![_requestDict.allKeys containsObject:item.required] ||
                [_requestDict[item.relateKey] isEqualToString:item.relateValue]) {
                continue;
            }
        }
        
        // 证明是验证 type = 4  经纬度  ** 需要在通用判断前判断完成
        if ([key isEqualToString:@"x|y"]) {
            
            if (![_requestDict.allKeys containsObject:@"x"] ||
                [StringObject(_requestDict[@"x"]) isEqualToString:@""] ||
                ![_requestDict.allKeys containsObject:@"y"] ||
                [StringObject(_requestDict[@"y"])  isEqualToString:@""]) {
                
                [UIAlert alertSmallTitle:@"经纬度为必填字段"];
                return;
            }
            
            continue;
        }
        
        
        NSString * requireKey = [NSString stringWithFormat:@"%@为必填字段",item.title];
        // zzc适配后台返回long类型 目前电表使用
        if (![_requestDict.allKeys containsObject:key] ||
            [[NSString stringWithFormat:@"%@",_requestDict[key]] isEqualToString:@""]) {
            [UIAlert alertSmallTitle:requireKey];
            return;
        }
        
        
        NSString * type = item.type;
        
        if (type.intValue == 3) {
            // 过去请选择字段是 0  -- 现在请选择字段是 -1
            // zzc适配后台返回long类型 目前电表使用
            if ([[NSString stringWithFormat:@"%@",_requestDict[key]] isEqualToString:@"-1"]) {
                [UIAlert alertSmallTitle:requireKey];
                return;
            }
        }
    }
    
    
    // 通过是否存在 resId 来判断是  '保存修改' 还是 '新建'

    // 保存修改
    if (_isHaveResId) {
        
        //光缆段
        if (_resLogicName_Enum == Yuan_NewMB_ModelEnum_optSect) {
            
            if ((![_oldProperty isEmptyString] && ![_oldProperty isEqualToString:[NSString stringWithFormat:@"%@",_requestDict[@"property"]]])|| (![_oldPropCharId isEmptyString] && ![_oldPropCharId isEqualToString:[NSString stringWithFormat:@"%@",_requestDict[@"propCharId"]]])) {
                
                [UIAlert alertSmallTitle:@"是否要对下属纤芯的产权归属和产权性质进行统一修改" agreeBtnBlock:^(UIAlertAction *action) {
                    
                    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
                    
                    // 如果有需要特殊注入的字段
                    if (_modifyDict) {
                        [postDict setValuesForKeysWithDictionary:_modifyDict];
                    }
                    //optSectSync   1：需要下属纤芯统一修改产权  不传或其他：不需要统一修改
                    [postDict setValue:@"1" forKey:@"optSectSync"];
                    
                    _modifyDict = postDict;
                    
                    [self Http_Modifi];

                } cancelBtnBlock:^(UIAlertAction *action) {
                    
                    [self Http_Modifi];
                }];
                
            }else{
                [self Http_Modifi];
            }
        
        }
        //纤芯
        else if (_resLogicName_Enum == Yuan_NewMB_ModelEnum_optPair){

            /// 只有纤芯才走这个 同步业务变更    zzc适配后台返回long类型 目前电表使用
            if (![_oldOprStateId isEmptyString] && ![_oldOprStateId isEqualToString:[NSString stringWithFormat:@"%@",_requestDict[@"oprStateId"]]]) {
                
                [self Http_UpdateOprState:@{
                    @"gid":_requestDict[@"gid"]?:@"",
                    @"resType":@"pair",
                    @"oprStateId":_requestDict[@"oprStateId"]?:@""
                }];
            }else{
                [self Http_Modifi];
            }

        }
        //其他
        else{
            [self Http_Modifi];
        }
    }
    // 新建
    else {
        [self Http_Add];
    }
    

}


/// 保存标签
- (void) saveRfidClick {
    
    // 没有gid
    if (!_isHaveResId) {
        
        [YuanHUD HUDFullText:@"该资源缺少GID , 无法保存"];
        return;
    }
    
    if (![_requestDict.allKeys containsObject:@"digCode"]) {
        
        [YuanHUD HUDFullText:@"没有需要保存的标签"];
        return;
    }
    
    
    [UIAlert alertSmallTitle:@"是否保存标签?"
               agreeBtnBlock:^(UIAlertAction *action) {
            
        // 调用保存 rfid 的接口
        [self Http_Add_digCode];
        
    }];

}


// 删除
- (void) deleteClick {
    [UIAlert alertSmallTitle:@"是否删除?"
               agreeBtnBlock:^(UIAlertAction *action) {
        [self Http_Delete];
    }];
}

// 模板
-(void)showModelClick {
    
    
    NSString * GID = _requestDict[@"gid"];
    Yuan_New_ODFModelVC *OBD =
    [[Yuan_New_ODFModelVC alloc] initWithType:InitType_OBD
                                          Gid:GID
                                         name:_requestDict[@"name"]];
    

    
    [self.navigationController pushViewController:OBD animated:YES];
    
    OBD.mb_Dict = _requestDict;
    
}
#pragma mark - 不同资源的特殊按钮 点击事件 ---


// 分光器查看下属端子
- (void) obd_PortClick {
    
    Yuan_OBD_PointVC * obd_point = [[Yuan_OBD_PointVC alloc] initWithSuperResId:_requestDict[@"gid"]];
    Push(self, obd_point);
}


// 新版纤芯 查看光路
- (void) FiberLink {
    [_presenter PushToFiberLink:_requestDict];
}

// 新版纤芯 查看所属局向光纤
- (void) FiberRoute {
    [_presenter PushToFiberRoute:_requestDict];
}


// 光缆段 纤芯配置
- (void) CFConfigClick {
    
    [_presenter PushToCFConfig:_pushVM.getOldKeys];
}

//列框 模块
-(void)showModuleClick {
    
    [_presenter PushToModule:_requestDict];

}

#pragma mark - Block ---

- (void) presenter_Blocks {
    
    __typeof(self)weakSelf = self;
    
    // 纤芯衰耗修改后 影响光纤性能字段的判断block
    weakSelf->_presenter.optPair_ConfigBlock = ^(NSDictionary * _Nonnull dict) {
      
        NSString * key = dict[@"key"];
        
        for (Inc_NewMB_Item * item in _allItemsViewArr) {
            
            if ([item.myModel.key isEqualToString:key]) {
        
                // 放开注释 将会自动为纤芯添加光纤性能
                // _requestDict[key] = dict[@"value"];
                // [item reloadWithDict:_requestDict];
                break;
            }
        }
    };
    
    
}





#pragma mark - HttpPort ---

/// 修改保存 *** *** *** *** *** *** *** ***
- (void) Http_Modifi {
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];

    // 通用资源
    if (_httpPortModel.code && _httpPortModel.type) {
        
        postDict[@"resType"] = _httpPortModel.type;
        postDict[@"datas"] = @[[self dataSourceCleanToPost:_requestDict]]; //必须要过滤一些不传的字段
    }
    

    
    // 如果有需要特殊注入的字段
    if (_modifyDict) {
        [postDict setValuesForKeysWithDictionary:_modifyDict];
    }
    
    [Inc_NewMB_HttpModel HTTP_NewMB_ModifiWithURL:_httpPortModel.Modifi
                                              Dict:postDict
                                           success:^(id  _Nonnull result) {
         
        
        // 是否存在digCode
        if (_digCode_IsChanged) {
            Http.shareInstance.statisticEnum = HttpStatistic_ResourceBindQR;
            // 修改 digCode
            [self Http_Add_digCode];
        }
        
        else {
            
            [self After_HttpSourceConfigEnum:Yuan_NewMB_Enum_Modifi
                                  searchName:_listSearchName];
        }
    }];
    
}


/// 新增 *** *** *** *** *** *** *** ***
- (void) Http_Add {
    
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    // 通用资源
    if (_httpPortModel.code && _httpPortModel.type) {
        
        postDict[@"resType"] = _httpPortModel.type;
        postDict[@"datas"] = @[[self dataSourceCleanToPost:_requestDict]]; //必须要过滤一些不传的字段
    }
    
    
    // 如果有需要特殊注入的字段
    if (_insertDict) {
        [postDict setValuesForKeysWithDictionary:_insertDict];
    }
    
    
    
    
    [Inc_NewMB_HttpModel HTTP_NewMB_AddWithURL:_httpPortModel.Add
                                           Dict:postDict
                                        success:^(id  _Nonnull result) {
            
        // 是否存在digCode
        
        NSDictionary * dict = result;
        
        NSString * GID = dict[@"GID"];
        
        if (GID) {
            _requestDict[@"gid"] = GID;
        }
        
        if ([_requestDict.allKeys containsObject:@"digCode"]) {
            Http.shareInstance.statisticEnum = HttpStatistic_ResourceBindQR;
            [self Http_Add_digCode];
        }
        
        else {
            
            //复制成功返回列表
            if (_isCopy) {
                
                NSString * msg = @"操作成功";
                
                [UIAlert alertSingle_SmallTitle:msg agreeBtnBlock:^(UIAlertAction *action) {
                        
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"copyComBoxSuccessful" object:nil];
                    
                    NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-2]animated:YES];
                    
                }];
                              
            }else{
                
                [self After_HttpSourceConfigEnum:Yuan_NewMB_Enum_Add
                                      searchName:_requestDict[@"resName"]];
            }
      
        }
        
        
        
    }];
}


/// 删除 *** *** *** *** *** *** *** ***
- (void) Http_Delete {
    
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];

    // 通用资源
    if (_httpPortModel.code && _httpPortModel.type) {
        
        postDict = [NSMutableDictionary dictionaryWithDictionary:@{
            @"resType": _httpPortModel.type,
            @"datas":@[@{@"gid":_requestDict[@"gid"] ?: @""}]
        }];
        
        if ([_requestDict.allKeys containsObject:@"digCodeId"]) {
            postDict[@"datas"] = @[@{@"gid":_requestDict[@"gid"] ?: @"" ,
                                     @"digCodeId" : _requestDict[@"digCodeId"]}];
        }
        
    }
    

    
    
    // 如果有需要特殊注入的字段
    if (_deleteDict) {
        [postDict setValuesForKeysWithDictionary:_deleteDict];
    }
    
    
            
    [Inc_NewMB_HttpModel HTTP_NewMB_DeleteWithURL:_httpPortModel.Delete
                                              Dict:postDict
                                           success:^(id  _Nonnull result) {
               
        [self After_HttpSourceConfigEnum:Yuan_NewMB_Enum_Delete
                              searchName:_listSearchName];
    }];
    
}




- (void) Http_Add_digCode {
    
    // 没有 digCode 不调用这个接口
    if (![_requestDict.allKeys containsObject:@"digCode"]
        || !_requestDict[@"gid"]) {
        return;
    }
    
    NSDictionary * postDict ;
    
    if (_httpPortModel.code && _httpPortModel.type) {
        
        

        
        NSMutableDictionary * postDatasDict = [NSMutableDictionary dictionaryWithDictionary:@{
            @"resTypeId" : _httpPortModel.type,
            @"digCode" : _requestDict[@"digCode"],
            @"resId" : _requestDict[@"gid"]
        }];
        
        
        NSString * url = @"";
        
        // 以前没有digCode , 那么现在是新增
        if (!_digCode_IsHaveAlready) {
            url = _httpPortModel.Add;
        }
        
        // 如果以前有digCode , 那么现在是修改
        else {
            url = _httpPortModel.Modifi;
            postDatasDict[@"gid"] = _requestDict[@"digCodeId"];
        }
        
        
        postDict = @{
            
            @"resType" : @"elecLabel",
            @"reqDb" : Yuan_WebService.webServiceGetDomainCode,
            @"datas" : @[postDatasDict]
        };
        
        /*
         // 删除
         postDict = @{
             
             @"resType" : @"elecLabel",
             @"reqDb" : Yuan_WebService.webServiceGetDomainCode,
             @"datas" : @{
                 @"gid" : _requestDict[@"digCodeId"],
             }
         };
         */
        
        
        [Inc_NewMB_HttpModel HTTP_NewMB_SourceAdddigCodeDict:postDict
                                                       Url:url
                                                   Success:^(id  _Nonnull result) {
            
            [self After_HttpSourceConfigEnum:Yuan_NewMB_Enum_Modifi
                                  searchName:_listSearchName];
        }];
        
        
        
        
    }
    else {
        return;
    }
    
    
}




// 整理一遍 , 哪些字段不传  -- 如果不过滤 会造成后台不能识别该字段
- (NSDictionary *) dataSourceCleanToPost:(NSDictionary *)dict {
    
    NSMutableDictionary * cleanDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    NSArray * cleanKeys = _VM.getCleanKeys;
    
    NSArray * dict_AllKeys = cleanDict.allKeys;
    
    for (NSString * key in dict_AllKeys) {
        
        for (NSString * cleanKey in cleanKeys) {
            
            if ([key isEqualToString:cleanKey]) {
                [cleanDict removeObjectForKey:key];
            }
        }
    }
    
    
    
    return cleanDict;
}




#pragma mark - 操作后的逻辑判断 ---
- (void) After_HttpSourceConfigEnum:(Yuan_NewMB_Enum_)EnumType
                         searchName:(NSString *)searchName{
   
    NSString * msg = @"操作成功";
    
    [UIAlert alertSingle_SmallTitle:msg agreeBtnBlock:^(UIAlertAction *action) {
            
        // 如果存在 保存回调
        if (_saveBlock) {
            _saveBlock(_requestDict);
        }
        
        // 重新请求
        [self.delegate reloadSearchName:searchName
                               EnumType:EnumType];
        
        // 回退
        [self.navigationController popViewControllerAnimated:YES];
        
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
                    _synchronousView.dataArray = self.synchronousArray;
                    [_synchronousView reloadData];
                    
                }else{
                                   
                    [self Http_Modifi];

                }
                
            }else{
                
                if ([msg containsString:@"已有光路占用"]) {
                    [YuanHUD HUDFullText:msg];
                    return;
                }
                
                [self Http_Modifi];

            }
            
        }
        
    }];
    
}


- (void) Http_ConfirmUpdateOprState:(NSDictionary *)param {
    
    [Inc_NewFL_HttpModel1 Http_ConfirmUpdateOprState:param success:^(id  _Nonnull result) {
        if (result) {
            [self Http_Modifi];
        }
        
        _windowBgView.hidden = YES;
        _synchronousView.hidden  = YES;
    }];
     
}



#pragma mark -zzc  btnClick

//需要点击背景隐藏 打开
-(void)tapEvent:(UITapGestureRecognizer *)gesture {
    _windowBgView.hidden = YES;
    // _synchronousView.hidden  = YES;
}

- (void)sureBtnClick {
    
    // state  1  列表显示的全部修改   2 只修改当前
    NSDictionary *parm = @{
            @"gid":_requestDict[@"gid"],
            @"resType":@"pair",
            @"oprStateId":_requestDict[@"oprStateId"],
            @"status":@"1",
            @"optPairRouterList":_httpSynchronousArray
        };
   
    
    [self Http_ConfirmUpdateOprState:parm];
}

- (void)cancelBtnClick {
    _windowBgView.hidden = YES;
    // _synchronousView.hidden  = YES;
}


#pragma mark - 导航栏与右侧按钮 ---

// 右侧导航栏
- (void) naviBarSet {
    
    // 导航栏右侧按钮
    
    UIBarButtonItem * rightBarBtn =
    [UIView getBarButtonItemWithImageName:@"icon_pplist_gongneng"
                                      Sel:@selector(rightBarBtnClick)
                                       VC:self];
    
    self.navigationItem.rightBarButtonItems = @[rightBarBtn];
    
}

// 点击事件
- (void) rightBarBtnClick {
    
    [self.menu showMenuEnterAnimation:MLAnimationStyleTop];
}


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
                               WithTitles:[_pushVM MenuTitleArr]
                           WithImageNames:nil
                    WithMenuViewOffsetTop:NaviBarHeight
                   WithTriangleOffsetLeft:menuWidth - 10
                            triangleColor:UIColor.whiteColor
                               cellHeight:Vertical(45)];
        
        
        _menu = menuView;
        
        menuView.separatorOffSet = 0;
        menuView.separatorColor = [UIColor colorWithHexString:@"#eee"];
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
    
    [_pushVM MenuSelectorIndex:index];
}



@end

