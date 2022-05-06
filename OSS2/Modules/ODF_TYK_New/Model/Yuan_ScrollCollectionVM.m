//
//  Yuan_ScrollCollectionVM.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/3.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_ScrollCollectionVM.h"

@implementation Yuan_ScrollCollectionVM



/// 得到每个item 此时应该对应的 position的值
/// @param section 就是 collection.tag 从1 开始计算
/// @param row indexPath.row + 1  从1 开始计算
/// @param dire 排序方式 枚举
- (NSInteger) viewModelCollectionViewTag:(NSInteger)section
                                 viewRow:(NSInteger)row
                               hangCount:(int)hangCount
                                lieCount:(int)lieCount
                                    Dire:(Direction_)dire{
    
    switch (dire) {
        case Direction_UpLeft:              //上左
            
           return  [self UpLeftTag:section
                           viewRow:row
                         hangCount:hangCount
                          lieCount:lieCount];
            break;
            
        case Direction_UpRight:             //上右
            
            return  [self UpRightTag:section
                             viewRow:row
                           hangCount:hangCount
                            lieCount:lieCount];
            break;
            
        case Direction_DownLeft:            //下左
        
            return  [self DownLeftTag:section
                              viewRow:row
                            hangCount:hangCount
                             lieCount:lieCount];
            break;
            
        case Direction_DownRight:           //下右
            
            return  [self DownRightTag:section
                               viewRow:row
                             hangCount:hangCount
                              lieCount:lieCount];
            break;
            
        default:
            break;
    }
    
    
    
    
    return 0;
    
}


#pragma mark - 上左 *** ***

- (NSInteger) UpLeftTag:(NSInteger)section
                viewRow:(NSInteger)row
              hangCount:(int)hangCount
               lieCount:(int)lieCount {

    
    // (当前列 - 1 ) * 总行数 + 当前行
    return (row - 1) * hangCount + section;
}


#pragma mark - 上右 *** ***

- (NSInteger) UpRightTag:(NSInteger)section
                 viewRow:(NSInteger)row
               hangCount:(int)hangCount
                lieCount:(int)lieCount {

    // (最大列 - 当前列) * 总行数 + 当前行
    return (lieCount - row) * hangCount + section;
}


#pragma mark - 下左 *** ***

- (NSInteger) DownLeftTag:(NSInteger)section
                  viewRow:(NSInteger)row
                hangCount:(int)hangCount
                 lieCount:(int)lieCount {
    // (当前列 - 1) * 最大行 + (最大行 - 当前行 + 1)
    return (row - 1) * hangCount + (hangCount - section + 1);
}



#pragma mark - 下右 *** ***

- (NSInteger) DownRightTag:(NSInteger)section
                   viewRow:(NSInteger)row
                 hangCount:(int)hangCount
                  lieCount:(int)lieCount {

    
    // (最大列 - 当前列) * 最大行 + (最大行 - 当前行 + 1)
    return (lieCount - row) * hangCount + (hangCount - section + 1);
}



@end
