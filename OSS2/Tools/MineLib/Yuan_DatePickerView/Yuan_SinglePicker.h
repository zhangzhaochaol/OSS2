//
//  Yuan_SinglePicker.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/2.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



typedef void (^selectTampBlock)(NSString * select);




@interface Yuan_SinglePicker : UIView



/** 数据源 */
@property (nonatomic,strong) NSArray * dataSource;

/** 选中的文字 */
@property (nonatomic,copy,readonly) NSString * selectRowTxt;


/* 不给block赋值 不回调 */
- (instancetype) initWithFrame:(CGRect)frame
                    dataSource:(NSArray *)dataSource
                   PickerBlock:(selectTampBlock) block ;


// 滚动到某一指定位置
- (void) scrollToIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
