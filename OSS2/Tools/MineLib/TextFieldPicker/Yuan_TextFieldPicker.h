//
//  Yuan_TextFieldPicker.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_TextFieldPicker : NSObject

/** <#注释#>  block */
@property (nonatomic , copy) void (^commitBlock) (NSInteger selectIndex);


- (instancetype)initWithDataSource:(NSArray *)dataSource
                         textField:(UITextField *)textField;

- (void) show;

// 滚动到某一指定位置
- (void) scrollToIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
