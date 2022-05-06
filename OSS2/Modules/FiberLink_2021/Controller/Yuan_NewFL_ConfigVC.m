//
//  Yuan_NewFL_ConfigVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_ConfigVC.h"
#import "Yuan_NewFL_LinkChooseView.h"

#import "Inc_BusDeviceView.h"      //端子
#import "Inc_BusCableFiberView.h"  //纤芯
#import "Yuan_NewFL2_AlertWindow.h"    //2期 检测端子纤芯是否有关系的提示框


#import "Yuan_BlockLabelView.h"
#import "Yuan_NewFL_HttpModel.h"
#import "Yuan_NewFL_VM.h"


// 二期业务 --- 查看所属局向光纤
#import "Yuan_NewFL_RouteVC.h"
// 二期业务 --- 查看所属光链路
#import "Yuan_NewFL_LinkVC.h"


typedef NS_ENUM(NSUInteger , ConfigSelectEnum_) {
    ConfigSelectEnum_Link1,     //当前是链路1
    ConfigSelectEnum_Link2,    //当前是链路2
};


@interface Yuan_NewFL_ConfigVC () <Yuan_BusDevice_ItemDelegate>

/** <#注释#> */
@property (nonatomic , strong) Yuan_BlockLabelView * blockView;

/** 链路1 */
@property (nonatomic , strong) Yuan_NewFL_LinkChooseView * firstChooseLink;

/** 链路2 */
@property (nonatomic , strong) Yuan_NewFL_LinkChooseView * secondChooseLink;


/** 设备端子 */
@property (nonatomic , strong) Inc_BusDeviceView * busDevice;

/** 光缆段纤芯 */
@property (nonatomic , strong) Inc_BusCableFiberView * busCable;

@end

@implementation Yuan_NewFL_ConfigVC

{
    NewFL_ConfigType_ _initType;
    NSDictionary * _myDict;
    
    
    Yuan_NewFL_VM * _VM;
    
    // 当前正在编辑的链路
    ConfigSelectEnum_ _nowSelectLinkNo;
    
    // 不论端子还是纤芯 , 最后一个点击的数据 存入其中
    NSDictionary * _lastSelectDatas_Dict;
    
    // 弹框
    Yuan_NewFL2_AlertWindow * _alertWindow;
    
    BOOL _isDoubleLinks_NotBothLength;
    
}


#pragma mark - 初始化构造方法

- (instancetype)initWithType:(NewFL_ConfigType_)type
                        data:(NSDictionary *)dict{
    
    if (self = [super init]) {
        _initType = type;
        _myDict = dict;
        _VM = Yuan_NewFL_VM.shareInstance;
        
        // 默认选择链路1
        _nowSelectLinkNo = ConfigSelectEnum_Link1;
        
        _isDoubleLinks_NotBothLength = _VM.numberOfLink == 2 && _VM.isDoubleLinks_NotBothLength;
        
    }
    return self;
}


- (void)viewDidLoad {
    	
    if (!_optRoadAndLink) {
        [YuanHUD HUDFullText:@"缺少optRoadAndLink"];
    }
    
    
    
    [super viewDidLoad];
    [self UI_Init];
    [self naviBarSet];
    
    // 端子的点击事件 通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(terminalClick:)
                                                 name:BusDeviceSubTerminalClickNotification
                                               object:nil];

    
    // 纤芯的点击事件 通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fiberClick:)
                                                 name:BusCableSubFiberClickNotification
                                               object:nil];
    
}




#pragma mark - UI ---

