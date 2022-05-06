//
//  Inc_HomeResCollectionVC.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/6/28.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_HomeResCollectionVC.h"


#import "ResourceTYKListViewController.h"
#import "MBProgressHUD.h"
#import "CollectionViewCell.h"
#import "SaoMiaoTYKViewControllerViewController.h"
#import "GisTYKMainViewController.h"
#import "IWPPropertiesReader.h"
#import "TYKDeviceInfoMationViewController.h"
//#import "CableTYKViewController.h"
#import "GeneratorTYKViewController.h"
//#import "GeneratorSSSBTYKInfoViewController.h"

#import "Yuan_NewFL_SearchListVC.h"              //局向光纤 和 光路列表入口
#import "InstrumentsMainViewController.h"        //仪器仪表

#import "Inc_Push_MB.h"
#import "Inc_NewMB_ListVC.h"           //新模板

#define Yuan_TYKMainDict true


/*以iPhone6为标准进行横向缩放*/
#define Zoomx [UIScreen mainScreen].bounds.size.width/375
/*以iPhone6为标准进行纵向缩放*/
#define Zoomy [UIScreen mainScreen].bounds.size.height/667


@interface Inc_HomeResCollectionVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, TYKDeviceInfomationDelegate>
@property (weak, nonatomic) UICollectionView *collectionView;
@property (nonatomic, weak) UIViewController * vc;
@end
static NSString *resourceTYKMainTitleStr = @"统一资源库";
@implementation Inc_HomeResCollectionVC
{
    NSMutableArray *imageArr;
    NSMutableArray *titleArr;
    
    MBProgressHUD *HUD;
    
    NSString *userPower;//用户权限
    Inc_UserModel *userModel;
}
@synthesize subItemArr;
- (void)viewDidLoad {
    
    [self viewDidLoad];
    

    imageArr = [[NSMutableArray alloc] init];
    titleArr = [[NSMutableArray alloc] init];
    userModel = Inc_UserModel.shareInstance;
    
    userPower = userModel.powersTYKDic[@"powers"];
    
    NSString * tykMainDict_File ;
    
    
    #if Yuan_TYKMainDict
    tykMainDict_File = @"Yuan_TYKResourceMainDic";
    #else
    tykMainDict_File = @"TYKResourceMainDic";
    #endif
    
    
    if (v_HLJ) {
        tykMainDict_File = @"Yuan_TYKResourceMainDic_V1";
    }
    
    
    //添加自定义功能类按钮
    if ([self.title isEqualToString:@"统一资源库"]) {
        // 读取文件内容

        // 本地还是走云端
        if (_sourceString == nil) {
            _sourceString = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@",DOC_DIR,kResourceMainProps,@"Yuan_TYKResourceMainDic.properties"] encoding:NSUTF8StringEncoding error:nil];
        }
        
        if (_sourceString.length == 0) {
            
            
            _sourceString = [NSString stringWithContentsOfFile:[NSBundle.mainBundle pathForResource:tykMainDict_File ofType:@"properties"] encoding:NSUTF8StringEncoding error:nil];
        }
        
        
        NSDictionary *itemDic = [self analysisFileWithSourceString:self.sourceString :@"subItem"];
        
        subItemArr = LoadJSONFile(tykMainDict_File);
        
        
        NSMutableDictionary *selfDic = [[NSMutableDictionary alloc] init];
        [selfDic setObject:@"qcode_IWP" forKey:@"image"];
        [selfDic setObject:@"二维码" forKey:@"title"];
        
        NSMutableDictionary *gisDic = [[NSMutableDictionary alloc] init];
        [gisDic setObject:@"gis_base" forKey:@"image"];
        [gisDic setObject:@"GIS定位" forKey:@"title"];
        
        
        NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:subItemArr];
#if VERSION_INSPECTION_HENAN && IS_HENAN_VERSION && IS_XUNJIAN_VERSION

        [temp addObject:selfDic];
        [temp addObject:gisDic];

#endif
         
        
        subItemArr = temp;
        
    }
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:subItemArr];
    //去除不在当前登录用户权限下的菜单
    if (userPower!=nil) {
        for (NSDictionary *tempDic in [temp copy]) {
            BOOL isHave = NO;
            for (NSString *str in [userPower componentsSeparatedByString:@","]) {
                if ([tempDic[@"power"] isEqualToString:str]) {
                    isHave = YES;
                    //  if (![tempDic[@"fileName"] isEqualToString:@"markStonePath"]) {
                    //      break;
                    //  }
                }
            }
            
            if ([tempDic[@"title"] isEqualToString:@"二维码"]||[tempDic[@"title"] isEqualToString:@"GIS定位"]) {
                isHave = YES;
            }
            
            // 暂时屏蔽综合箱  yes 显示
            if ([tempDic[@"fileName"] isEqualToString:@"complexBox"]) {
                isHave = YES;
            }
            
            if (!isHave) {
                [temp removeObject:tempDic];
            }
        }
    }
    
    subItemArr = temp;
    //分别生成图片和名称的二维数组
    NSMutableArray *arrImageTemp;
    NSMutableArray *arrTitleTemp;
    for (int i = 0; i<subItemArr.count; i++) {
        
        if (i%3 == 0) {
            arrImageTemp = [[NSMutableArray alloc] init];
            arrTitleTemp = [[NSMutableArray alloc] init];
        }
        [arrImageTemp addObject:subItemArr[i][@"image"]];
        [arrTitleTemp addObject:subItemArr[i][@"title"]];
        
        if ((i+1)%3 == 0) {
            [imageArr addObject:arrImageTemp];
            [titleArr addObject:arrTitleTemp];
        }else if (i ==subItemArr.count-1){
            if (arrImageTemp.count<3) {
                //如果数组元素个数不足3，则需要补足位数
                for (int j = 0; j<=(3-arrImageTemp.count); j++) {
                    [arrImageTemp addObject:@""];
                    [arrTitleTemp addObject:@""];
                }
            }
            
            [imageArr addObject:arrImageTemp];
            [titleArr addObject:arrTitleTemp];
        }
    }
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) collectionViewLayout:flowLayout];
    _collectionView = collectionView;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self.view addSubview:_collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 3;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (imageArr.count == 1) {
        [_collectionView setFrame:CGRectMake(0, ScreenHeight/3, ScreenWidth, ScreenHeight)];
    }else if (imageArr.count == 2){
        [_collectionView setFrame:CGRectMake(0, ScreenHeight/4, ScreenWidth, ScreenHeight)];
    }else if (imageArr.count == 3){
        [_collectionView setFrame:CGRectMake(0, ScreenHeight/7, ScreenWidth, ScreenHeight)];
    }
    return imageArr.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@/%@",DOC_DIR,kResourceMainProps,imageArr[indexPath.section][indexPath.row]];
    //        NSLog(@"现在的图片路径:%@",imagePath);
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    //        cell.imageView.image = [UIImage Inc_imageNamed:imageArr[indexPath.section][indexPath.row]];
    

    if (image == nil) {
        NSString * imageName = imageArr[indexPath.section][indexPath.row];
        
        if ([imageName isEqualToString:@"markStonePath"] ) {
            NSString *imagePath = [NSString stringWithFormat:@"%@/%@/%@",DOC_DIR,kResourceMainProps,@"markStonePath.png"];

            image = [UIImage imageWithContentsOfFile:imagePath];
        }
        else {
            
            // 仪器仪表 光纤光路 局限光纤
            image = [UIImage Inc_imageNamed:imageName];
            
        }
        
        
        
    }
    
    cell.imageView.image = image;
    
    if ([self.title isEqualToString:@"统一资源库"] && [titleArr[indexPath.section][indexPath.row] isEqualToString:@"二维码"]) {
        cell.imageView.image = [UIImage Inc_imageNamed:imageArr[indexPath.section][indexPath.row]];
    }
    if ([self.title isEqualToString:@"统一资源库"] && [titleArr[indexPath.section][indexPath.row] isEqualToString:@"GIS定位"]) {
        cell.imageView.image = [UIImage Inc_imageNamed:imageArr[indexPath.section][indexPath.row]];
    }
    
    cell.textLabel.text = titleArr[indexPath.section][indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    if ([cell.textLabel.text isEqualToString:@"分组传送网资源(IPRAN)"]) {
        cell.textLabel.font = [UIFont systemFontOfSize:12];
    }
    if (![self.title isEqualToString:@"统一资源库"]) {
        if ([cell.textLabel.text isEqualToString:@"网关（PGW,SGW）"]) {
            cell.textLabel.font = [UIFont systemFontOfSize:9];
        }else{
            cell.textLabel.font = [UIFont systemFontOfSize:12];
        }
    }
    
    return cell;
}
#pragma mark UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(80*Zoomx, 115*Zoomy);
    
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    NSInteger posX = 80;
    
    if (subItemArr.count>2) {
        posX = 30;
    }else if (subItemArr.count == 1){
        posX = 150;
    }
    
    return UIEdgeInsetsMake(10, posX*Zoomx, 10, posX*Zoomx);
}
#pragma mark UIColletionViewDelegate
/*-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([imageArr[indexPath.section][indexPath.row] isEqualToString:@""]) {
        return;
    }
    if ([imageArr[indexPath.section][indexPath.row] isEqualToString:@"qcode_IWP"]) {
        SaoMiaoTYKViewControllerViewController * saomiao  = [[SaoMiaoTYKViewControllerViewController alloc] init];
        [self.navigationController pushViewController:saomiao animated:YES];
    }else{
        ResourceTYKListViewController * resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
        resourceTYKListVC.fileName = imageArr[indexPath.section][indexPath.row];
        resourceTYKListVC.showName = titleArr[indexPath.section][indexPath.row];
        [self.navigationController pushViewController:resourceTYKListVC animated:YES];
    }
}*/
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString * fileName = imageArr[indexPath.section][indexPath.row];
    if (fileName.length == 0) {
        return; // 代表没文件
    }
    if (subItemArr[indexPath.section*3+indexPath.row][@"subItem"] != nil) {
        NSArray *subArr = subItemArr[indexPath.section*3+indexPath.row][@"subItem"];
        Inc_HomeResCollectionVC *resourceMainAutoVC = [[Inc_HomeResCollectionVC alloc] init];
        resourceMainAutoVC.subItemArr = subArr;
        [Inc_HomeResCollectionVC setResourceTYKMainTitleStr:subItemArr[indexPath.section*3+indexPath.row][@"title"]];
        resourceMainAutoVC.title = subItemArr[indexPath.section*3+indexPath.row][@"title"];
        [self.navigationController pushViewController:resourceMainAutoVC animated:YES];
    }else{
        BOOL isShowEditBtn = YES;
        
        if ((subItemArr[indexPath.section*3+indexPath.row][@"isHaveAddBtn"]!=nil)&&
            ([subItemArr[indexPath.section*3+indexPath.row][@"isHaveAddBtn"] isEqualToString:@"no"])) {
            isShowEditBtn = NO;
        }
        

        
        NSDictionary * dict = subItemArr[indexPath.section*3+indexPath.row];
        
        
        
        
        if ([dict[@"title"] isEqualToString:@"仪器仪表"]) {
            InstrumentsMainViewController * instrument = InstrumentsMainViewController.alloc.init;
            Push(self, instrument);
            return;
        }
        
//        // 如果是OLT 跳跳清查库
//        if ([dict[@"title"] isEqualToString:@"OLT"]) {
//            [Inc_Push_MB push_QCDataBase_PushFrom:self fileName:dict[@"fileName"]];
//            return;
//        }
        
        
        if ([dict[@"title"] isEqualToString:@"光纤光路"] ||
            [dict[@"title"] isEqualToString:@"光路"]) {
            
            Yuan_NewFL_SearchListVC * link = [[Yuan_NewFL_SearchListVC alloc] initWithEnterType:NewFL_EnterType_Link];
            Push(self, link);
            return;
        }
        
        if ([dict[@"title"] isEqualToString:@"局向光纤"]) {
            Yuan_NewFL_SearchListVC * link = [[Yuan_NewFL_SearchListVC alloc] initWithEnterType:NewFL_EnterType_Route];
            Push(self, link);
            return;
        }
        
        
        if ([dict[@"title"] isEqualToString:@"分光器"]) {
            // Yuan_NewMB_ModelEnum_obd
            Inc_NewMB_ListVC * list = [[Inc_NewMB_ListVC alloc] initWithModelEnum:Yuan_NewMB_ModelEnum_obd];
            
            Push(self, list);
            return;
        }
        
        // 新模板
        if ([dict[@"create"] isEqualToString:@"yuan"]) {
            
            Inc_NewMB_VM * VM = Inc_NewMB_VM.viewModel;
            
            Yuan_NewMB_ModelEnum_ Enum = [VM EnumFromFileName:dict[@"fileName"]];
            
            if (Enum == Yuan_NewMB_ModelEnum_None) {
                [YuanHUD HUDFullText:@"未检测到该资源"];
                return;
            }
            
            Inc_NewMB_ListVC * list = [[Inc_NewMB_ListVC alloc] initWithModelEnum:Enum];
            
            Push(self, list);
            return;
            
        }
        
        if ([dict[@"fileName"] isEqualToString:@"generator"]) {
            
            Inc_NewMB_ListVC * newMB =
            [[Inc_NewMB_ListVC alloc] initWithModelEnum:Yuan_NewMB_ModelEnum_room];
            
            Push(self, newMB);
            return;
        }
        
        
        if ([dict[@"fileName"] isEqualToString:@"cable"]) {
            
            Inc_NewMB_ListVC * newMB =
            [[Inc_NewMB_ListVC alloc] initWithModelEnum:Yuan_NewMB_ModelEnum_optSect];
            
            Push(self, newMB);
            return;
        }
        
        
        if (dict[@"fileName"] == nil) {
            return;
        }
        
        
        ResourceTYKListViewController * resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
        resourceTYKListVC.fileName = imageArr[indexPath.section][indexPath.row];
        resourceTYKListVC.showName = titleArr[indexPath.section][indexPath.row];
        [self.navigationController pushViewController:resourceTYKListVC animated:YES];
    }
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSDictionary *)analysisFileWithSourceString:(NSString *)sourceString :(NSString *)comperKey{
    NSMutableArray * sourceArray = [NSMutableArray arrayWithArray:[sourceString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]]];
    for (int j = 0; j < 5; j++) {
        for (int i = 0; i < sourceArray.count; i++) {
            if ([sourceArray[i] length] == 0 ||
                [sourceArray[i] hasPrefix:@"#"]) {
                [sourceArray removeObjectAtIndex:i];
            }
        }
    }
    return [self createDictionayWithSourceArray:sourceArray:comperKey];
}

