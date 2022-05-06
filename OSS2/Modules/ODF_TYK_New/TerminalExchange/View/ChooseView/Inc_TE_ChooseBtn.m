//
//  Inc_TE_ChooseBtn.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TE_ChooseBtn.h"


// ****
#import "Inc_TE_HttpModel.h"
#import "Inc_TE_ViewModel.h"

@implementation Inc_TE_ChooseBtn
{
    UIImageView * _img;
    
    // 半透明业务状态
    UILabel * _alphaState;
    
    UILabel * _resName;
    
    Inc_TE_ViewModel * _VM;
}





#pragma mark - 初始化构造方法

- (instancetype)initWithEnum:(TE_ChooseBtn_) Enum {
    
    if (self = [super init]) {
        
        _VM = Inc_TE_ViewModel.shareInstance;
        
        NSString * imageName = @"";
        
        if (Enum == TE_ChooseBtn_A) {
            imageName = @"TE_A";
        }
        
        else {
            imageName = @"TE_B";
        }
        
        _img = [UIView imageViewWithImg:[UIImage Inc_imageNamed:imageName]
                                  frame:CGRectNull];
        
        
        _alphaState = [UIView labelWithTitle:@"" frame:CGRectNull];
        _alphaState.font = Font_Bold_Yuan(25);
        
        _resName= [UIView labelWithTitle:@"" frame:CGRectNull];
        _resName.textAlignment = NSTextAlignmentCenter;
        _resName.font = Font_Yuan(12);
        
        [self addSubviews:@[_img , _alphaState , _resName]];
        [self yuan_LayoutSubViews];

    }
    return self;
}


- (void) yuan_LayoutSubViews {
    
    [_img YuanToSuper_Left:0];
    [_img YuanToSuper_Top:0];
    
    [_alphaState YuanAttributeHorizontalToView:self];
    [_alphaState YuanAttributeVerticalToView:self];
    
    [_resName YuanAttributeHorizontalToView:self];
    [_resName YuanToSuper_Left:Horizontal(15)];
    [_resName YuanToSuper_Right:Horizontal(15)];
}



- (void) reloadWithState:(NSString *) state
                 resName:(NSString *) resName{
    
    
    NSInteger oprStateId = state.integerValue;
    
    _alphaState.textColor = [_VM colorFromState:oprStateId needAlpha:YES];
    _alphaState.text = [_VM msgFromState:oprStateId];
    
    _resName.text = resName;
    
}


@end
