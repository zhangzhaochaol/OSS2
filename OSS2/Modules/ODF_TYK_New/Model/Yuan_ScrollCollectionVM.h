//
//  Yuan_ScrollCollectionVM.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/3.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_ScrollCollectionVM : NSObject


/// 得到每个item 此时应该对应的 position的值
/// @param section 就是 collection.tag 从1 开始计算
/// @param row indexPath.row  从1 开始计算
/// @param hangCount 行数
/// @param lieCount 列数
/// @param dire 排序方式 枚举

- (NSInteger) viewModelCollectionViewTag:(NSInteger)section
                                 viewRow:(NSInteger)row
                               hangCount:(int)hangCount
                                lieCount:(int)lieCount
                                    Dire:(Direction_)dire;

@end

NS_ASSUME_NONNULL_END
