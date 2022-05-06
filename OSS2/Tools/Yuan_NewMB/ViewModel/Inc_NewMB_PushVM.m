//
//  Inc_NewMB_PushVM.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/11/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewMB_PushVM.h"




// *** *** 机房

//#import "Yuan_UseElectricityVC.h"       //用电管理
//#import "Yuan_GeneratorRackConfigVC.h"  //机房机架
//#import "Yuan_SiteMonitorListVC.h"      //监控
//#import "Inc_NewMBEquipCollectVC.h"     //机房下属设备
//#import "Inc_NewMB_AssistDevCollectVC.h" //机房所属设备


// *** *** 光缆段
//#import "ResourceTYKListViewController.h"

//#import "Yuan_DeleteCableVC.h"
//#import "Inc_CableMergeVC.h"
//#import "Inc_CableSplitVC.h"
#import "Inc_NewMB_ListVC.h"
#import "Inc_NewMB_DetailVC.h"

// *** ***  拍照
//#import "Yuan_TYKPhotoVC.h"




@implementation Inc_NewMB_PushVM

{
    UIViewController * _vc;
    
    NSMutableDictionary * _requestDict;
    
    Yuan_NewMB_ModelEnum_ _enum;
    
    AMapNaviCompositeManager * _compositeManager;
}



#pragma mark - 初始化构造方法

- (instancetype)initWithEnum:(Yuan_NewMB_ModelEnum_) Enum
                      MbDict:(NSDictionary *) dict
                          vc:(UIViewController *) vc {
    
    if (self = [super init]) {
        
        _enum = Enum;
        _requestDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        _vc = vc;
        
        // 对旧字段的判断补充 resLogicName  GID 等
        // 每个旧资源的新模板 , 都需要对字段进行补充
        [self oldKeysConfig];
    }
    return self;
}



// 在右侧是否显示导航栏按钮
- (BOOL) isHaveRightNaviMenu {
    
    // 存在右上角按钮Menu的资源
    if (_enum == Yuan_NewMB_ModelEnum_room) {
        return YES;
    }
    
    else if (_enum == Yuan_NewMB_ModelEnum_optSect) {
        return YES;
    }
    
    else if (_enum == Yuan_NewMB_ModelEnum_complexBox) {
        return YES;
    }
    
    else if (_enum == Yuan_NewMB_ModelEnum_module) {
        return YES;
    }
    return NO;
}


// Menu Array

- (NSArray *) MenuTitleArr {
    
    if (_enum == Yuan_NewMB_ModelEnum_room) {
        
        return @[@"所属设备",@"用电管理",@"平面图",@"监控",@"下属设备",@"导航"];
    }
    
    if (_enum == Yuan_NewMB_ModelEnum_optSect) {
        
        return @[@"标签",@"GIS",@"光缆段合并",@"光缆段拆分"];
    }
    
    if (_enum == Yuan_NewMB_ModelEnum_complexBox) {
        
        return @[@"拍照",@"导航"];
//        return @[@"拍照",@"导航",@"列框",@"复制"];
//        return @[@"拍照",@"导航",@"列框",@"分光器",@"复制"];
    }
    
    if (_enum == Yuan_NewMB_ModelEnum_module) {
        
        return @[@"光端子"];
//        return @[@"拍照",@"导航",@"列框",@"复制"];
    }
    return @[];
}

- (void) MenuSelectorIndex:(NSInteger) index {
    
    SEL selectors[15];
    int size = 0;
    
    if (_enum == Yuan_NewMB_ModelEnum_room) {
        
        // 所属设备
        selectors[0] = @selector(EquipmentPointBtnClick);
        
        // 用电管理
        selectors[1] = @selector(UseElectClick);
        
        // 平面图
        selectors[2] = @selector(GeneratorRackConfig);
        
        // 监控
        selectors[3] = @selector(SiteMonitorList);
        
        // 下属设备
        selectors[4] = @selector(stationBase_Equipment);
        
        // 导航
        selectors[5] = @selector(Navigation);
        
        size = 6;
    }
    
    if (_enum == Yuan_NewMB_ModelEnum_optSect) {
        
        // 标签
        selectors[0] = @selector(showRFIDInfo);
        
        // GIS
        selectors[1] = @selector(cableDeleteCableClick);
        
        // 光缆段合并
        selectors[2] = @selector(cableMergeClick);
        
        // 光缆段拆分
        selectors[3] = @selector(cableSplitClick);
        
        size = (int)[self MenuTitleArr].count;
    }

    if (_enum == Yuan_NewMB_ModelEnum_complexBox) {
        
        // 拍照
        selectors[0] = @selector(Yuan_PhtotClick);
        
        // 导航
        selectors[1] = @selector(Navigation);
        
        // 列框
        selectors[2] = @selector(showShelfClick);
        
        // 分光器
        selectors[3] = @selector(showOBDClick);
        
        // 复制
        selectors[4] = @selector(copyClick);
        
        
        size = (int)[self MenuTitleArr].count;
    }

    if (_enum == Yuan_NewMB_ModelEnum_module) {
        
        // 光端子
        selectors[0] = @selector(PushToTerm);
                
        size = (int)[self MenuTitleArr].count;
    }
    if (index > size -1) {
        return;
    }
    
    SEL selector = selectors[index];
    
    if ([self respondsToSelector:selector]) {
        // 执行点击事件
        [self performSelector:selector];
    }

}


