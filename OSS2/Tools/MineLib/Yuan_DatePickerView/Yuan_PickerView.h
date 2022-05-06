//
//  Yuan_PickerView.h
//  FTP图影音
//
//  Created by 袁全 on 2020/3/18.
//  Copyright © 2020 袁全. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Yuan_PickerDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_PickerView : UIView




typedef void (^selectDateTimestampBlock)(NSString * year,
                                         NSString * month,
                                         NSString * day,
                                         NSString * hour,
                                         NSString * minute);


/** pickerView */
@property (nonatomic,strong) UIPickerView *pickerView;

/** 数据源 */
@property (nonatomic,strong) Yuan_PickerDataSource * dataSourece;




/* 不给block赋值 不回调 */
- (instancetype) initWithFrame:(CGRect)frame
                   PickerBlock:(selectDateTimestampBlock) block;



- (instancetype) initWithFrame:(CGRect)frame
                   PickerBlock:(selectDateTimestampBlock) block section:(NSInteger)secton_Count;




/** <#注释#>  block */
@property (nonatomic , copy) selectDateTimestampBlock selectBlock;


/// 切换数据源 不用年了
/// @param dataSource 数据源 暂时只支持单列
- (void) OnlyDataSource:(NSArray *)dataSource ;


//选中今天
- (void) select_Today;


// 只能查看为了的时间
- (void) needFuture;

@end

NS_ASSUME_NONNULL_END
