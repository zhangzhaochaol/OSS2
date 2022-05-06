//
//  Increase_OSS2_HomeVC.m
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/3/10.
//

#import "Increase_OSS2_HomeVC.h"


// 服务
#import <WebKit/WebKit.h>
#import "Yuan_LoginService.h"
#import "Inc_WKWebViewJavascriptBridge.h"
#import "Increase_Foundations.h"
#import "Increase_CaremaVC.h"
#import "Increase_ScanVC.h"


// 业务
#import "Inc_OSS2_VM.h"





static NSString * _url = @"http://115.28.188.220:8080/inc-intelligence-network-manage?user=wuy32";
//static NSString * _url = @"http://192.168.1.32:8848?user=wuy32";
//static NSString * _url = @"http://459z15i671.zicp.vip?user=wuy32";

@interface Increase_OSS2_HomeVC ()
<

    WKUIDelegate ,
    WKNavigationDelegate,

    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate ,
    AMapNaviCompositeManagerDelegate
>

/** webView */
@property (nonatomic , strong) WKWebView * webView;

/** bridge */
@property (nonatomic , strong) Inc_WKWebViewJavascriptBridge * webViewBridge;


@property (nonatomic,strong) AMapNaviCompositeManager *compositeManager;

/** 定位 */
@property (nonatomic , strong) AMapLocationManager * locationManager;



@end

@implementation Increase_OSS2_HomeVC

{
    // 当前正在执行的回调
    Inc_WVJBResponseCallback _nowCallBack;
    
    // 当前正在执行的是什么操作
    JsToOC_ _nowEnum;
    
    NSDictionary * _loginDict;
    
    Inc_UserModel * _userModel;
    Inc_OSS2_VM * _VM;
    
}

#pragma mark - 初始化构造方法

- (instancetype)initWithLoginDatas:(NSDictionary *)dict{
    
    if (self = [super init]) {
        
        _loginDict = dict;
        
        _nowEnum = JsToOC_None;
        
        self.locationManager = [[AMapLocationManager alloc] init];
        
        self.compositeManager = [[AMapNaviCompositeManager alloc] init];
    }
    return self;
}


#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        
        _nowEnum = JsToOC_None;
        
        self.locationManager = [[AMapLocationManager alloc] init];
        
        self.compositeManager = [[AMapNaviCompositeManager alloc] init];
    }
    return self;
}



- (void)viewDidLoad {

    [super viewDidLoad];
    
    _userModel = UserModel;
    _userModel.userName = @"0550admin";
    _userModel.passWord = @"kdyyS+7CvJrzIj2n0rePTA==";
    
    _VM = Inc_OSS2_VM.shareInstance;
    _VM.homeVC = self;
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    // 登录接口完成后 , 再加载html
    [self http_Login:^(id result) {
        
        // 初始化 webview
        [self UI_Init];
        
        // 监听点击事件
        [self ListenFuncs];
        
        // 将登录返回的信息 转交给前端
        [self Call_LoginClick];
    }];
        

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}



#pragma mark - 网络请求 ---

- (void) http_Login:(httpSuccessBlock)finishLogin {
    

    
    NSDictionary * dict = @{@"username" : _userModel.userName,
                            @"password" : _userModel.passWord,
                            @"version" : [NSString stringWithFormat:@"ios/%@",@"V2.3.18"]};
    
    [Yuan_LoginService http_Login:@{@"jsonRequest":dict.json} success:^(id result) {
            
        NSDictionary * res_dict = result;
        
        if (!res_dict) {
            [YuanHUD HUDFullText:@"登录请求失败 , 请重新进入"];
            return;
        }
        
        
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
            
            [Http.shareInstance Oss_2_DaivdLogin:^{
                if (finishLogin) {
                    finishLogin(nil);
                }
            }];
            

            
        }];
        
    }];
    
}







#pragma mark - UI Init ---

- (void) UI_Init {
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [WKUserContentController new];
     
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 1;
    configuration.preferences = preferences;

    
    _webView = [[WKWebView alloc] initWithFrame:UIScreen.mainScreen.bounds
                                  configuration:configuration];
    
    _webView.UIDelegate = self;


    NSMutableURLRequest *request;
    if (_isTestMode) {
        NSBundle * bundle1 = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"OSS2_Res" ofType:@"bundle"]];

        NSString *path1 = [bundle1 pathForResource:@"index.html" ofType:@""];

        NSURL *baseURL = [NSURL fileURLWithPath:path1];
        
        request = [NSMutableURLRequest requestWithURL:baseURL];
    }
    
    else {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
    }

    
    [_webView loadRequest:request];
    
    [self.view addSubview:_webView];
    
    _webViewBridge = [Inc_WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    
    // 如果控制器里需要监听WKWebView 的`navigationDelegate`方法，就需要添加下面这行。
    [_webViewBridge setWebViewDelegate:self];
    
    // 弱引用
    _VM.webViewBridge = _webViewBridge;
    
}

