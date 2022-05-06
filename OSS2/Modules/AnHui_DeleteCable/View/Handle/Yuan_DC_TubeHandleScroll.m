//
//  Yuan_DC_TubeHandleScroll.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/12.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_DC_TubeHandleScroll.h"
#import "Yuan_TubeBtn.h"

static float btnLength = (35);
static float btn_Limit = 10;
@interface Yuan_DC_TubeHandleScroll () < UIScrollViewDelegate >

@end



@implementation Yuan_DC_TubeHandleScroll

{
    
    UILabel * _name;
    
    UIScrollView * _scroll;
    
    NSMutableArray <Yuan_TubeBtn *> * _btnArray;
}




#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        [self UI_Init];
        
        _btnArray = [NSMutableArray array];
    }
    return self;
}



#pragma mark - method ---

- (void) reloadTitle:(NSString *)name dataSource:(NSArray *)dataSource {
    
    // 重置前先清空
    
    for (Yuan_TubeBtn * btn in _btnArray) {
        [btn removeFromSuperview];
    }
    
    [_btnArray removeAllObjects];
    
    
    
    
    _name.text = name;
    
    float limit = Horizontal(btnLength);
    
    float btn_limit_width = Horizontal(btn_Limit);
    
    NSInteger count = dataSource.count;
    _scroll.contentSize = CGSizeMake(count * (limit + btn_limit_width), 0);
    
    for (int i = 0; i < count; i++) {
        
        NSDictionary * dict = dataSource[i];
        
        CGRect rect = CGRectMake(i * (limit + btn_limit_width), 0, limit, limit);
        Yuan_TubeBtn * btn = [[Yuan_TubeBtn alloc] initWithFrame:rect];
        
        [btn setBackgroundImage:[UIImage Inc_imageNamed:@"DC_guankong_Gray"]
                       forState:UIControlStateNormal];

        [btn setTitle:[Yuan_Foundation fromInt:i + 1] forState:UIControlStateNormal];
        
        btn.myDict = dict;
        
        [_scroll addSubview:btn];
        
        [_btnArray addObject:btn];
        
        [btn addTarget:self
                action:@selector(btnClick:)
      forControlEvents:UIControlEventTouchUpInside];
        
    }
    
}


- (void) btnClick:(Yuan_TubeBtn * )btn {
    
    TubeHandleType_ nowType;
    
    if ([_name.text isEqualToString:@"管孔"]) {
        nowType = TubeHandleType_Father;
    }
    else {
        nowType = TubeHandleType_Children;
    }
    
    if (_tubeHandleBtnBlock) {
        _tubeHandleBtnBlock(btn.myDict,nowType);
    }
}



#pragma mark - UI ---

- (void) UI_Init {
    
    _name = [UIView labelWithTitle:@"管孔: " frame:CGRectNull];
    _scroll = [[UIScrollView alloc] init];
    
    _scroll.showsHorizontalScrollIndicator = NO;
    
    [self addSubviews:@[_name,_scroll]];
    [self yuan_LayoutSubViews];
}



- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_name YuanAttributeHorizontalToView:self];
    [_name autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    
    [_scroll YuanAttributeHorizontalToView:self];
    [_scroll autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_name withOffset:limit];
    [_scroll autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_scroll autoSetDimension:ALDimensionHeight toSize:Horizontal(btnLength)];
    
}


@end