- (void) UI_Init {
    
    NSString * name = @"";
    if (_initType == NewFL_ConfigType_Device) {
        
        NSArray * keys = _myDict.allKeys;
        if ([keys containsObject:@"occName"]) {
            name = _myDict[@"occName"];
        }
        else if ([keys containsObject:@"odbName"]) {
            
            name = _myDict[@"odbName"];
        }
        else if ([keys containsObject:@"rackName"]){
            name = _myDict[@"rackName"];
        }
        else name = @"";
    }
    
    if (_initType == NewFL_ConfigType_Cable) {
        name = _myDict[@"cableName"];
    }
    
    _blockView = [[Yuan_BlockLabelView alloc] initWithBlockColor:UIColor.mainColor
                                                           title:name ?: @"设备名称"];
    
    _firstChooseLink = [[Yuan_NewFL_LinkChooseView alloc] initWithType:LinkChooseType_First];
    _secondChooseLink = [[Yuan_NewFL_LinkChooseView alloc] initWithType:LinkChooseType_Second];
    
    [_firstChooseLink cornerRadius:3 borderWidth:1 borderColor:UIColor.mainColor];
    [_secondChooseLink cornerRadius:3 borderWidth:1 borderColor:ColorValue_RGB(0xe2e2e2)];
    
    [_firstChooseLink addTarget:self
                         action:@selector(firstChooseClick)
               forControlEvents:UIControlEventTouchUpInside];
    
    [_secondChooseLink addTarget:self
                          action:@selector(secondChooseClick)
                forControlEvents:UIControlEventTouchUpInside];
    
    
    if (_initType == NewFL_ConfigType_Device) {
        _busDevice = [[Inc_BusDeviceView alloc] initWithDeviceId:_myDict[@"GID"]
                                                       deviceDict:_myDict
                                                               VC:self];
        
        
        
        Yuan_BusDeviceEnum_ enum_FL;
        
        // 当空链路 或者 选择新起点的时候 , 不需要根据端子id 请求下属成端状态
        if (_VM.nowLinkState == NewFL_LinkState_ChooseDevice ||
            _VM.nowLinkState == NewFL_LinkState_ChooseTerminalFromLastDevice ||
            _VM.nowLinkState == NewFL_LinkState_ChooseJuXiangLastEptTerminal) {
            enum_FL = Yuan_BusDeviceEnum_Normal;
        }
        
        else enum_FL = Yuan_BusDeviceEnum_NewFL;
        
        // 如果是更换模式 不校验端子成端状态
        if (_isExchangeRoute) {
            enum_FL = Yuan_BusDeviceEnum_NewFL_Exchange;
        }
        
        
        // 业务状态
        _busDevice.busDevice_Enum = enum_FL;
        
        [self.view addSubview:_busDevice];
        
        _busDevice.delegate = self;
    }
    
    else {
        _busCable = [[Inc_BusCableFiberView alloc] initWithCableData:_myDict];
        _busCable.vc = self;
        
        if (_isExchangeRoute) {
            _busCable.busCableEnum = Yuan_BusCableEnum_NewFL_Exchange;
        }
        else {
            _busCable.busCableEnum = Yuan_BusCableEnum_NewFL;
        }
        [self.view addSubview:_busCable];
    }
    
    
    [self.view addSubviews:@[_blockView,_firstChooseLink,_secondChooseLink]];
    [self yuan_LayoutSubViews];
}



- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_blockView YuanToSuper_Left:limit];
    [_blockView YuanToSuper_Top:NaviBarHeight + limit];
    [_blockView YuanToSuper_Right:limit];
    
    
    // 当进行光链路 / 局向光纤节点替换时 , 相当于单链路操作
    // 或者是双链路时 , 两条链路长度不同
    if (_isExchangeRoute || _isDoubleLinks_NotBothLength) {
        
        [_firstChooseLink YuanAttributeVerticalToView:self.view];
        [_firstChooseLink YuanMyEdge:Top ToViewEdge:Bottom ToView:_blockView inset:limit * 2];
        [_firstChooseLink autoSetDimensionsToSize:CGSizeMake(Horizontal(160), Vertical(35))];
        
        
        _secondChooseLink.hidden = YES;
        
    }
    
    else {
        
        if (_VM.numberOfLink == 2) {
            
            [_firstChooseLink YuanToSuper_Left:limit];
            [_firstChooseLink YuanMyEdge:Top ToViewEdge:Bottom ToView:_blockView inset:limit * 2];
            [_firstChooseLink autoSetDimensionsToSize:CGSizeMake(Horizontal(160), Vertical(35))];
            
            [_secondChooseLink YuanAttributeHorizontalToView:_firstChooseLink];
            [_secondChooseLink YuanToSuper_Right:limit];
            [_secondChooseLink autoSetDimensionsToSize:CGSizeMake(Horizontal(160), Vertical(35))];
        }
        
        else {
            
            [_firstChooseLink YuanAttributeVerticalToView:self.view];
            [_firstChooseLink YuanMyEdge:Top ToViewEdge:Bottom ToView:_blockView inset:limit * 2];
            [_firstChooseLink autoSetDimensionsToSize:CGSizeMake(Horizontal(160), Vertical(35))];
            
            
            _secondChooseLink.hidden = YES;
        }
    }
    
    
    
    
    if (_initType == NewFL_ConfigType_Device) {
        
        [_busDevice YuanToSuper_Left:0];
        [_busDevice YuanToSuper_Right:0];
        [_busDevice YuanMyEdge:Top ToViewEdge:Bottom ToView:_firstChooseLink inset:limit * 3];
        [_busDevice autoSetDimension:ALDimensionHeight toSize:Vertical(350)];
        
    }
    else {
        [_busCable YuanToSuper_Left:0];
        [_busCable YuanToSuper_Right:0];
        [_busCable autoSetDimension:ALDimensionHeight toSize:Vertical(350)];
        [_busCable YuanMyEdge:Top ToViewEdge:Bottom ToView:_firstChooseLink inset:limit * 3];
    }
    
}