#pragma mark - delegate ---

// 如果是OC  加载不受信任的站点
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential * card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}



- (void)                webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (webView != _webView) { return; }
    
    NSURL * URL = navigationAction.request.URL;
    
    NSString * urlString = URL.absoluteString;
    
    NSLog(@"-- %@",urlString);
    
    NSLog(@"响应点击事件");
    
    
    // 回退
    if ([urlString containsString:@"back"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    // 必须实现该方法 , 否则会导致闪退
    decisionHandler(WKNavigationActionPolicyAllow);

}



- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    
    
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void(^)(void))completionHandler{

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:([UIAlertAction actionWithTitle:@"确认"style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        completionHandler();

    }])];

    [self presentViewController:alertController animated:YES completion:nil];

}



#pragma mark - ImagePicker Delegate

// 此处代理仅作为参考 还是需要到 vc中实现代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    
    NSString * mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
    
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        // 子线程做工作
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            UIImage * image = info[UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(image, 0.1);
            
            
            // 完成后拿到主线程中刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (_nowEnum == JsToOC_Carema || _nowEnum == JsToOC_Photo) {

                    NSString * base64Image = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                    
                    NSString * replaceStr = [Increase_Foundations removeSpaceAndNewline:base64Image];
                    
                    _nowCallBack(json(@{@"image" : replaceStr}));
                }
                
            });
        });
        
    }
            
}


/// 值传终点    起点默认我当前位置
- (void) endLocation:(CLLocationCoordinate2D)endLocation
         addressName:(NSString *)addressName {
    
    
    

    self.compositeManager.delegate = self;
    
    //导航组件配置类 since 5.2.0
    AMapNaviCompositeUserConfig *config = [[AMapNaviCompositeUserConfig alloc] init];

    
    //传入终点，并且带高德POIId
    [config setRoutePlanPOIType:AMapNaviRoutePlanPOITypeEnd
                       location:[AMapNaviPoint
           locationWithLatitude:endLocation.latitude
                      longitude:endLocation.longitude]
                           name:nil
                          POIId:nil];
    
    
    [config setStartNaviDirectly:YES];
    //启动
    [self.compositeManager presentRoutePlanViewControllerWithOptions:config];
    
}


- (void) locationEnum:(AMapServiceLocation_)serviceEnum
              success:(void(^)(NSDictionary * result))success {
    
    
    
    if (serviceEnum == AMapServiceLocation_Meter) {
        
        // 带逆地理信息的一次定位（返回坐标和地址信息）
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        //   定位超时时间，最低2s，此处设置为2s
        self.locationManager.locationTimeout =2;
        //   逆地理请求超时时间，最低2s，此处设置为2s
        self.locationManager.reGeocodeTimeout = 2;
    }
    else {
        
        // 带逆地理信息的一次定位（返回坐标和地址信息）
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //   定位超时时间，最低2s，此处设置为10s
        self.locationManager.locationTimeout =10;
        //   逆地理请求超时时间，最低2s，此处设置为10s
        self.locationManager.reGeocodeTimeout = 10;
    }
    
    
    // 带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [self.locationManager requestLocationWithReGeocode:YES
                                       completionBlock:^(CLLocation *location,
                                                         AMapLocationReGeocode *regeocode,
                                                         NSError *error) {
            
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
            
            
        if (success) {
            
            
            NSDictionary * result = @{
                @"lat" : [NSString stringWithFormat:@"%lf",location.coordinate.latitude] ?: @"",
                @"lon" : [NSString stringWithFormat:@"%lf",location.coordinate.longitude] ?: @"",
                @"address" : regeocode.formattedAddress ?: @""
            };
            
            success(result);
            
        }
    }];


    
}



#pragma mark -  delegate  ---


// 开始导航的回调函数
- (void)compositeManager:(AMapNaviCompositeManager *)compositeManager
            didStartNavi:(AMapNaviMode)naviMode {
    
    // 开始导航
    NSLog(@"开始导航");
}


#pragma mark - 注册 Js 调用 OC ---



