//
//  Yuan_LoginService.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/7/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_LoginService : NSObject

/// 不用管成功还是失败 后台只是计数
+ (void) http_LoginStatistics;


// pdaLogin!loginOnly.interface
/// 单独登录 但不返回权限
+ (void) http_Login:(NSDictionary *) parma
            success:(httpSuccessBlock)success;

/// 单独请求权限的接口
+ (void) http_LoginSelectPowers:(NSDictionary *) parma
                        success:(httpSuccessBlock)success;

@end

NS_ASSUME_NONNULL_END
