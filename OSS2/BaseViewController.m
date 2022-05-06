//
//  BaseViewController.m
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/3/10.
//

#import "BaseViewController.h"

// GIS
#import "GisTYKMainViewController.h"


#import "Yuan_LoginService.h"
@interface BaseViewController ()

/** 登录按钮 */
@property (nonatomic , strong) UIButton * loginBtn;

/** Gis入口 */
@property (nonatomic , strong) UIButton * GisBtn;


@end

@implementation BaseViewController
{
    
    Inc_UserModel * _userModel;
    
    NSArray <UIButton *> * _btnsArr;
}





#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        
        _userModel = UserModel;
        _userModel.userName = @"0550admin";
        _userModel.passWord = @"kdyyS+7CvJrzIj2n0rePTA==";
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"hhh";
    
    [self UI_Init];
}


#pragma mark - 网络请求 ---

- (void) http_Login {
    

    
    NSDictionary * dict = @{@"username" : _userModel.userName,
                            @"password" : _userModel.passWord,
                            @"version" : [NSString stringWithFormat:@"ios/%@",@"V2.3.18"]};
    
    [Yuan_LoginService http_Login:@{@"jsonRequest":dict.json} success:^(id result) {
            
        NSDictionary * res_dict = result;
        
        NSNumber * resultNum = res_dict[@"result"];
        
        if (resultNum.intValue != 0) {
            [YuanHUD HUDFullText:res_dict[@"info"]];
            return;
        }
        
        NSDictionary * dict = res_dict[@"data"];
        [_userModel userModelConfig:dict];
        
        [Yuan_LoginService http_LoginSelectPowers:@{@"UID" : _userModel.uid}
                                          success:^(id result) {
        
            NSDictionary * resultDict = result;
            
            // 证明权限请求成功了
            if (resultDict[@"data"]) {
                
                NSDictionary * data = resultDict[@"data"];
                
                [_userModel userPowerConfig:data];
                
                NSLog(@"权限请求成功");
            }
            
        }];
        
    }];
    
}




/// Gis 登录入口
- (void) gisClick {
    
    GisTYKMainViewController * gis = [[GisTYKMainViewController alloc] init];
    Push(self, gis);
}


#pragma mark - btnClick ---

- (void) loginClick {
    
    [UIAlert alertSmallTitle:@"是否登录"
               agreeBtnBlock:^(UIAlertAction *action) {
            
        [self http_Login];
    }];
    
}


#pragma mark - UI_Init

- (void) UI_Init {
    
    _loginBtn = [UIView buttonWithTitle:@"登录流程"
                              responder:self
                                    SEL:@selector(loginClick)
                                  frame:CGRectNull];
    
    [_loginBtn setTitleColor:UIColor.whiteColor forState:0];
    _loginBtn.backgroundColor = UIColor.mainColor;
    
    
    _GisBtn = [UIView buttonWithTitle:@"Gis入口"
                            responder:self
                                  SEL:@selector(gisClick)
                                frame:CGRectNull];
    
    [_GisBtn setTitleColor:UIColor.whiteColor forState:0];
    _GisBtn.backgroundColor = UIColor.systemBlueColor;
    
    _btnsArr = @[_loginBtn,_GisBtn];
    
    
    [self.view addSubviews:_btnsArr];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_loginBtn YuanToSuper_Top:NaviBarHeight + 5];
    
    [_GisBtn YuanMyEdge:Top ToViewEdge:Bottom ToView:_loginBtn inset:limit * 2];
    
    
    for (UIView * view in _btnsArr) {
        [view YuanToSuper_Left:limit];
        [view YuanToSuper_Right:limit];
        [view Yuan_EdgeHeight:Vertical(45)];
    }
    
    
    
}

@end
