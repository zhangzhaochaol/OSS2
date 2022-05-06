//
//  Yuan_OBD_PointsConfigVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_OBD_PointsConfigVC.h"

// 选择关联方式
#import "Yuan_OBD_Points_ConnectTipsVC.h"

// 分光器
#import "Yuan_BusOBD_PointView.h"

// 设备
#import "Inc_BusDeviceView.h"



#import "Yuan_OBD_PointsHttpModel.h"
#import "Inc_NewMB_HttpModel.h"            //新模板Http请求
#import "Yuan_OBD_PointsVM.h"               //viewModel


@interface Yuan_OBD_PointsConfigVC ()

<
    Yuan_BusDevice_ItemDelegate ,
    Yuan_BusOBD_ItemDelegate
>

/** 分光端子盘 */
@property (nonatomic , strong) Yuan_BusOBD_PointView * obd_pointView;

/** 设备端子盘 */
@property (nonatomic , strong) Inc_BusDeviceView * device_pointView;

@end

@implementation Yuan_OBD_PointsConfigVC

{
    
    // obdId
    NSString * _Obd_Id;
    NSDictionary * _deviceDict;

    // 关于设备的 id 和 type
    NSString * _deviceId;  NSString * _deviceType;
    
    // 关联方式 是手动关联还是自动关联
    Yuan_OBD_PointTips_ _tipsEnum;
    
    Yuan_OBD_PointsVM * _VM;
    
    
    // 只有在点击输出端口的时候 , 才会赋值
    NSIndexPath * _output_OBDIndex;
    
    // 选择分光器 是点击的输入口
    BOOL _obd_IsInput;
}


#pragma mark - 初始化构造方法


/// 构造方法
/// @param OBD_Id 分光器Id
/// @param deviceId 设备Id
/// @param device_MBDict 设备map
- (instancetype)initWith_OBD_Id:(NSString *)OBD_Id
                       deviceId:(NSString *)deviceId
                     deviceType:(NSString *)deviceType
                     deviceDict:(NSDictionary *)device_MBDict{
    
    
    if (self = [super init]) {
        
        _Obd_Id = OBD_Id;
        _deviceId = deviceId;
        _deviceType = deviceType;
        _deviceDict = device_MBDict;
        
        
        // 未选中关联方式
        _tipsEnum = Yuan_OBD_PointTips_None;
        
        _VM = Yuan_OBD_PointsVM.alloc.init;
    }
    return self;
}





- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self UI_Init];
    [self block_init];
}


#pragma mark - Http ---


/// 解绑
- (void) Http_DisConnect:(NSDictionary *) dict {
    
    // 如果没有GID 取resId
    
    NSString * pointId = @"";
    
    if ([dict.allKeys containsObject:@"GID"]) {
        
        NSString * terminalId = dict[@"GID"];
        
        BOOL isExistShip = NO;
        
        for (NSDictionary * terminalConnectDict in _VM.point_Terminal_ShipArr) {
            
            // 证明该长按端子 是有关联关系的
            if ([terminalConnectDict[@"terminalId"] isEqualToString:terminalId]) {
                pointId = terminalConnectDict[@"pointId"];
                isExistShip = YES;
                break;
            }
        }
        
        
        if (!isExistShip) {
            [YuanHUD HUDFullText:@"未检测到该端子存在关联关系,解绑失败"];
            return;
        }
        
    }
    else {
        
        BOOL isConnect = NO;
        for (NSDictionary * OBD_ConnectDict in _VM.point_Terminal_Ship_OBDPoint_Arr) {
            
            if ([OBD_ConnectDict[@"pointId"] isEqualToString:dict[@"resId"]?:dict[@"gid"]]) {
                isConnect = YES;
                break;
            }
            
        }
        
        
        if (isConnect) {
            pointId = dict[@"resId"]?:dict[@"gid"];
        }
        
        else {
            [YuanHUD HUDFullText:@"未检测到该端子存在关联关系,解绑失败"];
            return;
        }
    }
    
    
    // 证明是输入端端子解绑
    if ([pointId isEqualToString:_obd_pointView.inPutDatas[@"resId"]?:_obd_pointView.inPutDatas[@"gid"]]) {
        
        [Yuan_OBD_PointsHttpModel Http_Input_OBDPoint_Terminals_DisConnect:@{@"aid" : pointId}
                                                                   success:^(id  _Nonnull result) {
           
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(0.5 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(),  ^{
                
                // 解绑后 , 重新刷新 关联关系
                [self Http_GetTerminalsFrinendShips];
            });
        }];
        
    }
    else {
        // resId : 分光器端口 Id
        [Yuan_OBD_PointsHttpModel Http_OBDPoint_Terminals_DisConnect:@{@"resId" : pointId}
                                                             success:^(id  _Nonnull result) {
                
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(0.5 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(),  ^{
                // 解绑后 , 重新刷新 关联关系
                [self Http_GetTerminalsFrinendShips];
            });
        }];
        
    }
    
    
    
    
}






