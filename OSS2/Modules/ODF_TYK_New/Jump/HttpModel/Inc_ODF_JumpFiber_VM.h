//
//  Inc_ODF_JumpFiber_VM.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/24.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_ODF_JumpFiber_VM : NSObject

+ (Inc_ODF_JumpFiber_VM *) shareInstance;

/** 关联成功回调*/
@property (nonatomic , copy) void (^successBlock) (void);


/** 跳纤拼接数组 */
@property (nonatomic , copy) NSMutableArray * jumpFiber_Arr;


/// 对 A端和Z端进行组合
- (void) combinationJumpFiber;

/// 对 A端和Z端进行解除
//gid  两个端子关联id
- (void) relieveJumpFiber:(NSString *)gid;

//- (void) clearDatas;



@end

NS_ASSUME_NONNULL_END
