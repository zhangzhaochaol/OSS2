//
//  Inc_BaseNav.m
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/4/20.
//

#import "Inc_BaseNav.h"

@interface Inc_BaseNav ()

@end

@implementation Inc_BaseNav

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//设置nav的主题颜色字体大小等
+ (void)initialize
{

    UIColor *systemColor = Color_H5Blue;
    
    if (IS_IPHONE_X) {
        [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -37)];
    }else{
        [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -10)];

    }
    
    [[UINavigationBar appearance] setBarTintColor:systemColor];
    [UINavigationBar appearance].shadowImage = [[UIImage alloc] init];
    [UINavigationBar appearance].translucent = YES;
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
//    [UINavigationBar appearance].barStyle = UIBarStyleDefault;
    [UINavigationBar appearance].barStyle = UIBarStyleBlack;


    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                                        NSFontAttributeName : [UIFont systemFontOfSize:11]
                                                        } forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName : systemColor,
                                                        NSFontAttributeName : [UIFont systemFontOfSize:11]
                                                        } forState:UIControlStateSelected];

    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -SafeAreaStatusBar, ScreenWidth, SafeAreaStatusBar)];
    statusBarView.backgroundColor = [UIColor clearColor];
    [[UINavigationBar appearance] addSubview:statusBarView];
    
    
    
    if (@available(iOS 15.0, *)) {

        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        //设置导航条背景色
        appearance.backgroundColor = systemColor;
        appearance.shadowColor = UIColor.clearColor;
        //设置导航条标题颜色
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setValue:UIColor.whiteColor forKey:NSForegroundColorAttributeName];
        appearance.titleTextAttributes = attributes;

        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
    }

    
    
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
    
    
    #if DEBUG
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        viewController.title = NSStringFromClass(viewController.class);

    });
    
    #endif
  
}



- (UIStatusBarStyle)preferredStatusBarStyle
{
    // 黑/白样式
//    return UIStatusBarStyleDefault;
    return UIStatusBarStyleLightContent;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
