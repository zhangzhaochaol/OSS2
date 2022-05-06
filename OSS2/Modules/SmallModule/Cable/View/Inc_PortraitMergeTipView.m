//
//  Inc_PortraitMergeTipView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_PortraitMergeTipView.h"
//http
#import "Inc_Cable_HttpModel.h"


#import "Inc_KP_Config.h"

@interface Inc_PortraitMergeTipView ()

{
    //透明背景
    UIView *_bgView;
    
    
    //标题
    UILabel *_titleL;
    //横线
    UIView *_lineView;
    
    //第1个背景view
    UIView *_firstBgView;
    //提示
    UILabel *_tip1;
    //光缆段1
    UIButton *_cableBtn1;
    //光缆段2
    UIButton *_cableBtn2;
    
    
    //第2个背景view
    UIView *_secendBgView;
    //提示
    UILabel *_tip2;
    //合并后名称
    UITextView *_textView;
    
    
    //第3个背景view
    UIView *_thirdBgView;
    //提示
    UILabel *_tip3;
    //左光缆段背景view
    UIView *_leftBgView;
    //线
    UIImageView *_leftImage;
    //左光缆段名称
    UILabel *_leftName;
    //左光缆段纤芯序号
    UIButton *_leftPair;
    
    //右光缆段
    UIView *_rightBgView;
    //线
    UIImageView *_rightImage;
    //左光缆段名称
    UILabel *_rightName;
    //左光缆段纤芯序号
    UIButton *_rightPair;
    
    
    //确定
    UIButton *_sureBtn;
    //取消
    UIButton *_cancelBtn;
    
    //合并需要参数字典
    NSMutableDictionary *_postDic;
    
    // 1 第一条光缆段   2 第二条光缆段
    NSString *_type1;
    // 1 第一条光缆段纤芯  2  1 第二条光缆段纤芯
    NSString *_type2;


}

@end

@implementation Inc_PortraitMergeTipView

-(instancetype)initWithFrame:(CGRect)frame {
    
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:0.4];
        
        _postDic = NSMutableDictionary.dictionary;
        
        _type1 = @"1";
        _type2 = @"1";
        _isLeftOrder = YES;
        _isRightOrder = YES;
        
        [self createUI];
    }
    
    return self;
}

