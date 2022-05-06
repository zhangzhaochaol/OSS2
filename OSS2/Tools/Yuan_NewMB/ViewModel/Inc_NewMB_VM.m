//
//  Inc_NewMB_VM.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/11.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewMB_VM.h"


@implementation Inc_NewMB_VM


#pragma mark - 声明单粒 ---

+ (Inc_NewMB_VM *) viewModel {
    
    return Inc_NewMB_VM.alloc.init;
}



- (NSArray <UIButton *> *) bottomBtns_Enum:(Yuan_NewMB_ModelEnum_) modelEnum
                                    mbDict:(NSDictionary *)mbDict{
    
    
    
    NSDictionary * TYK_Power = UserModel.powersTYKDic;
    
    BOOL haveId = [mbDict.allKeys containsObject:@"gid"] || [mbDict.allKeys containsObject:@"resId"];
    
    NSMutableArray * btnsArr = NSMutableArray.array;
    
    // 保存
    
    UIButton * saveBtn = [UIView buttonWithTitle:@"保存"
                                       responder:_vc
                                             SEL:@selector(saveClick)
                                           frame:CGRectNull];
    [btnsArr addObject:saveBtn];
    
    
    // 保存标签按钮 -- 当没有保存权限是 , 他只可以保存标签
    UIButton * saveRfidBtn = [UIView buttonWithTitle:@"保存标签"
                                           responder:_vc
                                                 SEL:@selector(saveRfidClick)
                                               frame:CGRectNull];
    
    
    
    UIButton * deleteBtn = [UIView buttonWithTitle:@"删除"
                                         responder:_vc
                                               SEL:@selector(deleteClick)
                                             frame:CGRectNull];
    
    // 删除
    if (mbDict.count > 0 && haveId) {
        
        // 分光器端子 没有删除按钮
        if (modelEnum != Yuan_NewMB_ModelEnum_obdPort ||
            modelEnum != Yuan_NewMB_ModelEnum_rmePort) {
            
            [btnsArr addObject:deleteBtn];
        }
    }
    
    
    
    // MARK: 其他分类
    
    // 分光器
    if ( modelEnum == Yuan_NewMB_ModelEnum_obd && [mbDict.allKeys containsObject:@"gid"]) {
        
        UIButton * OBD_SubPort = [UIView buttonWithTitle:@"端子"
                                               responder:_vc
                                                     SEL:@selector(obd_PortClick)
                                                   frame:CGRectNull];
        [btnsArr addObject:OBD_SubPort];
        
        
        NSString * power_OCC = TYK_Power[@"OCC_Equt"];
        NSString * power_ODB = TYK_Power[@"OCC_Equt"];
        
        if ([[power_OCC substringToIndex:1] isEqualToString:@"0"] ||
            [[power_ODB substringToIndex:1] isEqualToString:@"0"]) {
            
            [btnsArr removeObject:saveBtn];
        }
        
        if ([[power_OCC substringWithRange:NSMakeRange(1,1)] isEqualToString:@"0"] ||
            [[power_ODB substringWithRange:NSMakeRange(1,1)] isEqualToString:@"0"]) {
            [btnsArr removeObject:deleteBtn];
        }
        
        
        
    }
    
    
    
    // 分光器端子 没有删除
    if (modelEnum == Yuan_NewMB_ModelEnum_obdPort ||
        modelEnum == Yuan_NewMB_ModelEnum_rmePort) {
        
        [btnsArr removeObject:deleteBtn];
    }
    
    // 新版纤芯
    if (modelEnum == Yuan_NewMB_ModelEnum_optPair) {
     
        UIButton * FiberLink = [UIView buttonWithTitle:@"查看光路"
                                             responder:_vc
                                                   SEL:@selector(FiberLink)
                                                 frame:CGRectNull];
        
        
        UIButton * FiberRoute = [UIView buttonWithTitle:@"局向光纤"
                                              responder:_vc
                                                    SEL:@selector(FiberRoute)
                                                  frame:CGRectNull];
        
        if (haveId) {
            [btnsArr addObject:FiberLink];
            [btnsArr addObject:FiberRoute];
        }
        
        
        
    }
    
    
    
    if (modelEnum == Yuan_NewMB_ModelEnum_FireWall ||
        modelEnum == Yuan_NewMB_ModelEnum_ServerWorkStation ||
        modelEnum == Yuan_NewMB_ModelEnum_NetWorkSwitch ||
        modelEnum == Yuan_NewMB_ModelEnum_Router) {
        
        if (!haveId) {
            [btnsArr removeObject:deleteBtn];
        }
    }
    
    
    // 机房没有删除按钮
    if (modelEnum == Yuan_NewMB_ModelEnum_room) {
        [btnsArr removeObject:deleteBtn];
    }
    
    
    // 光缆段
    if (modelEnum == Yuan_NewMB_ModelEnum_optSect) {
        
        
        // 根据删除权限判断
        if (!Authority_Delete(@"cable")) {
            [btnsArr removeObject:deleteBtn];
        }
        
        UIButton * CFConfigBtn = [UIView buttonWithTitle:@"纤芯配置"
                                             responder:_vc
                                                   SEL:@selector(CFConfigClick)
                                                 frame:CGRectNull];
        
        
        if (haveId) {
            [btnsArr addObject:CFConfigBtn];
        }
        
    }
    
    // 综合箱
    if (modelEnum == Yuan_NewMB_ModelEnum_complexBox) {
        
        
        // 根据删除权限判断
        if (!Authority_Delete(@"integratedBox")) {
            [btnsArr removeObject:deleteBtn];
        }
        
        UIButton * showModelBtn = [UIView buttonWithTitle:@"模板"
                                             responder:_vc
                                                   SEL:@selector(showModelClick)
                                                 frame:CGRectNull];
        
        
        if (haveId) {
            //暂时去掉综合箱模板
//            [btnsArr addObject:showModelBtn];
        }
        
    }
    
    
    // 列框
    if (modelEnum == Yuan_NewMB_ModelEnum_shelf) {
        
        
        // 根据删除权限判断
        if (!Authority_Delete(@"shelf")) {
            [btnsArr removeObject:deleteBtn];
        }
        
        UIButton * showModuleBtn = [UIView buttonWithTitle:@"模块"
                                             responder:_vc
                                                   SEL:@selector(showModuleClick)
                                                 frame:CGRectNull];
        
        
        if (haveId) {
            [btnsArr addObject:showModuleBtn];
        }
        
    }
    
    // 根据保存权限 判断 saveBtn 应该显示的是保存 , 还是保存标签 ?
    if ([self getOldResLogicNameFromEnum:modelEnum].length > 0) {
        
        if (!Authority_Modifi([self getOldResLogicNameFromEnum:modelEnum])) {
            [btnsArr removeObject:saveBtn];
            [btnsArr addObject:saveRfidBtn];
        }
    }
    
    
    return btnsArr;
    
}


