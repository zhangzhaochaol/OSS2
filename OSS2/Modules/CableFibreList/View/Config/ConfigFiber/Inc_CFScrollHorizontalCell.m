//
//  Inc_CFScrollHorizontalCell.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CFScrollHorizontalCell.h"

#import "Yuan_CFConfigVM.h"

#import "Yuan_CFConfigModel.h"

#import "Yuan_CF_HttpModel.h"

@interface Inc_CFScrollHorizontalCell ()

/** 左边 绑卡 */
@property (nonatomic,strong) UILabel *Limit_Left;

/** 右边 绑卡 */
@property (nonatomic,strong) UILabel *Limit_Right;


@end

@implementation Inc_CFScrollHorizontalCell

{
    float _Limit_Side;
    
    NSMutableArray * _btnViewArray;  //所有按钮的集合
    
    NSArray * _btnDatas;   //来自外部map
    
    NSInteger _position;  //当前模块的 position  初始化模块时使用
    
    NSInteger _terminalCount; //行内端子个数
    
    
    __weak Yuan_CFConfigVM * _viewModel;  //viewModel
    
}

#pragma mark - 初始化构造方法

- (instancetype) initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        
        _viewModel = Yuan_CFConfigVM.shareInstance;
        
        // 执行长按循环的事件  tapIndex是当前按钮 在数组中的位置 , position是当前按钮的组
/// MARK: 长按 自动配置  --
        _viewModel.viewModel_for_Circle_Block = ^(NSInteger tapIndex,
                                                  NSInteger position) {
            
            NSInteger position_now = position;
            
            for (int i = 0; i < _viewModel.for_Circle_Count; i++) {
                
                // 防止越界
                if (tapIndex + i > _viewModel.terminalBtnArray.count - 1) {
                    break;
                }
                
                Inc_CFConfigFiber_ItemBtn * btn = [_viewModel.terminalBtnArray objectAtIndex:tapIndex + i];
                
                position_now = btn.position;
                
                
                [self clickDo:btn];
            }
        };
        
        
               
/// MARK: 长按 手动配置  --
                
        __block Inc_CFConfigFiber_ItemBtn * btn;
        
        __block NSInteger startTapIndex;
        
        // 执行长按 手动配置事件 -- 开始按钮!!!!
        _viewModel.viewModel_for_HandleConfig_Block = ^(NSInteger tapIndex) {
          
            startTapIndex = tapIndex;
            
            btn = [_viewModel.terminalBtnArray objectAtIndex:startTapIndex];
            
            btn.layer.borderWidth = 2;
            btn.layer.borderColor = UIColor.blueColor.CGColor;
            
            [[Yuan_HUD shareInstance] HUDFullText:@"请再选中一个端子,作为此次关联的终点." delay:3];
            
        };
        
        
        
        // 执行长按 手动配置事件 -- 结束按钮!!!!
        _viewModel.viewModel_for_HandleConfig_END_Block = ^(NSInteger endIndex) {
            
            
            
            if (endIndex < startTapIndex) {
                
                [[Yuan_HUD shareInstance] HUDFullText:@"终点不能小于起点 , 请重新选择"];
                return ;
            }
            
            
            
            // 把刚才长按的开始按钮颜色变回去
            btn.layer.borderWidth = 0;
            btn.layer.borderColor = UIColor.clearColor.CGColor;
            
            [[Yuan_HUD shareInstance] HUDFullText:@"手动配置完成" delay:1];
            
            NSInteger allCircelCount = endIndex - startTapIndex + 1;
            
            if (allCircelCount > _viewModel.for_Circle_Count) {
                // 避免越界
                allCircelCount = _viewModel.for_Circle_Count;
            }
            
            
            for (int i = 0; i < allCircelCount; i++) {
                
                // 防止越界  -- 一定是通过 startTapIndex 起始位置来计算的
                if (startTapIndex + i > _viewModel.terminalBtnArray.count - 1) {
                    break;
                }
                
                Inc_CFConfigFiber_ItemBtn * item = [_viewModel.terminalBtnArray objectAtIndex:startTapIndex + i];
                
                [self clickDo:item];
            }
            
            // 操作完毕 None
            _viewModel.handleConfig_State = CF_ConfigHandle_None;
            
        };
         
        
        
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


