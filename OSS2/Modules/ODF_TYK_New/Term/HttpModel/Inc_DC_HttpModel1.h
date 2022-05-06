//
//  Inc_DC_HttpModel1.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/7/13.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 全部撤缆
#define DC_AllDeleteRoutePort @"lineApi/offAllLine"



@interface Inc_DC_HttpModel1 : NSObject


// 全部撤缆
+ (void) http_AllDeleteRoute:(NSDictionary *) param
                     success:(void(^)(id result))success;





@end

NS_ASSUME_NONNULL_END