#pragma mark - btnClick ---

- (void) firstChooseClick {
    _nowSelectLinkNo = ConfigSelectEnum_Link1;
    
    [_firstChooseLink cornerRadius:3 borderWidth:1 borderColor:UIColor.mainColor];
    [_secondChooseLink cornerRadius:3 borderWidth:1 borderColor:ColorValue_RGB(0xe2e2e2)];
    
}


- (void) secondChooseClick {
    
    if (Yuan_NewFL_VM.isNew_2021 == true) {
        
        if (_VM.numberOfLink == 1 || _isDoubleLinks_NotBothLength) {
            return;
        }
        else {
            _nowSelectLinkNo = ConfigSelectEnum_Link2;
            
            [_firstChooseLink cornerRadius:3 borderWidth:1 borderColor:ColorValue_RGB(0xe2e2e2)];
            [_secondChooseLink cornerRadius:3 borderWidth:1 borderColor:UIColor.mainColor];
        }
        
        
    }
    else {
        
        _nowSelectLinkNo = ConfigSelectEnum_Link2;
        
        [_firstChooseLink cornerRadius:3 borderWidth:1 borderColor:ColorValue_RGB(0xe2e2e2)];
        [_secondChooseLink cornerRadius:3 borderWidth:1 borderColor:UIColor.mainColor];
    }
    
    
}





// 端子点击事件
- (void) terminalClick:(NSNotification *) noti {
    
    // eqpId_Id -- 端子对应的设备 Id
    NSDictionary * dict = noti.userInfo;
    [self selectTerminalOrFiber:dict];
}

// 纤芯点击事件
- (void) fiberClick:(NSNotification *) noti {
    
    NSDictionary * dict = noti.userInfo;
    [self selectTerminalOrFiber:dict];
}



- (void) selectTerminalOrFiber:(NSDictionary *) dict {
    
    _lastSelectDatas_Dict = dict;
    
    // 如果是双链不一样长度的情况 , 走特殊判断
    if (_isDoubleLinks_NotBothLength) {
        
        [self doubleLinks_SpecialConfig:dict];
        return;
    }
    
    // 端子
    if (_initType == NewFL_ConfigType_Device) {
        
        if (_nowSelectLinkNo == ConfigSelectEnum_Link1) {
            _VM.LinkA_TerminalChooseDict = dict;
            
            
            NSString * selectPieName = _busDevice.nowSelectPieName;
            NSString * index = dict[@"index"];
            NSString * position = dict[@"position"];
            [_firstChooseLink reloadAddress:[NSString stringWithFormat:@"%@ %@-%@",selectPieName,index,position]];
            
            if (_VM.numberOfLink == 2) {
                // 自动选中二框 如果存在的话
                [self secondChooseClick];
            }
            
        }
        else {
            _VM.LinkB_TerminalChooseDict = dict;
            
            NSString * selectPieName = _busDevice.nowSelectPieName;
            NSString * index = dict[@"index"];
            NSString * position = dict[@"position"];
            
            [_secondChooseLink reloadAddress:[NSString stringWithFormat:@"%@ %@-%@",selectPieName,index,position]];
        }
    }
    
    // 纤芯
    else {
    
        if (_nowSelectLinkNo == ConfigSelectEnum_Link1) {
            
            NSArray * connectList = dict[@"connectList"];
            
            if (connectList.count == 2 && !_isExchangeRoute) {
                [YuanHUD HUDFullText:@"该纤芯两端都已占用 , 不可选取"];
                return;
            }
            
            
            _VM.LinkA_FiberChooseDict = dict;
            NSString * pairNo = dict[@"pairNo"];
            [_firstChooseLink reloadAddress:[NSString stringWithFormat:@"纤芯: %@",pairNo]];
            
            if (_VM.numberOfLink == 2) {
                // 自动选中二框 如果存在的话
                [self secondChooseClick];
            }
        }
        else {
            
            NSArray * connectList = dict[@"connectList"];
            if (connectList.count == 2 && !_isExchangeRoute) {
                [YuanHUD HUDFullText:@"该纤芯两端都已占用 , 不可选取"];
                return;
            }
            
            _VM.LinkB_FiberChooseDict = dict;
            NSString * pairNo = dict[@"pairNo"];
            [_secondChooseLink reloadAddress:[NSString stringWithFormat:@"纤芯: %@",pairNo]];
        }
    }
    
}


