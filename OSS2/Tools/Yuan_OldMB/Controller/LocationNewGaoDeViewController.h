//
//  LocationNewGaoDeViewController.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 16/6/12.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//



#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@protocol LocationDelegate <NSObject>
-(void)saveCoordinate:(CLLocationCoordinate2D)coordinate withAddr:(NSString *)addr;
@end

@interface LocationNewGaoDeViewController : Inc_BaseVC  <CLLocationManagerDelegate,MAMapViewDelegate,AMapSearchDelegate,MAAnnotation>
{
    MAMapView *_mapView;
}
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, weak) id <LocationDelegate> delegate;

@property (nonatomic, copy) NSString * fileName;
@property (nonatomic,strong)NSDictionary *well;
@property (nonatomic,assign)int wellId;
@property (nonatomic, assign) BOOL isOffline;



/// 袁全新增的根据经纬度初始化的构造方法
/// @param coordinate 经纬度信息
- (instancetype) initWithLocation:(CLLocationCoordinate2D)coordinate;

@end
