//
//  Yuan_PickerView.m
//  FTP图影音
//
//  Created by 袁全 on 2020/3/18.
//  Copyright © 2020 袁全. All rights reserved.
//

#import "Yuan_PickerView.h"





@interface Yuan_PickerView ()

<
    UIPickerViewDelegate ,
    UIPickerViewDataSource
>



/** 确认按钮 */
@property (nonatomic,strong) UIButton *enterButton;



/* block 用来给调用者回调 每个picker上都展示的值 */
// [self selectDateTimestamp] 方法中调用
// MARK: 为什么要把block 加入到构造方法中 ? 因为不实现block会闪退 只能通过 if(block) 去判断
@property (nonatomic ,copy) selectDateTimestampBlock block;

@end

@implementation Yuan_PickerView


{
    // 个数
    NSInteger _section_Count;
    
    BOOL _isMustFuture;
    
}

- (UIPickerView *)pickerView {
    
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.backgroundColor = ColorValue_RGB(0xf2f2f2);
        _pickerView.delegate   = self;
        _pickerView.dataSource = self;
        
        
        if (_isMustFuture) {
            _dataSourece = [[Yuan_PickerDataSource alloc] initWithFuture];
        }
        else {
            _dataSourece = [[Yuan_PickerDataSource alloc] init];
        }
        
        __block UIPickerView * picker = _pickerView;
        __typeof(self)wself = self;
        _dataSourece.reloadPickerDataSourceBlock = ^{
                
            [picker reloadAllComponents];

#warning 为什么要用0.5秒的延迟加载 ?  以防止刷新过快 , 导致的数组越界 [_pickerView selectedRowInComponent:1] 中 , datasource已经更新为新数组 , 可picker还停留在老地方 , 取老地方的indexpath.row 导致数组越界

            //在刷新数据后的0.5秒 , 更新回调的值
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wself selectDateTimestamp];
            });
        };
        
        if (_section_Count && _section_Count > 0 && _section_Count <= 5) {
        
            NSArray * array = @[_dataSourece.year,
                                _dataSourece.month,
                                _dataSourece.day,
                                _dataSourece.hour,
                                _dataSourece.minute];
            
            for (int i = 0; i < _section_Count; i++) {
                
                NSArray * dataSource = array[i];
                
                // 必须是未来时  年月日
                if (_isMustFuture) {
                    [_pickerView selectRow:0
                               inComponent:i
                                  animated:YES];
                    continue;
                }
                
                [_pickerView selectRow:dataSource.count - 1
                           inComponent:i
                              animated:YES];
                
            }
        }else {
            
            [[Yuan_HUD shareInstance] HUDFullText:@"传入的count 超出范围"];
        }
        
        
        
        
        // 年月日
//        [_pickerView selectRow:_dataSourece.year.count - 1
//                   inComponent:0 animated:YES];
//        [_pickerView selectRow:_dataSourece.month.count - 1
//                   inComponent:1 animated:YES];
//        [_pickerView selectRow:_dataSourece.day.count - 1
//                   inComponent:2 animated:YES];
//
//        //时分
//        [_pickerView selectRow:_dataSourece.hour.count - 1
//                   inComponent:3 animated:YES];
//        [_pickerView selectRow:_dataSourece.minute.count - 1
//                   inComponent:4 animated:YES];
        
        
        
        
    }
    return _pickerView;
}


- (UIButton *)enterButton {
    
    if (!_enterButton) {
        _enterButton = [UIView buttonWithTitle:@"确定" responder:self SEL:@selector(enterBtnClick) frame:CGRectNull];
        _enterButton.layer.cornerRadius = 5;
        _enterButton.layer.masksToBounds = YES;
        [_enterButton setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    }
    return _enterButton;
}


- (void) initWith {
    
    self.backgroundColor = UIColor.lightGrayColor;
    
    [self addSubview:self.pickerView];
    [self addSubview:self.enterButton];
    
    [self layoutAllSubViews];
    self.backgroundColor = [UIColor whiteColor];
    
}


- (instancetype) initWithFrame:(CGRect)frame
                   PickerBlock:(selectDateTimestampBlock) block{
    
    if (self = [super initWithFrame:frame]) {
        
        
        _section_Count = 5;
        self.backgroundColor = UIColor.whiteColor;
        [self addSubview:self.pickerView];
        
        _pickerView.frame = frame;
        
        @try {
            self.block = block;
        } @catch (NSException *exception) {
            [YuanHUD HUDFullText:@"请开发者实现 Yuan_Picker的block方法"];
        }
        
        
    }
    return self;
    
}



- (instancetype) initWithFrame:(CGRect)frame
                   PickerBlock:(selectDateTimestampBlock ) block
                       section:(NSInteger)secton_Count {
    
    if (self = [super initWithFrame:frame]) {
        
        
        self.backgroundColor = UIColor.whiteColor;
        _section_Count = secton_Count <= 5 ? secton_Count : 5;
        
//        [self addSubview:self.pickerView];
//        _pickerView.frame = frame;
        
        [self initWith];
        
        @try {
            self.block = block;
        } @catch (NSException *exception) {
            [YuanHUD HUDFullText:@"请开发者实现 Yuan_Picker的block方法"];
        }
        
        
    }
    return self;
}




- (void) OnlyDataSource:(NSArray *)dataSource  {
    
    
    _dataSourece.year = [dataSource mutableCopy];
    
    [_pickerView reloadComponent:0];
}


// 只能查看为了的时间
- (void) needFuture {
    
    _isMustFuture = YES;
    [_pickerView removeFromSuperview];
    _pickerView = nil;
    
    [_enterButton removeFromSuperview];
    _enterButton = nil;
    
    [self addSubview:self.pickerView];
    [self addSubview:self.enterButton];
    
    [self layoutAllSubViews];
    
}


#pragma mark - 把各个pickerView component列上的值 通过block回调给外界

- (void)selectDateTimestamp {
    
    
        
    NSString * year = _dataSourece.year[[_pickerView selectedRowInComponent:0]];
    NSString * month = _section_Count - 1 >= 1 ? _dataSourece.month[[_pickerView selectedRowInComponent:1]] : @"";
    NSString * day = _section_Count - 1 >= 2 ? _dataSourece.day[[_pickerView selectedRowInComponent:2]] : @"";
    NSString * hour = _section_Count - 1 >= 3 ? _dataSourece.hour[[_pickerView selectedRowInComponent:3]] :@"";
    NSString * minute = _section_Count - 1 >= 4 ? _dataSourece.minute[[_pickerView selectedRowInComponent:4]] : @"";
    
    if (self.block) {   //当存在block时 执行
        self.block(year, month, day, hour, minute);
    }
}



#pragma mark - >>>>>>>>>>>>  UIPickerViewDelegate & UIPickerViewDataSource <<<<<<<<<<<<

// returns the number of 'columns' to display.
// MARK: 一共有多少组
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{

    return _section_Count ?:0;
}


// MARK: 每组各有多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    NSInteger count = 0;
    
    switch (component) {
        case 0:
            count = [_dataSourece year].count;
            break;
        case 1:
            count = [_dataSourece month].count;
            break;
        case 2:
            count = [_dataSourece day].count;
            break;
        case 3:
            count = [_dataSourece hour].count;
            break;
        case 4:
            count = [_dataSourece minute].count;
        break;
            
        default:
            break;
    }
    
    return count;
}