/// 双链路 不同长度的特殊判断
- (void) doubleLinks_SpecialConfig:(NSDictionary *) dict {
    
    // 端子
    if (_initType == NewFL_ConfigType_Device) {
        
        if (_VM.now_LinkNum == 1) {
            _VM.LinkA_TerminalChooseDict = dict;
        }
        else {
            _VM.LinkB_TerminalChooseDict = dict;
        }
        
        NSString * selectPieName = _busDevice.nowSelectPieName;
        NSString * index = dict[@"index"];
        NSString * position = dict[@"position"];
        [_firstChooseLink reloadAddress:[NSString stringWithFormat:@"%@ %@-%@",selectPieName,index,position]];
        
    }
    
    // 纤芯
    else {
        
        NSArray * connectList = dict[@"connectList"];
        
        if (connectList.count == 2 && !_isExchangeRoute) {
            [YuanHUD HUDFullText:@"该纤芯两端都已占用 , 不可选取"];
            return;
        }
        
        if (_VM.now_LinkNum == 1) {
            _VM.LinkA_FiberChooseDict = dict;
        }
        else {
            _VM.LinkB_FiberChooseDict = dict;
        }
        
        NSString * pairNo = dict[@"pairNo"];
        [_firstChooseLink reloadAddress:[NSString stringWithFormat:@"纤芯: %@",pairNo]];
    }
}



#pragma mark - Yuan_BusDeviceSelectItems ---

- (void)Yuan_BusDeviceSelectItems:(NSArray<Inc_BusScrollItem *> *)btnsArr
                    nowSelectItem:(Inc_BusScrollItem *)item
                 BusODFScrollView:(nonnull Inc_BusDeviceView *)busView{
    
    
    if (_nowSelectLinkNo == ConfigSelectEnum_Link1) {
        
        for (Inc_BusScrollItem * item in btnsArr) {
            
            NSDictionary * itemDict = item.dict;
            
            if (_VM.LinkB_TerminalChooseDict) {
                if ([itemDict[@"GID"] isEqualToString:_VM.LinkB_TerminalChooseDict[@"GID"]]) {
                    continue;
                }
            }
            
            [item borderColor:UIColor.clearColor];
        }
        
        [item borderColor:UIColor.mainColor];
    }
    
    else {
        
        
        for (Inc_BusScrollItem * item in btnsArr) {
            
            NSDictionary * itemDict = item.dict;
            
            if (_VM.LinkA_TerminalChooseDict) {
                if ([itemDict[@"GID"] isEqualToString:_VM.LinkA_TerminalChooseDict[@"GID"]]) {
                    continue;
                }
            }
            
            [item borderColor:UIColor.clearColor];
        }
        
        [item borderColor:UIColor.mainColor];
    }
    
    
}



#pragma mark - naviBar ---
- (void) naviBarSet {
    
    UIBarButtonItem * save = [UIView getBarButtonItemWithTitleStr:@"保存" Sel:@selector(saveClick) VC:self];
    self.navigationItem.rightBarButtonItems = @[save];
}


- (void) saveClick {
    
    // 验证是否可以保存
    if (![self isCanSave]) {
        [YuanHUD HUDFullText:@"数据不完整或数据重复 , 无法保存"];
        return;
    }
    
    
    NSString * alertMsg = @"";
    
    if (_isExchangeRoute) {
        alertMsg = @"是否要是用该端子替换当前节点?";
    }
    else {
        alertMsg = @"是否保存数据";
    }
    
    
    [UIAlert alertSmallTitle:alertMsg agreeBtnBlock:^(UIAlertAction *action) {
        
        if (_initType == NewFL_ConfigType_Device) {
            [self saveTerminal];
        }
        
        if (_initType == NewFL_ConfigType_Cable) {
            [self saveFiber];
        }
    }];
    
}

