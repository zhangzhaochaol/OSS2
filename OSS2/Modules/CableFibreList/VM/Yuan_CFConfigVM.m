//
//  Yuan_CFConfigVM.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_CFConfigVM.h"

@implementation Yuan_CFConfigVM

{
    
    // 用于关联选中的两个纤芯之间的搭桥的数组
    NSMutableArray * _bindingArray;
    
    // 界面上方的纤芯 我选中了哪个
    NSString * _chooseFiber;
    
    
}




#pragma mark -  获取 起始设备Id  终止设备Id 根据模板dict 获取 ---


- (NSString *) viewModel_GetStartDeviceId {
    
    NSString * GID = _moBan_Dict[@"cableStart_Id"] ?: @"";
    
    // 给GID 赋值  起始或终止设备ID
    _resZEqp_Id = _startOrEndDevice_Id = GID;
    
    return GID;
}


- (NSString *) viewModel_GetEndDeviceId {
    
    NSString * GID = _moBan_Dict[@"cableEnd_Id"] ?: @"";
    // 给GID 赋值  起始或终止设备ID
    _resZEqp_Id = _startOrEndDevice_Id = GID;
    
    return GID;
}



/// 起始设备和终止设备名称

- (NSString *) viewModel_GetStartDeviceName {
    
    return _moBan_Dict[@"cableStart"] ?: @"";
}


- (NSString *) viewModel_GetEndDeviceName {
    
    return _moBan_Dict[@"cableEnd"] ?: @"";
}





#pragma mark -  根据纤芯的单个Dict 判断应该显示在左上右下 是成端还是熔接 item的红蓝图片 左上右下!!---
/// @param fiberDict 当前纤芯 对应的 connectList 数组中的dict
/// @param pairId 当前纤芯的 ID
- (NSDictionary *) viewModelFiberTypeAndLocationFromDict:(NSDictionary *) fiberDict
                                                  pairId:(NSString *)pairId{
    
    // 光缆段的起始和终止的设备名称  用于和纤芯去判断
    
    CF_VM_FiberLocation_ location = CF_VM_FiberLocation_unknow;
    
    // 数组里有 一个元素 或 两个元素的情况 ~  0元素的情况在上面已经判断返回 CF_VM_FiberType_None
    

    
    // 只有熔接状态下有效
    
    NSString * tieInName = fiberDict[@"tieInName"] ?: @"";
    NSString * tieInId = fiberDict[@"tieInId"] ?: @"";
    
    NSString * superResId = fiberDict[@"superResId"] ?: @"";
    NSString * superResName = fiberDict[@"superResName"] ?: @"";
    

     
    // 成端还是熔接
    
    NSString * type = @"";
    // cableEnd_Id cableStart_Id
    NSString * cableStart_Id = _moBan_Dict[@"cableStart_Id"];
    NSString * cableEnd_Id = _moBan_Dict[@"cableEnd_Id"];
    
    // 熔接
    if (tieInName.length > 0 && tieInId.length > 0) {
        
        // 熔接状态下
        if ([tieInId rangeOfString:cableStart_Id ?: @""].location != NSNotFound) {
            // 证明是熔接是起始设备
            location = CF_VM_FiberLocation_up;
        }else if([tieInId rangeOfString:cableEnd_Id ?: @""].location != NSNotFound){
            location = CF_VM_FiberLocation_down;
        }
        
        type = @"1";
    }

    
    // 成端
    
    if (superResId.length > 0 && superResName.length > 0) {

        // 熔接状态下
        if ([superResId rangeOfString:cableStart_Id ?: @""].location != NSNotFound) {
            // 证明是熔接是起始设备
            location = CF_VM_FiberLocation_up;
        }else if([superResId rangeOfString:cableEnd_Id ?: @""].location != NSNotFound){
            location = CF_VM_FiberLocation_down;
        }

        type = @"2";

    }
    
    
    NSString * locationStr ;
    
    if (location == CF_VM_FiberLocation_up) {
        locationStr = @"1";
    }else if (location == CF_VM_FiberLocation_down) {
        locationStr = @"2";
    }else if (location == CF_VM_FiberLocation_unknow) {
        locationStr = @"0";
    }
    
    
    
    return @{@"type":type ,
             @"location" : locationStr};
    
}



