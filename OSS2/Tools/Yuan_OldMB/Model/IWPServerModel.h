//
//  IWPServerModel.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2017/9/1.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWPServerModel : NSObject
@property (nonatomic, copy) NSString * host;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, copy) NSString * appName;
@property (nonatomic, copy) NSString * serverName;
@property (nonatomic, copy) NSString * displayIP;
@property (nonatomic, copy) NSString * schame;
+(instancetype)modelWithDict:(NSDictionary *)dict;
-(instancetype)initWithDict:(NSDictionary *)dict;
@end
