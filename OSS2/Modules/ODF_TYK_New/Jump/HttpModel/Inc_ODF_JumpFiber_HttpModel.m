//
//  Inc_ODF_JumpFiber_HttpModel.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/25.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_ODF_JumpFiber_HttpModel.h"

@implementation Inc_ODF_JumpFiber_HttpModel

+ (void)FindRoomList:(NSDictionary *)dict
         successBlock:(void(^)(id result))success {
    
    
    NSString * url = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,ODF_FindRoomList];

    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];

    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    paramDict[@"reqDb"] = reqDb;
    
    [Http.shareInstance DavidJsonPostURL:url
                                   Parma:paramDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
    
}

//查询列框中存在跳纤的端子
+ (void)FindTermOptLineByShelfId:(NSDictionary *)dict
                       successBlock:(void(^)(id result))success{
    
    
    NSString * url = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,FindTermOptLineByShelf];

    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];

    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    paramDict[@"reqDb"] = reqDb;
    
    [Http.shareInstance DavidJsonPostURL:url
                                   Parma:paramDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
    
}


//添加跳纤关系
+ (void)AddUnionTermJump:(NSDictionary *)dict
                       successBlock:(void(^)(id result))success{
    
    
    NSString * url = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,AddUnionJumpEqp];

    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];

    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    paramDict[@"reqDb"] = reqDb;
    
    [Http.shareInstance DavidJsonPostURL:url
                                   Parma:paramDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
    
}

//解除跳纤关系
+ (void)DeleteUnionTermJump:(NSDictionary *)dict
                       successBlock:(void(^)(id result))success{
    
    
    NSString * url = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,DeleteUnionJumpEqp];

    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];

    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    paramDict[@"reqDb"] = reqDb;
    
    [Http.shareInstance DavidJsonPostURL:url
                                   Parma:paramDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
    
}

//通过机房id查所属设备
+ (void)SearchUnionTermJump:(NSDictionary *)dict
                       successBlock:(void(^)(id result))success{
    
    
    NSString * url = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,SearchUnionJumpEqp];

    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];

    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    paramDict[@"reqDb"] = reqDb;
    
    [Http.shareInstance DavidJsonPostURL:url
                                   Parma:paramDict
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
    
}
@end