#pragma mark -  拆分数组环节  ---


- (void) clearUpToArrays:(NSArray *)listArray {
    
    [_allXianXinArray removeAllObjects];
    [_allStartDeviceArray removeAllObjects];
    [_allEndDeviceArray removeAllObjects];
        
    
    for (NSDictionary * dict in listArray) {
        
        NSString * pairId = dict[@"pairId"];
        NSString * pairNo = dict[@"pairNo"];
        
        
        [_allXianXinArray addObject:@{@"pairNo":pairNo ?: @"" ,
                                      @"pairId":pairId ?: @"" ,
                                      @"pairName":dict[@"pairName"] ?: @""
        }];
        
        
        NSArray * connectArray = dict[@"connectList"];
        
        if (!connectArray || connectArray.count == 0) {
            continue;
        }
        
        
        for (NSDictionary * connectDict in connectArray) {
            
            // 把一个数据 变成三个数据
            
            NSMutableDictionary * zhengliDict = [self clearUpSubConfig:connectDict
                                                                pairId:pairId];
            
            zhengliDict[@"pairNo"] = pairNo;  // 把右上角的编号存进去
            
            if ([zhengliDict[@"location"] isEqualToString:@"start"]) {
                // 证明是起始的组
                [_allStartDeviceArray addObject:zhengliDict];
            }else if ([zhengliDict[@"location"] isEqualToString:@"end"]) {
                [_allEndDeviceArray addObject:zhengliDict];
            }
            else {
                continue;
            }
        }
    }
}




#pragma mark -  把大为的数据 分成了三个数据  ---


/// 为了 通过网络请求回来的数据 给右上角赋值 数字 , 
- (NSMutableDictionary *) clearUpSubConfig:(NSDictionary *) fiberDict
                                    pairId:(NSString *)pairId{
    
    
    
    // 光缆段的起始和终止的设备名称  用于和纤芯去判断
    // 数组里有 一个元素 或 两个元素的情况 ~  0元素的情况在上面已经判断返回 CF_VM_FiberType_None
    
    
    NSString * resAId = fiberDict[@"resAId"] ?: @"";
    NSString * resBId = fiberDict[@"resBId"] ?: @"";
    
    
    // 只有熔接状态下有效
    
    NSString * tieInName = fiberDict[@"tieInName"] ?: @"";
    NSString * tieInId = fiberDict[@"tieInId"] ?: @"";
    
    
    // 只有在成端下有效
    NSString * superResId = fiberDict[@"superResId"] ?: @"";
    NSString * superResName = fiberDict[@"superResName"] ?: @"";
    
    
    NSString * A_Or_B = @"" ;
    
    // 如果 resAId 或者 resBId 与 pairId 相同的那一组 弃用
    
    
    NSString * resId = @"";    //端子或者对端光缆段的Id , 用于下方view 验证
    NSString * resName = @"";
    
    NSString * qizhi = @"";
    
    
      
    
    
    if (![resAId isEqualToString:pairId]) {
        
        resName = fiberDict[@"resAName"] ?:@"";
        resId = fiberDict[@"resAId"] ?: @"";
        A_Or_B = @"A";
    }else if (![resBId isEqualToString:pairId]) {
        
        resName = fiberDict[@"resBName"] ?: @"";
        resId = fiberDict[@"resBId"] ?: @"";
        A_Or_B = @"B";
    }else {
        
        resName = @"";
        resId = @"";
        A_Or_B = @"";
    }
    
    
    // cableEnd_Id cableStart_Id
    NSString * cableStart_Id = _moBan_Dict[@"cableStart_Id"];
    NSString * cableEnd_Id = _moBan_Dict[@"cableEnd_Id"];
    
    
    if (tieInName.length > 0 && tieInId.length > 0) {
        
        // 熔接状态下
        if ([tieInId rangeOfString:cableStart_Id ?: @""].location != NSNotFound) {
            // 证明是熔接是起始设备
            qizhi = @"start";
        }else if([tieInId rangeOfString:cableEnd_Id ?: @""].location != NSNotFound){
            qizhi = @"end";
        }else {
            qizhi = @"";
        }
        
    }
 
    // 成端
    
    if (superResId.length > 0 && superResName.length > 0) {

        // 熔接状态下
        if ([superResId rangeOfString:cableStart_Id ?: @""].location != NSNotFound) {
            // 证明是熔接是起始设备
            qizhi = @"start";
        }else if([superResId rangeOfString:cableEnd_Id ?: @""].location != NSNotFound){
            qizhi = @"end";
        }else {
            qizhi = @"";
        }

    }
    
    
 
    
    // 返回 id 名称 和 起止
    
    return [@{@"resId":resId  ?: @"",
             @"resName":resName  ?: @"",
             @"location":qizhi ?: @""} mutableCopy];
    
}





