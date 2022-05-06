//
//  Inc_PoleNC_ViewModel.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/9/7.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , PoleLocationEnum_) {
    
    PoleLocationEnum_Auto,
    PoleLocationEnum_Handle,
};


@interface Inc_PoleNC_ViewModel : NSObject

+ (Inc_PoleNC_ViewModel *) shareInstance;

/** 杆路的模板 */
@property (nonatomic , copy) NSDictionary * mb_Dict;

/** 是否是关联模式下 */
@property (nonatomic , assign) BOOL isConnectModel;

/** 定位模式 */
@property (nonatomic , assign) PoleLocationEnum_ poleLocationEnum;

@end

NS_ASSUME_NONNULL_END
