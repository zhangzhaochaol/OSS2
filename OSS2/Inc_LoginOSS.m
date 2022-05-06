//
//  Inc_LoginOSS.m
//  OSS2
//
//  Created by yuanquan on 2022/4/28.
//

#import "Inc_LoginOSS.h"
#import "Increase_OSS2_HomeVC.h"
#import "Inc_BaseNav.h"

@implementation Inc_LoginOSS

+ (void) Login_OSS:(UIViewController *) vc
             datas:(NSDictionary *) data {
    
    Increase_OSS2_HomeVC * base = [[Increase_OSS2_HomeVC alloc] initWithLoginDatas:data];
        
//    [self setlocalNav:vc.navigationController];

    [vc.navigationController pushViewController:base animated:YES];
    
    
}

+(void)setlocalNav:(UINavigationController *)nav{
    
    UIColor *systemColor = Color_H5Blue;

    if (IS_IPHONE_X) {
        [nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -37)];
    }else{
        [nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -10)];

    }
    
    [nav.navigationBar setBarTintColor:systemColor];
    nav.navigationBar.shadowImage = [[UIImage alloc] init];
    nav.navigationBar.translucent = YES;
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    
    
    [nav.tabBarItem setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                                        NSFontAttributeName : [UIFont systemFontOfSize:11]
                                                        } forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName : systemColor,
                                                        NSFontAttributeName : [UIFont systemFontOfSize:11]
                                                        } forState:UIControlStateSelected];

    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -SafeAreaStatusBar, ScreenWidth, SafeAreaStatusBar)];
    statusBarView.backgroundColor = [UIColor clearColor];
    [nav.navigationBar addSubview:statusBarView];
    
    
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
        
        // UINavigationBarAppearance 会覆盖原有的导航栏设置，这里需要重新设置返回按钮隐藏
//        appearance.backButtonAppearance.normal.titlePositionAdjustment = UIOffsetMake(NSIntegerMin, 0);
        
        
        nav.navigationBar.standardAppearance = appearance;
        nav.navigationBar.scrollEdgeAppearance = appearance;
    }

   
}

@end