- (BOOL) isCanSave {
    
    
    if (!_optRoadAndLink) {
        return NO;
    }
    
    
    // 如果是双链路状态下 , 并且两条链路长度不一致 , 按照单链进行保存
    if (_VM.numberOfLink == 2 && _VM.isDoubleLinks_NotBothLength) {
        return YES;
    }
    
    
    
    // 设备查端子
    if (_initType == NewFL_ConfigType_Device) {
    
        if (_VM.numberOfLink == 2 && (!_VM.LinkA_TerminalChooseDict || !_VM.LinkB_TerminalChooseDict)) {
            
            return NO;
        }
        
        if (_VM.numberOfLink == 1 && !_VM.LinkA_TerminalChooseDict) {
            
            return NO;
        }
        
        if (_VM.LinkA_TerminalChooseDict == _VM.LinkB_TerminalChooseDict) {
            return NO;
        }
        
    }
    
    
    // 光缆段查纤芯
    if (_initType == NewFL_ConfigType_Cable) {
    
        if (_VM.numberOfLink == 2 &&
            (!_VM.LinkA_FiberChooseDict || !_VM.LinkB_FiberChooseDict)) {
            
            return NO;
        }
        
        if (_VM.numberOfLink == 1 && !_VM.LinkA_FiberChooseDict) {
            
            return NO;
        }
        
        if (_VM.LinkA_FiberChooseDict == _VM.LinkB_FiberChooseDict) {
            return NO;
        }
    }
    
    return YES;
    
}


#pragma mark - 保存事件 ---

#pragma mark - 新增端子 ---

- (void) saveTerminal {
    
    
    // 如果是节点替换状态 进行替换处理
    if (_isExchangeRoute) {
        
        [self http_isExchangeRouter_Business:^{
            [self http_ConstraintExchange];
        }];
        return;
    }
    
    // 如果存在插入的index 证明需要插入操作
    if (_insertIndex) {
        
        
        [self http_isExchangeRouter_Business:^{
            [self http_InsertIntoLinksRoute];
        }];
        
        return;
    }
    
    
    if ([_VM.LinkA_TerminalChooseDict[@"GID"] isEqualToString:_VM.LinkB_TerminalChooseDict[@"GID"]] &&
        _VM.numberOfLink == 2) {
        [YuanHUD HUDFullText:@"链路1和链路2 不可选取相同端子"];
        return;
    }
    
    
    [self checkTerminalIsExistOtherLins:^{
       
        NSDictionary * newPostDict;
        
        // 当双链 并且长度不一致时走的方法
        if (_isDoubleLinks_NotBothLength) {
            
            newPostDict =
            [_VM Links2_DoubleLinks_NotBothLength_SaveBusiness_Terminal:_optRoadAndLink
                                                             deviceDict:_myDict];
        }
        // 正常状态
        else {
            newPostDict = [_VM saveBusiness_Terminal:_optRoadAndLink deviceDict:_myDict];
        }
        
        
        
        [Yuan_NewFL_HttpModel Http_LinkAddEpt:newPostDict
                                      success:^(id  _Nonnull result) {
           
            [YuanHUD HUDFullText:@"端子添加成功"];
            
            if (_ConfigSave_ReturnDataBlock) {
                _ConfigSave_ReturnDataBlock(result);
            }
            
            Pop(self);
            
        }];
        
    }];
    
}