#pragma mark - 对旧字段的特殊处理 ---
- (void) oldKeysConfig {
    
    NSString * resLogicName = @"";
    
    // 机房
    if (_enum == Yuan_NewMB_ModelEnum_room) {
        
        _requestDict[@"GID"] = _requestDict[@"gid"];
        _requestDict[@"lon"] = _requestDict[@"x"];
        _requestDict[@"lat"] = _requestDict[@"y"];
        
        resLogicName = @"generator";
        NSString * searchName = [NSString stringWithFormat:@"%@Name",resLogicName];
        _requestDict[@"resLogicName"] = resLogicName;
        _requestDict[searchName] = _requestDict[@"name"];
        
    }
    
    // 光缆段
    if (_enum == Yuan_NewMB_ModelEnum_optSect) {

        //zzc
        _requestDict[@"GID"] = _requestDict[@"gid"];

        _requestDict[@"cableStart_Id"] = _requestDict[@"beginId"];
        _requestDict[@"cableEnd_Id"] = _requestDict[@"endId"];
        
        _requestDict[@"cableStart"] = _requestDict[@"beginName"];
        _requestDict[@"cableEnd"] = _requestDict[@"endName"];
        
        _requestDict[@"cableName"] = _requestDict[@"name"];
        _requestDict[@"cableSectionLength"] = _requestDict[@"length"];
        //所属光缆
        _requestDict[@"route"] = _requestDict[@"optName"];
        
        
        NSString * cableStart_Type = @"";
        NSString * cableEnd_Type = @"";
        
        NSString * beginTypeId = _requestDict[@"beginTypeId"];
        NSString * endTypeId = _requestDict[@"endTypeId"];
        
        
        switch (beginTypeId.intValue) {
                
            case 302:   // odf
                cableStart_Type = @"1";
                break;
            case 705:   // 接头
                cableStart_Type = @"2";
                break;
            case 703:   // occ
                cableStart_Type = @"3";
                break;
            case 704:   // odb
                cableStart_Type = @"4";
                break;
            case 205:   // 机房
                cableStart_Type = @"6";
                break;
            case 383:   // 综合箱
                cableStart_Type = @"7";
                break;
            case 208:   // 放置点
                cableStart_Type = @"8";
                break;
                
            default:
                break;
        }
        
        
        switch (endTypeId.intValue) {
                
            case 302:   // odf
                cableEnd_Type = @"1";
                break;
            case 705:   // 接头
                cableEnd_Type = @"2";
                break;
            case 703:   // occ
                cableEnd_Type = @"3";
                break;
            case 704:   // odb
                cableEnd_Type = @"4";
                break;
            case 205:   // 机房
                cableEnd_Type = @"6";
                break;
            case 383:   // 综合箱
                cableEnd_Type = @"7";
                break;
            case 208:   // 放置点
                cableEnd_Type = @"8";
                break;
                
                
            default:
                break;
        }
        
        
        
        
        _requestDict[@"cableStart_Type"] = cableStart_Type;
        _requestDict[@"cableEnd_Type"] = cableEnd_Type;
        
        resLogicName = @"cable";
        NSString * searchName = [NSString stringWithFormat:@"%@Name",resLogicName];
        _requestDict[@"resLogicName"] = resLogicName;
        _requestDict[searchName] = _requestDict[@"name"];
    }
    
    // 综合箱
    if (_enum == Yuan_NewMB_ModelEnum_complexBox) {

        _requestDict[@"GID"] = _requestDict[@"gid"];
        _requestDict[@"lon"] = _requestDict[@"x"];
        _requestDict[@"lat"] = _requestDict[@"y"];
        resLogicName = @"generator";
        NSString * searchName = [NSString stringWithFormat:@"%@Name",resLogicName];
        _requestDict[@"resLogicName"] = resLogicName;
        _requestDict[searchName] = _requestDict[@"name"];
    }
    
    // 光端子
    if (_enum == Yuan_NewMB_ModelEnum_module) {

        _requestDict[@"GID"] = _requestDict[@"gid"];

    }
    
    
    
}

