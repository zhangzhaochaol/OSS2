//
//  INCBaseModel.h
//  ChinaUnicom_Liaoning
//
//  Created by 王旭焜 on 2018/3/21.
//  Copyright © 2018年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^NEW)(NSDictionary * dict);

@interface INCBaseModel : NSObject <NSSecureCoding>
- (NSDictionary *)makeDictionary;
- (NSString *)makeJSON;
- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)modelWithDict:(NSDictionary *)dict;
+ (NEW)create;
@end

@interface NSObject (INCBaseModel)

@end
