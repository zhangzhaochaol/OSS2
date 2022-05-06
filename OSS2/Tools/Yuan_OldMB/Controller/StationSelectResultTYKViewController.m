//
//  StationSelectResultViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/10/25.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "StationSelectResultTYKViewController.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"


#import "CusButton.h"
#import "LinePipeTableViewCell.h"
#import "IWPPropertiesReader.h"


#import "Yuan_SinglePicker.h"   //单行picker

@interface StationSelectResultTYKViewController ()<UITextFieldDelegate>
@property (nonatomic, weak) UIBarButtonItem * editItem;
@property (nonatomic, strong) NSMutableArray <NSIndexPath *> * indexPaths;
@property (nonatomic, strong) IWPPropertiesReader * reader;
@property (nonatomic, strong) IWPPropertiesSourceModel * model;
@property (nonatomic, strong) NSArray <IWPViewModel *>* viewModel;
@end

@implementation StationSelectResultTYKViewController
{
    CGFloat nowHight;
    UITextField *searchNameTextField;
    MBProgressHUD *HUD;
    
    Inc_UserModel *userModel;
    
    NSInteger start;// 从第几个开始
    NSInteger limit; // 获取多少个
    float tableCellHeight;
    
    UIButton * uploadButton;
    
    
    NSString * TYKNew_fileName;  //统一库新增了 UNI_前缀的 fileName ; 袁全添加--
    
    // 声明一个blcok 用于接收 (智能判障block)
    void(^_YuanBlock)(NSDictionary * cableMsg);
    
    // 声明一个block 用于接受 通用回调
    void(^_YuanNormalBlock)(NSDictionary * dict);
    
    // 声明一个block  用于从所属设备到ODB 后再回到楼宇
    void(^_YuanEquipmentPointToODFBlock)(NSDictionary * dict);
    
    
    BOOL _isYuan_Buliding;
    
    Yuan_SinglePicker * _picker;
    
    UITextField * _yuanChooseField;
    
    NSArray * _yuanBulidingChooseSource;
    
    NSArray * _IDsArr;
    
    NSArray * _fileNamesArr;
    
    NSString * _resTypeId;
    
    // 从设备放置点 到 ODF
    NSDictionary * _equipmentPointDict;
        

}
@synthesize stationArray;
@synthesize backStr;


- (instancetype) initWithResLogicName:(NSString *)resLogicName
                                Block:(void(^)(NSDictionary * cableMsg))block {
    
    if (self = [super init]) {
        _fileName = resLogicName;
        _YuanNormalBlock = block;
    }
    return self;
}


/// 袁全新增 构造方法 , 用于楼宇
- (instancetype) initWithBulid_ODBBlock:(void(^)(NSDictionary * cableMsg))block {
    
    if (self = [super init]) {
        
        _YuanBlock = block;
        _isYuan_Buliding = YES;
 
        
        
        
        
        _yuanBulidingChooseSource = @[@"设备放置点",@"光交接箱",@"光分纤箱",@"光缆接头"];
        _IDsArr = @[@"208",@"703",@"704",@"705"];
        _fileNamesArr = @[@"EquipmentPoint",@"OCC_Equt",@"ODB_Equt",@"joint"];
        
        // 初始化默认的resLogicName
        _fileName = @"EquipmentPoint";
        _resTypeId = @"208";
        
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            UIButton * leftButton= [UIButton buttonWithType:UIButtonTypeCustom];
            leftButton.titleLabel.textAlignment = NSTextAlignmentLeft;
            [leftButton setTitle:@"关闭" forState:UIControlStateNormal];
            leftButton.titleLabel.font = [UIFont systemFontOfSize:Horizontal(16)];
            [leftButton setFrame:CGRectMake(0, 0, Horizontal(44), Vertical(44))];
            [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [leftButton addTarget:self
                           action:@selector(back_Yuan)
                 forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem * leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
            self.navigationItem.leftBarButtonItem=leftBarButton;
            
        });
        
        
        
    }
    return self;
    
}




