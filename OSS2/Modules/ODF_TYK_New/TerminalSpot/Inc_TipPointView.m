//
//  Inc_TipPointView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/7/8.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TipPointView.h"

@interface Inc_TipPointView () {
  
    //箭头
    UIImageView *_tipImage;
    
    //白色背景
    UIView *_whiteView;
    //文字
    UILabel *_tipLabel;
    //倒计时按钮
    UIButton *_button;
    
    
    //定时器
    dispatch_source_t _timer;
}

@end

@implementation Inc_TipPointView



-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
      
        [self openCountdown:5 interval:^(NSInteger currentTime) {
            //设置按钮显示读秒效果
            [_button setTitle:[NSString stringWithFormat:@"好的,我知道了(%zds)",currentTime] forState:UIControlStateNormal];
            NSLog( @"%ld",(long)currentTime);
        } Intervalfinish:^{
           
            //设置按钮的样式
            [_button setTitle:@"好的,我知道了" forState:UIControlStateNormal];

            if(self.btnBlock){
                self.btnBlock();
            }
        }];
        
    }
    return self;
}

- (void)setupUI {
    
    _tipImage = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"tip_point"] frame:CGRectNull];
    
    _whiteView = [UIView viewWithColor:UIColor.whiteColor];
    [_whiteView setCornerRadius:8 borderColor:UIColor.clearColor borderWidth:1];
    
    _tipLabel = [UIView labelWithTitle:@"新增端子识别功能" frame:CGRectNull];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    
    _button = [UIView buttonWithTitle:@"" responder:self SEL:@selector(sureClcik) frame:CGRectNull];
    [_button setCornerRadius:Vertical(30)/2 borderColor:UIColor.redColor borderWidth:1];
    [_button setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    _button.titleLabel.font = Font_Yuan(13);
    
    [self addSubviews:@[_tipImage,_whiteView]];
    [_whiteView addSubviews:@[_tipLabel,_button]];
    
    [self Zhang_layouts];
}


- (void)Zhang_layouts {
 
    [_tipImage YuanToSuper_Top:Vertical(0)];
    [_tipImage YuanToSuper_Right:Horizontal(30)];
    
    [_whiteView YuanToSuper_Right:Horizontal(45)];
    [_whiteView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tipImage withOffset:0];
    [_whiteView autoSetDimensionsToSize:CGSizeMake(Horizontal(170), Vertical(80))];
    
    [_tipLabel YuanToSuper_Top:0];
    [_tipLabel YuanToSuper_Right:0];
    [_tipLabel YuanToSuper_Left:0];
    [_tipLabel autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    
    [_button autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
    [_button autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tipLabel];
    [_button YuanToSuper_Right:Horizontal(20)];
    [_button YuanToSuper_Left:Horizontal(20)];
    
}


- (void)sureClcik {
    
    if (self.btnBlock) {
        //点击按钮  停止倒计时
        dispatch_source_cancel(_timer);
        self.btnBlock();
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
