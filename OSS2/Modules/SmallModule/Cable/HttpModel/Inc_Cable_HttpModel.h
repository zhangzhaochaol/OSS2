//
//  Inc_Cable_HttpModel.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/22.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_Cable_HttpModel : NSObject


/// 根据起始设施和终止设施查询光缆段和光缆名称  纵向合并使用
+ (void) Http_FindOptSectByBeginAndEnd:(NSDictionary *) param
                               success:(void(^)(id result)) success;




/// 根据起始设施和终止设施查询光缆段和光缆名称,起始设施或终止设置一端相同,另一端不同(横向合并)
+ (void) Http_FindOptSectByBeginAndEndDif:(NSDictionary *) param
                               success:(void(^)(id result)) success;



/// 光缆段纵向合并
+ (void) Http_UpdateOptSectMergeVer:(NSDictionary *) param
                               success:(void(^)(id result)) success;



/// 光缆段横向合并
+ (void) Http_UpdateOptSectMergeTra:(NSDictionary *) param
                               success:(void(^)(id result)) success;


/// 光缆段纵向拆分
+ (void) Http_UpdateOptSectSplitVer:(NSDictionary *) param
                               success:(void(^)(id result)) success;




/// 光缆段横向拆分
+ (void) Http_UpdateOptSectSplitTra:(NSDictionary *) param
                               success:(void(^)(id result)) success;



/// 光缆段id查询下属纤芯
+ (void) Http_SelectPairBySectId:(NSDictionary *) param
                               success:(void(^)(id result)) success;


///根据光缆段id获取光缆段信息和起始终止设施经纬度
+ (void) Http_getOptSectLonLatInfo:(NSDictionary *) param
                               success:(void(^)(id result)) success;
@end

NS_ASSUME_NONNULL_END
