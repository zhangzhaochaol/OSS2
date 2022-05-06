//
//  Inc_TerminalTipView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/7/8.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TerminalTipView.h"

//按钮倒计时时间 秒
#define sTime 5

@interface Inc_TerminalTipView () {
    
    //顶部图片和文字提示
    UILabel *_tipLbael;
    //顶部横线
    UIView *_tLine;
    //图片
    UIImageView *_imageView;
    //图片下横线
    UIView *_mLine;
    //红色提示内容
    UILabel *_redTip;
    //文字提示lable
    UILabel *_tipContent;
    //最底线
    UIView *_bLine;
    //识别按钮
    UIButton *_sureBtn;
    //取消按钮
    UIButton *_cancalBtn;

    //定时器
    dispatch_source_t _timer;
    

}

@end

@implementation Inc_TerminalTipView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        self.backgroundColor = [UIColor whiteColor];
        [self setCornerRadius:10 borderColor:UIColor.clearColor borderWidth:1];
        [self setupUI];
        
    }
    return self;
}

- (void)setupUI {
    _tipLbael = [UIView labelWithTitle:@"⚠️ 提示" frame:CGRectNull];
    _tipLbael.font =  Font_Yuan(17);
    _tipLbael.textColor = UIColor.blackColor;
    _tipLbael.textAlignment = NSTextAlignmentCenter;
    
    _tLine = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    
    //虚线使用frame
    _imageView = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"term_tip"] frame:CGRectMake(Horizontal(20), Vertical(45), ScreenWidth - 2 *Horizontal(50), Vertical(120))];
    [self addDottedBorderWithView:_imageView color:ColorR_G_B(219, 75, 78)];
    
    _redTip = [UIView labelWithTitle:@"*请正对端子盘进行拍摄，保持端子两端在取景框内。" isZheH:YES];
    _redTip.textColor = ColorR_G_B(253, 115, 108);
    _redTip.font = Font_Yuan(13);
    
    _mLine = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    
    _tipContent = [UILabel labelWithTitle:@"拍摄结束后，请将端子盘图片裁剪成如图所示状态，会提升识别的精准度。" isZheH:YES];
    _tipContent.textColor = UIColor.grayColor;
    
    _bLine = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    
    _cancalBtn = [UIView buttonWithTitle:@"取消" responder:self SEL:@selector(btnClick:) frame:CGRectNull];
    [_cancalBtn setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    [_cancalBtn setBackgroundColor:ColorR_G_B(229, 229, 229)];
    _cancalBtn.titleLabel.font =  Font_Yuan(15);
    [_cancalBtn setCornerRadius:8 borderColor:UIColor.clearColor borderWidth:1];

    
    _sureBtn = [UIView buttonWithTitle:@"立即识别" responder:self SEL:@selector(btnClick:) frame:CGRectNull];
    [_sureBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_sureBtn setBackgroundColor:ColorR_G_B(219, 75, 78)];
    _sureBtn.titleLabel.font =  Font_Yuan(15);
    [_sureBtn setCornerRadius:8 borderColor:UIColor.clearColor borderWidth:1];

    
    [self addSubviews:@[
        _tipLbael,
        _tLine,
        _imageView,
        _redTip,
        _mLine,
        _tipContent,
        _bLine,
        _cancalBtn,
        _sureBtn
    ]];
    
    [self Zhang_layouts];
}




- (void)Zhang_layouts {
 
    [_tipLbael YuanToSuper_Top:0];
    [_tipLbael YuanToSuper_Right:0];
    [_tipLbael YuanToSuper_Left:0];
    [_tipLbael autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
    
    [_tLine autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tipLbael];
    [_tLine YuanToSuper_Right:0];
    [_tLine YuanToSuper_Left:0];
    [_tLine autoSetDimension:ALDimensionHeight toSize:Vertical(1)];

    
    [_imageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tLine withOffset:Vertical(15)];
    [_imageView YuanToSuper_Right:Horizontal(20)];
    [_imageView YuanToSuper_Left:Horizontal(20)];
    [_imageView autoSetDimension:ALDimensionHeight toSize:Vertical(120)];

    
    [_redTip autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_imageView withOffset:Vertical(10)];
    [_redTip YuanToSuper_Right:Horizontal(15)];
    [_redTip YuanToSuper_Left:Horizontal(15)];
    [_redTip autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    
    [_mLine autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_redTip];
    [_mLine YuanToSuper_Right:Horizontal(15)];
    [_mLine YuanToSuper_Left:Horizontal(15)];
    [_mLine autoSetDimension:ALDimensionHeight toSize:Vertical(1)];
    
    
    [_tipContent autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_mLine];
    [_tipContent YuanToSuper_Right:Horizontal(15)];
    [_tipContent YuanToSuper_Left:Horizontal(15)];
    [_tipContent autoSetDimension:ALDimensionHeight toSize:Vertical(50)];
    
    [_bLine autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tipContent];
    [_bLine YuanToSuper_Right:0];
    [_bLine YuanToSuper_Left:0];
    [_bLine autoSetDimension:ALDimensionHeight toSize:Vertical(1)];
    
    
    [_cancalBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_bLine withOffset:Vertical(10)];
    [_cancalBtn YuanToSuper_Left:Horizontal(15)];
    [_cancalBtn autoSetDimensionsToSize:CGSizeMake(Horizontal(90), Vertical(30))];
    
    [_sureBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_bLine withOffset:Vertical(10)];
    [_sureBtn YuanToSuper_Right:Horizontal(15)];
    [_sureBtn autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_cancalBtn withOffset:Vertical(10)];
    [_sureBtn autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
    
}

//button点击
- (void)btnClick:(UIButton *)btn {
    if (self.btnBlock) {
        //点击按钮  停止倒计时
        dispatch_source_cancel(_timer);
        self.btnBlock(btn);
    }
}

//暂时没有事件
- (void)tipClick{
    
}


//开始
- (void)startTimer {
    
    [self openCountdown:sTime interval:^(NSInteger currentTime) {
        //设置按钮显示读秒效果
        [_sureBtn setTitle:[NSString stringWithFormat:@"立即识别(%zds)",currentTime] forState:UIControlStateNormal];
        NSLog( @"%ld",(long)currentTime);
    } Intervalfinish:^{
       
        //设置按钮的样式
        [_sureBtn setTitle:@"立即识别(0s)" forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.btnBlock){
                self.btnBlock(_sureBtn);
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


//添加虚线边框
-(void)addDottedBorderWithView:(UIView*)view color:(UIColor *)color{
    CGFloat viewWidth = view.width + Horizontal(10);
    CGFloat viewHeight = view.height + Vertical(10);
    view.layer.cornerRadius = 0;
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.bounds = CGRectMake(0, 0, viewWidth, viewHeight);
    borderLayer.position = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:1].CGPath;
    borderLayer.lineWidth = 1;
    borderLayer.lineDashPattern = @[@7, @3];
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = color.CGColor;
    [view.layer addSublayer:borderLayer];
}


@end