/// 当选择所属设备后 , 再去选择ODB
/// 当选择所属设备后 , 再去选择ODB
- (instancetype) initWithBulid_EquipmentPointTo_ODF:(NSDictionary *)equipmentPointDict
                                              Block:(void(^)(NSDictionary * odfBlock))odf_BackBlock {
    
    
    if (self = [super init]) {
        
        _equipmentPointDict = equipmentPointDict;
        
        _isYuan_Buliding = YES;
        
        _YuanEquipmentPointToODFBlock = odf_BackBlock;
        
        _yuanBulidingChooseSource = @[@"ODF"];
        _IDsArr = @[@"302"];
        _fileNamesArr = @[@"ODF_Equt"];

        // 初始化默认的resLogicName
        _fileName = @"ODF_Equt";
        _resTypeId = @"302";
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            UIButton * leftButton= [UIButton buttonWithType:UIButtonTypeCustom];
            leftButton.titleLabel.textAlignment = NSTextAlignmentLeft;
            [leftButton setTitle:@"关闭" forState:UIControlStateNormal];
            leftButton.titleLabel.font = [UIFont systemFontOfSize:Horizontal(16)];
            [leftButton setFrame:CGRectMake(0, 0, Horizontal(44), Vertical(44))];
            [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [leftButton addTarget:self
                           action:@selector(back_Yuan)
                 forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem * leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
            self.navigationItem.leftBarButtonItem=leftBarButton;
            
        });
        
    }
    
    return self;
}




- (void) back_Yuan {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



- (void)viewDidLoad {
    
    if (self.fileName) {
        [self createPropertiesReader];
    }
    
    else {
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少 resLogicName"];
    }
    
    
    self.view.backgroundColor=[UIColor whiteColor];
    

    userModel = Inc_UserModel.shareInstance;
    
    start = 1;
    limit = 20;
    
    //控件初始化
    if (_isYuan_Buliding) {
        self.title = @"查询列表";
        [self yuan_UIInit];
    }
    else {
        self.title = [NSString stringWithFormat:@"%@查询列表",self.model.name];
        [self uiInit];
    }
    

    [super viewDidLoad];
}

- (void)createPropertiesReader{
    
    TYKNew_fileName = [NSString stringWithFormat:@"UNI_%@",self.fileName];
    

    self.reader = [IWPPropertiesReader propertiesReaderWithFileName:TYKNew_fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
    self.model = [IWPPropertiesSourceModel modelWithDict:self.reader.result];
    // 创建viewModel
    NSMutableArray * arrr = [NSMutableArray array];
    for (NSDictionary * dict in self.model.view) {
        IWPViewModel * viewModel = [IWPViewModel modelWithDict:dict];
        [arrr addObject:viewModel];
    }
    self.viewModel = arrr;
}



- (void)yuan_UIInit {
    
    
    //搜索控件
    nowHight = [StrUtil heightOfTop]+16;/*80*/;
    UILabel *searchNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, nowHight, ScreenWidth/5, 30)];
    searchNameLabel.tag = 100;
    searchNameLabel.text = @"设备名称";
    searchNameLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:searchNameLabel];
    searchNameTextField =[[UITextField alloc] initWithFrame:CGRectMake(ScreenWidth/5+10, nowHight, ScreenWidth/5*3, 30)];
    [searchNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    searchNameTextField.tag = 200;
    searchNameTextField.returnKeyType = UIReturnKeyDone;
    //点击done关闭软键盘
    searchNameTextField.delegate = self;
    [self.view addSubview:searchNameTextField];
    
    UIButton *searchButton = [[UIButton alloc]initWithFrame:CGRectMake((ScreenWidth/5+10)+(ScreenWidth/5*3), nowHight-10, 40, 40)];
    [searchButton setImage:[UIImage Inc_imageNamed:@"search"] forState:UIControlStateNormal];
    //    [searchButton heightAnchor];
    [searchButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton];
    
    
    nowHight += 40;
    
    
    
    UILabel * device_type = [UIView labelWithTitle:@"设备类型" frame:CGRectMake(10, nowHight, ScreenWidth/5, 30)];
    
    device_type.font = Font_Bold_Yuan(14);
    
    [self.view addSubview:device_type];
    
    
    
    
    // 选择界面
    _yuanChooseField = [UIView textFieldFrame:CGRectMake(ScreenWidth/5+10,
                                                         nowHight,
                                                         ScreenWidth/5*3, 30)];
    
    [_yuanChooseField setBorderStyle:UITextBorderStyleRoundedRect];
    _yuanChooseField.textAlignment = NSTextAlignmentCenter;
    
    // 设置弹出
    [self createPicker];
    [self.view addSubview:_yuanChooseField];
    
    //查询结果列表
    nowHight += 30;
    UITableView * routeTableView=[[UITableView alloc] initWithFrame:CGRectMake(10, nowHight, ScreenWidth-20, ScreenHeight - nowHight-50) style:UITableViewStyleGrouped];
    _stationTableView = routeTableView;
        
    _stationTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [_stationTableView.mj_header endRefreshing];
        [self header];

    }];

    _stationTableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        [_stationTableView.mj_footer endRefreshingWithNoMoreData];
        [self footer];

    }];
    
    
    
    _stationTableView.backgroundColor=[UIColor whiteColor];
    [_stationTableView setEditing:NO];
    _stationTableView.delegate=self;
    _stationTableView.dataSource=self;
    [self.view addSubview:_stationTableView];
    
    
}