/// 查询绑定关系  -- 通过设备端子 查询关联关系
- (void) Http_GetTerminalsFrinendShips {
    
    // 每次请求之前 先清空
    _VM.point_Terminal_ShipArr = @[];
    
    // 设备端子Id
    NSArray * terminalIds = [_device_pointView getAllTerminalIds];
    
    
    // 分光器端子Id
    NSMutableArray * points_IdsArr = NSMutableArray.array;
    for (NSDictionary * obd_pointDict in _obd_pointView.outPutDatas) {
        
        NSString * pointId = obd_pointDict[@"resId"]?:obd_pointDict[@"gid"];
        [points_IdsArr addObject:pointId];
    }
    
    // 增加输入端端子
    [points_IdsArr addObject:_obd_pointView.inPutDatas[@"resId"]?:_obd_pointView.inPutDatas[@"gid"]];
    
    [Yuan_OBD_PointsHttpModel Http_OBDPoint_Terminals_ShipSelect_FromTerminals:terminalIds
                                                                       success:^(id  _Nonnull result) {
            
        // zid 设备端子  aid 分光端口  aeqpName 分光名  aname 分光端口名
        
        NSArray * datas = result;
        
        if (datas.count > 0) {
            
            NSMutableArray * mt_arr = NSMutableArray.array;
            
            for (NSDictionary * dict in datas) {
                
                // 此处的字段  自己改造过
                
                NSString * zid = dict[@"zid"] ?: @"";
                NSString * aid = dict[@"aid"] ?: @"";
                
                NSString * aeqpName = dict[@"aeqpName"] ?: @"";
                NSString * aname = dict[@"aname"] ?: @"";
                
                NSString * position = [aname stringByReplacingOccurrencesOfString:aeqpName withString:@""];
                
                if ([position containsString:@"/"]) {
                    position = [position stringByReplacingOccurrencesOfString:@"/" withString:@""];
                }
                
                position = [NSString stringWithFormat:@"%d",position.intValue];
                
                
                NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                
                dict[@"pointId"] = aid;
                dict[@"terminalId"] = zid;
                dict[@"position"] = position;
                
                if (![points_IdsArr containsObject:aid]) {
                    dict[@"position"] = @"占";
                }
                

                
                [mt_arr addObject:dict];
            }
            
            _VM.point_Terminal_ShipArr = mt_arr;
        }
        
        else {
            _VM.point_Terminal_ShipArr = @[];
        }
        
        // 刷新端子关联状态
        [self viewsReload_FriendShip_Connect_Terminals];
        
        
        // 再去查询 分光器端子的数据
        [self Http_GetTerminalsFrinendShipsFrom_OBDIds];
    }];
}



- (void) viewsReload_FriendShip_Connect_Terminals {
    
    NSArray * terminalsBtnsArr = [_device_pointView getBtns];
    
    
    /// 处理设备端子绑定的对应分光器位置的角标
    for (Inc_BusScrollItem * btn in terminalsBtnsArr) {
        
        NSString * terminalId = btn.terminalId;
        
        [btn config_ConnectNum:@""];
        
        for (NSDictionary * shipDict in _VM.point_Terminal_ShipArr) {
            
            if ([shipDict[@"terminalId"] isEqualToString:terminalId]) {
                [btn config_ConnectNum:shipDict[@"position"]];
                break;
            }
        }
    }
    
}


