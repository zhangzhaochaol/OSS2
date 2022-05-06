//
//  Inc_NewMB_AssistMapVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/11.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewMB_AssistMapVC.h"

@interface Inc_NewMB_AssistMapVC () <MAMapViewDelegate , MLMenuViewDelegate>
/** 地图 */
@property (nonatomic , strong) MAMapView * mapView;

/** 地图中心图标 */
@property (nonatomic , strong) UIImageView * centerImage;

@end

@implementation Inc_NewMB_AssistMapVC
{
    
    // 维度
    double _lat;
    
    // 经度
    double _lon;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self naviBarSet];
    
    _mapView = [UIView mapViewAndDelegate:self frame:CGRectNull];

    [self.view addSubview:_mapView];
    
    [_mapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(NaviBarHeight,
                                                                      0,
                                                                      BottomZero,
                                                                      0)];
    
    
    _centerImage = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"DC_shizi"]
                                      frame:CGRectNull];
    
    [self.view addSubview:_centerImage];
    [self.view bringSubviewToFront:_centerImage];
    
    [_centerImage YuanAttributeHorizontalToView:self.view];
    [_centerImage YuanAttributeVerticalToView:self.view];
}



#pragma mark - delegate ---


/**
 * @brief 地图移动结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    
    CLLocationCoordinate2D coor = mapView.region.center;
    
    _lat = coor.latitude;
    _lon = coor.longitude;
}





/// 导航栏右侧按钮
- (void) naviBarSet {
    
    UIBarButtonItem * barBtn = [UIView getBarButtonItemWithTitleStr:@"选择"
                                                                Sel:@selector(barClick)
                                                                 VC:self];;
    self.navigationItem.rightBarButtonItems = @[barBtn];
}




- (void) barClick {
    
    
    if (_lat != 0 && _lon != 0) {
        
        if (_Type4_GetLatLonBlock) {
         
            [UIAlert alertSmallTitle:@"是否使用该位置"
                       agreeBtnBlock:^(UIAlertAction *action) {
                
                [self setTheCoor];
            }];
            
        }
    }
    
    else {
        [YuanHUD HUDFullText:@"未获取到地图中心点经纬度"];
    }
    
    
}

// 使用该地址
- (void) setTheCoor {
    
    _Type4_GetLatLonBlock(_lat,_lon);
    Pop(self);
    
}







@end
