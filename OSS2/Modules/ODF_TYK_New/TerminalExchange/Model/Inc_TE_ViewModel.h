//
//  Inc_TE_ViewModel.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


// 端子显示在左侧 还是右侧
typedef NS_ENUM(NSUInteger , TE_ExTerShow_) {
    TE_ExTerShow_Left = 0,
    TE_ExTerShow_Right,
};

typedef NS_ENUM(NSUInteger , BaseScroll_) {
    BaseScroll_Before = 0,
    BaseScroll_After,
};


typedef NS_ENUM(NSUInteger , TE_ExTerminal_) {
    TE_ExTerminal_Normal = 0,   //正常状态
    TE_ExTerminal_Warning,      //警告状态
    TE_ExTerminal_A,            //A
    TE_ExTerminal_B,            //B
};


typedef NS_ENUM(NSUInteger , TE_ContentSpecialMode_) {
    TE_ContentSpecialMode_Reverse,              //倒序
    TE_ContentSpecialMode_JumpingRelationship   //互为跳接关系
};



@interface Inc_TE_ViewModel : NSObject

+ (Inc_TE_ViewModel *) shareInstance;


/** 选择端子的block */
@property (nonatomic , copy) void (^chooseTerminalBlock) (NSDictionary * terminalDict);

/** 端子A的数据 */
@property (nonatomic , copy) NSDictionary * Terminal_A_Dict;

/** 端子B的数据 */
@property (nonatomic , copy) NSDictionary * Terminal_B_Dict;


/** 端子A 最终会改成的业务状态  */
@property (nonatomic , assign) NSInteger terminal_A_ExceptOprStateId;

/** 端子B 最终会改成的业务状态  */
@property (nonatomic , assign) NSInteger terminal_B_ExceptOprStateId;


/** AB两个端子的 对端端子是否在同一设备中 , 不在的话 端子框是红色的 , 并且在第二页需要显示底部view */
@property (nonatomic , assign) BOOL isSameDeviceInOtherSide;



// 根据端子业务状态 返回颜色
- (UIColor *) colorFromState:(NSInteger) oprStateId needAlpha:(BOOL) needAlpha;

// 根据端子业务状态 返回文字
- (NSString *) msgFromState:(NSInteger) oprStateId;

// 判断对调后 ,是否还需要进行端子跳接
- (NSDictionary *) afterTerminalExchange_IsJumpT: (NSDictionary *) dictionary;


/// 销毁
- (void) destroy;


@end

NS_ASSUME_NONNULL_END
