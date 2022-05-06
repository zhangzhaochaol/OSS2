//
//  Yuan_NewFL_LinkVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_LinkVC.h"

#import "Yuan_NewFL_RouteVC.h"
#import "Yuan_NewFL_SearchListVC.h"     // 搜索局向列表
#import "Yuan_NewFL_ConfigVC.h"         // 端子纤芯配置页面
#import "Inc_NewFL_GisVC.h"             // Gis地图
#import "Yuan_NewFL3_AlertDecayVC.h"    // 纤芯衰耗分解

#import "Yuan_NewFL2_RouteSelectList.h" // 根据设备id 查询同设备的局向光纤

#import "Yuan_FL_HeaderView.h"          //头视图
#import "Yuan_FL_LinkChooseView.h"      //光链路切换
#import "Yuan_FL_IntervalView.h"        //分割线
#import "Yuan_NewFL2_InsertWindow.h"    //选择插入的类型


#import "Yuan_NewFL_LinkCell.h"         //端子纤芯cell
#import "Yuan_NewFL_DT_RouteCell.h"     //局向光纤cell


// 选择设备
#import "Yuan_NewFL_ChooseDeviceView.h"
// 选择光缆段
#import "Yuan_NewFL_ChooseCableView.h"
// 选择接入方式
#import "Yuan_NewFL_ChooseAddTypeView.h"


// Http请求
#import "Yuan_NewFL_HttpModel.h"
#import "Yuan_CF_HttpModel.h"       // 根据id 查光缆段
// VM
#import "Yuan_NewFL_VM.h"
// 二期专用的业务判断逻辑处理
#import "Inc_NewFL_SecVM.h"

// push
#import "Inc_Push_MB.h"



@interface Yuan_NewFL_LinkVC () <UITableViewDelegate , UITableViewDataSource>

/** 头视图 */
@property (nonatomic,strong) Yuan_FL_HeaderView *headerView;

/** 光链路切换 */
@property (nonatomic,strong) Yuan_FL_LinkChooseView *linkChooseView;

/** 分割线 */
@property (nonatomic,strong) Yuan_FL_IntervalView *intervalView;

/** tableView */
@property (nonatomic , strong) UITableView * tableView;

/** 添加路由按钮 */
@property (nonatomic , strong) UIButton * AddRouteBtn;

/** 添加局向光纤 */
@property (nonatomic , strong) UIButton * Add_JXFiberBtn;

/** 选择设备 */
@property (nonatomic , strong) Yuan_NewFL_ChooseDeviceView * chooseDeviceView;

/** 选择光缆段 */
@property (nonatomic , strong) Yuan_NewFL_ChooseCableView * chooseCableView;

/** 选择接入方式 成端还是熔接*/
@property (nonatomic , strong) Yuan_NewFL_ChooseAddTypeView * chooseAddTypeView;

/** 衰耗分解按钮 */
@property (nonatomic , strong) UIButton * decayBtn;

@end

@implementation Yuan_NewFL_LinkVC

{

    // 下一步需要做什么  enum
    NewFL_LinkState_ _linkState;
    
    // 光路ID
    NSString * _Id;
    
    NSDictionary * _httpSelectDict;
    
    // 路由中 最后一个节点的map -- 以链路1为标准
    NSDictionary * _lastEptDict;
    NSString * _lastEptType;
    
    // 一条或两条光链路的数据
    NSArray * _linkArr;
    NSArray * _tableViewShowDataArray;
    
    Yuan_NewFL_VM * _VM;
    Inc_NewFL_SecVM * _VM_Sec;
    
    // **** ***  在展示成端熔接小弹框时使用
    
    // 当前 选中的光缆段的map
    NSDictionary * _nowSelectCableDict;
    // 选中的光缆段 对端是什么设备 ?
    NSDictionary * _http_V2Post_GetDeviceDict;
    
    NSString * _linkId_A;
    NSString * _linkId_B;
    
    // 左滑操作的行的 index.row
    NSInteger _leftScroll_ConfigIndex;
    NSDictionary * _leftScroll_ConfigCellDict;
    
    
    
    // 新的初始化构造方法 , 通过端子Id 查询所在的
    BOOL _isNewInitMethod;
    
    NSIndexPath * _links2_InsertIndex;
    // 左滑点击插入后 , 从第一个节点到当前节点的新数据源
    NSArray * _links2_InsertNewRouteData;
}



#pragma mark - 初始化构造方法

- (instancetype)initFromTerminalId_SelectFiberLinkDatas:(NSDictionary *) fiberLinkDicts {
    
    if (self = [super init]) {
        _isNewInitMethod = YES;
        _httpSelectDict = fiberLinkDicts;
    }
    return self;
}


/// 2期构造方法 - 根据光链路id 查询 光链路 , 但会组合成光路查看
- (instancetype)initFromLinkDatas:(NSDictionary *) fiberLinkDicts {
    
    
    if (self = [super init]) {
        
        _isNewInitMethod = YES;
        
        NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:fiberLinkDicts];
        
        mt_Dict[@"optRoadId"] = @"";
        mt_Dict[@"optRoadName"] = @"光链路";
        mt_Dict[@"optPairNum"] = @"1";
        
        
        _httpSelectDict = mt_Dict;
    }
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"光纤光路";

    if (_MB_Dict) {
        _Id = _MB_Dict[@"GID"];
    }
    
    _VM = Yuan_NewFL_VM.shareInstance;
    // 清空数据
    [_VM clean_LinkChooseData];
    
    _VM.isDoubleLinks_NotBothLength = NO;
    
    // 初始化时 , 是无任何状态的
    _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseDevice;
    
    _VM_Sec = Inc_NewFL_SecVM.shareInstance;
    _VM.insertMode = NewFL2_InsertMode_None;
    
    #if DEBUG
    // 测试环境下 才有清空按钮
        [self naviBarSet];
    #endif
    
    
    
    [self UI_Init];
    [self block_Init];
    
    if (!_isNewInitMethod) {
        
        [self Http_SelectFromLinkId];
    }
    
    else {
        
        _AddRouteBtn.hidden = YES;
        _Add_JXFiberBtn.hidden = YES;
        
        [self clearResultDatas:_httpSelectDict];
    }
    
    
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(refreshSelect)
//                                                 name:HttpSuccess_Error_Info_Notification
//                                               object:nil];
    
}


#pragma mark - Http ---


- (void) refreshSelect {
    
    [self Http_SelectFromLinkId];
}


- (void) clean {
    
    
    
    [Yuan_NewFL_HttpModel Http_ClearLinkId:_linkId_A
                                       IdB:_linkId_B
                                   success:^(id  _Nonnull result) {
        Pop(self);
    }];
}

//MARK: 一进来 查询光路下属路由
- (void) Http_SelectFromLinkId {

    [Yuan_NewFL_HttpModel Http_SelectLinkFromId:_Id
                                        success:^(id  _Nonnull result) {
            
        _httpSelectDict = result;
        
        [self clearResultDatas:_httpSelectDict];
    }];
    
}



/// 抽离处理的数据抽离方法
- (void) clearResultDatas : (NSDictionary *) dict {
    
    // 光路内 光链路的个数
    NSArray * linkArr = dict[@"optPairLinkList"];
    NSString * optPairNum = [Yuan_Foundation fromInteger:linkArr.count];
    
    
    if (!linkArr || linkArr.count == 0) {
        
        [self btnHidden];
        
        [UIAlert alertSmallTitle:@"尚未初始化光链路,是否初始化?"
                   agreeBtnBlock:^(UIAlertAction *action) {
                            
            [self http_CreateLinks];
        }];
        return;
    }
    
    if (optPairNum.intValue != linkArr.count) {
        
        // 未初始化光链路 , 去初始化光链路
        if (!linkArr || linkArr.count == 0) {
            
            [UIAlert alertSmallTitle:@"尚未初始化光链路,是否初始化?"
                       agreeBtnBlock:^(UIAlertAction *action) {
                                
                [self http_CreateLinks];
            }];
            
            return;
        }
        
        
        if (linkArr.count != optPairNum.intValue) {
            
            [self btnHidden];
            return;
        }
        
        
    }
     
    
    if (linkArr.count == 1) {
        NSDictionary * dict = linkArr.firstObject;
        _linkId_A = dict[@"linkId"];
        
        _VM.nowLinkId = _linkId_A;
        _VM.now_LinkNum = 1;
        _VM.nowLinkRouters = dict[@"optPairRouterList"];
        // 配置倒叙光链路数组
        _VM.nowLinkRouters_flashback = [_VM configNowLinkRouters_flashback];
    }
    else {
        
        NSDictionary * dict_A = linkArr.firstObject;
        NSDictionary * dict_B = linkArr.lastObject;
        
        _linkId_A = dict_A[@"linkId"];
        _linkId_B = dict_B[@"linkId"];
        
        _VM.nowLinkId = _linkId_A;
        _VM.now_LinkNum = 1;
        _VM.nowLinkRouters = dict_A[@"optPairRouterList"];
        // 配置倒叙光链路数组
        _VM.nowLinkRouters_flashback = [_VM configNowLinkRouters_flashback];
    }
    
    // 默认选择第一个
    [_linkChooseView NewFL_ReloadLink:linkArr nowSelectIndex:1];
    
    [_headerView reloadResName:dict[@"optRoadName"]];
    [_headerView reloadHeaderName:@"光纤光路"];
    
    
    // 数据抽离处理
    [self cleanSelectData:dict];
    
}





