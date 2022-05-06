//
//  PipeMapMainTYKViewController.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/10/9.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
@class IWPViewModel;
@class IWPPropertiesSourceModel;

@protocol PipeMapMainTYKDelegate <NSObject>
-(void)deleteWellWithDict:(NSDictionary *)dict withClass:(Class)class;
-(void)deleteLedUpWithDict:(NSDictionary *)dict withClass:(Class)class;
-(void)deleteOccWithDict:(NSDictionary *)dict withClass:(Class)class;

-(void)newWellWithDict:(NSDictionary *)dict withClass:(Class)class;
-(void)newLedUpWithDict:(NSDictionary *)dict withClass:(Class)class;
-(void)newOccWithDict:(NSDictionary *)dict withClass:(Class)class;

/**
 2017年02月17日 添加此代理方法，为使纯离线管道中的井信息被修改后，可以正常保存到本地中。
 */
-(void)newPureOfflineWellEdited:(NSDictionary *)dict;

@end


@interface PipeMapMainTYKViewController : Inc_BaseVC<CLLocationManagerDelegate,MAAnnotation,MAMapViewDelegate,AMapSearchDelegate,UITableViewDataSource,UITableViewDelegate,ptotocolDelegate>
{
    CLLocationManager *locationManager;
    
}
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, weak) id <PipeMapMainTYKDelegate> delegate;
@property(strong,nonatomic) NSMutableDictionary * pipe;//当前管道；
@property (nonatomic, weak) MAMapView *mapView;

@end
