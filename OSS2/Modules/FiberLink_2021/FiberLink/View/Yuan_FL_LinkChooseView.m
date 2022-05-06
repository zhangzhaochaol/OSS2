//
//  Yuan_FL_LinkChooseView.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/12/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_FL_LinkChooseView.h"
#import "Yuan_NewFL_VM.h"


@implementation Yuan_FL_LinkChooseView
{
    
    UIImageView * _icon;
    
    UILabel * _name;
    
    UIButton * _firstFiber;
    
    UIButton * _secondFiber;
    
    NSArray * _myOptPairLinkList;
    
    Yuan_NewFL_VM * _VM;
}


#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
        [self UI_Init];
        self.backgroundColor = UIColor.whiteColor;
        _VM = Yuan_NewFL_VM.shareInstance;
    }
    return self;
}


#pragma mark -  method  ---

// 验证一共有几个选项 , 并且当前选中的应该是哪个芯
- (void) reloadLink:(NSArray *)optPairLinkList currentOptPairLinkId:(NSString *)currentOptPairLinkId {
    
    _myOptPairLinkList = optPairLinkList;
    
    _nowSelectId = currentOptPairLinkId;
    
    if (!optPairLinkList) {
        _firstFiber.hidden = YES;
        _secondFiber.hidden = YES;
        
        return;
    }
    
    if (optPairLinkList.count == 1) {
        
        NSDictionary * dict = optPairLinkList.firstObject;
        
        if (![dict[@"linkId"] isEqualToString:currentOptPairLinkId]) {
            _firstFiber.hidden = YES;
            _secondFiber.hidden = YES;
            
            [[Yuan_HUD shareInstance] HUDFullText:@"数据错误,无法切换光链路"];
            return;
        }
        
        [_secondFiber autoSetDimension:ALDimensionWidth toSize:0];
        _secondFiber.hidden = YES;
    }
    
    else if (optPairLinkList.count == 2) {
        
        NSDictionary * dict_Fir = optPairLinkList.firstObject;
        NSDictionary * dict_Sec = optPairLinkList.lastObject;
        
        [_firstFiber setTitle:dict_Fir[@"linkName"] forState:UIControlStateNormal];
        [_secondFiber setTitle:dict_Sec[@"linkName"] forState:UIControlStateNormal];
        
        if ([dict_Fir[@"linkId"] isEqualToString:currentOptPairLinkId]) {
            [self selectBtn:YES];
        }
        
        else  if ([dict_Sec[@"linkId"] isEqualToString:currentOptPairLinkId]) {
            [self selectBtn:NO];
        }
        else {
            
            _firstFiber.hidden = YES;
            _secondFiber.hidden = YES;
            
            [[Yuan_HUD shareInstance] HUDFullText:@"数据错误,无法切换光链路"];
            
            return;
        }
        
    }
    else {
        [[Yuan_HUD shareInstance] HUDFullText:@"数据错误,无法切换光链路,光链路个数大于2"];
        return;
    }
    
    
}



- (void) NewFL_ReloadLink:(NSArray *)optPairLinkList nowSelectIndex:(NSInteger)index {
    
    _myOptPairLinkList = optPairLinkList;
    
    _firstFiber.hidden = YES;
    _secondFiber.hidden = YES;
    
    if (!optPairLinkList ||
        optPairLinkList.count == 0 || optPairLinkList.count > 2 ||
        index > 2 ) {
        return;
    }
    
    
    // 只有一个链路
    if (optPairLinkList.count == 1) {
        
        _VM.numberOfLink = 1;
        
        _firstFiber.hidden = NO;
        [_secondFiber autoSetDimension:ALDimensionWidth toSize:0];
        _secondFiber.hidden = YES;
    }
    
    // 有两个链路
    else {
        
        _VM.numberOfLink = 2;
        
        _firstFiber.hidden = NO;
        _secondFiber.hidden = NO;
        
        if (index == 1) {
            [self selectBtn:YES];
        }
        else {
            [self selectBtn:NO];
        }
  
    }

}





#pragma mark -  btnClick  ---

- (void) firstFiberClick {
    
    if (_myOptPairLinkList.count < 1) {
        return;
    }
    
    [self selectBtn:YES];
    
    _VM.now_LinkNum = 1;
    
    NSDictionary * dict = _myOptPairLinkList.firstObject;
    if (_chooseId_Block) {
        _chooseId_Block(dict[@"linkId"] , 1);
    }
    
}


- (void) secondFiberClick {
    
    if (_myOptPairLinkList.count != 2) {
        return;
    }
    
    [self selectBtn:NO];
    
    _VM.now_LinkNum = 2;
    
    NSDictionary * dict = _myOptPairLinkList.lastObject;
    if (_chooseId_Block) {
        _chooseId_Block(dict[@"linkId"] , 2);
    }
}


- (void) selectBtn:(BOOL)isFirst {
    
    UIColor * noSelectColor = ColorValue_RGB(0x888888);
    
    _firstFiber.layer.borderColor = [noSelectColor CGColor];
    [_firstFiber setTitleColor:noSelectColor forState:UIControlStateNormal];
    
    _secondFiber.layer.borderColor = [noSelectColor CGColor];
    [_secondFiber setTitleColor:noSelectColor forState:UIControlStateNormal];
    
    
    if (isFirst) {
        _firstFiber.layer.borderColor = [Color_V2Red CGColor];
        [_firstFiber setTitleColor:Color_V2Red forState:UIControlStateNormal];
    }
    else {
        _secondFiber.layer.borderColor = [Color_V2Red CGColor];
        [_secondFiber setTitleColor:Color_V2Red forState:UIControlStateNormal];
    }
    
}



#pragma mark -  UI  ---


- (void) UI_Init {
    
    _icon = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"FL_GuangLian"] frame:CGRectNull];
    
    _name = [UIView labelWithTitle:@"光链路" frame:CGRectNull];
    
    _firstFiber = [UIView buttonWithTitle:@"1"
                                responder:self
                                      SEL:@selector(firstFiberClick)
                                    frame:CGRectNull];
    
    _secondFiber = [UIView buttonWithTitle:@"2"
                                 responder:self
                                       SEL:@selector(secondFiberClick)
                                     frame:CGRectNull];
    
    [_firstFiber cornerRadius:10 borderWidth:1 borderColor:Color_V2Red];
    [_secondFiber cornerRadius:10 borderWidth:1 borderColor:Color_V2Red];
    
    [_firstFiber setTitleColor:Color_V2Red forState:UIControlStateNormal];
    [_secondFiber setTitleColor:Color_V2Red forState:UIControlStateNormal];
    
    
    [self addSubviews:@[_icon,_name,_firstFiber,_secondFiber]];
    
    [self yuan_layoutAllSubViews];
}


#pragma mark - 屏幕适配

- (void) yuan_layoutAllSubViews {
    
    float limit = Horizontal(15);
    
    [_icon autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_icon YuanAttributeHorizontalToView:self];
    
    [_name YuanAttributeHorizontalToView:self];
    [_name autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_icon withOffset:limit];
    
    [_firstFiber YuanAttributeHorizontalToView:self];
    [_secondFiber YuanAttributeHorizontalToView:self];
    
    [_secondFiber autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_firstFiber autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:_secondFiber withOffset:-limit];
    
    
    [_firstFiber autoSetDimensionsToSize:CGSizeMake(Horizontal(70), Vertical(35))];
    [_secondFiber autoSetDimensionsToSize:CGSizeMake(Horizontal(70), Vertical(35))];
}

@end
