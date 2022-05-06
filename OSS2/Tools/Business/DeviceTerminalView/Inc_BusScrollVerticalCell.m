//
//  Inc_BusScrollVerticalCell.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BusScrollVerticalCell.h"

#import "Yuan_CFConfigVM.h"
#import "Yuan_CFConfigModel.h"
#import "Inc_BusScrollItem.h"

@interface Inc_BusScrollVerticalCell ()

/** 上边 绑卡*/
@property (nonatomic,strong) UILabel *Limit_Top;

/** 下边 绑卡 */
@property (nonatomic,strong) UILabel *Limit_Bottom;

@end

@implementation Inc_BusScrollVerticalCell
{
    float _Limit_Side;
    
    NSMutableArray * _btnViewArray;
    
    NSArray * _btnDatas;   //来自外部map
    
    UILongPressGestureRecognizer * _gesture;  //长按手势
    
    NSInteger _position;  //当前模块的 position  初始化模块时使用
    
    NSInteger _terminalCount; // 行内端子个数
    
    
    __weak Yuan_CFConfigVM * _viewModel;  //viewModel
}



#pragma mark - 初始化构造方法

- (instancetype) initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        
        _viewModel = Yuan_CFConfigVM.shareInstance;
        
        _Limit_Side = Horizontal(40);
        _btnViewArray = [NSMutableArray array];

        [self.contentView addSubview:self.Limit_Top];
        [self.contentView addSubview:self.Limit_Bottom];
        [self layoutAllSubViews];
     
    }
    return self;
}




#pragma mark - 设置数值

- (void) CellPosition:(NSInteger)position {
    
    _position = position;
    
    //绑卡赋值  -- 当初始化构造器是4的时候 , 则不显示绑卡数字
    if (_viewModel.isInitType_4_Mode) {
        _Limit_Top.text = @"";
        _Limit_Bottom.text = @"";
    }
    else {
        _Limit_Top.text = [Yuan_Foundation fromInteger:position];
        _Limit_Bottom.text = [Yuan_Foundation fromInteger:position];
    }
    
}


#pragma mark - 设置模块内端子个数与排序

/// 设置 模块内的端子个数 与排序
/// terminalCount 端子个数
/// moduleRows 盘内端子列数
/// moduleColumn 盘内端子行数
- (void) CellTerminal:(int)terminalCount
           moduleRows:(int)moduleRows
         moduleColumn:(int)moduleColumn {
    
    
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
        
        
     
        
        CGRect frame = CGRectMake(Row_Y * _Limit_Side,
                                  Col_X * _Limit_Side,
                                  _Limit_Side,
                                  _Limit_Side);
        
        Inc_BusScrollItem * btn = [[Inc_BusScrollItem alloc] initWithFrame:frame];
          
        btn.index = i;

        btn.position = _position;
        
        [btn configMyNum:i];

        btn.backgroundColor = [UIColor whiteColor];

        [btn addTarget:self action:@selector(btnClick:)
        forControlEvents:UIControlEventTouchUpInside];

        btn.hidden = YES;  //默认是红色状态 , 如果有值传入 , 给他改成正常状态

        [self.contentView addSubview:btn];

        // 把所有的按钮 都放置在此数组中
        [_btnViewArray addObject:btn];
        
        
        //TODO: 暂时注释
        // 给viewmodel里增加这个集合  点击事件和 切换端子盘时使用
        //[_viewModel.terminalBtnArray addObject:btn];
    }
    
    
    // 组成一个  position : btnarray 的map
    
    _position_btnArray_Dict = @{[NSNumber numberWithInteger:_position] :
                                    _btnViewArray};
    
}



#pragma mark - 点击事件

- (void) btnClick:(Inc_BusScrollItem *)sender {
    
    
    // 如果 代理类 声明了代理 , 并且实现了代理方法
    // 把按钮对象 传过去
    [_delegate vertical_TerminalBtn:sender];
}



#pragma mark - 给btn 传数据

/// 按钮的数据源 用于跳转到模板时传参 或 判断当前端子状态与颜色
/// @param btnDataSource 数据源

- (void) CellBtnMap_Dict:(NSDictionary *)btnDataSource {
    
    // 拿到对应的资源数组
    _btnDatas = btnDataSource[@"opticTerms"];
    
    
    
    if (_btnDatas.count != _terminalCount) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"端子盘信息错误!"];
        
        // 端子盘信息错误 , 返回上一个界面
        NSNotification * info_Noti =
        [[NSNotification alloc] initWithName:Noti_DuanZiPan_msg_Error
                                      object:nil
                                    userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] postNotification:info_Noti];
        
        
        return;
    }
    
    
    
    // 正常状况下 给按钮赋值
    for (Inc_BusScrollItem * btn in _btnViewArray) {
        
        // 模块绑卡的颜色 从红色 变为 浅蓝色
        _Limit_Top.backgroundColor = ColorValue_RGB(0x9ab2cc);
        _Limit_Bottom.backgroundColor = ColorValue_RGB(0x9ab2cc);
        
        
        // 每个map里都有一个 position字段 , 需要根据这个position字段 与按钮的index 对应赋值
        for (NSDictionary * positionDict in _btnDatas) {
            
            if ([[Yuan_Foundation fromObject:positionDict[@"position"]] isEqualToString:[Yuan_Foundation fromInteger:btn.index]]) {
                
                // 证明这是新的接口 , 走新的赋值方式
                if ([positionDict.allKeys containsObject:@"opticTermList"]) {
                    [btn configNewDict:positionDict];
                }
                
                // 老接口
                else {
                    btn.dict = positionDict;
                }
                
                
                btn.hidden = NO;   //有值的时候 就显示出来
            }
        }

    }
    
    // 并且有map 的时候 就要取消掉他的长按手势 , 以免有端子 还可以再继续创建
    [self.contentView removeGestureRecognizer:_gesture];
    
}



#pragma mark - UI *** *** ***


- (UILabel *)Limit_Top {
    
    if (!_Limit_Top) {
        _Limit_Top = [UIView labelWithTitle:@"1" frame:CGRectNull];
        _Limit_Top.textAlignment = NSTextAlignmentCenter;
        _Limit_Top.backgroundColor = ColorValue_RGB(0xAA0033);
        _Limit_Top.textColor = [UIColor whiteColor];
        
        [_Limit_Top addSubview:[self pointView]];
    }
    return _Limit_Top;
}


- (UILabel *)Limit_Bottom {
    
    if (!_Limit_Bottom) {
        _Limit_Bottom = [UIView labelWithTitle:@"1" frame:CGRectNull];
        _Limit_Bottom.textAlignment = NSTextAlignmentCenter;
        _Limit_Bottom.backgroundColor = ColorValue_RGB(0xAA0033);
        _Limit_Bottom.textColor = [UIColor whiteColor];
        
        [_Limit_Bottom addSubview:[self pointView]];
    }
    return _Limit_Bottom;
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
    
    /// 上边
    [_Limit_Top autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [_Limit_Top autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_Limit_Top autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_Limit_Top autoSetDimensionsToSize:CGSizeMake(_Limit_Side, _Limit_Side)];
    
    
    
    /// 下边
    [_Limit_Bottom autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_Limit_Bottom autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_Limit_Bottom autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_Limit_Bottom autoSetDimensionsToSize:CGSizeMake(_Limit_Side, _Limit_Side)];
    
}


- (NSArray *) btnsArr  {
    return _btnViewArray;
    
}

@end
