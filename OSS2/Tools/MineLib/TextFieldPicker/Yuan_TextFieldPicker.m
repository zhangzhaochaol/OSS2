//
//  Yuan_TextFieldPicker.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_TextFieldPicker.h"
#import "Yuan_SinglePicker.h"



@implementation Yuan_TextFieldPicker
{
    
    Yuan_SinglePicker * _picker;
    
    NSArray * _dataSource;
    
    UITextField * _textField;
    
    NSInteger _menuSelectRow; // 当前点击的是第几行
}



#pragma mark - 初始化构造方法

- (instancetype)initWithDataSource:(NSArray *)dataSource
                         textField:(UITextField *)textField{
    
    if (self = [super init]) {
        _dataSource = dataSource;
        _textField = textField;
        [self configPickerData];
    }
    return self;
}



- (void) configPickerData {
    
    _textField.text = [_dataSource firstObject];
    
    CGRect pickerFrame = CGRectMake(0, 0, ScreenWidth, Vertical(250));
      

    _picker =
        [[Yuan_SinglePicker alloc] initWithFrame:pickerFrame
                                  dataSource:_dataSource
                                 PickerBlock:^(NSString * _Nonnull select) {}];
      
      
    _picker.backgroundColor = [UIColor whiteColor];
    _textField.inputView = _picker;


    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, IphoneSize_Height(44))];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.clipsToBounds = YES;
    toolBar.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *doneButton =  [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain  target:self action:@selector(commit)];
    doneButton.tintColor = [UIColor blueColor];

    doneButton.mainView = _textField;

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain  target:self action:@selector(cancel)];
    cancelButton.mainView = _textField;
    cancelButton.tintColor = [UIColor blueColor];


    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];

    [toolBar layoutIfNeeded];
    
    _textField.inputAccessoryView = toolBar;

//    _textField.backgroundColor = ColorValue_RGB(0xf2f2f2);
    
}


- (void) commit {
    
    
    [[UIApplication sharedApplication].delegate.window endEditing:YES];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        NSString * key = _picker.selectRowTxt;
        
        _textField.text =  key;
        
        
        // 获取当前滚动到了第几行
        
        NSInteger nowSelect = [_dataSource indexOfObject:key];
        
        _menuSelectRow = nowSelect;
        
        if (_commitBlock) {
            _commitBlock(nowSelect);
        }
        
    });
    
}


- (void) cancel {
    [[UIApplication sharedApplication].delegate.window endEditing:YES];
}



- (void) show {
    
    [_textField becomeFirstResponder];
}



// 滚动到某一指定位置
- (void) scrollToIndex:(NSInteger)index {
    

    
}


@end
