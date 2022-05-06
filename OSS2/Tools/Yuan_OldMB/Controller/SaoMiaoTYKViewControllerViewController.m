//
//  SaoMiaoTYKViewControllerViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/7/6.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "SaoMiaoTYKViewControllerViewController.h"
#import "IWPQcodeScaner.h"
#import "MBProgressHUD.h"


#import "IWPPropertiesReader.h"
#import "GeneratorTYKViewController.h"
#import "ptotocolDelegate.h"
//#import "GeneratorSSSBTYKInfoViewController.h"
//#import "CableTYKViewController.h"

#import "Inc_NewMB_HttpModel.h"
#import "Inc_NewMB_DetailVC.h"

#import "Inc_ShareListVC.h"    //分享 2021.7.19
#import "Inc_Push_MB.h"
//#import "Inc_CloudNet_HttpModel.h"
//#import "Inc_CloudNet_ViewModel.h"
//#import "Inc_CloudNet_DetailVC.h"

// AES 解密
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>




BOOL isTYKScaned = NO;
@interface SaoMiaoTYKViewControllerViewController ()
<TYKDeviceInfomationDelegate ,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>{
    
    
    MBProgressHUD * HUD;
    
    BOOL _isYuanNewXJ;
    
    /** 声明 新巡检扫描的回调block */
    void(^_scanBlock)(NSString * scanMsg);

    UIImagePickerController * _imagePicker;
    
    // 是否是云网资源账号
    BOOL _isCloudNet_Account;
    
}
@property (nonatomic, strong) IWPQcodeScaner * scanner;


/** <#注释#> */
@property (nonatomic , strong) UIButton * photoBtn;


/**
 *  123123123
 */
@end

@implementation SaoMiaoTYKViewControllerViewController
-(void)viewDidAppear:(BOOL)animated{
    
    [self.navigationController.navigationBar.maskView setAlpha:.1f];
    [super viewDidAppear:animated];
    
    [self createScanner];
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [self.navigationController.navigationBar.maskView setAlpha:1.f];
    
    [super viewWillDisappear:animated];
}
-(instancetype)init{
    if (self = [super init]) {
        _isGet = NO;
    }
    return self;
}



#pragma mark - 初始化构造方法

- (instancetype) initWithYuanNewXJ:(void(^)(NSString * scanMsg))scanBlock {
    
    if (self = [super init]) {
        _isYuanNewXJ = true;
        _scanBlock = scanBlock;
    }
    return self;
}



