//
//  IWPULMarkStonePathLocationViewController.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2018/4/25.
//  Copyright © 2018年 青岛英凯利信息科技有限公司. All rights reserved.
//


#import "Inc_BaseVC.h"

@class IWPViewModel;
@class IWPPropertiesSourceModel;

@protocol IWPULMarkStonePathLocationViewControllerDelegate <NSObject>
-(void)deleteMarkStoneWithDict:(NSDictionary *)dict withClass:(Class)class;
-(void)newMarkStoneWithDict:(NSDictionary *)dict withClass:(Class)class;
@end

@interface IWPULMarkStonePathLocationViewController: Inc_BaseVC<CLLocationManagerDelegate,MAAnnotation,MAMapViewDelegate,UITableViewDataSource,UITableViewDelegate,AMapSearchDelegate,ptotocolDelegate>
{
    CLLocationManager *locationManager;
    MAMapView *_mapView;
}
@property (nonatomic, strong) AMapSearchAPI *search;
@property(strong,nonatomic)NSMutableDictionary *markStonePath;//当前标石路径；
@property (nonatomic, assign) BOOL isOffline;
//@property (nonatomic, assign) BOOL isSubDevice;
@property (nonatomic, weak) id <IWPULMarkStonePathLocationViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isInWorkOrder;

/**
 2017年03月02日 新增
 工单内新增电杆相关需求，其格式为 #工单号#接收人1#接收人2...#
 */
@property (nonatomic, copy) NSString * taskId;

@end
