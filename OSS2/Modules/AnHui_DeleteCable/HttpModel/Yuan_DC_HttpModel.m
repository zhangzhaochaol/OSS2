//
//  Yuan_DC_HttpModel.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2021/1/11.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_DC_HttpModel.h"

#import "Yuan_WebService.h"


@implementation Yuan_DC_HttpModel



// 获取起始终止设备
+ (void) http_GetStartEndDevice:(NSString *) cableId
                        success:(void(^)(id result))success {
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,DC_GetStartEndDevicePort];

    
    NSDictionary * dict = @{
        
        @"resConditions" : @{
            @"optSect" : @{
                @"name" : @"optSect",
                @"ids" : cableId
            }
        }
    };
    
    
    [[Http shareInstance] DavidJsonPostURL:URL
                                     Parma:dict
                                   success:^(id result) {
       
        if (success) {
            success(result);
        }
    }];
    
}



// 获取光缆段下属路由

+ (void) http_GetCableRoute:(NSString *) cableId
                    success:(void(^)(id result))success {
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,DC_GetCableRoutePort];
    
    NSDictionary * dict = @{
        
        @"resType" : @"optSect" ,
        @"lineId" : cableId
    };
    
    
    
    
    [[Http shareInstance] DavidJsonPostURL:URL
                                     Parma:dict
                                   success:^(id result) {
       
        if (success) {
            success(result);
        }
    }];
    
}



// 获取半径范围内的下属资源  直传经纬度和半径
+ (void) http_GetCircleRadiusSubResMapCenterCoor:(CLLocationCoordinate2D) coor
                                         success:(void(^)(id result))success {
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,DC_GetCircleSubPort];
    

    
    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionary];
    
    mt_Dict[@"resTypes"] = @"hole,stayPoint,marker";
    mt_Dict[@"lat"] = [NSString stringWithFormat:@"%f",coor.latitude];
    mt_Dict[@"lon"] = [NSString stringWithFormat:@"%f",coor.longitude];
    mt_Dict[@"radius"] = @"1000";
    mt_Dict[@"pageNum"] = @"-1";
    mt_Dict[@"pageSize"] = @"-1";
    
    
    [[Http shareInstance] DavidJsonPostURL:URL
                                     Parma:mt_Dict
                                   success:^(id result) {
            
        if (success) {
            success(result);
        }
        
    }];
    
    
}



// 根据点资源查询所属线资源的下属段资源   点击获取线路按钮
+ (void) http_GetBelongResourceFromDict:(NSDictionary *) param
                                success:(void(^)(id result))success {
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,DC_GetBelongResources];
        

    NSMutableDictionary * mt_Dict = NSMutableDictionary.dictionary;
    
    mt_Dict[@"id"] = param[@"resId"];
    mt_Dict[@"type"] = param[@"resType"];
    
    [[Http shareInstance] DavidJsonPostURL:URL
                                     Parma:mt_Dict
                                   success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
}






// 根据资源查询关联段资源      点击关联资源按钮 (副)
+ (void) http_GetReleatResourceFromDict:(NSDictionary *) param
                                success:(void(^)(id result))success {
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,DC_GetRelateResource];
        

    NSMutableDictionary * mt_Dict = NSMutableDictionary.dictionary;
    

    mt_Dict[@"resId"] = param[@"resId"];
    mt_Dict[@"resType"] = param[@"resType"];
    
    [[Http shareInstance] DavidJsonPostURL:URL
                                     Parma:mt_Dict
                                   success:^(id result) {
        if (success) {
            success(result);
        }
    }];
    
    
    
}





// 撤缆接口
+ (void) http_DeleteCableFromArray:(NSArray *) deleteIdsArr
                          cableId :(NSString *)belongCableId
                           success:(void(^)(id result))success {
    
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,DC_DeleteRoutePort];
        
    NSMutableArray * postArr = NSMutableArray.array;
    
    for (NSDictionary * singleDict in deleteIdsArr) {
        
        NSDictionary * dict = @{
            
            @"eqpId" : singleDict[@"eqpId"],
            @"eqpTypeId" : singleDict[@"eqpTypeId"],
            @"optSectId" : belongCableId
        };
        
        [postArr addObject:dict];
    }
    
    
    
    NSMutableDictionary * mt_Dict = NSMutableDictionary.dictionary;
    
    
    mt_Dict[@"optOccupyList"] = postArr;
    
    
    [[Http shareInstance] DavidJsonPostURL:URL
                                     Parma:mt_Dict
                                   success:^(id result) {
            
        if (success) {
            success(result);
        }
        
    }];
    
}



// 自动穿缆
+ (void) http_putUpCableAuto:(NSDictionary *) param
                     success:(void(^)(id result))success {
    

    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,DC_AddRoutePort_Auto];
    
    [[Http shareInstance] DavidJsonPostURL:URL
                                     Parma:param
                                   success:^(id result) {
       
        if (success) {
            success(result);
        }
    }];
    
}





// 手动穿缆 , 仅在手动 选管孔时使用
+ (void) http_putUpCableHands_FromArray:(NSArray *) param
                                success:(void(^)(id result))success {
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,DC_AddRoutePort_Hands];
    
    NSMutableDictionary * dict = NSMutableDictionary.dictionary;
    
    dict[@"optOccupyList"] = param;
    
    [[Http shareInstance] DavidJsonPostURL:URL
                                     Parma:dict
                                   success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
    
}




// 根据管道段Id 获取下属管孔信息
+ (void) http_GetFatherTubeFromId:(NSString *) Id
                          success:(void(^)(id result))success {
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,DC_GetFatherTubePort];
    
    NSDictionary * dict = @{
        @"id" : Id
    };
    
    
    [[Http shareInstance] DavidJsonPostURL:URL
                                     Parma:dict
                                   success:^(id result) {
            
        if (success) {
            success(result);
        }
        
    }];
    
    
}




@end
