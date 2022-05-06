//
//  Yuan_OBD_PointVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_OBD_PointVC.h"
#import "Yuan_BusOBD_PointView.h"
#import "Yuan_OBD_PointsHttpModel.h"

@interface Yuan_OBD_PointVC ()

/** 输入输出 */
@property (nonatomic , strong) Yuan_BusOBD_PointView * obd_pointView;

@end

@implementation Yuan_OBD_PointVC

{
    // 所属分光器Id
    NSString * _superResId;
    
}


#pragma mark - 初始化构造方法

- (instancetype)initWithSuperResId:(NSString *) superResId {
    
    if (self = [super init]) {
        _superResId = superResId;
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // UI 创建
    
    _obd_pointView = [[Yuan_BusOBD_PointView alloc] initWithSuperResId:_superResId];
    _obd_pointView.pointEnum = BusOBD_PointView_Select;
    _obd_pointView.vc = self;
    
    
    __typeof(self)weakSelf = self;
    _obd_pointView.uninitialized_PointBlock = ^{
      
        [weakSelf Http_InitPoints];
    };
    
    [self.view addSubviews:@[_obd_pointView]];
    
    [self yuan_LayoutSubViews];
}

#pragma mark - http ---

// 如果没有初始化端子的话 , 需要进行初始化
- (void) Http_InitPoints {
    
    [Yuan_OBD_PointsHttpModel Http_OBD_Point_Init:_superResId
                                          success:^(id  _Nonnull result) {
            
        [YuanHUD HUDFullText:@"初始化端子成功"];
        Pop(self);
    }];
}


- (void) yuan_LayoutSubViews {
    
    [_obd_pointView YuanToSuper_Top:NaviBarHeight];
    [_obd_pointView YuanToSuper_Left:0];
    [_obd_pointView YuanToSuper_Right:0];
    [_obd_pointView autoSetDimension:ALDimensionHeight toSize:Vertical(250)];
}


@end
