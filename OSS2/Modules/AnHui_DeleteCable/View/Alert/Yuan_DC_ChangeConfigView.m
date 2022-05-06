//
//  Yuan_DC_ChangeConfigView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_DC_ChangeConfigView.h"

#import "Yuan_DC_VM.h"

@implementation Yuan_DC_ChangeConfigView

{
    
    UIButton * _myChooseBtn;
    
    UIView * _chooseView;
    
    UILabel * _chooseTitle;
    
    UILabel * _msg;
    
    NSString * _title;
    
    Yuan_DC_VM * _VM;
    
}


#pragma mark - 初始化构造方法

- (instancetype)initWithTitle:(NSString *) title {
    
    if (self = [super init]) {
        
        _VM = Yuan_DC_VM.shareInstance;
        
        _title = title;
        
        [self UI_Init];
    }
    return self;
}




- (void) chooseClick {
    
    NSString * myMsg = [NSString stringWithFormat:@"是否将管孔配置切换为%@",_title];
    
    [UIAlert alertSmallTitle:myMsg
                          vc:_vc
               agreeBtnBlock:^(UIAlertAction *action) {
            
        if ([_title isEqualToString:@"手动配置"]) {
            _VM.isAutoConfigTube = NO;
        }
        else {
            _VM.isAutoConfigTube = YES;
        }
        
        [_vc dismissViewControllerAnimated:YES completion:^{
            [[Yuan_HUD shareInstance] HUDFullText:@"切换成功"];
        }];
        
    }];
    
}



- (void) mySelect:(BOOL)isSelect {
    
    if (isSelect) {
        _chooseView.backgroundColor = UIColor.mainColor;
    }
    else {
        _chooseView.backgroundColor = UIColor.whiteColor;
    }
    
}



- (void) UI_Init {
    
    _myChooseBtn = [UIView buttonWithTitle:@""
                                 responder:self
                                       SEL:@selector(chooseClick)
                                     frame:CGRectNull];
    
    
    _chooseView = [UIView viewWithColor:UIColor.whiteColor];
    [_chooseView cornerRadius:0 borderWidth:1 borderColor:UIColor.blackColor];
    
    _chooseTitle = [UIView labelWithTitle:_title frame:CGRectNull];
    
    
    
    NSString * myMsg = @"";
    
    if ([_title isEqualToString:@"手动配置"]) {
            
        myMsg = @"在管道段上进行挂缆操作时 , 弹出管孔界面进行管孔选择";
    }
    
    else {
        myMsg = @"系统默认1号孔为挂缆管孔 , 如没有管孔系统则自动生成一号管孔";
        
    }
        
    
    
    _msg = [UIView labelWithTitle:myMsg frame:CGRectNull];
    _msg.numberOfLines = 0;//根据最大行数需求来设置
    _msg.lineBreakMode = NSLineBreakByTruncatingTail;
    _msg.textColor = ColorValue_RGB(0x777777);
    _msg.font = Font_Yuan(12);
    _msg.textAlignment = NSTextAlignmentLeft;
    
    
    [self addSubviews:@[_myChooseBtn,_msg]];
    [_myChooseBtn addSubviews:@[_chooseTitle,_chooseView]];
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(10);
    
    [_myChooseBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_myChooseBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_myChooseBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
    [_myChooseBtn autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
    
    
    [_chooseView autoSetDimensionsToSize:CGSizeMake(Horizontal(15), Horizontal(15))];
    [_chooseView YuanAttributeHorizontalToView:_myChooseBtn];
    [_chooseView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit/2];
    
    [_chooseTitle YuanAttributeHorizontalToView:_myChooseBtn];
    [_chooseTitle autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_chooseView withOffset:limit/2];
    
    
    
    
    [_msg autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_myChooseBtn withOffset:limit/2];
    [_msg autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit * 2];
    [_msg autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_msg autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
 
}


@end