// 通过分光器端子 查询更新分光器端子的关联关系
- (void) Http_GetTerminalsFrinendShipsFrom_OBDIds {
    
    
    // 分光器端子Id
    NSMutableArray * points_IdsArr = NSMutableArray.array;
    for (NSDictionary * obd_pointDict in _obd_pointView.outPutDatas) {
        
        NSString * pointId = obd_pointDict[@"resId"]?:obd_pointDict[@"gid"];
        [points_IdsArr addObject:pointId];
    }
    
    // 增加输入端端子
    [points_IdsArr addObject:_obd_pointView.inPutDatas[@"resId"]?:_obd_pointView.inPutDatas[@"gid"]];
    
    
    [Yuan_OBD_PointsHttpModel Http_OBDPoint_Terminals_ShipSelect:points_IdsArr
                                                         success:^(id  _Nonnull result) {
        // zid 设备端子  aid 分光端口  aeqpName 分光名  aname 分光端口名
        
        NSArray * datas = result;
        
        NSMutableArray * mt_arr = NSMutableArray.array;
        
        if (datas.count > 0) {
                    
            for (NSDictionary * dict in datas) {
                
                // 此处的字段  自己改造过
                
                NSString * zid = dict[@"zid"] ?: @"";
                NSString * aid = dict[@"aid"] ?: @"";
                
                NSString * aeqpName = dict[@"aeqpName"] ?: @"";
                NSString * aname = dict[@"aname"] ?: @"";
                
                NSString * position = [aname stringByReplacingOccurrencesOfString:aeqpName withString:@""];
                
                if ([position containsString:@"/"]) {
                    position = [position stringByReplacingOccurrencesOfString:@"/" withString:@""];
                }
                
                position = [NSString stringWithFormat:@"%d",position.intValue];
                
                
                NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                
                dict[@"pointId"] = aid;
                dict[@"terminalId"] = zid;
                dict[@"position"] = position;
                
                if (![points_IdsArr containsObject:aid]) {
                    dict[@"position"] = @"占";
                }
                

                
                [mt_arr addObject:dict];
            }
            
        }
        
        // 刷新端子关联状态
        if (mt_arr.count > 0) {
            
            // 通过数据 刷新OBD_PointsView
            _VM.point_Terminal_Ship_OBDPoint_Arr = mt_arr;
        }
        else {
            _VM.point_Terminal_Ship_OBDPoint_Arr = @[];
        }
        
        [self viewsReload_FriendShip_Connect_OBDPoints:mt_arr];
    }];
    
    
}


// 通过数据 刷新OBD_PointsView
- (void) viewsReload_FriendShip_Connect_OBDPoints:(NSArray *) obdPoints_ConnectArr {
    
    /// 处理分光器端口的 已绑定角标
    NSMutableArray * pointsConnectIdsArr = NSMutableArray.array;
    
    for (NSDictionary * dict in _obd_pointView.outPutDatas) {
        
        NSString * resId = dict[@"resId"]?:dict[@"gid"];
        
        for (NSDictionary * shipDict in _VM.point_Terminal_ShipArr) {
            
            if ([shipDict[@"pointId"] isEqualToString:resId]) {
                
                [pointsConnectIdsArr addObject:resId];
                break;
            }
        }
        
    }
    
    
    // 输入端
    for (NSDictionary * shipDict in _VM.point_Terminal_ShipArr) {
        
        if ([shipDict[@"pointId"] isEqualToString:_obd_pointView.inPutDatas[@"resId"]?:_obd_pointView.inPutDatas[@"gid"]]) {
            
            [pointsConnectIdsArr addObject:shipDict[@"pointId"]];
            break;
        }
    }
    
    
    
    // 刷新角标数据
    [_obd_pointView reloadConnectSympolArray:obdPoints_ConnectArr];
    
}