- (void) createPicker {
    
    CGRect pickerFrame = CGRectMake(0, 0, ScreenWidth, Vertical(250));

    
    

    _picker =
    [[Yuan_SinglePicker alloc] initWithFrame:pickerFrame
                          dataSource:_yuanBulidingChooseSource
                         PickerBlock:^(NSString * _Nonnull select) {}];


    _picker.backgroundColor = [UIColor whiteColor];
    _yuanChooseField.inputView = _picker;
    _yuanChooseField.text = _yuanBulidingChooseSource[0];

    
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, IphoneSize_Height(44))];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.clipsToBounds = YES;
    toolBar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *doneButton =  [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain  target:self action:@selector(commit)];
    doneButton.tintColor = [UIColor blueColor];

    doneButton.mainView = _yuanChooseField;

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain  target:self action:@selector(cancel)];
    cancelButton.mainView = _yuanChooseField;
    cancelButton.tintColor = [UIColor blueColor];


    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];

    _yuanChooseField.inputAccessoryView = toolBar;
    
}


/// 提交
- (void) commit {
    

    
    _yuanChooseField.text = _picker.selectRowTxt;
    
    // 获取索引
    NSInteger index = [_yuanBulidingChooseSource indexOfObject:_yuanChooseField.text];
    
    
    // 获得post 参数
    _resTypeId = [_IDsArr objectAtIndex:index];
    _fileName = [_fileNamesArr objectAtIndex:index];
    
    // 重新加载一遍模板
    [self createPropertiesReader];
    
    [self.view endEditing:YES];
        
    NSNotification * noti = [[NSNotification alloc] initWithName:@"Noti_DataPickerCommit"
                                                          object:nil
                                                        userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:noti];
}


- (void) cancel {
    
    // 取消
    [self.view endEditing:YES];
    
}





