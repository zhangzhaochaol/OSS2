//
//  Yuan_ScrollHorizontalCell.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/3.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_ScrollHorizontalCell.h"





@interface Yuan_ScrollHorizontalCell ()

/** 左边 */
@property (nonatomic,strong) UILabel *Limit_Left;

/** 右边 */
@property (nonatomic,strong) UILabel *Limit_Right;

@end

@implementation Yuan_ScrollHorizontalCell
{
    float _Limit_Side;
    
    NSMutableArray * _btnViewArray;  //所有按钮的集合
    
    NSArray * _btnDatas;   //来自外部map
    
    UILongPressGestureRecognizer * _gesture;  //长按手势
    
    NSInteger _position;  //当前模块的 position  初始化模块时使用
    
    
    NSInteger _terminalCount; //行内端子个数
    
}

#pragma mark - 初始化构造方法

- (instancetype) initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        
        _Limit_Side = Horizontal(40);
        _btnViewArray = [NSMutableArray array];

        [self.contentView addSubview:self.Limit_Left];
        [self.contentView addSubview:self.Limit_Right];
        [self layoutAllSubViews];
        
    }
    return self;
}



#pragma mark - 设置数值

- (void) CellPosition:(NSInteger)position {
    
    _position = position;
    
    // 绑卡赋值
    _Limit_Left.text = [Yuan_Foundation fromInteger:position];
    _Limit_Right.text = [Yuan_Foundation fromInteger:position];
}


#pragma mark - 设置模块内端子个数与排序 


- (void) CellTerminal:(int)terminalCount
           moduleRows:(int)moduleRows
         moduleColumn:(int)moduleColumn {
    
    // moduleColumn 横向几个
    // moduleRows 纵向几个
    
    // 行内端子个数
    _terminalCount = terminalCount;
    
    
    for (int i = 1; i <= terminalCount; i++) {
        
        int Row_Y = 0;      //纵向高度
        int Col_X = moduleColumn;      //横向宽度
        
        if (i % moduleColumn != 0) {
            Row_Y = (int)(i / moduleColumn);
        }
        else {
            Row_Y = i / moduleColumn - 1;
        }
        
        
        if (i % moduleColumn != 0) {
            Col_X = i % moduleColumn;
        }
        
        
        
        
        CGRect frame = CGRectMake(Col_X * _Limit_Side,
                                  Row_Y * _Limit_Side,
                                  _Limit_Side,
                                  _Limit_Side);
        
        Yuan_terminalBtn * btn = [[Yuan_terminalBtn alloc] initWithFrame:frame];
        
        btn.index = i;
        
        btn.position = _position;
        
        [btn setTitle:[Yuan_Foundation fromInt:i]
             forState:UIControlStateNormal];
        
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.backgroundColor = [UIColor whiteColor];
        
        [btn setTitleColor:ColorValue_RGB(0x000000)
                  forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(btnClick:)
      forControlEvents:UIControlEventTouchUpInside];
        
        btn.hidden = YES;  //默认是红色状态 , 如果有值传入 , 给他改成正常状态
        
        [self.contentView addSubview:btn];
        
        // 把所有的按钮 都放置在此数组中
        [_btnViewArray addObject:btn];
    }

}



#pragma mark - 点击事件

- (void) btnClick:(Yuan_terminalBtn *)sender {
    
    NSLog(@"-- %@",sender.dict);
    
    if ([[_delegate class] conformsToProtocol:@protocol(ScrollHorizontalDeletate)]&&
      [_delegate respondsToSelector:@selector(horizontal_TerminalBtn:)]) {
      
        // 如果 代理类 声明了代理 , 并且实现了代理方法
        // 把按钮对象 传过去
        [_delegate horizontal_TerminalBtn:sender];
        
    }
    
    
}




#pragma mark - 给btn 传数据

/// 按钮的数据源 用于跳转到模板时传参 或 判断当前端子状态与颜色
/// @param btnDataSource 数据源
- (void) CellBtnMap_Dict:(NSDictionary *)btnDataSource {
    
    // 拿到对应的资源数组
    _btnDatas = btnDataSource[@"opticTerms"];
    
    if (_btnDatas.count != _terminalCount) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"端子盘信息错误!"];
        

        
        return;
    }
    
    
    
    
    // 正常状况下 给按钮赋值
    for (Yuan_terminalBtn * btn in _btnViewArray) {
        
        // 模块绑卡的颜色 从红色 变为 浅蓝色
        _Limit_Left.backgroundColor = ColorValue_RGB(0x9ab2cc);
        _Limit_Right.backgroundColor = ColorValue_RGB(0x9ab2cc);
        
        
        // 每个map里都有一个 position字段 , 需要根据这个position字段 与按钮的index 对应赋值
        for (NSDictionary * positionDict in _btnDatas) {
            if ([positionDict[@"position"] isEqualToString:[Yuan_Foundation fromInteger:btn.index]]) {
                btn.dict = positionDict;
                btn.hidden = NO;   //有值的时候 就显示出来
            }
        }

    }
    
    // 并且有map 的时候 就要取消掉他的长按手势 , 以免有端子 还可以再继续创建
    [self.contentView removeGestureRecognizer:_gesture];
    
}

#pragma mark - UI *** *** *** *** *** *** *** *** ***  UI创建 不用修改

- (UILabel *)Limit_Left {
    
    if (!_Limit_Left) {
        _Limit_Left = [UIView labelWithTitle:@"1" frame:CGRectNull];
        _Limit_Left.textAlignment = NSTextAlignmentCenter;
        _Limit_Left.backgroundColor = ColorValue_RGB(0xAA0033);
        _Limit_Left.textColor = [UIColor whiteColor];
        _Limit_Left.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(limitClick:)];
        
        [_Limit_Left addGestureRecognizer:tap];
        
        
        [_Limit_Left addSubview:[self pointView]];
        
    }
    return _Limit_Left;
}


- (UILabel *)Limit_Right {
    
    if (!_Limit_Right) {
        _Limit_Right = [UIView labelWithTitle:@"1" frame:CGRectNull];
        _Limit_Right.textAlignment = NSTextAlignmentCenter;
        _Limit_Right.backgroundColor = ColorValue_RGB(0xAA0033);
        _Limit_Right.textColor = [UIColor whiteColor];
        
        
        [_Limit_Right addSubview:[self pointView]];
    }
    return _Limit_Right;
}



- (UIView *) pointView {
    
    UIView * point = [UIView viewWithColor:[UIColor whiteColor]];
    point.frame = CGRectMake(5, 5, 2, 2);
    point.layer.cornerRadius = 1;
    point.layer.masksToBounds = YES;
    
    return point;
    
}



#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    
    
    
    /// 左边
    [_Limit_Left autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_Limit_Left autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [_Limit_Left autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_Limit_Left Yuan_EdgeWidth:_Limit_Side];
    
    
    
    /// 右边
    [_Limit_Right autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_Limit_Right autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [_Limit_Right autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_Limit_Right Yuan_EdgeWidth:_Limit_Side];
    
    
    
}


- (NSArray *) btnsArr {
    
    return _btnViewArray;
}


- (void)limitClick:(UITapGestureRecognizer *)tap {
    UILabel *lab = (UILabel*)tap.view;

    if (self.remarkBlock) {
        self.remarkBlock(lab.text);
    }

}
@end
