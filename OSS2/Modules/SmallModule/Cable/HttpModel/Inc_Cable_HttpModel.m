//
//  Inc_Cable_HttpModel.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/22.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_Cable_HttpModel.h"


// 根据起始设施和终止设施查询光缆段和光缆名称(纵向合并)
static NSString * FindOptSectByBeginAndEnd = @"optRes/findOptSectByBeginAndEnd";

//根据起始设施和终止设施查询光缆段和光缆名称,起始设施或终止设置一端相同,另一端不同(横向合并)
static NSString * FindOptSectByBeginAndEndDif = @"optRes/findOptSectByBeginAndEndDif";

//光缆段纵向合并
static NSString * UpdateOptSectMergeVer = @"eqpApi/updateOptSectMergeVer";

//光缆段横向合并
static NSString * UpdateOptSectMergeTra = @"eqpApi/updateOptSectMergeTra";

//光缆段纵向拆分
static NSString * UpdateOptSectSplitVer = @"eqpApi/updateOptSectSplitVer";

//光缆段横向拆分
static NSString * UpdateOptSectSplitTra = @"eqpApi/updateOptSectSplitTra";


//根据光缆段id查询下属纤芯   目前纵向拆分使用    对比光缆段详情返回纤芯总数是否相等
static NSString * SelectPairBySectId = @"optRes/selectPairBySectId";

//根据光缆段id获取光缆段信息和起始终止设施经纬度
static NSString * GetOptSectLonLatInfo = @"optRes/getOptSectLonLatInfo";

@implementation Inc_Cable_HttpModel

///纵向合并使用

+ (void) Http_FindOptSectByBeginAndEnd:(NSDictionary *) param
                                 success:(void(^)(id result)) success{
    
    
    [Http.shareInstance DavidJsonPostURL:David_SelectUrl(FindOptSectByBeginAndEnd)
                                   Parma:param
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}

///横向合并使用

+ (void) Http_FindOptSectByBeginAndEndDif:(NSDictionary *) param
                               success:(void(^)(id result)) success{
    
    
    [Http.shareInstance DavidJsonPostURL:David_SelectUrl(FindOptSectByBeginAndEndDif)
                                   Parma:param
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}

/// 光缆段纵向合并
+ (void) Http_UpdateOptSectMergeVer:(NSDictionary *) param
                            success:(void(^)(id result)) success {
    
    
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(UpdateOptSectMergeVer)
                                   Parma:param
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}

/// 光缆段横向合并
+ (void) Http_UpdateOptSectMergeTra:(NSDictionary *) param
                            success:(void(^)(id result)) success {
    
    
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(UpdateOptSectMergeTra)
                                   Parma:param
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
    
}


/// 光缆段纵向拆分
+ (void) Http_UpdateOptSectSplitVer:(NSDictionary *) param
                            success:(void(^)(id result)) success {
    
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(UpdateOptSectSplitVer)
                                   Parma:param
                                 success:^(id result) {

        if (success) {
            success(result);
        }
    }];
    
}

/// 光缆段横向拆分
+ (void) Http_UpdateOptSectSplitTra:(NSDictionary *) param
                            success:(void(^)(id result)) success {
    
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(UpdateOptSectSplitTra)
                                   Parma:param
                                 success:^(id result) {

        if (success) {
            success(result);
        }
    }];
    
    
}

/// 光缆段id查询下属纤芯
+ (void) Http_SelectPairBySectId:(NSDictionary *) param
                         success:(void(^)(id result)) success {
    
    [Http.shareInstance DavidJsonPostURL:David_SelectUrl(SelectPairBySectId)
                                   Parma:param
                                 success:^(id result) {

        if (success) {
            success(result);
        }
    }];
    
    
}


///根据光缆段id获取光缆段信息和起始终止设施经纬度
+ (void) Http_getOptSectLonLatInfo:(NSDictionary *) param
                           success:(void(^)(id result)) success {
    
    [Http.shareInstance DavidJsonPostURL:David_SelectUrl(GetOptSectLonLatInfo)
                                   Parma:param
                                 success:^(id result) {

        if (success) {
            success(result);
        }
    }];
    
    
}


@end
