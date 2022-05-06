//
//  EquModelTYKViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/8/31.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "EquModelTYKViewController.h"

#import "CusButton.h"
#import "MBProgressHUD.h"

#import "StrUtil.h"
#import "EquModelTYKCell.h"
#import "TYKDeviceInfoMationViewController.h"

@interface EquModelTYKViewController ()<UITableViewDataSource,UITableViewDelegate,ptotocolDelegate>
@property (weak, nonatomic) UITableView *modelTableView;
@end

@implementation EquModelTYKViewController
{
    MBProgressHUD *HUD;
    
    StrUtil *strUtil;
    NSMutableArray *shelfsArray;//机框列表
    float tableCellHeight;
}

- (void)viewDidLoad {
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.title = @"设备平面图";
    

    strUtil = [[StrUtil alloc]init];
    
    [self uiInit];
    [self getShelfData];
    [super viewDidLoad];
}
-(void)uiInit{
    UITableView * modelTableView=[[UITableView alloc] initWithFrame:CGRectMake(5, 0, ScreenWidth-10, ScreenHeight) style:UITableViewStyleGrouped];
    _modelTableView = modelTableView;
    _modelTableView.backgroundColor=[UIColor whiteColor];
     _modelTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_modelTableView setEditing:NO];
    _modelTableView.delegate=self;
    _modelTableView.dataSource=self;
    [self.view addSubview:_modelTableView];
}
//获取机框信息
-(void)getShelfData{

    [Yuan_HUD.shareInstance HUDStartText:@"正在加载设备信息"];
    
    NSDictionary * param = nil;
    
    param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"resLogicName\":\"shelf\",\"GID\":\"%@\"}",[self.dicIn objectForKey:@"GID"]]};
    
    
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto([IWPServerService sharedService].link);
#endif
    
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@rm!getShelfInfoContainsSlotCardByEqp.interface",baseURL] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        
        NSDictionary *dic = responseObject;
        

        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
           
            NSData *tempData=[[[NSMutableDictionary dictionaryWithDictionary:dic] objectForKey:@"info"] dataUsingEncoding:NSUTF8StringEncoding];
            
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"arr--:%@",arr);
            if (arr.count>0) {
                shelfsArray = [[NSMutableArray alloc] initWithArray:arr[0][@"shelfs"]];
                [_modelTableView reloadData];
            }
         
        }else{
            
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];
            
        }

        [[Yuan_HUD shareInstance] HUDHide];

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}
//获取端子数据
-(void)getPointsData:(NSMutableDictionary *) requescDic{

    [Yuan_HUD.shareInstance HUDStartText:@"正在加载设备信息"];

    
    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"resLogicName\":\"port\",\"GID\":\"%@\"}",requescDic[@"GID"]]};
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto([IWPServerService sharedService].link);
#endif
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@rm!getPortInfoByCard.interface",baseURL] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        NSDictionary *dic = responseObject;

        if ([dic objectForKey:@"info"] == [NSNull null]) {
            
            [YuanHUD HUDFullText:@"数据异常"];
            
            return ;
        }
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {

            
            NSData *tempData=[[[NSMutableDictionary dictionaryWithDictionary:dic] objectForKey:@"info"] dataUsingEncoding:NSUTF8StringEncoding];
            
            //TODO:
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            [dataDic setObject:arr forKey:@"dataDic"];
            
            TYKDeviceInfoMationViewController * deviceInfo = [[TYKDeviceInfoMationViewController alloc] initWithControlMode:TYKDeviceInfomationTypeDuanZiMianBan_Update withMainModel:nil withViewModel:nil withDataDict:dataDic withFileName:@"port"];
            
            deviceInfo.sourceFileName = self.dicIn[kResLogicName];
            
            deviceInfo.card_code = [requescDic[@"positionCode"] integerValue];
            
            
            
            
            [self.navigationController pushViewController:deviceInfo animated:YES];
        }else{
           
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];
            
        }
        
        [[Yuan_HUD shareInstance] HUDHide];


        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框

        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
}
#pragma mark tableviewdatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [shelfsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [NSString stringWithFormat:@"identifier%li%li",(long)indexPath.section,(long)indexPath.row];
    EquModelTYKCell *cell=[_modelTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[EquModelTYKCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    NSDictionary *dic = shelfsArray[indexPath.row];
    cell.dict = dic;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    tableCellHeight = cell.backView.frame.size.height+6;
   
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableCellHeight;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)doSomeThingo:(NSDictionary *)dic{
    if ([dic[@"doType"] isEqualToString:@"clickPan"]) {
        [self getPointsData:dic[@"panInfo"]];
    }
}
@end
