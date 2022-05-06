//
//  Yuan_RCHis_NavView.m
//  INCP&EManager
//
//  Created by 袁全 on 2020/6/17.
//  Copyright © 2020 Unigame.space. All rights reserved.
//

#import "Yuan_RCHis_NavView.h"

#import "Yuan_RCListHistory_NavBtn.h"

#import "Yuan_PickerView.h"





@interface Yuan_RCHis_NavView ()

/** 日期选择 */
@property (nonatomic,strong) UITextField *dateField;


@end

@implementation Yuan_RCHis_NavView
{
    
    NSMutableArray * _btnArrays;
    
    NSString * _dateChooseDay ;
    
    NSString * _postStr;
    
    /// 代理回调的map
    NSMutableDictionary * _delegateDict;
}

#pragma mark - 初始化构造方法

- (instancetype) init {
    
    
    if (self = [super init]) {
        
        _btnArrays = [NSMutableArray array];
        
        _delegateDict = [NSMutableDictionary dictionary];
        
        
        // 默认选择的是今天
        _dateChooseDay = [Yuan_Foundation currentDate];
        // 默认的筛查格式是天
        _postStr = @"day";
        
        _delegateDict[@"date"] = _dateChooseDay;
        _delegateDict[@"queryCondition"] = _postStr;
        
        
        float limit = Horizontal(15);
        float btnWidth = Horizontal(60);
        
        [self addSubview:self.dateField];
        [self layoutAllSubViews];
        
        NSInteger tagStart = 100000;
        
        NSArray <NSString *> * btnsDataSource = @[@"当日",
                                                  @"当周",
                                                  @"当月",
                                                  @"本季度",
                                                  @"本年度"];
        
        for (int i = 0 ; i < btnsDataSource.count ; i++) {
            
            
            RC_ListHistoryBtn_SelectType type ;
            if (i == 0) { //默认选择的是当日
                type = RC_ListHistoryBtn_SelectType_Select;
            }else {
                type = RC_ListHistoryBtn_SelectType_Normal;
            }
            
            Yuan_RCListHistory_NavBtn * btn =
            [[Yuan_RCListHistory_NavBtn alloc] initWithTitle:btnsDataSource[i]  NavBtnChangeImageWithType:type];
         
            [self addSubview:btn];
            
            btn.tag = tagStart + i;
            
            btn.frame = CGRectMake((limit + btnWidth) * i + 10, 70, btnWidth, 25);
            
            [_btnArrays addObject:btn];
            
            [btn addTarget:self
                    action:@selector(btnClick:)
          forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    return self;
}




///MARK: 向 ViewController 发送代理回调  告诉他 开始加载请求  ---

- (void)delegateClick {
    
    
    BOOL isDelegate = [self.delegate respondsToSelector:@selector(RC_His_NavViewDict:)];
    // 直接回调
    if (isDelegate) {
        [self.delegate RC_His_NavViewDict:_delegateDict];
    }
    
}


#pragma mark - 点击事件


- (void) btnClick:(Yuan_RCListHistory_NavBtn *)sender {
    
    /// 重置 *** *** ***
    for (Yuan_RCListHistory_NavBtn * buttons in _btnArrays) {
        [buttons NavBtnChangeImageWithType:RC_ListHistoryBtn_SelectType_Normal];
    }
    
    _postStr = @"";
    
    /// 再赋值 *** *** ***
    NSInteger tag = sender.tag;
    [sender NavBtnChangeImageWithType:RC_ListHistoryBtn_SelectType_Select];
    
    
    switch (tag) {
        case 100000:
            // 当日
            _postStr = @"day";
            break;
        case 100001:
            // 当周
            _postStr = @"week";
            break;
         case 100002:
            // 当月
            _postStr = @"month";
            break;
        case 100003:
            // 当季度
            _postStr = @"season";
            break;
        case 100004:
            // 当年度
            _postStr = @"year";
        break;
            
        default:
            break;
    }
    
    
    // 本周 ? 本日 ....
    _delegateDict[@"queryCondition"] = _postStr;
    
    // 修改后 发送代理
    [self delegateClick];
    
    
}






- (void) commit_date:(UIButton *)sender {
    
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_dateField.text = self->_dateChooseDay;
        
        // yyyy-mm-dd 格式
        self->_delegateDict[@"date"] = self->_dateChooseDay;
        
        // 修改后 发送代理
        [self delegateClick];
        
        [self endEditing:YES];
    });
    
}


- (void) cancel_date:(UIButton *)sender {
    
    
    [self endEditing:YES];
}




- (UITextField *)dateField {
    
    if (!_dateField) {
        
        _dateField = [UIView textFieldFrame:CGRectNull];
        _dateField.layer.cornerRadius = 10;
        _dateField.layer.masksToBounds = YES;
        _dateField.layer.borderWidth = 1;
        _dateField.layer.borderColor = [ColorValue_RGB(0xdddddd) CGColor];
        
        _dateField.text = [Yuan_Foundation currentDate];
        
        
        CGRect pickerFrame = CGRectMake(0, 0, ScreenWidth, Vertical(250));
        
        Yuan_PickerView *picker =
        [[Yuan_PickerView alloc] initWithFrame:pickerFrame
                                   PickerBlock:^(NSString * _Nonnull year,
                                                 NSString * _Nonnull month,
                                                 NSString * _Nonnull day,
                                                 NSString * _Nonnull hour,
                                                 NSString * _Nonnull minute) {
            
            self->_dateChooseDay = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
            
        } section:3];
        
        
        
        _dateField.inputView = picker;
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, IphoneSize_Height(44))];
        toolBar.barStyle = UIBarStyleDefault;
        toolBar.clipsToBounds = YES;
        toolBar.backgroundColor = [UIColor whiteColor];
        UIBarButtonItem *doneButton =  [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain  target:self action:@selector(commit_date:)];
        doneButton.tintColor = Color_V2Red;
                
        doneButton.mainView = _dateField;
                
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain  target:self action:@selector(cancel_date:)];
        cancelButton.mainView = _dateField;
        cancelButton.tintColor = Color_V2Red;
                    
        [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
        _dateField.inputAccessoryView = toolBar;
        
        
        UIImageView * right_paddingView =
        [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"icon_riqi"]
                           frame:CGRectNull];

        _dateField.rightView = right_paddingView;

        _dateField.rightViewMode = UITextFieldViewModeAlways;
        
        
        
    }
    return _dateField;
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    [_dateField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
    [_dateField autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(10)];
    [_dateField autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(10)];
    [_dateField autoSetDimension:ALDimensionHeight toSize:Vertical(45)];
    
}

@end
