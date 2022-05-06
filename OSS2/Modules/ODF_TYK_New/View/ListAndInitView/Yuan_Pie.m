//
//  Yuan_Pie.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/28.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_Pie.h"


@interface Yuan_Pie ()

/** 端子盘背景 */
@property (nonatomic,strong) UIImageView *img;

/** 左上角 三角形 */
@property (nonatomic,strong) UIImageView *leftTop_Triangle;

/** 左上角三角形里的 数字 */
@property (nonatomic,strong) UILabel *num;


@end


@implementation Yuan_Pie

{
    
    // 当前的状态 , 是高亮 还是黑暗   0 暗色     1 亮色
    PieState _state;
    
}


#pragma mark - 初始化构造方法 ****** ******* ********

- (instancetype) initWithState:(PieState)state {
    
    if (self = [super init]) {
        
        _state = state;
        [self UI_init];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
                        State:(PieState)state {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _state = state;
        [self UI_init];
    }
    return self;
}





- (void) UI_init {
    
    
    [self addSubview:self.img];
    [self addSubview:self.guanBi_Btn];
    [self addSubview:self.leftTop_Triangle];
    [self addSubview:self.num];
    
    [self layoutAllSubViews];
}



#pragma mark - 逻辑处理 *** *** ***



/// 切换盘的状态
/// @param state 盘的状态
- (void) changePieState:(PieState)state {
    
    _state = state;
    
    if (state == PieState_Colorful) {
        [self pieStateHighLight];
    }else {
        [self pieStateGray];
    }
    
}


- (PieState) getNowPieState {
    
    return _state;
}



/// 切换编辑状态
/// @param isEditStat 当前状态是否是编辑状态 ?  false是退出编辑状态 true 进入编辑状态
- (void) changeEditState:(BOOL) isEditStat
           isFaceInverse:(BOOL)isFaceInverse{
    
    /// 对侧边关闭按钮状态 进行判断 *** ***
    if (_state == PieState_Colorful) {
        _guanBi_Btn.hidden = !isEditStat;
        
    }else {
        // 盘的状态为 PieState_Normal_Gray 的话  无论如何 都不显示关闭按钮
        _guanBi_Btn.hidden = YES;
    }
    
    
    
    ///  对盘显示隐藏 进行判断 *** ***
    if (isEditStat == true) {
        self.hidden = NO;  // 进入编辑模式 , 所有的按钮都要显示出来
    }else {
        
        if (_state == PieState_Normal_Gray) {
            // 退出编辑模式  灰色按钮才隐藏起来
            self.hidden = YES;
        }
        
    }
    
    
    
    
    
    
}



/// 配置左上角的数字
/// @param count 数字字符串
- (void) setCountNum:(NSString *)count {
    
    _num.text = count;
}








#pragma mark -  *** ***  高亮和黑暗的切换


- (void) pieStateHighLight {
    // 背景
    _img.image = [UIImage Inc_imageNamed:@"bg_1"];
    
    // 左上角颜色
    _leftTop_Triangle.image = [UIImage Inc_imageNamed:@"img_1"];
    
    // 编号颜色
    _num.textColor = [UIColor whiteColor];   // 亮
}


- (void) pieStateGray {
    // 背景
    _img.image = [UIImage Inc_imageNamed:@"bg_2"];
    
    // 左上角颜色
    _leftTop_Triangle.image = [UIImage Inc_imageNamed:@"img_2"];
    
    // 编号颜色
    _num.textColor = ColorValue_RGB(0x444444);   //暗
    
}





 
#pragma mark - Lazy Load ****** ******* ******** ******** *


- (UIImageView *)img {
    
    if (!_img) {
        
        _img = [[UIImageView alloc] init];
        
        NSString * imgName = @"";
        
        if (_state == PieState_Colorful) {
            imgName = @"bg_1";      //亮
        }else {
            imgName = @"bg_2";      //暗
        }
        
        _img.image = [UIImage Inc_imageNamed:imgName];
        
    }
    return _img;
}


- (UIButton *)guanBi_Btn {
    
    if (!_guanBi_Btn) {
        
        _guanBi_Btn = [[UIButton alloc] init];
        
        NSString * imgName = @"";
        
        if (_state == PieState_Colorful) {
            imgName = @"guanbi";      //亮 高亮状态下 只有编辑模式下 才显示关闭按钮
        }else {
            imgName = @"";      //暗 -- 黑暗情况下 没有关闭按钮
        }
        
        [_guanBi_Btn setBackgroundImage:[UIImage Inc_imageNamed:@"guanbi"]
                               forState:UIControlStateNormal];
        
        _guanBi_Btn.hidden = YES;  //默认隐藏 只有在编辑模式 才打开
    }
    return _guanBi_Btn;
}


- (UIImageView *)leftTop_Triangle {
    
    if (!_leftTop_Triangle) {
        
        _leftTop_Triangle = [[UIImageView alloc] init];
        
        NSString * imgName = @"";
        
        if (_state == PieState_Colorful) {
            imgName = @"img_1";      //亮
        }else {
            imgName = @"img_2";      //暗
        }
        
        _leftTop_Triangle.image = [UIImage Inc_imageNamed:imgName];
        
    }
    return _leftTop_Triangle;
}


- (UILabel *)num {
    
    if (!_num) {
        _num = [UIView labelWithTitle:@"1" frame:CGRectNull];
        
        if (_state == PieState_Colorful) {
            _num.textColor = [UIColor whiteColor];       //亮
        }else {
            _num.textColor = ColorValue_RGB(0x444444);   //暗
        }
        
        _num.font = [UIFont systemFontOfSize:12];
    }
    return _num;
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    /// 背景图
    [_img autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [_img autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_img autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_img autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(20)];
    
    /// 关闭按钮
    [_guanBi_Btn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [_guanBi_Btn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_guanBi_Btn autoPinEdge:ALEdgeLeft
                      toEdge:ALEdgeRight
                      ofView:_img
                  withOffset:0];
    
    
    /// 左上角三角形
    [_leftTop_Triangle autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [_leftTop_Triangle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    
    /// 数字
    [_num autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:3];
    [_num autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:3];
    
}

@end