- (NSDictionary *) getOldKeys {
    return _requestDict;
}

#pragma mark - 跳转方法 ---

#pragma mark - 机房侧边栏跳转 ---

// 用电管理
- (void) UseElectClick {
    
//    Yuan_UseElectricityVC * useElect = Yuan_UseElectricityVC.alloc.init;
//    useElect.moban_Dict = _requestDict;
//    Push(_vc, useElect);
}


// 机房机架
- (void) GeneratorRackConfig {
    
    // 横屏处理  智网通中不可以使用该功能
    [YuanHUD HUDFullText:@"智网通中不可以使用该功能"];

    //    delegate.isCanLandscape = YES;
//
//    [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft]
//                                forKey:@"orientation"];
//
//    Yuan_GeneratorRackConfigVC * config = [[Yuan_GeneratorRackConfigVC alloc] init];
//    config.mb_Dict = _requestDict;
//    Push(_vc, config);
}


/// 监控

- (void) SiteMonitorList {
//
//    Yuan_SiteMonitorListVC * list = Yuan_SiteMonitorListVC.alloc.init;
//
//    Push(_vc, list);
}


// 局站、机房、设备放置点   下属设备
- (void) stationBase_Equipment {
    
//    Inc_NewMBEquipCollectVC * equip = [[Inc_NewMBEquipCollectVC alloc] init];
//    equip.title = @"下属设备";
//    equip.gid = _requestDict[@"GID"];
//    equip.requestDict = _requestDict;
//
//    Push(_vc, equip);
}


// 所属设备
- (void) EquipmentPointBtnClick {
    
    
//    Inc_NewMB_AssistDevCollectVC * assDev = [[Inc_NewMB_AssistDevCollectVC alloc] init];
//
//    assDev.requestDict = _requestDict;
//
//    Push(_vc, assDev);
}


//导航
- (void) Navigation {
    
    
    _compositeManager = [[AMapNaviCompositeManager alloc] init];  // 初始化
    _compositeManager.delegate = self;  // 如果需要使用AMapNaviCompositeManagerDelegate的相关回调（如自定义语音、获取实时位置等），需要设置delegate
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),  ^{
        
        if ([_requestDict[@"lat"] doubleValue] != 0 && [_requestDict[@"lon"] doubleValue] != 0) {
            AMapNaviCompositeUserConfig *config = [[AMapNaviCompositeUserConfig alloc] init];

            [config setRoutePlanPOIType:AMapNaviRoutePlanPOITypeEnd location:[AMapNaviPoint locationWithLatitude:[_requestDict[@"lat"] doubleValue] longitude:[_requestDict[@"lon"] doubleValue]] name:@"目标位置" POIId:nil];  //传入终点
            [_compositeManager presentRoutePlanViewControllerWithOptions:config];
        }else{
            [YuanHUD HUDFullText:@"请先获取经纬度"];
        }
        
    });
    
}

#pragma mark - 光缆段侧边栏跳转 ---

#pragma mark 光缆段RFID信息表按钮点击事件

//标签
-(void)showRFIDInfo{
    
    if ([self isOfflineDevice]) {
        AlertShow([UIApplication sharedApplication].keyWindow, @"离线模式下不可用", 2.f, @"");
        return;
    }
    
    NSArray *array = [_vc.navigationController viewControllers];
    ////从统一库资源信息列表页面进来 ｜｜ 从统一库扫描二维码页面进来
    if ((array.count>1&&[[array objectAtIndex:array.count-2] isKindOfClass:[Inc_NewMB_ListVC class]]) || (array.count>0&&[[array objectAtIndex:array.count-1] isKindOfClass:[Inc_NewMB_DetailVC class]])) {
        //从统一库资源信息列表页面进来
//        ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
//        resourceTYKListVC.dicIn = _requestDict;
//        resourceTYKListVC.fileName = @"rfidInfo";
//        resourceTYKListVC.showName = @"地址";
//        [_vc.navigationController pushViewController:resourceTYKListVC animated:YES];
        return;
    }
}

//撤揽
- (void) cableDeleteCableClick {
    
//    Yuan_DeleteCableVC * deleteCable_Gis =  [[Yuan_DeleteCableVC alloc] init];
//
//    deleteCable_Gis.mb_Dict = _requestDict;
//
//
//    Push(_vc, deleteCable_Gis);
}

//合并
- (void) cableMergeClick {
    
//    Inc_CableMergeVC *vc = [[Inc_CableMergeVC alloc]init];
//    vc.mb_Dict = _requestDict;
//    vc.title = @"光缆段合并";
//    Push(_vc, vc);
    
}

