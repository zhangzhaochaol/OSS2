//
//  UIView+WorksInit.h
//  helloworld
//
//  Created by 袁全 on 2020/2/21.
//  Copyright © 2020 Ryan Treem. All rights reserved.
//

#import <UIKit/UIKit.h>

//Map
#import "Yuan_AMap.h"

#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface UIView (WorksInit)


+ (MAMapView *) mapViewAndDelegate:(id <MAMapViewDelegate>)delegate
                             frame:(CGRect)frame;


+ (UIView *) viewWithColor:(UIColor *)color;


+ (UILabel *) labelWithTitle:(NSString *)title
                       frame:(CGRect)frame;

+ (UILabel *) labelWithTitle:(NSString *) title
                      isZheH:(BOOL) isZheH;


+ (UIButton *) buttonWithTitle:(NSString *)title
                    responder :(id) weakSelf
                           SEL:(SEL)target
                         frame:(CGRect)frame;


+ (UIButton *) buttonWithImage:(NSString *)imgNamed
                    responder :(id) weakSelf
                     SEL_Click:(SEL)target
                         frame:(CGRect)frame;


+ (UIButton *) button_V2_Title:(NSString *)title
                     responder:(id) weakSelf
                           SEL:(SEL)target
                         frame:(CGRect)frame;



+ (UIImageView *) imageViewWithImg:(UIImage *)img
                             frame:(CGRect)frame;


+ (UITextField *) textFieldFrame:(CGRect)frame;



+ (UITableView *) tableViewDelegate:(id)delegate
                      registerClass:(Class)registerClass
                CellReuseIdentifier:(NSString *)ID;



/**
    param : flowLayout : 控制collection的item的大小与流向.
 */
+ (UICollectionView *) collectionDatasource:(id)delegate
                              registerClass:(Class)registerClass
                        CellReuseIdentifier:(NSString *)ID
flowLayout:(UICollectionViewFlowLayout *) flowLayout;




+ (UIBarButtonItem *)getBarButtonItemWithTitleStr:(NSString *)titleStr
                                              Sel:(SEL)sel
                                               VC:(UIViewController *)VC;



+ (UIBarButtonItem *)getBarButtonItemWithImageName:(NSString *)imageName
                                               Sel:(SEL)sel
                                                VC:(UIViewController *)VC;



+ (UIBarButtonItem *)getBarButtonItemWithView:(UIButton *)btn
                                          Sel:(SEL)sel
                                           VC:(UIViewController *)VC;




+ (WKWebView *) webViewURL:(NSString *)URL
                  delegate:(id<WKUIDelegate ,WKNavigationDelegate>) delegate
                     frame:(CGRect)frame;


- (void) addSubviews:(NSArray *)subviews;

@end

NS_ASSUME_NONNULL_END
