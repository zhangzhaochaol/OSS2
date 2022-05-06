//
//  Inc_NewMB_AssistLocationVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2022/2/16.
//  Copyright © 2022 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"
#import "Inc_NewMB_VM.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_NewMB_AssistLocationVC : Inc_BaseVC

- (instancetype)initWithLocationRes:(NSArray *) datas
                          modelEnum:(Yuan_NewMB_ModelEnum_)modelEnum;

@end

NS_ASSUME_NONNULL_END
