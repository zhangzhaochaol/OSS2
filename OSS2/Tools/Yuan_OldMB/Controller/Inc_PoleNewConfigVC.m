//
//  Inc_PoleNewConfigVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/9/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_PoleNewConfigVC.h"

#import "Inc_PoleNC_ViewModel.h"


#import "Inc_PoleNewConfig_MapView.h"
#import "Inc_PoleStateBtn.h"
#import "Inc_Push_MB.h"

@interface Inc_PoleNewConfigVC ()

/** 地图 */
@property (nonatomic , strong) Inc_PoleNewConfig_MapView * mapView;

@end

@implementation Inc_PoleNewConfigVC

{
    
    // 杆路 map
    NSDictionary * _myDict;
    
    Inc_PoleStateBtn * _addPole;
    Inc_PoleStateBtn * _addSupportingPoints;
    Inc_PoleStateBtn * _poleLineconnect;
    Inc_PoleStateBtn * _nearPole;
    Inc_PoleStateBtn * _nearSupportingPoints;
    
    // 自动定位和手动定位
    UIButton * _nowLocationBtn;
    UIButton * _handleLocationBtn;
    
    UIImageView * _handleLocation_Sympol;
 
    
    Inc_PoleNC_ViewModel * _VM;
    
    NSInteger _yuan_IsAutoAdd;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithDict:(NSDictionary *) myDict {
    
    if (self = [super init]) {
        _myDict = myDict;
        _VM = Inc_PoleNC_ViewModel.shareInstance;
        
        _VM.mb_Dict = myDict;
        _VM.isConnectModel = NO;
        
        // 默认定位到当前位置
        _VM.poleLocationEnum = PoleLocationEnum_Auto;
        
        
        NSNumber * code = [[NSUserDefaults standardUserDefaults] valueForKey:@"yuan_IsAutoAdd"];
        _yuan_IsAutoAdd = code.integerValue;
        
    }
    return self;
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"定位";
    [self UI_Init];
    [self block_Init];
}


#pragma mark - btnClick ---

// 新增电杆
- (void) addPoleClick {
    
    // 关联模式下 无法进行操作
    if (_VM.isConnectModel) {
        [YuanHUD HUDFullText:@"取消关联杆路段模式后 , 再进行操作"];
        return;
    }
    
    
    NSString * lat = [Yuan_Foundation fromFloat:_mapView.mapCenterCoor.latitude];
    NSString * lon = [Yuan_Foundation fromFloat:_mapView.mapCenterCoor.longitude];
    
    // 手动
    if (_yuan_IsAutoAdd == 2) {
        
        NSDictionary * dict = @{@"lat" : lat ,
                                @"lon" : lon ,
                                @"poleLine" : _VM.mb_Dict[@"poleLineName"],
                                @"poleLine_Id" : _VM.mb_Dict[@"GID"],
                                @"poleSubName" : [NSString stringWithFormat:@"%@P",_VM.mb_Dict[@"poleLineName"]],
                                @"poleCode" : [NSString stringWithFormat:@"%@P",_VM.mb_Dict[@"poleLineName"]]
        };
        [YuanHUD HUDFullText:@"Inc_Push_MB 到这了TYKDeviceInfoMationViewController  0000"];

//        TYKDeviceInfoMationViewController * vc =  [Inc_Push_MB pushFrom:self
//                                                           resLogicName:@"pole"
//                                                                   dict:dict
//                                                                   type:TYKDeviceListInsertRfid];
//
//        vc.Yuan_ODFOCC_Block = ^(NSDictionary *changeDict) {
//
//
//            double lat = [Yuan_Foundation fromObject:changeDict[@"lat"]].doubleValue;
//            double lon = [Yuan_Foundation fromObject:changeDict[@"lon"]].doubleValue;
//
//            CLLocationCoordinate2D latlon = CLLocationCoordinate2DMake(lat, lon);
//            // 将资源点加入到地图上
//            [_mapView addPolePointDict:changeDict coor:latlon];
//        };
        
    }
    
    else {
        
        NSMutableArray <Yuan_PointAnnotation *>* pole_Arr = NSMutableArray.array;
        
        for (Yuan_PointAnnotation * anno in _mapView.getRouters) {
            
            if ([anno.dataSource[@"resLogicName"] isEqualToString:@"pole"]) {
                [pole_Arr addObject:anno];
            }
        }
        
        // 走手动模式
        if (pole_Arr.count == 0) {
            
            NSDictionary * dict = @{@"lat" : lat ,
                                    @"lon" : lon ,
                                    @"poleLine" : _VM.mb_Dict[@"poleLineName"],
                                    @"poleLine_Id" : _VM.mb_Dict[@"GID"],
                                    @"poleSubName" : [NSString stringWithFormat:@"%@P",_VM.mb_Dict[@"poleLineName"]],
                                    @"poleCode" : [NSString stringWithFormat:@"%@P",_VM.mb_Dict[@"poleLineName"]]
            };

            TYKDeviceInfoMationViewController * vc =  [Inc_Push_MB pushFrom:self
                                                               resLogicName:@"pole"
                                                                       dict:dict
                                                                       type:TYKDeviceListInsertRfid];

            vc.Yuan_ODFOCC_Block = ^(NSDictionary *changeDict) {


                double lat = [Yuan_Foundation fromObject:changeDict[@"lat"]].doubleValue;
                double lon = [Yuan_Foundation fromObject:changeDict[@"lon"]].doubleValue;

                CLLocationCoordinate2D latlon = CLLocationCoordinate2DMake(lat, lon);
                // 将资源点加入到地图上
                [_mapView addPolePointDict:changeDict coor:latlon];
            };
        }
        
        else {
            
            Yuan_PointAnnotation * lastAnno = pole_Arr.lastObject;
            
            NSDictionary * lastDict = lastAnno.dataSource;
            
            NSInteger large = 0;
            NSMutableDictionary * newPole = NSMutableDictionary.dictionary;
            
            for (Yuan_PointAnnotation * anno in _mapView.getRouters) {

                NSDictionary * dict = anno.dataSource;
                
                NSString * poleCode = dict[@"poleSubName"];
                
                NSArray * codeArr = [poleCode componentsSeparatedByString:@"P"];
                
                NSString * newName = codeArr.lastObject;
                
                if (!newName) {
                    continue;
                }
                
                
                if (newName.integerValue > large) {
                    // 记得 +1
                    large = newName.integerValue;
                }
                
            }
            // 记得 +1
            large++;
            
    
            newPole[@"poleCode"] =
            [NSString stringWithFormat:@"%@P%ld",lastDict[@"poleLine"],large];
            
            newPole[@"poleSubName"] =
            [NSString stringWithFormat:@"%@P%ld",lastDict[@"poleLine"],large];

            
            newPole[@"lat"] = lat;
            newPole[@"lon"] = lon;
            
            for (NSString * key in lastDict.allKeys) {
                
                if (![newPole.allKeys containsObject:key]) {
                    
                    if ([key isEqualToAnyString:@"GID",@"rfid",@"poleId", nil]) {
                        continue;
                    }
                    newPole[key] = lastDict[key];
                }
            
            }
            
            // 走保存接口
            
            
            [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Insert
                                     dict:newPole
                                  succeed:^(id data) {
                    
                NSArray * arr = data;
                
                if (arr.count > 0) {
                    
                    NSDictionary * dict = arr.firstObject;
                    
                    double Coor_lat = lat.doubleValue;
                    double Coor_lon = lon.doubleValue;
                    
                    CLLocationCoordinate2D latlon = CLLocationCoordinate2DMake(Coor_lat, Coor_lon);
                    // 将资源点加入到地图上
                    [_mapView addPolePointDict:dict coor:latlon];
                }
                else {
                    [[Yuan_HUD shareInstance] HUDFullText:@"自动添电杆失败"];
                }
            }];
        }
    }
    

    

    
    
    
    
}

// 新增撑点
- (void) addSupportingPointsClick {
    
    // 关联模式下 无法进行操作
    if (_VM.isConnectModel) {
        [YuanHUD HUDFullText:@"取消关联杆路段模式后 , 再进行操作"];
        return;
    }
    
    NSString * lat = [Yuan_Foundation fromFloat:_mapView.mapCenterCoor.latitude];
    NSString * lon = [Yuan_Foundation fromFloat:_mapView.mapCenterCoor.longitude];
    
    // 手动
    if (_yuan_IsAutoAdd == 2) {
        
        NSDictionary * dict = @{@"lat" : lat ,
                                @"lon" : lon ,
                                @"poleLine" : _VM.mb_Dict[@"poleLineName"],
                                @"poleLine_Id" : _VM.mb_Dict[@"GID"],
                                @"supportPSubName" : [NSString stringWithFormat:@"%@CD",_VM.mb_Dict[@"poleLineName"]],
                                @"supportPointCode" : [NSString stringWithFormat:@"%@CD",_VM.mb_Dict[@"poleLineName"]]
        };
        

        
        TYKDeviceInfoMationViewController * vc =  [Inc_Push_MB pushFrom:self
                                                           resLogicName:@"supportingPoints"
                                                                   dict:dict
                                                                   type:TYKDeviceListInsertRfid];

        vc.Yuan_ODFOCC_Block = ^(NSDictionary *changeDict) {

            double lat = [Yuan_Foundation fromObject:changeDict[@"lat"]].doubleValue;
            double lon = [Yuan_Foundation fromObject:changeDict[@"lon"]].doubleValue;

            CLLocationCoordinate2D latlon = CLLocationCoordinate2DMake(lat, lon);
            // 将资源点加入到地图上
            [_mapView addSupportingPointDict:changeDict coor:latlon];
        };
    }
    
    else {
        
        NSMutableArray <Yuan_PointAnnotation *>* sp_Arr = NSMutableArray.array;
        
        for (Yuan_PointAnnotation * anno in _mapView.getRouters) {
            
            if ([anno.dataSource[@"resLogicName"] isEqualToString:@"supportingPoints"]) {
                [sp_Arr addObject:anno];
            }
        }
        
        // 走手动模式
        if (sp_Arr.count == 0) {
            
            NSDictionary * dict = @{@"lat" : lat ,
                                    @"lon" : lon ,
                                    @"poleLine" : _VM.mb_Dict[@"poleLineName"],
                                    @"poleLine_Id" : _VM.mb_Dict[@"GID"],
                                    @"supportPSubName" : [NSString stringWithFormat:@"%@CD",_VM.mb_Dict[@"poleLineName"]],
                                    @"supportPointCode" : [NSString stringWithFormat:@"%@CD",_VM.mb_Dict[@"poleLineName"]]
            };

            
            TYKDeviceInfoMationViewController * vc =  [Inc_Push_MB pushFrom:self
                                                               resLogicName:@"supportingPoints"
                                                                       dict:dict
                                                                       type:TYKDeviceListInsertRfid];

            vc.Yuan_ODFOCC_Block = ^(NSDictionary *changeDict) {

                double lat = [Yuan_Foundation fromObject:changeDict[@"lat"]].doubleValue;
                double lon = [Yuan_Foundation fromObject:changeDict[@"lon"]].doubleValue;

                CLLocationCoordinate2D latlon = CLLocationCoordinate2DMake(lat, lon);
                // 将资源点加入到地图上
                [_mapView addSupportingPointDict:changeDict coor:latlon];
            };
        }
        
        else {
            
            Yuan_PointAnnotation * lastAnno = sp_Arr.lastObject;
            
            NSDictionary * lastDict = lastAnno.dataSource;
            
            NSInteger large = 0;
            NSMutableDictionary * newSP = NSMutableDictionary.dictionary;
            
            for (Yuan_PointAnnotation * anno in _mapView.getRouters) {

                NSDictionary * dict = anno.dataSource;
                
                NSString * poleCode = dict[@"supportPSubName"];
                
                NSArray * codeArr = [poleCode componentsSeparatedByString:@"CD"];
                
                NSString * newName = codeArr.lastObject;
                
                if (!newName) {
                    continue;
                }
                
                
                if (newName.integerValue > large) {
                    // 记得 +1
                    large = newName.integerValue;
                }
                
            }
            // 记得 +1
            large++;
            
            newSP[@"supportPointCode"] =
            [NSString stringWithFormat:@"%@CD%ld",lastDict[@"poleLine"],large];
            
            newSP[@"supportPSubName"] =
            [NSString stringWithFormat:@"%@CD%ld",lastDict[@"poleLine"],large];

            
            newSP[@"lat"] = lat;
            newSP[@"lon"] = lon;
            
            for (NSString * key in lastDict.allKeys) {
                
                if (![newSP.allKeys containsObject:key]) {
                    
                    if ([key isEqualToAnyString:@"GID",@"rfid",@"supportingPointsId", nil]) {
                        continue;
                    }
                    newSP[key] = lastDict[key];
                }
            
            }
            
            
            // 走保存接口
            
            [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Insert
                                     dict:newSP
                                  succeed:^(id data) {
                    
                NSArray * arr = data;
                
                if (arr.count > 0) {
                    
                    NSDictionary * dict = arr.firstObject;
                    
                    double Coor_lat = lat.doubleValue;
                    double Coor_lon = lon.doubleValue;
                    
                    CLLocationCoordinate2D latlon = CLLocationCoordinate2DMake(Coor_lat, Coor_lon);
                    // 将资源点加入到地图上
                    [_mapView addSupportingPointDict:dict coor:latlon];
                }
                else {
                    [[Yuan_HUD shareInstance] HUDFullText:@"自动添撑点失败"];
                }
            }];
        }
    }
    
}

// 进入或取消关联状态
- (void) poleLineconnectClick {
    
    // 进入关联杆路段模式
    if (_poleLineconnect.myEnum < 6) {
        [_nearPole myState_IsSelect:NO];
        [_nearSupportingPoints myState_IsSelect:NO];
        [_poleLineconnect myState_IsSelect:YES];
        
        _VM.isConnectModel = YES;
        

    }
    
    // 确认关联 并且解除关联模式
    else {
        [_mapView connectPoleLine];
    }
    

}

// 附近电杆
- (void) nearPoleClick {
    
    // 关联模式下 无法进行操作
    if (_VM.isConnectModel) {
        [YuanHUD HUDFullText:@"取消关联杆路段模式后 , 再进行操作"];
        return;
    }
    
    [_mapView showNearPole];
}


// 附近撑点
- (void) nearSupportingPointsClick {
    
    // 关联模式下 无法进行操作
    if (_VM.isConnectModel) {
        [YuanHUD HUDFullText:@"取消关联杆路段模式后 , 再进行操作"];
        return;
    }
    
    [_mapView showNearSP];
}


// 回到当前位置定位
- (void) nowLocationClick {
    
    _VM.poleLocationEnum = PoleLocationEnum_Auto;
    _handleLocation_Sympol.hidden = YES;
    
    [_nowLocationBtn setImage:[UIImage Inc_imageNamed:@"Pole_NowCoor_Select"]
            forState:UIControlStateNormal];
     
    
    [_handleLocationBtn setImage:[UIImage Inc_imageNamed:@"Pole_handleCoor"]
                        forState:UIControlStateNormal];
    
    [YuanHUD HUDFullText:@"自动定位模式"];
    
    [_mapView goBackToPersonCoor];
}


// 手动定位
- (void) handleLocationClick {
    
    _VM.poleLocationEnum = PoleLocationEnum_Handle;
    _handleLocation_Sympol.hidden = NO;
    
    [_nowLocationBtn setImage:[UIImage Inc_imageNamed:@"Pole_NowCoor"]
            forState:UIControlStateNormal];
     
    
    [_handleLocationBtn setImage:[UIImage Inc_imageNamed:@"Pole_handleCoor_Select"]
                        forState:UIControlStateNormal];
    
    [YuanHUD HUDFullText:@"手动定位模式"];
    
}

#pragma mark - block_Init ---

- (void) block_Init {
    
    __typeof(self)weakSelf = self;
    
    weakSelf->_mapView.connectBlock = ^{
        [_poleLineconnect myState_IsSelect:NO];
        _VM.isConnectModel = NO;
    };
    
}

#pragma mark - UI_Init

- (void) UI_Init {
    
    
    _mapView = [[Inc_PoleNewConfig_MapView alloc] init];
    _mapView.vc = self;
    
    
    _addPole = [[Inc_PoleStateBtn alloc] initWithBtnState:PoleState_AddPole];
    _addSupportingPoints = [[Inc_PoleStateBtn alloc] initWithBtnState:PoleState_AddSupportingPoints];
    _poleLineconnect = [[Inc_PoleStateBtn alloc] initWithBtnState:PoleState_AddPoleLine];
    _nearPole = [[Inc_PoleStateBtn alloc] initWithBtnState:PoleState_NearPoleLine];
    _nearSupportingPoints = [[Inc_PoleStateBtn alloc] initWithBtnState:PoleState_NearSupportingPoints];
    
    
    [_addPole addTarget:self
                 action:@selector(addPoleClick)
       forControlEvents:UIControlEventTouchUpInside];
    
    [_addSupportingPoints addTarget:self
                             action:@selector(addSupportingPointsClick)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [_poleLineconnect addTarget:self
                         action:@selector(poleLineconnectClick)
               forControlEvents:UIControlEventTouchUpInside];
    
    [_nearPole addTarget:self
                  action:@selector(nearPoleClick)
        forControlEvents:UIControlEventTouchUpInside];
    
    [_nearSupportingPoints addTarget:self
                              action:@selector(nearSupportingPointsClick)
                    forControlEvents:UIControlEventTouchUpInside];
    
    
    _nowLocationBtn = [UIView buttonWithImage:@"Pole_NowCoor_Select"
                                    responder:self
                                    SEL_Click:@selector(nowLocationClick)
                                        frame:CGRectNull];
    
    
    _handleLocationBtn = [UIView buttonWithImage:@"Pole_handleCoor"
                                       responder:self
                                       SEL_Click:@selector(handleLocationClick)
                                           frame:CGRectNull];
    
    _handleLocation_Sympol = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"Pole_Center"]
                                                frame:CGRectNull];

    _handleLocation_Sympol.hidden = YES;
    
    
    [self.view addSubviews:@[_addPole,
                             _addSupportingPoints,
                             _poleLineconnect,
                             _nearPole,
                             _nearSupportingPoints,
                             _mapView,
                             _nowLocationBtn,
                             _handleLocationBtn,
                             _handleLocation_Sympol]];
    
    
    [self.view bringSubviewToFront:_nowLocationBtn];
    [self.view bringSubviewToFront:_handleLocationBtn];
    [self.view bringSubviewToFront:_handleLocation_Sympol];
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    
    float limit = Horizontal(15);
    
    [_handleLocationBtn YuanToSuper_Bottom:BottomZero + limit * 2];
    [_handleLocationBtn YuanToSuper_Right:limit * 2];
    
    [_nowLocationBtn YuanAttributeHorizontalToView:_handleLocationBtn];
    [_nowLocationBtn YuanMyEdge:Right ToViewEdge:Left ToView:_handleLocationBtn inset: -limit];
        
    NSArray * btns = @[_addPole,
                       _addSupportingPoints,
                       _poleLineconnect,
                       _nearPole,
                       _nearSupportingPoints];
    
    NSInteger index = 0;
    
    for (UIView * view in btns) {
        
        [self.view bringSubviewToFront:view];
        
        [view YuanToSuper_Left:limit];
        [view YuanToSuper_Top: NaviBarHeight + index * Vertical(30) + 2 + limit];
        [view Yuan_EdgeWidth:Horizontal(130)];
        [view Yuan_EdgeHeight:Vertical(30)];
        
        index++;
    }
    
    [_mapView Yuan_Edges:UIEdgeInsetsMake(NaviBarHeight, 0, BottomZero, 0)];
    
    [_handleLocation_Sympol YuanAttributeHorizontalToView:_mapView];
    [_handleLocation_Sympol YuanAttributeVerticalToView:_mapView];
    
}





@end
