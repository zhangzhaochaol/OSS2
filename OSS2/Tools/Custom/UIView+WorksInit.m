//
//  UIView+WorksInit.m
//  helloworld
//
//  Created by 袁全 on 2020/2/21.
//  Copyright © 2020 Ryan Treem. All rights reserved.
//

#import "UIView+WorksInit.h"

@implementation UIView (WorksInit)


#pragma mark ---  mapView  ---

+ (MAMapView *) mapViewAndDelegate:(id <MAMapViewDelegate>)delegate
                             frame:(CGRect)frame{
    
    MAMapView * map;
    
    map = [[MAMapView alloc] initWithFrame:frame];
    
    
    if ([delegate conformsToProtocol:@protocol(MAMapViewDelegate)]) {
        [map setDelegate:delegate];
    }
    
    //是否显示指南针
    [map setShowsCompass:NO];
    
    //是否显示比例尺
    [map setShowsScale:YES];
    
    //设置缩放级别
    [map setZoomLevel:15];
    
    //是否显示用户位置
    map.showsUserLocation = YES;

    //设置导航模式为跟随
    map.userTrackingMode = MAUserTrackingModeFollow ;
    
    return map;
}



#pragma mark - view init

+ (UIView *) viewWithColor:(UIColor *)color {
    
    UIView * view = [[UIView alloc] init];
    
    view.backgroundColor = color;
    
    return view;
}


#pragma mark - label init

+ (UILabel *) labelWithTitle:(NSString *)title
                       frame:(CGRect)frame {
    
    
    UILabel * label ;
    
    label = [[UILabel alloc] initWithFrame:frame];
    
    label.text = title;
    
    label.font = [UIFont systemFontOfSize:14];
    
    label.textColor = ColorValue_RGB(0x333333);
    
    label.numberOfLines = 0;//根据最大行数需求来设置
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    
//    label.textAlignment = NSTextAlignmentCenter;
    
//    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20]; //加粗
    return label;
}


+ (UILabel *) labelWithTitle:(NSString *) title isZheH:(BOOL) isZheH {
    
    
    UILabel * label ;
    
    label = [[UILabel alloc] initWithFrame:CGRectNull];
    
    label.text = title;
    
    label.font = [UIFont systemFontOfSize:14];
    
    label.textColor = ColorValue_RGB(0x333333);
    
    if (isZheH) {
        label.numberOfLines = 0;//根据最大行数需求来设置
        label.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return label;
}





#pragma mark - button init

+ (UIButton *) buttonWithTitle:(NSString *)title
                    responder :(id) weakSelf
                           SEL:(SEL)target
                         frame:(CGRect)frame {
    
    UIButton * button ;
    
    button = [[UIButton alloc] initWithFrame:frame];
    
    if ([weakSelf respondsToSelector:target]) {
        //如果 weakSelf 实现了target方法
        //防止 闪退
        [button addTarget:weakSelf action:target forControlEvents:UIControlEventTouchUpInside];
    }
    
    button.titleLabel.font = Font_Yuan(14);
                             
    [button setTitle:title forState:UIControlStateNormal];
                             
                             
    [button setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1] forState:UIControlStateNormal];
    
    return button;
}



+ (UIButton *) buttonWithImage:(NSString *)imgNamed
                    responder :(id) weakSelf
                     SEL_Click:(SEL)target
                         frame:(CGRect)frame {
    
    UIButton * button ;
    button = [[UIButton alloc] initWithFrame:frame];
    
    if ([weakSelf respondsToSelector:target]) {
        //如果 weakSelf 实现了target方法
        //防止 闪退
        [button addTarget:weakSelf action:target forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (imgNamed.length > 0) {    
        [button setImage:[UIImage Inc_imageNamed:imgNamed]
                forState:UIControlStateNormal];
    }
    
    return button;
    
}


+ (UIButton *) button_V2_Title:(NSString *)title
                    responder :(id) weakSelf
                           SEL:(SEL)target
                         frame:(CGRect)frame {
    
    UIButton * button ;
    
    button = [[UIButton alloc] initWithFrame:frame];
    
    if ([weakSelf respondsToSelector:target]) {
        //如果 weakSelf 实现了target方法
        //防止 闪退
        [button addTarget:weakSelf action:target forControlEvents:UIControlEventTouchUpInside];
    }
    
    button.titleLabel.font = Font_Yuan(14);
                             
    [button setTitle:title forState:UIControlStateNormal];
                             
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button cornerRadius:5 borderWidth:0 borderColor:nil];
    button.backgroundColor = UIColor.mainColor;
                             
    
    return button;
}


#pragma mark - imageView init

+ (UIImageView *) imageViewWithImg:(UIImage *)img
                             frame:(CGRect)frame {
    
    
    UIImageView * imageV ;
    
    imageV = [[UIImageView alloc] initWithFrame:frame];
    
    imageV.image = img;

//    self.imageView.contentMode =UIViewContentModeScaleAspectFit;
    
    return imageV;
}

#pragma mark - textField


+ (UITextField *) textFieldFrame:(CGRect)frame {
    
    UITextField * textField = [[UITextField alloc] initWithFrame:frame];
    
//    textField.backgroundColor = UIColor.whiteColor;
    
    textField.font = [UIFont systemFontOfSize:14];
    
    textField.textColor = ColorValue_RGB(0x333333);
    
    textField.tintColor = ColorValue_RGB(0x68C5F0);
    
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    // 左侧 留白
    
    UILabel *paddingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 25)];

    paddingView.text = @" ";

    paddingView.textColor = [UIColor darkGrayColor];

    paddingView.backgroundColor = [UIColor clearColor];

    textField.leftView = paddingView;

    textField.leftViewMode = UITextFieldViewModeAlways;
    
    
    return textField;
}


