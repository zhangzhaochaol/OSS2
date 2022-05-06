//
//  Yuan_Enum.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/3.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#ifndef Yuan_Enum_h
#define Yuan_Enum_h


#pragma mark - ODF / OCC 端子盘 **** **** **** **** **** **** **** ****


/// OCC 还是 ODF
typedef NS_ENUM(NSUInteger, InitType) {
    
    InitType_ODF = 1,
    InitType_OCC = 2,
    InitType_ODB = 3,
    InitType_OBD = 4,   //综合箱
};



/// 行优还是列优
typedef NS_ENUM(NSUInteger, Important_) {
    Important_Line = 1, //行优
    Important_row = 2   //列优
};

/// 排序方向
typedef NS_ENUM(NSUInteger, Direction_) {
    
    Direction_UpLeft = 1, // 上左
    Direction_UpRight = 2, // 上右
    Direction_DownLeft = 3 , // 下左
    Direction_DownRight = 4  // 下右
};


#pragma mark - workSurface 工作台 **** **** **** **** **** **** **** ****


typedef NS_ENUM(NSUInteger, WS_HandleBtnType_) {
    WS_HandleBtnType_DF,  //盯防
    WS_HandleBtnType_XJ   //巡检
};

typedef NS_ENUM(NSUInteger, WS_ShowType_) {
    WS_ShowType_Gis ,       //GIS
    WS_ShowType_OrderList   //工单列表
};



#pragma mark ---  RecordFile 档案列表  ---

typedef NS_ENUM(NSUInteger, RecordMapResType_) {
    RecordMapResType_Normal,     //普通点和线
    RecordMapResType_Modifi,     //移动过的点和线
    RecordMapResType_Plan        //应急预案点和线
};

// 材料成本

typedef NS_ENUM(NSUInteger, MeterialsCostType_) {
    MeterialsCostType_Meterial , // 材料
    MeterialsCostType_Cost       // 成本
};


typedef NS_ENUM(NSUInteger, MeterialsCostNowState_) {
    MeterialsCostNowState_MeterialFold,         //材料折叠
    MeterialsCostNowState_MeterialUnFold,       //材料展开
    MeterialsCostNowState_CostFold,             //成本折叠
    MeterialsCostNowState_CostUnFold,           //成本展开
    MeterialsCostNowState_DoubleFold,           //双折叠
    MeterialsCostNowState_DoubleUnFold,         //双展开
    MeterialsCostNowState_None                  //不做任何修改
};


#pragma mark -  CableFibre 光缆纤芯  ---



typedef NS_ENUM(NSUInteger, CF_HeaderCell_) {
    CF_HeaderCell_Start,                //起始
    CF_HeaderCell_End                   //终止
};


typedef NS_ENUM(NSUInteger, CF_HeaderCellType_) {
    CF_HeaderCellType_ChengDuan,        //成端
    CF_HeaderCellType_RongJie,          //熔接
    CF_HeaderCellType_None              //未知
};


//入口  配置collectionView时使用
typedef NS_ENUM(NSUInteger, CF_EnterType_) {
    CF_EnterType_List ,     //入口是列表
    CF_EnterType_Config     //入口是详情
};


// 是网络请求的数据源 还是 自己手动组合的数据源 给按钮赋值时改变颜色
typedef NS_ENUM(NSUInteger, configBindingNumFrom_) {
    configBindingNumFrom_HTTP,
    configBindingNumFrom_Connect
};



#pragma mark -  Buliding 扫楼  ---

typedef NS_ENUM(NSUInteger, BulidingSearch_) {
    BulidingSearch_Name ,       //名称搜索
    BulidingSearch_Level        //分级搜索
};


// 当前为资源点类型的哪一个 ?

typedef NS_ENUM(NSUInteger, ResourceHandle_) {
    ResourceHandle_Cancel,      //关闭
    ResourceHandle_Location,    //定位开始
    ResourceHandle_LocationEnd, //定位结束
    ResourceHandle_Msg,         //信息
    ResourceHandle_TongJi,      //统计
    ResourceHandle_TuXing,      //图形
    ResourceHandle_Picture,     //画像
    ResourceHandle_DaoHang,     //导航
    
};


#endif /* Yuan_Enum_h */
