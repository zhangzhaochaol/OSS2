//
//  Inc_PairNoChangeTipView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/9.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_PairNoChangeTipView.h"


@interface Inc_PairNoChangeTipView ()<UITextFieldDelegate>{
    
    //提示 纤芯编号变更
    UILabel *_tipName;
    //纤芯编号变更下面横线
    UIView *_line1;
    //红色提示 *请在右侧框内输入变更后的纤芯编号
    UILabel *_remark;
    //需要变更的纤芯
    UILabel *_pairReplace;
    //需要变更的纤芯label右侧的  右向箭头
    UIImageView *_img1;
    //需要变更的纤芯label下方横线
    UIView *_line2;
    //是否进行批量变更
    UILabel *_btnLabel;

    //底部需要批量变更背景view
    UIView *_bottomBgView;
    UIImageView *_bgImage;
    
    //底部view 批量变更前第一个
    UILabel *_nextBeforPair;
    //批量变更前最后一个
    UILabel *_lastBeforPair;
    //批量变更后第一个
    UILabel *_nextReplacePair;
    //批量变更后最后一个
    UILabel *_lastReplacePair;

    //横向图片上
    UIImageView *_nextImageH;
    //竖向图片左
    UIImageView *_beImageV;
    //横向图片下
    UIImageView *_lastImageH;
    //竖向图片右
    UIImageView *_reImageV;

    //取消
    UIButton *_cancelBtn;
    //确定
    UIButton *_sureBtn;
    
    
    //数据
    NSArray *_dataArr;
    //下标
    int _index;
    
    //需要变更的数据数组
    NSMutableArray *_postArr;
}
@end


@implementation Inc_PairNoChangeTipView

-(instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        _postArr = NSMutableArray.array;
        [self createUI];

    }
    
    return self;
}


-(void)createUI {
    
    _tipName = [UIView labelWithTitle:@"纤芯编号变更" frame:CGRectNull];
    _tipName.font = Font_Yuan(15);
    _tipName.textColor = UIColor.blackColor;
    _tipName.textAlignment = NSTextAlignmentCenter;
    
    _line1 = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    
    _remark = [UIView labelWithTitle:@"*请在右侧框内输入变更后的纤芯编号" isZheH:YES];
    _remark.textColor = HexColor(@"#FF6161");
    _remark.font  =Font(11);
    
    _pairReplace = [UIView labelWithTitle:@"" frame:CGRectNull];
    _pairReplace.backgroundColor = HexColor(@"#F8F8F8");
    [_pairReplace setCornerRadius:2 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    _pairReplace.textAlignment = NSTextAlignmentCenter;

    _img1 = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"zzc_pari_green"] frame:CGRectNull];
    
    _pairNoTextField = [UIView textFieldFrame:CGRectNull];
    _pairNoTextField.backgroundColor = HexColor(@"#F8F8F8");
    [_pairNoTextField setCornerRadius:2 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    _pairNoTextField.textAlignment = NSTextAlignmentCenter;
    _pairNoTextField.delegate = self;
    _pairNoTextField.keyboardType =  UIKeyboardTypeNumberPad;

    _line2 = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];

    _checkBtn = [UIView buttonWithImage:@"zzc_pari_btnNomel" responder:self SEL_Click:@selector(checkClick:) frame:CGRectNull];
    [_checkBtn setImage:[UIImage Inc_imageNamed:@"zzc_pari_btnSelect"] forState:UIControlStateSelected];
    _checkBtn.adjustsImageWhenHighlighted = NO;
    
    _btnLabel = [UIView labelWithTitle:@"是否进行批量变更" isZheH:YES];
    _btnLabel.font = Font(12);
    
    
    _bottomBgView = [UIView viewWithColor:UIColor.whiteColor];
    
    _bgImage = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"zzc_pair_bg_gray"] frame:CGRectNull];
    _bgImage.contentMode  = UIViewContentModeScaleToFill;
    
    _nextBeforPair = [UIView labelWithTitle:@"" frame:CGRectNull];
    _nextBeforPair.backgroundColor = HexColor(@"#F8F8F8");
    [_nextBeforPair setCornerRadius:2 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    _nextBeforPair.textAlignment = NSTextAlignmentCenter;
    
    _nextReplacePair = [UIView labelWithTitle:@"" frame:CGRectNull];
    _nextReplacePair.backgroundColor = HexColor(@"#F8F8F8");
    [_nextReplacePair setCornerRadius:2 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    _nextReplacePair.textAlignment = NSTextAlignmentCenter;

    _lastBeforPair = [UIView labelWithTitle:@"" frame:CGRectNull];
    _lastBeforPair.backgroundColor = HexColor(@"#F8F8F8");
    [_lastBeforPair setCornerRadius:2 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    _lastBeforPair.textAlignment = NSTextAlignmentCenter;

    _lastReplacePair = [UIView labelWithTitle:@"" frame:CGRectNull];
    _lastReplacePair.backgroundColor = HexColor(@"#F8F8F8");
    [_lastReplacePair setCornerRadius:2 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    _lastReplacePair.textAlignment = NSTextAlignmentCenter;

    
    _nextImageH = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"zzc_pari_gray"] frame:CGRectNull];
    _beImageV = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"zzc_pari_speed"] frame:CGRectNull];
    _lastImageH = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"zzc_pari_gray"] frame:CGRectNull];
    _reImageV = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"zzc_pari_speed"] frame:CGRectNull];

    
    _cancelBtn = [UIView buttonWithTitle:@"取消" responder:self SEL:@selector(btnClick:) frame:CGRectNull];
    [_cancelBtn setCornerRadius:1 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    
    _sureBtn = [UIView buttonWithTitle:@"确定" responder:self SEL:@selector(btnClick:) frame:CGRectNull];
    [_sureBtn setCornerRadius:1 borderColor:HexColor(@"#DCDCDC") borderWidth:1];
    [_sureBtn setTitleColor:HexColor(@"#AD0100") forState:UIControlStateNormal];
    
    
    [self addSubviews:@[
        _tipName,
        _line1,
        _remark,
        _pairReplace,
        _img1,
        _pairNoTextField,
        _line2,
        _checkBtn,
        _btnLabel,
        _bottomBgView,
        _cancelBtn,
        _sureBtn
        
    ]];
    
    [_bottomBgView addSubviews:@[
        _bgImage,
        _nextBeforPair,
        _nextReplacePair,
        _lastBeforPair,
        _lastReplacePair,
        _nextImageH,
        _beImageV,
        _lastImageH,
        _reImageV
    ]];
    
    
}