/// 查看新增权限
BOOL Authority_Add (NSString * oldResLogicName) {
    
    
    NSDictionary * TYK_Power = UserModel.powersTYKDic;
    
    NSString * power_Generator = TYK_Power[oldResLogicName];
    if ([[power_Generator substringToIndex:0] isEqualToString:@"0"]) {
        return NO;
    }
    
    
    return YES;
}

/// 查看删除权限
BOOL Authority_Delete (NSString * oldResLogicName) {
    
    
    NSDictionary * TYK_Power = UserModel.powersTYKDic;
    
    NSString * power_Generator = TYK_Power[oldResLogicName];
    if ([[power_Generator substringToIndex:1] isEqualToString:@"0"]) {
        return NO;
    }
    
    
    return YES;
}

/// 查看修改权限
BOOL Authority_Modifi (NSString * oldResLogicName) {
    
    
    NSDictionary * TYK_Power = UserModel.powersTYKDic;
    
    NSString * power_Generator = TYK_Power[oldResLogicName];
    if ([[power_Generator substringToIndex:2] isEqualToString:@"0"]) {
        return NO;
    }
    
    
    return YES;
}



// 根据分光器枚举 返回对应的fileName
- (NSString *) fileNameFromEnum: (Yuan_NewMB_ModelEnum_) modelEnum {
    
    NSString * _jsonFile = @"";
    
    switch (modelEnum) {
        
        case Yuan_NewMB_ModelEnum_obd:
            _jsonFile = @"obd";
            break;
            
        case Yuan_NewMB_ModelEnum_obdPort:              //分光器 输入端子
            _jsonFile = @"obdPort";
            break;
            
        case Yuan_NewMB_ModelEnum_rmePort:              //分光器 输出端子
            _jsonFile = @"rmePort";
            break;
        
        case Yuan_NewMB_ModelEnum_ServerWorkStation:    //服务器工作站设备
            _jsonFile = @"server";
            break;
            
        case Yuan_NewMB_ModelEnum_FireWall:     //防火墙
            _jsonFile = @"fireWall";
            break;
            
        case Yuan_NewMB_ModelEnum_NetWorkSwitch:    //交换机
            _jsonFile = @"data_switch";
            break;
        
        case Yuan_NewMB_ModelEnum_Router:       //路由器
            _jsonFile = @"router";
            break;
       
            
/// 移动无线网    --- ---
            
        case Yuan_NewMB_ModelEnum_BSC:
            _jsonFile = @"BSC";
            break;
            
        case Yuan_NewMB_ModelEnum_RNC:
            _jsonFile = @"RNC";
            break;
            
        case Yuan_NewMB_ModelEnum_BTS:
            _jsonFile = @"BTS";
            break;
            
        case Yuan_NewMB_ModelEnum_NODEB:
            _jsonFile = @"NODEB";
            break;
            
        case Yuan_NewMB_ModelEnum_ENODEB:
            _jsonFile = @"ENODEB";
            break;
            
        case Yuan_NewMB_ModelEnum_GNODEB:
            _jsonFile = @"GNODEB";
            break;
            
        case Yuan_NewMB_ModelEnum_RRU:
            _jsonFile = @"RRU";
            break;
            
        case Yuan_NewMB_ModelEnum_BBU:
            _jsonFile = @"BBU";
            break;
            
        case Yuan_NewMB_ModelEnum_CU:
            _jsonFile = @"CU";
            break;
            
        case Yuan_NewMB_ModelEnum_DU:
            _jsonFile = @"DU";
            break;
            
            

/// 核心网电路域    --- ---     还未调试
        case Yuan_NewMB_ModelEnum_MSC:
            _jsonFile = @"MSC";
            break;
            
        case Yuan_NewMB_ModelEnum_HLR:
            _jsonFile = @"HLR";
            break;
            
        case Yuan_NewMB_ModelEnum_MGW:
            _jsonFile = @"MGW";
            break;
            
        case Yuan_NewMB_ModelEnum_mscServer:
            _jsonFile = @"MSCSERVER";
            break;
            
        case Yuan_NewMB_ModelEnum_HLR_FE:
            _jsonFile = @"HLR-FE";
            break;
            
        case Yuan_NewMB_ModelEnum_HLR_BE:
            _jsonFile = @"HLR-BE";
            break;
            
/// 核心网分组域    --- ---
        case Yuan_NewMB_ModelEnum_GGSN:
            _jsonFile = @"GGSN";
            break;
            
        case Yuan_NewMB_ModelEnum_SGSN:
            _jsonFile = @"SGSN";
            break;
            
/// LET核心网    --- ---
        case Yuan_NewMB_ModelEnum_MME:
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_PCRF:
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_DRA:
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_HSS_Be:
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_HSS_Fe:
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_ServingGW:
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_PGWSGW:
            _jsonFile = @"";
            break;
            
/// NB核心网    --- ---
        case Yuan_NewMB_ModelEnum_SPR:
            _jsonFile = @"";
            break;
 
            
/// 动环设备    --- ---
        case Yuan_NewMB_ModelEnum_high_voltage_s:    // 高压变配电系统
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_low_voltage_s:     // 低压供电系统
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_dc_supply:         // 开关电源系统
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_hvdc:              // 高压直流系统
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_pwr_ups:           // 交流不间断电源系统
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_modul_ups:         // 模块化UPS系统
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_oilengine:         // 油机发电机组系统
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_earthing:          // 防雷接地(系统)
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_monitor:           // 动力监控系统
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_other:             // 蓄电池组
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_ups:               // UPS
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_power_set:         // 发电机组
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_switch_power:      // 开关电源
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_oil_machine:       // 固定式油机
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_solar_power:       // 太阳能供电设备
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_Wind_power:        // 风能供电设备
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_equipment_power:   // 防雷接地(设备)
            _jsonFile = @"EquipmentPower";
            break;
            
        case Yuan_NewMB_ModelEnum_power_monitor:     // 电源监控设备
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_high_voltage:      // 高压配电设备
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_low_voltage:       // 低压配电设备
            _jsonFile = @"";
            break;

        case Yuan_NewMB_ModelEnum_dc_voltage:        // 直流配电设备
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_energy_saving:     // 节能设备
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_dc_voltage_panel:  // 直流配电屏
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_ac_voltage_panel:  // 交流配电屏
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_dc_converter:      // 直流变换
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_SPD:               // 浪涌抑制器
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_air_con:           // 普通空调
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_center_air_con:    // 中央空调设备
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_generator_air_con: // 机房专用空调
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_inverter:          // 逆变器
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_voltage_changer:   // 变压器
            _jsonFile = @"VoltageChanger";
            break;
            
        case Yuan_NewMB_ModelEnum_rectifying_model:  // 整流模块
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_array_cabinet:     // 列头柜
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_other_pwr_equip:   // 其它动力设备
            _jsonFile = @"";
            break;

        case Yuan_NewMB_ModelEnum_external_power:    // 外市电引入电缆
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_cable:             // 动力网电缆
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_power_term:        // 动力网端子
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_eqp:               // 电表
            _jsonFile = @"";
            break;
            
        case Yuan_NewMB_ModelEnum_powerMeterEqp:     // 电表（新字段）
            _jsonFile = @"powerMeterEqp";
            break;
            
        case Yuan_NewMB_ModelEnum_relaition:         // 电表与资源关联关系
            _jsonFile = @"";
            break;
            

    
            
/// 数据网设备    --- ---
        case Yuan_NewMB_ModelEnum_baseEqp:          // 电表与资源关联关系
            _jsonFile = @"baseEqp";
            break;
            
        case Yuan_NewMB_ModelEnum_MCPE:             // MCPE设备
            _jsonFile = @"MCPE";
            break;
            
        case Yuan_NewMB_ModelEnum_UTN:              // UTN设备
            _jsonFile = @"UTN";
            break;
            
            
 /// 旧设备
        case Yuan_NewMB_ModelEnum_optPair:          // 纤芯
            _jsonFile = @"optPair";
            break;
            
        case Yuan_NewMB_ModelEnum_room:             // 机房
            _jsonFile = @"room";
            break;
            
        case Yuan_NewMB_ModelEnum_optSect:          // 光缆段
            _jsonFile = @"optSect";
            break;
        
        case Yuan_NewMB_ModelEnum_complexBox:       // 综合箱
            _jsonFile = @"complexBox";
            break;
            
        case Yuan_NewMB_ModelEnum_shelf:            // 列/框
                _jsonFile = @"shelf";
                break;
            
        case Yuan_NewMB_ModelEnum_module:           // 模块
                _jsonFile = @"module";
                break;
            
        case Yuan_NewMB_ModelEnum_opticTerm:        // 光端子
                _jsonFile = @"opticTerm";
                break;
         
            
 // GIS 相关设备
            
        case Yuan_NewMB_ModelEnum_hole:             // 井
            _jsonFile = @"hole";
            break;
            
        case Yuan_NewMB_ModelEnum_stayPoint:             // 电杆
            _jsonFile = @"stayPoint";
            break;
            
        case Yuan_NewMB_ModelEnum_marker:             // 标石
            _jsonFile = @"marker";
            break;
            
        case Yuan_NewMB_ModelEnum_optConnectBox:             // 光交接箱
            _jsonFile = @"optConnectBox";
            break;
            
        case Yuan_NewMB_ModelEnum_station:             // 局站
            _jsonFile = @"station";
            break;
            
        case Yuan_NewMB_ModelEnum_upPoint:             // 引上点
            _jsonFile = @"upPoint";
            break;
            
        case Yuan_NewMB_ModelEnum_optJntBox:             // 光分箱
            _jsonFile = @"optJntBox";
            break;
            
        case Yuan_NewMB_ModelEnum_supportPoint:             // 撑点
            _jsonFile = @"supportPoint";
            break;
            
        case Yuan_NewMB_ModelEnum_position:             // 设备放置点
            _jsonFile = @"position";
            break;
         
            
        default:
            [YuanHUD HUDFullText:@"未配置'枚举值和模板'的关联关系 - 在Yuan_NewMB_VM中"];
            break;
    }
    
    
    
    
    return _jsonFile;
}