#pragma mark - 数据拆分抽离 -- 所有新增的数据的最终处理 ---
- (void) cleanSelectData:(NSDictionary *) dict {
    
    // 外界发过来的 也会跟着改变
    _httpSelectDict = dict;
    
    // 光路路由的详细信息 , 单链时 linkArr里有一个元素 双链两个元素
    _linkArr = dict[@"optPairLinkList"];
    
    // 默认选择第一个  nowSelectIndex 1 或 2  ** 初始化链路选择选项卡
    [_linkChooseView NewFL_ReloadLink:_linkArr nowSelectIndex:1];
    
    [_headerView reloadResName:dict[@"optRoadName"]];
    [_headerView reloadHeaderName:@"光纤光路"];
    
    
    NSDictionary * firstLinkRouteDict = _linkArr.firstObject;
    
    // 拿到第一条光链路的路由数据
    NSArray * optPairRouterList = firstLinkRouteDict[@"optPairRouterList"];
    
    if (!optPairRouterList || optPairRouterList.count == 0) {
        
        _tableViewShowDataArray = optPairRouterList;
        [_tableView reloadData];
        _VM.isEmptyLink = YES;
        
        
        _lastEptDict = nil;
        _lastEptType = nil;
        
        return;
    }
    
    // 非空
    _VM.isEmptyLink = NO;
    
    _tableViewShowDataArray = optPairRouterList;
    
    /// 2021.10 新增判断 -- 验证有没有可以组合成为局向光纤的数据
    [self NewFL2_CheckComboRoutersToNewRoute];
    
    // 验证后 再来刷新数据
    [_tableView reloadData];
    
    
    // 证明是双路  , 判断链路1 和 链路2 长度是否一致
    if (_linkArr.count == 2) {
        
        NSDictionary * firstLinkRouteDict = _linkArr.firstObject;
        NSDictionary * secondLinkRouteDict = _linkArr.lastObject;
        
        NSArray * fir_OptPairRouterList = firstLinkRouteDict[@"optPairRouterList"];
        NSArray * sec_OptPairRouterList = secondLinkRouteDict[@"optPairRouterList"];
        
        if (fir_OptPairRouterList.count != sec_OptPairRouterList.count) {
//            [YuanHUD HUDFullText:@"两条光链路长度不同,数据错误 , 但可以继续编辑"];
            _VM.isDoubleLinks_NotBothLength = YES;
        }
        
        
        
    }
    
    // 得到最后一个节点
    _lastEptDict = optPairRouterList.lastObject;
    _lastEptType = _lastEptDict[@"eptTypeId"];
    
    // 先置位false , 当最后一个是纤芯时 , 置位 true , 当再选择一个纤芯时 , 在接口中告诉两根纤芯需要进行熔接
    _VM.isNeedRongJ = false;
    

    
    // 只有一个元素的时候 ,  是局向或者端子
    if (optPairRouterList.count < 2) {
        
        // 只有一个 如果 他是端子  下一步 查光缆段 不需要去重
        if ([_lastEptType isEqualToString:@"317"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType;
        }
        
        // 只有一个 如果 他是局向 下一步 根据局向最后一个端子 , 查新端子 , 拼入路由中
        else if ([_lastEptType isEqualToString:@"731"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseJuXiangLastEptTerminal;
        }
        
        // 是其他 那就有问题了
        else {
            [YuanHUD HUDFullText:@"路由数据错误 , 第一个数据不可以为纤芯 , 请删除后再操作"];
            _VM.nowLinkState = NewFL_LinkState_ChooseError;
        }
        
    }
    
    
    // 如果路由数据 大于2
    else {
        
        // 倒数第二个是啥
        NSDictionary * last2Dict = optPairRouterList[optPairRouterList.count - 2];
        NSString * last2Type = last2Dict[@"eptTypeId"];
        
        // 最后一个是纤芯 , 那么他还是去根据光缆段终止设备 查关联光缆段 并且去重
        if ([_lastEptType isEqualToString:@"702"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseCable_Repeat;
            _VM.isNeedRongJ = true;
        }
        
        // 最后一个是局向 , 那么根据局向的最后一位 , 查新端子
        else if ([_lastEptType isEqualToString:@"731"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseJuXiangLastEptTerminal;
        }
        
        //TODO: 最后两个都是端子 , 那么 会根据最后一位 ,选择光缆段  (只有1期有这个判断 , 二期时不会出现这个情况)
        // 根据最后一个设备 , 选择光缆段
        else if ([_lastEptType isEqualToString:@"317"] && [last2Type isEqualToString:@"317"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType;
        }
        
        //TODO: 倒数第二个是纤芯 ,最后一个是端子 , 理论上的闭合局向  (只有1期有这个判断 , 二期时不会出现这个情况)
        // 根据最后一个端子的设备 , 再选择一个端子作为新局向的起点
        else if ([_lastEptType isEqualToString:@"317"] && [last2Type isEqualToString:@"702"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseTerminalFromLastDevice;
        }
        
        // 倒数第二个是局向 , 最后一个是端子 . 根据端子设备 选择光缆段
        else if ([_lastEptType isEqualToString:@"317"] && [last2Type isEqualToString:@"731"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType;
        }
        
        else {
            // 二期不需要此判断

        }
    }
}

/// 当切换链路 1, 2 选项卡时 , 对数据进行重新配置 , 只有在 双链并且不同长度时进入该判断
- (void) remakeSelectConfigDatas {
    
    // 选择的光链路
    NSDictionary * linkRouteDict;
    
    if (_VM.now_LinkNum == 1) {
        linkRouteDict = _linkArr.firstObject;
    }
    else {
        linkRouteDict = _linkArr.lastObject;
    }
    
    
    
    // 拿到第一条光链路的路由数据
    NSArray * optPairRouterList = linkRouteDict[@"optPairRouterList"];
    
    if (!optPairRouterList || optPairRouterList.count == 0) {
        
        _VM.isEmptyLink = YES;
        return;
    }
    
    // 非空
    _VM.isEmptyLink = NO;
    
    _tableViewShowDataArray = optPairRouterList;
    
    /// 2021.10 新增判断 -- 验证有没有可以组合成为局向光纤的数据
    [self NewFL2_CheckComboRoutersToNewRoute];
    
    // 验证后 再来刷新数据
    [_tableView reloadData];
    
    
    // 得到最后一个节点
    _lastEptDict = optPairRouterList.lastObject;
    _lastEptType = _lastEptDict[@"eptTypeId"];
    
    // 先置位false , 当最后一个是纤芯时 , 置位 true , 当再选择一个纤芯时 , 在接口中告诉两根纤芯需要进行熔接
    _VM.isNeedRongJ = false;
    

    
    // 只有一个元素的时候 ,  是局向或者端子
    if (optPairRouterList.count < 2) {
        
        // 只有一个 如果 他是端子  下一步 查光缆段 不需要去重
        if ([_lastEptType isEqualToString:@"317"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType;
        }
        
        // 只有一个 如果 他是局向 下一步 根据局向最后一个端子 , 查新端子 , 拼入路由中
        else if ([_lastEptType isEqualToString:@"731"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseJuXiangLastEptTerminal;
        }
        
        // 是其他 那就有问题了
        else {
            [YuanHUD HUDFullText:@"路由数据错误 , 第一个数据不可以为纤芯 , 请删除后再操作"];
            _VM.nowLinkState = NewFL_LinkState_ChooseError;
        }
        
    }
    
    
    // 如果路由数据 大于2
    else {
        
        // 倒数第二个是啥
        NSDictionary * last2Dict = optPairRouterList[optPairRouterList.count - 2];
        NSString * last2Type = last2Dict[@"eptTypeId"];
        
        // 最后一个是纤芯 , 那么他还是去根据光缆段终止设备 查关联光缆段 并且去重
        if ([_lastEptType isEqualToString:@"702"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseCable_Repeat;
            _VM.isNeedRongJ = true;
        }
        
        // 最后一个是局向 , 那么根据局向的最后一位 , 查新端子
        else if ([_lastEptType isEqualToString:@"731"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseJuXiangLastEptTerminal;
        }
        
        //TODO: 最后两个都是端子 , 那么 会根据最后一位 ,选择光缆段  (只有1期有这个判断 , 二期时不会出现这个情况)
        // 根据最后一个设备 , 选择光缆段
        else if ([_lastEptType isEqualToString:@"317"] && [last2Type isEqualToString:@"317"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType;
        }
        
        //TODO: 倒数第二个是纤芯 ,最后一个是端子 , 理论上的闭合局向  (只有1期有这个判断 , 二期时不会出现这个情况)
        // 根据最后一个端子的设备 , 再选择一个端子作为新局向的起点
        else if ([_lastEptType isEqualToString:@"317"] && [last2Type isEqualToString:@"702"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseTerminalFromLastDevice;
        }
        
        // 倒数第二个是局向 , 最后一个是端子 . 根据端子设备 选择光缆段
        else if ([_lastEptType isEqualToString:@"317"] && [last2Type isEqualToString:@"731"]) {
            _VM.nowLinkState = _linkState = NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType;
        }
        
        else {

        }
    }
    
}



// 初始化光链路  成功后再调一遍查询接口
- (void) http_CreateLinks {
    
    [Yuan_NewFL_HttpModel Http_CreateLinesFromLinkId:_Id
                                             success:^(id  _Nonnull result) {
//        [self Http_SelectFromLinkId];
        Pop(self);
        [YuanHUD HUDFullText:@"初始化完成"];
    }];
}


#pragma mark - 2期 Http请求 ---

- (void) http_ComboRouteFromDatas:(NSArray *) datas {
    
    NSMutableArray * postDatas = NSMutableArray.array;
    
    for (NSDictionary * singleDatas in datas) {
        
        NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:singleDatas];
        mt_Dict[@"linkId"] = _VM.nowLinkId;
        mt_Dict[@"sequence"] = singleDatas[@"oldSequence"];
        
        [postDatas addObject:mt_Dict];
    }
    
    
    [Yuan_NewFL_HttpModel Http2_ComboRouteFromComboArr:postDatas
                                               success:^(id  _Nonnull result) {
        [self refreshSelect];
    }];
    
}


/// 路由节点的更换
- (void) http_ExchangeRouter:(NSDictionary *) nowRouterDict {
    
    //  资源类型
    NSString * eptTypeId = nowRouterDict[@"eptTypeId"];
    
    // 父资源相关
    NSString * relateResTypeId = nowRouterDict[@"relateResTypeId"];
    NSString * relateResId = nowRouterDict[@"relateResId"];
    
    // 局向光纤
    if ([eptTypeId isEqualToString:@"731"]) {
        
        NSArray * optLogicRouteList = nowRouterDict[@"optLogicRouteList"];
        
        if (optLogicRouteList.count == 0) {
            [YuanHUD HUDFullText:@"当前局向光纤无下属节点 , 无法进行向下插入"];
            return;
        }
        
        NSDictionary * firstDict = optLogicRouteList.firstObject;
        NSDictionary * lastDict = optLogicRouteList.lastObject;
        
        if (![firstDict[@"nodeTypeId"] isEqualToString:@"317"] ||
            ![lastDict[@"nodeTypeId"] isEqualToString:@"317"]) {
            
            [YuanHUD HUDFullText:@"当前局向光纤数据错误 , 无法进行替换"];
            return;
        }
        
        
        
        Yuan_NewFL2_RouteSelectList * routeList =
        [[Yuan_NewFL2_RouteSelectList alloc] initWithEqpIdA:firstDict[@"rootId"]
                                                 eqpTypeIdA:firstDict[@"rootTypeId"]
                                                     eqpIdZ:lastDict[@"rootId"]
                                                 eqpTypeIdZ:lastDict[@"rootTypeId"]];
        
        NSMutableArray * idsArr = NSMutableArray.array;
        
        for (NSDictionary * dict in _VM.nowLinkRouters) {
            
            NSString * eptId = dict[@"eptId"];
            NSString * eptTypeId = dict[@"eptTypeId"];
            
            if ([eptTypeId isEqualToString:@"731"]) {
                [idsArr addObject:eptId];
            }
            
        }
        
        routeList.filterIdsArr = idsArr;
        routeList.isExchangeMode = YES;
        
        // 选取了局向光纤并存入路由后的回调 , 刷新界面
        routeList.selectRouteBlock = ^(NSDictionary * _Nonnull routeDict) {
            [self refreshSelect];
        };
        
        routeList.needExchangeDict = nowRouterDict;
        
        Push(self, routeList);
        
    }
    
    // 设备或者光缆段
    else {
        
        [self Links2_ChooseSuperDeviceOrCableFromDeviceId:relateResId
                                        deviceType:relateResTypeId
                                           success:^(id result) {
            
            NewFL_ConfigType_ type = NewFL_ConfigType_Device;
            
            // 光缆段
            if ([relateResTypeId isEqualToString:@"701"]) {
                
                type = NewFL_ConfigType_Cable;
            }
            
            [self Yuan_NewFL_ConfigVC_Push:type
                                      dict:result
                           isExchangeRoute:YES];
        }];
    }
}



/// 光链路路由 , 局向光纤路由节点的删除
- (void) http_DeleteRouterInLinkOrRoute:(NSDictionary *) nowRouterDict {
    
    NSMutableDictionary * swapTerm = NSMutableDictionary.dictionary;
    
    // 局向光纤
    if ([nowRouterDict.allKeys containsObject:belongRouteId]) {
     
        swapTerm[@"termId"] = nowRouterDict[@"eptId"] ?: @"";
        swapTerm[@"linkId"] = nowRouterDict[belongRouteId] ?: @"";
        
        NSDictionary * belongRouteDict ;
        
        for (NSDictionary * cellDict in _tableViewShowDataArray) {
            
            if ([cellDict[@"eptId"] isEqualToString:nowRouterDict[belongRouteId]]) {
                belongRouteDict = cellDict;
                break;
            }
        }
        
        if (!belongRouteDict) {
            [YuanHUD HUDFullText:@"未找到局向光纤"];
            return;
        }
        
        
        NSMutableArray * mt_Arr = NSMutableArray.array;
        
        for (NSDictionary * singleDict in belongRouteDict[@"optLogicRouteList"]) {
            
            NSMutableDictionary * newDict = [NSMutableDictionary dictionaryWithDictionary:singleDict];
            
            newDict[@"eptId"] = newDict[@"nodeId"];
            newDict[@"eptName"] = newDict[@"nodeName"];
            newDict[@"eptTypeId"] = newDict[@"nodeTypeId"];
            
            // relateRes root
            newDict[@"relateResId"] = newDict[@"rootId"];
            newDict[@"relateResName"] = newDict[@"rootName"];
            newDict[@"relateResTypeId"] = newDict[@"rootTypeId"];
            
            [mt_Arr addObject:newDict];
            
        }
        
        swapTerm[@"route"] = mt_Arr;
        
        [Yuan_NewFL_HttpModel Http2_DeleteRouterPoint:swapTerm
                                               isLink:NO
                                              success:^(id  _Nonnull result) {
            [self refreshSelect];
        }];
        
    }
    
    // 光链路
    else {
        
        swapTerm[@"termId"] = nowRouterDict[@"eptId"] ?: @"";
        swapTerm[@"linkId"] = _VM.nowLinkId;
        swapTerm[@"route"] = _VM.nowLinkRouters;
        
        [Yuan_NewFL_HttpModel Http2_DeleteRouterPoint:swapTerm
                                               isLink:YES
                                              success:^(id  _Nonnull result) {
            
            [self refreshSelect];
        }];
    }
}






#pragma mark - delegate ---

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tableViewShowDataArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    NSDictionary * cellDict = _tableViewShowDataArray[indexPath.row];
    
    //Yuan_NewFL_DT_RouteCell
    
    NSString * eptTypeId = cellDict[@"eptTypeId"];
    
    
    // 局向光纤
    if ([eptTypeId isEqualToString:@"731"]) {
        
        Yuan_NewFL_DT_RouteCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_NewFL_DT_RouteCell"];
        
        if (!cell) {
            
            cell = [[Yuan_NewFL_DT_RouteCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:@"Yuan_NewFL_DT_RouteCell"];
            
        }
        
        cell.selectionStyle = 0;
        
        [cell cellDict:cellDict];
        
        
        return cell;
        
    }
    
    // 端子和纤芯
    else {
        
        Yuan_NewFL_LinkCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_NewFL_LinkCell"];
        
        
        if (!cell) {
            cell = [[Yuan_NewFL_LinkCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"Yuan_NewFL_LinkCell"];
        }
        
        cell.selectionStyle = 0;
        
        [cell cellDict:cellDict];
        
        return cell;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSDictionary * cellDict = _tableViewShowDataArray[indexPath.row];
    
    //Yuan_NewFL_DT_RouteCell
    
    NSString * eptTypeId = cellDict[@"eptTypeId"];
    
    if ([eptTypeId isEqualToString:@"731"]) {
        return Vertical(50);
    }
    
    
    NSString * eptName = cellDict[@"eptName"];
    NSString * relateResName = cellDict[@"relateResName"];
    
    
    NSInteger length = eptName.length + relateResName.length;
    
    if (length <= 50) {
        return Vertical(90);
    }
    
    else if (length > 50 && length <= 80) {
        return Vertical(150);
    }
    else {
        return Vertical(200);
    }
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (!Yuan_NewFL_VM.isNew_2021) {
//        return;
//    }
    
    NSDictionary * cellDict = _tableViewShowDataArray[indexPath.row];
    
    //Yuan_NewFL_DT_RouteCell
    
    NSString * eptTypeId = cellDict[@"eptTypeId"];
    
    // 当点击局向光纤时 , 展开局向光纤
    if ([eptTypeId isEqualToString:@"731"]) {
        
        if ([cellDict[@"localCreate"] isEqualToString:@"1"]) {
            
            [UIAlert alertSmallTitle:@"是否生成局向光纤?"
                       agreeBtnBlock:^(UIAlertAction *action) {
                
                NSArray * optLogicRouteList = cellDict[@"optLogicRouteList"];
                
                // 发起生成局向光纤的请求
                [self http_ComboRouteFromDatas:optLogicRouteList];
            }];
            
            return;
        }
        
        
        // 未展开的
        if (![cellDict.allKeys containsObject:@"isOpen"] ||
            [cellDict[@"isOpen"] isEqualToString:@"0"]) {
            
            NSArray * juX_SubRouteList = cellDict[@"optLogicRouteList"];
            NSMutableArray * reset_JuXRouteList = [NSMutableArray array];
            
            for (NSDictionary * singleRoute in juX_SubRouteList) {
                
                NSMutableDictionary * newDict = [NSMutableDictionary dictionaryWithDictionary:singleRoute];
                
                newDict[belongRouteId] = cellDict[@"eptId"];
                
                newDict[@"eptId"] = newDict[@"nodeId"];
                newDict[@"eptName"] = newDict[@"nodeName"];
                newDict[@"eptTypeId"] = newDict[@"nodeTypeId"];
                
                // relateRes root
                newDict[@"relateResId"] = newDict[@"rootId"];
                newDict[@"relateResName"] = newDict[@"rootName"];
                newDict[@"relateResTypeId"] = newDict[@"rootTypeId"];
                
                [reset_JuXRouteList addObject:newDict];
            }
            
            NSMutableArray * newShowDataArray = [NSMutableArray arrayWithArray:_tableViewShowDataArray];
            
            NSRange range = NSMakeRange(indexPath.row + 1, reset_JuXRouteList.count);
            NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [newShowDataArray insertObjects:reset_JuXRouteList atIndexes:indexSet];
            
            
            NSMutableDictionary * mt_CellDict = [NSMutableDictionary dictionaryWithDictionary:cellDict];
            mt_CellDict[@"isOpen"] = @"1";
            
            [newShowDataArray replaceObjectAtIndex:indexPath.row withObject:mt_CellDict];
            
            _tableViewShowDataArray = newShowDataArray;
            [_tableView reloadData];
        }
        
        // 已展开的
        if ([cellDict[@"isOpen"] isEqualToString:@"1"])  {
            
            
            NSMutableArray * reset_JuXRouteList = [NSMutableArray array];
            
            for (NSDictionary * singleRoute in _tableViewShowDataArray) {
                
                if ([singleRoute.allKeys containsObject:belongRouteId] && [singleRoute[belongRouteId] isEqualToString:cellDict[@"eptId"]]) {
                    continue;
                }
                
                [reset_JuXRouteList addObject:singleRoute];
            }
            
            
            NSMutableDictionary * mt_CellDict = [NSMutableDictionary dictionaryWithDictionary:cellDict];
            mt_CellDict[@"isOpen"] = @"0";
            
            [reset_JuXRouteList replaceObjectAtIndex:indexPath.row withObject:mt_CellDict];
            
            _tableViewShowDataArray = reset_JuXRouteList;
            [_tableView reloadData];
        }
        
        
    }
    
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 暂未开放时
    if (!Yuan_NewFL_VM.isNew_2021) {
        return @[];
    }
    
    
    NSDictionary * cellDict = _tableViewShowDataArray[indexPath.row];
    
    _leftScroll_ConfigIndex = indexPath.row;
    _leftScroll_ConfigCellDict = cellDict;

    
    // 如果有这个字段 , 证明是虚拟的局向光纤 , 不允许左滑
    if ([cellDict.allKeys containsObject:@"oldSequence"] ||
        [cellDict.allKeys containsObject:@"localCreate"] ) {
        
        return @[];
    }
    
    
    
    UITableViewRowAction * upInsert =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                       title:@"向上插入"
                                     handler:^(UITableViewRowAction * _Nonnull action,
                                               NSIndexPath * _Nonnull indexPath) {
        
        [UIAlert alertSmallTitle:@"是否向上插入路由节点"
                   agreeBtnBlock:^(UIAlertAction *action) {
            
            _VM.insertMode = NewFL2_InsertMode_Up;
            [self upInsert_BussinessConfig:indexPath
                                  cellDict:cellDict];
        }];

    }];

    

    
    UITableViewRowAction * downInsert =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                       title:@"向下插入"
                                     handler:^(UITableViewRowAction * _Nonnull action,
                                               NSIndexPath * _Nonnull indexPath) {

        [UIAlert alertSmallTitle:@"是否向下插入路由节点"
                   agreeBtnBlock:^(UIAlertAction *action) {
            
            _VM.insertMode = NewFL2_InsertMode_Down;
            
            [self downInsert_BussinessConfig:indexPath
                                    cellDict:cellDict];
        }];
        
    }];
    
    
    UITableViewRowAction * exchangeRouter =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                       title:@"更换节点"
                                     handler:^(UITableViewRowAction * _Nonnull action,
                                               NSIndexPath * _Nonnull indexPath) {

        [UIAlert alertSmallTitle:@"是否更换路由节点"
                   agreeBtnBlock:^(UIAlertAction *action) {
            
            [self http_ExchangeRouter:cellDict];
        }];
        
    }];
    
    upInsert.backgroundColor = downInsert.backgroundColor = exchangeRouter.backgroundColor = ColorValue_RGB(0xFFAA23);
    
    
    UITableViewRowAction * deleteRouter =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                       title:@"移除"
                                     handler:^(UITableViewRowAction * _Nonnull action,
                                               NSIndexPath * _Nonnull indexPath) {

        
        [UIAlert alertSmallTitle:@"是否移除路由节点"
                   agreeBtnBlock:^(UIAlertAction *action) {
            
            [self http_DeleteRouterInLinkOrRoute:cellDict];
        }];
    }];
    
    deleteRouter.backgroundColor = ColorValue_RGB(0xE46262);
    
    
    // 从查看所在链路进入的 , 只显示移除一个按钮
    if (_isNewInitMethod) {
        return @[deleteRouter];
    }
    
    // 第一行可以允许向上添加
    if (indexPath.row == 0) {
        return @[deleteRouter,exchangeRouter,downInsert,upInsert];
    }
  
    
    return @[deleteRouter,exchangeRouter,downInsert];
}


#pragma mark -  block_Init  ---

- (void) block_Init {
    
    __typeof(self)wself = self;
    
    wself->_linkChooseView.chooseId_Block = ^(NSString * _Nonnull linkId, int now_LinkNum) {
      
        NSArray * copyLinkArr = _linkArr;
        
        // 切换光路
        NSLog(@"ID --- %@",linkId);
        
        for (NSDictionary * dict in copyLinkArr) {
            NSString * dict_LinkId = dict[@"linkId"];
            
            if ([linkId isEqualToString:dict_LinkId]) {
                _tableViewShowDataArray = dict[@"optPairRouterList"];
                
                // 当前显示的光链路的Id
                _VM.nowLinkId = dict_LinkId;
                
                // 配置倒叙光链路数组
                _VM.nowLinkRouters_flashback = [_VM configNowLinkRouters_flashback];
                
                /// 2021.10 新增判断 -- 验证有没有可以组合成为局向光纤的数据
                [self NewFL2_CheckComboRoutersToNewRoute];
                
                /// 再刷新数据处理
                [_tableView reloadData];
            }
        }

        _VM.now_LinkNum = now_LinkNum;
        
        // 只有当双链 并且链路长度不同时调用
        if (_VM.isDoubleLinks_NotBothLength) {
            [self remakeSelectConfigDatas];
        }
        
    };
    
   
    
    
    // 选择设备
    _chooseDeviceView.ChooseDeviceCancelBlock = ^(ChooseDeviceType_ type) {
        [wself chooseDeviceType:type];
    };
    
    
    // 选择光缆段
    _chooseCableView.chooseCableBlock = ^(NSDictionary * _Nullable dict) {
      
        
        wself.chooseCableView.hidden = YES;

        if (!dict) {
            return;
        }
        
        // 选择光缆段
        [wself chooseCable:dict];
    };
    
    // 选择接入方式
    _chooseAddTypeView.chooseAddTypeBlock = ^(NewFL_ChooseAddType_ type) {
        [wself chooseAddType:type];
    };
    
}


- (void) chooseDeviceType:(ChooseDeviceType_) type {
    
    NSString * resLogicName = @"";
    
    switch (type) {
            
        case ChooseDeviceType_OCC:
            resLogicName = @"OCC_Equt";
            [self pushToResLogicName:resLogicName];
            break;
        
        case ChooseDeviceType_ODB:
            resLogicName = @"ODB_Equt";
            [self pushToResLogicName:resLogicName];
            break;
            
        case ChooseDeviceType_ODF:
            resLogicName = @"ODF_Equt";
            [self pushToResLogicName:resLogicName];
            break;
        
        default:
            break;
    }
    
    _chooseDeviceView.hidden = YES;
}


- (void) chooseAddType:(NewFL_ChooseAddType_) type {
    
    _chooseAddTypeView.hidden = YES;
    switch (type) {
            
        case NewFL_ChooseAddType_ChengDuan:
            // 进行成端
            [self Yuan_NewFL_ConfigVC_Push:NewFL_ConfigType_Device
                                      dict:_http_V2Post_GetDeviceDict
                           isExchangeRoute:NO];
            break;
        
        case NewFL_ChooseAddType_RongJie:
            // 进行熔接
//            [self Yuan_NewFL_ConfigVC_Push:NewFL_ConfigType_Cable dict:_nowSelectCableDict];
            
            // 根据终止设备Id 请求下属光缆段
            if (_links2_InsertIndex) {
                
                NSArray * nowRouter_Datas;
                NSArray * linkRouteArr  = [self GetLinkRouteArrFromCellDict];
                
                
                if (_VM.insertMode == NewFL2_InsertMode_Down) {
                
                    nowRouter_Datas = [linkRouteArr subarrayWithRange:NSMakeRange(0, _links2_InsertIndex.row + 1)];
                }
                else {
                    nowRouter_Datas = _VM.nowLinkRouters_flashback;
                }
                
                [self Links2_ChooseCable_IsNeedRepeat:YES DatasArr:nowRouter_Datas];
            }
            else {
                [self ChooseCable_IsNeedRepeat:YES];
            }
            
            break;
        
        default:
            break;
    }
    
}


#pragma mark - 跳转相关配置 ---

// 跳转 并获取数据
- (void) pushToResLogicName:(NSString *)resLogicName {
    
    __typeof(self)weakSelf = self;
    
    [Inc_Push_MB chooseResource_PushFrom:self
                             resLogicName:resLogicName
                                    Block:^(NSDictionary * _Nonnull dict) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(),  ^{
            
            // 跳转到端子选择界面
            [self Yuan_NewFL_ConfigVC_Push:NewFL_ConfigType_Device dict:dict isExchangeRoute:NO];
        });
        
        
    }];
}


- (void) ConfigSave_ReturnData:(id) returnData {
    
    // 清空数据
    [_VM clean_LinkChooseData];
    
    NSDictionary * returnDict = returnData;
    [self cleanSelectData:returnDict];
    
}


/// 根据最后一个端子选择同设备的跳纤关系
- (void) ChooseTerminalFromDeviceId:(NSString *) deviceId
                         deviceType:(NSString *) type{
    
    if (!deviceId || !type) {
        [YuanHUD HUDFullText:@"缺少必要的参数"];
        return;
    }
    
    // 1 - ODF 302 ,  3 - 光交接箱 occ 703 , 4 - 光分纤箱和光终端盒 odb 704
    NSString * resLogicName = @"";
    
    switch (type.integerValue) {
        case 302:
            resLogicName = @"ODF_Equt";
            break;
        
        case 703:
            resLogicName = @"OCC_Equt";
            break;
        
        case 704:
            resLogicName = @"ODB_Equt";
            break;
        default:
            break;
    }
    
    NSDictionary * postDict = @{
        @"resLogicName" : resLogicName,
        @"GID" : deviceId
    };
    
    [Http.shareInstance V2_POST:HTTP_TYK_Normal_Get dict:postDict succeed:^(id data) {
       
        NSArray * arr = data;
        if (arr.count > 0) {
            NSDictionary * dict = arr.firstObject;
            [self Yuan_NewFL_ConfigVC_Push:NewFL_ConfigType_Device dict:dict isExchangeRoute:NO];
        }
    }];
    
    
}




/// 根据最后一个端子选择同设备的跳纤关系
- (void) Links2_ChooseTerminalFromDeviceId:(NSString *) deviceId
                                deviceType:(NSString *) type {
    
    
    if (!deviceId || !type) {
        [YuanHUD HUDFullText:@"缺少必要的参数"];
        return;
    }
    
    // 1 - ODF 302 ,  3 - 光交接箱 occ 703 , 4 - 光分纤箱和光终端盒 odb 704
    NSString * resLogicName = @"";
    
    switch (type.integerValue) {
        case 302:
            resLogicName = @"ODF_Equt";
            break;
        
        case 703:
            resLogicName = @"OCC_Equt";
            break;
        
        case 704:
            resLogicName = @"ODB_Equt";
            break;
        default:
            break;
    }
    
    NSDictionary * postDict = @{
        @"resLogicName" : resLogicName,
        @"GID" : deviceId
    };
    
    [Http.shareInstance V2_POST:HTTP_TYK_Normal_Get dict:postDict succeed:^(id data) {
       
        NSArray * arr = data;
        if (arr.count > 0) {
            
            NSDictionary * dict = arr.firstObject;
            [self Yuan_NewFL_ConfigVC_Push:NewFL_ConfigType_Device
                                      dict:dict
                           isExchangeRoute:NO];
        }
    }];
    
}



/// 二期使用 , 根据 父资源id 和 父资源类型 , 获取到对应的父资源详细信息数据 , 并跳转对应的界面
- (void) Links2_ChooseSuperDeviceOrCableFromDeviceId:(NSString *) superId
                                   deviceType:(NSString *) superType
                                      success:(void(^)(id result))success {
    
    if (!superId || !superType) {
        [YuanHUD HUDFullText:@"缺少必要的参数"];
        return;
    }
    
    
    // 1 - ODF 302 ,  3 - 光交接箱 occ 703 , 4 - 光分纤箱和光终端盒 odb 704
    NSString * resLogicName = @"";
    
    switch (superType.integerValue) {
        case 302:
            resLogicName = @"ODF_Equt";
            break;
            
        case 701:
            resLogicName = @"cable";
            break;
        
        case 703:
            resLogicName = @"OCC_Equt";
            break;
        
        case 704:
            resLogicName = @"ODB_Equt";
            break;
        default:
            break;
    }
    
    NSDictionary * postDict = @{
        @"resLogicName" : resLogicName,
        @"GID" : superId
    };
    
    
    [Http.shareInstance V2_POST:HTTP_TYK_Normal_Get
                           dict:postDict
                        succeed:^(id data) {
       
        NSArray * arr = data;
        if (arr.count > 0) {
            
            NSDictionary * dict = arr.firstObject;
            
            if (success) {
                success(dict);
            }
        }
    }];
    
}



// 根据光缆段终止设备,判断 是否是成端还是熔接
- (void) checkCableEndDevice {
    
    
    NSDictionary * subLinkRouteDict = _linkArr.firstObject;
    NSArray * optPairRouterList = subLinkRouteDict[@"optPairRouterList"];
    
    
    [_VM nowSelectCableDevice:optPairRouterList
                        block:^(NSDictionary * _Nonnull dict) {
        // cableStart_Type
        // cableStart_Id
        // 1 - ODF, 2 - 光缆接头, 3 - 光交接箱, 4 - 光分纤箱和光终端盒
        NSString * cableStart_Type = dict[@"cableStart_Type"];
        if ([cableStart_Type isEqualToString:@"2"]) {
            // 接头
            [self ChooseCable_IsNeedRepeat:YES];
        }
        else {
            // 设备 弹出成端还是熔接
            
            NSString * type = cableStart_Type;
            
            NSString * resLogicName = @"";
            
            if ([type isEqualToString:@"1"]) {
                resLogicName = @"ODF_Equt";
            }
            else if ([type isEqualToString:@"3"]) {
                resLogicName = @"OCC_Equt";
            }
            else if ([type isEqualToString:@"4"]) {
                resLogicName = @"ODB_Equt";
            }
            else {
                return;
            }
            
            NSDictionary * postDict = @{
                @"resLogicName" : resLogicName,
                @"GID" : dict[@"cableStart_Id"]
            };
            
            [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Get
                                     dict:postDict
                                  succeed:^(id data) {
                        
                NSArray * arr = data;
                if (arr.count > 0) {
                    _chooseAddTypeView.hidden = NO;
                    _http_V2Post_GetDeviceDict = arr.firstObject;
                }
            }];
            
        }
        
    }];
    
}


// 根据光缆段终止设备,判断 是否是成端还是熔接 --- 二期向下插入时的判断
- (void) Links2_checkCableEndDeviceDatasArr:(NSArray *)optPairRouterList {
        
    [_VM nowSelectCableDevice:optPairRouterList
                        block:^(NSDictionary * _Nonnull dict) {
        // cableStart_Type
        // cableStart_Id
        // 1 - ODF, 2 - 光缆接头, 3 - 光交接箱, 4 - 光分纤箱和光终端盒
        NSString * cableStart_Type = dict[@"cableStart_Type"];
        if ([cableStart_Type isEqualToString:@"2"]) {
            // 接头
            [self ChooseCable_IsNeedRepeat:YES];
        }
        else {
            // 设备 弹出成端还是熔接
            
            NSString * type = cableStart_Type;
            
            NSString * resLogicName = @"";
            
            if ([type isEqualToString:@"1"]) {
                resLogicName = @"ODF_Equt";
            }
            else if ([type isEqualToString:@"3"]) {
                resLogicName = @"OCC_Equt";
            }
            else if ([type isEqualToString:@"4"]) {
                resLogicName = @"ODB_Equt";
            }
            else {
                return;
            }
            
            NSDictionary * postDict = @{
                @"resLogicName" : resLogicName,
                @"GID" : dict[@"cableStart_Id"]
            };
            
            [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Get
                                     dict:postDict
                                  succeed:^(id data) {
                        
                NSArray * arr = data;
                if (arr.count > 0) {
                    _chooseAddTypeView.hidden = NO;
                    _http_V2Post_GetDeviceDict = arr.firstObject;
                }
            }];
            
        }
        
    }];
    
}


#pragma mark - 选择光缆段相关 ---

// 预加载光缆段 *** 是否需要对光缆段列表进行去重操作
- (void) ChooseCable_IsNeedRepeat:(BOOL) needRepeat {
    
   
    NSDictionary * subLinkRouteDict ;
    
    if (_VM.isDoubleLinks_NotBothLength) {
        
        if (_VM.now_LinkNum == 1) {
            subLinkRouteDict = _linkArr.firstObject;
        }
        else {
            subLinkRouteDict = _linkArr.lastObject;
        }
        
    }
    else {
        subLinkRouteDict = _linkArr.firstObject;
    }
    
    NSArray * optPairRouterList = subLinkRouteDict[@"optPairRouterList"];
    
    // 根据路由数据 获取当前 需要请求光缆段的设备是哪个
    
    [_VM nowSelectCableDevice:optPairRouterList block:^(NSDictionary * _Nonnull dict) {
        
        NSDictionary * deviceDict = dict;
        
        if (deviceDict.count == 0) {
            [YuanHUD HUDFullText:@"未检测到可以获取光缆段列表的设备"];
            return;
        }
        
        [self getCableFromDeviceId:deviceDict[@"cableStart_Id"]
                        deviceType:deviceDict[@"cableStart_Type"]
                           isJoint:needRepeat];
    }];
}



// 加载光缆段列表
- (void) getCableFromDeviceId:(NSString *)deviceId
                   deviceType:(NSString *)deviceType
                      isJoint:(BOOL) isJoint{
    
    
    [Yuan_CF_HttpModel HttpCableStart_Type:deviceType
                                  Start_Id:deviceId
                                   success:^(NSArray * _Nonnull data) {
            
        _chooseCableView.hidden = NO;
        
        // 需要去重 , 找到需要去重的光缆段Id
        if (isJoint) {

            NSArray * arr;
            
            // 向上/向下插入时
            if (_links2_InsertIndex) {
                arr = [_VM Links2_CableList_Repeat:data
                                           linkArr:_links2_InsertNewRouteData];
            }
            
            // 正常添加时
            else {
                
                // 双链状态下
                if (_VM.isDoubleLinks_NotBothLength) {
                    arr = [_VM DoubleLinks_NotBothLength_CableList_Repeat:data
                                                                  linkArr:_linkArr];
                }
                // 善良数据
                else {
                    arr = [_VM cableList_Repeat:data
                                        linkArr:_linkArr];
                }
            }
            
            
            if (arr.count == 0 || !arr) {
            
                _chooseCableView.hidden = YES;
                [YuanHUD HUDFullText:@"无可选的光缆段"];
                return;
            }
            
            // 去重后的数据  包括 如果有局向的数据 , 那么局向内部的光缆段也要去重
            [_chooseCableView reloadData:arr];
        }
        
        else {
            [_chooseCableView reloadData:data];
        }
        
        
    }];
    
}


// 光缆段 点击事件 ***
- (void) chooseCable:(NSDictionary *)cableDict {
    
    _nowSelectCableDict = cableDict;
    
    // 如果是 以端子结尾的 , 不能再根据光缆段判断 成端还是熔接 , 必须选纤芯 , 直接跳纤芯列表
    if (_linkState == NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType) {
        // 跳转到纤芯选择界面
        [self Yuan_NewFL_ConfigVC_Push:NewFL_ConfigType_Cable dict:cableDict isExchangeRoute:NO];
        return;
    }
    
    
    NSString * cable_Sid = cableDict[@"cableStart_Id"];
    NSString * cable_Eid = cableDict[@"cableEnd_Id"];

    NSString * nowSelectDeviceId = _VM.nowSelectCableDevice_Dict[@"cableStart_Id"];
    
    NSString * type = @"";
    NSString * Id = @"";
    
    if ([cable_Sid isEqualToString:nowSelectDeviceId]) {
        type = cableDict[@"cableEnd_Type"];
        Id = cable_Eid;
    }
    else if ([cable_Eid isEqualToString:nowSelectDeviceId]) {
        type = cableDict[@"cableStart_Type"];
        Id = cable_Sid;
    }
    else {
        [YuanHUD HUDFullText:@"当前光缆段数据异常"];
        return;
    }
    
    
#warning 这个版本中 只要点击光缆段 那么必然跳转纤芯
    [self Yuan_NewFL_ConfigVC_Push:NewFL_ConfigType_Cable dict:cableDict isExchangeRoute:NO];
    
    return;
    
    // 2 是接头  直接跳转
    if ([type isEqualToString:@"2"]) {
        
        // 跳转到纤芯选择界面
        [self Yuan_NewFL_ConfigVC_Push:NewFL_ConfigType_Cable dict:cableDict isExchangeRoute:NO];
    }
    
    // 设备 -- 弹出 选择成端还是熔纤
    else {
        
        // 1 - ODF, 2 - 光缆接头, 3 - 光交接箱 occ, 4 - 光分纤箱和光终端盒 odb
        
        NSString * resLogicName = @"";
        
        if ([type isEqualToString:@"1"]) {
            resLogicName = @"ODF_Equt";
        }
        else if ([type isEqualToString:@"3"]) {
            resLogicName = @"OCC_Equt";
        }
        else if ([type isEqualToString:@"4"]) {
            resLogicName = @"ODB_Equt";
        }
        else {
            return;
        }
        
        NSDictionary * postDict = @{
            @"resLogicName" : resLogicName,
            @"GID" : Id
        };
        
        [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Get
                                 dict:postDict
                              succeed:^(id data) {
                    
            NSArray * arr = data;
            if (arr.count > 0) {
                _chooseAddTypeView.hidden = NO;
                _http_V2Post_GetDeviceDict = arr.firstObject;
            }
        }];
        
    }
    
}


// 二期光链路 向下插入时的判断,是一期的
- (void) Links2_ChooseCable_IsNeedRepeat:(BOOL) needRepeat
                                DatasArr:(NSArray *)optPairRouterList{
    
    
    // 根据路由数据 获取当前 需要请求光缆段的设备是哪个
    
    [_VM nowSelectCableDevice:optPairRouterList block:^(NSDictionary * _Nonnull dict) {
        
        NSDictionary * deviceDict = dict;
        
        if (deviceDict.count == 0) {
            [YuanHUD HUDFullText:@"未检测到可以获取光缆段列表的设备"];
            return;
        }
        
        [self getCableFromDeviceId:deviceDict[@"cableStart_Id"]
                        deviceType:deviceDict[@"cableStart_Type"]
                           isJoint:needRepeat];
    }];
}




#pragma mark -  下方两个 按钮 点击事件 ---

// 添加路由
- (void) addRouteClick {

    _links2_InsertIndex = nil;
    _VM.insertMode = NewFL2_InsertMode_None;
    
    _chooseDeviceView.hidden = YES;
    _chooseCableView.hidden = YES;
    _chooseAddTypeView.hidden = YES;
    
    switch (_linkState) {
            
        case NewFL_LinkState_ChooseDevice:
            // 选择设备 ODF ODB OCC
            _chooseDeviceView.hidden = NO;
            break;
        
        case NewFL_LinkState_ChooseCable:
            // 根据第一个设备 , 选择一条不需要去重的光缆段
            [self ChooseCable_IsNeedRepeat:NO];
            break;
        
        case NewFL_LinkState_ChooseCable_Repeat:
            // 根据最后一个路由数据 (接头 或 设备) , 查询他们的光缆段 , 需要去重
//            [self ChooseCable_IsNeedRepeat:YES];
            [self checkCableEndDevice];
            break;
            
            
        case NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType:
            // 链路中不止一个端子 , 而且以端子结尾的 , 不能再进行成端 , 必须直接跳转光缆段选择纤芯
            [self ChooseCable_IsNeedRepeat:YES];
            break;
        
        case NewFL_LinkState_ChooseJuXiangLastEptTerminal:
            // 根据局向光纤的最后一个节点的设备 , 选择一组新端子 , 作为新局向的起点
            
        {
            NSArray * optLogicRouteList = _lastEptDict[@"optLogicRouteList"];
            
            if (optLogicRouteList.count == 0) {
                [YuanHUD HUDFullText:@"路由数据错误"];
                return;
            }
            NSDictionary * la_RoouteEpt = optLogicRouteList.lastObject;
            
            if (![la_RoouteEpt[@"nodeTypeId"] isEqualToString:@"317"]) {
                
                [YuanHUD HUDFullText:@"数据错误 , 局向光纤最后一条数据不是端子"];
                return;
            }
            
            // 根据最后一个端子节点 , 选出同设备的另一对端子拼入路由中
            [self ChooseTerminalFromDeviceId:la_RoouteEpt[@"rootId"]
                                  deviceType:la_RoouteEpt[@"rootTypeId"]];
        }
            
            
            break;
        
        case NewFL_LinkState_ChooseTerminalFromLastDevice:
            // 根据最后一个端子节点 , 选出同设备的另一对端子拼入路由中
            [self ChooseTerminalFromDeviceId:_lastEptDict[@"relateResId"]
                                  deviceType:_lastEptDict[@"relateResTypeId"]];
            break;
            
        default:
            break;
    }
    
}


/// 添加局向光纤 按钮点击事件
- (void) add_JXFiberClick {
    
    _links2_InsertIndex = nil;
    
    // beginResId endResId name
    //  当链路最后一条为局向时
    if (_linkState == NewFL_LinkState_ChooseJuXiangLastEptTerminal) {
        
        NSArray * optLogicRouteList = _lastEptDict[@"optLogicRouteList"];
        
        NSDictionary * routeLastDict = optLogicRouteList.lastObject;
        
        NSString * nodeTypeId = routeLastDict[@"nodeTypeId"];
        
        if (optLogicRouteList.count == 0 || ![nodeTypeId isEqualToString:@"317"]) {
            [YuanHUD HUDFullText:@"路由数据错误"];
            return;
        }

    
        // 根据局向光纤最后一个端子所在设备 去查询局向光纤
        NSString * routeLastRootId = routeLastDict[@"rootId"];
        [self add_JXSearchRuler:@{
            @"beginResId" : routeLastRootId
        }];

    }
    
    //  当链路最后一条为端子 , 且倒数第二个位纤芯时 (一期的闭合)
    else if (_linkState == NewFL_LinkState_ChooseTerminalFromLastDevice) {
        
        NSDictionary * dict = @{
            @"beginResId":_lastEptDict[@"relateResId"]
        };
        [self add_JXSearchRuler:dict];
    }
    
    //  链路为空时
    else if (_linkState == NewFL_LinkState_ChooseDevice) {
        [self add_JXSearchRuler:nil];
    }
    
    else {
        [YuanHUD HUDFullText:@"当前状态不可以选取局向光纤"];
    }
    
}


- (void) add_JXSearchRuler:(NSDictionary *)dict {
    
    Yuan_NewFL_SearchListVC * search;
    
    if (dict) {
        
        // beginResId
        
        search = [[Yuan_NewFL_SearchListVC alloc] initWithEnterType:NewFL_EnterType_Route
                                                               dict:dict
                                                        selectBlock:^(id  _Nonnull data) {
            [self addRouteToLinks:data];
        }];
    
    }
    
    else {
        
        search = [[Yuan_NewFL_SearchListVC alloc] initWithEnterType:NewFL_EnterType_Route
                                                        selectBlock:^(id  _Nonnull data) {
            [self addRouteToLinks:data];
        }];
    }
    
    // 光路内有几条链路
    search.numberOfLinks = _VM.numberOfLink;
    Push(self, search);
}


// 保存局向光纤到
- (void) addRouteToLinks: (id) arr {
    
    
    NSArray * array = arr;
    
    if (_VM.numberOfLink == 1) {
        
        _VM.LinkA_RouteChooseDict = array.firstObject;
        
    }
    else {
        _VM.LinkA_RouteChooseDict = array.firstObject;
        _VM.LinkB_RouteChooseDict = array.lastObject;
    }
    
    // 保存局向光纤到光链路中
    NSDictionary * newPostDict = [_VM saveBusiness_Route:_httpSelectDict];
    
    [Yuan_NewFL_HttpModel Http_LinkAddEpt:newPostDict
                                  success:^(id  _Nonnull result) {
       
        [YuanHUD HUDFullText:@"局向添加成功"];
        
        [self cleanSelectData:result];
    }];
    
}



#pragma mark - 2021.10月 光链路2期 , 新函数 ---

/// 检测并校验 , 有可以生成局向光纤的路由 , 组合成一个新的局向光纤
/// 每次切换光链路 , 或者新增一条端子时 都会校验
- (void) NewFL2_CheckComboRoutersToNewRoute  {
    
    // 暂未开放
    if (!Yuan_NewFL_VM.isNew_2021) {
        return;
    }
    
    NSMutableArray * eptTypeId_Arrs = NSMutableArray.array;
    
    for (NSDictionary * cellDict in _tableViewShowDataArray) {
        
        // 当前路由节点的类型  317 端子 , 702 纤芯 , 731 局向光纤
        NSString * eptTypeId = cellDict[@"eptTypeId"];
        [eptTypeId_Arrs addObject:eptTypeId];
    }
    
    
    NSArray * canComboToRoutersArr = [_VM viewModel_ComboToRouters:eptTypeId_Arrs];
    
    // 没有可以组成局向光纤的
    if (canComboToRoutersArr.count == 0) {
        return;
    }
    
    else {
        
        
        NSMutableArray * continue_Index = NSMutableArray.array;
        // 所以局向光纤开头的index
        NSMutableDictionary * starts_Index = NSMutableDictionary.dictionary;
        for (NSDictionary * startEndDict in canComboToRoutersArr) {
            
            NSNumber * startCount = startEndDict[@"start"];
            NSNumber * endCount = startEndDict[@"end"];
            
            
            NSMutableArray * mt_Arr = NSMutableArray.array;
            
            for (int i = startCount.intValue; i <= endCount.intValue; i++) {
                [mt_Arr addObject:_tableViewShowDataArray[i]];
            }
            
            for (int i = startCount.intValue; i <= endCount.intValue; i++) {
                [continue_Index addObject:@(i)];
            }
            
            
            // 拿到局向光纤
            NSDictionary * newRouter =
            [_VM viewModel_GetNewRouterFromTerminalAndFibers:mt_Arr];
            
            starts_Index[startCount] = newRouter;
        }
        
        
        NSMutableArray * newArr = NSMutableArray.array;
        
        NSInteger index = 0;
        
        for (NSDictionary * dict in _tableViewShowDataArray) {
            
            
            if ([continue_Index containsObject:@(index)]) {
                
                // 如果是开头 那么把局向光纤注入进去
                if ([starts_Index.allKeys containsObject:@(index)]) {
                    
                    NSMutableDictionary * routerDict = [NSMutableDictionary dictionaryWithDictionary:starts_Index[@(index)]];
                    
                    routerDict[@"sequence"] = [Yuan_Foundation fromInteger:newArr.count + 1];
                    
                    [newArr addObject:routerDict];
                }
                
                index++;
                continue;
            }
            
            
            [newArr addObject:dict];
            
            index++;
        }
        
        
        NSMutableArray * openRouter_MtArr = NSMutableArray.array;
        
        for (NSDictionary * cellDict in newArr) {
            
            NSString * eptTypeId = cellDict[@"eptTypeId"];
            
            // 局向光纤
            if ([eptTypeId isEqualToString:@"731"]) {
                
                [openRouter_MtArr addObject:cellDict];
                
                NSArray * juX_SubRouteList = cellDict[@"optLogicRouteList"];
                
                for (NSDictionary * singleRoute in juX_SubRouteList) {
                    
                    NSMutableDictionary * newDict = [NSMutableDictionary dictionaryWithDictionary:singleRoute];
                    
                    newDict[belongRouteId] = cellDict[@"eptId"] ?: @"无";
                    
                    newDict[@"eptId"] = newDict[@"nodeId"];
                    newDict[@"eptName"] = newDict[@"nodeName"];
                    newDict[@"eptTypeId"] = newDict[@"nodeTypeId"];
                    
                    // relateRes root
                    newDict[@"relateResId"] = newDict[@"rootId"];
                    newDict[@"relateResName"] = newDict[@"rootName"];
                    newDict[@"relateResTypeId"] = newDict[@"rootTypeId"];
                    
                    [openRouter_MtArr addObject:newDict];
                }
                
                
            }
            
            else {
                [openRouter_MtArr addObject:cellDict];
            }
        }
        
        _tableViewShowDataArray = openRouter_MtArr;
        [_tableView reloadData];
        
    }
    
}


#pragma mark - 2期 '向上插入' 的相关判断 ---

- (void) upInsert_BussinessConfig:(NSIndexPath *) indexPath
                         cellDict:(NSDictionary *) cellDict {
    
    
    NSIndexPath * daoX_Index;
    
    NSInteger newRow = _VM.nowLinkRouters_flashback.count - 1 - indexPath.row;
    
    daoX_Index = [NSIndexPath indexPathForRow:newRow inSection:0];
    
    // 由于向下插入和向上插入的逻辑不同 , 所以是倒叙操作
    _links2_InsertIndex = daoX_Index;
    
    // cellDict 就是倒叙情况下 最后一个数据
    NSString * cellEptTypeId = cellDict[@"eptTypeId"];
    
    Yuan_NewFL2_InsertWindow * insertWindow;
    InsertWindowFromType_ Enum = InsertWindowFromType_Links;
    
    if ([cellEptTypeId isEqualToString:@"702"]) {
        Enum = InsertWindowFromType_Routes;
    }
    
    if ([cellEptTypeId isEqualToString:@"731"]) {
        
        NSArray * optLogicRouteList = cellDict[@"optLogicRouteList"];
        
        if (optLogicRouteList.count == 0) {
            [YuanHUD HUDFullText:@"当前局向光纤无下属节点 , 无法进行向上插入"];
            return;
        }
        
        // 向上插入时 , 去判断局向光纤的第一个节点 , 是不是端子
        NSDictionary * routeFirstDict = optLogicRouteList.firstObject;

        if ([routeFirstDict[@"nodeTypeId"] isEqualToString:@"317"]) {
            Enum = InsertWindowFromType_Links;
        }
        
        else {
            [YuanHUD HUDFullText:@"当前局向光纤第一个的节点不是端子, 无法向上插入"];
            return;
        }
        
    }
    
    _links2_InsertNewRouteData = _VM.nowLinkRouters_flashback;
    
    insertWindow =
    [[Yuan_NewFL2_InsertWindow alloc] initWithFrame:UIScreen.mainScreen.bounds
                                               Enum:Enum];
    
    insertWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    
    __weak Yuan_NewFL2_InsertWindow * insertCopyWindow = insertWindow;
    
    // 插入的数据类型
    insertCopyWindow.insertTypeBlock = ^(BOOL isInsertRoute) {
        
        [insertWindow removeFromSuperview];
        //  插入局向光纤
        if (isInsertRoute) {
            [self insertRoute:indexPath
                     cellDict:cellDict
                  nowLinksArr:_VM.nowLinkRouters_flashback];
        }
        //  插入单节点 端子/纤芯
        else {
            [self insertPoint:indexPath
                     cellDict:cellDict
                  nowLinksArr:_VM.nowLinkRouters_flashback];
        }
        
    };
    
    [[UIApplication sharedApplication].keyWindow addSubview:insertWindow];
    
}


#pragma mark - 2期 '向下插入' 的相关判断 ---

- (void) downInsert_BussinessConfig:(NSIndexPath *) indexPath
                           cellDict:(NSDictionary *) cellDict{
    
    _links2_InsertIndex = indexPath;
    
    // 当前选中的是否是局向光纤内部的数据?
    BOOL isInRouter = [cellDict.allKeys containsObject:belongRouteId];
    
    NSArray * nowRouter_Datas ;
    NSArray * linkRouteArr = [self GetLinkRouteArrFromCellDict];
    
    
    // 如果他是局向光纤内部的数据
    if (isInRouter) {
        
        NSString * cellEptId = cellDict[@"eptId"];
        
        NSInteger index = -1;
        
        for (NSDictionary * routeDict in linkRouteArr) {
            NSString * nodeId = routeDict[@"nodeId"];
            
            if ([nodeId isEqualToString:cellEptId]) {
                index = [linkRouteArr indexOfObject:routeDict];
                break;
            }
        }
        
        
        if (index == -1) {
            return;
        }
        
        _links2_InsertNewRouteData = nowRouter_Datas = [linkRouteArr subarrayWithRange:NSMakeRange(0, index + 1)];
        
        // 局向光纤时 , 需要对 _links2_InsertIndex 重新赋值 , 取从局向光纤内部 第0个 到当前位置的index
        _links2_InsertIndex = [NSIndexPath indexPathForRow:index inSection:0];
    }
    
    // 是光链路内部的数据 , 而非局向光纤
    else {
        _links2_InsertNewRouteData = nowRouter_Datas = [linkRouteArr subarrayWithRange:NSMakeRange(0, indexPath.row + 1)];
    }
    
    
    
    
    Yuan_NewFL2_InsertWindow * insertWindow;
    
    // 局向光纤的向下
    if ([cellDict.allKeys containsObject:belongRouteId]) {
        
        insertWindow =
        [[Yuan_NewFL2_InsertWindow alloc] initWithFrame:UIScreen.mainScreen.bounds
                                                   Enum:InsertWindowFromType_Routes];
        
    }
    
    // 光链路的向下
    else {
        
        InsertWindowFromType_ Enum = InsertWindowFromType_Links;
        
        NSString * cellEptTypeId = cellDict[@"eptTypeId"];
        
        if ([cellEptTypeId isEqualToString:@"702"]) {
            Enum = InsertWindowFromType_Routes;
        }
        
        if ([cellEptTypeId isEqualToString:@"731"]) {
            
            NSArray * optLogicRouteList = cellDict[@"optLogicRouteList"];
            
            if (optLogicRouteList.count == 0) {
                [YuanHUD HUDFullText:@"当前局向光纤无下属节点 , 无法进行向下插入"];
                return;
            }
            
            NSDictionary * routeLastDict = optLogicRouteList.lastObject;

            if ([routeLastDict[@"nodeTypeId"] isEqualToString:@"317"]) {
                Enum = InsertWindowFromType_Links;
            }
            
            else {
                [YuanHUD HUDFullText:@"当前局向光纤最后的节点不是端子, 无法向下插入"];
                return;
            }
            
        }
        
        
        
        insertWindow =
        [[Yuan_NewFL2_InsertWindow alloc] initWithFrame:UIScreen.mainScreen.bounds
                                                   Enum:Enum];
    }
    
    insertWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    
    __weak Yuan_NewFL2_InsertWindow * insertCopyWindow = insertWindow;
    
    // 插入的数据类型
    insertCopyWindow.insertTypeBlock = ^(BOOL isInsertRoute) {
        
        [insertWindow removeFromSuperview];
        //  插入局向光纤
        if (isInsertRoute) {
            [self insertRoute:indexPath cellDict:cellDict nowLinksArr:nowRouter_Datas];
        }
        //  插入单节点 端子/纤芯
        else {
            [self insertPoint:indexPath cellDict:cellDict nowLinksArr:nowRouter_Datas];
        }
        
    };
    
    [[UIApplication sharedApplication].keyWindow addSubview:insertWindow];
    
}


// 插入局向光纤
- (void) insertRoute:(NSIndexPath *)indexPath
            cellDict:(NSDictionary *)cellDict
         nowLinksArr:(NSArray *) nowRouter_Datas{
    

    NSString * eptTypeId = cellDict[@"eptTypeId"];
    
    // 所属设备Id 和 设备类型
    NSString * eqpId = @"";
    NSString * eqpTypeId = @"";
    
    // 端子 向上/向下 插入局向光纤
    if ([eptTypeId isEqualToString:@"317"]) {
        eqpId = cellDict[@"relateResId"];
        eqpTypeId = cellDict[@"relateResTypeId"];
    }
    
    // 局向光纤 向上/向下插入局向光纤
    else if ([eptTypeId isEqualToString:@"731"]) {
        
        NSArray * optLogicRouteList = cellDict[@"optLogicRouteList"];
        
        NSDictionary * lastTerminalDict = optLogicRouteList.lastObject;
        eqpId = lastTerminalDict[@"rootId"];
        eqpTypeId = lastTerminalDict[@"rootTypeId"];
    }
    
    else return;
    
    
    Yuan_NewFL2_RouteSelectList * routeList =
    [[Yuan_NewFL2_RouteSelectList alloc] initWithEqpId:eqpId
                                             eqpTypeId:eqpTypeId];
    
    
    NSMutableArray * idsArr = NSMutableArray.array;
    
    NSArray * baseArray ;
    
    if (_VM.insertMode == NewFL2_InsertMode_Up) {
        baseArray = _VM.nowLinkRouters_flashback;
    }
    
    else if (_VM.insertMode == NewFL2_InsertMode_Down) {
        baseArray = _VM.nowLinkRouters;
    }
    
    else return;
    
    
    
    for (NSDictionary * dict in baseArray) {
        
        NSString * eptId = dict[@"eptId"];
        NSString * eptTypeId = dict[@"eptTypeId"];
        
        if ([eptTypeId isEqualToString:@"731"]) {
            [idsArr addObject:eptId];
        }
        
    }
    
    routeList.filterIdsArr = idsArr;
    routeList.insertIndex = _links2_InsertIndex;
    routeList.insertBaseArray = baseArray;

    
    // 选取了局向光纤并存入路由后的回调 , 刷新界面
    routeList.selectRouteBlock = ^(NSDictionary * _Nonnull routeDict) {
        [self refreshSelect];
    };
    
    Push(self, routeList);
}


// 插入端子纤芯
- (void) insertPoint:(NSIndexPath *)indexPath
            cellDict:(NSDictionary *)cellDict
         nowLinksArr:(NSArray *) nowRouter_Datas{
    
    
    
    NSString * nowEptId = cellDict[@"eptId"];
    
    NewFL_LinkState_ businessLinkState;
    
    NSMutableArray * downInsert_CutArr = NSMutableArray.array;
    
    
     for (NSDictionary * routeDict in nowRouter_Datas) {
         
         NSString * eptId = routeDict[@"eptId"] ?: routeDict[@"nodeId"];
         
         //按顺序排序 , 如果id 不等 , 那么进行拼接 , 如果id 相等 ,那么终止循环并拼接
         if (![eptId isEqualToString:nowEptId]) {
             [downInsert_CutArr addObject:routeDict];
         }
         else {
             [downInsert_CutArr addObject:routeDict];
             break;
         }
         
         
     }
     
    //获取截取到的index部分 , 下一步应该干什么
     businessLinkState = [self UpDownInsert_StateBussinessCharge:downInsert_CutArr];
     
     if (businessLinkState == NewFL_LinkState_ChooseError) {
         return;
     }
     
    // 根据截取的数组 , 查看下一步的状态 该干什么
    [self UpDown_Insert_StateBranch:nowRouter_Datas
                       linkState:businessLinkState];
}



/// 关于 截取向下插入时 , 顺序判断的抽离方法

- (NewFL_LinkState_) UpDownInsert_StateBussinessCharge :(NSArray *) downInsert_CutArr{
    
    NewFL_LinkState_ businessLinkState;
    
    // 此时 downInsert_CutArr 里是新截取出来的数据
    // 找到光链路里 , 倒数第一个和倒数第二个 开始逻辑判断
    
    // 得到最后一个节点
    NSDictionary * lastEptDict = downInsert_CutArr.lastObject;
    NSString * lastEptType = lastEptDict[@"eptTypeId"] ?: lastEptDict[@"nodeTypeId"];
    
    // 只有一个元素的时候 ,  是局向或者端子
    if (downInsert_CutArr.count < 2) {
        
        // 只有一个 如果 他是端子  下一步 查光缆段 不需要去重
        if ([lastEptType isEqualToString:@"317"]) {
            businessLinkState = NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType;
        }
        
        // 只有一个 如果 他是局向 下一步 根据局向最后一个端子 , 查新端子 , 拼入路由中
        else if ([lastEptType isEqualToString:@"731"]) {
            businessLinkState = NewFL_LinkState_ChooseJuXiangLastEptTerminal;
        }
        
        // 是其他 那就有问题了
        else {
            [YuanHUD HUDFullText:@"路由数据错误 , 第一个数据不可以为纤芯 , 请删除后再操作"];
            businessLinkState = NewFL_LinkState_ChooseError;
        }
        
    }
    
    // 如果路由数据 大于2
    else {
        
        // 倒数第二个是啥
        NSDictionary * last2Dict = downInsert_CutArr[downInsert_CutArr.count - 2];
        NSString * last2Type = last2Dict[@"eptTypeId"] ?: last2Dict[@"nodeTypeId"];
        
        // 最后一个是纤芯 , 那么他还是去根据光缆段终止设备 查关联光缆段 并且去重
        if ([lastEptType isEqualToString:@"702"]) {
            businessLinkState = NewFL_LinkState_ChooseCable_Repeat;
            _VM.isNeedRongJ = true;
        }
        
        // 最后一个是局向 , 那么根据局向的最后一位 , 查新端子
        else if ([lastEptType isEqualToString:@"731"]) {
            businessLinkState = NewFL_LinkState_ChooseJuXiangLastEptTerminal;
        }
        
        //TODO: 最后两个都是端子 , 那么 会根据最后一位 ,选择光缆段  (只有1期有这个判断 , 二期时不会出现这个情况)
        // 根据最后一个设备 , 选择光缆段
        else if ([lastEptType isEqualToString:@"317"] && [last2Type isEqualToString:@"317"]) {
            businessLinkState = NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType;
        }
        
        //TODO: 倒数第二个是纤芯 ,最后一个是端子 , 理论上的闭合局向  (只有1期有这个判断 , 二期时不会出现这个情况)
        // 根据最后一个端子的设备 , 再选择一个端子作为新局向的起点
        else if ([lastEptType isEqualToString:@"317"] && [last2Type isEqualToString:@"702"]) {
            businessLinkState = NewFL_LinkState_ChooseTerminalFromLastDevice;
        }
        
        // 倒数第二个是局向 , 最后一个是端子 . 根据端子设备 选择光缆段
        else if ([lastEptType isEqualToString:@"317"] && [last2Type isEqualToString:@"731"]) {
            businessLinkState = NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType;
        }
        
        else {
            
            [YuanHUD HUDFullText:@"不规则的光链路顺序 , 建议检查后重新排序"];
            businessLinkState = NewFL_LinkState_ChooseError;
        }
    }
    
    
    return businessLinkState;
}



// 向上/向下 插入的事件分流 -- 现在该吊起哪个设备?

- (void) UpDown_Insert_StateBranch:(NSArray *)updownInsert_LinkRoute
                         linkState:(NewFL_LinkState_) linkState{
    
    
    NSDictionary * lastEptDict = updownInsert_LinkRoute.lastObject;
    
    _chooseDeviceView.hidden = YES;
    _chooseCableView.hidden = YES;
    _chooseAddTypeView.hidden = YES;
    
    switch (linkState) {
            
        case NewFL_LinkState_ChooseDevice:
            
            // 选择设备 ODF ODB OCC
            _chooseDeviceView.hidden = NO;
            break;
        
        case NewFL_LinkState_ChooseCable:
            
            // 根据第一个设备 , 选择一条不需要去重的光缆段
            [self Links2_ChooseCable_IsNeedRepeat:NO
                                         DatasArr:updownInsert_LinkRoute];
            break;
        
        case NewFL_LinkState_ChooseCable_Repeat:
            
            // 根据最后一个路由数据 (接头 或 设备) , 查询他们的光缆段 , 需要去重
            [self Links2_checkCableEndDeviceDatasArr:updownInsert_LinkRoute];
            break;
            
            
        case NewFL_LinkState_ChooseCable_Repeat_NoChooseAddType:
            
            // 链路中不止一个端子 , 而且以端子结尾的 , 不能再进行成端 , 必须直接跳转光缆段选择纤芯
            [self Links2_ChooseCable_IsNeedRepeat:YES
                                         DatasArr:updownInsert_LinkRoute];
            break;
        
        case NewFL_LinkState_ChooseJuXiangLastEptTerminal:
            
            // 根据局向光纤的最后一个节点的设备 , 选择一组新端子 , 作为新局向的起点
            
        {
            NSArray * optLogicRouteList = lastEptDict[@"optLogicRouteList"];
            
            if (optLogicRouteList.count == 0) {
                [YuanHUD HUDFullText:@"路由数据错误"];
                return;
            }
            
            
            NSDictionary * la_RoouteEpt;
            
            if (_VM.insertMode == NewFL2_InsertMode_Down) {
                la_RoouteEpt = optLogicRouteList.lastObject;
            }
            else {
                la_RoouteEpt = optLogicRouteList.firstObject;
            }
            
            
            if (![la_RoouteEpt[@"nodeTypeId"] isEqualToString:@"317"]) {
                
                
                if (_VM.insertMode == NewFL2_InsertMode_Down) {
                    [YuanHUD HUDFullText:@"数据错误 , 局向光纤最后一条数据不是端子"];
                }
                else {
                    [YuanHUD HUDFullText:@"数据错误 , 局向光纤第一条数据不是端子"];
                }
                
                return;
            }
            
            // 根据最后一个端子节点 , 选出同设备的另一对端子拼入路由中
            [self Links2_ChooseTerminalFromDeviceId:la_RoouteEpt[@"rootId"]
                                         deviceType:la_RoouteEpt[@"rootTypeId"]];
        }
            
            
            break;
        
        case NewFL_LinkState_ChooseTerminalFromLastDevice:
            
            // 根据最后一个端子节点 , 选出同设备的另一对端子拼入路由中
            [self Links2_ChooseTerminalFromDeviceId:lastEptDict[@"relateResId"]
                                         deviceType:lastEptDict[@"relateResTypeId"]];
            break;
            
        default:
            break;
    }
    
}



/// 获取当前光链路 / 局向光纤 的全部路由数据
- (NSArray *) GetLinkRouteArrFromCellDict {
    
    NSArray * linkRouteArr ;
    BOOL isInRouter = [_leftScroll_ConfigCellDict.allKeys containsObject:belongRouteId];
    
    NSArray * baseArr;
    
    if (_VM.insertMode == NewFL2_InsertMode_Up) {
        baseArr = _VM.nowLinkRouters_flashback;
    }
    else {
        baseArr = _VM.nowLinkRouters;
    }
    
    
    if (_VM.now_LinkNum == 1) {
        
        // 局向光纤
        if (isInRouter) {
            
            NSDictionary * routeDict;
            for (NSDictionary * singleDict in baseArr) {
                if ([singleDict[@"eptId"] isEqualToString:_leftScroll_ConfigCellDict[belongRouteId]]) {
                    routeDict = singleDict;
                    break;
                }
            }
            
            if (routeDict) {
                linkRouteArr = routeDict[@"optLogicRouteList"];
                
                NSMutableArray * addWordArray = [NSMutableArray array];
                
                for (NSDictionary * dict in linkRouteArr) {
                    
                    NSMutableDictionary * mt_D = [NSMutableDictionary dictionaryWithDictionary:dict];
                    
                    mt_D[@"eptTypeId"] = dict[@"nodeTypeId"];
                    mt_D[@"eptName"] = dict[@"nodeName"];
                    mt_D[@"eptId"] = dict[@"nodeId"];
                    
                    mt_D[@"relateResId"] = dict[@"rootId"];
                    mt_D[@"relateResTypeId"] = dict[@"rootTypeId"];
                    mt_D[@"relateResName"] = dict[@"rootName"] ;
                    
                    [addWordArray addObject:mt_D];
                }
                
                // 重新赋值
                linkRouteArr = addWordArray;
            }
            
        }
        else {
            linkRouteArr = _linkArr.firstObject[@"optPairRouterList"];
        }
        
        
    }
    
    // 双链时 选择链路2 的情况
    else {
        
        if (_linkArr.count < 2) {
            [YuanHUD HUDFullText:@"数据错误"];
            return @[];
        }
        
        // 局向光纤
        if (isInRouter) {
            
            NSDictionary * routeDict;
            for (NSDictionary * singleDict in baseArr) {
                if ([singleDict[@"eptId"] isEqualToString:_leftScroll_ConfigCellDict[belongRouteId]]) {
                    routeDict = singleDict;
                    break;
                }
            }
            
            if (routeDict) {
                linkRouteArr = routeDict[@"optLogicRouteList"];
                
                NSMutableArray * addWordArray = [NSMutableArray array];
                
                for (NSDictionary * dict in linkRouteArr) {
                    
                    NSMutableDictionary * mt_D = [NSMutableDictionary dictionaryWithDictionary:dict];
                    
                    mt_D[@"eptTypeId"] = dict[@"nodeTypeId"];
                    mt_D[@"eptName"] = dict[@"nodeName"];
                    mt_D[@"eptId"] = dict[@"nodeId"];
                    
                    mt_D[@"relateResId"] = dict[@"rootId"];
                    mt_D[@"relateResTypeId"] = dict[@"rootTypeId"];
                    mt_D[@"relateResName"] = dict[@"rootName"] ;
                    
                    [addWordArray addObject:mt_D];
                }
                
                // 重新赋值
                linkRouteArr = addWordArray;
            }
            
        }
        else {
            linkRouteArr = _linkArr[1][@"optPairRouterList"];
        }
    }
    
    
    return linkRouteArr;
}




#pragma mark -  UI  ---

- (void) UI_Init {
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[Yuan_NewFL_LinkCell class]
                       CellReuseIdentifier:@"Yuan_NewFL_LinkCell"];
    
    
    [_tableView registerClass:[Yuan_NewFL_DT_RouteCell class]
       forCellReuseIdentifier:@"Yuan_NewFL_DT_RouteCell"];
    
    
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _headerView = Yuan_FL_HeaderView.alloc.init;
    
    _linkChooseView = Yuan_FL_LinkChooseView.alloc.init;
    
    NSString * interTitle = @"光链路路由";
    
    _intervalView = [[Yuan_FL_IntervalView alloc] initWithTitle:interTitle];
    
    _AddRouteBtn = [UIView buttonWithTitle:@"添加路由"
                                 responder:self
                                       SEL:@selector(addRouteClick)
                                     frame:CGRectNull];
    
    [_AddRouteBtn cornerRadius:3 borderWidth:0 borderColor:nil];
    _AddRouteBtn.backgroundColor = UIColor.mainColor;
    [_AddRouteBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    
    
    _Add_JXFiberBtn = [UIView buttonWithTitle:@"添加局向光纤"
                                    responder:self
                                          SEL:@selector(add_JXFiberClick)
                                        frame:CGRectNull];
    
    [_Add_JXFiberBtn cornerRadius:3 borderWidth:1 borderColor:UIColor.mainColor];
    [_Add_JXFiberBtn setTitleColor:UIColor.mainColor forState:UIControlStateNormal];
    
    
    // 选择设备
    _chooseDeviceView = Yuan_NewFL_ChooseDeviceView.alloc.init;
    _chooseDeviceView.hidden = YES;
    [_chooseDeviceView cornerRadius:3 borderWidth:1 borderColor:ColorValue_RGB(0xf2f2f2)];
    
    // 选择光缆段
    _chooseCableView = Yuan_NewFL_ChooseCableView.alloc.init;
    _chooseCableView.hidden = YES;
    [_chooseCableView cornerRadius:3 borderWidth:1 borderColor:ColorValue_RGB(0xf2f2f2)];
    
    
    _chooseAddTypeView = Yuan_NewFL_ChooseAddTypeView.alloc.init;
    _chooseAddTypeView.hidden = YES;
    [_chooseAddTypeView cornerRadius:3 borderWidth:1 borderColor:ColorValue_RGB(0xf2f2f2)];
    
    //
    _decayBtn = [UIView buttonWithImage:@"FL_Decsy"
                              responder:self
                              SEL_Click:@selector(decayClick)
                                  frame:CGRectNull];
    
    
    [self.view addSubviews:@[_tableView,
                             _headerView,
                             _linkChooseView,
                             _intervalView,
                             _AddRouteBtn,
                             _Add_JXFiberBtn,
                             _decayBtn,
                             _chooseDeviceView,
                             _chooseCableView,
                             _chooseAddTypeView]];
    
    [self yuan_layoutAllSubViews];
}


#pragma mark - 屏幕适配

- (void) yuan_layoutAllSubViews {
    
    float limit = Horizontal(15);
    
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:NaviBarHeight];
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_headerView autoSetDimension:ALDimensionHeight toSize:Vertical(60)];
    
    
    [_linkChooseView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_linkChooseView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    [_linkChooseView autoSetDimension:ALDimensionHeight toSize:50];
    [_linkChooseView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_headerView withOffset:limit];
    
    
    [_intervalView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_linkChooseView withOffset:0];
    [_intervalView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_intervalView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_intervalView autoSetDimension:ALDimensionHeight toSize:Vertical(50)];
    
    [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_intervalView withOffset:0];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:Vertical(60)];
    
    
    if (Yuan_NewFL_VM.isFiberDecay == true) {

        [_AddRouteBtn YuanToSuper_Bottom: BottomZero + 5];
        [_AddRouteBtn YuanToSuper_Left:limit];
        [_AddRouteBtn autoSetDimensionsToSize:CGSizeMake(ScreenWidth/2 - (limit * 2) - Horizontal(20), Vertical(40))];
        
        [_Add_JXFiberBtn YuanToSuper_Bottom: BottomZero + 5];
        [_Add_JXFiberBtn YuanMyEdge:Left ToViewEdge:Right ToView:_AddRouteBtn inset:limit];
        [_Add_JXFiberBtn autoSetDimensionsToSize:CGSizeMake(ScreenWidth/2 - (limit * 2) - Horizontal(20) , Vertical(40))];
        
        [_decayBtn YuanToSuper_Right:limit];
        [_decayBtn Yuan_EdgeSize:CGSizeMake(Vertical(40), Vertical(40))];
        [_decayBtn YuanAttributeHorizontalToView:_Add_JXFiberBtn];
        
    }
    
    else {
        
        [_AddRouteBtn YuanToSuper_Bottom: BottomZero + 5];
        [_AddRouteBtn YuanToSuper_Left:limit];
        [_AddRouteBtn autoSetDimensionsToSize:CGSizeMake(ScreenWidth/2 - (limit * 2), Vertical(40))];
        
        [_Add_JXFiberBtn YuanToSuper_Bottom: BottomZero + 5];
        [_Add_JXFiberBtn YuanToSuper_Right:limit];
        [_Add_JXFiberBtn autoSetDimensionsToSize:CGSizeMake(ScreenWidth/2 - (limit * 2) , Vertical(40))];
    }
    
    

    

    
    [_chooseDeviceView YuanToSuper_Left:limit];
    [_chooseDeviceView YuanMyEdge:Bottom ToViewEdge:Top ToView:_AddRouteBtn inset:-limit];
    [_chooseDeviceView autoSetDimensionsToSize:CGSizeMake(ScreenWidth/2 - (limit * 2), Vertical(160))];
    
    [_chooseCableView YuanToSuper_Left:limit];
    [_chooseCableView YuanToSuper_Right:limit];
    [_chooseCableView autoSetDimension:ALDimensionHeight toSize:Vertical(250)];
    [_chooseCableView YuanMyEdge:Bottom ToViewEdge:Top ToView:_AddRouteBtn inset:-limit];
    
    
    [_chooseAddTypeView YuanToSuper_Left:limit];
    [_chooseAddTypeView YuanMyEdge:Bottom ToViewEdge:Top ToView:_AddRouteBtn inset:-limit];
    [_chooseAddTypeView autoSetDimensionsToSize:CGSizeMake(ScreenWidth/2 - (limit * 2), Vertical(120))];
    
}


- (void) btnHidden {
    
    _AddRouteBtn.hidden = YES;
    _Add_JXFiberBtn.hidden = YES;
    _decayBtn.hidden = YES;
}



/// 跳转端子或纤芯界面
/// @param type 端子还是纤芯
/// @param dict 设备数据或光缆段数据
/// @param isExchangeRoute 是否是光链路节点的替换
- (void) Yuan_NewFL_ConfigVC_Push:(NewFL_ConfigType_)type
                             dict:(NSDictionary *)dict
                  isExchangeRoute:(BOOL) isExchangeRoute{
    
    // 哈尔滨宾县解放路光终端盒01
    __typeof(self)weakSelf = self;
    Yuan_NewFL_ConfigVC * vc = [[Yuan_NewFL_ConfigVC alloc] initWithType:type data:dict];

    // 是否进行光链路/局限光纤 节点的替换?
    vc.isExchangeRoute = isExchangeRoute;

    // 当左滑处理时 , 会传这个值
    if (isExchangeRoute) {
        vc.exchangeIndex = _leftScroll_ConfigIndex;
        vc.exchangeCellDict = _leftScroll_ConfigCellDict;
    }
    
    if (_links2_InsertIndex) {
        
        // 证明滑动的是局向光纤
        if ([_leftScroll_ConfigCellDict.allKeys containsObject:belongRouteId]) {
            vc.insertTypeEnum = NewFL_InsertType_Routes;
            // optLogicRouteList
            
            NSDictionary * routeDict;
            for (NSDictionary * cellDict in _tableViewShowDataArray) {
                
                NSString * eptId = cellDict[@"eptId"];
                
                if ([eptId isEqualToString:_leftScroll_ConfigCellDict[belongRouteId]]) {
                    
                    routeDict = cellDict;
                    break;
                }
            }
            
            if (!routeDict) {
                NSLog(@"没找到局向光纤");
                return;
            }
            
            // 赋值 需要插入的原数据
            vc.insertBaseArray = routeDict[@"optLogicRouteList"];
        }
        
        // 向下插入的是光链路
        else {
            vc.insertTypeEnum = NewFL_InsertType_Links;
            
            // 赋值 需要插入的原数据
            vc.insertBaseArray = _VM.nowLinkRouters;
        }

        vc.insertIndex = _links2_InsertIndex;
        _links2_InsertIndex = nil;
    }
    
    // 赋值 完整的值
    vc.optRoadAndLink = _httpSelectDict;
    Push(self, vc);
    
    // 保存成功的回调
    vc.ConfigSave_ReturnDataBlock = ^(id  _Nonnull returnData) {
        [weakSelf ConfigSave_ReturnData:returnData];
    };
    
    // 保存成功后 直接刷新光路数据
    vc.Config_RefreshDatasBlock = ^{
        [self refreshSelect];
    };
    
}


- (void) naviBarSet {
    
    UIBarButtonItem * clear = [UIView getBarButtonItemWithTitleStr:@"清空"
                                                             Sel:@selector(clean) VC:self];
    
    UIBarButtonItem * Gis = [UIView getBarButtonItemWithTitleStr:@"Gis"
                                                             Sel:@selector(GisClick) VC:self];
    

    #if DEBUG
        self.navigationItem.rightBarButtonItems = @[/*clear ,*/ Gis];
    #else
        self.navigationItem.rightBarButtonItems = @[Gis];
    #endif
    
}


/// 查看对应的Gis地图
- (void) GisClick {
    
    Inc_NewFL_GisVC * gis = [[Inc_NewFL_GisVC alloc] initWithEnum:NewFL_Gis_Link
                                                             dict:@{@"Id" : _VM.nowLinkId}];
    
    Push(self, gis);
}
 

/// 衰耗分解按钮
- (void) decayClick {
    
    Yuan_NewFL3_AlertDecayVC * vc = [[Yuan_NewFL3_AlertDecayVC alloc] initWithArray:_VM.nowLinkRouters];
    self.definesPresentationContext = true;
    
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    // [UIApplication sharedApplication].keyWindow.rootViewController
    [self presentViewController:vc animated:NO completion:^{
        
        // 只让 view半透明 , 但其上方的其他view不受影响
        vc.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_VM clean_LinkChooseData];
}


@end
