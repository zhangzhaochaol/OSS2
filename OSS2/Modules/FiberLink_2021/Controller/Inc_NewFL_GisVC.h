//
//  Inc_NewFL_GisVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2022/3/1.
//  Copyright © 2022 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , NewFL_Gis_) {
    NewFL_Gis_Link,     // 光链路
    NewFL_Gis_Route,    // 局向光纤
};

@interface Inc_NewFL_GisVC : Inc_BaseVC

- (instancetype)initWithEnum:(NewFL_Gis_)Enum dict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
