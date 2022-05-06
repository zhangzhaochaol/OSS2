//
//  Inc_NewMB_Presenter.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/22.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewMB_Presenter.h"


// *** controller


#import "Inc_NewMB_ListVC.h"

#import "Inc_CFListController.h"        // 纤芯配置
#import "Yuan_NewFL_RouteVC.h"          // 局向光纤

// *** 业务类
#import "Inc_NewFL_HttpModel1.h"
#import "Yuan_NewFL_HttpModel.h"
#import "Inc_Push_MB.h"


// *** 视图类
#import "Yuan_AMap.h"

#import "Inc_NewMB_PushVM.h"

@interface Inc_NewMB_Presenter () <AMapSearchDelegate >     //地理反编码



@end

@implementation Inc_NewMB_Presenter

{
    
    AMapSearchAPI * _search;
    
    
    // 地理反编码的回调
    void (^_ReGeocodeSearchBlock) (NSString * address);
    
    Inc_NewMB_PushVM * _pushVM;
    
}

/// 当前字段是否需要特殊判断
- (BOOL) theKeyIsInSpecial:(NSString *) key {
    
    NSArray * specialKeys = @[@"lightAttenuationCoefficient", //纤芯衰耗系数
    ];
    
    
    if ([specialKeys containsObject:key]) {
        return YES;
    }
    
    
    return NO;
    
}


