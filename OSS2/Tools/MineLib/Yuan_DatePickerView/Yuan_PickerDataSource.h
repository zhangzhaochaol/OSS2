//
//  Yuan_PickerDataSource.h
//  FTP图影音
//
//  Created by 袁全 on 2020/3/18.
//  Copyright © 2020 袁全. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_PickerDataSource : NSObject


// 如果必须使用未来的时间 则走这个构造方法
- (instancetype)initWithFuture;


/** 年 */
@property (nonatomic,strong) NSMutableArray *year;

/** 月  */
@property (nonatomic,strong) NSMutableArray *month;

/** 日 */
@property (nonatomic,strong) NSMutableArray *day;

/** 时 */
@property (nonatomic,strong) NSMutableArray *hour;

/** 分 */
@property (nonatomic,strong) NSMutableArray *minute;





- (void) reloadDateYear:(int)year Month:(int)month Day:(int)day;

@property (nonatomic ,copy) void(^reloadPickerDataSourceBlock)(void);

@end




@interface Yuan_pickerDataSourceDateAndTime : NSObject

/** 年 */
@property (nonatomic,strong,readonly) NSMutableArray *year;

/** 月  */
@property (nonatomic,strong,readonly) NSMutableArray *month;

/** 日 */
@property (nonatomic,strong,readonly) NSMutableArray *day;

/** 时 */
@property (nonatomic,strong,readonly) NSMutableArray *hour;

/** 分 */
@property (nonatomic,strong,readonly) NSMutableArray *minute;

@end




NS_ASSUME_NONNULL_END
