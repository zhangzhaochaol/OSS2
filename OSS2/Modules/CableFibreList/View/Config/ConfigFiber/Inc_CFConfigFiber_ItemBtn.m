//
//  Inc_CFConfigFiber_ItemBtn.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//
//  每个 collectionView的 cell 里的 一个按钮元素

//  左下角是编号 右上角是绑定的纤芯

#import "Inc_CFConfigFiber_ItemBtn.h"
#import "Yuan_CFConfigVM.h"


@implementation Inc_CFConfigFiber_ItemBtn
{
    
    // 这个端子信息 对应的数据
    NSDictionary * _myDict;
    
    // 我自己的编号
    UILabel * _myNum;
    // 绑定的编号
    UILabel * _bindingNum;
    
    
    Yuan_CFConfigVM * _viewModel;
}


#pragma mark - 初始化构造方法

- (instancetype) initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self UI_Config];
        [self layoutAllSubViews];
        
        _viewModel = Yuan_CFConfigVM.shareInstance;
        
        /**
         *  UITapGestureRecognizer        敲击
         *  UIPinchGestureRecognizer      捏合/缩放
         *  UIPanGestureRecognizer        拖拽
         *  UISwipeGestureRecognizer      轻扫
         *  UIRotationGestureRecognizer   旋转
         *  UILongPressGestureRecognizer  长按
         */
        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]init];
        [self addGestureRecognizer:gesture];
        [gesture setMinimumPressDuration:0.3];  //长按1秒后执行事件
        [gesture addTarget:self action:@selector(gestureEvent:)];
        
    }
    return self;
}




#pragma mark -  dataSource  ---


- (void)setDict:(NSDictionary *)dict {
    
    
    //MARK: 1.首先 对端子颜色进行判断
    _myDict = dict;
    
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    NSInteger oprStateId = [dict[@"oprStateId"] integerValue];

    
    /*
        TODO:  1. 询问 为何保存后 oprStateId 还是 1 没有成功修改
        TODO:  2. 修改后 应该如何变化 按钮颜色 ??
    */
    
    switch (oprStateId) {
        case 2:     //预占
        case 4:     //预释放
        case 5:     //预留
        case 6:     //预选
        case 7:     //备用
        case 11:    //测试
        case 12:    //临时占用
            
            self.backgroundColor = ColorR_G_B(252, 160, 0);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 3:     //占用
        
            
            self.backgroundColor = ColorR_G_B(147, 222, 113);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 8:     //停用
        case 10:    //损坏
            
            self.backgroundColor = ColorR_G_B(255, 0, 44);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
            
        default:    //1.空闲 9.闲置
            
            self.backgroundColor = ColorR_G_B(232, 232, 232);
            [self setTitleColor:ColorValue_RGB(0x929292)
                       forState:UIControlStateNormal];
            break;
    }
    
    // MARK: 2 其次 需要 遍历 起始或终止设备数组里的Id 找到对应的编号 显示到右上角
    // 这一部分与ODF OCC模块不同  是光缆段纤芯独有的判断
    // 从 HTTP 请求中 拉取的数据
    
    NSString * pairNo = @"";
    
    if (_viewModel.startOrEnd == CF_VC_StartOrEndType_Start) {
        
        // 遍历起始设备数组
        
        pairNo = [self circleArray:_viewModel.allStartDeviceArray
                              myId:_myDict[@"GID"]];
        
        
    }else {
        
        
        // 遍历终止设备数组
        pairNo = [self circleArray:_viewModel.allEndDeviceArray
                              myId:_myDict[@"GID"]];
    }
    
    
    [self configBindingNum:pairNo from:configBindingNumFrom_HTTP];
    
    
    // MARK: 3. 最后 绑定的数据中拉取数据  看有没有 过去的操作
    
    for (NSDictionary * already_saveDict in _viewModel.linkSaveHttpArray) {
        //optConjunctions,resB_Id
        
        NSArray * optConjunctions = already_saveDict[@"optConjunctions"];
        NSDictionary * dict = [optConjunctions firstObject];
        
        if ([dict[@"resB_Id"] isEqualToString:_myDict[@"GID"]]) {
            
            NSString * pairNo = already_saveDict[@"pairNo"] ?:@"";
            [self configBindingNum:pairNo from:configBindingNumFrom_Connect];
        }
    }
    
    
}


