//
//  Inc_UserModel.h
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/4/19.
//

#import <Foundation/Foundation.h>

#define UserModel Inc_UserModel.shareInstance

NS_ASSUME_NONNULL_BEGIN







@interface Inc_UserModel : NSObject

/** 账号 */
@property (nonatomic , copy ) NSString * userName;

/** 密码 */
@property (nonatomic , copy ) NSString * passWord;

/** uid */
@property (nonatomic , copy ,readonly) NSString * uid;

/** 区域code */
@property (nonatomic , copy ,readonly) NSString * areano;

/** 区域id */
@property (nonatomic , copy ,readonly) NSString * domainCode;

/** areaName */
@property (nonatomic , copy ,readonly) NSString * areaName;

/** 用户权限串 */
@property (nonatomic , copy ,readonly) NSDictionary * powersDic;

/** 用户权限串 统一库 */
@property (nonatomic , copy ,readonly) NSDictionary * powersTYKDic;

/** 完整数据 */
@property (nonatomic , copy ,readonly) NSDictionary * userInfo;





+ (Inc_UserModel *) shareInstance;

/// 对用户信息赋值
- (void) userModelConfig:(NSDictionary *) dict;


/// 对用户权限进行缓存
- (void) userPowerConfig:(NSDictionary *) dict;

@end

NS_ASSUME_NONNULL_END
