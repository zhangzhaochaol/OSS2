//
//  CusMKPointAnnotation.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 16/6/12.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//


typedef NS_ENUM(NSUInteger, YuanAnnotationType) {
    YuanAnnotationTypeNormal = 0,
    YuanAnnotationTypeQiDian = 1,
    YuanAnnotationTypeFangXiang = 2
};

@interface CusMAPointAnnotation :MAPointAnnotation
@property(assign,nonatomic)long tag;
@property(assign,nonatomic)int type;


/**
 管道段信息
 */
@property (nonatomic, strong) NSDictionary * segMark;

/**
 是否为管道段中心点
 */
@property (nonatomic, assign) BOOL isSegCenter;

/**
 当前资源字典的json
 */
@property (nonatomic, copy) NSString * jsonSource;


/** 类型 */
@property (nonatomic ,assign) YuanAnnotationType state;

/** <#注释#> */
@property (nonatomic ,assign) NSInteger index;


/** 我资源点的数据源 */
@property (nonatomic,strong) NSDictionary *myDict;

/** 资源点的经纬度 */
@property (nonatomic ,assign) CLLocationCoordinate2D yuan_Location;


/** 隐藏或显示 */
@property (nonatomic,assign , getter=isHidden) BOOL hidden;


/** True 不执行点击事件 */
@property (nonatomic ,assign) BOOL yuan_IsDisplay;


/// 检测 传入的资源点位置 和我是否一致
/// @param location 传入的资源点的位置
- (BOOL) checkPointIsMyPoint:(CLLocationCoordinate2D)location;


@end