// 根据分jsonfile 返回对应的枚举   --- 传入的filename是 模板里对应的type字段
- (Yuan_NewMB_ModelEnum_ ) EnumFromFileName: (NSString *) jsonFile {
    
    /// 分光器    --- ---
    
    // 新
    if ([jsonFile isEqualToString:@"obd"])
        return Yuan_NewMB_ModelEnum_obd;
    
    if ([jsonFile isEqualToString:@"obdPort"])  //分光器 输入端子
        return Yuan_NewMB_ModelEnum_obdPort;
    
    if ([jsonFile isEqualToString:@"rmePort"])  //分光器 输出端子
        return Yuan_NewMB_ModelEnum_rmePort;
    
    
    /// IT分册    --- ---
    if ([jsonFile isEqualToString:@"server"])
        return Yuan_NewMB_ModelEnum_ServerWorkStation;
    
    if ([jsonFile isEqualToString:@"fireWall"])
        return Yuan_NewMB_ModelEnum_FireWall;
    
    if ([jsonFile isEqualToString:@"router"])
        return Yuan_NewMB_ModelEnum_Router;
    
    if ([jsonFile isEqualToString:@"data_switch"])
        return Yuan_NewMB_ModelEnum_NetWorkSwitch;
    
    /// 移动无线网    --- ---
    if ([jsonFile isEqualToString:@"BSC"])
        return Yuan_NewMB_ModelEnum_BSC;
    
    if ([jsonFile isEqualToString:@"RNC"])
        return Yuan_NewMB_ModelEnum_RNC;
    
    if ([jsonFile isEqualToString:@"BTS"])
        return Yuan_NewMB_ModelEnum_BTS;
    
    if ([jsonFile isEqualToString:@"NODEB"])
        return Yuan_NewMB_ModelEnum_NODEB;
    
    if ([jsonFile isEqualToString:@"ENODEB"])
        return Yuan_NewMB_ModelEnum_ENODEB;
    
    if ([jsonFile isEqualToString:@"GNODEB"])
        return Yuan_NewMB_ModelEnum_GNODEB;
    
    if ([jsonFile isEqualToString:@"RRU"])
        return Yuan_NewMB_ModelEnum_RRU;
    
    if ([jsonFile isEqualToString:@"BBU"])
        return Yuan_NewMB_ModelEnum_BBU;
    
    if ([jsonFile isEqualToString:@"CU"])
        return Yuan_NewMB_ModelEnum_CU;
    
    if ([jsonFile isEqualToString:@"DU"])
        return Yuan_NewMB_ModelEnum_DU;
    
    /// 核心网分组域   --- ---
    if ([jsonFile isEqualToString:@"GGSN"])
        return Yuan_NewMB_ModelEnum_GGSN;
    
    if ([jsonFile isEqualToString:@"SGSN"])
        return Yuan_NewMB_ModelEnum_SGSN;
    
    
    /// 核心网电路域  --- ---   还未调试
    if ([jsonFile isEqualToString:@"MSC"])
        return Yuan_NewMB_ModelEnum_MSC;
    
    if ([jsonFile isEqualToString:@"HLR"])
        return Yuan_NewMB_ModelEnum_HLR;
    
    if ([jsonFile isEqualToString:@"MGW"])
        return Yuan_NewMB_ModelEnum_MGW;
    
    if ([jsonFile isEqualToString:@"MSCSERVER"])
        return Yuan_NewMB_ModelEnum_mscServer;
    
    if ([jsonFile isEqualToString:@"HLR-FE"])
        return Yuan_NewMB_ModelEnum_HLR_FE;
    
    if ([jsonFile isEqualToString:@"HLR-BE"])
        return Yuan_NewMB_ModelEnum_HLR_BE;

    
    
    /// 动环设备 --- --- 还未完全调试
    
    if ([jsonFile isEqualToString:@"lightning_protect_equip"]) {
        return Yuan_NewMB_ModelEnum_equipment_power;
    }
    
    if ([jsonFile isEqualToString:@"voltage_changer"]) {
        return Yuan_NewMB_ModelEnum_voltage_changer;
    }
    
    if ([jsonFile isEqualToString:@"powerMeterEqp"]) {
        return Yuan_NewMB_ModelEnum_powerMeterEqp;
    }
    
    
    /// 数据网设备    --- ---
    if ([jsonFile isEqualToString:@"baseEqp"]) {
        return Yuan_NewMB_ModelEnum_baseEqp;
    }
    
    if ([jsonFile isEqualToString:@"MCPE"]) {
        return Yuan_NewMB_ModelEnum_MCPE;
    }
    
    if ([jsonFile isEqualToString:@"UTN"]) {
        return Yuan_NewMB_ModelEnum_UTN;
    }
    
    
    
    // 以旧换新的设备 *** *** ***
    
    // 纤芯
    if ([jsonFile isEqualToString:@"optPair"]) {
        return Yuan_NewMB_ModelEnum_optPair;
    }
    
    // 机房
    if ([jsonFile isEqualToString:@"room"]) {
        return Yuan_NewMB_ModelEnum_room;
    }
    
    // 光缆段
    if ([jsonFile isEqualToString:@"optSect"]) {
        return Yuan_NewMB_ModelEnum_optSect;
    }
      
    
    // 综合箱
    if ([jsonFile isEqualToString:@"complexBox"]) {
        return Yuan_NewMB_ModelEnum_complexBox;
    }
    
    // 列/框
    if ([jsonFile isEqualToString:@"shelf"]) {
        return Yuan_NewMB_ModelEnum_shelf;
    }
    
    // 模块
    if ([jsonFile isEqualToString:@"module"]) {
        return Yuan_NewMB_ModelEnum_module;
    }
    
    // 光端子
    if ([jsonFile isEqualToString:@"opticTerm"]) {
        return Yuan_NewMB_ModelEnum_opticTerm;
    }
    
    
    
    // *********  GIS 相关资源
    
    // 井
    if ([jsonFile isEqualToString:@"hole"]) {
        return Yuan_NewMB_ModelEnum_hole;
    }
    
    // 电杆
    if ([jsonFile isEqualToString:@"stayPoint"]) {
        return Yuan_NewMB_ModelEnum_stayPoint;
    }
    
    // 标石
    if ([jsonFile isEqualToString:@"marker"]) {
        return Yuan_NewMB_ModelEnum_marker;
    }
    
    // 光交箱
    if ([jsonFile isEqualToString:@"optConnectBox"]) {
        return Yuan_NewMB_ModelEnum_optConnectBox;
    }
    
    //  局站
    if ([jsonFile isEqualToString:@"station"]) {
        return Yuan_NewMB_ModelEnum_station;
    }
    

    // 引上点
    if ([jsonFile isEqualToString:@"upPoint"]) {
        return Yuan_NewMB_ModelEnum_upPoint;
    }
    
    // ODB 光分箱
    if ([jsonFile isEqualToString:@"optJntBox"]) {
        return Yuan_NewMB_ModelEnum_optJntBox;
    }
    
    // 撑点
    if ([jsonFile isEqualToString:@"supportPoint"]) {
        return Yuan_NewMB_ModelEnum_supportPoint;
    }
    
    // 设备放置点
    if ([jsonFile isEqualToString:@"position"]) {
        return Yuan_NewMB_ModelEnum_position;
    }
    
    
    return Yuan_NewMB_ModelEnum_None;

}


