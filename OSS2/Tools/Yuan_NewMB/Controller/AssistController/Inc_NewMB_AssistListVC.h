//
//  Inc_NewMB_AssistListVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/13.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inc_NewMB_VM.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger , Assist_HttpPort_) {
    Assist_HttpPort_NULL,           //啥也不是
    Assist_HttpPort_OLTPort,        //搜索OLT端口
    Assist_HttpPort_Region,         //搜索所属维护区域
    Assist_HttpPort_Manufacturer,   //生产厂家
    Assist_HttpPort_MaintainUnit,   //维护单位
};

@interface Inc_NewMB_AssistListVC : UIViewController

- (instancetype)initWithAssistPort:(Assist_HttpPort_) HttpPort
                          postDict:(NSDictionary *) postDict
                   isHaveSearchBar:(BOOL) isHaveSearchBar;


/** 选择的回调  block */
@property (nonatomic , copy) void (^selectBlock) (NSDictionary * dict);

@end

NS_ASSUME_NONNULL_END