-(NSDictionary *)createDictionayWithSourceArray:(NSArray *)sourceArray :(NSString *)comperKey{
    
   
    NSString * cutStr = @"=";

    
    NSMutableArray * keys = [NSMutableArray array];
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    for (NSString * string in sourceArray) {
        NSArray * arr = [string componentsSeparatedByString:cutStr];
        
        NSString * key = arr[0];
        NSString * object = [arr[1] stringByReplacingOccurrencesOfString:@"\\:" withString:@":"];
        
        
        [result setValue:object forKey:key];
        [keys addObject:key];
    }
    
    NSString * s = [NSMutableString stringWithString:@"{"];
    for (NSString * key in keys) {
        if ([key isEqualToString:comperKey]) {
            s = [s stringByAppendingString:[NSString stringWithFormat:@"\"%@\":%@,",key,[result valueForKey:key]]];;
            continue;
        }
        NSString * strTmp = [result valueForKey:key];
        s = [s stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\",",key,strTmp]];
    }
    
    NSMutableString * str = [s mutableCopy];
    NSRange range = {str.length - 1,1};
    s = [str stringByReplacingCharactersInRange:range withString:@"}"];
    
    NSData * data = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError * err = nil;
    
    //    s = [[s stringByReplacingOccurrencesOfString:@"\\:" withString:@":"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSLog(@"%@", s);
    
    
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
    
    NSLog(@"dict:%@ --- %@",dict,err.localizedDescription);
    return  dict;
}
+ (void)setResourceTYKMainTitleStr:(NSString *)str{
    resourceTYKMainTitleStr = str;
}

