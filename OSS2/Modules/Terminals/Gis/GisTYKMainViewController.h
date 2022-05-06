//
//  GisTYKMainViewController.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/12/13.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"
#import "ptotocolDelegate.h"

@class IWPViewModel;

@interface GisTYKMainViewController : Inc_BaseVC
<
    MAAnnotation,
    MAMapViewDelegate,
    AMapSearchDelegate,
    ptotocolDelegate
>

{
    MAMapView *_mapView;
}
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, assign) BOOL isPushedBy3DTouch;
@property (nonatomic, strong) NSDictionary *point;//从端子信息过来查看的路由

/**
 查看路由 - 文件名
 */
@property (nonatomic, copy) NSString * resLogicName;

/**
 查看路由 - GID
 */
@property (nonatomic, copy) NSString * GID;

@end
