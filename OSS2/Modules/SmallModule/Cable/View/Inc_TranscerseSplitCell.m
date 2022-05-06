//
//  Inc_TranscerseSplitCell.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/16.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TranscerseSplitCell.h"

@interface Inc_TranscerseSplitCell ()<UITextViewDelegate>
{
    //灰色背景
    UIView *_bgView;

    
    //名称
    UITextView *_textView;
    
    //长度背景
    UIView *_lenthView;
    
    //长度提示
    UILabel *_lenthLabel;
    //长度
    UITextField *_lenthTF;
    
    //起
    UILabel *_sLable;
    //起始设施名称
    UILabel *_startFName;
    //终
    UILabel *_eLabel;
    //终止设施名称
    UILabel *_endFName;

    //第二cell 横线
    UIView *_lineView;
}

@end





@implementation Inc_TranscerseSplitCell


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
    [_bgView setCornerRadius:1 borderColor:UIColor.clearColor borderWidth:1];

    _textView = [[UITextView alloc]initWithFrame:CGRectNull];
    _textView.delegate = self;
    [_textView setCornerRadius:1 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    _textView.backgroundColor = UIColor.whiteColor;
    _textView.font = Font(13);
    
    _lenthView = [UIView viewWithColor:UIColor.whiteColor];
    [_lenthView setCornerRadius:1 borderColor:HexColor(@"#DCDCDC") borderWidth:1];

    _lenthLabel = [UIView labelWithTitle:@"长度(km)" frame:CGRectNull];
    _lenthLabel.textAlignment  = NSTextAlignmentCenter;
    _lenthLabel.font = Font(13);

    _lenthTF = [UIView textFieldFrame:CGRectNull];
    _lenthTF.font = Font_Yuan(18);
    _lenthTF.textColor = HexColor(@"#FF8080");
    _lenthTF.textAlignment  = NSTextAlignmentCenter;
    _lenthTF.enabled = NO;

    _sLable = [UILabel labelWithTitle:@"起" frame:CGRectNull];
    _sLable.textColor = UIColor.whiteColor;
    _sLable.font = Font(12);
    _sLable.backgroundColor = HexColor(@"#AFAFAF");
    _sLable.textAlignment  = NSTextAlignmentCenter;
    [_sLable setCornerRadius:3 borderColor:UIColor.clearColor borderWidth:1];

    _eLabel = [UILabel labelWithTitle:@"终" frame:CGRectNull];
    _eLabel.textColor = UIColor.whiteColor;
    _eLabel.font = Font(12);
    _eLabel.backgroundColor = HexColor(@"#FF8080");
    _eLabel.textAlignment  = NSTextAlignmentCenter;
    [_eLabel setCornerRadius:3 borderColor:UIColor.clearColor borderWidth:1];

    _startFName = [UILabel labelWithTitle:@"" isZheH:YES];
    _startFName.textColor = HexColor(@"#939393");
    _startFName.font = Font(13);
    _startFName.backgroundColor = UIColor.clearColor;

    _endFName = [UILabel labelWithTitle:@"" isZheH:YES];
    _endFName.textColor = HexColor(@"#FF8080");
    _endFName.font = Font(13);
    _endFName.backgroundColor = UIColor.clearColor;

    _lineView = [UIView viewWithColor:HexColor(@"#E5E5E5")];
    
    [self.contentView addSubview:_bgView];

    [_bgView addSubviews:@[_textView,
                           _lenthView,
                           _startFName,
                           _endFName,
                           _sLable,
                           _eLabel,
                           _lineView]];
    
    [_lenthView addSubviews:@[_lenthLabel,
                              _lenthTF]];

}



-(void)setDataSource:(NSDictionary *)dic indexPath:(NSInteger)indexPath
{

    if (indexPath == 0) {
        _sLable.backgroundColor = HexColor(@"#AFAFAF");
        _startFName.textColor = HexColor(@"#939393");
        _eLabel.backgroundColor = HexColor(@"#FF8080");
        _endFName.textColor = HexColor(@"#FF8080");
    }else{
        _sLable.backgroundColor = HexColor(@"#FF8080");
        _startFName.textColor = HexColor(@"#FF8080");
        _eLabel.backgroundColor = HexColor(@"#AFAFAF");
        _endFName.textColor = HexColor(@"#939393");
        
    }
    _textView.text = dic[@"cableName"];
    _lenthTF.text = dic[@"cableSectionLength"];
    _startFName.text = dic[@"cableStart"];
    _endFName.text = dic[@"cableEnd"];


    [self autolayout:indexPath];
}