/// 当 NewMB_Item 进行赋值时的特殊判断
- (NSString *) NewMB_Item_ModelConfigKey:(NSString *) key
                                    dict:(NSDictionary *) dict {
    
    NSString * value = dict[key];
    
    if (!value) {
        return @"";
    }
    
    // 纤芯衰耗系数
    if ([key isEqualToString:@"lightAttenuationCoefficient"]) {
        
        // 是否去掉 '-'
        return value;
//        return [value stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    
    return @"";
    
}


#pragma mark - 纤芯衰耗 ---



// 纤芯衰耗字段的 '-' 负号判断
- (NSString *) lightAttenuationCoefficient_Config:(NSString *) textField_Txt {

    if (![self isNumbers:textField_Txt]) {
        [YuanHUD HUDFullText:@"此字段只能接收数值,请重新输入"];
        return @"";
    }
    
    if (textField_Txt.length == 0) {
        return @"";
    }
    
    // 屏蔽纤芯衰耗的 '-'
    if ([textField_Txt hasPrefix:@"-"]) {
        
        // 不需要管他有没有 '-'
        return textField_Txt;
        // 需要移除 '-'
//        return [textField_Txt stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    // 不是负号'-'开头  直接返回
    else {
        
        return textField_Txt;
    }
}


// 纤芯的 衰耗系数特殊判断
- (NSString *) optPair_SpecialConfig:(NSString *) textField_Txt  {
    
    if (![self isNumbers:textField_Txt]) {
        return @"";
    }
    
    
    NSArray * msgArr = @[@"优秀",@"一般",@"高损耗",@"断纤"];
    NSArray * enumArr = @[@"7021101",@"7021102",@"7021103",@"7021104"];
    
    CGFloat length = 0.0;
    if ([_cableLength floatValue] > 0) {
        length = [_cableLength floatValue]/1000;
    }
    
    float textFloatValue = textField_Txt.floatValue * length;
    
    NSInteger arrIndex = 0;
    
    if (textFloatValue < 0.25) {
        arrIndex = 0;
    }
    else if ( textFloatValue >= 0.25 && textFloatValue <= 0.3 ) {
        arrIndex = 1;
    }
    else if (textFloatValue >= 0.3 && textFloatValue <= 0.4 ) {
        arrIndex = 2;
    }
    else if (textFloatValue > 0.4) {
        arrIndex = 3;
    }
    
    
    NSDictionary * blockDict = @{
        @"key" : @"opticalFiberPerformance",
        @"value" : enumArr[arrIndex]
    };
    
    
    
    
    NSString * result = [NSString stringWithFormat:@"实际衰耗值为%.2fdb。(衰减系数 x 光缆长度) 建议光纤性能为%@ ",textFloatValue,msgArr[arrIndex]];
    
    if (_optPair_ConfigBlock) {
        _optPair_ConfigBlock(blockDict);
    }
    
    return result;
}


- (BOOL) isNumbers:(NSString *) textField_Txt {
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789.-"] invertedSet];
    NSString *filtered = [[textField_Txt componentsSeparatedByCharactersInSet:cs]
                          componentsJoinedByString:@""];

    BOOL isNumbers = NO;
    
    if (![textField_Txt isEqualToString:filtered]) {
        isNumbers = NO;
    }
    else {
        isNumbers = YES;
    }
    
    return isNumbers;
}

//MARK: 跳转光纤光路
- (void) PushToFiberLink:(NSDictionary *) dict {
    
    NSString * gid = dict[@"gid"];

    //
    [self Http_SelectRoadInfoByTermPairId:@{
        @"type":@"optPair",
        @"id":gid
    }];

    
}

/// 根据光纤id 查询所属光链路
- (void) Http_SelectRoadInfoByTermPairId:(NSDictionary *)param {
    
    
    [Inc_NewFL_HttpModel1 Http_SelectRoadInfoByTermPairId:param success:^(id  _Nonnull result) {
        
        if (result) {
            NSArray *array = result;
            
            if (array.count == 0) {
                
                [YuanHUD HUDFullText:@"没有关联的光路"];

            }else {
                NSDictionary *dic = array[0];
                
                //push详情
                [self GetDetailWithGID:dic[@"optRoadId"] block:^(NSDictionary *dict) {
                    /*
                    // 跳转模板
                    [Inc_Push_MB pushFrom:_detailVC
                              resLogicName:@"opticalPath"
                                      dict:dict
                                      type:TYKDeviceListUpdate];
                     */
                }];
                
            }
        }
        
    }];
     
}

// 根据 Gid 和 reslogicName 获取 详细信息
- (void) GetDetailWithGID:(NSString *)GID
                    block:(void(^)(NSDictionary * dict))block{
    
    NSDictionary * dict = @{
        @"resLogicName" : @"opticalPath",
        @"GID":GID
    };
    
    [Http.shareInstance V2_POST:HTTP_TYK_Normal_Get
                           dict:dict
                        succeed:^(id data) {
            
        NSArray * arr = data;
        
        if (arr.count > 0) {
            block(arr.firstObject);
        }
        
    }];
    
}



//MARK: 跳转局向光纤
- (void) PushToFiberRoute:(NSDictionary *) dict {
    
    
    
    NSString * gid = dict[@"gid"];

    [Yuan_NewFL_HttpModel Http3_SelectRouteFromTerFibDict:@{@"nodeId" : gid}
                                                  success:^(id result) {
        NSDictionary * resDic = result;
        NSDictionary * optLogicOptPair = resDic[@"optLogicOptPair"];
        NSString * pairId = optLogicOptPair[@"pairId"];
        
        if (!pairId) {
            [YuanHUD HUDFullText:@"未找到所属局向光纤"];
            return;
        }
        
        Yuan_NewFL_RouteVC * route = [[Yuan_NewFL_RouteVC alloc] init];
        route.routeId = pairId;
        Push(_detailVC, route);
    }];
     
}



//MARK: 跳转纤芯配置
- (void) PushToCFConfig:(NSDictionary *)dict {
    

    
    Inc_CFListController * list = [[Inc_CFListController alloc] initWithCableId:dict[@"gid"]];
    
    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    mt_Dict[@"GID"] = dict[@"gid"];
    
    // 起始设备id
    if ([dict.allKeys containsObject:@"beginId"]) {
        mt_Dict[@"cableStart_Id"] = dict[@"beginId"];
    }
    else {
        [YuanHUD HUDFullText:@"缺少起始设备id"];
        return;
    }
    
    // 终止设备id
    if ([dict.allKeys containsObject:@"endId"]) {
        mt_Dict[@"cableEnd_Id"] = dict[@"EndId"];
    }
    else {
        [YuanHUD HUDFullText:@"缺少终止设备id"];
        return;
    }
    
    
    //  起始设备名称
    if ([dict.allKeys containsObject:@"beginName"]) {
        mt_Dict[@"cableStart"] = dict[@"beginName"];
    }
    else {
        [YuanHUD HUDFullText:@"缺少起始设备名称"];
        return;
    }
    
    
    //  终止设备名称
    if ([dict.allKeys containsObject:@"endName"]) {
        mt_Dict[@"cableEnd"] = dict[@"endName"];
    }
    else {
        [YuanHUD HUDFullText:@"缺少终止设备名称"];
        return;
    }
    
    mt_Dict[@"cableName"] = dict[@"name"];
    
    _pushVM = [[Inc_NewMB_PushVM alloc] initWithEnum:Yuan_NewMB_ModelEnum_optSect
                                              MbDict:dict
                                                  vc:[[UIViewController alloc] init]];
    
    list.moban_Dict = [_pushVM getOldKeys];
    
    Push(_detailVC, list);
    
     
}

// 跳转模块配置
- (void) PushToModule:(NSDictionary *)dict {
    
    Inc_NewMB_ListVC * list = [[Inc_NewMB_ListVC alloc] initWithModelEnum:Yuan_NewMB_ModelEnum_module];

    //通过列框id查询模块
    NSDictionary * selectDict = @{
        @"shelfId":dict[@"gid"]
    };
    list.selectDict = selectDict;

    Push(_detailVC, list);

    
}

#pragma mark - 反地理编码 ---

// 反地理编码
- (void) reGeocodeSearch:(CLLocationCoordinate2D) coor
                 success:(nonnull void (^)(NSString * _Nonnull))block {
    
    
    _ReGeocodeSearchBlock = block;
    
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];

    regeo.location = [AMapGeoPoint locationWithLatitude:coor.latitude
                                              longitude:coor.longitude];
    regeo.requireExtension = YES;
    
    [_search AMapReGoecodeSearch:regeo];
    
}



/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request
                     response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil) {
        
        NSLog(@"%@",response.regeocode.formattedAddress);
      
        // 回调
        if (_ReGeocodeSearchBlock) {
            _ReGeocodeSearchBlock(response.regeocode.formattedAddress);
        }
        
        
    }
}



