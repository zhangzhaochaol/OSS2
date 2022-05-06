//
//  Inc_PoleStateBtn.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/9/6.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger , PoleState_) {

    PoleState_AddPole = 1,                  //添加电杆
    PoleState_AddSupportingPoints,          //添加撑点
    
    
    PoleState_AddPoleLine = 3,              //添加杆路段
    PoleState_NearSupportingPoints,         //附近撑点
    PoleState_NearPoleLine,                 //附近杆路段
    
    PoleState_AddPoleLine_Select = 6,       //添加杆路段
    
};

@interface Inc_PoleStateBtn : UIButton


- (instancetype)initWithBtnState:(PoleState_)Enum;


/** 枚举类型 */
@property (nonatomic , assign , readonly) PoleState_ myEnum;


// 切换选中状态
- (void) myState_IsSelect:(BOOL) mySelectState;

@end

NS_ASSUME_NONNULL_END
