//
//  Yuan_ConfigCableCollectionItem.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_ConfigCableCollectionItem.h"

#import "Yuan_CFConfigVM.h"

@interface Yuan_ConfigCableCollectionItem ()

/** 我的编号 */
@property (nonatomic,strong) UILabel *myNum;

/** 绑定的编号 */
@property (nonatomic,strong) UILabel *bindingNum;

@end

@implementation Yuan_ConfigCableCollectionItem

{
    
    UIImageView * _upImg;
    UIImageView * _downImg;
    
    Yuan_CFConfigVM * _viewModel;
}


#pragma mark - 初始化构造方法

- (instancetype) initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.backgroundColor = ColorValue_RGB(0xf2f2f2);
        
        _myNum = [UIView labelWithTitle:@"01" frame:CGRectNull];
        _myNum.textColor = UIColor.blackColor;
        _myNum.font = Font_Bold_Yuan(14);
        
        _bindingNum = [UIView labelWithTitle:@"   " frame:CGRectNull];
        _bindingNum.font = Font_Bold_Yuan(12);
        _bindingNum.textColor = ColorR_G_B(0, 225, 109);
        
        _upImg = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"cf_lan_shang"]
                                    frame:CGRectNull];
        
        _downImg = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"cf_lan_xia"]
                                      frame:CGRectNull];
        
        [self.contentView addSubviews:@[_myNum,_bindingNum,_upImg,_downImg]];
        [self layoutAllSubViews];
        
        _viewModel = Yuan_CFConfigVM.shareInstance;
        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]init];
        [self addGestureRecognizer:gesture];
        [gesture setMinimumPressDuration:0.3];  //长按1秒后执行事件
        
        // 非楼宇模式下 才使用长按功能 2020.12.15新增
        if (!_viewModel.isBuildingMode) {
            [gesture addTarget:self action:@selector(gestureEvent:)];
        }
        
        
    }
    return self;
}




/// 左上角图片 是成端还是熔接
- (void) imgConfigUpImage:(CF_HeaderCellType_)upType {
    
    _upImg.hidden = NO;
    
    if (upType == CF_HeaderCellType_ChengDuan) {
        _upImg.image = [UIImage Inc_imageNamed:@"cf_lan_shang"];
    }else if(upType == CF_HeaderCellType_RongJie){
        _upImg.image = [UIImage Inc_imageNamed:@"cf_hong_shang"];
    }else {
        
        _upImg.hidden = YES;
    }
    
}


/// 右下角图片 是成端还是熔接
- (void) imgConfigDownImg:(CF_HeaderCellType_)downType {
    
    _downImg.hidden = NO;
    
    if (downType == CF_HeaderCellType_ChengDuan) {
        _downImg.image = [UIImage Inc_imageNamed:@"cf_lan_xia"];
    }else if(downType == CF_HeaderCellType_RongJie){
        _downImg.image = [UIImage Inc_imageNamed:@"cf_hong_xia"];
    }else {
        _downImg.hidden = YES;
    }
    
}



- (void) configNum:(NSString *)index {
    
    _myNum.text = index;
}


- (void) configBindNum : (NSString *)pairNo from:(configBindingNumFrom_)type{
    
    _bindingNum.text = pairNo;
    
    if (type == configBindingNumFrom_HTTP) {
        _bindingNum.textColor = UIColor.orangeColor;
    }else {
        _bindingNum.textColor = ColorR_G_B(0, 225, 109);
    }
}






#pragma mark -  按钮的长按手势  ---

- (void) gestureEvent:(UILongPressGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        
        __block NSInteger index = [_viewModel.connectionItemArray indexOfObject:self];
        
        
        [self alertSmallTitle:@"是否执行自动纤芯配置"
                agreeBtnBlock:^(UIAlertAction *action) {
            
            // 去自动配置
            [_viewModel viewModel_Notification_forCircleClick:index position:0];
            
            
        } handleBtnBlock:^(UIAlertAction *action) {
            
            // 去手动配置
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




#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    float limit = Horizontal(3);
    
    [_myNum autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_myNum autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:limit];
    
    [_bindingNum autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_bindingNum autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
    
    [_upImg autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_upImg autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    
    [_downImg autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_downImg autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
}

@end