-(void)setDataSource:(NSArray *)array index:(int)index{
    
    _dataArr = array;
    _index = index;
    
    _pairReplace.text = array[index][@"pairNo"];
    
    if (array.count > index + 1) {
        _nextBeforPair.text = array[index + 1][@"pairNo"];
        _lastBeforPair.text = array.lastObject[@"pairNo"];
    }
    
  
    
    [self autolayout];
}


-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([textField.text obj_IsNull]) {
        return;
    }
    
    [_postArr removeAllObjects];
    
    _nextReplacePair.text = [NSString stringWithFormat:@"%d",[_pairNoTextField.text intValue] + 1];
    _lastReplacePair.text = [NSString stringWithFormat:@"%lu",[_pairNoTextField.text intValue] + _dataArr.count - _index - 1];
    
    int no = [_pairNoTextField.text intValue];
    
    for (int i = _index; i<_dataArr.count; i++) {
        NSDictionary *dic = _dataArr[i];
        
        NSDictionary *dict = @{
            @"gid" : dic[@"GID"],
            @"no" : [NSString stringWithFormat:@"%d",no]
        };
        [_postArr addObject:dict];
        
        no ++;
    }
    
    
    
}

- (void)autolayout {
    
    //显示状态 3  如果长按的是最后一个，表示无需要后续的批量修改
    //显示状态 2  如果长按的是倒数第二个，表示有一个需要后续的批量修改
    //显示状态 1  正常
    int showState = 1;
    if (_dataArr.count == _index +1) {
        showState = 3;
    }else if (_dataArr.count == _index + 2){
        showState = 2;
    }
      
    _tipName.frame = CGRectMake(0, 0, self.width, 30);

    _line1.frame = CGRectMake(0, _tipName.height, self.width, 1);
    
    _remark.frame = CGRectMake(10, _line1.height + _line1.y + 5, self.width - 20, 20);

    _pairReplace.frame = CGRectMake(Horizontal(40), _remark.height + _remark.y + 5, Horizontal(35), Horizontal(35));

    _pairNoTextField.frame = CGRectMake(self.width - Horizontal(40) - Horizontal(35), _pairReplace.y, _pairReplace.width, _pairReplace.height);

    
    _img1.frame = CGRectMake(_pairReplace.width + _pairReplace.x + 10, _pairReplace.y, _pairNoTextField.x - 10 - 10 - _pairReplace.width - _pairReplace.x, 6);
    _img1.centerY = _pairReplace.centerY;
    
    _line2.frame = CGRectMake(0, _pairReplace.height + _pairReplace.y + 10, self.width, 1);

    
    
    if (showState == 3) {

        _checkBtn.hidden = YES;
        _btnLabel.hidden = YES;
        _bottomBgView.hidden = YES;
        
        _cancelBtn.frame  = CGRectMake(0, _line2.y, self.width/2, 40);
        _sureBtn.frame  = CGRectMake(self.width/2, _line2.y, self.width/2, 40);

        
    }else if (showState == 2){
        
        _checkBtn.hidden = NO;
        _btnLabel.hidden = NO;
        _bottomBgView.hidden = NO;
        _lastBeforPair.hidden = YES;
        _lastReplacePair.hidden = YES;
        _lastImageH.hidden = YES;
        _beImageV.hidden = YES;
        _reImageV.hidden = YES;
        
        _checkBtn.frame = CGRectMake(10, _line2.y + _line2.height + 10, 15, 15);
        
        _btnLabel.frame = CGRectMake(_checkBtn.width + _checkBtn.x + 5, _line2.y + _line2.height, self.width - (_checkBtn.width + _checkBtn.x + 5)-10, 35);


        CGFloat bottomHeight =  Horizontal(35)+ 2*10;
        
        _bottomBgView.frame = CGRectMake(25, _btnLabel.y + _btnLabel.height , self.width - 50, bottomHeight);
        
        _bgImage.frame = CGRectMake(0, 0, _bottomBgView.width, _bottomBgView.height);
    
        _nextBeforPair.frame = CGRectMake(20, 10, Horizontal(35), Horizontal(35));
        
        _nextReplacePair.frame = CGRectMake(_bottomBgView.width - 20 -Horizontal(35) , 10, Horizontal(35), Horizontal(35));

        _nextImageH.frame = CGRectMake(_nextBeforPair.width + _nextBeforPair.x + 10 , _nextBeforPair.y, _nextReplacePair.x - 10 - 10 - _nextBeforPair.width - _nextBeforPair.x, 6);
        _nextImageH.centerY = _nextBeforPair.centerY;
        
        
        _cancelBtn.frame  = CGRectMake(0, _bottomBgView.y + _bottomBgView.height + 10, self.width/2, 40);
        _sureBtn.frame  = CGRectMake(self.width/2, _cancelBtn.y, self.width/2, 40);


        
    }else{
        
        _checkBtn.hidden = NO;
        _btnLabel.hidden = NO;
        _bottomBgView.hidden = NO;
        
        _lastBeforPair.hidden = NO;
        _lastReplacePair.hidden = NO;
        _lastImageH.hidden = NO;
        _beImageV.hidden = NO;
        _reImageV.hidden = NO;

        
        _checkBtn.frame = CGRectMake(10, _line2.y + _line2.height + 10, 15, 15);
        
        _btnLabel.frame = CGRectMake(_checkBtn.width + _checkBtn.x + 5, _line2.y + _line2.height, self.width - (_checkBtn.width + _checkBtn.x + 5)-10, 35);


        CGFloat bottomHeight =  Horizontal(35)*2+ 3*10;

        _bottomBgView.frame = CGRectMake(25, _btnLabel.y + _btnLabel.height , self.width - 50, bottomHeight);
        
        _bgImage.frame = CGRectMake(0, 0, _bottomBgView.width, _bottomBgView.height);

        _nextBeforPair.frame = CGRectMake(20, 10, Horizontal(35), Horizontal(35));
        
        _nextReplacePair.frame = CGRectMake(_bottomBgView.width - 20 -Horizontal(35) , 10, Horizontal(35), Horizontal(35));

        _nextImageH.frame = CGRectMake(_nextBeforPair.width + _nextBeforPair.x + 10 , _nextBeforPair.y, _nextReplacePair.x - 10 - 10 - _nextBeforPair.width - _nextBeforPair.x, 6);
        _nextImageH.centerY = _nextBeforPair.centerY;
        
        
        _lastBeforPair.frame = CGRectMake(20, _nextBeforPair.height + _nextBeforPair.y + 10, Horizontal(35), Horizontal(35));

        _lastReplacePair.frame = CGRectMake(_bottomBgView.width - 20 -Horizontal(35) , _lastBeforPair.y, Horizontal(35), Horizontal(35));

    
        _lastImageH.frame = CGRectMake(_lastBeforPair.width + _lastBeforPair.x + 10 , _lastBeforPair.y, _lastReplacePair.x - 10 - 10 - _lastBeforPair.width - _lastBeforPair.x, 6);
        _lastImageH.centerY = _lastBeforPair.centerY;

        _beImageV.frame = CGRectMake(_nextBeforPair.x, _nextBeforPair.y + _nextBeforPair.height, 2, 10);
        _beImageV.centerX = _nextBeforPair.centerX;
        
        
   
        _reImageV.frame = CGRectMake(_lastReplacePair.x, _nextBeforPair.y + _nextBeforPair.height, 2, 10);
        _reImageV.centerX = _lastReplacePair.centerX;
        
        
        _cancelBtn.frame  = CGRectMake(0, _bottomBgView.y + _bottomBgView.height + 10, self.width/2, 40);
        _sureBtn.frame  = CGRectMake(self.width/2, _cancelBtn.y, self.width/2, 40);

    }
    
    if (self.heightBlock) {
        self.heightBlock(_cancelBtn.y + _cancelBtn.height);
    }
    
}