//代理方法，扫描RFID结果
-(void)makeRfidText:(NSString *)rfidText{
    if (self.vc == nil) {
        [self requestWithResLogicName:@"rfidInfo" withValue:rfidText];
    }
}
-(void)requestWithResLogicName:(NSString *)resLogicName withValue:(NSString *)value{
    // 创建请求字典
    NSDictionary *dict = @{@"resLogicName":resLogicName,@"rfid":value};
    
    // 拼接请求连接
#ifdef BaseURL
    NSString * requestURL = [NSString stringWithFormat:@"%@rm!getResByRfid.interface",BaseURL];
#else
    NSString * requestURL = [NSString stringWithFormat:@"%@rm!getResByRfid.interface",BaseURL_Auto(([IWPServerService sharedService].link))];
#endif
    // 创建请求体
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    // 设置UID
    [param setValue:userModel.uid forKey:@"UID"];
    
    NSLog(@"---param:%@",param);

    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];

    
    __weak typeof(self) wself = self;
    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        // 请求成功，拿到数据
        NSDictionary * dict = responseObject;
        NSLog(@"dict:%@",dict);
        NSNumber * num = dict[@"success"];
        
        if (num.intValue == 1) {
            
            // 取出json
            NSData * infoData = [REPLACE_HHF(dict[@"info"]) dataUsingEncoding:NSUTF8StringEncoding];
            NSError * err = nil;
            
            // 将json解析成数组
            NSArray * info = [NSJSONSerialization JSONObjectWithData:infoData options:NSJSONReadingMutableContainers error:&err];
            
            [HUD removeFromSuperview];
            HUD = nil;
            if (info.count > 0 && info[0][@"resLogicName"]!=nil) {
                // 扫描到设备
                [wself showInfomationViewControllerWithDict:info];
            }else{
                // 未扫描到任何设备
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"未查询到相关资源信息" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                    [wself createScanner];
                    return;
                }];
                [alert addAction:action];
                Present(wself, alert);
            }
        }else{
            // 未扫描到任何设备
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"未查询到相关资源信息" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                [wself createScanner];
                return;
            }];
            [alert addAction:action];
            Present(wself, alert);
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

