//
//  Inc_TransverseMergeTipView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/16.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TransverseMergeTipView.h"
#import "Inc_KP_Config.h"


@interface Inc_TransverseMergeTipView ()<UITextFieldDelegate>

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
    //关联设备
    UILabel *_cableName;

    
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

    //光缆段1 + 长度
    UILabel *_cable1;
    //光缆段2 + 长度
    UILabel *_cable2;
    //箭头
    UIImageView *_arrowImage;
    
    //新光缆段view
    UIView *_newCableView;
    
    //新光缆段
    UILabel *_newCable;
    //合并长度
    UITextField *_newLengthTF;
    
    //提示
    UILabel *_tipLabel;
    
    //确定
    UIButton *_sureBtn;
    //取消
    UIButton *_cancelBtn;
    
    //合并需要参数字典
    NSMutableDictionary *_postDic;
}


@end

@implementation Inc_TransverseMergeTipView


-(instancetype)initWithFrame:(CGRect)frame {
    
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:0.4];
        
        _postDic = NSMutableDictionary.dictionary;
        
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
    
    
    _tip1 = [UIView labelWithTitle:@"1.横向合并后会去掉与下列设备共同的关联关系。" isZheH:YES];
    _tip1.backgroundColor = UIColor.clearColor;
    _tip1.font = Font(15);
    
    _cableName = [UIView labelWithTitle:@"" isZheH:YES];
    _cableName.textColor = HexColor(@"#FF8080");
    _cableName.font = Font(13);
    [_cableName setCornerRadius:1 borderColor:HexColor(@"#DCDCDC") borderWidth:1];

    
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
    
    _tip3 = [UIView labelWithTitle:@"3.请确认光缆段合并后的长度。" isZheH:YES];
    _tip3.backgroundColor = UIColor.clearColor;
    _tip3.font = Font(15);
    
    _cable1 = [UIView labelWithTitle:@"光缆段一"  isZheH:YES];
    _cable1.backgroundColor = UIColor.clearColor;
    [_cable1 setCornerRadius:1 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    _cable1.font = Font(13);
    _cable1.textAlignment = NSTextAlignmentCenter;
    _cable1.textColor = HexColor(@"#FF8080");
    
    _cable2 = [UIView labelWithTitle:@"光缆段二"  isZheH:YES];
    [_cable2 setCornerRadius:1 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    _cable2.backgroundColor = UIColor.clearColor;
    _cable2.font = Font(13);
    _cable2.textAlignment = NSTextAlignmentCenter;
    _cable2.textColor = HexColor(@"#FF8080");

    
    _arrowImage = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"zzc_cable_arrow"] frame:CGRectNull];
    _arrowImage.contentMode = UIViewContentModeScaleToFill;
    
    
    _newCableView = [UIView viewWithColor:UIColor.clearColor];
    _newCableView.frame = CGRectMake(0, 0, Vertical(100), Horizontal(60));
    [[Inc_KP_Config sharedInstanced] addDottedBorderWithView:_newCableView color:HexColor(@"#10A12B")];
    
    _newCable = [UIView labelWithTitle:@"新光缆段"  isZheH:YES];
    _newCable.font = Font(13);
    _newCable.textAlignment = NSTextAlignmentCenter;
    _newCable.backgroundColor = UIColor.clearColor;

    _newLengthTF = [UIView textFieldFrame:CGRectNull];
    [_newLengthTF setCornerRadius:1 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    _newLengthTF.font = Font(13);
    _newLengthTF.delegate = self;
    _newLengthTF.textAlignment = NSTextAlignmentCenter;
    _newLengthTF.backgroundColor = UIColor.whiteColor;
    _newLengthTF.textColor = HexColor(@"#10A12B");
    _newLengthTF.keyboardType = UIKeyboardTypeDecimalPad;

    _tipLabel = [UIView labelWithTitle:@"如果长度不准确请点击进行修改" isZheH:YES];
    _tipLabel.font = Font(11);
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.backgroundColor = UIColor.clearColor;
    _tipLabel.textColor = HexColor(@"#B2B1B1");
    
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
                                _cableName]];
    
    [_secendBgView addSubviews:@[_tip2,
                                 _textView]];
    
    [_thirdBgView addSubviews:@[_tip3,
                                _cable1,
                                _cable2,
                                _newCableView,
                                _arrowImage,
                                _tipLabel
    
    ]];
    
    
    [_newCableView addSubviews:@[_newCable,_newLengthTF]];
    
    
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
    
    CGFloat cableHeight = [_cableName.text boundingRectWithSize:CGSizeMake(ScreenWidth - 4*limit, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_cableName.font} context:nil].size.height +5;

    [_cableName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tip1 withOffset:limit];
    [_cableName YuanToSuper_Left:limit];
    [_cableName YuanToSuper_Right:limit];
    [_cableName YuanToSuper_Bottom:limit];
    [_cableName autoSetDimension:ALDimensionHeight toSize:MAX(cableHeight, 30)];
    
    
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
    
    [_cable1 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tip3 withOffset:limit];
    [_cable1 YuanToSuper_Left:limit * 3];
    [_cable1 autoSetDimensionsToSize:CGSizeMake(Vertical(90), Horizontal(50))];
   
    
    [_cable2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tip3 withOffset:limit];
    [_cable2 YuanToSuper_Right:limit * 3];
    [_cable2 autoSetDimensionsToSize:CGSizeMake(Vertical(90), Horizontal(50))];
    
    
    [_arrowImage autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_cable1 withOffset:-2];
    [_arrowImage YuanToSuper_Left:limit * 3 + Vertical(90)/2];
    [_arrowImage YuanToSuper_Right:limit * 3 + Vertical(90)/2];

    [_newCableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_arrowImage withOffset:-2];
    [_newCableView autoSetDimensionsToSize:CGSizeMake(Vertical(100), Horizontal(60))];
    [_newCableView YuanAttributeVerticalToView:_thirdBgView];

    [_newCable YuanToSuper_Top:0];
    [_newCable YuanToSuper_Left:0];
    [_newCable YuanToSuper_Right:0];
    [_newCable autoSetDimension:ALDimensionHeight toSize:Horizontal(30)];
    
    
    [_newLengthTF autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_newCable withOffset:0];
    [_newLengthTF YuanToSuper_Bottom:limit];
    [_newLengthTF YuanToSuper_Left:limit * 2];
    [_newLengthTF YuanToSuper_Right:limit * 2];
    
    [_tipLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_newCableView withOffset:limit];
    [_tipLabel YuanAttributeVerticalToView:_thirdBgView];
    [_tipLabel YuanToSuper_Bottom:limit];

    
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

    _textView.text = firstDic[@"cableName"];
    _cable1.text = [NSString stringWithFormat:@"光缆段一\n%@",firstDic[@"cableSectionLength"]?:@"0"];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:_cable1.text];
    [text addAttribute:NSForegroundColorAttributeName value:ColorValue_RGB(0x333333) range:[_cable1.text rangeOfString:@"光缆段一"]];
    _cable1.attributedText = text;
    
    
}

