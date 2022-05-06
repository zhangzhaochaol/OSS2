//
//  Yuan_DeleteCableVC.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2021/1/11.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_DeleteCableVC.h"

#import "Yuan_DC_ChangeConfigVC.h"

// mapView
#import "Yuan_DC_MapView.h"



// 业务类
#import "Yuan_DC_VM.h"
#import "Yuan_DC_HttpModel.h"


//全部撤缆接口
#import "Inc_DC_HttpModel1.h"


@interface Yuan_DeleteCableVC () <MLMenuViewDelegate>

/** map */
@property (nonatomic,strong) Yuan_DC_MapView *mapView;

@end



@implementation Yuan_DeleteCableVC

{
    
//    // 图例
//    UIImageView * _markImage;
//
//    // 收起展开 按钮
//    UIButton * _scalingBtn;
    
    // 公里
    UILabel * _kilimeter;
    
    // 定位
    UIButton * _locationBtn;
    
    // 资源
    UIButton * _resourceBtn;
    
    BOOL _markImageIsShow;
    
    NSLayoutConstraint * _scalingBtnConstraint;
    
    Yuan_DC_VM * _VM;
    
    // 全部撤缆
    UIButton * _allDeleteBtn;
    
}




- (void)viewDidLoad {

    [super viewDidLoad];

    // 默认 图例
    _markImageIsShow = true;
    
    _VM = Yuan_DC_VM.shareInstance;

    self.title = @"光缆段GIS";
    
    NSString * cableId = _mb_Dict[@"GID"];
//    cableId = @"150007010000001467337566";
    _VM.cableId = cableId;
    
    [self naviBarSet];
    
    
    [self UI_Init];
    
    // 获取光缆段下属路由
    [self http_GetStartEndDevice];
    

    //进入页面设置yes  撤缆弹窗使用
//    [[INCUserInfomation sharedInformation] setIsFirstDelete:YES];

}








// 获取起始和终止设备接口
- (void) http_GetStartEndDevice {
    
    // 150007010000001467337566
    [Yuan_DC_HttpModel http_GetStartEndDevice:_VM.cableId
                                      success:^(id  _Nonnull result) {
            
        NSArray * arr = result;
        
        NSDictionary * resultDict = arr.firstObject;
        
        NSArray * optSectArr = resultDict[@"optSect"];
        
        if (!optSectArr || optSectArr.count == 0) {
            [[Yuan_HUD shareInstance] HUDFullText:@"未查询到起始和终止设备"];
            return;;
        }
        
        NSDictionary * cableDict = optSectArr.firstObject;
        
        NSMutableDictionary * startDevceDict = NSMutableDictionary.dictionary;
        startDevceDict[@"id"] = cableDict[@"sid"];
        startDevceDict[@"typeId"] = cableDict[@"stypeId"];
        startDevceDict[@"type"] = cableDict[@"stype"];
        startDevceDict[@"lat"] = cableDict[@"slat"];
        startDevceDict[@"lon"] = cableDict[@"slon"];
        startDevceDict[@"name"] = cableDict[@"sname"];
        startDevceDict[@"position"] = @"start";

        
        NSMutableDictionary * endDevceDict = NSMutableDictionary.dictionary;
        endDevceDict[@"id"] = cableDict[@"eid"];
        endDevceDict[@"typeId"] = cableDict[@"etypeId"];
        endDevceDict[@"type"] = cableDict[@"etype"];
        endDevceDict[@"lat"] = cableDict[@"elat"];
        endDevceDict[@"lon"] = cableDict[@"elon"];
        endDevceDict[@"name"] = cableDict[@"ename"];
        endDevceDict[@"position"] = @"end";
        
        [_mapView loadStartEnd:@[startDevceDict,endDevceDict]];
        
        
        // 查询完起始终止设备后 , 再去查询 路由
        [_mapView http_GetCableRoute];
        
    }];
}




// 获取半径内的资源
- (void) http_GetRadiusCircleSubResource {
    
    CLLocationCoordinate2D location = _mapView.mapView.region.center;
    
    [_mapView.mapView setCenterCoordinate:location];
    
    
    // 根据地图中心点经纬度 , 获取范围1000米的资源 _mapView.mapView.region.center
    [Yuan_DC_HttpModel http_GetCircleRadiusSubResMapCenterCoor:location
                                                       success:^(id  _Nonnull result) {
    
        NSArray * resultArr = result;
        
        NSMutableArray * mt_Arr = NSMutableArray.array;
        
        for (NSDictionary * resArrDict in resultArr) {
            
            NSDictionary * singleDic = resArrDict.allValues.firstObject;
            NSArray * contentArr = singleDic[@"content"];
            
            if (contentArr.count == 0 || !contentArr || [contentArr obj_IsNull]) {
                continue;
            }
            
            [mt_Arr addObjectsFromArray:contentArr];
        }
        
        
        [_mapView http_LoadCircleRadiusRes:mt_Arr];
    }];
    
    
    
}



