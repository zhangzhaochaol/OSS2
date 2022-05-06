//
//  Inc_NewFL_HttpModel1.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/7/5.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewFL_HttpModel1.h"


@implementation Inc_NewFL_HttpModel1


/// 端子、纤芯、局向光纤业务状态变更
+ (void) Http_UpdateOprState:(NSDictionary *)param
                     success:(void(^)(id result))success{
    
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:param];
    
    paramDict[@"reqDb"] = reqDb;
    
    [Http.shareInstance DavidJsonPostURL:[self EditURL:NewFL_UpdateOprState]
                                   Parma:paramDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
}



/// 确认端子、纤芯、局向光纤业务状态变更
+ (void) Http_ConfirmUpdateOprState:(NSDictionary *)param
                            success:(void(^)(id result))success{
    
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:param];
    
    paramDict[@"reqDb"] = reqDb;
    
    
    
    [Http.shareInstance DavidJsonPostURL:[self EditURL:NewFL_ConfirmUpdateOprState]
                                   Parma:paramDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
}

/// 根据光缆段ID或者设备ID查询关联的光路
+ (void) Http_SelectRoadInfoByEqpId:(NSDictionary *)param
                            success:(void(^)(id result))success {
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:param];
    
    paramDict[@"reqDb"] = reqDb;
    
    
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_SelectRoadInfoByEqpId]
                                   Parma:paramDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
}

/// 根据设备ID查询查询所属端子信息
+ (void) Http_SelectTermsByEqpId:(NSDictionary *)param
                         success:(void(^)(id result))success{
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:param];
    
    paramDict[@"reqDb"] = reqDb;
    
    
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_SelectTermsByEqpId]
                                   Parma:paramDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
}


/// 根据光缆段ID或者设备ID查询关联的光路
+ (void) Http_SelectRoadInfoByTermPairId:(NSDictionary *)param
                                 success:(void(^)(id result))success{
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:param];
    
    paramDict[@"reqDb"] = reqDb;
    
    
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_SelectRoadInfoByTermPairId]
                                   Parma:paramDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}

/// 根据端子ids集合查看是否有光电路关系
+ (void) Http_SelectRoadByTermIds:(NSArray *)paramArr
                          success:(void(^)(id result))success {
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
    NSDictionary * paramDict = @{
        @"reqDb":reqDb,
        @"resIds":paramArr
    };
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_SelectRoadByTermIds]
                                   Parma:paramDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
    
}

///通过端子id查询承载业务
+ (void) Http_GetRouterAndCircuitInfo:(NSDictionary *)param
                      success:(void(^)(id result))success
{
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:param];
    
    paramDict[@"reqDb"] = reqDb;
    
    
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_GetRouterAndCircuitInfo]
                                   Parma:paramDict
                                 success:^(id result) {
        
        if (success) {
            success(result);
        }
    }];
    
}


//根据设备ID查询光缆段接口
+ (void)Http_GetOpeSectAndPort:(NSDictionary *)param
                       success:(void(^)(id result))success{
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:param];
    
    paramDict[@"reqDb"] = reqDb;
    
    
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_GetOpeSectAndPortIds]
                                   Parma:paramDict
                                 success:^(id result) {
        
        if (success) {
            success(result);
        }
    }];
    
}



//根据设备ID查询承载业务接口
+ (void)Http_GetCircuitAndPort:(NSDictionary *)param
                       success:(void(^)(id result))success{
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:param];
    
    paramDict[@"reqDb"] = reqDb;
    
    
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_GetCircuitAndPortIds]
                                   Parma:paramDict
                                 success:^(id result) {
        
        if (success) {
            success(result);
        }
    }];
    
}


//根据设备ID查询端子信息
+ (void)Http_GetTermSData:(NSDictionary *)param
                  success:(void(^)(id result))success {
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:param];
    
    paramDict[@"reqDb"] = reqDb;
    
    
    
    [Http.shareInstance DavidJsonPostURL:[self URL:NewFL_GetTermsByEqpId]
                                   Parma:paramDict
                                 success:^(id result) {
        
        if (success) {
            success(result);
        }
    }];
    
}

+ (NSString *) URL:(NSString *) str {
    return  [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,str];
}


+ (NSString *) EditURL:(NSString *) str {
    
    return [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,str];
}

@end
