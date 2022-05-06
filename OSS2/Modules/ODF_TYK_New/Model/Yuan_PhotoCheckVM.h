//
//  Yuan_PhotoCheckVM.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger , BatchHoldOprState_) {
    BatchHoldOprState_KongXian,
    BatchHoldOprState_YuZhan,
    BatchHoldOprState_ZhanYong,
    BatchHoldOprState_YuShiFang,
    BatchHoldOprState_YuLiu,
};


/*
 stateList.add(new Pair<>("1", "空闲"));
 stateList.add(new Pair<>("2", "预占"));
 stateList.add(new Pair<>("3", "占用"));
 stateList.add(new Pair<>("4", "预释放"));
 stateList.add(new Pair<>("5", "预留"));
 stateList.add(new Pair<>("6", "预选"));
 stateList.add(new Pair<>("7", "备用"));
 stateList.add(new Pair<>("8", "停用"));
 stateList.add(new Pair<>("9", "闲置"));
 stateList.add(new Pair<>("10", "损坏"));
 stateList.add(new Pair<>("11", "测试"));
 stateList.add(new Pair<>("12", "临时占用"));
 
 */



@interface Yuan_PhotoCheckVM : NSObject

+ (Yuan_PhotoCheckVM *) shareInstance;

/** 是否是端子选择校验的过程? */
@property (nonatomic , assign) BOOL isChooseTerminalMode;


/** 起点position */
@property (nonatomic , assign) NSInteger position_Start;

/** 终点的position */
@property (nonatomic , assign) NSInteger position_End;


/** 修改状态 */
@property (nonatomic , assign) BatchHoldOprState_ optState;

/** 选中的状态 */
@property (nonatomic , copy ) NSString * selectOprState;

@end


NS_ASSUME_NONNULL_END
