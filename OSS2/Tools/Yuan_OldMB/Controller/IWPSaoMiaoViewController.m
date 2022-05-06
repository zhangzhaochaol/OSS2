//
//  IWPSaoMiaoViewController.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/6/18.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPSaoMiaoViewController.h"
#import "IWPQcodeScaner.h"
#import "MBProgressHUD.h"


#import "IWPPropertiesReader.h"
//#import "BindTubeRfidUIViewController.h"
//#import "IWPDeviceInfoMationViewController.h"
//#import "ResourceMainAutoViewController.h"

// jifang
//#import "IWPGeneratorViewController.h"
//局站自定义
//#import "IWPStationViewController.h"
//杆路自定义
//#import "IWPPoleLineViewController.h"
//電桿自定義
//#import "IWPPoleViewContorller.h"
//管道自定义
//#import "IWPPipeViewController.h"
//井自定义
//#import "IWPWellViewController.h"
//引上点自定义
//#import "IWPLedUpViewController.h"
// 标石自定义
//#import "IWPMarkStoneViewController.h"
// OCC自定义
//#import "IWPOCCEqutViewController.h"
// joint
//#import "IWPJointViewController.h"
//ODB_Equt
//#import "IWPODBViewController.h"
//ODF_Equt
//#import "IWPODFViewController.h"
//#import "IWPOLTViewController.h"
//#import "IWPRFIDViewController.h"
//#import "IWPCableViewController.h"
//#import "TubeInfoShowViewController.h"
//#import "TubeInfoNewViewController.h"
//#import "ptotocolDelegate.h"
//#import "IWPDataNetEquViewController.h"
//#import "IWPTransmissionEquViewController.h"
//#import "IWPPowerEquViewController.h"
//#import "IWPPowerCableViewController.h"
//#import "IWPSupportingPointsViewContorller.h"
BOOL isScaned = NO;
@interface IWPSaoMiaoViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    
//@interface IWPSaoMiaoViewController ()<IWPDeviceInfomationDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{

    MBProgressHUD * HUD;
    
}
@property (nonatomic, strong) IWPQcodeScaner * scanner;


/** <#注释#> */
@property (nonatomic , strong) UIButton * photoBtn;

/**
 *  123123123
 */
@end

@implementation IWPSaoMiaoViewController

{
    
    UIImagePickerController * _imagePicker;
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self.navigationController.navigationBar.maskView setAlpha:.1f];
    [super viewDidAppear:animated];


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

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    self.scanner = nil;
    if (isScaned) {
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
        if (weself.isGet) {
            [weself.scanner stopReading];
            [weself makeRFIDWithRFID:msg];
        }else if(!weself.hanlder){
            [weself scanedResultWithString:msg];
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
        
        [YuanHUD HUDFullText:@"到这了 出错了？BindTubeRfidUIViewController"];
//        if ([self.delegate isKindOfClass:BindTubeRfidUIViewController.class]) {
//            [self.navigationController popViewControllerAnimated:true];
//        }
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [self.delegate makeRfidText:msg];
        });
      
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"扫描设备二维码";
    [self createScanner];
//    [self needShow];
    
    // Do any additional setup after loading the view.
}
-(void)scanedResultWithString:(NSString *)string{
    [self requestWithResLogicName:@"rfidInfo" withValue:string];
}


