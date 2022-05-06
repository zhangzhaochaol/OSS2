//
//  Yuan_TerminalSelectCableView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/9.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_TerminalSelectCableView.h"

@implementation Yuan_TerminalSelectCableView
{
    
    UILabel * _cable;
    
    UILabel * _cableName;
    
    UIButton * _selectBtn;
    
    void(^_myBlock)(void);
    
    
    // zzc 2021-07-12 承载业务
    UIView *_line;
    UILabel *_carryBusiness;
    UILabel *_carryName;

    UIActivityIndicatorView * _activityIndicator;

}


#pragma mark - 初始化构造方法

- (instancetype)initWithCableName:(NSString *)cableName
                            block:(void(^)(void))selectBlock{
    
    if (self = [super init]) {
        
        
        self.backgroundColor = ColorValue_RGB(0xe2e2e2);
        
        _myBlock = selectBlock;
        
        _cable = [UIView labelWithTitle:@"光缆段" frame:CGRectNull];
        _cable.backgroundColor = ColorValue_RGB(0xffeed6);
        _cable.textColor = UIColor.orangeColor;
        _cable.font = Font_Yuan(13);
        
        
        _cableName = [UIView labelWithTitle:cableName frame:CGRectNull];
        _cableName.numberOfLines = 0;//根据最大行数需求来设置
        _cableName.lineBreakMode = NSLineBreakByTruncatingTail;
        _carryName.backgroundColor = UIColor.greenColor;
        
        _selectBtn = [UIView buttonWithTitle:@"查看"
                                   responder:self
                                         SEL:@selector(selectClick)
                                       frame:CGRectNull];
        
        [_selectBtn cornerRadius:3 borderWidth:0 borderColor:nil];
        [_selectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _selectBtn.backgroundColor = UIColor.mainColor;
        
        [self addSubviews:@[_cable,_cableName , _selectBtn]];
        
        
        _line = [UIView viewWithColor:UIColor.lightGrayColor];
        
        
        _carryBusiness = [UIView labelWithTitle:@"承载业务" frame:CGRectNull];
        _carryBusiness.backgroundColor = ColorR_G_B(146, 181, 219);
        _carryBusiness.textColor = ColorR_G_B(200, 235, 255);
        _carryBusiness.font = Font_Yuan(13);
        [_carryBusiness setCornerRadius:3 borderColor:UIColor.clearColor borderWidth:1];
        
        _carryName = [UIView labelWithTitle:@"       加载中" frame:CGRectNull];
        _carryName.numberOfLines = 0;//根据最大行数需求来设置
        _carryName.lineBreakMode = NSLineBreakByTruncatingTail;
        
        
        [self addSubviews:@[_line,_carryBusiness,_carryName]];

        
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        [self addSubview:_activityIndicator];
        //设置小菊花的frame
        _activityIndicator.frame= CGRectMake(Horizontal(80), Vertical(65), Vertical(20), Vertical(20));
        //设置小菊花颜色
        _activityIndicator.color = [UIColor grayColor];
        //设置背景颜色
        _activityIndicator.backgroundColor = [UIColor clearColor];
        //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
        _activityIndicator.hidesWhenStopped = NO;
        [_activityIndicator startAnimating];

        
        [self yuan_LayoutSubViews];
        
    }
    return self;
}



- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_cable YuanToSuper_Left:limit];
    [_cable YuanToSuper_Top:limit];
    [_cable autoSetDimension:ALDimensionHeight toSize:Vertical(20)];
    
    [_cableName YuanMyEdge:Left ToViewEdge:Right ToView:_cable inset:limit];
    [_cableName YuanToSuper_Top:0];
    [_cableName autoSetDimension:ALDimensionWidth toSize:Horizontal(220)];
    [_cableName autoSetDimension:ALDimensionHeight toSize:Vertical(50)];

    
    [_selectBtn YuanToSuper_Top:Vertical(10)];
    [_selectBtn YuanToSuper_Right:limit];
    [_selectBtn autoSetDimensionsToSize:CGSizeMake(Horizontal(60), Vertical(30))];
    
    [_line YuanToSuper_Left:0];
    [_line YuanToSuper_Right:0];
    [_line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_selectBtn withOffset:Vertical(10)];
    [_line autoSetDimension:ALDimensionHeight toSize:1];
    
    [_carryBusiness YuanToSuper_Left:limit];
    [_carryBusiness autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_line withOffset:Vertical(15)];
    [_carryBusiness autoSetDimension:ALDimensionHeight toSize:Vertical(20)];

    [_activityIndicator autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_carryBusiness withOffset:Horizontal(10)];
    [_activityIndicator autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_line withOffset:Vertical(15)];

    
    [_carryName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_line withOffset:Vertical(0)];
    [_carryName YuanMyEdge:Left ToViewEdge:Right ToView:_carryBusiness inset:limit];
    [_carryName YuanToSuper_Right:limit];
    [_carryName autoSetDimension:ALDimensionHeight toSize:Vertical(49)];
    
    
}

//更新carryName值
- (void)updateCarryName:(NSString *)carryName {
    
    //停止
    [_activityIndicator stopAnimating];
    [_activityIndicator setHidden:YES];
    
    _carryName.text = carryName;

}

- (void) selectClick {
    
    if (_myBlock) {
        _myBlock();
    }
    
}


@end