/// 设置 模块内的端子个数 与排序
/// terminalCount 端子个数
/// moduleRows 盘内端子列数
/// moduleColumn 盘内端子行数
- (void) CellTerminal:(int)terminalCount
           moduleRows:(int)moduleRows
         moduleColumn:(int)moduleColumn {
    
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
        
        Inc_CFConfigFiber_ItemBtn * btn = [[Inc_CFConfigFiber_ItemBtn alloc] initWithFrame:frame];
        
        btn.index = i;
        
        btn.position = _position;
        
        // 设置 左下角数字
        [btn configMyNum:i];
        
        btn.backgroundColor = [UIColor whiteColor];
        
        [btn addTarget:self action:@selector(btnClick:)
      forControlEvents:UIControlEventTouchUpInside];
        
        btn.hidden = YES;  //默认是红色状态 , 如果有值传入 , 给他改成正常状态
        
        [self.contentView addSubview:btn];
        
        // 把所有的按钮 都放置在此数组中
        [_btnViewArray addObject:btn];
        
        //TODO:  暂时注释
        // 给viewmodel里增加这个集合  点击事件和 切换端子盘时使用
   //     [_viewModel.terminalBtnArray addObject:btn];
    }
    
    
    
    // 组成一个  position : btnarray 的map
    
    _position_btnArray_Dict = @{[NSNumber numberWithInteger:_position] :
                                    _btnViewArray};
    

}




#pragma mark - 点击事件

- (void) btnClick:(Inc_CFConfigFiber_ItemBtn *)sender {
    
    NSLog(@"-- %@",sender.dict);
    
    
    
    // 手动配置
    if (_viewModel.handleConfig_State == CF_ConfigHandle_Setting) {
        // 如果当前是手动配置工单中 , 要走手动配置流程
        
        NSInteger index = [_viewModel.terminalBtnArray indexOfObject:sender];
        
        [_viewModel Notification_HandleConfigEndIndexFromResArray:index];
        
        return;
    }
    
    
    [self clickDo:sender];
    
}



// 点击事件抽离

- (void) clickDo:(Inc_CFConfigFiber_ItemBtn *)sender {
    
    // 此处应该是把 按钮的index  和 viewModel 关联起来
    // 再把之前 点击上方纤芯的 数值 和 index 进行匹配 存在 viewModel中
    
    Yuan_CFConfigModel * postModel = [[Yuan_CFConfigModel alloc] init];
    
    // 把所有的其实终止的id 拼接map 再加入数组当中
    BOOL isSuccessJoinHttpSaveArray = [postModel joinSingleDictToLinkSaveHttpArray:sender.dict type:CF_HeaderCellType_ChengDuan];
    
    
    
    if (isSuccessJoinHttpSaveArray) {

        NSLog(@"-- %@",_viewModel.linkSaveHttpArray);
        
        
        // 遍历 viewmodel的 端子盘按钮集合
        for (Inc_CFConfigFiber_ItemBtn * btn in _viewModel.terminalBtnArray) {
            
            NSString * btn_Id = btn.dict[@"GID"];
            
            
            // 首先 先把所有的都置为空
            [btn configBindingNum:@"" from:configBindingNumFrom_Connect];
            btn.backgroundColor  = ColorValue_RGB(0xf2f2f2);
            
            
         //MARK: 步骤1  首先去看 网络请求中的数据源 , 如果刚才被覆盖 , 现在取消覆盖 , 要给他复原的
            NSString * pairNo = @"";
            
            if (_viewModel.startOrEnd == CF_VC_StartOrEndType_Start) {
                
                // 遍历起始设备数组
                pairNo = [btn circleArray:_viewModel.allStartDeviceArray
                                      myId:btn_Id];
                
            }else {
                // 遍历终止设备数组
                pairNo = [btn circleArray:_viewModel.allEndDeviceArray
                                      myId:btn_Id];
            }
            
            
            // 新增判断 ** 显示 '占'字
            // 如果 btn的GID 在 _viewModel.AnotherCableConfigTermIds_Arr 数组中.
            // 证明 他是被其他光缆段纤芯关联的 显示占
            
            if ([_viewModel.AnotherCableConfigTermIds_Arr containsObject:btn_Id]) {
                pairNo = @"占";
            }
            
            
            [btn configBindingNum:pairNo from:configBindingNumFrom_HTTP];
            
            
            
            //MARK: 步骤2  再去看 手动绑定的数组 , 如果有新操作 要覆盖之前的操作 , 优先级最高
            // **** **** **** 这一部分是通过 手动绑定的数组 给按钮赋值的呀  -- 后一步
            
            // 再通过已有的数据源 , 给每个btn 赋值 num , 以达到替换的效果
            
            for (NSDictionary * already_saveDict in _viewModel.linkSaveHttpArray) {
                //optConjunctions,resB_Id
                
                NSArray * optConjunctions = already_saveDict[@"optConjunctions"];
                NSDictionary * dict = [optConjunctions firstObject];
                
                if ([dict[@"resB_Id"] isEqualToString:btn_Id]) {
                    
                    NSString * pairNo = already_saveDict[@"pairNo"] ?:@"";
                    [btn configBindingNum:pairNo from:configBindingNumFrom_Connect];
                }
            }
        }
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
        
        
        NSNotification * info_Noti =
        [[NSNotification alloc] initWithName:Noti_DuanZiPan_msg_Error
                                      object:nil
                                    userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] postNotification:info_Noti];
        
        
        
        return;
    }
    
    
    // 进行网络请求 , 去请求当前端子对应的关联关系
    [self terminalShip_Port];
    
    
    // 正常状况下 给按钮赋值
    for (Inc_CFConfigFiber_ItemBtn * btn in _btnViewArray) {
        
        // 模块绑卡的颜色 从红色 变为 浅蓝色
        _Limit_Left.backgroundColor = ColorValue_RGB(0x9ab2cc);
        _Limit_Right.backgroundColor = ColorValue_RGB(0x9ab2cc);
        
        
        // 每个map里都有一个 position字段 , 需要根据这个position字段 与按钮的index 对应赋值
        
        for (NSDictionary * positionDict in _btnDatas) {
            // 每一个端子的dict
            
            if ([positionDict[@"position"] isEqualToString:[Yuan_Foundation fromInteger:btn.index]]) {
                btn.dict = positionDict;
                btn.hidden = NO;   //有值的时候 就显示出来
            }
        }

    }
    
    
    // 此处的cell 不需要长按手势
    // 并且有map 的时候 就要取消掉他的长按手势 , 以免有端子 还可以再继续创建
    // [self.contentView removeGestureRecognizer:_gesture];
    
}