-(void)requestWithResLogicName:(NSString *)resLogicName withValue:(NSString *)value{
    
    // 创建请求字典
    NSDictionary * dict = nil;
    if ([resLogicName isEqualToString:@"rfidInfo"]) {
        dict = @{@"resLogicName":resLogicName,@"rfid":value};
    }else{
        dict = @{@"resLogicName":resLogicName,[NSString stringWithFormat:@"%@Id",resLogicName]:value};
    }

    // 拼接请求连接
#ifdef BaseURL
    NSString * requestURL = [NSString stringWithFormat:@"%@data!getData.interface",BaseURL];
#else
    NSString * requestURL = [NSString stringWithFormat:@"%@data!getData.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    // 创建请求体
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    // 设置UID
    [param setValue:UserModel.uid forKey:@"UID"];
    
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    
    __weak typeof(self) wself = self;
    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        // 请求成功，拿到数据
        
        NSDictionary * dict = responseObject;
        NSNumber * num = dict[@"success"];
        
        if (num.intValue == 1) {
            
            // 取出json
            NSData * infoData = [REPLACE_HHF(dict[@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSError * err = nil;
            
            // 将json解析成数组
            NSArray * info = [NSJSONSerialization JSONObjectWithData:infoData options:NSJSONReadingMutableContainers error:&err];


            if (info.count > 0) {
                // 扫描到设备
                
                NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
                
                BOOL isOpen = [[user valueForKey:@"isZiChanGuanLian"] integerValue] == 1;
                
                if ([info[0][@"resLogicName"] isEqualToString:@"rfidInfo"]) {
                    // 如果拿到的是rfid信息表，则继续请求
                    
                    if (isOpen) {
                        [YuanHUD HUDFullText:@"到这了?ResourceMainAutoViewController"];
//                        if ([self.delegate isKindOfClass:[ResourceMainAutoViewController class]]) {
//
//                            ResourceMainAutoViewController * mainVC = (ResourceMainAutoViewController *)self.delegate;
//
//                            mainVC.rfidInfo = info.firstObject;
//
//                        }
                    }
                    
                    [wself continueHandleDataWithDict:info];
                }else{
                    // 否则，即为拿到了设备信息，前往显示该设备
                    
                    if (_scannedInfo != nil){
                        
                        _scannedInfo(info.firstObject);
                        
                        return;
                    }
                    
                    
                    if (isOpen) {
                        [YuanHUD HUDFullText:@"到这了?ResourceMainAutoViewController"];

//                        if ([self.delegate isKindOfClass:[ResourceMainAutoViewController class]]) {
//
//                        ResourceMainAutoViewController * mainVC = (ResourceMainAutoViewController *)self.delegate;
//
//                        mainVC.currentDeviceInfo = info.firstObject;
//
//                        [mainVC showZichanBangding];
//
//                        [self.navigationController popViewControllerAnimated:true];
//
//                        }
                    }else{
                        [wself showInfomationViewControllerWithDict:info];
                    }
                    
                    
                }
            }else{
               
                

                // 未扫描到任何设备
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"未查询到相关设备" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    // 重新创建扫描工具
                    [wself createScanner];
                    return;
                }];
                [alert addAction:action];
                Present(wself, alert);
            }
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.label.text = @"亲，网络请求出错了";
        HUD.detailsLabel.text = error.localizedDescription;
        HUD.mode = MBProgressHUDModeText;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            HUD.mode = MBProgressHUDModeText ;
            
            [HUD hideAnimated:YES afterDelay:2];
            
            HUD = nil;
        });
    }];
}

