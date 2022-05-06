//
//  PoleLineMapMainTYKViewController.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/10/9.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"


@class IWPViewModel;
@class IWPPropertiesSourceModel;

@protocol PoleLineMapDelegate <NSObject>
-(void)deletePoleWithDict:(NSDictionary *)dict withClass:(Class)class;
-(void)newPoleWithDict:(NSDictionary *)dict withClass:(Class)class;
-(void)newSurpportingPoints:(NSDictionary *)dict withClass:(Class)class;
-(void)newPureOfflinePoleEdited:(NSDictionary *)dict;
@end

@interface PoleLineMapMainTYKViewController : Inc_BaseVC<CLLocationManagerDelegate,MAAnnotation,MAMapViewDelegate,UITableViewDataSource,UITableViewDelegate,AMapSearchDelegate,ptotocolDelegate>
{
    MAMapView *_mapView;
}
@property (nonatomic, strong) AMapSearchAPI *search;
@property(strong,nonatomic)NSMutableDictionary *poleLine;//当前杆路；
@property (nonatomic, weak) id <PoleLineMapDelegate> delegate;

@end
