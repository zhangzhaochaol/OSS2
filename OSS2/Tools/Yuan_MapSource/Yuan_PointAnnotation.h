//
//  Yuan_PointAnnotation.h
//  INCP&EManager
//
//  Created by 袁全 on 2020/6/11.
//  Copyright © 2020 Unigame.space. All rights reserved.
//


#import "Yuan_AMap.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, DJI_AnnoPointType_) {
    DJI_AnnoPointType_None,                 //啥也不是
    DJI_AnnoPointType_StartFlyPoint,        //放飞点
    DJI_AnnoPointType_MissionPoint,         //任务点
    DJI_AnnoPointType_TurningPoint,         //拐点 , 不执行任务 只改变方向
};




typedef NS_ENUM(NSUInteger , DC_AnnoPointType_) {
    DC_AnnoPointType_None,                  //啥也不是
    DC_AnnoPointType_StartEndPoint,         //起始终止点
    DC_AnnoPointType_RoutePoint,            //属于光缆路由的点
    DC_AnnoPointType_circleRadiusPoint,     //附近资源点 散点
    DC_AnnoPointType_GetLinesPoint,         //获取线路的点
    DC_AnnoPointType_SelectSympol,          //选中的点
};




@interface Yuan_PointAnnotation : MAPointAnnotation <MAAnnotation>

#pragma mark - 新 ---

/** tag */
@property (nonatomic , assign) long tag;

/** isSegCenter */
@property (nonatomic , assign) BOOL isSegCenter;

/** segMark */
@property (nonatomic , copy) NSDictionary * segMark;

#pragma mark - 旧 ---


/**
 索引，传入的是该Annotation对应资源在数组中的下标
 */
@property (nonatomic, assign) NSUInteger index;

/** 设备ID -- 袁全添加 */
@property (nonatomic ,copy)  NSString *deviceID;

/** 所属的工单Id */
@property (nonatomic ,copy)  NSString *belongOrderId;


/** type */
@property (nonatomic ,copy)  NSString *type;

/** 对应的数据源 */
@property (nonatomic,strong) NSDictionary *dataSource;

/** 是否完成 */
@property (nonatomic ,assign) BOOL isComplete;

/** 是否是可编辑的资源点 */
@property (nonatomic ,assign) BOOL isCanEdit;

/** 是不是关键点 */
@property (nonatomic ,assign) BOOL isKeyPoint;


/** 是不是起始终止设备 */
@property (nonatomic , assign) BOOL isStartOrEndPoint;


/** 对应的view  弱引用 */
@property (nonatomic,weak) MAAnnotationView *annoView;

/** markView   */
@property (nonatomic,weak) UIImageView *markView;

/** markBtn */
@property (nonatomic,strong) UIButton *markBtn;




// *** *** *** *** *** *** *** *** *** *** *** ***  楼宇专业字段

/** 是否是行政区域划分资源点 -- 楼宇 */
@property (nonatomic ,assign) BOOL isDistrict;

/** 是否是地址搜索结果资源点 -- 楼宇 */
@property (nonatomic ,assign) BOOL isAddressSearch;

/** 是否是标准地址资源点 -- 楼宇 */
@property (nonatomic ,assign) BOOL isStandardAddress;

/** 是否是楼宇资源点 8级 -- 楼宇 */
@property (nonatomic ,assign) BOOL isBuliding;

/** 父节点 ID */
@property (nonatomic ,copy)  NSString *parentSegmId;

/** 当楼宇 -- 标准地址位置和楼宇位置不相同时 点击出现弹框 */
@property (nonatomic ,assign) BOOL isShowAlert;

/** 显示楼宇 三角形图标 当资源地址经纬度和楼宇经纬度不等时 */
@property (nonatomic ,assign) BOOL isNeedTriangleAlertImg;

/** 8级资源点存入的全部信息 */
@property (nonatomic,strong) NSDictionary *allDict;



// *** *** *** *** *** *** *** *** *** *** *** ***  档案管理字段