-(void)setSecendDic:(NSDictionary *)secendDic {
    _secendDic = secendDic;
    
    _cableName.text = secendDic[@"resName"];
    _cable2.text = [NSString stringWithFormat:@"光缆段二\n%@",secendDic[@"cableSectionLength"]?:@"0"];
    
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:_cable2.text];
    [text addAttribute:NSForegroundColorAttributeName value:ColorValue_RGB(0x333333) range:[_cable2.text rangeOfString:@"光缆段二"]];
    _cable2.attributedText = text;
    
    
    CGFloat lenth = [_firstDic[@"cableSectionLength"] floatValue] + [secendDic[@"cableSectionLength"] floatValue];
    
    _newLengthTF.text = [NSString stringWithFormat:@"%.0f",lenth];
    
    
    [self autoLayout];
}


- (void)btnClick:(UIButton *)btn {
    
    if ([_textView.text isEmpty] && [btn.titleLabel.text isEqualToString:@"确定"]) {
        [YuanHUD HUDFullText:@"光缆段名称不能为空"];
        return;
    }
    
    [_postDic addEntriesFromDictionary:@{
        @"optSectIdA":_firstDic[@"GID"]?:@"",
        @"beginIdA":_firstDic[@"cableStart_Id"]?:@"",
        @"endIdA":_firstDic[@"cableEnd_Id"]?:@"",
        @"optSectIdB":_secendDic[@"resId"]?:@"",
        @"beginIdB":_secendDic[@"beginId"]?:@"",
        @"endIdB":_secendDic[@"endId"]?:@"",
        @"newSectName":_textView.text?:@"",
        @"length":_newLengthTF.text
        
    }];
    

    
    if (self.btnClick) {
        self.btnClick(btn,_postDic);
    }
}



-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([textField.text isEmptyString] || [textField.text isEqualToString:@"0"]) {

        [YuanHUD HUDFullText:@"合并长度不可为空"];
        return;
    }
    
}

@end