/// 根据 设备数字代码 转 设备英文代码
+ (NSString *) DeviceNumCode_To_DeviceEnglishCode: (NSString *) DeviceNumCode {
    
    NSString * deviceEnglishCode = @"";
    
    switch (DeviceNumCode.intValue) {
        
        case 205:
            // 机房
            deviceEnglishCode = @"room";
            break;
            
        case 208:
            // 设备放置点
            deviceEnglishCode = @"position";
            break;
            
        case 201:
            // 局站
            deviceEnglishCode = @"station";
            break;
            
        case 700:
            // 光缆
            deviceEnglishCode = @"opt";
            break;
            
        case 701:
            // 机房
            deviceEnglishCode = @"optSect";
            break;
            
        case 703:
            // 光交接箱
            deviceEnglishCode = @"optConnectBox";
            break;
            
        case 705:
            // 光缆接头
            deviceEnglishCode = @"optTieIn";
            break;
            
        case 704:
            // 光分纤箱
            deviceEnglishCode = @"optJntBox";
            break;
            
        case 302:
            // ODF
            deviceEnglishCode = @"rackOdf";
            break;
            
        case 733:
            // 省界
            deviceEnglishCode = @"demarcation";
            break;
          
        case 711:
            // 光虚拟接入点
            deviceEnglishCode = @"virtualPoint";
            break;
            
        case 383:
            // 综合箱
            deviceEnglishCode = @"complexBox";
            break;
        default:
            break;
    }
    
    return deviceEnglishCode;
    
}






#pragma mark - 声明单粒 ---

+ (Inc_NewMB_Presenter *) presenter {
    
    static Inc_NewMB_Presenter * instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[super alloc] init];
    });
    
    return instance;
}

#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        
        _search = [[AMapSearchAPI alloc] init];
        _search.delegate = self;

    }
    return self;
}

- (id) copyWithZone:(NSZone *) zone {
    
    return  [self.class shareInstance];
}

- (id) mutableCopyWithZone:(NSZone *) zone {
    
    return  [self.class shareInstance];
}

@end
