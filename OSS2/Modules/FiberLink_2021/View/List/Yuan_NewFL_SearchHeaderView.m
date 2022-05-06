//
//  Yuan_NewFL_SearchHeaderView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_SearchHeaderView.h"

#import "Yuan_NewFL_AZField.h"      // AZ端
#import "Yuan_NewFL_SearchField.h"




@implementation Yuan_NewFL_SearchHeaderView

{
    
    Yuan_NewFL_SearchField * _header;
    Yuan_NewFL_AZField * _A;
    Yuan_NewFL_AZField * _Z;
    
    UIButton * _clear;
    UIButton * _search;
}




#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        [self UI_Init];
        [self block_Init];
    }
    return self;
}


- (void) UI_Init {
    
    _header = [[Yuan_NewFL_SearchField alloc] init];
    [_header cornerRadius:5 borderWidth:1 borderColor:ColorValue_RGB(0xf2f2f2)];
    
    
    _A = [[Yuan_NewFL_AZField alloc] initWithAZ:Yuan_NewFL_AZField_A];
    _Z = [[Yuan_NewFL_AZField alloc] initWithAZ:Yuan_NewFL_AZField_Z];
    
    _clear = [UIView buttonWithTitle:@"清空" responder:self SEL:@selector(clearClick) frame:CGRectNull];
    _search = [UIView buttonWithTitle:@"搜索" responder:self SEL:@selector(searchClick) frame:CGRectNull];
    
    _search.backgroundColor = UIColor.mainColor;
    [_search setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_search cornerRadius:5 borderWidth:0 borderColor:nil];
    
    [self addSubviews:@[_header,_A,_Z,_clear,_search]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_header YuanToSuper_Top:0];
    [_header YuanToSuper_Left:0];
    [_header YuanToSuper_Right:0];
    [_header autoSetDimension:ALDimensionHeight toSize:Vertical(50)];
    
    
    [_A YuanMyEdge:Top ToViewEdge:Bottom ToView:_header inset:0];
    [_A YuanToSuper_Left:limit/2];
    [_A YuanToSuper_Right:limit/2];
    [_A autoSetDimension:ALDimensionHeight toSize:Vertical(70)];
    
    [_Z YuanMyEdge:Top ToViewEdge:Bottom ToView:_A inset:limit/2];
    [_Z YuanToSuper_Left:limit/2];
    [_Z YuanToSuper_Right:limit/2];
    [_Z autoSetDimension:ALDimensionHeight toSize:Vertical(70)];
    
    [_clear YuanMyEdge:Top ToViewEdge:Bottom ToView:_Z inset:limit];
    [_clear YuanToSuper_Left: limit];
    [_clear autoSetDimension:ALDimensionWidth toSize:Horizontal(50)];
    
    [_search YuanAttributeHorizontalToView:_clear];
    [_search YuanToSuper_Right:limit];
    [_search autoSetDimension:ALDimensionHeight toSize:Vertical(35)];
    [_search YuanMyEdge:Left ToViewEdge:Right ToView:_clear inset:limit];
}



- (void) block_Init {
    
    __typeof(self)weakSelf = self;
    // header 点击事件
    _header.NewFL_ClickBlock = ^(NewFL_Click_ click) {
        
        if (click == NewFL_Click_Show) {
            [weakSelf headerClick:HeaderBtnClick_Show];
        }
        else {
            [weakSelf headerClick:HeaderBtnClick_HeaderSearch];
        }
    };
    
    
    // A端点击事件 搜索
    _A.AZ_Block = ^(Yuan_NewFL_AZField_ AZ) {
        [weakSelf headerClick:HeaderBtnClick_A];
    };
    
    // Z端点击事件 搜索
    _Z.AZ_Block = ^(Yuan_NewFL_AZField_ AZ) {
        [weakSelf headerClick:HeaderBtnClick_Z];
    };
}

- (void) headerClick: (HeaderBtnClick_)click {
    
    if (!_headerBlock) {
        return;
    }
    
    _headerBlock(click);
    
}



#pragma mark - btnClick ---

// 清空
- (void) clearClick {
    
    [self clear];
    // 并且通知外部 , 把选完的数据干掉
    [self headerClick:HeaderBtnClick_Clear];
}

// 红色搜索按钮
- (void) searchClick {
    
    [self headerClick:HeaderBtnClick_Search];
}


- (void) show  {
    
    _nowIsShow = YES;
    
    _A.hidden = NO;
    _Z.hidden = NO;
    _search.hidden = NO;
    _clear.hidden = NO;
}

- (void) hide  {
    
    _nowIsShow = NO;
    
    _A.hidden = YES;
    _Z.hidden = YES;
    _search.hidden = YES;
    _clear.hidden = YES;
}


- (void) reloadDeviceName:(NSString *)deviceName
                     Type:(HeaderBtnClick_)azType {
    
    if (azType == HeaderBtnClick_A) {
        [_A reloadName:deviceName];
    }
    else {
        [_Z reloadName:deviceName];
    }
    
}


- (void) clear {
    
    [_header clear];
    [_A clear];
    [_Z clear];
}

- (NSString *) searchName {
    
    return _header.searchName;
}

@end
