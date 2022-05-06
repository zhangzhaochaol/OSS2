//
//  Yuan_ScrollVC.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/3.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_ScrollVC : Inc_BaseVC



/// 构造方法
/// @param dict 根据端子盘信息 , 初始化
- (instancetype) initWithDict:(NSDictionary *)dict;


/** 上层设备的模板Dict */
@property (nonatomic , copy) NSDictionary * mb_Dict;



@end

NS_ASSUME_NONNULL_END