-(void)createUI {
    
    _bgView =  [UIView viewWithColor:UIColor.whiteColor];
    
    
    _titleL = [UIView labelWithTitle:@"合并操作" frame:CGRectNull];
    _titleL.font = Font_Yuan(15);
    _titleL.textAlignment = NSTextAlignmentCenter;
    
    
    _lineView = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    
    
    _firstBgView = [UIView viewWithColor:HexColor(@"#F3F3F3")];
    [_firstBgView setCornerRadius:8 borderColor:UIColor.clearColor borderWidth:1];
    
    
    _tip1 = [UIView labelWithTitle:@"1.纵向合并后会保留一条光缆段信息，请选择要保留的光缆段。" isZheH:YES];
    _tip1.backgroundColor = UIColor.clearColor;
    _tip1.font = Font(15);
    
    
    _cableBtn1 = [UIView buttonWithTitle:@"" responder:self SEL:@selector(cableBtnClick:) frame:CGRectNull];
    _cableBtn1.backgroundColor = UIColor.clearColor;
    [_cableBtn1 setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_cableBtn_select"] forState:UIControlStateNormal];
    _cableBtn1.titleLabel.numberOfLines = 0;
    _cableBtn1.titleLabel.font = Font(13);
    _cableBtn1.adjustsImageWhenHighlighted = NO;
    
    _cableBtn2 = [UIView buttonWithTitle:@"" responder:self SEL:@selector(cableBtnClick:) frame:CGRectNull];
    [_cableBtn2 setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_cableBtn_select"] forState:UIControlStateNormal];
    _cableBtn2.backgroundColor = UIColor.clearColor;
    _cableBtn2.titleLabel.numberOfLines = 0;
    _cableBtn2.titleLabel.font = Font(13);
    _cableBtn2.adjustsImageWhenHighlighted = NO;
    
    
    
    _secendBgView = [UIView viewWithColor:HexColor(@"#F3F3F3")];
    [_secendBgView setCornerRadius:8 borderColor:UIColor.clearColor borderWidth:1];
    
    _tip2 = [UIView labelWithTitle:@"2.请输入并确认合并后的光缆段名称。" isZheH:YES];
    _tip2.backgroundColor = UIColor.clearColor;
    _tip2.font = Font(15);
    
    
    _textView = [[UITextView alloc]initWithFrame:CGRectNull];
    [_textView setCornerRadius:1 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    _textView.backgroundColor = UIColor.whiteColor;
    _textView.font = Font(13);
    
    _thirdBgView = [UIView viewWithColor:HexColor(@"#F3F3F3")];
    [_thirdBgView setCornerRadius:8 borderColor:UIColor.clearColor borderWidth:1];
    
    _tip3 = [UIView labelWithTitle:@"3.选择纤芯序号（默认为第一条光缆段为起始纤芯，点击进行更换。）" isZheH:YES];
    _tip3.backgroundColor = UIColor.clearColor;
    _tip3.font = Font(15);
    
    _leftBgView = [UIView viewWithColor:UIColor.clearColor];
    _leftBgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *leftTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [_leftBgView addGestureRecognizer:leftTap];
    
    _leftImage = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"zzc_cable_pairview_select"] frame:CGRectNull];
    _leftImage.contentMode = UIViewContentModeScaleToFill;
    
    
    _leftName = [UIView labelWithTitle:@"" isZheH:YES];
    _leftName.font = Font(13);
    
    _leftPair = [UIView buttonWithTitle:@"" responder:self SEL:@selector(pairBtnClick:) frame:CGRectNull];
    [_leftPair setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_PairBtn_select"] forState:UIControlStateNormal];
    _leftPair.adjustsImageWhenHighlighted = NO;
    
    _rightBgView = [UIView viewWithColor:UIColor.clearColor];
    _rightBgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *rightTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [_rightBgView addGestureRecognizer:rightTap];
    _rightBgView.backgroundColor = [UIColor colorwithImage:@"zzc_cable_pairview_norml"];

    _rightImage = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"zzc_cable_pairview_norml"] frame:CGRectNull];
    _rightImage.contentMode = UIViewContentModeScaleToFill;
    
    _rightName = [UIView labelWithTitle:@"" isZheH:YES];
    _rightName.font = Font(13);
    
    _rightPair = [UIView buttonWithTitle:@"" responder:self SEL:@selector(pairBtnClick:) frame:CGRectNull];
    [_rightPair setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_PairBtn_norml"] forState:UIControlStateNormal];
    _rightPair.adjustsImageWhenHighlighted = NO;
    
    _sureBtn = [UIView buttonWithTitle:@"确定" responder:self SEL:@selector(btnClick:) frame:CGRectNull];
    [_sureBtn setCornerRadius:4 borderColor:UIColor.clearColor borderWidth:1];
    [_sureBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_sureBtn setBackgroundColor:HexColor(@"#DD4B4A")];
    
    _cancelBtn = [UIView buttonWithTitle:@"取消" responder:self SEL:@selector(btnClick:) frame:CGRectNull];
    [_cancelBtn setCornerRadius:4 borderColor:UIColor.clearColor borderWidth:1];
    [_cancelBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_cancelBtn setBackgroundColor:HexColor(@"#C3C3C3")];
    
    
    [self addSubview:_bgView];
    
    [_bgView addSubviews:@[_titleL,
                           _lineView,
                           _firstBgView,
                           _secendBgView,
                           _thirdBgView,
                           _sureBtn,
                           _cancelBtn
    ]];
    
    [_firstBgView addSubviews:@[_tip1,
                                _cableBtn1,
                                _cableBtn2]];
    
    [_secendBgView addSubviews:@[_tip2,
                                 _textView]];
    
    [_thirdBgView addSubviews:@[_tip3,
                                _leftBgView,
                                _rightBgView]];
    
    
    [_leftBgView addSubviews:@[_leftImage,_leftName,_leftPair]];
    [_rightBgView addSubviews:@[_rightImage,_rightName,_rightPair]];
    
    
}


//适配
-(void)autoLayout {
    
    CGFloat limit = Horizontal(10);
    
    
    [_bgView YuanToSuper_Left:0];
    [_bgView YuanToSuper_Right:0];
    [_bgView YuanToSuper_Bottom:0];
    
    [_titleL YuanToSuper_Top:0];
    [_titleL YuanToSuper_Left:0];
    [_titleL YuanToSuper_Right:0];
    [_titleL autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
    
    
    [_lineView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleL withOffset:1];
    [_lineView YuanToSuper_Left:0];
    [_lineView YuanToSuper_Right:0];
    [_lineView autoSetDimension:ALDimensionHeight toSize:1];
    
    [_firstBgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_lineView withOffset:limit];
    [_firstBgView YuanToSuper_Left:limit];
    [_firstBgView YuanToSuper_Right:limit];
    
    
    [_tip1 YuanToSuper_Top:limit];
    [_tip1 YuanToSuper_Left:limit];
    [_tip1 YuanToSuper_Right:limit];
    
    [_cableBtn1 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tip1 withOffset:limit];
    [_cableBtn1 YuanToSuper_Left:limit];
    [_cableBtn1 YuanToSuper_Right:limit];
    
    [_cableBtn2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_cableBtn1];
    [_cableBtn2 YuanToSuper_Left:limit];
    [_cableBtn2 YuanToSuper_Right:limit];
    [_cableBtn2 YuanToSuper_Bottom:limit];
    
    [_secendBgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_firstBgView withOffset:limit];
    [_secendBgView YuanToSuper_Left:limit];
    [_secendBgView YuanToSuper_Right:limit];
    
    [_tip2 YuanToSuper_Top:limit];
    [_tip2 YuanToSuper_Left:limit];
    [_tip2 YuanToSuper_Right:limit];
    
    [_textView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tip2 withOffset:limit];
    [_textView YuanToSuper_Left:limit];
    [_textView YuanToSuper_Right:limit];
    [_textView autoSetDimension:ALDimensionHeight toSize:50];
    [_textView YuanToSuper_Bottom:limit];
    
    [_thirdBgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_secendBgView withOffset:limit];
    [_thirdBgView YuanToSuper_Left:limit];
    [_thirdBgView YuanToSuper_Right:limit];
    
    [_tip3 YuanToSuper_Top:limit];
    [_tip3 YuanToSuper_Left:limit];
    [_tip3 YuanToSuper_Right:limit];
    
    
    
    [_leftBgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tip3 withOffset:limit];
    [_leftBgView YuanToSuper_Left:limit];
    [_leftBgView YuanToSuper_Bottom:limit];
    
    [_leftImage YuanToSuper_Top:0];
    [_leftImage YuanToSuper_Left:0];
    [_leftImage YuanToSuper_Bottom:0];
    [_leftImage YuanToSuper_Right:0];

    [_rightBgView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_leftBgView withOffset:limit];
    [_rightBgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tip3 withOffset:limit];
    [_rightBgView YuanToSuper_Right:limit];
    [_rightBgView YuanToSuper_Bottom:limit];
    [@[_leftBgView,_rightBgView] autoMatchViewsDimension:ALDimensionWidth];
    
    [_rightImage YuanToSuper_Top:0];
    [_rightImage YuanToSuper_Left:0];
    [_rightImage YuanToSuper_Bottom:0];
    [_rightImage YuanToSuper_Right:0];
    
    
    [_leftName YuanToSuper_Top:limit];
    [_leftName YuanToSuper_Right:limit];
    [_leftName YuanToSuper_Left:limit];
    
    [_leftPair autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_leftName withOffset:limit];
    [_leftPair autoSetDimensionsToSize:CGSizeMake(90, 30)];
    [_leftPair YuanAttributeVerticalToView:_leftBgView];
    [_leftPair YuanToSuper_Bottom:limit];
    
    [_rightName YuanToSuper_Top:limit];
    [_rightName YuanToSuper_Right:limit];
    [_rightName YuanToSuper_Left:limit];
    
    [_rightPair autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_rightName withOffset:limit];
    [_rightPair autoSetDimensionsToSize:CGSizeMake(90, 30)];
    [_rightPair YuanAttributeVerticalToView:_rightBgView];
    [_rightPair YuanToSuper_Bottom:limit];
    
    [_sureBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_thirdBgView withOffset:limit];
    [_sureBtn YuanToSuper_Left:limit];
    [_sureBtn YuanToSuper_Bottom:limit];
    [_sureBtn autoSetDimension:ALDimensionHeight toSize:40];
    
    [@[_sureBtn,_cancelBtn] autoMatchViewsDimension:ALDimensionWidth];
    [@[_sureBtn,_cancelBtn] autoMatchViewsDimension:ALDimensionHeight];
    [_cancelBtn autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_sureBtn withOffset:limit];
    [_cancelBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_thirdBgView withOffset:limit];
    [_cancelBtn YuanToSuper_Right:limit];
    [_cancelBtn YuanToSuper_Bottom:limit];

    
}


//赋值
-(void)setFirstDic:(NSDictionary *)firstDic {
    _firstDic = firstDic;
    [_cableBtn1 setTitle:firstDic[@"cableName"] forState:UIControlStateNormal];
    
    _textView.text = firstDic[@"cableName"];
    _leftName.text = firstDic[@"cableName"];
    
        
    //第一条光缆段纤芯1-[firstDic[@"capacity"] intValue]
//    [_leftPair setTitle:[NSString stringWithFormat:@"1-%d",[firstDic[@"capacity"] intValue]] forState:UIControlStateNormal];

    
    if ([firstDic[@"capacity"] intValue] == 0) {
        
        [_leftPair setTitle:@"0-0" forState:UIControlStateNormal];

    }
    
    
    
}

-(void)setSecendDic:(NSDictionary *)secendDic {
    _secendDic = secendDic;
    [_cableBtn2 setTitle:secendDic[@"resName"] forState:UIControlStateNormal];
    
    _rightName.text = secendDic[@"resName"];

//    [_rightPair setTitle:[NSString stringWithFormat:@"%d-%d",[_firstDic[@"capacity"] intValue] + 1,[_firstDic[@"capacity"] intValue] + [secendDic[@"capacity"] intValue]] forState:UIControlStateNormal];
    
    //默认选择第一光缆段的起始纤芯
    [self leftPairViewTap];

    //设置默认选择第一个
    [_cableBtn1 setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_cableBtn_select"] forState:UIControlStateNormal];
    [_cableBtn2 setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_cableBtn_norml"] forState:UIControlStateNormal];
    
    [self autoLayout];
}


#pragma mark - btnClick

-(void)cableBtnClick:(UIButton *)btn {
    
    if (btn == _cableBtn1) {
        [_cableBtn1 setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_cableBtn_select"] forState:UIControlStateNormal];
        [_cableBtn2 setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_cableBtn_norml"] forState:UIControlStateNormal];

        _type1 = @"1";
        _textView.text = _firstDic[@"cableName"];

    }else{
        [_cableBtn2 setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_cableBtn_select"] forState:UIControlStateNormal];
        [_cableBtn1 setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_cableBtn_norml"] forState:UIControlStateNormal];
     
        _type1 = @"2";
        _textView.text = _secendDic[@"resName"];

    }
    
}

- (void)btnClick:(UIButton *)btn {
    
    if ([_textView.text isEmpty] && [btn.titleLabel.text isEqualToString:@"确定"]) {
        [YuanHUD HUDFullText:@"光缆段名称不能为空"];
        return;
    }
    
    
    
    [_postDic addEntriesFromDictionary:@{
        @"optSectIdA":_firstDic[@"GID"]?:@"",
        @"optSectIdB":_secendDic[@"resId"]?:@"",
            @"optSectName":_textView.text?:@"",
            @"type1":_type1,
            @"type2":_type2

        }];
    
    if ([btn.titleLabel.text isEqualToString:@"确定"]) {
        
        //选择光缆段的纤芯序号目前是否为乱序
        if ([_type2 isEqualToString:@"1"]) {
            if (!_isLeftOrder) {
                [YuanHUD HUDFullText:@"选择的纤芯序号不是从1开始的连续序号，合并后会改变纤芯序号"];
            }

        }else{

            if (!_isRightOrder) {
                [YuanHUD HUDFullText:@"选择的纤芯序号不是从1开始的连续序号，合并后会改变纤芯序号"];
            }
        }
        
    }
   
    
    if (self.btnClick) {
        self.btnClick(btn,_postDic);
    }
}

//view点击
- (void)tapClick:(UIGestureRecognizer *)tap {
    
    if (tap.view == _leftBgView) {
        [self leftPairViewTap];
    }else{
        [self rightPairViewTap];
    }
    
}
//btn自身点击
-(void)pairBtnClick:(UIButton *)pairBtn {
    if (pairBtn == _leftPair) {
        [self leftPairViewTap];
    }else{
        [self rightPairViewTap];
    }
}

-(void)leftPairViewTap{
    
    _leftImage.image = [UIImage Inc_imageNamed:@"zzc_cable_pairview_select"];
    _rightImage.image = [UIImage Inc_imageNamed:@"zzc_cable_pairview_norml"];

    [_leftPair setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_PairBtn_select"] forState:UIControlStateNormal];
    [_rightPair setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_PairBtn_norml"] forState:UIControlStateNormal];
    
    _type2 = @"1";
    
    
    //第一条光缆段纤芯1-[firstDic[@"capacity"] intValue]
    [_leftPair setTitle:[NSString stringWithFormat:@"1-%d",[_firstDic[@"capacity"] intValue]] forState:UIControlStateNormal];
    
    [_rightPair setTitle:[NSString stringWithFormat:@"%d-%d",[_firstDic[@"capacity"] intValue] + 1,[_firstDic[@"capacity"] intValue] + [_secendDic[@"capacity"] intValue]] forState:UIControlStateNormal];

    
    if ([_firstDic[@"capacity"] intValue] == 0) {
        
        [_leftPair setTitle:@"0-0" forState:UIControlStateNormal];

    }
    
    if ([_secendDic[@"capacity"] intValue] == 0) {
        
        [_rightPair setTitle:@"0-0" forState:UIControlStateNormal];

    }
}

-(void)rightPairViewTap {
    
    _leftImage.image = [UIImage Inc_imageNamed:@"zzc_cable_pairview_norml"];
    _rightImage.image = [UIImage Inc_imageNamed:@"zzc_cable_pairview_select"];
    
    [_leftPair setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_PairBtn_norml"] forState:UIControlStateNormal];
    [_rightPair setBackgroundImage:[UIImage Inc_imageNamed:@"zzc_cable_PairBtn_select"] forState:UIControlStateNormal];
    
    _type2 = @"2";
    
    
    //第一条光缆段纤芯1-[firstDic[@"capacity"] intValue]
    [_leftPair setTitle:[NSString stringWithFormat:@"%d-%d",[_secendDic[@"capacity"] intValue] + 1,[_secendDic[@"capacity"] intValue] + [_firstDic[@"capacity"] intValue]] forState:UIControlStateNormal];
    
    [_rightPair setTitle:[NSString stringWithFormat:@"1-%d",[_secendDic[@"capacity"] intValue]] forState:UIControlStateNormal];
    
    if ([_firstDic[@"capacity"] intValue] == 0) {
        
        [_leftPair setTitle:@"0-0" forState:UIControlStateNormal];

    }
    
    if ([_secendDic[@"capacity"] intValue] == 0) {
        
        [_rightPair setTitle:@"0-0" forState:UIControlStateNormal];

    }
}



@end
