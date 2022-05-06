//
//  Yuan_PickerDataSource.m
//  FTP图影音
//
//  Created by 袁全 on 2020/3/18.
//  Copyright © 2020 袁全. All rights reserved.
//

#import "Yuan_PickerDataSource.h"

#define MINYEAR 2000

#pragma mark - Yuan_PickerDataSource



@interface Yuan_PickerDataSource()
{
            
    int selectYears;            //刷新时传值 , 你选中的是哪年 ? 2020
    int selectMonths;           //刷新时传值 , 你选中的是几月 ? 3
    int selectDays;             //刷新时传值 , 你选中的是几号 ?
    
    
    
    int _nowYear ;              //当下 今年是哪年
    int _nowMonth ;             //当下 这个月是几月
    int _nowDay ;               //当下 今天是几号
    
    int _nowHour;               //当下 现在是几点
    int _nowMinute;             //当下 几分?
    
    
    BOOL _isMustFuture;
}

@end


@implementation Yuan_PickerDataSource

#pragma mark - 初始化构造方法

- (instancetype) init{
    
    if (self = [super init]) {
        
        _nowYear = 0;
        _nowMonth = 0;
        _nowDay = 0;
        
        _nowHour = 0;
        _nowMinute = 0;
        
        
        //获取当前时间 年月日 时分
        [self getNowDateAndTime];
        
        // 并且在刚初始化时 , 让选中的日期是今天
        selectYears = _nowYear;
        selectMonths = _nowMonth;
        selectDays = _nowDay;
        
        
        
        [self initDataSources];
        
       
    }
    return self;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithFuture{
    
    if (self = [super init]) {
        _nowYear = 0;
        _nowMonth = 0;
        _nowDay = 0;
        
        _nowHour = 0;
        _nowMinute = 0;
        
        
        //获取当前时间 年月日 时分
        [self getNowDateAndTime];
        
        // 并且在刚初始化时 , 让选中的日期是今天
        selectYears = _nowYear;
        selectMonths = _nowMonth;
        selectDays = _nowDay;
        
        _isMustFuture = YES;
        
        [self initDataSources];
        
       
    }
    return self;
}



- (void) initDataSources {

    
    // 为数组赋值
    [self dataSourceYear];
    [self dataSourceMonth];
    [self dataSourceDay];
    [self dataSourceHourMinute];
    
    
}

#pragma mark - 年


- (void) dataSourceYear{
    
    _year = [NSMutableArray array];
    
    if (_isMustFuture) {
        
        int now = [Yuan_Foundation currentYear].intValue;
        
        for (int i = now; i < _nowYear + 51 ; i++) {
            [_year addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    else {
        
        for (int i = MINYEAR; i < _nowYear + 1 ; i++) {
            [_year addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    

}


#pragma mark - 月
- (void) dataSourceMonth{
    
    _month = [NSMutableArray array];
    
    // 如果选中的年份是今年 , 那么月份能选中的最大月份就是 当前月份
    if (selectYears == _nowYear) {
        
        if (_isMustFuture) {
            
            for (int i = _nowMonth; i < 13; i++) {
                [_month addObject:[NSString stringWithFormat:@"%.2d",i]];
            }
        }
        
        else {
            
            for (int i = 1; i < _nowMonth + 1; i++) {
                [_month addObject:[NSString stringWithFormat:@"%.2d",i]];
            }
        }
        

        return;
    }
    
    
    
    // 如果不是今年 , 那就可以选12个月喽
    for (int i = 1; i < 13; i++) {
        [_month addObject:[NSString stringWithFormat:@"%.2d",i]];
    }
    
}

#pragma mark - 日
- (void) dataSourceDay{
    
    _day = [NSMutableArray array];
    
    int maxDay = 0;
    // 根据选中的月份不同 返回不同的月日期
    switch (selectMonths) {
        case 1:
            maxDay = 31;
            break;
        case 2:
            maxDay = selectYears % 4 == 0 ? 29 : 28;
            break;
        case 3:
            maxDay = 31;
            break;
        case 4:
            maxDay = 30;
            break;
        case 5:
            maxDay = 31;
            break;
        case 6:
            maxDay = 30;
            break;
        case 7:
            maxDay = 31;
            break;
        case 8:
            maxDay = 31;
            break;
        case 9:
            maxDay = 30;
            break;
        case 10:
            maxDay = 31;
            break;
        case 11:
            maxDay = 30;
            break;
        case 12:
            maxDay = 31;
            break;
            
        default:
            maxDay = 31;
            break;
    }
    
    // 当选择的是今年 并且 (选择的月份是本月 或者大于本月 , 都归置为今天)
    if (selectYears == _nowYear && ( selectMonths == _nowMonth || selectMonths > _nowMonth)) {
        // 选中的是当前月 当前年份  , 那么日期最大选中期限就是今天 !!
        
        
        if (_isMustFuture) {
            
            for (int i = _nowDay ; i < maxDay + 1; i++) {
                [_day addObject:[NSString stringWithFormat:@"%.2d",i]];
            }
        }
        
        else {
            for (int i = 1 ; i < _nowDay + 1; i++) {
                [_day addObject:[NSString stringWithFormat:@"%.2d",i]];
            }
        }
        
        return;
    }
    
    // 否则的话 , 就是根据月份吧 13578,12 这样选了
    for (int i = 1 ; i < maxDay + 1; i++) {
        [_day addObject:[NSString stringWithFormat:@"%.2d",i]];
    }
    
}


#pragma mark - 时分
- (void) dataSourceHourMinute {
    
    _hour = [NSMutableArray array];
    _minute = [NSMutableArray array];
    
    
    if (_isMustFuture) {
        for (int i = 0 ; i < 24; i++) {
            [_hour addObject:[NSString stringWithFormat:@"%.2d",i]];
        }
        
        
        for (int i = 0; i < 60; i++) {
            
            [_minute addObject:[NSString stringWithFormat:@"%.2d",i]];
        }
        return;
    }
    
  
    if (selectYears == _nowYear && ( selectMonths == _nowMonth || selectMonths > _nowMonth) && (selectDays == _nowDay || selectDays > _nowDay ) ) {
        
        for (int i = 0; i < _nowHour + 1; i++) {
            [_hour addObject:[NSString stringWithFormat:@"%.2d",i]];
        }
        
        for (int i = 0; i < _nowMinute + 1; i++) {
            [_minute addObject:[NSString stringWithFormat:@"%.2d",i]];
        }
        return;
    }
    
    
    
    for (int i = 0 ; i < 24; i++) {
        [_hour addObject:[NSString stringWithFormat:@"%.2d",i]];
    }
    
    
    for (int i = 0; i < 60; i++) {
        
        [_minute addObject:[NSString stringWithFormat:@"%.2d",i]];
    }
    
}




- (void) reloadDateYear:(int)year Month:(int)month Day:(int)day{
    
    
    
    // MARK: 给选中项赋值
    selectYears = year == 0 ? selectYears : year;
    selectMonths = month == 0 ? selectMonths : month;
    selectDays = day == 0 ? selectDays : day;
    
    [self initDataSources];
    
    // 调用block 让dataPicker刷新数据源
    self.reloadPickerDataSourceBlock();
    
}


- (void) getNowDateAndTime {
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *timeString = [formatter stringFromDate:[NSDate date]];
    
    NSArray * dateAndTimeArray = [timeString componentsSeparatedByString:@" "];
    
    
    
    NSString * date = dateAndTimeArray[0];
    
    if (date) {
        
        NSArray * YMD = [date componentsSeparatedByString:@"-"];
        
        if (YMD.count == 3) {
            _nowYear = (int)[YMD[0] intValue];
            _nowMonth = (int)[YMD[1] intValue];
            _nowDay = (int)[YMD[2] intValue];
        }
    }
    
    
    
    
    NSString * time = [dateAndTimeArray lastObject];
    
    if (time) {
        
        NSArray * HM = [time componentsSeparatedByString:@":"];
        
        if (HM.count == 2) {
            _nowHour = (int)[[HM firstObject] intValue];
            _nowMinute = (int)[[HM lastObject] intValue];
        }
    }
}

@end




















#pragma mark - Yuan_pickerDataSourceDateAndTime

@implementation Yuan_pickerDataSourceDateAndTime


#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
        
    }
    return self;
}



@end
