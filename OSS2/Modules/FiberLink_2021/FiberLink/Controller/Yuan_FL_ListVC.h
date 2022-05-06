//
//  Yuan_FL_ListVC.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/12/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, FL_InitType_) {
    FL_InitType_OpticalFiber ,  //光纤
    FL_InitType_OpticalLink ,   //光链路
};



@interface Yuan_FL_ListVC : Inc_BaseVC


// 构造方法
- (instancetype) initWithEnum:(FL_InitType_)type;


/** 端子的GID */
@property (nonatomic ,copy)  NSString *opticTermId;

@end

NS_ASSUME_NONNULL_END
