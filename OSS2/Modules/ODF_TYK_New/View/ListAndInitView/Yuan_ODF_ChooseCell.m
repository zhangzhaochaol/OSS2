//
//  Yuan_ODF_ChooseCell.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/28.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_ODF_ChooseCell.h"
#import "Yuan_SinglePicker.h"   //单行picker
#import "INCBarButtonItem.h"

const float _limit = 10;


@interface Yuan_ODF_ChooseCell ()

/** 标题 */
@property (nonatomic,strong) UILabel *txt;



/** 下拉箭头 */
@property (nonatomic,strong) UIImageView *img;

@end

@implementation Yuan_ODF_ChooseCell

{
    
    Yuan_SinglePicker * _picker;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.txt];
        [self.contentView addSubview:self.printView];
        [self.contentView addSubview:self.img];
        
        [self layoutAllSubViews];
        
    }
    return self;
}

- (void) setTxt_Title:(NSString *)txt  {
    
    _txt.text = txt;
}


- (NSString *) getTextFieldTxt {
    
    return _printView.text;
}



- (void)setDataSource:(NSArray *)dataSource {
    
    
    _printView.text = [dataSource firstObject];
    
        CGRect pickerFrame = CGRectMake(0, 0, ScreenWidth, Vertical(250));
      
      
    _picker =
        [[Yuan_SinglePicker alloc] initWithFrame:pickerFrame
                                  dataSource:dataSource
                                 PickerBlock:^(NSString * _Nonnull select) {}];
      
      
    _picker.backgroundColor = [UIColor whiteColor];
    _printView.inputView = _picker;


    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, ScreenW, IphoneSize_Height(44))];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.clipsToBounds = YES;
    toolBar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *doneButton =  [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain  target:self action:@selector(commit)];
    doneButton.tintColor = [UIColor blueColor];

    doneButton.mainView = _printView;

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain  target:self action:@selector(cancel)];
    cancelButton.mainView = _printView;
    cancelButton.tintColor = [UIColor blueColor];


    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];

    _printView.inputAccessoryView = toolBar;

    _printView.backgroundColor = ColorValue_RGB(0xf2f2f2);

}


#pragma mark - Lazy Load

- (UILabel *)txt {
    
    if (!_txt) {
        _txt = [UIView labelWithTitle:@"标题" frame:CGRectNull];
        _txt.font = [UIFont systemFontOfSize:14];
        _txt.textColor = ColorValue_RGB(0x606060);
    }
    return _txt;
}

- (UIImageView *)img {
    
    if (!_img) {
        _img = [[UIImageView alloc] init];
        _img.image = [UIImage Inc_imageNamed:@"icon_xiala"];
    }
    return _img;
}


- (UITextField *)printView{
    
    if (!_printView) {
        
        _printView = [[UITextField alloc] initWithFrame:CGRectNull];
        
        _printView.layer.cornerRadius = 5;
        _printView.layer.masksToBounds = YES;
        
        _printView.layer.borderWidth = 1;
        _printView.layer.borderColor = [ColorValue_RGB(0xeeeeee) CGColor];
        
        _printView.placeholder = @"请选择";
        
        _printView.font = [UIFont systemFontOfSize:13];
        
        UILabel *paddingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 25)];

        paddingView.text = @"  ";

        paddingView.textColor = [UIColor darkGrayColor];

        paddingView.backgroundColor = [UIColor clearColor];

        _printView.leftView = paddingView;

        _printView.leftViewMode = UITextFieldViewModeAlways;
        
    }
    return _printView;
}



/// 提交
- (void) commit {
    

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _printView.text = _picker.selectRowTxt;
        [self endEditing:YES];
            
        NSNotification * noti = [[NSNotification alloc] initWithName:Noti_DataPickerCommit
                                                              object:nil
                                                            userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] postNotification:noti];
        
    });
    
    
    
}


- (void) cancel {
    
    // 取消
    [self endEditing:YES];
    
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    float left = 15;
    
    // 标题
    [_txt autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:Vertical(_limit / 2)];
    [_txt autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(left)];
    
    
    // 输入框
    [_printView autoPinEdge:ALEdgeTop
                     toEdge:ALEdgeBottom
                     ofView:_txt
                 withOffset:Vertical(_limit / 2)];
    
    [_printView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(left)];
    [_printView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(_limit)];
    [_printView autoSetDimension:ALDimensionHeight toSize:Vertical(36)];
    
    
    [_img autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:_printView withMultiplier:1.0];
    [_img autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(_limit * 2)];
    
}

@end