// 如果端子没有初始化 , 那么去初始化端子
- (void) Http_InitPoints {
    
    [Yuan_OBD_PointsHttpModel Http_OBD_Point_Init:_Obd_Id
                                          success:^(id  _Nonnull result) {
            
        [YuanHUD HUDFullText:@"初始化端子成功"];
        Pop(self);
    }];
}


#pragma mark - Delegate ---


// 分光器 输入点击事件
- (void)Yuan_BusOBDSelect_inputItem_DataSource:(NSDictionary *)dict
                                           btn:(UIButton *)inputBtn {
    
    _obd_IsInput = YES;
    
    _VM.obd_Point_Dict = dict;
    
    _output_OBDIndex = nil;
    
    [_obd_pointView BusOBD_InputBtn_Select];
}


// 分光器 输出点击事件
- (void)Yuan_BusOBDSelect_outPut_nowSelectItem:(Yuan_BusOBD_PointItem *)item
                                         index:(nonnull NSIndexPath *)index
                                         datas:(nonnull NSArray *)datas{
    
    _obd_IsInput = NO;
    
    _VM.obd_Point_Dict = item.myDict;
    
    _output_OBDIndex = index;
    
    [_obd_pointView BusOBD_OutPutItem_Select:item];
}



// 点击的 设备端子 点击事件
- (void)Yuan_BusDeviceSelectItems:(NSArray<Inc_BusScrollItem *> *)btnsArr
                    nowSelectItem:(Inc_BusScrollItem *)item
                 BusODFScrollView:(nonnull Inc_BusDeviceView *)busView{
    
    if (!_VM.obd_Point_Dict) {
        [YuanHUD HUDFullText:@"请先选择分光器端子"];
        return;
    }
    
    
    _VM.terminal_Dict = item.dict;
    
    [self chooseTips:^{
        
        
        if (_obd_IsInput) {
            
            // 输入端不论 手动还是自动 , 都是走这个方法
            [self handle_Config_InPut];
            return;
        }
        
        // 手动
        if (_tipsEnum == Yuan_OBD_PointTips_Handle) {
            [self handle_Config];
        }
        
        // 自动
        else if(_tipsEnum == Yuan_OBD_PointTips_Auto){
            
            [self auto_ConfigItem:item
                          btnsArr:btnsArr];
        }
        
        else return;
    }];
}


#pragma mark - 手动 自动 关联   --- 输出端 ---

// 手动关联
- (void) handle_Config {
    
    [_VM handleModel_Config:^{
        
        // 手动替用户选中下一个
        [_obd_pointView BusOBD_OutPutItem_SelectNext:_output_OBDIndex];
        
        // 保存成功后 重新请求关联关系
        [self Http_GetTerminalsFrinendShips];
    }];
}


// 自动关联
- (void) auto_ConfigItem:(Inc_BusScrollItem *) item
                 btnsArr:(NSArray<Inc_BusScrollItem *> *)btnsArr {
    
    // 当前选中的分光器端子的索引
    // _output_OBDIndex
    NSInteger obd_pointIndex = _output_OBDIndex.row;
    

    
    
    // 截取 分光器端子的数组们
    NSMutableArray * obd_CutArr = NSMutableArray.array;
    
    for (NSDictionary * obd_Dict in _obd_pointView.outPutDatas) {
        
        NSInteger index = [_obd_pointView.outPutDatas indexOfObject:obd_Dict];
        
        if (index >= obd_pointIndex) {
            [obd_CutArr addObject:obd_Dict];
        }
    }
    
    
    
    // 截取 设备端子的数组们
    
    
    NSArray * sortingBtnsArr = [_device_pointView getArrangementBtn];
    
    // 当前选中的设备端子的索引
    NSInteger terminalIndex = [sortingBtnsArr indexOfObject:item];
    
    NSMutableArray * terminal_CutArr = NSMutableArray.array;
    for (Inc_BusScrollItem * item in sortingBtnsArr) {
        
        NSInteger index = [sortingBtnsArr indexOfObject:item];
        
        if (index >= terminalIndex) {
            [terminal_CutArr addObject:item.dict];
        }
    }
    
    
    
    // 自动关联
    _VM.obd_PointsArr = obd_CutArr;
    _VM.terminalsArr = terminal_CutArr;
    [_VM autoModel_Config:^{
        
        // 保存成功后 重新请求关联关系
        [self Http_GetTerminalsFrinendShips];
    }];
}