// 根据enum获取旧版resLogicName  只有老资源模板会使用到
- (NSString *) getOldResLogicNameFromEnum:(Yuan_NewMB_ModelEnum_) modelEnum {
    
    NSString * resLogicName = @"";
    
    switch (modelEnum) {
            
            // 光缆段
        case Yuan_NewMB_ModelEnum_optSect:
            resLogicName = @"cable";
            break;
            
            // obd
        case Yuan_NewMB_ModelEnum_obd:
            resLogicName = @"OBD_Equt";
            break;
            
            // 机房
        case Yuan_NewMB_ModelEnum_room:
            resLogicName = @"generator";
            break;
            
            // 纤芯
        case Yuan_NewMB_ModelEnum_optPair:
            resLogicName = @"optPair";
            break;
            
            // 列框
        case Yuan_NewMB_ModelEnum_shelf:
            resLogicName = @"cnctShelf";
            break;
            
            // 模块
        case Yuan_NewMB_ModelEnum_module:
            resLogicName = @"module";
            break;
            
            // 光端子
        case Yuan_NewMB_ModelEnum_opticTerm:
            resLogicName = @"opticTerm";
            break;
        default:
            break;
    }
    
    return resLogicName;
}

- (NSArray *)getCleanKeys {
    
    return @[@"code"];
}