#pragma mark - tableview


+ (UITableView *) tableViewDelegate:(id)delegate
                      registerClass:(Class)registerClass
                CellReuseIdentifier:(NSString *)ID {
    
    
    UITableView * tableView = [[UITableView alloc] init];
    
    tableView.backgroundColor = UIColor.whiteColor;
    if ([[delegate class] conformsToProtocol:@protocol(UITableViewDataSource)]&&
        [delegate respondsToSelector:@selector(tableView: numberOfRowsInSection:)] &&
        [delegate respondsToSelector:@selector(tableView: cellForRowAtIndexPath:)]) {
     
        // 判断该类 是否遵循了 UITableViewDataSource 协议
        // 如果该tableview实现类 实现了 DataSource两个元数据方法的话
        // 让这个类做 tableView的代理
        tableView.delegate = delegate;
        tableView.dataSource = delegate;
    }
    
 
    [tableView registerClass:registerClass forCellReuseIdentifier:ID];
    
    if (@available(iOS 15.0, *)) {
        tableView.sectionHeaderTopPadding = 0;
    }
    
    //  遮挡没有用的线
    
    UIView *view = [[UIView alloc] init];
    
    view.backgroundColor = [UIColor clearColor];
    
    [tableView setTableFooterView:view];
    
    return tableView;
}



+ (UICollectionView *) collectionDatasource:(id)delegate
                              registerClass:(Class)registerClass
                        CellReuseIdentifier:(NSString *)ID flowLayout:(UICollectionViewFlowLayout *) flowLayout{
    
    
    UICollectionView * collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    
    collection.backgroundColor = [UIColor whiteColor];
    
    if (@available(iOS 11.0, *)) {
        collection.contentInsetAdjustmentBehavior = NO;
    } else {
        // Fallback on earlier versions
    }
    
    collection.showsHorizontalScrollIndicator = NO;
    collection.delegate = delegate;
    collection.dataSource = delegate;
    [collection registerClass:registerClass forCellWithReuseIdentifier:ID];
    
    
    return collection;
}



#pragma mark - 导航栏按钮 *** ***
/**
    UIBarButtonItem * edit =
    [UIView getBarButtonItemWithView:editBtn
                                 Sel:@selector(editClick) VC:self];
    
    
    self.navigationItem.leftBarButtonItems = @[back,edit];
 */

+ (UIBarButtonItem *)getBarButtonItemWithTitleStr:(NSString *)titleStr
                                              Sel:(SEL)sel
                                               VC:(UIViewController *)VC{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:titleStr forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:VC action:sel forControlEvents:UIControlEventTouchUpInside];
    //btn.size = CGSizeMake(23, 23);
    //[btn sizeToFit];
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    return btnItem;
}



+ (UIBarButtonItem *)getBarButtonItemWithImageName:(NSString *)imageName
                                               Sel:(SEL)sel
                                                VC:(UIViewController *)VC{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn setBackgroundImage:[UIImage Inc_imageNamed:imageName] forState:UIControlStateNormal];

    [btn addTarget:VC action:sel forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return btnItem;
}


+ (UIBarButtonItem *)getBarButtonItemWithView:(UIButton *)btn
                                          Sel:(SEL)sel
                                           VC:(UIViewController *)VC{
    

    [btn addTarget:VC action:sel forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return btnItem;
}




#pragma mark -  WKWebView  ---


+ (WKWebView *) webViewURL:(NSString *)URL
                  delegate:(id<WKUIDelegate ,WKNavigationDelegate>) delegate
                     frame:(CGRect)frame{
    
    WKWebView * webView = [[WKWebView alloc] initWithFrame:frame];
    
    webView.UIDelegate = delegate;
    webView.navigationDelegate = delegate;
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    [webView loadRequest:request];
    
    return webView;
}



- (void) addSubviews:(NSArray <__kindof UIView *> *)subviews {
    
    [subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj,
                                           NSUInteger idx,
                                           BOOL * _Nonnull stop) {
       
        [self addSubview:obj];
    }];
    
}

@end