#pragma mark - 手动关联 -- 输入端 ---



// 手动关联
- (void) handle_Config_InPut {
    
    [_VM handleModel_InputConfig:^{
        
        // 手动关联输入端子 不为其选择其他端子
        [_obd_pointView BusOBD_SelectNothing];
        
        // 保存成功后 重新请求关联关系
        [self Http_GetTerminalsFrinendShips];
    }];
}



#pragma mark - tipsChoose ---

- (void) chooseTips:(void(^)(void))block {
    
    Yuan_OBD_Points_ConnectTipsVC * vc = Yuan_OBD_Points_ConnectTipsVC.alloc.init;
    self.definesPresentationContext = true;
    
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    [self presentViewController:vc animated:NO completion:^{
        
        // 只让 view半透明 , 但其上方的其他view不受影响
        vc.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }];
    
    
    
    vc.pointTipsBlock = ^(Yuan_OBD_PointTips_ tipsEnum) {
        _tipsEnum = tipsEnum;
        
        if (block) {
            block();
        }
    };
}


#pragma mark - UI ---

- (void) UI_Init {
    
    _obd_pointView = [[Yuan_BusOBD_PointView alloc] initWithSuperResId:_Obd_Id];
    _obd_pointView.pointEnum = BusOBD_PointView_Bind;
    _obd_pointView.vc = self;
    _obd_pointView.delegate = self;
    
    _device_pointView = [[Inc_BusDeviceView alloc] initWithDeviceId:_deviceId
                                                          deviceDict:_deviceDict
                                                                  VC:self];
    
    _device_pointView.delegate = self;
    _device_pointView.busDevice_Enum = Yuan_BusDeviceEnum_OBD_Bind;
    
    [self.view addSubviews:@[_obd_pointView,
                             _device_pointView]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    [_obd_pointView YuanToSuper_Top:NaviBarHeight];
    [_obd_pointView YuanToSuper_Left:0];
    [_obd_pointView YuanToSuper_Right:0];
    [_obd_pointView autoSetDimension:ALDimensionHeight toSize:Vertical(250)];
    
    
    [_device_pointView YuanToSuper_Left:0];
    [_device_pointView YuanToSuper_Right:0];
    [_device_pointView YuanToSuper_Bottom:BottomZero];
    [_device_pointView YuanMyEdge:Top ToViewEdge:Bottom ToView:_obd_pointView inset:Vertical(20)];
}


- (void) block_init {
    __typeof(self)weakSelf = self;
    
    // 网络请求成功后 , 进行设备端子和分光器端子的关联关系查询
    _device_pointView.httpSuccessBlock = ^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(0.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(),  ^{
            
            [weakSelf Http_GetTerminalsFrinendShips];
        });
    };
    
    
    
    // 长按后的事件  -- 设备端子
    _device_pointView.terminalLongPressBlock = ^(NSDictionary * _Nonnull btnDict) {
      
        [UIAlert alertSmallTitle:@"是否解绑?" agreeBtnBlock:^(UIAlertAction *action) {
            
            [weakSelf Http_DisConnect:btnDict];
        }];
    };
    
    
    _obd_pointView.uninitialized_PointBlock = ^{
        
        [weakSelf Http_InitPoints];
    };
    
    // 长按解绑  -- 分光端子
    _obd_pointView.disConnect_ShipBlock = ^(NSDictionary * _Nonnull dict) {
        [weakSelf Http_DisConnect:dict];
    };
    
}


@end
