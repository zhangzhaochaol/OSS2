//
//  Yuan_NewMB_Enum.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/8.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#ifndef Yuan_NewMB_Enum_h
#define Yuan_NewMB_Enum_h


/**
    该枚举对应的是新模板的资源名称 , David这边的resLogicName
 */
typedef NS_ENUM(NSUInteger , Yuan_NewMB_ModelEnum_) {

    Yuan_NewMB_ModelEnum_None,                  //啥也不是
    
    
    Yuan_NewMB_ModelEnum_obd,                   //分光器 新模板
    Yuan_NewMB_ModelEnum_obdPort,               //分光器 输入端子
    Yuan_NewMB_ModelEnum_rmePort,               //分光器 输出端子
    
    
#pragma mark - 移动网 ---
    
    // 数据网
    Yuan_NewMB_ModelEnum_ServerWorkStation,     //服务器工作站设备
    Yuan_NewMB_ModelEnum_FireWall,              //防火墙
    
    // IT专业
    Yuan_NewMB_ModelEnum_NetWorkSwitch,         //网络交换机
    Yuan_NewMB_ModelEnum_Router,                //路由器
    
    
    // 移动无线网
    
    Yuan_NewMB_ModelEnum_BSC,
    Yuan_NewMB_ModelEnum_RNC,
    Yuan_NewMB_ModelEnum_BTS,
    Yuan_NewMB_ModelEnum_NODEB,
    Yuan_NewMB_ModelEnum_ENODEB,
    Yuan_NewMB_ModelEnum_GNODEB,
    Yuan_NewMB_ModelEnum_RRU,
    Yuan_NewMB_ModelEnum_BBU,
    Yuan_NewMB_ModelEnum_CU,
    Yuan_NewMB_ModelEnum_DU,
    
    
    // 核心网电路域
    Yuan_NewMB_ModelEnum_MSC,
    Yuan_NewMB_ModelEnum_HLR,
    Yuan_NewMB_ModelEnum_MGW,
    Yuan_NewMB_ModelEnum_mscServer,
    Yuan_NewMB_ModelEnum_HLR_FE,
    Yuan_NewMB_ModelEnum_HLR_BE,
    
    // 核心网分组域
    Yuan_NewMB_ModelEnum_GGSN,
    Yuan_NewMB_ModelEnum_SGSN,
    
    // LET核心网
    Yuan_NewMB_ModelEnum_MME,
    Yuan_NewMB_ModelEnum_PCRF,
    Yuan_NewMB_ModelEnum_DRA,
    Yuan_NewMB_ModelEnum_HSS_Be,
    Yuan_NewMB_ModelEnum_HSS_Fe,
    Yuan_NewMB_ModelEnum_ServingGW,
    Yuan_NewMB_ModelEnum_PGWSGW,
    
    // NB核心网
    Yuan_NewMB_ModelEnum_SPR,
    
    
    
#pragma mark - 动环 ---
    
    
    Yuan_NewMB_ModelEnum_high_voltage_s,    // 高压变配电系统
    Yuan_NewMB_ModelEnum_low_voltage_s,     // 低压供电系统
    Yuan_NewMB_ModelEnum_dc_supply,         // 开关电源系统
    Yuan_NewMB_ModelEnum_hvdc,              // 高压直流系统
    Yuan_NewMB_ModelEnum_pwr_ups,           // 交流不间断电源系统
    Yuan_NewMB_ModelEnum_modul_ups,         // 模块化UPS系统
    Yuan_NewMB_ModelEnum_oilengine,         // 油机发电机组系统
    
    Yuan_NewMB_ModelEnum_earthing,          // 防雷接地系统
    Yuan_NewMB_ModelEnum_monitor,           // 动力监控系统
    Yuan_NewMB_ModelEnum_other,             // 蓄电池组
    Yuan_NewMB_ModelEnum_ups,               // UPS
    Yuan_NewMB_ModelEnum_power_set,         // 发电机组
    Yuan_NewMB_ModelEnum_switch_power,      // 开关电源
    Yuan_NewMB_ModelEnum_oil_machine,       // 固定式油机
    Yuan_NewMB_ModelEnum_solar_power,       // 太阳能供电设备
    Yuan_NewMB_ModelEnum_Wind_power,        // 风能供电设备
    Yuan_NewMB_ModelEnum_equipment_power,   // 防雷接地设备
    Yuan_NewMB_ModelEnum_power_monitor,     // 电源监控设备
    Yuan_NewMB_ModelEnum_high_voltage,      // 高压配电设备
    Yuan_NewMB_ModelEnum_low_voltage,       // 低压配电设备
    
    Yuan_NewMB_ModelEnum_dc_voltage,        // 直流配电设备
    Yuan_NewMB_ModelEnum_energy_saving,     // 节能设备
    Yuan_NewMB_ModelEnum_dc_voltage_panel,  // 直流配电屏
    Yuan_NewMB_ModelEnum_ac_voltage_panel,  // 交流配电屏
    Yuan_NewMB_ModelEnum_dc_converter,      // 直流变换
    Yuan_NewMB_ModelEnum_SPD,               // 浪涌抑制器
    Yuan_NewMB_ModelEnum_air_con,           // 普通空调
    Yuan_NewMB_ModelEnum_center_air_con,    // 中央空调设备
    Yuan_NewMB_ModelEnum_generator_air_con, // 机房专用空调
    Yuan_NewMB_ModelEnum_inverter,          // 逆变器
    Yuan_NewMB_ModelEnum_voltage_changer,   // 变压器
    Yuan_NewMB_ModelEnum_rectifying_model,  // 整流模块
    Yuan_NewMB_ModelEnum_array_cabinet,     // 列头柜
    Yuan_NewMB_ModelEnum_other_pwr_equip,   // 其它动力设备

    Yuan_NewMB_ModelEnum_external_power,    // 外市电引入电缆
    Yuan_NewMB_ModelEnum_cable,             // 动力网电缆
    Yuan_NewMB_ModelEnum_power_term,        // 动力网端子
    Yuan_NewMB_ModelEnum_eqp,               // 电表
    Yuan_NewMB_ModelEnum_powerMeterEqp,     // 电表(新字段)
    Yuan_NewMB_ModelEnum_relaition,         // 电表与资源关联关系
    
    
    // ******** 以旧换新
    
    Yuan_NewMB_ModelEnum_optPair,           // 纤芯
    Yuan_NewMB_ModelEnum_room,              // 机房
    Yuan_NewMB_ModelEnum_optSect,           // 光缆段
    Yuan_NewMB_ModelEnum_complexBox,        // 综合箱
    
    Yuan_NewMB_ModelEnum_shelf,             // 列/框
    Yuan_NewMB_ModelEnum_module,            // 模块
    Yuan_NewMB_ModelEnum_opticTerm,         // 光端子

    Yuan_NewMB_ModelEnum_hole,              // 井
    Yuan_NewMB_ModelEnum_stayPoint,         // 电杆
    Yuan_NewMB_ModelEnum_marker,            // 标石
    Yuan_NewMB_ModelEnum_optConnectBox,     // 光交接箱
    Yuan_NewMB_ModelEnum_station,           // 局站
    Yuan_NewMB_ModelEnum_upPoint,           // 引上点
    Yuan_NewMB_ModelEnum_optJntBox,         // odb 光分箱
    Yuan_NewMB_ModelEnum_supportPoint,      // 撑点
    Yuan_NewMB_ModelEnum_position,          // 设备放置点
    
#pragma mark - 数据网 ---
    
    Yuan_NewMB_ModelEnum_baseEqp,           // 数据基础网设备
    Yuan_NewMB_ModelEnum_MCPE,              // MCPE设备
    Yuan_NewMB_ModelEnum_UTN,               // UTN设备
    // Yuan_NewMB_ModelEnum_
    
};





#endif /* Yuan_NewMB_Enum_h */