/// 验证所选择的端子 是否已经存在在其他链路中
- (void) checkTerminalIsExistOtherLins:(void(^)(void)) allow {
    
    
    
    if (_VM.numberOfLink < 1) {
        
        [YuanHUD HUDFullText:@"当前光路无下属光链路"];
        return;
    }
    
    NSString * GID;
    
    if (_VM.isDoubleLinks_NotBothLength) {

        if (_VM.now_LinkNum == 1) {
            GID = _VM.LinkA_TerminalChooseDict[@"GID"];
        }
        else {
            GID = _VM.LinkB_TerminalChooseDict[@"GID"];
        }

    }
    else {
        GID = _VM.LinkA_TerminalChooseDict[@"GID"];
    }
    
    [Yuan_NewFL_HttpModel Http_SearchLinksFromRouterId:GID
                                           routeTypeId:@"317"
                                               success:^(id  _Nonnull result) {
       
        NSArray * resultArr = result;
        
        if (_VM.numberOfLink == 1) {
            
            if (resultArr.count == 0 || !resultArr) {
                if (allow) {
                    allow();
                }
            }
            else {
                [YuanHUD HUDFullText:@"所选端子已有所属光链路"];
                return;
            }
            
        }
        
        else {
            
            BOOL isAllow = YES;
            if (resultArr.count == 0 || !resultArr) {
                isAllow = YES;
            }
            else {
                [YuanHUD HUDFullText:@"链路1所选端子已有所属光链路"];
                return;
            }
            
            
            
            // 有链路B 的时候 才进行验证
            if (!_VM.LinkB_TerminalChooseDict) {
                
                if (isAllow && allow) {
                    allow();
                }
                
                return;
            }
            
            [Yuan_NewFL_HttpModel Http_SearchLinksFromRouterId:_VM.LinkB_TerminalChooseDict[@"GID"]
                                                   routeTypeId:@"317"
                                                       success:^(id  _Nonnull result) {
               
                NSArray * resultArr_Two = result;
                
                if (resultArr_Two.count == 0 || !resultArr_Two) {
                    
                    if (isAllow && allow) {
                        allow();
                    }
                }
                else {
                    [YuanHUD HUDFullText:@"链路2所选端子已有所属光链路"];
                    return;
                }
            }];
            
        }
        
        
        
    }];
    
}



#pragma mark - 新增纤芯 ---

- (void) saveFiber {
    
    // 如果是节点替换状态 进行替换处理
    if (_isExchangeRoute) {
        
        [self http_isExchangeRouter_Business:^{
            [self http_ConstraintExchange];
        }];
        
        return;
    }
    
    // 如果存在插入的index 证明需要插入操作
    if (_insertIndex) {
        
        [self http_isExchangeRouter_Business:^{
            [self http_InsertIntoLinksRoute];
        }];
        
        return;
    }
    
    
    if ([_VM.LinkA_FiberChooseDict[@"GID"] isEqualToString:_VM.LinkB_FiberChooseDict[@"GID"]]) {
        [YuanHUD HUDFullText:@"链路1和链路2 不可选取相同纤芯"];
        return;
    }
    
    
    
    
    NSDictionary * newPostDict;
    
    // 当双链 并且长度不一致时走的方法
    if (_isDoubleLinks_NotBothLength) {
        
        newPostDict =
        [_VM Links2_DoubleLinks_NotBothLength_SaveBusiness_Fiber:_optRoadAndLink
                                                      deviceDict:_myDict
                                                   isNeedRongJie:_VM.isNeedRongJ];
    }
    // 正常状态
    else {
        newPostDict = [_VM saveBusiness_Fiber:_optRoadAndLink
                                   deviceDict:_myDict
                                isNeedRongJie:_VM.isNeedRongJ];
    }

    [Yuan_NewFL_HttpModel Http_LinkAddEpt:newPostDict
                                  success:^(id  _Nonnull result) {
       
        [YuanHUD HUDFullText:@"纤芯添加成功"];
        
        if (_ConfigSave_ReturnDataBlock) {
            _ConfigSave_ReturnDataBlock(result);
        }
        
        Pop(self);
        
    }];
    
    
}


#pragma mark - 当替换/插入时 , 需要先进行校验当前节点是否存在其他关系 , 再确定是否保存 ---