// 注册的获取位置信息的Native 功能
- (void)ListenFuncs {
    
    __typeof(self)weakSelf = self;
    
    Inc_WKWebViewJavascriptBridge * weakBridge = weakSelf->_webViewBridge;
    
    // 调起相机
    [weakBridge registerHandler:@"cameraClick"
                        handler:^(id data, Inc_WVJBResponseCallback responseCallback) {
        
        // 赋值
        _nowCallBack = responseCallback;
        _nowEnum = JsToOC_Carema;
        
        Increase_CaremaVC * imagePicker = [[Increase_CaremaVC alloc] initWithVC:self];
        [imagePicker openCarema];
        
    }];
    
    
    // 调起相册
    [weakBridge registerHandler:@"photoClick"
                        handler:^(id data, Inc_WVJBResponseCallback responseCallback) {
        
        // 赋值
        _nowCallBack = responseCallback;
        _nowEnum = JsToOC_Photo;
        
        Increase_CaremaVC * imagePicker = [[Increase_CaremaVC alloc] initWithVC:self];
        [imagePicker openLibrary];
        
    }];
    
    
    // 调起扫一扫
    [weakBridge registerHandler:@"scanClick"
                        handler:^(id data, Inc_WVJBResponseCallback responseCallback) {
        
        // 赋值
        _nowEnum = JsToOC_QRCode;
        
        if (_isAgreeLog) {
            responseCallback(json(@{@"msg" : @"允许访问"}));
            return;
        }
        
        Increase_ScanVC * scan = [[Increase_ScanVC alloc] init];
        scan.showCodeBlock = ^(NSString *codeStr) {
            responseCallback(json(@{@"msg" : codeStr}));
        };
        
        [self.navigationController pushViewController:scan animated:YES];
        
    }];
    
    
    
    
    // 打电话
    [weakBridge registerHandler:@"callClick"
                        handler:^(id data, Inc_WVJBResponseCallback responseCallback) {
        
        // 赋值
        _nowEnum = JsToOC_Call;

        NSString * phoneNumber = data[@"number"];
        
        if (phoneNumber && [Increase_Foundations isNumber:phoneNumber]) {
            
            NSString * tel = [NSString stringWithFormat:@"tel:%@",phoneNumber];
        }
    }];
    
    
    // 发短信
    [weakBridge registerHandler:@"smsClick"
                        handler:^(id data, Inc_WVJBResponseCallback responseCallback) {
        
        // 赋值
        _nowEnum = JsToOC_Call;

        NSString * phoneNumber = data[@"number"];
        
        if (phoneNumber && [Increase_Foundations isNumber:phoneNumber]) {
            
            NSString * tel = [NSString stringWithFormat:@"sms:%@",phoneNumber];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]
                                               options:@{}
                                     completionHandler:^(BOOL success) {}];
            
        }
    }];
    
    
    // 定位
    [weakBridge registerHandler:@"getCoorsClick"
                        handler:^(id data, Inc_WVJBResponseCallback responseCallback) {
        
        // 赋值
        _nowEnum = JsToOC_Location;
        
        [self locationEnum:AMapServiceLocation_Meter
                   success:^(NSDictionary * _Nonnull result) {
                    
            if (result) {
                responseCallback(json(result));
            }
            else {
                responseCallback(json(@{
                    @"address" : @"未获取到经纬度信息",
                    @"lat" : @"0",
                    @"lon" : @"0",
                }));
            }
            
        }];
        
    }];
    
    
    // 导航
    [weakBridge registerHandler:@"aMapNaviClick"
                        handler:^(id data, Inc_WVJBResponseCallback responseCallback) {
        
        // 赋值
        _nowEnum = JsToOC_Navi;
        
        NSString * lat = data[@"lat"];
        NSString * lon = data[@"lon"];
        NSString * address = data[@"address"];
        
        [self endLocation:CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue)
              addressName:address];
        
    }];
    
    
    // 地图版本
    [weakBridge registerHandler:@"aMapVersionClick"
                        handler:^(id data, Inc_WVJBResponseCallback responseCallback) {
        
        
        NSDictionary * versionDict = @{
            @"AMapFoundationVersion" : AMapFoundationVersion,
            @"AMapLocationVersion" : AMapLocationVersion,
            @"AMapNaviVersion" : AMapNaviVersion
        };

        responseCallback(json(versionDict));
    }];
    
    
    // 登录信息
    [weakBridge registerHandler:@"getLoginDataClick"
                        handler:^(id data, Inc_WVJBResponseCallback responseCallback) {
        
        if (_loginDict) {
            responseCallback(json(_loginDict));
        }
        
        else {
            responseCallback(nil);
        }
        
        
    }];
    
    
    
    // 关闭 并退出资源清查
    [weakBridge registerHandler:@"closeClick"
                        handler:^(id data, Inc_WVJBResponseCallback responseCallback) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    
    // 进入模块
    [weakBridge registerHandler:@"joinModuleClick"
                        handler:^(id data, Inc_WVJBResponseCallback responseCallback) {
            
        NSError * error;
        
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * result = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&error];
        
        [_VM viewModel_JoinModuleDict:result];
    }];
    
    
}


#pragma mark - OC 调用 JS ---


- (void) Call_LoginClick {
    
    [_webViewBridge callHandler:@"LoginClick"
                           data:json(_userModel.userInfo)
               responseCallback:^(id responseData) {
            
    }];
}


@end