// MARK: 每一行显示的内容都是什么 ?
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED{
    NSString * titleStr;
    
    switch (component) {
        case 0:
            //年
            titleStr = [_dataSourece year][row];
            titleStr = [titleStr stringByAppendingFormat:@"年"];
            break;
        case 1:
            //月
            titleStr = [_dataSourece month][row];
            titleStr = [titleStr stringByAppendingFormat:@"月"];
            break;
        case 2:
            //日
            titleStr = [_dataSourece day][row];
            titleStr = [titleStr stringByAppendingFormat:@"日"];
            break;
        case 3:
            //时
            titleStr = [_dataSourece hour][row];
            titleStr = [titleStr stringByAppendingFormat:@"点"];
            break;
        case 4:
            //分
            titleStr = [_dataSourece minute][row];
            titleStr = [titleStr stringByAppendingFormat:@"分"];
            break;
            
        default:
            break;
    }
        
    return titleStr;
}


//每行的高度和宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component __TVOS_PROHIBITED{

    return  (100)/3;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return 60;
    
}


// MARK: 每次滑动 都会走这个回调接口
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED{
    
    int selectYear = 0 ;
    int selectMonth = 0;
    int selectDay = 0;
    
    switch (component) {
        case 0:
            selectYear = (int)[[_dataSourece year][row] intValue];
            break;
         case 1:
            selectMonth = (int)[[_dataSourece month][row] intValue];
            break;
        case 2:
            selectDay = (int)[[_dataSourece day][row] intValue];
            break;
        default:
            break;
    }
    
    
    // 去刷新数据源喽
    [_dataSourece reloadDateYear:selectYear
                           Month:selectMonth
                             Day:selectDay];
    
    
    
}



//给picker上的文字字体做一些微调
-(UIView *)pickerView:(UIPickerView *)pickerView
           viewForRow:(NSInteger)row
         forComponent:(NSInteger)component
          reusingView:(UIView *)view {
    
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.minimumScaleFactor = 8.;
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:13]];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    return pickerLabel;
}




//选中今天
- (void) select_Today {
    
    
    NSArray * array = @[_dataSourece.year,
                        _dataSourece.month,
                        _dataSourece.day,
                        _dataSourece.hour,
                        _dataSourece.minute];
    
    for (int i = 0; i < _section_Count; i++) {
        
        NSArray * subArr = array[i];
        
        [_pickerView selectRow:subArr.count - 1
                   inComponent:i
                      animated:true];
    }
    
    
    
}



#pragma mark - 点击事件

// 确认按钮的点击事件
- (void) enterBtnClick {
    
    if (!_selectBlock) {
        return;
    }
    
    
    NSString * year = _dataSourece.year[[_pickerView selectedRowInComponent:0]];
    NSString * month = _section_Count - 1 >= 1 ? _dataSourece.month[[_pickerView selectedRowInComponent:1]] : @"";
    NSString * day = _section_Count - 1 >= 2 ? _dataSourece.day[[_pickerView selectedRowInComponent:2]] : @"";
    NSString * hour = _section_Count - 1 >= 3 ? _dataSourece.hour[[_pickerView selectedRowInComponent:3]] :@"";
    NSString * minute = _section_Count - 1 >= 4 ? _dataSourece.minute[[_pickerView selectedRowInComponent:4]] : @"";
    
    _selectBlock(year,month,day,hour,minute);
    
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    [_pickerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_pickerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_pickerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_pickerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:Vertical(40)];
    
    
    [_enterButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset: 5 ];
    [_enterButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [_enterButton autoSetDimensionsToSize:CGSizeMake(Horizontal(50), Vertical(30))];
    
}


@end
