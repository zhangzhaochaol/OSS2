//
//  ResourceLocationTYKViewController.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2018/1/29.
//  Copyright © 2018年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

#import <AMapFoundationKit/AMapFoundationKit.h>

@interface ResourceLocationTYKViewController : Inc_BaseVC<MAAnnotation,MAMapViewDelegate>
{
    MAMapView *_mapView;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property(nonatomic,strong)NSString *labelText;
@property (strong, nonatomic) NSMutableArray *resourceArray;//传过来的资源信息列表
@property (strong, nonatomic) NSMutableArray *resourceOfflineArray;//传过来的离线资源信息列表
@property(strong,nonatomic) NSString *latIn;//传过来的纬度
@property(strong,nonatomic) NSString *lonIn;//传过来的经度
@property(strong,nonatomic) NSMutableArray *nameArray;//传过来的资源名称
@property(strong,nonatomic) NSMutableArray *nameOfflineArray;//传过来的资源名称
@property(strong,nonatomic) NSString *imageName;//显示的图标
@property(strong,nonatomic) NSString *type;//传过来的资源类型
@property (nonatomic, copy) NSString * taskId;
@property (nonatomic, assign) BOOL isInWorkOrder;
@property long selectIndex;//当前点击的覆盖物

@end