#pragma mark -  新增 关联关系接口  ---


- (void) terminalShip_Port {
    
    NSMutableArray * termId_Arr = NSMutableArray.array;
    
    for (NSDictionary * dict in _btnDatas) {
        
        if (![dict.allKeys containsObject:@"GID"]) {
            continue;
        }
        
        // 把端子ID 放入数组中
        [termId_Arr addObject:dict[@"GID"]];
    }
    
    // 给 VM 赋值  成端的端子Id们
    _viewModel.termIds_Arr = termId_Arr;
    
    // 清空这个数组 用于存放非本光缆段关联的Id们
    [_viewModel.AnotherCableConfigTermIds_Arr removeAllObjects];
    
    // 逗号切割数组
    NSString * termIds = [termId_Arr componentsJoinedByString:@","];
    
    
    [Yuan_CF_HttpModel HttpSelectFiberReleationShipWithTermIds:termIds
                                                       Success:^(NSArray * _Nonnull data) {
        
        NSLog(@"data -- %@",data);
        
        if (data.count == 0) {
            return ;
        }
        
        for (NSDictionary * dict in data) {
            
            [self shipDict:dict];
        }
        
        for (Inc_CFConfigFiber_ItemBtn * btn in _viewModel.terminalBtnArray) {
            
            NSString * btn_Id = btn.dict[@"GID"];
            
            if ([_viewModel.AnotherCableConfigTermIds_Arr containsObject:btn_Id]) {
                [btn configBindingNum:@"占" from:configBindingNumFrom_HTTP];
            }
            
        }
        
        
    }];
    
    
}


- (void) shipDict:(NSDictionary *)dict {
    
    NSString * resId = @"";
    
    if ([dict[@"resBType"] isEqualToString:@"317"]) {
        
        // 如果当前成端端子对应的关联关系 , 不存在于本光缆段纤芯中 , 证明这是和别人关联的
        if (![_viewModel.fiberIds_Arr containsObject:dict[@"resAId"]]) {
            resId = dict[@"resBId"];
        }
    }
    
    
    if ([dict[@"resAType"] isEqualToString:@"317"]) {
        
        // 如果当前成端端子对应的关联关系 , 不存在于本光缆段纤芯中 , 证明这是和别人关联的
        if (![_viewModel.fiberIds_Arr containsObject:dict[@"resBId"]]) {
               resId = dict[@"resAId"];
        }
    }
    
    // 把非本光缆段内纤芯关联的 存放在这个数组中
    [_viewModel.AnotherCableConfigTermIds_Arr addObject:resId];
}



#pragma mark - UI *** *** *** *** *** *** *** *** ***  UI创建 不用修改

- (UILabel *)Limit_Left {
    
    if (!_Limit_Left) {
        _Limit_Left = [UIView labelWithTitle:@"1" frame:CGRectNull];
        _Limit_Left.textAlignment = NSTextAlignmentCenter;
        _Limit_Left.backgroundColor = ColorValue_RGB(0xAA0033);
        _Limit_Left.textColor = [UIColor whiteColor];
        
        // 给绑卡添加点 ·
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
        
        // 给绑卡添加点 ·
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
    [_Limit_Left autoSetDimensionsToSize:CGSizeMake(_Limit_Side, _Limit_Side)];
    
    
    
    /// 右边
    [_Limit_Right autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_Limit_Right autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [_Limit_Right autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_Limit_Right autoSetDimensionsToSize:CGSizeMake(_Limit_Side, _Limit_Side)];
    
    
    
}



@end
