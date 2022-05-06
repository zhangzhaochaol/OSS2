//
//  Yuan_PolyLine.h
//  INCP&EManager
//
//  Created by 袁全 on 2020/6/11.
//  Copyright © 2020 Unigame.space. All rights reserved.
//

#import "Yuan_AMap.h"

#import "Yuan_PointAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_PolyLine : MAPolyline

@property(assign,nonatomic)int type;
@property(strong,nonatomic)NSString *color;
@property (nonatomic, assign) BOOL isGuanLianLine;


typedef NS_ENUM(NSUInteger, Yuan_PolyLineState_) {
    Yuan_PolyLineState_Xu , // 虚线
    Yuan_PolyLineState_Shi  // 实线
};

/** 数据源 */
@property (nonatomic,strong) NSDictionary *dataSource;

///经纬度
@property (nonatomic, assign) CLLocationCoordinate2D startCoor;

///经纬度
@property (nonatomic, assign) CLLocationCoordinate2D endCoor;

/** start_ID */
@property (nonatomic ,copy)  NSString *s_ID;

/** end_ID */
@property (nonatomic ,copy)  NSString *e_ID;


/** 线的index */
@property (nonatomic ,assign) NSInteger index;



/** 虚线还是实线 */
@property (nonatomic ,assign) Yuan_PolyLineState_ lineState;

/** 是否是行政区域划分线段 , 目前仅扫楼使用此字段 */
@property (nonatomic ,assign) BOOL isDistrict;


// *** 穿缆撤缆 专用字段 *** ***


/** dcType */
@property (nonatomic , assign) DC_AnnoPointType_ dc_Type;

/// 通过起点 终点 连线
- (BOOL) formLine;


// 快捷构造方法
+ (Yuan_PolyLine *)lineWith_sCoor:(CLLocationCoordinate2D)sCoor
                            eCoor:(CLLocationCoordinate2D)eCoor;

@end

NS_ASSUME_NONNULL_END