- (void)hideViewController:(id)obj{
    
    [self dismissViewControllerAnimated:true completion:^{
        self.vc = nil;
    }];
    
}

-(void)showInfomationViewControllerWithDict:(NSArray *)devices{
    // 显示设备信息
    // 取出设备字典
    NSDictionary * dict = [devices firstObject];
    // 取出文件名
    NSString * fileName = dict[@"resLogicName"];
    // 根据不同文件名跳转不同的控制器
    if ([fileName isEqualToString:@"generator"]){
        //机房信息
        // 取出文件模型
        IWPPropertiesSourceModel * model = [[IWPPropertiesReader propertiesReaderWithFileName:fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] mainModel];
        
        GeneratorTYKViewController * deviceInfo =[GeneratorTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
        
        self.vc = deviceInfo;
        
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:deviceInfo];
        
        deviceInfo.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:self action:@selector(hideViewController:)];
        
        
        Present(self, nav);
        
        
        
    }else if ([fileName isEqualToString:@"cable"]){
//        //光缆段信息
//        // 取出文件模型
//        IWPPropertiesSourceModel * model = [[IWPPropertiesReader propertiesReaderWithFileName:fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] mainModel];
//        CableTYKViewController * deviceInfo =[CableTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
//
//        self.vc = deviceInfo;
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:deviceInfo];
//
//        deviceInfo.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:self action:@selector(hideViewController:)];
//        Present(self, nav);
        
    }else if ([fileName isEqualToString:@"ABCDEFG"]){//TODO:这里要改,加入全资源类型的判断
        [YuanHUD HUDFullText:@"到这了GeneratorSSSBTYKInfoViewControllerasddddd"];
//        // 机房下属设备信息
//        GeneratorSSSBTYKInfoViewController *infoVC = [[GeneratorSSSBTYKInfoViewController alloc] init];
//        infoVC.dictIn = dict;
//
//        self.vc = infoVC;
//        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:infoVC];
//
//        infoVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:self action:@selector(hideViewController:)];
//        Present(self, nav);
    }else{
        IWPPropertiesSourceModel * model = [[IWPPropertiesReader propertiesReaderWithFileName:fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] mainModel];
//        构造方法
        TYKDeviceInfoMationViewController * deviceInfo =[TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:model withViewModel:nil withDataDict:dict withFileName:fileName];
        
        self.vc = deviceInfo;
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:deviceInfo];
        
        deviceInfo.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style: UIBarButtonItemStyleDone target:self action:@selector(hideViewController:)];
        Present(self, nav);
    }
//    isTYKScaned = YES;
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
    [param setValue:userModel.uid forKey:@"UID"];
    

    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除成功" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert addAction:action];
        Present(self.navigationController, alert);
        
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        AlertShow([UIApplication sharedApplication].keyWindow, @"删除失败", 2.f, error.localizedDescription);
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)dealloc{
    NSLog(@"释放");
}

-(void)viewWillAppear:(BOOL)animated{
    
//    userModel.RFIDimage.alpha = 1.f;
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    
//    userModel.RFIDimage.alpha = 0.f;
    
    [super viewWillDisappear:animated];
}


@end