- (void) http_isExchangeRouter_Business:(void(^)(void)) isAgressUse {
    
    NSString * type = @"317";
    
    if (_initType == NewFL_ConfigType_Cable) {
        
        NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:_lastSelectDatas_Dict];
        mt_Dict[@"GID"] = _lastSelectDatas_Dict[@"pairId"];
        _lastSelectDatas_Dict = mt_Dict;
        
        type = @"702";
    }
    
    
    
    
    NSDictionary * postDict = @{@"id": _lastSelectDatas_Dict[@"GID"],
                                @"type":type};
    
    //  optLink 光链路  logicOptPair 局向光纤  conjunction 成端 none无
    [Yuan_NewFL_HttpModel Http2_CheckChooseTerminalOrFiberShip:postDict
                                                       success:^(id  _Nonnull result) {
        NSLog(@"-- %@" , result);
        
        NSString * linkType = result[@"linkType"];
        
        if (![linkType isEqualToString:@"none"]) {
            
            __typeof(self)weakSelf = self;
            _alertWindow = [[Yuan_NewFL2_AlertWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
            _alertWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            
            [_alertWindow reloadWithEnum:AlertWindow_TF];
            
            
            if ([linkType isEqualToString:@"optLink"]) {
                [_alertWindow reloadWithEnum:AlertWindow_Link];
            }
            
            if ([linkType isEqualToString:@"logicOptPair"]) {
                [_alertWindow reloadWithEnum:AlertWindow_Route];
            }
            
            if ([linkType isEqualToString:@"conjunction"]) {
                [_alertWindow reloadWithEnum:AlertWindow_TF];
            }
            
            weakSelf->_alertWindow.AlertGoBlock = ^(AlertChooseType_ Enum) {
                
                switch (Enum) {
                        
                        // 取消
                    case AlertChooseType_Cancel:
                        
                        [_alertWindow removeFromSuperview];
                        _alertWindow = nil;
                        break;
                        
                        // 查看
                    case AlertChooseType_Look:
                        [self Look:linkType result:result];
                        
                        [_alertWindow removeFromSuperview];
                        _alertWindow = nil;
                        
                        break;
                        
                        // 强制交换
                    case AlertChooseType_ConstraintExchange:
                        
                        if (isAgressUse) {
                            isAgressUse();
                        }
                        
                        [_alertWindow removeFromSuperview];
                        _alertWindow = nil;
                        
                        break;
                        
                    default:
                        break;
                }
                
            };
            
            [[UIApplication sharedApplication].keyWindow addSubview:_alertWindow];
        }
        else {
            
            if (isAgressUse) {
                isAgressUse();
            }
        }
        
    }];
    
}

/// 强制交换的网络请求
- (void) http_ConstraintExchange {
    
    
    if (!_exchangeCellDict) {
        [YuanHUD HUDFullText:@"缺少原数据 , 无法替换"];
        return;
    }
    
    NSString * newEptId = @"";
    NSString * newEptTypeId = @"";
    
    NSString * newRelateResId = @"";
    NSString * newRelateResTypeId = @"";
    
    // 端子
    if (_initType == NewFL_ConfigType_Device) {
        
        NSString *eqpId_Type;
        NSString * eqpIdType = _lastSelectDatas_Dict[@"eqpId_Type"];
        
        switch (eqpIdType.intValue) {
            
            case 1: //odf
                eqpId_Type = @"302";
                break;
            
            case 2: //光交接
                eqpId_Type = @"703";
                break;
            
            case 3: //odb 分纤箱
                eqpId_Type = @"704";
                break;
                
            default:
                break;
        }
        
        // 父类 赋值
        newRelateResTypeId = eqpId_Type;
        newRelateResId = _lastSelectDatas_Dict[@"eqpId_Id"];
        
        // 端子 赋值
        newEptTypeId = @"317";
        newEptId = _lastSelectDatas_Dict[@"GID"];
    }
    
    // 纤芯
    else {
        
        newRelateResTypeId = @"701";
        newRelateResId = _lastSelectDatas_Dict[@"optSectId"];
        
        newEptId = _lastSelectDatas_Dict[@"pairId"];
        newEptTypeId = @"702";
        
    }
    
    // 走局向光纤内部节点替换的接口  -- 证明这个是光链路中的局向光纤内部的 端子和纤芯
    if ([_exchangeCellDict.allKeys containsObject:belongRouteId]) {
        
        NSString * belongId = _exchangeCellDict[belongRouteId];
        
        // 替换的所属局向光纤
        NSDictionary * myRoute ;
        
        for (NSDictionary * dict in _VM.nowLinkRouters) {
            
            NSString * eptId = dict[@"eptId"];
            
            if ([belongId isEqualToString:eptId]) {
                myRoute = dict;
                break;;
            }
        }
        
        
        if (!myRoute) {
            [YuanHUD HUDFullText:@"未找到该局向光纤的数据"];
            return;
        }
        
        // 局向光纤的路由
        NSArray * route_Router = myRoute[@"optLogicRouteList"];
        

        NSDictionary * newDict = @{
            @"nodeTypeId" : newEptTypeId,
            @"nodeId" : newEptId,
            @"rootId" : newRelateResId,
            @"rootTypeId" : newRelateResTypeId,
            @"sequence" : _exchangeCellDict[@"sequence"] ?: @"1",
        };
        
        
        NSDictionary * postDict = @{
            
            @"optLogicRouteList" : route_Router,
            @"changeOptLogicPairRoute" : _exchangeCellDict,  //旧
            @"optLogicPairRoute" : newDict,     //新
        };
        
        [Yuan_NewFL_HttpModel Http2_ExchangeRouterPointInRoutes:postDict
                                                        success:^(id  _Nonnull result) {
            if (_Config_RefreshDatasBlock) {
                Pop(self);
                _Config_RefreshDatasBlock();
            }
        }];
        
    }
    
    // 走光链路内部节点的替换接口
    else {
        
        NSDictionary * oldDict ;
        
        if (_exchangeIndex <= _VM.nowLinkRouters.count) {
            oldDict = _VM.nowLinkRouters[_exchangeIndex];
        }
        else {
            [YuanHUD HUDFullText:@"交换失败 , 数组越界"];
            return;
        }
        
        NSDictionary * newDict = @{
            @"eptTypeId" : newEptTypeId,
            @"eptId" : newEptId,
            @"relateResTypeId" : newRelateResTypeId,
            @"relateResId" : newRelateResId,
            @"sequence" : _exchangeCellDict[@"sequence"] ?: @"1",
        };
        
        
        NSDictionary * postDict = @{
            
            @"optPairRouterList" : _VM.nowLinkRouters,
            @"changeRouterList" : @[_exchangeCellDict],  //旧
            @"optPairRouter" : newDict,     //新
        };
        
        [Yuan_NewFL_HttpModel Http2_ExchangeRouterPointInLinks:postDict
                                                success:^(id  _Nonnull result) {
            
            if (_Config_RefreshDatasBlock) {
                Pop(self);
                _Config_RefreshDatasBlock();
            }
        }];
        
    }

}


- (void) Look:(NSString *) linkType result:(NSDictionary *) result {
    
    // 光链路 / 局向光纤的id
    NSString * linkId = result[@"linkId"];
    
    // 光链路 -- 需要再返回一个所属光路id的字段
    if ([linkType isEqualToString:@"optLink"]) {
        
        [Yuan_NewFL_HttpModel Http2_GetLinkFromLinkId:linkId
                                              success:^(id  _Nonnull result) {
            NSDictionary * linkRouter = result;
            if (linkRouter.count == 0) {
                [YuanHUD HUDFullText:@"所在光链路无下属路由"];
                return;
            }
            
            NSDictionary * dict = @{@"optPairLinkList" : @[linkRouter]};
            Yuan_NewFL_LinkVC * linkVC = [[Yuan_NewFL_LinkVC alloc] initFromLinkDatas:dict];
            
            Push(self, linkVC);
            
        }];
    }
    
    // 局向光纤
    if ([linkType isEqualToString:@"logicOptPair"]) {
        
        
        Yuan_NewFL_RouteVC * vc = [[Yuan_NewFL_RouteVC alloc] init];
        vc.routeId = linkId;
        Push(self, vc);
    }
    
}



#pragma mark - 光链路插入 ---

- (void) http_InsertIntoLinksRoute {
    
    if (_insertTypeEnum == NewFL_InsertType_None) {
        return;
    }
    
    
    // 在光链路中插入
    if (_insertTypeEnum == NewFL_InsertType_Links) {
        [self insertIntoLinks];
    }
    
    
    // 在局向光纤中插入
    if (_insertTypeEnum == NewFL_InsertType_Routes) {
        [self insertIntoRoute];
    }
}

// 发起光链路路由插入的接口
- (void) insertIntoLinks {
    
    // _lastSelectDatas_Dict
    NSMutableDictionary * mt_Dict =
    [NSMutableDictionary dictionaryWithDictionary:_lastSelectDatas_Dict];
    
    mt_Dict[@"linkId"] = _VM.nowLinkId;
    
    [Yuan_NewFL_HttpModel Http2_InsertInLinks:mt_Dict
                                  insertIndex:_insertIndex.row
                                        links:_insertBaseArray
                                      success:^(id  _Nonnull result) {
        if (_Config_RefreshDatasBlock) {
            Pop(self);
            _Config_RefreshDatasBlock();
        }
    }];
    
    
}

// 发起局向光纤插入的接口
- (void) insertIntoRoute {
    
    [Yuan_NewFL_HttpModel Http2_InsertInRoutes:_lastSelectDatas_Dict
                                   insertIndex:_insertIndex.row
                                         links:_insertBaseArray
                                       success:^(id  _Nonnull result) {
        if (_Config_RefreshDatasBlock) {
            Pop(self);
            _Config_RefreshDatasBlock();
        }
    }];
    
}



- (void)dealloc {
    
    
    _VM.LinkA_TerminalChooseDict = nil;
    _VM.LinkB_TerminalChooseDict = nil;
}

@end
