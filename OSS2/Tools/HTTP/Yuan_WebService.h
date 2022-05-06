//
//  Yuan_WebService.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_WebService : NSObject

// domain 转 拼音省份名称
- (NSString *) webServiceGetDomainCode;

// domain 转 拼音省份名称
+ (NSString *) webServiceGetDomainCode;

// domain 转 汉字省份名称
+ (NSString *) webServiceGetChineseName;
@end

NS_ASSUME_NONNULL_END
