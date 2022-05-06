//
//  Yuan_ODF_InitVC.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/28.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_ODF_InitVC : Inc_BaseVC



/// 初始化构造方法
/// @param num 序号
/// @param isFaceInverse 正反面 
- (instancetype) initWithNum:(NSInteger)num
                 faceInverse:(BOOL)isFaceInverse
                        name:(NSString *)name;

/** 声明 saveBtnBlock 的block */
@property (nonatomic ,copy) void(^saveBtnBlock)(NSDictionary * dict);


@end

NS_ASSUME_NONNULL_END
