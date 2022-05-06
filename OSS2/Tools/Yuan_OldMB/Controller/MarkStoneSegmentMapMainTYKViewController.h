//
//  MarkStoneSegmentMapMainTYKViewController.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2018/1/29.
//  Copyright © 2018年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
@class IWPViewModel;
@class IWPPropertiesSourceModel;

@protocol MarkStoneSegmentMapMainTYKDelegate <NSObject>
-(void)deleteMarkStoneWithDict:(NSDictionary *)dict withClass:(Class)class;
-(void)newMarkStoneWithDict:(NSDictionary *)dict withClass:(Class)class;

/**
 2017年02月17日 添加此代理方法，为使纯离线管道中的井信息被修改后，可以正常保存到本地中。
 */
-(void)newPureOfflineWellEdited:(NSDictionary *)dict;

@end

@interface MarkStoneSegmentMapMainTYKViewController : Inc_BaseVC<CLLocationManagerDelegate,MAAnnotation,MAMapViewDelegate,AMapSearchDelegate,ptotocolDelegate>
{
    MAMapView *_mapView;
}
@property (nonatomic, weak) id <MarkStoneSegmentMapMainTYKDelegate> delegate;
@property(strong,nonatomic) NSMutableDictionary * markStoneSegment;//当前标石段；

@end