- (void)checkClick:(UIButton *)btn {
    
    if ([_pairNoTextField.text obj_IsNull]) {
        
        [YuanHUD HUDFullText:@"请先输入变更后的纤芯编号，在进行操作"];
        return;
    }
    
    if (_dataArr.count - _index < 2) {
        
        [YuanHUD HUDFullText:@"无批量变更数据"];
        return;
    }
    
    
    btn.selected = !btn.selected;

    
    if (btn.selected) {
        _bgImage.image = [UIImage Inc_imageNamed:@"zzc_pair_bg_green"];
        _nextImageH.image = [UIImage Inc_imageNamed:@"zzc_pari_green"];
        _lastImageH.image = [UIImage Inc_imageNamed:@"zzc_pari_green"];

    }else{
        _bgImage.image = [UIImage Inc_imageNamed:@"zzc_pair_bg_gray"];
        _nextImageH.image = [UIImage Inc_imageNamed:@"zzc_pari_gray"];
        _lastImageH.image = [UIImage Inc_imageNamed:@"zzc_pari_gray"];
    }
    
    
}


- (void)btnClick:(UIButton *)btn {
    
    if ([btn.titleLabel.text isEqualToString:@"确定"]) {
        if ([_pairNoTextField.text obj_IsNull]) {
            
            [YuanHUD HUDFullText:@"请先输入变更后的纤芯编号，在进行操作"];
            return;
        }
    }
    
    [_pairNoTextField resignFirstResponder];
    
    if (self.btnBlock) {
        if (_checkBtn.selected) {
            self.btnBlock(btn,_postArr);
        }else{
            
            
            NSMutableArray *arr = NSMutableArray.array;
            
            NSDictionary *dic = _dataArr[_index];
            
            NSDictionary *dict = @{
                @"gid" : dic[@"GID"],
                @"no" : [NSString stringWithFormat:@"%d",[_pairNoTextField.text intValue]]
            };
            [arr addObject:dict];
            
            self.btnBlock(btn,arr);
        }
    }
    
}



-(void)cleareData {
    
    [_postArr removeAllObjects];
    _pairReplace.text = @"";
    _pairNoTextField.text = @"";
    _nextReplacePair.text = @"";
    _lastReplacePair.text = @"";
    _nextBeforPair.text = @"";
    _lastBeforPair.text = @"";
    
    _checkBtn.selected = NO;


    _nextImageH.image = [UIImage Inc_imageNamed:@"zzc_pari_gray"];
    _lastImageH.image = [UIImage Inc_imageNamed:@"zzc_pari_gray"];
    
}

@end