- (NSDictionary *)dict {
    
    return _myDict;
}



#pragma mark -  遍历数组   ---


/// 传入起始或终止数组 返回右上角显示的数组
/// @param array 起始或终止数组
/// @param myId 我的 端子Id
- (NSString *) circleArray:(NSMutableArray *)array
                      myId:(NSString *)myId{
    
    
    NSString * pairNo = @"";
    
    
    for (NSDictionary * singleDeviceMap in array) {
        
        NSString * resId = singleDeviceMap[@"resId"];
        
        if ([resId isEqualToString:myId]) {
            pairNo = singleDeviceMap[@"pairNo"];
            break;
        }
        
    }
    
    
    return pairNo ?: @"";
    
}




/// 配置我的按钮的编号
/// @param num 编号 通过for循环创建
- (void) configMyNum:(int) num {
    
    // 显示 01 02 11 12 等两位有效数字
    _myNum.text = [NSString stringWithFormat:@"%2d",num];
    
}


/// 绑定对应的纤芯的编号
/// @param num 纤芯编号
- (void) configBindingNum:(NSString *) num
                     from:(configBindingNumFrom_)type{
    
    _bindingNum.text = num;
    
    if (type == configBindingNumFrom_HTTP) {
        _bindingNum.textColor = UIColor.orangeColor;
    }else {
        _bindingNum.textColor = ColorValue_RGB(0x3CB371);
    }
    
}



#pragma mark -  按钮的长按手势  ---

- (void) gestureEvent:(UILongPressGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
       
        
       __block NSInteger index = [_viewModel.terminalBtnArray indexOfObject:self];
        
        [self alertSmallTitle:@"是否执行自动纤芯配置"
                agreeBtnBlock:^(UIAlertAction *action) {
            
            // 自动配置
            [_viewModel viewModel_Notification_forCircleClick:index
                                                     position:self.position];
            
            
        } handleBtnBlock:^(UIAlertAction *action) {
            // 手动配置
            [_viewModel Notification_HandleConfigWithNowIndexFromResArray:index];
        }];
        
        
    }
    
}





/// 自动管理提示框
/// @param title
/// @param Autoblock 批量 block
/// @param handleBlock 手动关联 block
- (void) alertSmallTitle:(NSString *)title
           agreeBtnBlock:(void(^)(UIAlertAction *action))Autoblock
          handleBtnBlock:(void(^)(UIAlertAction * action))handleBlock {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *IKnowAction = [UIAlertAction actionWithTitle:@"批量关联" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 把点击事件回调给调用的界面
        if (Autoblock) {
            Autoblock(action);
        }
    }];
    
    
    // Create the actions.
    UIAlertAction *handleConfig = [UIAlertAction actionWithTitle:@"手动关联" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 把点击事件回调给调用的界面
        if (handleBlock) {
            handleBlock(action);
        }
    }];
    
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //什么也不做
    }];
    
    
    // Add the actions.
    [alertController addAction:IKnowAction];    //自动
    [alertController addAction:handleConfig];   //手动
    [alertController addAction:cancelAction];   //取消
    
    [[UIApplication sharedApplication].keyWindow.rootViewController
     presentViewController:alertController animated:YES completion:nil];

}







#pragma mark -  UI  ---

- (void) UI_Config {
    
    _myNum = [UIView labelWithTitle:@"01" frame:CGRectNull];
    _bindingNum = [UIView labelWithTitle:@"" frame:CGRectNull];
    
    _myNum.font = Font_Bold_Yuan(14); //加粗
    _bindingNum.font = Font_Bold_Yuan(12);
    
    _myNum.textColor = UIColor.blackColor;
    _bindingNum.textColor = ColorValue_RGB(0x3CB371);
    
    [self addSubviews:@[_myNum,_bindingNum]];
    
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    float limit = Horizontal(3);
    
    [_myNum autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_myNum autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:limit];
    
    [_bindingNum autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_bindingNum autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
}


@end