//拆分
- (void) cableSplitClick {

//    Inc_CableSplitVC *vc = [[Inc_CableSplitVC alloc]init];
//    vc.mb_Dict = _requestDict;
//    vc.title = @"光缆段拆分";
//    Push(_vc, vc);
}

#pragma mark - 综合箱侧边栏跳转 ---


//拍照
- (void) Yuan_PhtotClick {
    
    
//    Yuan_TYKPhotoVC * vc = Yuan_TYKPhotoVC.alloc.init;
//
//    vc.moban_Dict = _requestDict;
//
//    Push(_vc, vc);
}

//列框
-(void)showODFMianBanHandler {
    
    if ([self isOfflineDevice]) {
        AlertShow([UIApplication sharedApplication].keyWindow, @"离线模式下不可用", 2.f, @"");
        return;
    }
    
//    ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
//    resourceTYKListVC.dicIn = [_requestDict mutableCopy];
//    resourceTYKListVC.fileName = @"cnctShelf";
////    resourceTYKListVC.sourceFileName = @"OBD_Equt";
//    resourceTYKListVC.showName = @"列/框";
//    [_vc.navigationController pushViewController:resourceTYKListVC animated:YES];
    
}

//列框
-(void)showShelfClick {
    
    Inc_NewMB_ListVC * list = [[Inc_NewMB_ListVC alloc] initWithModelEnum:Yuan_NewMB_ModelEnum_shelf];

    //通过设备id查询列框
    NSDictionary * selectDict = @{
        @"eqpId":_requestDict[@"GID"]
    };
    list.selectDict = selectDict;

    Push(_vc, list);
    
}


//分光器
-(void)showOBDClick {

    Inc_NewMB_ListVC * list = [[Inc_NewMB_ListVC alloc] initWithModelEnum:Yuan_NewMB_ModelEnum_obd];
    
    NSString * resTypeId = @"";
    
    NSString * resLogicName = _requestDict[@"resLogicName"];
    
    if ([resLogicName isEqualToString:@"OCC_Equt"]) {
        resTypeId = @"703";      // 703
    }
    
    else if ([resLogicName isEqualToString:@"ODB_Equt"]) {
        resTypeId = @"704";      //704
    }
    
    else if ([resLogicName isEqualToString:@"ODF_Equt"]) {
        resTypeId = @"302";      //302
    }
    
    else if ([resLogicName isEqualToString:@"generator"]) {
        resTypeId = @"205";      //205
    }
        
    else {
        return;
    }
    
    NSDictionary * insertDict = @{
        
        @"positId" : _requestDict[@"GID"],
        @"positTypeId" : resTypeId,
        @"positName" : _requestDict[@"name"]
    };
    
    list.insertDict = insertDict;
    
    //zzc 2021-9-16 根据positTypeId 对应查询分光器列表
    NSDictionary * selectDict = @{
        @"positTypeId" : resTypeId
    };
    list.selectDict = selectDict;

    Push(_vc, list);
}


//复制
-(void)copyClick {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_requestDict];
    
    NSArray *array = @[@"GID",@"gid",@"no",@"name",@"lat",@"lon",@"addr",@"rfid",@"resLogicName",@"digCode",@"x",@"y",];
    
    for (NSString *str in array) {
        if ([dict.allKeys containsObject:str]) {
            [dict removeObjectForKey:str];
        }
    }
    
    
    
    Inc_NewMB_DetailVC * detail = [[Inc_NewMB_DetailVC alloc] initWithDict:dict
                                                        Yuan_NewMB_ModelEnum:_enum];
    
//    if (_enum == Yuan_NewMB_ModelEnum_voltage_changer || _enum == Yuan_NewMB_ModelEnum_equipment_power) {
//
//        detail.modifyDict = @{@"code":@"pwr"};
//    }
    
    detail.isCopy = YES;
    detail.gId = _requestDict[@"GID"];
    Push(_vc, detail);

    
}


#pragma mark - 模块侧边栏跳转 ---
//光端子
- (void) PushToTerm {
    
    if ([self isOfflineDevice]) {
        AlertShow([UIApplication sharedApplication].keyWindow, @"离线模式下不可用", 2.f, @"");
        return;
    }
    
   
//    ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
//    resourceTYKListVC.dicIn = [_requestDict mutableCopy];
//    resourceTYKListVC.fileName = @"opticTerm";
//    resourceTYKListVC.showName = @"端子";
////    resourceTYKListVC.sourceFileName = self.sourceFileName;
//
//    Push(_vc, resourceTYKListVC);
    
}





#pragma mark 判断请求用字典是否为离线资源
-(BOOL)isOfflineDevice{
    return [_requestDict[@"deviceId"] integerValue] > 0;
}

@end
