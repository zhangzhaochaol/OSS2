//
//  Inc_CardRemarksTipView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/8.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CardRemarksTipView.h"
#import "Inc_TriangleView.h"


@interface Inc_CardRemarksTipView ()
{
    //角标
    Inc_TriangleView *_triangView;
    //角标数字
    UILabel *_noLabel;
    
    
    //备注标题
    UILabel *_tipLabel;
    
    //取消按钮
    UIButton *_cancelBtn;
    //保存按钮
    UIButton *_saveBtn;
    
    
}

@end


@implementation Inc_CardRemarksTipView



- (instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self setCornerRadius:4 borderColor:UIColor.clearColor borderWidth:1];

        [self setupUI];
        
    }
    return self;
}

-(void)setupUI {
    
    _tipLabel = [UIView labelWithTitle:@"备注" isZheH:YES];
    _tipLabel.backgroundColor = UIColor.whiteColor;
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.font = Font_Yuan(15);
    _tipLabel.textColor = UIColor.blackColor;
    _tipLabel.frame = CGRectMake(0, 0, self.width, 40);
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(0, _tipLabel.height + 1, self.width, 100)];
    
    _cancelBtn = [UIView buttonWithTitle:@"取消" responder:self SEL:@selector(btnClick:) frame:CGRectMake(0, _textView.height + _textView.y+1, self.width/2, 40)];
    _cancelBtn.backgroundColor = UIColor.whiteColor;

    _saveBtn = [UIView buttonWithTitle:@"保存" responder:self SEL:@selector(btnClick:) frame:CGRectMake(self.width/2 + 1, _textView.height + _textView.y+1, self.width/2-1, 40)];
    [_saveBtn setTitleColor:Color_V2Red forState:UIControlStateNormal];
    _saveBtn.backgroundColor = UIColor.whiteColor;

    [self addSubviews:@[_tipLabel,_textView,_cancelBtn,_saveBtn]];
    
    
    _triangView = [[Inc_TriangleView alloc]initWithColor:ColorValue_RGB(0x9ab2cc)];
    _triangView.frame = CGRectMake(0, 0, 40, 40);
    
    [self addSubview:_triangView];
    
    _noLabel = [UIView labelWithTitle:@"" isZheH:YES];
    _noLabel.frame = CGRectMake(4, 6, _triangView.width/2 -2, 12);
    _noLabel.textColor = UIColor.whiteColor;
    _noLabel.font = Font_Yuan(9);
    _noLabel.textAlignment = NSTextAlignmentCenter;
    
    [_triangView addSubview:_noLabel];
    
    
    //白点
    UIView *cView  =[UIView viewWithColor:UIColor.whiteColor];
    cView.frame = CGRectMake(3, 3, 3, 3);
    [cView setCornerRadius:1.5 borderColor:UIColor.whiteColor borderWidth:1];
    
    [_triangView addSubview:cView];
    
}


-(void)setNum:(NSString *)num {
    
    _noLabel.text = num;
    
    if (self.heightBlock) {
        self.heightBlock(182);
    }
}


- (void)btnClick:(UIButton *)btn {
            
    if (self.btnBlock) {
        self.btnBlock(btn);
    }
}


- (NSString *)getRemarkText {
    
    return _textView.text;
}


@end
