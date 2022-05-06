//
//  Yuan_ImageCheckChooseVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_ImageCheckChooseVC : Inc_BaseVC

- (instancetype)initWithImage:(UIImage * )image
                   dataSource:(NSArray *)dataSource;


/** 行内个数 */
@property (nonatomic , assign) NSInteger inlineNums;

/** 行数 */
@property (nonatomic , assign) NSInteger lineCount;

/** <#注释#>  block */
@property (nonatomic , copy) void (^finishBlock) (void);


@end

NS_ASSUME_NONNULL_END
