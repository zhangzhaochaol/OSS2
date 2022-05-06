//
//  Inc_DC_HttpModel1.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/7/13.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_DC_HttpModel1.h"


@implementation Inc_DC_HttpModel1


// 全部撤缆
+ (void) http_AllDeleteRoute:(NSDictionary *) param
                     success:(void(^)(id result))success{
    
    NSString * reqDb = [[[Yuan_WebService alloc] init] webServiceGetDomainCode];
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionaryWithDictionary:param];
    
    paramDict[@"reqDb"] = reqDb;
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,DC_AllDeleteRoutePort];
    
    [[Http shareInstance] DavidJsonPostURL:URL
                                     Parma:paramDict
                                   success:^(id result) {
        
        if (success) {
            success(result);
        }
    }];
    
    
}

@end
