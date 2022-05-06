//
//  Inc_PoryraitSplitCell.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/16.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_PoryraitSplitCell.h"


@interface Inc_PoryraitSplitCell ()<UITextFieldDelegate,UITextViewDelegate>

{
    //灰色背景
    UIView *_bgView;
    //提示
    UILabel *_tipLabel;
    //名称
    UITextView *_textView;
    
    //纤芯数背景
    UIView *_pairView;
    
    //纤芯数提示
    UILabel *_pairLabel;
    //纤芯数量
    UITextField *_pairNum;
    
}

@end


@implementation Inc_PoryraitSplitCell



-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.whiteColor;
    
        
        [self setupUI];
        
    }
    
    return self;
}


-(void)setupUI {
    
    _bgView = [UIView viewWithColor:HexColor(@"#F3F3F3")];
    
    _tipLabel = [UIView labelWithTitle:@"" isZheH:YES];
    _tipLabel.backgroundColor = UIColor.clearColor;
    _tipLabel.font = Font(15);
   
    _textView = [[UITextView alloc]initWithFrame:CGRectNull];
    _textView.delegate = self;
    [_textView setCornerRadius:1 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    _textView.backgroundColor = UIColor.whiteColor;
    _textView.font = Font(13);
    
    _pairView = [UIView viewWithColor:UIColor.whiteColor];
    [_pairView setCornerRadius:1 borderColor:HexColor(@"#DCDCDC") borderWidth:1];

    _pairLabel = [UIView labelWithTitle:@"纤芯数" frame:CGRectNull];
    _pairLabel.textAlignment  = NSTextAlignmentCenter;
    _pairLabel.font = Font(13);
    
    _pairNum = [UIView textFieldFrame:CGRectNull];
    _pairNum.delegate = self;
    _pairNum.font = Font_Yuan(18);
    _pairNum.textColor = HexColor(@"#FF8080");
    _pairNum.textAlignment  = NSTextAlignmentCenter;
    _pairNum.keyboardType = UIKeyboardTypeNumberPad;
    

    UILabel *leftView = [UIView labelWithTitle:@"-  " frame:CGRectMake(0, 0, 20, 20)];
    leftView.userInteractionEnabled = YES;
    leftView.backgroundColor = UIColor.whiteColor;
    leftView.tag = 1000;
    leftView.font = Font(18);
    leftView.textAlignment  = NSTextAlignmentCenter;
    UITapGestureRecognizer *tapLeft = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [leftView addGestureRecognizer:tapLeft];
    
    _pairNum.leftView = leftView;
    _pairNum.leftViewMode = UITextFieldViewModeAlways;

    UILabel *rightView = [UIView labelWithTitle:@" + " frame:CGRectMake(0, 0, 20, 20)];
    rightView.userInteractionEnabled = YES;
    rightView.backgroundColor = UIColor.whiteColor;
    rightView.tag = 1001;
    rightView.font = Font(18);
    rightView.textAlignment  = NSTextAlignmentCenter;
    UITapGestureRecognizer *tapRight = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    [rightView addGestureRecognizer:tapRight];
    
    _pairNum.rightView = rightView;
    _pairNum.rightViewMode = UITextFieldViewModeAlways;
    
    
    
    [self.contentView addSubview:_bgView];

    [_bgView addSubviews:@[_tipLabel,
                           _textView,
                           _pairView]];
    
    [_pairView addSubviews:@[_pairLabel,
                             _pairNum]];

}


-(void)setDataSource:(NSDictionary *)dic indexPath:(NSInteger)indexPath
{

    _tipLabel.text = [NSString stringWithFormat:@"%ld.请点击输入光缆段名称。",(long)indexPath + 1];
    _textView.text = dic[@"cableName"];
    _pairNum.text = dic[@"capacity"];


    [self autolayout];
}




-(void)autolayout {
    
    CGFloat limit = Horizontal(10);
    
    
    [_bgView YuanToSuper_Top:limit];
    [_bgView YuanToSuper_Left:limit];
    [_bgView YuanToSuper_Right:limit];
    [_bgView YuanToSuper_Bottom:0];

    
    
    [_tipLabel YuanToSuper_Top:limit];
    [_tipLabel YuanToSuper_Left:limit];
    [_tipLabel YuanToSuper_Right:limit];
    [_tipLabel autoSetDimension:ALDimensionHeight toSize:Vertical(35)];

    [_textView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tipLabel];
    [_textView YuanToSuper_Left:limit];
    [_textView YuanToSuper_Bottom:limit];

    [_pairView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tipLabel];
    [_pairView autoSetDimensionsToSize:CGSizeMake(Horizontal(90), Vertical(60))];
    [_pairView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_textView withOffset:limit];
    [_pairView YuanToSuper_Bottom:limit];
    [_pairView YuanToSuper_Right:limit];


    [_pairLabel YuanToSuper_Top:0];
    [_pairLabel YuanToSuper_Left:0];
    [_pairLabel YuanToSuper_Right:0];
    [_pairLabel autoSetDimension:ALDimensionHeight toSize:Vertical(20)];

    [_pairNum autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_pairLabel];
    [_pairNum YuanToSuper_Left:limit/2];
    [_pairNum YuanToSuper_Right:limit/2];
    [_pairNum YuanToSuper_Bottom:limit];
    
}




- (void)tapClick:(UITapGestureRecognizer *)tap {
    
    UILabel *label = (UILabel *)tap.view;
    
    int num = [_pairNum.text intValue];
    
    if (label.tag == 1000) {
        
        num --;
        
    }else{
        num ++;

    }
    
    if (num <1) {
        num = 1;
    }
    
    _pairNum.text = [NSString stringWithFormat:@"%d",num];
    
    if (self.textFeildBlock) {
        self.textFeildBlock(_pairNum.text);
    }
}



#pragma mark - UITextFeildDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([textField.text isEmpty] || [textField.text isEqualToString:@"0"]) {
        textField.text = @"1";
    }
    
    if (self.textFeildBlock) {
        self.textFeildBlock(textField.text);
    }
    
}

-(void)textViewDidEndEditing:(UITextView *)textView {
        
    if (self.textViewBlock) {
        self.textViewBlock(textView.text);
    }
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
