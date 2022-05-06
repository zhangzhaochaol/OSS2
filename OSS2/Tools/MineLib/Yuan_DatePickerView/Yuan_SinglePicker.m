//
//  Yuan_SinglePicker.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/2.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_SinglePicker.h"

@interface Yuan_SinglePicker ()


<
    UIPickerViewDelegate ,
    UIPickerViewDataSource
>


/** pickerView */
@property (nonatomic,strong) UIPickerView *pickerView;

@end

@implementation Yuan_SinglePicker
{
    
    

    // MARK: 为什么要把block 加入到构造方法中 ? 因为不实现block会闪退 只能通过 if(block) 去判断
    selectTampBlock _block;
}



/* 不给block赋值 不回调 */
- (instancetype) initWithFrame:(CGRect)frame
                    dataSource:(NSArray *)dataSource
                   PickerBlock:(selectTampBlock) block  {
    
    if (self = [super initWithFrame:frame]) {
        
        _dataSource = dataSource;
        
        _block = block;
        
        _selectRowTxt = [dataSource firstObject];
        
        [self addSubview:self.pickerView];
        [self layoutAllSubViews];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}



// 滚动到某一指定位置
- (void) scrollToIndex:(NSInteger)index {
    
    [_pickerView selectRow:index inComponent:0 animated:YES];
}



#pragma mark - >>>>>>>>>>>>  UIPickerViewDelegate & UIPickerViewDataSource <<<<<<<<<<<<

// returns the number of 'columns' to display.
// MARK: 一共有多少组
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{

    return 1;
}


// MARK: 每组各有多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return _dataSource.count;
}


// MARK: 每一行显示的内容都是什么 ?
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED{
    
    return _dataSource[row];
}


//每行的高度和宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component __TVOS_PROHIBITED{

    return  (100)/3;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView
    widthForComponent:(NSInteger)component {
    
    return ScreenWidth;
    
}


// MARK: 每次滑动 都会走这个回调接口
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component __TVOS_PROHIBITED{
    
    
    
    
    if (component == 0) {
        _selectRowTxt = _dataSource[row];
    }
    
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
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:17]];
        pickerLabel.textColor = ColorValue_RGB(0x333333);
    }
    
    pickerLabel.text = [self pickerView:pickerView
                            titleForRow:row
                           forComponent:component];
    
    return pickerLabel;
}


#pragma mark - 懒加载

- (UIPickerView *)pickerView {
    
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.delegate   = self;
        _pickerView.dataSource = self;
        
        [_pickerView selectRow:0 inComponent:0 animated:YES];
    }
    return _pickerView;
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    [_pickerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_pickerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_pickerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_pickerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    
}

@end