-(void)continueHandleDataWithDict:(NSArray *)devices{
    // 取出设备，并获得设备名，使用rfid获取该设备的详细信息
    
    NSString * deviceId = devices[0][@"resId"];
    [self requestWithResLogicName:devices[0][@"resType"] withValue:deviceId];
}
-(void)showInfomationViewControllerWithDict:(NSArray *)devices{
    
    [YuanHUD HUDFullText:@"到这里了；；；showInfomationViewControllerWithDict"];
    
//    // 显示设备信息
//    // 取出设备字典
//    NSDictionary * dict = [devices firstObject];
//    // 取出文件名
//    NSString * fileName = dict[@"resLogicName"];
//
//
//    // 取出文件模型
//    IWPPropertiesSourceModel * model = [[IWPPropertiesReader propertiesReaderWithFileName:fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] mainModel];
//
//
//
//    // 根据不同文件名跳转不同的控制器
//    if ([fileName isEqualToString:@"poleline"]) {
//        IWPPoleLineViewController * poline = [IWPPoleLineViewController
//                                              deviceInfomationWithControlMode:IWPDeviceListUpdate
//                                              withMainModel:model
//                                              withViewModel:nil
//                                              withDataDict:dict
//                                              withFileName:fileName];
//        poline.delegate = self;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:poline];
//
//        poline.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:poline action:@selector(dismissModalViewControllerAnimated:)];
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"PowerEqu"]){
//        IWPPowerEquViewController * pequ = [IWPPowerEquViewController deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        pequ.delegate = self;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:pequ];
//
//        pequ.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:pequ action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"rifdInfo"]){
//        IWPRFIDViewController * rfid = [IWPRFIDViewController deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        rfid.delegate = self;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:rfid];
//
//        rfid.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:rfid action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"DataNetEqu"]){
//        IWPDataNetEquViewController * DataNetEqu = [IWPDataNetEquViewController
//                                                    deviceInfomationWithControlMode:IWPDeviceListUpdate
//                                                    withMainModel:model
//                                                    withViewModel:nil
//                                                    withDataDict:dict                                                    withFileName:fileName];
//        DataNetEqu.delegate = self;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:DataNetEqu];
//
//        DataNetEqu.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:DataNetEqu action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"transmissionEqu"]){
//        IWPTransmissionEquViewController * TransmissionEqu = [IWPTransmissionEquViewController
//                                                              deviceInfomationWithControlMode:IWPDeviceListUpdate
//                                                              withMainModel:model
//                                                              withViewModel:nil
//                                                              withDataDict:dict
//                                                              withFileName:fileName];
//        TransmissionEqu.delegate = self;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:TransmissionEqu];
//
//        TransmissionEqu.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:TransmissionEqu action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"PowerCable"]){
//        IWPPowerCableViewController * PowerCable = [IWPPowerCableViewController
//                                                    deviceInfomationWithControlMode:IWPDeviceListUpdate
//                                                    withMainModel:model
//                                                    withViewModel:nil
//                                                    withDataDict:dict
//                                                    withFileName:fileName];
//        PowerCable.delegate = self;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:PowerCable];
//
//        PowerCable.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:PowerCable action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }
//    else if([fileName isEqualToString:@"pole"]){
//        IWPPoleViewContorller * pole = [IWPPoleViewContorller
//                                        deviceInfomationWithControlMode:IWPDeviceListUpdate
//                                        withMainModel:model
//                                        withViewModel:nil
//                                        withDataDict:dict
//                                        withFileName:fileName];
//        pole.delegate = self;
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:pole];
//
//        pole.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:pole action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"pipe"]){
//        IWPPipeViewController * pipe = [IWPPipeViewController deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        pipe.delegate = self;
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:pipe];
//
//        pipe.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:pipe action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"well"]){
//        IWPWellViewController * well = [IWPWellViewController deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        well.delegate = self;
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:well];
//
//        well.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:well action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//
//    }else if ([fileName isEqualToString:@"ledUp"]){
//        IWPLedUpViewController * ledUP = [IWPLedUpViewController deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        ledUP.delegate = self;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:ledUP];
//
//        ledUP.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:ledUP action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"markStone"]){
//        IWPMarkStoneViewController * markStone = [IWPMarkStoneViewController deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        markStone.delegate = self;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:markStone];
//
//        markStone.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:markStone action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//
//    }else if ([fileName isEqualToString:@"OCC_Equt"]){
//        IWPOCCEqutViewController * occ = [IWPOCCEqutViewController deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//
//        occ.delegate = self;
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:occ];
//
//        occ.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:occ action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"joint"]){
//        IWPJointViewController * joint = [IWPJointViewController  deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        joint.delegate = self;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:joint];
//
//        joint.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:joint action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"ODB_Equt"]){
//        IWPODBViewController * odb = [IWPODBViewController  deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        odb.delegate = self;
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:odb];
//
//        odb.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:odb action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"ODF_Equt"]){
//        IWPODFViewController * odf = [IWPODFViewController  deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        odf.delegate = self;
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:odf];
//
//        odf.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:odf action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"OLT_Equt"]){
//        IWPOLTViewController * olt = [IWPOLTViewController  deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        olt.delegate = self;
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:olt];
//
//        olt.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:olt action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"stationBase"]){
//        IWPStationViewController * station = [IWPStationViewController deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        station.delegate = self;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:station];
//
//        station.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:station action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"supportingPoints"]){
//        IWPSupportingPointsViewContorller * station = [IWPSupportingPointsViewContorller deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        station.delegate = self;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:station];
//
//        station.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:station action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//    }else if ([fileName isEqualToString:@"generator"]){
//
//        NSLog(@"%@", dict);
//
//        IWPGeneratorViewController * geo =[IWPGeneratorViewController deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        geo.delegate = self;
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:geo];
//
//        geo.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:geo action:@selector(dismissModalViewControllerAnimated:)];
//        //        [self presentModalViewController:nav animated:YES];
//
//        Present(self, nav);
//
//    }else if ([fileName isEqualToString:@"tube"]){
//                TubeInfoNewViewController * tube = [[TubeInfoNewViewController alloc] init];
//                tube.tubeIn = dict;
//                tube.isUpdate = YES;
//                tube.isFather = [dict[@"isFather"] intValue];
//                tube.number = dict[@"tubeCode"];
//
//        //        tubeInfoNewVC.tubeIn = _tubeArray[selectIndex];
//        //        tubeInfoNewVC.isUpdate = YES;
//        //        tubeInfoNewVC.number = selectTubeBtn.titleLabel.text;
//        //        tubeInfoNewVC.face = faceSelectMuDic;
//        //        tubeInfoNewVC.well = wellInDic;
//
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:tube];
//
//        tube.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:tube action:@selector(dismissModalViewControllerAnimated:)];
//
//        Present(self, nav);
//
//    }else if ([fileName isEqualToString:@"cable"]){
//        IWPCableViewController * cable = [IWPCableViewController deviceInfomationWithControlMode:IWPDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//        cable.delegate = self;
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:cable];
//
//        cable.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:cable action:@selector(dismissModalViewControllerAnimated:)];
//
//        Present(self, nav);
//    }
//    else{
//
//        [YuanHUD HUDFullText:@"到这里啊啊啊？IWPDeviceInfoMationViewController"];
////        IWPDeviceInfoMationViewController * deviceVC =
////
////        [IWPDeviceInfoMationViewController
////         deviceInfomationWithControlMode:IWPDeviceListUpdate
////         withMainModel:model
////         withViewModel:nil
////         withDataDict:dict
////         withFileName:fileName];
////
////        deviceVC.delegate = self;
////
////        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:deviceVC];
////
////        deviceVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:deviceVC action:@selector(dismissModalViewControllerAnimated:)];
////
////        Present(self, nav);
//    }
//
//    isScaned = YES;

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
    
    
    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除成功" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert addAction:action];
        Present(self.navigationController, alert);
        
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {

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
    
    
    
    if (self.isGet) {
        [self.scanner stopReading];
        [self makeRFIDWithRFID:result];
    }else if(!self.hanlder){
        [self scanedResultWithString:result];
    }
    
    if (self.hanlder) {
        self.hanlder(result);
        if ([self.navigationController.viewControllers.lastObject isKindOfClass:[self class]]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}



@end
