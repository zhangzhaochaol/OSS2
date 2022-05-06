//
//  Inc_ODF_JumpFiber_HttpModel.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/25.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>


//通过ODF的id查询所属局站下所有机房
#define ODF_FindRoomList @"eqpResApi/findRoomByOdfId"

//查询列框中存在跳纤的端子
#define FindTermOptLineByShelf @"eqpResApi/findTermOptLineByShelfId"

//添加跳纤关系 （通用添加资源）
#define AddUnionJumpEqp @"unionEqpApi/addUnionEqp"

//解除跳纤关系 （通用删除资源）
#define DeleteUnionJumpEqp @"unionEqpApi/deleteUnionEqp"

//通用查询资源分页
#define SearchUnionJumpEqp @"unionSearch/unionSearchPage"

@interface Inc_ODF_JumpFiber_HttpModel : NSObject


//通过ODF的id查询所属局站下所有机房
+ (void)FindRoomList:(NSDictionary *)dict
                       successBlock:(void(^)(id result))success;


//查询列框中存在跳纤的端子
+ (void)FindTermOptLineByShelfId:(NSDictionary *)dict
                       successBlock:(void(^)(id result))success;


//添加跳纤关系
+ (void)AddUnionTermJump:(NSDictionary *)dict
                       successBlock:(void(^)(id result))success;

//解除跳纤关系
+ (void)DeleteUnionTermJump:(NSDictionary *)dict
                       successBlock:(void(^)(id result))success;

//通过机房id查所属设备
+ (void)SearchUnionTermJump:(NSDictionary *)dict
                       successBlock:(void(^)(id result))success;
@end


