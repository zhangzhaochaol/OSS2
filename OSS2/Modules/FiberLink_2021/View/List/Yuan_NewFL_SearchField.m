//
//  Yuan_NewFL_SearchField.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_SearchField.h"


@interface Yuan_NewFL_SearchField () <UITextFieldDelegate>

@end

@implementation Yuan_NewFL_SearchField

{
    
    UIButton * _showBtn;
    
    UITextField * _textField;
    
    UIButton * _searchBtn;
    
}



#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        [self UI_Init];
    }
    return self;
}


- (void) UI_Init {
    
    _showBtn = [UIView buttonWithImage:@"XJ_icon_xiala_new"
                             responder:self
                             SEL_Click:@selector(showClick)
                                 frame:CGRectNull];
    
    _textField = [UIView textFieldFrame:CGRectNull];
    _textField.placeholder = @"请输入名称";
    _textField.delegate = self;
    
    _searchBtn = [UIView buttonWithImage:@"icon_search"
                               responder:self
                               SEL_Click:@selector(searchClick)
                                   frame:CGRectNull];
    
    [self addSubviews:@[_showBtn,_textField,_searchBtn]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    
    [_showBtn YuanToSuper_Left:limit];
    [_showBtn YuanAttributeHorizontalToView:self];
    
    [_textField YuanAttributeHorizontalToView:self];
    [_textField autoSetDimension:ALDimensionWidth toSize:Horizontal(200)];
    [_textField YuanMyEdge:Left ToViewEdge:Right ToView:_showBtn inset:limit];
    
    [_searchBtn YuanAttributeHorizontalToView:self];
    [_searchBtn YuanToSuper_Right:limit];
    
}


#pragma mark - btnClick ---

- (void) searchClick {
    
    if (_NewFL_ClickBlock) {
        _NewFL_ClickBlock(NewFL_Click_Search);
    }
}


- (void) showClick {
    
    if (_NewFL_ClickBlock) {
        _NewFL_ClickBlock(NewFL_Click_Show);
    }
}


#pragma mark - method --- 

- (void)clear {
    _textField.text = @"";
}

- (NSString *)searchName {
    
    return _textField.text;
}


// 执行搜索
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endEditing:YES];
    
    if (_NewFL_ClickBlock) {
        _NewFL_ClickBlock(NewFL_Click_Search);
    }
    
    return YES;
}


@end