/** 判断是 起点 (1)   终点 (2) 还是中间点 (0) */
@property (nonatomic ,assign) NSInteger coordinateSign;



// *** ***

/** 大疆无人机巡检资源点类型 */
@property (nonatomic ,assign) DJI_AnnoPointType_ DJI_PointType;

/** 是否是无人机的图标? */
@property (nonatomic ,assign) BOOL isAirPlane;




// *** 穿缆撤缆 专用字段 *** ***


/** dcType */
@property (nonatomic , assign) DC_AnnoPointType_ dc_Type;

@end








#pragma mark - 海量点 ---

@interface Yuan_MultiPointItem : MAMultiPointItem <MAAnnotation>

/**
 索引，传入的是该Annotation对应资源在数组中的下标
 */
@property (nonatomic, assign) NSUInteger index;

/** 设备ID -- 袁全添加 */
@property (nonatomic ,copy)  NSString *deviceID;

/** 所属的工单Id */
@property (nonatomic ,copy)  NSString *belongOrderId;


/** type */
@property (nonatomic ,copy)  NSString *type;

/** 对应的数据源 */
@property (nonatomic,strong) NSDictionary *dataSource;

/** 是否完成 */
@property (nonatomic ,assign) BOOL isComplete;

/** 是否是可编辑的资源点 */
@property (nonatomic ,assign) BOOL isCanEdit;

/** 是不是关键点 */
@property (nonatomic ,assign) BOOL isKeyPoint;


/** 对应的view  弱引用 */
@property (nonatomic,weak) MAAnnotationView *annoView;

/** markView   */
@property (nonatomic,weak) UIImageView *markView;

/** markBtn */
@property (nonatomic,strong) UIButton *markBtn;




// *** *** *** *** *** *** *** *** *** *** *** ***  楼宇专业字段

/** 是否是行政区域划分资源点 -- 楼宇 */
@property (nonatomic ,assign) BOOL isDistrict;

/** 是否是地址搜索结果资源点 -- 楼宇 */
@property (nonatomic ,assign) BOOL isAddressSearch;

/** 是否是标准地址资源点 -- 楼宇 */
@property (nonatomic ,assign) BOOL isStandardAddress;

/** 是否是楼宇资源点 8级 -- 楼宇 */
@property (nonatomic ,assign) BOOL isBuliding;

/** 父节点 ID */
@property (nonatomic ,copy)  NSString *parentSegmId;

/** 当楼宇 -- 标准地址位置和楼宇位置不相同时 点击出现弹框 */
@property (nonatomic ,assign) BOOL isShowAlert;

/** 显示楼宇 三角形图标 当资源地址经纬度和楼宇经纬度不等时 */
@property (nonatomic ,assign) BOOL isNeedTriangleAlertImg;

/** 8级资源点存入的全部信息 */
@property (nonatomic,strong) NSDictionary *allDict;



// *** *** *** *** *** *** *** *** *** *** *** ***  档案管理字段

/** 判断是 起点 (1)   终点 (2) 还是中间点 (0) */
@property (nonatomic ,assign) NSInteger coordinateSign;



// *** ***

/** 大疆无人机巡检资源点类型 */
@property (nonatomic ,assign) DJI_AnnoPointType_ DJI_PointType;

/** 是否是无人机的图标? */
@property (nonatomic ,assign) BOOL isAirPlane;





// *** 穿缆撤缆 专用字段 *** ***


/** dcType */
@property (nonatomic , assign) DC_AnnoPointType_ dc_Type;

@end








typedef NS_ENUM(NSUInteger , DC_MultiPointOverlayState_) {
    DC_MultiPointOverlayState_Route,
    DC_MultiPointOverlayState_Lines,
    DC_MultiPointOverlayState_Single,
    DC_MultiPointOverlayState_None
};



#pragma mark - 海量点图层 ---
@interface Yuan_PointOverlay : MAMultiPointOverlay

@property (nonatomic , assign) DC_MultiPointOverlayState_ overlayState;
@end



NS_ASSUME_NONNULL_END