//控件初始化
-(void)uiInit{
    //搜索控件
    nowHight = [StrUtil heightOfTop]+16;/*80*/;
    UILabel *searchNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, nowHight, ScreenWidth/5, 30)];
    searchNameLabel.tag = 100;
    searchNameLabel.text = _showName ?: @"名称";
    searchNameLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:searchNameLabel];
    searchNameTextField =[[UITextField alloc] initWithFrame:CGRectMake(ScreenWidth/5+10, nowHight, ScreenWidth/5*3, 30)];
    [searchNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    searchNameTextField.tag = 200;
    searchNameTextField.returnKeyType = UIReturnKeyDone;
    //点击done关闭软键盘
    searchNameTextField.delegate = self;
    [self.view addSubview:searchNameTextField];
    
    UIButton *searchButton = [[UIButton alloc]initWithFrame:CGRectMake((ScreenWidth/5+10)+(ScreenWidth/5*3), nowHight-10, 40, 40)];
    [searchButton setImage:[UIImage Inc_imageNamed:@"search"] forState:UIControlStateNormal];
    //    [searchButton heightAnchor];
    [searchButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton];
    
    //查询结果列表
    nowHight += 30;
    UITableView * routeTableView=[[UITableView alloc] initWithFrame:CGRectMake(10, nowHight, ScreenWidth-20, ScreenHeight - nowHight-50) style:UITableViewStyleGrouped];
    _stationTableView = routeTableView;
    
    _stationTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [_stationTableView.mj_header endRefreshing];
        [self header];

    }];

    _stationTableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        [_stationTableView.mj_footer endRefreshingWithNoMoreData];
        [self footer];

    }];
    
    
    _stationTableView.backgroundColor=[UIColor whiteColor];
    [_stationTableView setEditing:NO];
    _stationTableView.delegate=self;
    _stationTableView.dataSource=self;
    [self.view addSubview:_stationTableView];
    
}
-(void)header{
    start = 1;
    NSString *resName = [searchNameTextField.text isEqualToString:@""] ? @"\"\"":[NSString stringWithFormat:@"\"%@\"",searchNameTextField.text];
    [self getResData:resName];
}
-(void)footer{
    
    start = stationArray.count+1;
    //    start += limit;
    NSString *resName = [searchNameTextField.text isEqualToString:@""] ? @"\"\"":[NSString stringWithFormat:@"\"%@\"",searchNameTextField.text];
    [self getResData:resName];
}
//查询
-(IBAction)search:(UIButton *)sender
{
    start = 1;
    NSString *resName = [searchNameTextField.text isEqualToString:@""] ? @"\"\"":[NSString stringWithFormat:@"\"%@\"",searchNameTextField.text];
    [self getResData:resName];
}
//获取资源信息线程
-(void)getResData:(NSString *) resName
{

    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];


    //调用查询接口
    NSDictionary *param;
    
    if ([self.doType isEqualToString:@"GetCableJoint"]) {
        //获取光缆段下接头盒
        param = @{@"UID":userModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"jointType\":\"1\",\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"%@\":%@}",start,limit,self.fileName,_model.list_sreach_name,resName]};
    }else if([self.doType isEqualToString:@"GetInterStart_EndDevice"]){
        //
        param = @{@"UID":userModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"jointType\":\"1\",\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"%@\":%@,\"%@\":%@}",start,limit,self.fileName,_model.list_sreach_name,resName,_ssDeviceKey,_ssDeviceId]};
    }
    
    else if (_equipmentPointDict && _YuanEquipmentPointToODFBlock) {
        
        NSMutableDictionary * jsReq = NSMutableDictionary.dictionary;
        jsReq[@"start"] = [Yuan_Foundation fromInteger:start];
        jsReq[@"limit"] = @"100";
        jsReq[@"resLogicName"] = _fileName;
        jsReq[@"posit_Type"] = @"2";
        jsReq[@"posit_Id"] = _equipmentPointDict[@"GID"];
        jsReq[_model.list_sreach_name] = searchNameTextField.text;
        
        param = @{@"UID":userModel.uid , @"jsonRequest":jsReq.json};
    }
    
    else{
        param = @{@"UID":userModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@:%@}",start,limit,self.fileName,_model.list_sreach_name,resName]};
    }
    NSLog(@"param %@",param);
    
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
    
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@rm!getCommonData.interface",baseURL] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
    
        
        
        NSDictionary *dic = responseObject;
        
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            HUD = nil;
            
            NSData *tempData=[REPLACE_HHF([dic objectForKey:@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:nil];
            
            if (arr.count == 0) {
                MBProgressHUD * alert = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                alert.label.text = @"未查询到相关信息";
                alert.detailsLabel.text = @"已无更多内容或未匹配到相关资源";
                alert.mode = MBProgressHUDModeText;
                alert.animationType = MBProgressHUDAnimationZoomIn;
                [alert hideAnimated:YES afterDelay:1.f];
                //            self.dataSource = nil;
                //            [self.tableView reloadData];
                [_stationTableView.mj_header endRefreshing];
                [_stationTableView.mj_footer endRefreshing];
                
                return;
            }
            if (stationArray == nil) {
                stationArray = [[NSMutableArray alloc] init];
            }
            if (start !=1 ) {
                for (NSDictionary * dict in arr) {
                    
                    [stationArray addObject:dict];
                }
            }else{
                stationArray = [[NSMutableArray alloc] initWithArray:arr];
            }
        }else{
            //操作执行完后取消对话框
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            //操作失败，提示用户
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            if (dic==nil ||([dic objectForKey:@"info"]==nil)) {
                HUD.label.text = @"操作失败，数据为空";
            }else{
                HUD.detailsLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"info"]];
            }
            HUD.mode = MBProgressHUDModeText;
            
                        dispatch_async(dispatch_get_main_queue(), ^{
                
                HUD.mode = MBProgressHUDModeText ;
                
                
                
                [HUD hideAnimated:YES afterDelay:2];
                
                HUD = nil;
            });
        }
        
        //        NSLog(@"%@",_array.count);
        [_stationTableView.mj_header endRefreshing];
        [_stationTableView.mj_footer endRefreshing];
        [_stationTableView reloadData];
        [self.view endEditing:YES];
        
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark tableviewdatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [stationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [NSString stringWithFormat:@"identifier%li%li",(long)indexPath.section,(long)indexPath.row];

    LinePipeTableViewCell *cell=[_stationTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[LinePipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.type = @"5";//其他类型
    NSDictionary *dic = stationArray[indexPath.row];
    cell.dict = dic;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    tableCellHeight = cell.backView.frame.size.height+6;

    return cell;
}
//点击带回给上一个页面

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
//    NSArray *array = [self.navigationController viewControllers];
//    if ([[array objectAtIndex:array.count-2] isKindOfClass:[GisMainViewController class]]) {
//        //从GIS信息页面进来
//        GisMainViewController *gisMainVC = (GisMainViewController *)[array objectAtIndex:array.count-2];
//        self.delegate=gisMainVC;
//        [self.delegate getRoute:[routeArray objectAtIndex:indexPath.row]];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    
    NSDictionary * dict = self.stationArray[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(deviceWithDict:withSenderTag:)] == YES) {
        
        if ([self.doType isEqualToString:@"GetCableJoint"]) {
            [self.delegate deviceWithDict:dict withSenderTag:_senderTag];
        }else{
            [self.delegate deviceWithDict:dict withSenderTag:_senderTag];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    
    if (_YuanEquipmentPointToODFBlock) {
        
        NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
        mt_Dict[@"resTypeId"] = _resTypeId;
        
        [UIAlert alertSmallTitle:@"是否选择此设备" vc:self agreeBtnBlock:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                // 选中想要的ODF设备
                _YuanEquipmentPointToODFBlock(mt_Dict);
            }];
        }];
    }

    
    
    // 楼宇时使用
    
    if (_YuanBlock) {
        
        NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
        mt_Dict[@"resTypeId"] = _resTypeId;
        
        [UIAlert alertSmallTitle:@"是否选择此设备" vc:self agreeBtnBlock:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                _YuanBlock(mt_Dict);
            }];
            
        }];
        
        
    }
    
    // 通用跳转
    if (_YuanNormalBlock) {
        
        [UIAlert alertSmallTitle:@"是否选择此设备" vc:self agreeBtnBlock:^(UIAlertAction *action) {
            
            NSString * nameKey = _model.list_sreach_name;
            
            NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
            mt_Dict[@"deviceName"] = dict[nameKey];
            
            _YuanNormalBlock(mt_Dict);
            Pop(self);
            
        }];
    }
    
    
}

#pragma mark tableviewdelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableCellHeight;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //当捕捉到触摸事件时，取消UITextField的第一响应
    if ([(UITextField *)[self.view viewWithTag:200] isFirstResponder]) {
        [(UITextField *)[self.view viewWithTag:200] resignFirstResponder];
    }
}
//隐藏键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