-(void)autolayout:(NSInteger)indexPath {
    
    _lineView.hidden = YES;

    CGRect frame = [self frame];

    
    CGFloat limit = Horizontal(10);
    CGFloat top = limit;

    if (indexPath == 1) {
        top = 0;
        _lineView.hidden = NO;
    }
    
    _bgView.frame = CGRectMake(limit, top, ScreenWidth - 2*limit, Vertical(60) + limit*4 + 20*2);

    _lineView.frame = CGRectMake(0, 0, _bgView.width, 1);
    
    
    _textView.frame = CGRectMake(limit, limit, ScreenWidth - 5*limit - Horizontal(90), Vertical(60));
    
    _lenthView.frame = CGRectMake(ScreenWidth - 3 *limit - Horizontal(90), _textView.y, Horizontal(90), _textView.height);
    
    _lenthLabel.frame = CGRectMake(0, 10, _lenthView.width, Vertical(20));
    
    _lenthTF.frame = CGRectMake(0, _lenthLabel.height+ _lenthLabel.y, _lenthView.width, _lenthView.height - limit - 10 -_lenthLabel.height);
    
    
    CGFloat sHeight = [_startFName.text boundingRectWithSize:CGSizeMake(ScreenWidth - 5*limit - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_startFName.font} context:nil].size.height +5;
    CGFloat eHeight = [_endFName.text boundingRectWithSize:CGSizeMake(ScreenWidth - 5*limit - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_endFName.font} context:nil].size.height +5;


    _startFName.frame = CGRectMake(limit * 2 + 20, _textView.y+_textView.height +limit, ScreenWidth - 5*limit - 20, MAX(20, sHeight));
    _sLable.frame = CGRectMake(limit, 0, 20, 20);
    _sLable.centerY = _startFName.centerY;
    
    _endFName.frame = CGRectMake(_startFName.x, _startFName.y+_startFName.height +limit, _startFName.width, MAX(20, eHeight));
    _eLabel.frame = _sLable.frame;
    _eLabel.centerY = _endFName.centerY;
    
    
 
    _bgView.frame = CGRectMake(limit, top, ScreenWidth - 2*limit, _endFName.y + _endFName.height + limit);
    
    frame.size.height = _bgView.height + _bgView.y;
    
    self.frame = frame;
    
    
//    [_bgView YuanToSuper_Top:limit];
//    [_bgView YuanToSuper_Left:limit];
//    [_bgView YuanToSuper_Right:limit];
//    [_bgView YuanToSuper_Bottom:0];
//
//    [_textView YuanToSuper_Top:limit];
//    [_textView YuanToSuper_Left:limit];
//    [_textView autoSetDimension:ALDimensionHeight toSize:Vertical(60)];
//
//    [_lenthView YuanToSuper_Top:limit];
//    [_lenthView autoSetDimensionsToSize:CGSizeMake(Horizontal(90), Vertical(60))];
//    [_lenthView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_textView withOffset:limit];
//    [_lenthView YuanToSuper_Right:limit];
//
//
//    [_lenthLabel YuanToSuper_Top:10];
//    [_lenthLabel YuanToSuper_Left:0];
//    [_lenthLabel YuanToSuper_Right:0];
//    [_lenthLabel autoSetDimension:ALDimensionHeight toSize:Vertical(20)];
//
//    [_lenthTF autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_lenthLabel];
//    [_lenthTF YuanToSuper_Left:0];
//    [_lenthTF YuanToSuper_Right:0];
//    [_lenthTF YuanToSuper_Bottom:limit];
    
//    [_startFName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_textView withOffset:limit];
//    [_startFName YuanToSuper_Right:limit];
//    [_startFName YuanToSuper_Left:limit * 2 + 20];
//    [_startFName autoSetDimension:ALDimensionHeight toSize:MAX(20, sHeight)];
//
//    [_sLable YuanToSuper_Left:limit];
//    [_sLable autoSetDimensionsToSize:CGSizeMake(20, 20)];
//    [_sLable YuanAttributeHorizontalToView:_startFName];
//
//    [_endFName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_startFName withOffset:limit];
//    [_endFName YuanToSuper_Right:limit];
//    [_endFName YuanToSuper_Left:limit * 2 + 20];
//    [_endFName YuanToSuper_Bottom:limit];
//    [_endFName autoSetDimension:ALDimensionHeight toSize:MAX(20, eHeight)];
//
//
//    [_eLabel YuanToSuper_Left:limit];
//    [_eLabel autoSetDimensionsToSize:CGSizeMake(20, 20)];
//    [_eLabel YuanAttributeHorizontalToView:_endFName];
    
    
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