#pragma mark -  通知 CF_ConfigController 刷新 collection  ---

- (void) viewModel_NotiConfigController_ReloadTheCollection {
    
    // 仅通知刷新 不传值
    if (_viewModel_Block_ReloadConfigListCollection) {
        _viewModel_Block_ReloadConfigListCollection();
    }
    
}



#pragma mark -  通知首页 刷新 http List  ---

- (void) viewModel_NotiListControllerReloadHttp {
    
    // 仅通知 不传值
    if (_viewModel_Block_ReloadHttp) {
        _viewModel_Block_ReloadHttp();
    }
    
}





#pragma mark -  长按 自动配置 ---

/// 执行长按事件的view 通知其上层view , 进行长按循环事件
- (void) viewModel_Notification_forCircleClick:(NSInteger) index
                                      position:(NSInteger )position{
    
    if (_viewModel_for_Circle_Block) {
        _viewModel_for_Circle_Block(index,position);
    }
    
}



#pragma mark -  长按 手动配置  ---




/// 手动配置 '成端' '熔接'时 先存下当前点击的按钮的值 , 再点击一个按钮时  校验
/// @param index 当前长按的对象 在对应资源数组中的位置
- (void) Notification_HandleConfigWithNowIndexFromResArray:(NSInteger)index {
    
    
    if (!self.baseLink_FiberId || self.baseLink_FiberId.length == 0) {
       
        // 证明还没选中 baseLinkDict
       
       [[Yuan_HUD shareInstance] HUDFullText:@"在关联之前,要先选择一个光缆段纤芯"];
       return ;
    }
    
    
    
    // 如果实现了回调
    if (_viewModel_for_HandleConfig_Block) {
        
        // 正在操作中 , 再选中一个按钮 即可自动配置 , 此时
        _handleConfig_State = CF_ConfigHandle_Setting;
        
        _viewModel_for_HandleConfig_Block(index);
    }
    
}



/// 手动配置结束时点击的按钮的位置
- (void) Notification_HandleConfigEndIndexFromResArray:(NSInteger)endIndex {
    

    
    if (_viewModel_for_HandleConfig_END_Block) {
                
        _viewModel_for_HandleConfig_END_Block(endIndex);
    }
    
}





#pragma mark -  初始化方法  ---


+ (Yuan_CFConfigVM *)shareInstance {
    
    static Yuan_CFConfigVM *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[super alloc] init];
    });
    return sharedAccountManagerInstance;
}

#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
        
        _connect_LazyLoad_DataSource = [NSMutableArray array];
        _ODF_LazyLoad_DataSource = [NSMutableArray array];
        
        
        // 初始化待拆分的数组
        _allXianXinArray = NSMutableArray.array;
        _allStartDeviceArray = NSMutableArray.array;
        _allEndDeviceArray = NSMutableArray.array;
        
        // 所有待保存的集合
        _linkSaveHttpArray = NSMutableArray.array;
        
        // 所有端子的按钮
        _terminalBtnArray = NSMutableArray.array;
        _connectionItemArray = NSMutableArray.array;
        
        
        // 和其他光缆段绑定的纤芯Id们 2020.11.3
        _AnotherCableConfigTermIds_Arr = NSMutableArray.array;
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone{
    return [self.class shareInstance];
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return [self.class shareInstance];
}


@end