-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.scanner stopReading];
    self.scanner = nil;
    if (isTYKScaned) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (self.isPushedBy3DTouch) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)createScanner{
    __weak typeof(self) weself = self;
    
    if (self.scanner == nil) {
        self.scanner = [[IWPQcodeScaner alloc] initWithSupperView:self.view];
    }
    
    
    
    [self.scanner startReading:^(NSString *msg) {
        
        
        // 分享
        if ([msg hasPrefix:@"app://increase/openv2?content="]) {
            
            NSString * subString =
            [msg stringByReplacingOccurrencesOfString:@"app://increase/openv2?content=" withString:@""];
            
            Inc_ShareListVC * share = [[Inc_ShareListVC alloc] initWithPassLogin:@{@"msg":subString}];
            Push(self, share);
            
            return;
        }
        
        
        if (_isYuanNewXJ && _scanBlock) {
            
            _scanBlock(msg);
            
            if ([self.navigationController.viewControllers.lastObject isKindOfClass:[self class]]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            return ;
        }
        
        
        if (weself.isGet) {
            [weself makeRFIDWithRFID:msg];
        }
        else if(!weself.hanlder){
            
            // 稽核部分
            if ([msg hasPrefix:@"QA"]) {
                [weself Yuan_NewCheck_Port:msg];
            }
            
            // 通常扫码请求的方法
            else {
                [weself scanedResultWithString:msg];
            }
            
        }
        
        if (weself.hanlder) {
            weself.hanlder(msg);
            if ([self.navigationController.viewControllers.lastObject isKindOfClass:[self class]]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        
        

            
        
    }];
    
    
    
    _photoBtn = [UIView buttonWithImage:@"SaoMiao_Photo"
                              responder:self
                              SEL_Click:@selector(choicePhoto)
                                  frame:CGRectNull];
    
    [_photoBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    [self.view addSubview:_photoBtn];
    
    
    [_photoBtn YuanToSuper_Bottom:30];
    [_photoBtn YuanAttributeVerticalToView:self.view];
    
    
    
}

-(void)makeRFIDWithRFID:(NSString *)msg{
    if ([self.delegate respondsToSelector:@selector(makeRfidText:)]) {
        [self.delegate makeRfidText:msg];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.title = @"扫描设备二维码";
    self.view.backgroundColor = UIColor.blackColor;


    NSString * powers = UserModel.powersDic[@"powers"];
    // 证明存在云网资源权限 , 走云网资源
    if ([powers containsString:@"CLOUD_RESOURCE"]) {
        _isCloudNet_Account = true;
    }
    
}
-(void)scanedResultWithString:(NSString *)string{
    [self requestWithResLogicName:@"rfidInfo" withValue:string];
}



// 稽核新增请求接口
- (void) Yuan_NewCheck_Port:(NSString *) msg {
    
    NSString * key = @"abcdsxyzhkj12345";
    
    NSString * aesCode = [msg substringFromIndex:2];
    
    NSString * deCode = [self aesDecrypt:aesCode key:key];
    
    NSLog(@"%@", deCode);
    
    if (!deCode) {
        [YuanHUD HUDFullText:@"稽核解析失败"];
        return;
    }
    
    // 过期时间
    NSString * time = [deCode substringWithRange:NSMakeRange(0, 14)];
    // 类型
    NSString * type = [deCode substringWithRange:NSMakeRange(14, 2)];
    // ID
    NSString * resId = [deCode substringFromIndex:16];
    
    
    int type_Int = type.intValue;
    
    NSString * resLogicName = @"";
    NSString * numType = @"";
    
    // 1://光交箱 2://纤芯3://机房 4://局站 5://光缆段  6://光缆  7://光分纤箱+光终端盒  8://机架 9://接头
    switch (type_Int) {
        // 光缆
        case 1:
            resLogicName = @"route";
            numType = @"6";
            break;
        // 光缆段
        case 2:
            resLogicName = @"cable";
            numType = @"5";
            break;
        // ODF
        case 3:
            resLogicName = @"ODF_Equt";
            numType = @"8";
            break;
        // 光交接箱
        case 4:
            resLogicName = @"OCC_Equt";
            numType = @"1";
            break;
        // 光分纤箱
        case 5:
            resLogicName = @"ODB_Equt";
            numType = @"7";
            break;
        // 杆路
        case 6:
            resLogicName = @"poleline";
//            numType = @"6";
            break;
        // 管道
        case 7:
            resLogicName = @"pipe";
//            numType = @"7";
            break;
        // ? 未知
        case 8:
            resLogicName = @"";
//            numType = @"8";
            break;
        // 标石
        case 9:
            resLogicName = @"markStone";
            numType = @"9";
            break;
        
            
        default:
            break;
    }
    
    
    
    
    [Http.shareInstance V2_POST:HTTP_TYK_Normal_Get dict:@{@"resLogicName": resLogicName ,
                                                           @"GID":resId}
                        succeed:^(id data) {
    
        
        NSArray * result = data;
        
        if (result.count > 0) {

            NSDictionary * dict = result.firstObject;

            TYKDeviceInfoMationViewController * device =  [Inc_Push_MB pushFrom:self
                                                                    resLogicName:resLogicName
                                                                            dict:dict
                                                                            type:TYKDevice_NewCheck];

            device.Yuan_NewCheckId = numType;
            
        }
    }];
    
}





// 传统扫一扫请求接口
-(void)requestWithResLogicName:(NSString *)resLogicName
                     withValue:(NSString *)value{
    
    
    // 如果是云网资源的话
    if (_isCloudNet_Account) {
        
        [self http_CloudNetResourceMB:value];
    }
    
    // 正常的逻辑判断
    else {
        
        [self http_OldResourceMB:value
                    resLogicName:resLogicName
                   davidResource:^(id result) {
            
            [self newMB_Port:value];
        }];
    }
}


- (void) newMB_Port:(NSString * )value {
    
    __typeof(self)weakSelf = self;
    [self http_David_NewMB:value success:^(id result) {
        
        NSDictionary * dict = result;
        
        if (dict.allKeys.count == 0) {
            [weakSelf createScanner];
            return;
        }
        else {
            
            NSString * gid = dict[@"resId"];
            NSString * fileName = dict[@"resType"];
            
            
            Yuan_NewMB_ModelEnum_ Enum = [Inc_NewMB_VM.viewModel EnumFromFileName:fileName];
            
            if (Enum == Yuan_NewMB_ModelEnum_None) {
                [YuanHUD HUDFullText:@"未检测到该资源"];
                return;
            }
            
            [Inc_Push_MB NewMB_GetDetailDictFromGid:gid
                                               Enum:Enum
                                            success:^(NSDictionary * _Nonnull gidDict) {
                          
                Inc_NewMB_DetailVC * new_MB = [[Inc_NewMB_DetailVC alloc] initWithDict:gidDict Yuan_NewMB_ModelEnum:Enum];
                
                Push(weakSelf, new_MB);
            }];
        }
        
    }];

}


#pragma mark - 网络请求 ---


- (void) http_OldResourceMB:(NSString *) rfid
               resLogicName:(NSString *) resLogicName
              davidResource:(void(^)(id result))success {
    
    // 创建请求字典
    NSDictionary *dic = @{@"resLogicName":resLogicName,@"rfid":rfid};
    NSString * URL = [NSString stringWithFormat:@"%@rm!getResByRfid.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
    
    // 创建请求体
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    
    
    // 设置UID
    [param setValue:UserModel.uid forKey:@"UID"];
    
    // 放入请求体
    [param setValue:DictToString(dic) forKey:@"jsonRequest"];
    
    __weak typeof(self) wself = self;
    [Http.shareInstance POST:URL dict:param succeed:^(id data) {
            
        NSDictionary * dict = data;
        NSNumber * result = dict[@"result"];
        
        // 取出json
        NSData * infoData = [REPLACE_HHF(dict[@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
        NSError * err = nil;
        
        // 将json解析成数组
        NSArray * info = [NSJSONSerialization JSONObjectWithData:infoData options:NSJSONReadingMutableContainers error:&err];
        
        NSDictionary * getDict = info.firstObject;
        NSString * resLogicName = getDict[@"resLogicName"];
        
        if (result.intValue == 0) {
            
            if (!info || info.count == 0) {
                [YuanHUD HUDFullText:@"未查询到设备"];
                [wself createScanner];
                return;
            }
            
            
            // ABCDEFG 机房 光缆段
            if ([resLogicName isEqualToAnyString:@"ABCDEFG",@"generator",@"cable",@"PowerEqu", nil]) {
                
                if (success) {
                    success(data);
                }
            }
            else {
                
                // 扫描到设备
                [wself showInfomationViewControllerWithDict:info];
            }
            

        }
        
        else if (result.intValue == 1) {
            

            if (getDict.count > 0 &&
                resLogicName!=nil &&
                ![resLogicName isEqualToString:@"ABCDEFG"]) {
                
                // 扫描到设备
                [wself showInfomationViewControllerWithDict:info];
            }
            
            // 请求大为新模板设备
            else{
                
                if (success) {
                    success(data);
                }
            }
        }
        
        
        // 正常应该不会出现这种情况 **** 
        else{
            
            [self http_David_NewMB:rfid success:^(id result) {
                NSDictionary * dict = result;
                
                if (dict.allKeys.count == 0) {
                    [wself createScanner];
                    return;
                }
            }];
  
        }
        
    }];
    
}


- (void) http_David_NewMB:(NSString *) rfid
                  success:(void(^)(id result))success{
    
    [Inc_NewMB_HttpModel HTTP_NewMB_Rfid:rfid
                                 Success:^(id  _Nonnull result) {
        
        if (result) {
            success(result);
        }
        
    }];
}

/// 云网资源 二维码扫描的请求
- (void) http_CloudNetResourceMB:(NSString *) rfid {
    
//    [Inc_CloudNet_HttpModel Http_cloudLoginSuccess:^(id  _Nonnull result) {
//
//        NSDictionary *dic = result;
//        Inc_CloudNet_ViewModel *vm = Inc_CloudNet_ViewModel.shareInstance;
//        vm.token = dic[@"access_token"]?:@"";
//        NSLog(@"token: %@",vm.token);
//
//        [Inc_CloudNet_HttpModel http_CloudNet_Rfid:rfid
//                                           success:^(id  _Nonnull result) {
//
//            NSArray * info = result[@"info"];
//
//            if (!info || info.count == 0) {
//                [self createScanner];
//                [YuanHUD HUDFullText:@"未查询到资源"];
//                return;
//            }
//
//            NSDictionary * resDict = info.firstObject;
//
//            NSString * type = resDict[@"bk_obj_id"];
//            Inc_CloudNet_Enum_ Enum = [vm cloudNet_EnumGetJsonFile:type];
//
//            if (Enum == Inc_CloudNet_Enum_None) {
//                [YuanHUD HUDFullText:[NSString stringWithFormat:@"未识别的设备 %@",resDict[@"bk_obj_id"]]];
//                return;
//            }
//
//            if (Http_MB) {
//
//                // 网络请求 模板资源属性
//                [Inc_CloudNet_HttpModel http_CloudNet_GetJsonDatasFromResourceType:type
//                                                                           success:^(id  _Nonnull result) {
//                    NSArray * mb = result;
//                    if (mb.count == 0) {
//                        [YuanHUD HUDFullText:@"未查询到模板资源"];
//                        return;
//                    }
//
//                    vm.http_MBDetailArr = mb;
//
//                    Inc_CloudNet_DetailVC * vc =
//                    [[Inc_CloudNet_DetailVC alloc] initWithDict:resDict
//                                           Yuan_NewMB_ModelEnum:Enum];
//
//                    // 物理机
//                    if (Enum == Inc_CloudNet_Enum_bare_metal) {
//
//                        vc.leftDrapModeEnum = CloudNet_Detail_LeftDrapMode_bare_metal;
//                    }
//
//                    Push(self, vc);
//
//                }];
//            }
//
//            else {
//
//                Inc_CloudNet_DetailVC * vc =
//                [[Inc_CloudNet_DetailVC alloc] initWithDict:resDict
//                                       Yuan_NewMB_ModelEnum:Enum];
//
//                // 物理机
//                if (Enum == Inc_CloudNet_Enum_bare_metal) {
//
//                    vc.leftDrapModeEnum = CloudNet_Detail_LeftDrapMode_bare_metal;
//                }
//
//                Push(self, vc);
//            }
//
//        }];
//
//    }];
}

// ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

-(void)continueHandleDataWithDict:(NSArray *)devices{
    // 取出设备，并获得设备名，使用rfid获取该设备的详细信息
    
    NSString * deviceId = devices[0][@"resId"];
    [self requestWithResLogicName:devices[0][@"resType"] withValue:deviceId];
}
-(void)showInfomationViewControllerWithDict:(NSArray *)devices{
    // 显示设备信息
    // 取出设备字典
    NSDictionary * dict = [devices firstObject];
   
    
    // 新增省内资源判断 2020-11-12
    if ([dict[@"searchBy"] isEqualToString:@"digCodeOld"]) {
        [[Yuan_HUD shareInstance] HUDFullText:@"该标签为省内二维码标签"];
    }
    
    
    // 取出文件名
    NSString * fileName = dict[@"resLogicName"];
    // 根据不同文件名跳转不同的控制器
    if ([fileName isEqualToString:@"generator"]){
        //机房信息
        // 取出文件模型
        IWPPropertiesSourceModel * model = [[IWPPropertiesReader propertiesReaderWithFileName:fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] mainModel];
        GeneratorTYKViewController * deviceInfo =[GeneratorTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
        
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:deviceInfo];
        
        deviceInfo.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:deviceInfo action:@selector(dismissModalViewControllerAnimated:)];
        Present(self, nav);
        
    }else if ([fileName isEqualToString:@"cable"]){
        //光缆段信息
//        // 取出文件模型
//        IWPPropertiesSourceModel * model = [[IWPPropertiesReader propertiesReaderWithFileName:fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] mainModel];
//        CableTYKViewController * deviceInfo =[CableTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:deviceInfo];
//
//        deviceInfo.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:deviceInfo action:@selector(dismissModalViewControllerAnimated:)];
//        Present(self, nav);
        
    }else if ([fileName isEqualToString:@"ABCDEFG"]){//TODO:这里要改,加入全资源类型的判断
        [YuanHUD HUDFullText:@"到这了GeneratorSSSBTYKInfoViewController 大大大"];
//        // 机房下属设备信息
//        GeneratorSSSBTYKInfoViewController *infoVC = [[GeneratorSSSBTYKInfoViewController alloc] init];
//        infoVC.dictIn = dict;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:infoVC];
//
//        infoVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:infoVC action:@selector(dismissModalViewControllerAnimated:)];
//        Present(self, nav);
    }else{
        IWPPropertiesSourceModel * model = [[IWPPropertiesReader propertiesReaderWithFileName:fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] mainModel];
        TYKDeviceInfoMationViewController * deviceInfo =[TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
        
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:deviceInfo];
        
        deviceInfo.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:deviceInfo action:@selector(dismissModalViewControllerAnimated:)];
        Present(self, nav);
    }
    isTYKScaned = YES;
}

-(void)dismissModalViewControllerAnimated:(BOOL)animated{
    [super dismissModalViewControllerAnimated:animated];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)deleteDeviceWithDict:(NSDictionary *)dict withViewControllerClass:(__unsafe_unretained Class)vcClass{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"确定要删除该设备？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteDevice:dict withClass:vcClass];
    }];
    UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        return;
    }];
    
    [alert addAction:actionYES];
    [alert addAction:actionNO];
    Present(self, alert);
}

-(void)deleteDevice:(NSDictionary *)dict withClass:(Class)class{
    // 删除事件
    
#ifdef BaseURL
    NSString * requestURL = [NSString stringWithFormat:@"%@data!deleteData.interface", BaseURL];
#else
    NSString * requestURL = [NSString stringWithFormat:@"%@data!deleteData.interface", BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setValue:UserModel.uid forKey:@"UID"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [param setValue:str forKey:@"jsonRequest"];
    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除成功" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert addAction:action];
        Present(self.navigationController, alert);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [YuanHUD HUDFullText:@"删除失败"];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}




#pragma mark - 从图片选取二维码 ---

- (void)choicePhoto{
  //调用相册
    _imagePicker = [[UIImagePickerController alloc]init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

//选中图片的回调
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *content = @"" ;
    //取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(pickImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];

    //创建探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSArray *feature = [detector featuresInImage:ciImage];
  
    if (feature.count == 0) {
        [YuanHUD HUDFullText:@"未检测到二维码"];
        return;
    }
    
    //取出探测到的数据
    for (CIQRCodeFeature *result in feature) {
      content = result.messageString;
      [_imagePicker dismissViewControllerAnimated:YES completion:nil];
      
      // 执行扫码完成的事件
      [self scan_Photo:content];
    }
    //进行处理(音效、网址分析、页面跳转等)
}


- (void) scan_Photo:(NSString *) result {
    
    [self scanedResultWithString:result];
}






#pragma mark - AES 解密 ---
- (NSString *)aesDecrypt:(NSString *)secretStr
                     key:(NSString *)key{
    
    
    //先对加密的字符串进行base64解码
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:secretStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
     
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
     
    NSUInteger dataLength = [decodeData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, [decodeData bytes], dataLength, buffer, bufferSize, &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return result;
    } else {
        free(buffer);
        return nil;
    }

    
}

@end
