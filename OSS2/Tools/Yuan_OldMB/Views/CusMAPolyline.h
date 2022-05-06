//
//  CusMAPolyline.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 16/8/24.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//



typedef NS_ENUM(NSUInteger, YuanLineType) {
    YuanLineTypeNormalOrSelect = 0,         // 正常状态
    YuanLineTypeDeSelect = 1,        // 未选中
    YuanLineTypeFault = 2         //故障
};


// 判断传入点A 和线的关系时使用 ,
typedef NS_ENUM(NSUInteger, YuanPoint_At_Line_) {
    YuanPoint_At_Line_Start,     //线的起始坐标
    YuanPoint_At_Line_End,       //线的终止坐标
    YuanPoint_At_Line_UnKnow     //点不在线的两端
};



@interface CusMAPolyline : MAPolyline
@property(assign,nonatomic)int type;
@property(strong,nonatomic)NSString *color;
@property (nonatomic, assign) BOOL isGuanLianLine;


///经纬度
@property (nonatomic, assign) CLLocationCoordinate2D startCoor;



///经纬度
@property (nonatomic, assign) CLLocationCoordinate2D endCoor;


/** 线的index */
@property (nonatomic ,assign) NSInteger index;


/** <#注释#> */
@property (nonatomic ,assign) YuanLineType state;



/// 检查传入的资源点经纬度 和 当前线的起点或终点是否有重合?
/// @param pointLocation 传入的经纬度
- (YuanPoint_At_Line_) checkPointLocation:(CLLocationCoordinate2D)pointLocation;




/// 给线段传入一个资源点 , 返回该线段的另一头的资源点的经纬度
/// @param onePoint 传入点的经纬度
- (CLLocationCoordinate2D) backLines_AnotherPoint:(CLLocationCoordinate2D)onePoint;




/// 检测这两个点是不是 我线段的两端的点
/// @param startCoor A
/// @param endCoor B
- (BOOL) checkPointsIsCreateMyLineStartCoor:(CLLocationCoordinate2D)startCoor
                                    endCoor:(CLLocationCoordinate2D)endCoor;

@end
