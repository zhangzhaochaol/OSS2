//
//  Inc_BaseVC.m
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/4/20.
//

#import "Inc_BaseVC.h"

@interface Inc_BaseVC ()
{
    
    //h5 导航样式 右侧按钮
    UIView *_rightView;
    
}

@end

@implementation Inc_BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
        
    [self setRightItem];
    
    
    self.navigationController.navigationItem.backButtonTitle = @"4";

    
//    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithImage:[UIImage Inc_imageNamed:@"zzc_icon_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backClick)];
    
}


-(void)setRightItem {
    
    _rightView = [UIView viewWithColor:Color_H5Blue];
    _rightView.frame = CGRectMake(0, 0, 70, 30);
    [_rightView setCornerRadius:_rightView.height/2.0 borderColor:UIColor.whiteColor borderWidth:1.5];
    
    UIButton *moreBtn = [UIView buttonWithImage:@"h5_more" responder:self SEL_Click:@selector(moreBtnClick:) frame:CGRectMake(8, 5, 20, 20)];
    
    UIView *lineView = [UIView viewWithColor:UIColor.whiteColor];
    lineView.frame = CGRectMake(_rightView.width/2, 7, 1, 16);
    
    UIButton *closeBtn = [UIView buttonWithImage:@"h5_close" responder:self SEL_Click:@selector(closeBtnClick) frame:CGRectMake(42, 5, 20, 20)];

    [_rightView addSubviews:@[moreBtn,lineView,closeBtn]];
    

    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc]initWithCustomView:_rightView];
    self.navigationItem.rightBarButtonItem = rightBar;
    
        
}

#pragma  mark -btnClick

-(void)moreBtnClick:(UIButton *)btn{
    
    if (self.moreBtnBlock) {
        self.moreBtnBlock(btn);
    }
}

-(void)closeBtnClick {
    
    NSLog(@"退出SDk，返回H5页面");
    
    [self.navigationController popViewControllerAnimated:YES];
//    if (self.closeBtnBlock) {
//        self.closeBtnBlock();
//    }
    
}

-(void)backClick {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
