//
//  Inc_DeviceInfoTipView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/8/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_DeviceInfoTipView.h"

@interface Inc_DeviceInfoTipView ()

{
    //标题
    UILabel *_tip;
    //提示内容1
    UILabel *_label1;
    
    //线
    UIView *_line;
    
    //提示内容2
    UILabel *_label2;
    //确认
    UIButton *_btn;

    //定时器
    dispatch_source_t _timer;
}

@end

@implementation Inc_DeviceInfoTipView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    
        self.backgroundColor = UIColor.whiteColor;
        [self setCornerRadius:8 borderColor:UIColor.clearColor borderWidth:1];
        [self createUI];
        
        [self openCountdown:5 interval:^(NSInteger currentTime) {
            //设置按钮显示读秒效果
            [_btn setTitle:[NSString stringWithFormat:@"我知道了(%zds)",currentTime] forState:UIControlStateNormal];
            NSLog( @"%ld",(long)currentTime);
        } Intervalfinish:^{
           
            //设置按钮的样式
            [_btn setTitle:@"我知道了" forState:UIControlStateNormal];

            if(self.btnSureBlock){
                self.btnSureBlock();
            }
        }];
        
        [self zhang_Autolayout];

    }
    return self;
}

- (void)createUI {
    
    _tip = [UIView labelWithTitle:@"复制设备" frame:CGRectNull];
    _tip.font = Font_Bold_Yuan(17);
    _tip.textColor = UIColor.blackColor;
    _tip.textAlignment = NSTextAlignmentCenter;
    
    
    _label1 = [UIView labelWithTitle:@"1.复制设备会复制设备的基础信息，但是请手动填写设备名称、编码、地址等唯一性内容。" isZheH:YES];
    
    NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc] initWithString:_label1.text];

    [text1 addAttribute:NSForegroundColorAttributeName value:ColorR_G_B(255, 91, 90) range:[_label1.text rangeOfString:@"名称、编码、地址"]];
    
    _label1.attributedText  =  text1;

    _line = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    
    
    _label2 = [UIView labelWithTitle:@"2.复制设备会复制设备的子框、模块、端子等资源的数量和排列方式，不会复制详细信息。" isZheH:YES];

    NSMutableAttributedString *text2 = [[NSMutableAttributedString alloc] initWithString:_label2.text];

    [text2 addAttribute:NSForegroundColorAttributeName value:ColorR_G_B(255, 91, 90) range:[_label2.text rangeOfString:@"子框、模块、端子"]];
    
    _label2.attributedText  =  text2;

    
    _btn = [UIView buttonWithTitle:@"我知道了" responder:self SEL:@selector(btnClick) frame:CGRectNull];
    _btn.titleLabel.font = Font_Yuan(16);
    _btn.backgroundColor  = ColorR_G_B(255, 91, 90);
    [_btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_btn setCornerRadius:Vertical(40)/2 borderColor:UIColor.clearColor borderWidth:1];
    
    
    [self addSubviews:@[_tip,
                        _label1,
                        _line,
                        _label2,
                        _btn]];
    
    
}


- (void)zhang_Autolayout{
    
    CGFloat offset =  Vertical(10);
    
    [_tip YuanToSuper_Top:offset];
    [_tip YuanToSuper_Left:0];
    [_tip YuanToSuper_Right:0];
    [_tip autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
    
    [_label1 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tip withOffset:offset];
    [_label1 YuanToSuper_Left:offset];
    [_label1 YuanToSuper_Right:offset];
    
    [_line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_label1 withOffset:offset];
    [_line YuanToSuper_Left:offset];
    [_line YuanToSuper_Right:offset];
    [_line autoSetDimension:ALDimensionHeight toSize:1];
    
    [_label2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_line withOffset:offset];
    [_label2 YuanToSuper_Left:offset];
    [_label2 YuanToSuper_Right:offset];
    
    
    [_btn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_label2 withOffset:offset];
    [_btn YuanToSuper_Left:offset*4];
    [_btn YuanToSuper_Right:offset*4];
    [_btn autoSetDimension:ALDimensionHeight toSize:Vertical(40)];

    

}


- (void)btnClick{
    if (self.btnSureBlock) {
        self.btnSureBlock();
    }
}



-(void)openCountdown:(NSInteger)interval interval:(void(^)(NSInteger currentTime))current Intervalfinish:(dispatch_block_t)finish{

    __block NSInteger time = interval;//倒计时时间

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0, queue);

    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行

    dispatch_source_set_event_handler(_timer, ^{

        if(time <=0){//倒计时结束，关闭

            dispatch_source_cancel(_timer);

            dispatch_async(dispatch_get_main_queue(), ^{

                if(finish){//设置按钮的样式

                    finish();

                }

            });
        }else{
            int seconds = time %60;
            dispatch_async(dispatch_get_main_queue(), ^{

                if(current){//设置按钮的样式

                    current(seconds);

                }
            });
            time--;
        }
    });
    dispatch_resume(_timer);

}

@end
