//
//  Inc_HomeResCollectionVC.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/6/28.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inc_BaseVC.h"

@interface Inc_HomeResCollectionVC : Inc_BaseVC
@property(nonatomic,strong) NSArray *subItemArr;
@property(nonatomic,strong) NSString *sourceString;//从配置文件读取的源内容
+(void)setResourceTYKMainTitleStr:(NSString *)str;
- (NSDictionary *)analysisFileWithSourceString:(NSString *)sourceString :(NSString *)comperKey;
@end
