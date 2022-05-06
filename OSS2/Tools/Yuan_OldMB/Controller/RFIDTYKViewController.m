//
//  RFIDTYKViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/7/26.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "RFIDTYKViewController.h"
#import "IWPPropertiesReader.h"
#import "IWPButton.h"


#import "MBProgressHUD.h"
@interface RFIDTYKViewController ()
@property(strong,nonatomic)MBProgressHUD * HUD;
@end

@implementation RFIDTYKViewController
{
    NSString * TYKNew_fileName;  //统一库新增了 UNI_前缀的 fileName ; 袁全添加--
}

-(instancetype)initWithControlMode:(TYKDeviceListControlTypeRef)controlMode withMainModel:(IWPPropertiesSourceModel *)model withViewModel:(NSArray<IWPViewModel *> *)viewModel withDataDict:(NSDictionary *)dict withFileName:(NSString *)fileName{
    
    
    TYKNew_fileName = [NSString stringWithFormat:@"UNI_%@",fileName];
    
    NSArray * views = [NSArray arrayWithArray:[[IWPPropertiesReader propertiesReaderWithFileName:TYKNew_fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] viewModels]];
    
    NSMutableArray * newArr = [views mutableCopy];
    IWPViewModel * viewModelnew = [[IWPViewModel alloc] init];
    viewModelnew.tv1_Required = @"1";
    viewModelnew.tv1_Text = @"标签ID";
    viewModelnew.type = @"52";
    viewModelnew.name1 = @"rfid";// key
    viewModelnew.ed1_Ed = @"0";
    viewModelnew.ed1_Hint = @"请扫描";
    viewModelnew.btn1_text = @"扫描";
    [newArr insertObject:viewModelnew atIndex:0];
    
    
    self = [super initWithControlMode:controlMode withMainModel:model withViewModel:newArr withDataDict:dict withFileName:fileName];
    return self;
}
-(void)saveButtonHandler:(IWPButton *)sender{
    if (self.requestDict[@"rfid"] == nil || [self.requestDict[@"rfid"] isEqualToString:@""]) {
     
        [YuanHUD HUDFullText:@"请填写【标签ID】后再进行保存"];
        
        return;
    }
    NSString * postUrl = nil;
    if (!self.isUpdate) {
        //新增
        postUrl = @"rm!insertGIDandRFID.interface";
    }else{
        //核查
        postUrl = @"rm!updateRfidAndGidRelation.interface";
    }
    [self saveTYKInfoData_TYKKK:postUrl];
}
-(void)deleteStationButtonHandler:(IWPButton *)sender{
    if (self.requestDict == nil ||(self.requestDict[@"GIDandRFIDrelationId"] == nil)) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"请在保存后再进行删除操作" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        
        [alert addAction:action];
        Present(self, alert);
    }else if ([self.delegate respondsToSelector:@selector(deleteDeviceWithDict:withViewControllerClass:)] == YES) {
        [self.delegate deleteDeviceWithDict:self.requestDict withViewControllerClass:[self class]];
    }

}
//保存统一库资源信息
-(void)saveTYKInfoData_TYKKK:(NSString *) postUrl{
    [self.requestDict setObject:@"GIDandRFIDrelation" forKey:@"resLogicName"];
    [self.requestDict setObject:@"701" forKey:@"resTypeId"];
    
    NSLog(@"self.requestDict:%@",self.requestDict);
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    // 这里拦截UserModel.uid为空时
    if (UserModel.uid == nil) {
        //            UIViewController * viewC = self.navigationController.viewControllers[0];
     
        [YuanHUD HUDFullText:@"登录信息失效，请重新登录"];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
        
    }
    [param setValue:UserModel.uid forKey:@"UID"];
    NSError * err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.requestDict options:NSJSONWritingPrettyPrinted error:&err];
    // 这里拦截解析字典出错
    if (err) {
    
        [YuanHUD HUDFullText:err.localizedDescription];
        
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    // jsonData有内容时，str一定不为空
    NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"jsonStr = %@",str);
    
    
    
    [param setValue:str forKey:@"jsonRequest"];
   
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    
    
#ifdef BaseURL
    NSString * url = [NSString stringWithFormat:@"%@%@",BaseURL,postUrl];
#else
    NSString * url = [NSString stringWithFormat:@"%@%@",BaseURL_Auto(([IWPServerService sharedService].link)),postUrl];
#endif
    
    [Http.shareInstance POST:url parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];

        
        NSLog(@"%@", dict);
        
        NSNumber * num = dict[@"success"];


        if (num.intValue == 1) {
            NSData * dataTmp = [dict[@"info"] dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary * retDict = [[NSJSONSerialization JSONObjectWithData:dataTmp options:NSJSONReadingAllowFragments error:nil] firstObject];
            
            NSLog(@"%@", dict[@"info"]);
            NSData *tempData=[REPLACE_HHF([dict objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            if (arr.count>0) {
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",@"操作成功"] message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if ([self.delegate respondsToSelector:@selector(newDeciceWithDict:)]) {
                        [self.delegate newDeciceWithDict:retDict];
                    }
                }];
                [alert addAction:action];
                Present(self, alert);
            }else{
               
                [YuanHUD HUDFullText:@"未知错误"];
            }
        }else{
            
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@保存失败",@"RFID信息"]];

        }
        
        [[Yuan_HUD shareInstance] HUDHide];

        
    }  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