#pragma mark - UI 和 点击事件 ---
- (void) UI_Init {
    
    _mapView = Yuan_DC_MapView.alloc.init;
    _mapView.vc = self;
    
    NSString * cableSectionLength = _mb_Dict[@"cableSectionLength"] ?: @"0";
    cableSectionLength = [NSString stringWithFormat:@"%@米",cableSectionLength];
    
    
    _kilimeter = [UIView labelWithTitle:cableSectionLength frame:CGRectNull];
    [_kilimeter cornerRadius:5 borderWidth:0 borderColor:nil];
    _kilimeter.textAlignment = NSTextAlignmentCenter;
    
    _kilimeter.backgroundColor = UIColor.mainColor;
    _kilimeter.textColor = UIColor.whiteColor;
    
    
    
    _locationBtn = [UIButton buttonWithImage:@"DC_dingwei"
                                   responder:self
                                   SEL_Click:@selector(locationClick:)
                                       frame:CGRectNull];
    
    
    _resourceBtn = [UIButton buttonWithImage:@"DC_ziyuan"
                                   responder:self
                                   SEL_Click:@selector(resourceBtnClick)
                                       frame:CGRectNull];
    
    
    _allDeleteBtn = [UIButton buttonWithImage:@"DC_allDelete"
                                   responder:self
                                   SEL_Click:@selector(allDeleteBtnClick)
                                       frame:CGRectNull];
    
    [self.view addSubviews:@[_mapView]];
    
    [_mapView addSubviews:@[_kilimeter,
                            _locationBtn,
                            _resourceBtn,
                            _allDeleteBtn]];
    
    [self yuan_layoutAllSubViews];
    
}


// 定位按钮 点击事件
- (void) locationClick:(UIButton *)sender {
    
    if (_VM.isCableing) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"正在配置中 .."];
        return;
    }
    
    _VM.isLocationing = !_VM.isLocationing;

    // 正在定位中
    if (_VM.isLocationing) {
        [sender setImage:[UIImage Inc_imageNamed:@"DC_dingwei_Select"] forState:UIControlStateNormal];
        [[Yuan_HUD shareInstance] HUDFullText:@"正在定位中..."];
        [self showCenterCircle];
    }
    
    else {
        [sender setImage:[UIImage Inc_imageNamed:@"DC_dingwei"] forState:UIControlStateNormal];
        [self hideCenterCircle];
    }
    
    
}



// 资源按钮 点击事件
- (void) resourceBtnClick {
    
    
    if (_VM.isCableing) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"正在配置中 .."];
        return;
    }
    
    
    [UIAlert alertSmallTitle:@"查询地图中心半径1000米的资源"
               agreeBtnBlock:^(UIAlertAction *action) {
        
        // 不论怎样 , 定位按钮 都归为未选中状态
        [_locationBtn setImage:[UIImage Inc_imageNamed:@"DC_dingwei"] forState:UIControlStateNormal];
        _VM.isLocationing = NO;
        [self hideCenterCircle];
        
        // 发起请求
        [self http_GetRadiusCircleSubResource];
        
    }];
    
    
    
}

- (void)allDeleteBtnClick {
    
    [_allDeleteBtn setImage:[UIImage Inc_imageNamed:@"DC_allDeleteS"] forState:UIControlStateNormal];
    
    [self alertSmallTitle:@"⚠️全部撤缆后，所有承载物会与光缆段解除关联关系，是否进行撤缆操作？" agreeBtnBlock:^(UIAlertAction *action) {
        [_allDeleteBtn setImage:[UIImage Inc_imageNamed:@"DC_allDelete"] forState:UIControlStateNormal];
        //全部撤缆
        NSLog(@"全部撤缆");
        [_mapView http_AllDeleteRoute:@{@"id":_mb_Dict[@"GID"]}];
        
    } cancelBtnBlock:^(UIAlertAction *action) {
        [_allDeleteBtn setImage:[UIImage Inc_imageNamed:@"DC_allDelete"] forState:UIControlStateNormal];
    }];
    
    
}

#pragma mark - 显示与隐藏 屏幕中心1000米半径的圆 ---

- (void) showCenterCircle {
    [_mapView showCenterCircle];
}

- (void) hideCenterCircle {
    [_mapView hideCenterCircle];
}


#pragma mark - 屏幕适配

- (void) yuan_layoutAllSubViews {
    
    float limit = Horizontal(15);
    
    [_mapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(NaviBarHeight,
                                                                      0,
                                                                      BottomZero,
                                                                      0)];
        
    
    
    // 右侧
    [_kilimeter autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_kilimeter autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
    [_kilimeter autoSetDimensionsToSize:CGSizeMake(60, 25)];
    
    
    [_resourceBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_resourceBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_kilimeter withOffset:limit];
    
    [_locationBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_locationBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_resourceBtn withOffset:limit/2];
    

    [_allDeleteBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_allDeleteBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_locationBtn withOffset:limit/2];
}


- (void)dealloc {
    
    _VM.isLocationing = NO;
    _VM.isCableing = NO;
}


- (void) naviBarSet {
    
    
    UIBarButtonItem * rightBtn = [UIView getBarButtonItemWithTitleStr:@"切换" Sel:@selector(goTo) VC:self];
    
    self.navigationItem.rightBarButtonItems = @[rightBtn];
}


- (void) goTo {
    
    Yuan_DC_ChangeConfigVC * vc = Yuan_DC_ChangeConfigVC.alloc.init;
    
    self.definesPresentationContext = true;
    
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    [self presentViewController:vc animated:NO completion:^{
        
        // 只让 view半透明 , 但其上方的其他view不受影响
        vc.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    }];
}

- (void) alertSmallTitle:(NSString *)title
           agreeBtnBlock:(void(^)(UIAlertAction *action))block
           cancelBtnBlock:(void(^)(UIAlertAction *action))cancel{
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *IKnowAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 把点击事件回调给调用的界面
        if (block) {
            block(action);
        }
    }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //什么也不做
        // 把点击事件回调给调用的界面
        if (cancel) {
            cancel(action);
        }
    }];
    
    
    // Add the actions.
    [alertController addAction:IKnowAction];
    [alertController addAction:cancelAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    
    
    
}


@end
