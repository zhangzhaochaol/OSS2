//
//  IWPCableRFIDScannerViewController.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/7/8.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPCableRFIDScannerViewController.h"
#import "IWPSaoMiaoViewController.h"
#import "IWPButton.h"
#import "MBProgressHUD.h"
#import "QRCodeUtil.h"

@interface IWPCableRFIDScannerViewController () <ptotocolDelegate, UITextViewDelegate>
@property (nonatomic, weak) UITextView * textField;
@property (nonatomic, assign) BOOL isSaved;
@property (nonatomic, assign) bool isGoScan;
@property (nonatomic, strong) NSDictionary * cable;
@property (nonatomic, weak) MBProgressHUD * HUD;
@end

@implementation IWPCableRFIDScannerViewController
{
    BOOL isStopScan;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫描标签";
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"$%@",self.cableInfo);
    [self configSubviews];
   
    
    // Do any additional setup after loading the view.
}
#pragma mark - 重写
-(void)setRFID:(NSString *)RFID{
    _RFID = RFID;
    self.textField.text = RFID;
}
-(void)configSubviews{
    CGFloat x,y,w,h;
    
    x = 0;
    y = 70.f;
    w = ScreenWidth;
    h = 30;
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
    titleLabel.text = @"扫描标签";
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    y = CGRectGetMaxY(titleLabel.frame) + 10.f;
    UILabel * hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
    hintLabel.text = @"标签号:";
    hintLabel.font = [UIFont boldSystemFontOfSize:14];
    
    [self.view addSubview:hintLabel];
    
    x = 5.f;
    y = CGRectGetMaxY(hintLabel.frame) + 5.f;
    w = ScreenWidth - 10.f;
    h = 40;
    UITextView * textField = [[UITextView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    self.textField = textField;
    [self.view addSubview:textField];
    
    
    [textField  YuanToSuper_Right:5];
    [textField  YuanToSuper_Left:5];
    [textField autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:hintLabel withOffset:5];
    [textField autoSetDimension:ALDimensionHeight toSize:40];

//    textField.sd_layout.leftSpaceToView(self.view, 5.f)
//    .rightSpaceToView(self.view, 5.f)
//    .topSpaceToView(hintLabel, 5.f)
//    .heightIs(40.f);
    
    textField.layer.borderColor = [UIColor colorWithHexString:@"#4d4d4d"].CGColor;
    textField.layer.borderWidth = .7f;
    textField.layer.cornerRadius = 5.f;
    textField.layer.masksToBounds = true;
    
    textField.font = [UIFont systemFontOfSize:16.f];
    textField.text = [self.cableInfo[kCableRfid] isEqualToString:@" "] ? @"" : self.cableInfo[kCableRfid];
    textField.delegate = self;
    textField.editable = false;
    
    [self changeTextFiledHeight];
    
//    textField.userInteractionEnabled = NO;
    
    NSArray * btnTitles = @[@"二维码",@"确认绑定"];
    
    y = CGRectGetMaxY(textField.frame) + 20.f;
    w = ScreenWidth / 2.f;
    h = 40;
    
    
    IWPButton * lastBtn = nil;
    for (int i = 0; i < btnTitles.count; i++) {
        x = i * w;
        IWPButton * btn = [IWPButton buttonWithType:UIButtonTypeSystem];
        [self.view addSubview:btn];
        
        
        
        if (btn == nil) {
            btn.frame = CGRectMake(5, textField.height + textField.origin.y + 10, self.view.width *0.4, 40);
//            btn.sd_layout.leftSpaceToView(self.view, 5.f)
//            .widthRatioToView(self.view, .4f)
//            .topSpaceToView(textField, 10.f)
//            .heightIs(40.f);
        }else{
            
            btn.frame = CGRectMake(lastBtn.origin.x + lastBtn.width + 5, textField.height + textField.origin.y + 10, self.view.width *0.4, 40);

//            btn.sd_layout.leftSpaceToView(lastBtn, 5.f)
//            .widthRatioToView(self.view, .4f)
//            .topSpaceToView(textField, 10.f)
//            .heightIs(40.f);
        }
//        __weak typeof(btn) wbtn = btn;
//        btn.didFinishAutoLayoutBlock = ^(CGRect frame) {
//
//            wbtn.frame = frame;
//
//        };
        
        lastBtn = btn;
        
        [btn setTitle:btnTitles[i] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor mainColor]];
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        btn.tintColor = [UIColor whiteColor];
        btn.tag = 10000 + i;
        [btn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    
        
        
        
        
    }
}

-(void)makeRfidText:(NSString *)rfidText{
    if (!isStopScan) {
        isStopScan = YES;
        //1.验证二维码位数是否为128位或者256位
        if (!(rfidText.length == 128 || (rfidText.length == 256))) {

            [YuanHUD HUDFullText:@"标签不合格"];
            
            id vc = self.navigationController.viewControllers.lastObject;
            if (!([vc class] ==  [self class])) {
                // 是否跳转
                [self.navigationController popViewControllerAnimated:YES];
            }
            return;
        }
        //2.验证校验位是否都对
        QRCodeUtil *btutil = [[QRCodeUtil alloc] init];
        //第一次校验
        NSString *arcCodeStr = [btutil generateCRC:[rfidText substringWithRange:NSMakeRange(18, 23)]];
        NSLog(@"arcCodeStr:%@",arcCodeStr);
        NSLog(@"arcCodeStr2:%@",[rfidText substringWithRange:NSMakeRange(41, 2)]);
        if ([arcCodeStr isEqualToString:[rfidText substringWithRange:NSMakeRange(41, 2)]]) {
            //第二次校验
            arcCodeStr = [btutil generateCRC:[rfidText substringWithRange:NSMakeRange(43, 19)]];
            NSLog(@"arcCodeStr:%@",arcCodeStr);
            NSLog(@"arcCodeStr2:%@",[rfidText substringWithRange:NSMakeRange(62, 2)]);
            if ([arcCodeStr isEqualToString:[rfidText substringWithRange:NSMakeRange(62, 2)]]) {
                //校验位正确，调用中心接口进行验证
                [self getRfidBatchDate:rfidText];
            }else{
                //提示用户
                [YuanHUD HUDFullText:@"标签不合格"];

                id vc = self.navigationController.viewControllers.lastObject;
                if (!([vc class] ==  [self class])) {
                    // 是否跳转
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }else{
            //提示用户
            [YuanHUD HUDFullText:@"标签不合格"];

            id vc = self.navigationController.viewControllers.lastObject;
            if (!([vc class] ==  [self class])) {
                // 是否跳转
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
//    self.textField.text = rfidText;
//    _isGoScan = NO;
//    // 轉換傳入字典
//    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.cableInfo];
//
//    [dict setValue:rfidText forKey:kCableRfid];
//    self.cable = dict;
//
//    id vc = self.navigationController.viewControllers.lastObject;
//
//    if (!([vc class] ==  [self class])) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    
}
//获取当前二维码是否合法
-(void)getRfidBatchDate:(NSString *)rfidText
{
    //调用查询接口

    NSDictionary *param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"resLogicName\":\"rfidBatch\",code:%@}",rfidText]};
    
    NSLog(@"param %@",param);
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@data!getData.interface",baseURL] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        

        NSDictionary *dic = responseObject;
        
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            //成功，显示在界面上
            self.textField.text = rfidText;
            
            [self changeTextFiledHeight];
            
            _isGoScan = NO;
            // 轉換傳入字典
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.cableInfo];
            
            [dict setValue:rfidText forKey:kCableRfid];
            self.cable = dict;
            
            id vc = self.navigationController.viewControllers.lastObject;
            
            if (!([vc class] ==  [self class])) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }else{
            //查询失败，提示用户
            
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];

            
            id vc = self.navigationController.viewControllers.lastObject;
            if (!([vc class] ==  [self class])) {
                // 是否跳转
                [self.navigationController popViewControllerAnimated:YES];
            }
        }

        
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        //操作执行完后取消对话框
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        
        id vc = self.navigationController.viewControllers.lastObject;
        if (!([vc class] ==  [self class])) {
            // 是否跳转
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
#pragma mark RFID读卡器扫描回调
-(void)returnSaomiaoRfid:(NSString *)rfidStr{
    NSLog(@"rfidStr:%@",rfidStr);
    [self makeSaomiaoRfidText:rfidStr];
}
-(void)makeSaomiaoRfidText:(NSString *)rfidText{
    self.textField.text = rfidText;
    
    [self changeTextFiledHeight];
    _isGoScan = NO;
    // 轉換傳入字典
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.cableInfo];
    
    [dict setValue:rfidText forKey:kCableRfid];
    self.cable = dict;
    
    id vc = self.navigationController.viewControllers.lastObject;
    
    if (!([vc class] ==  [self class])) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)changeTextFiledHeight{
    
    CGSize maxSize = CGSizeMake(self.textField.frame.size.width, self.view.frame.size.height / 1.7f);
    
    CGSize size = [self.textField.text boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.textField.font} context:nil].size;
    
    size.height += 10.f;
    
    NSLog(@"%@", NSStringFromCGSize(size));
    
    
    if (size.height > 40) {
        self.textField.height = size.height;
        
//        self.textField.sd_layout.heightIs(size.height);
    }else{
//        self.textField.sd_layout.heightIs(40.f);
        self.textField.height = size.height;

    }
    
    
}

-(void)btnHandler:(IWPButton *)sender{
    if (sender.tag % 2 == 0) {
        // 扫描二维码
        isStopScan = NO;
        IWPSaoMiaoViewController * saomiao = [[IWPSaoMiaoViewController alloc] init];
        saomiao.isGet = YES;
        _isGoScan = YES;
        saomiao.delegate = self;
        [self.navigationController pushViewController:saomiao animated:YES];
    }else{
        // 如果沒掃描
        if ([self.textField.text isEqualToString:@" "] || self.textField.text.length == 0) {
         
            [YuanHUD HUDFullText:@"尚未扫描任何二维码信息"];
            
            return;
        }
        
        _isSaved = YES;
        if ([self.delegate respondsToSelector:@selector(cableWithDict:)]) {
            // 判斷是否有被修改
            NSString * rfid = self.cable[kCableRfid];
            if ([rfid isEqualToString:self.textField.text]) {
                // 沒有被修改, 直接返回
                [self.delegate cableWithDict:self.cable];
                
            }else{
                // 被修改
                
                NSString * newRFID = self.textField.text;
                if (self.textField.text.length == 0) {
                    // 如果為空, 置為@" "
                    newRFID = @" ";
                }
                // 替換為新的 rfid
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.cableInfo];
                [dict setValue:newRFID forKey:kCableRfid];
                self.cable = dict;
                if ([self.delegate respondsToSelector:@selector(cableWithDict:)]) {
                    [self.delegate cableWithDict:self.cable];
                }
                
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else if (self.handler) {
            
            // 判斷是否有被修改
            NSString * rfid = self.cable[kCableRfid];
            if ([rfid isEqualToString:self.textField.text]) {
                // 沒有被修改, 直接返回
                 self.handler(rfid);
                
            }else{
                // 被修改
                
                NSString * newRFID = self.textField.text;
                if (self.textField.text.length == 0) {
                    // 如果為空, 置為@" "
                    newRFID = @" ";
                }
                // 替換為新的 rfid
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.cableInfo];
                [dict setValue:newRFID forKey:kCableRfid];
                self.cable = dict;
                
                self.handler(newRFID);

                
            }
            
            
           
        }
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//-(void)viewWillDisappear:(BOOL)animated{
//    if (!_isSaved && !_isGoScan) {
//        
//        if ([self.delegate respondsToSelector:@selector(cableWithDict:)]) {
//            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.cableInfo];
//            if ([dict[kCableRfid] length] == 0) {
//                [dict setValue:@" " forKey:kCableRfid];
//            }
//            [self.delegate cableWithDict:dict];
//        }
//    }
//}

-(void)viewDidDisappear:(BOOL)animated{
    
    
    //  2017年01月20日 测试发现， 滑动nav时就会加入一个，导致重复添加。修改1：在这里加入重复验证。修改2：将扫描界面中的“返回带回”的viewWillDisapper改为ViewDidDisapper
    if (!_isSaved && !_isGoScan) {

        if ([self.delegate respondsToSelector:@selector(cableWithDict:)]) {
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.cableInfo];
            if ([dict[kCableRfid] length] == 0) {
                [dict setValue:@" " forKey:kCableRfid];
            }
            [self.delegate cableWithDict:dict];
        }
    }
    [super viewDidDisappear:animated];
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
