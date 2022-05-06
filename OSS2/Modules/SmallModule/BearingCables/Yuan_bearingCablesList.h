//
//  Yuan_bearingCablesList.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/9/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_bearingCablesList : Inc_BaseVC

/** map */
@property (nonatomic ,copy)  NSDictionary *requestDict;


/** tube 管孔时 , 如果是从子孔进入的 ,保存时 会在requestDict中 新增 isFather = 2的字段*/
@property (nonatomic ,assign) BOOL isNeed_isFather;

@end

NS_ASSUME_NONNULL_END