// 根据 resLogicName 转 新的type
- (NSString *) getNewTypeFromOldResLogicName:(NSString *) resLogicName {
    
    // 井
    if ([resLogicName isEqualToString:@"well"]) {
        return @"hole";
    }
    
    // 电杆
    if ([resLogicName isEqualToString:@"pole"]) {
        return @"stayPoint";
    }
    
    // 标石
    if ([resLogicName isEqualToString:@"markStone"]) {
        return @"marker";
    }
    
    // 光交接箱
    if ([resLogicName isEqualToString:@"OCC_Equt"]) {
        return @"optConnectBox";
    }
    
    // 局站
    if ([resLogicName isEqualToString:@"stationBase"]) {
        return @"station";
    }
    
    // 机房
    if ([resLogicName isEqualToString:@"generator"]) {
        return @"room";
    }
    
    // 引上点
    if ([resLogicName isEqualToString:@"ledUp"]) {
        return @"upPoint";
    }
    
    // ODB
    if ([resLogicName isEqualToString:@"ODB_Equt"]) {
        return @"obd";
    }
    
    // 撑点
    if ([resLogicName isEqualToString:@"supportingPoints"]) {
        return @"supportPoint";
    }
    
    // 设备放置点
    if ([resLogicName isEqualToString:@"EquipmentPoint"]) {
        return @"position";
    }
    
    return @"";
    
}

@end
