//
//  Inc_CountdownTipsView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CountdownTipsView.h"

@interface Inc_CountdownTipsView ()

{
    
    //提示标题
    UILabel *_titleL;
    //内容
    UILabel *_msgL;
    //确定按钮
    UIButton *_sureBtn;
    //取消按钮
    UIButton *_cancalBtn;

    //定时器
    dispatch_source_t _timer;
    

    NSString *_title;
    NSString *_msg;
    int _time;
}

@end


@implementation Inc_CountdownTipsView

-(instancetype)initWithFrame:(CGRect)frame title:(NSString*)title message:(NSString *)msg time:(int)time {
    
    if (self = [super initWithFrame:frame]) {

        self.backgroundColor = [UIColor whiteColor];
        [self setCornerRadius:10 borderColor:UIColor.clearColor borderWidth:1];

        _title = title;
        _msg = msg;
        _time = time;
        
        [self setupUI];
        
    }
    return self;
    
}

- (void)setupUI {
    
    
    _titleL = [UIView labelWithTitle:_title isZheH:YES];
    _titleL.font = Font_Bold_Yuan(17);
    _titleL.textAlignment = NSTextAlignmentCenter;
    _titleL.textColor = UIColor.blackColor;
    
    
    _msgL = [UIView labelWithTitle:_msg isZheH:YES];

    
    _sureBtn = [UIView buttonWithTitle:@"" responder:self SEL:@selector(sureClick:) frame:CGRectNull];
    [_sureBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _sureBtn.backgroundColor = ColorR_G_B(219, 75, 78);
    [_sureBtn setCornerRadius:Vertical(30)/2.0 borderColor:UIColor.clearColor borderWidth:1];
    
    
    
    _cancalBtn = [UIView buttonWithTitle:@"" responder:self SEL:@selector(cancelClick:) frame:CGRectNull];
    [_cancalBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_cancalBtn setCornerRadius:Vertical(30)/2.0 borderColor:UIColor.clearColor borderWidth:1];
    _cancalBtn.backgroundColor = UIColor.lightGrayColor;

    
    [self addSubviews:@[
    _titleL,
    _msgL,
    _sureBtn,
    _cancalBtn]];

}


- (void)zhangAutolayout {
    
    [_titleL YuanToSuper_Top:0];
    [_titleL YuanToSuper_Left:0];
    [_titleL YuanToSuper_Right:0];
    [_titleL autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    
    
    [_msgL autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleL];
    [_msgL YuanToSuper_Left:10];
    [_msgL YuanToSuper_Right:10];
    [_msgL autoSetDimension:ALDimensionHeight toSize:Vertical(40)];

//    [_cancalBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_msgL withOffset:10];
//    [_cancalBtn YuanToSuper_Left:10];
//    [_cancalBtn autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
//    [_cancalBtn YuanToSuper_Bottom:10];
//    [_cancalBtn autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:_sureBtn withOffset:-10];
//    [_cancalBtn autoSetDimension:ALDimensionWidth toSize:(self.width - 20 - 10)/2];

    
    [_sureBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_msgL withOffset:10];
    [_sureBtn YuanToSuper_Right:10];
    [_sureBtn YuanToSuper_Left:10];
    [_sureBtn autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
    [_sureBtn YuanToSuper_Bottom:10];
    
    
    CGFloat height = Vertical(30) + Vertical(40)*2 + 10*2;
    if (self.heightBlock) {
        self.heightBlock(height);
    }

}


#pragma mark --btnClick

//确定
- (void)sureClick:(UIButton *)btn {
    if (self.sureBlock) {
        //点击按钮  停止倒计时
        dispatch_source_cancel(_timer);
        
        self.sureBlock();
    }
}


//取消
- (void)cancelClick:(UIButton *)btn {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}



//开始
- (void)startTimer {
    
    [self zhangAutolayout];

    [self openCountdown:_time interval:^(NSInteger currentTime) {
//        _cancalBtn.enabled = NO;
        //设置按钮显示读秒效果
        [_sureBtn setTitle:[NSString stringWithFormat:@"确定(%zds)",currentTime] forState:UIControlStateNormal];
//        _cancalBtn.backgroundColor = UIColor.lightGrayColor;

    } Intervalfinish:^{
       
//        _cancalBtn.enabled = YES;
        //设置按钮的样式
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
//        _cancalBtn.backgroundColor = ColorR_G_B(219, 75, 78);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.sureBlock) {
                self.sureBlock();
            }
        });
        
    }];
}

- (void)stopTimer {
    //停止
    dispatch_source_cancel(_timer);
}

//倒计时
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
