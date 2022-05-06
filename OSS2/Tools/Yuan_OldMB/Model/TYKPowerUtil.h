//
//  TYKPowerUtil.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/10/27.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYKPowerUtil : NSObject
/*
 * 获取当前版本统一库上的全部资源类型
 */
-(NSMutableArray *)getHaveTYKRes:(NSMutableArray *)powersArr;
/*
 * 当前资源是否为统一库内资源
 */
-(BOOL)isInTYKRes:(NSString *)s;
@end
