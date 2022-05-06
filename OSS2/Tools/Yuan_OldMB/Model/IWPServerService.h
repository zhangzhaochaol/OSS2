//
//  IWPServerService.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2017/9/1.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IWPServerModel;
/////******* 此类用于管理和获取服务器列表 *******/////

@interface IWPServerService : NSObject

/**
 获取当前应用地址
 */
@property (nonatomic, copy, readonly) NSString * link;
@property (nonatomic, copy, readonly) NSString * errMessage;
@property (nonatomic, strong) NSArray <IWPServerModel *>* servers;
+ (instancetype)sharedService;

- (void)serverList:(dispatch_block_t)block;

- (void)setCurrentLink:(IWPServerModel *)model;
@end
