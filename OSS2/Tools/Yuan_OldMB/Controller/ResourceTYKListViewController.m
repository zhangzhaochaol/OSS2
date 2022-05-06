//
//  ResourceTYKListViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/6/28.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//
//_model.list_sreach_name
#import "ResourceTYKListViewController.h"

#import "MBProgressHUD.h"

#import "MJRefresh.h"
#import "ResourceTYKTableViewCell.h"
#import "GeneratorTYKViewController.h"
#import "RouteTYKViewController.h"
//#import "CableTYKViewController.h"
#import "RFIDTYKViewController.h"
//#import "CardTYKViewController.h"
#import "IWPPropertiesReader.h"
#import "TYKDeviceInfoMationViewController.h"
#import "PoleLineTYKViewController.h"
#import "PipeTYKViewController.h"
#import "PoleLineMapMainTYKViewController.h"
#import "PipeMapMainTYKViewController.h"
#import "MarkStoneSegmentMapMainTYKViewController.h"
#import "ResourceLocationTYKViewController.h"
#import "CusButton.h"

#import "IWPULMarkStonePathLocationViewController.h"

#import "Inc_Push_MB.h"
//zzc
#import "MLMenuView.h"                 // 菜单
#import "IWPPopverView.h"
#import "IWPPopverViewItem.h"

//http
#import "Yuan_FL_HttpModel.h"


// 级联删除
#import "Yuan_MoreLevelDeleteVC.h"

// 新版杆路定位
#import "Inc_PoleNewConfigVC.h"


// 标题
#define kTitle @"title"
// 图片名称
#define kImageName @"imageName"
// 响应事件，普通状态
#define kHandler @"handler"
// 选中状态响应事件
#define kSelectedHandler @"selectedHandler"
// 选中标题
#define kSelectedTitle @"selectedTitle"
// 可用状态
#define kEnabled @"enabled"


@interface ResourceTYKListViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UITextFieldDelegate,
    TYKDeviceInfomationDelegate,
    PipeMapMainTYKDelegate,
    MarkStoneSegmentMapMainTYKDelegate,
    IWPULMarkStonePathLocationViewControllerDelegate,
    PoleLineMapDelegate,
    UITextFieldDelegate,
    MLMenuViewDelegate
>
@property (weak, nonatomic) UITableView *resourceTableView;
@property (strong, nonatomic) NSMutableArray *resourceArray;//获取到的资源信息列表
@property (nonatomic, strong) IWPPropertiesReader * reader;
@property (nonatomic, strong) IWPPropertiesSourceModel * model;
@property (nonatomic, strong) NSArray <IWPViewModel *>* viewModel;

//zzc 2021-05-11 搜索列表下拉菜单view
@property (nonatomic, weak) MLMenuView * menuView;

@end

@implementation ResourceTYKListViewController
{
    MBProgressHUD *HUD;

    float tableCellHeight;
    CGFloat nowHight;
    UITextField *_searchNameTextField;
    UILabel * _placeHolder;
    
    NSInteger start;// 从第几个开始
    NSInteger limit; // 获取多少个
    
    NSString * TYKNew_fileName;  //统一库新增了 UNI_前缀的 fileName ; 袁全添加--
    
    // 声明一个blcok 用于接收 (智能判障block)
    void(^_YuanBlock)(NSDictionary * cableMsg);
    
    NSString * _isLiteSmart;
    
    NSString * _searchMsg;     // 搜索光缆段内容 -- 智能判障专用
    
    
    // 如果push到这个界面时 , 不去执行 yuan_searchClick这个方法 , 从上一界面返回后(pop)的viewdidappear方法中
    // 才去执行  yuan_searchClick 放
    BOOL _firstViewDidLoad ;
    
    // zzc 2021-05-11 搜索框左侧下拉按钮 fileName为：ODB_Equt、OCC_Equt、ODF_Equt 使用
    UIButton *_leftDropBtn;

}


#pragma mark - 袁全自定义的构造方法 !! 只用于智能判障 !!! 切记  ---

#pragma mark - 初始化构造方法

- (instancetype)initWithSearchTitle:(NSString *)title
                           blockMsg:(void (^)(NSDictionary *))block{
    
    if (self = [super init]) {
        
        _isLiteSmart = @"isLiteSmart";  //用于判断的
        
        _YuanBlock = block;
        
        _searchMsg = title;
    }
    return self;
}


/// 袁全新增 构造方法 , 用于楼宇
- (instancetype) initWithBulid_ODBBlock:(void(^)(NSDictionary * cableMsg))block {
    
    if (self = [super init]) {
        
        _YuanBlock = block;
        
        
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



#pragma mark - viewDidLoad

- (void)viewDidLoad {
    
    [self createPropertiesReader];
    
    self.title = [NSString stringWithFormat:@"%@列表",self.showName];
    self.view.backgroundColor=[UIColor whiteColor];
    

    start = 1;
    limit = 20;
    
    //控件初始化
    [self uiInit];
    if (self.dicIn!=nil) {
        //调用查询接口
        NSDictionary *param;
        if ([self.fileName isEqualToString:@"rfidInfo"]) {
            
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"GIDandRFIDrelation\",\"GID\":\"%@\",\"resTypeId\":\"701\"}",(long)start,(long)limit,self.dicIn[@"GID"]]};
            
        }else if ([self.fileName isEqualToString:@"shelf"]||[self.fileName isEqualToString:@"card"]||[self.fileName isEqualToString:@"port"]) {
            
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"GID\":\"%@\"}",(long)start,(long)limit,self.fileName,self.dicIn[@"GID"]]};
            
        }else if ([self.fileName isEqualToString:@"cnctShelf"]) {
            
            NSString * eqpId_Type = @"1";
            
            NSString * dict_In_ResLogicName = self.dicIn[@"resLogicName"];
            if ([dict_In_ResLogicName isEqualToString:@"OCC_Equt"]) {
                eqpId_Type = @"2";
            }
            
            else if ([dict_In_ResLogicName isEqualToString:@"ODB_Equt"]) {
                eqpId_Type = @"3";
            }
            else if ([dict_In_ResLogicName isEqualToString:@"OBD_Equt"]) {
                eqpId_Type = @"4";
            }
            
            NSDictionary * jsonRequest = @{
                
                @"limit" : [Yuan_Foundation fromInteger:limit],
                @"start" : [Yuan_Foundation fromInteger:start],
                @"resLogicName" : _fileName,
                @"eqpId_Id" : self.dicIn[@"GID"],
                @"eqpId_Type" : eqpId_Type
            };
            
            param = @{@"UID":UserModel.uid,@"jsonRequest":jsonRequest.json};
            
        }else if ([self.fileName isEqualToString:@"module"] ) {
            
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"shelfName_Id\":\"%@\"}",(long)start,(long)limit,self.fileName,self.dicIn[@"GID"]]};
            
        }else if ([self.fileName isEqualToString:@"opticTerm"]) {
            
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"moduleName_Id\":\"%@\"}",(long)start,(long)limit,self.fileName,self.dicIn[@"GID"]]};
            
        }else if ([self.fileName isEqualToString:@"pole"]||([self.fileName isEqualToString:@"poleLineSegment"])||([self.fileName isEqualToString:@"supportingPoints"])) {
            
        
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"poleLine_Id\":\"%@\"}",(long)start,(long)limit,self.fileName,self.dicIn[@"GID"]]};
            
            
        }else if ([self.fileName isEqualToString:@"markStonePath"]){
            
            // TODO: unicomMarkStonePath_Id 不对
            NSDictionary * dict = @{@"start":[NSNumber numberWithInteger:start], @"limit":[NSNumber numberWithInteger:limit], kResLogicName:self.fileName, @"markStonePath_Id":self.dicIn[@"GID"]};
            
            param = @{@"UID":UserModel.uid, @"jsonRequest":DictToString(dict)};
            
        }else if ([self.fileName isEqualToString:@"markStone"] ||
                  [self.fileName isEqualToString:@"markStoneSegment"]){
            
            
            
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"ssmarkStoneP_Id\":\"%@\"}",(long)start,(long)limit,self.fileName,self.dicIn[@"markStonePathId"]]};
            
        }
        
        // 如果是管孔 ***  yuan 2020.09.02
        else if ([self.fileName isEqualToString:@"tube"]) {
            
            NSMutableDictionary * jsReqDict = NSMutableDictionary.dictionary;
            jsReqDict[@"start"] = [Yuan_Foundation fromInteger:start];
            jsReqDict[@"limit"] = [Yuan_Foundation fromInteger:limit];
            jsReqDict[@"resLogicName"] = self.fileName;
            jsReqDict[@"pipeSegment_Id"] = self.dicIn[@"GID"];
            
            if (_isNeed_isFather) {   //如果是子孔
                jsReqDict[@"isFather"] = @"2";
                jsReqDict[@"fatherPore_Id"] = _fatherPore_Id;
            }
            
            param = @{@"UID":UserModel.uid,@"jsonRequest":jsReqDict.json};
            
        }
        
        else{
            
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"%@_Id\":\"%@\"}",(long)start,(long)limit,self.fileName,self.dicIn[@"resLogicName"],self.dicIn[@"GID"]]};
            
        }
        NSLog(@"param %@",param);
        [self getResourceData:param];
    }
    
    
    // 袁全新增 智能判障 -- 光缆段 ***
    
    // 把智能判障页面 传过来的搜索内容 赋值到 _searchNameTextField 上 , 进行搜索
    if (_YuanBlock && _searchMsg) {
        // 证明此时是智能判障
        _searchNameTextField.text = _searchMsg;
    }
    
    _firstViewDidLoad = YES;  // 袁 *** 为了避免 第一次的 viewdidappear 执行 yuan_searchClick;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(header) name:@"copySuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(header) name:@"cableSuccessful" object:nil];

    
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (![_fileName isEqualToString:@"markStoneSegment"]) {
        
        if (_firstViewDidLoad == NO) {
#warning --- 自动刷新 我注释掉了 ~~~~   没见到有什么需要解开的地方呀 ~ 阿秋
//            [self yuan_searchClick];
        }
    }
    
    _firstViewDidLoad = NO;
    
}



- (void)createPropertiesReader{
    
//    不能这么修改 !!! 袁全
//    self.fileName = [NSString stringWithFormat:@"UNI_%@",self.fileName];
    
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

- (void) oldSearchView {
    
    //搜索控件
    nowHight = [StrUtil heightOfTop]+16;//80;
    UILabel *searchNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, nowHight-5, ScreenWidth/5, 40)];
    searchNameLabel.tag = 100;
    if ([self.fileName isEqualToString:@"rfidInfo"]) {
        searchNameLabel.text = self.showName;
    }else{
        searchNameLabel.text = [NSString stringWithFormat:@"%@名称",_model.name];
    }
    searchNameLabel.font = [UIFont boldSystemFontOfSize:14.0];
    searchNameLabel.numberOfLines = 0;
    [self.view addSubview:searchNameLabel];
    _searchNameTextField =[[UITextField alloc] initWithFrame:CGRectMake(ScreenWidth/5+10, nowHight, ScreenWidth/5*3, 30)];
    [_searchNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    _searchNameTextField.tag = 200;
    //点击done关闭软键盘
    _searchNameTextField.delegate = self;
    _searchNameTextField.returnKeyType = UIReturnKeySearch;
    
    [self.view addSubview:_searchNameTextField];
    
    //MARK: 袁全修改约束条件 , 有bug提出 searchbutton被向下平移 看不见了 , 我就用purelayout 给他做了约束
    // CGRectMake((ScreenWidth/5+10)+(ScreenWidth/5*3), nowHight-10, 40, 40)
    // 修改成了 CGRectNULL
    
    UIButton *searchButton = [[UIButton alloc]initWithFrame:CGRectMake((ScreenWidth/5+10)+(ScreenWidth/5*3), nowHight-10, 40, 40)];
    [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton];
    
}

//控件初始化
-(void)uiInit{
    
    
    // 搜索移入导航栏中
    // ODB_Equt、OCC_Equt、ODF_Equt 使用新的搜素框
//    if ([self.fileName isEqualToString:@"ODB_Equt"] || [self.fileName isEqualToString:@"OCC_Equt"] || [self.fileName isEqualToString:@"ODF_Equt"]) {
//        [self ZZC_NaviBarSet];
//    }else{
//        [self naviBarSet];
//    }
//
    
    self.title = @"资源列表";
    
    _searchNameTextField = [UIView textFieldFrame:CGRectMake(Horizontal(15), NaviBarHeight + 5, ScreenWidth - Horizontal(30), Vertical(40))];
    _searchNameTextField.backgroundColor = UIColor.f2_Color;
    [_searchNameTextField cornerRadius:5
                           borderWidth:0
                           borderColor:UIColor.whiteColor];
    
    UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage Inc_imageNamed:@"TYKList_Search_New"]];
    img.contentMode = UIViewContentModeScaleAspectFit;
    
    _searchNameTextField.leftView = img;
    
    _searchNameTextField.leftViewMode = UITextFieldViewModeAlways;
    _searchNameTextField.placeholder = @"";
    
    _searchNameTextField.delegate = self;
    
    // 搜索
    _searchNameTextField.returnKeyType= UIReturnKeySearch;
    
    [self.view addSubview:_searchNameTextField];
    

//    [_searchNameTextField YuanToSuper_Top:NaviBarHeight + 5];
//    [_searchNameTextField YuanToSuper_Left:Horizontal(15)];
//    [_searchNameTextField YuanToSuper_Right:Horizontal(15)];
//    [_searchNameTextField Yuan_EdgeHeight:Vertical(40)];
    
        
    NSString * placeholder_Txt = [NSString stringWithFormat:@"请输入%@名称进行搜索",_showName ?: @"设备"];
    
    _placeHolder = [UIView labelWithTitle:placeholder_Txt
                                             frame:CGRectNull];
    
    _placeHolder.font = [UIFont systemFontOfSize:13];
    _placeHolder.textColor = ColorValue_RGB(0x666666);
    [_searchNameTextField addSubview:_placeHolder];
    
    [_placeHolder YuanAttributeHorizontalToView:_searchNameTextField];
    [_placeHolder YuanAttributeVerticalToView:_searchNameTextField];
    
    
    if (_searchMsg && _searchMsg.length > 0) {
        _placeHolder.hidden = YES;
        _searchNameTextField.text = _searchMsg;
    }

    
    
    
    
    
    //查询结果列表
    nowHight += NaviBarHeight + Vertical(50);
    UITableView * resourceTableView=[[UITableView alloc] initWithFrame:CGRectMake(10, nowHight, ScreenWidth-20, ScreenHeight - nowHight-10) style:UITableViewStyleGrouped];
    _resourceTableView = resourceTableView;
    
    _resourceTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [_resourceTableView.mj_header endRefreshing];
        [self header];

    }];

    _resourceTableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        [_resourceTableView.mj_footer endRefreshingWithNoMoreData];
        [self footer];

    }];
    
    
    _resourceTableView.backgroundColor=[UIColor whiteColor];
    
    _resourceTableView.delegate=self;
    _resourceTableView.dataSource=self;
    [self.view addSubview:_resourceTableView];
    
    
    [self btn_Init];
}


- (void) btn_Init {
    
    float limit = Horizontal(10);
    
    float btnHeight = 40;
    // 单双按钮宽度
    float btnWidthSingle = ScreenWidth - limit * 2;
    float btnWidthDouble = (ScreenWidth - limit * 3)/2;
    
    float btn_Y = ScreenHeight-50;
    
    
    if ([self.fileName isEqualToString:@"rfidInfo"]) {
        CusButton *addBtn = [[CusButton alloc]initWithFrame:CGRectMake(limit, btn_Y, btnWidthSingle, btnHeight)];
        [addBtn setTitle:@"添加RFID信息表" forState:UIControlStateNormal];
        [addBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [addBtn setBackgroundColor:[UIColor mainColor]];
        [addBtn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:addBtn];
        
        addBtn.titleLabel.font = Font_Yuan(14);
        
        [_resourceTableView setFrame:CGRectMake(10, nowHight, ScreenWidth-20, ScreenHeight - nowHight-10-50)];
    }
    else if ([self.fileName isEqualToString:@"poleline"]||
             [self.fileName isEqualToString:@"pipe"]||
             [self.fileName isEqualToString:@"supportingPoints"]||
             [self.fileName isEqualToString:@"ledUp"]||
             [self.fileName isEqualToString:@"markStoneSegment"]||
             [self.fileName isEqualToString:@"markStone"]){
        
        BOOL isNeedAddButton = true;
        if (([[UserModel.powersTYKDic[self.fileName] substringToIndex:1] integerValue] == 0)) {
            isNeedAddButton = false;
        }
        CusButton *addBtn;
        if (isNeedAddButton) {
            addBtn = [[CusButton alloc]initWithFrame:CGRectMake(limit, btn_Y, btnWidthSingle, btnHeight)];
            if ([self.fileName isEqualToString:@"poleline"]){
                [addBtn setTitle:@"添加杆路" forState:UIControlStateNormal];
            }else if ([self.fileName isEqualToString:@"pipe"]){
                [addBtn setTitle:@"添加管道" forState:UIControlStateNormal];
            }else if ([self.fileName isEqualToString:@"supportingPoints"]){
                [addBtn setTitle:@"添加撑点" forState:UIControlStateNormal];
            }else if ([self.fileName isEqualToString:@"ledUp"]){
                [addBtn setTitle:@"添加引上点" forState:UIControlStateNormal];
            }else if ([self.fileName isEqualToString:@"markStoneSegment"]){
//                [addBtn setTitle:@"添加标石段" forState:UIControlStateNormal];
//                resourceTableView.height += addBtn.height;
                addBtn.hidden = true;
            }else if ([self.fileName isEqualToString:@"markStone"]){
//                [addBtn setTitle:@"添加标石" forState:UIControlStateNormal];
//                resourceTableView.height += addBtn.height;
                addBtn.hidden = true;
            }
            
            [addBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [addBtn setBackgroundColor:[UIColor mainColor]];
            [addBtn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:addBtn];
            addBtn.titleLabel.font = Font_Yuan(14);
            if (addBtn.hidden == false) {
                [_resourceTableView setFrame:CGRectMake(10, nowHight, ScreenWidth-20, ScreenHeight - nowHight-10-50)];
            }
        }
        if ([self.fileName isEqualToString:@"markStone"]) {
            
            
            CusButton *locationBtn = [[CusButton alloc]initWithFrame:CGRectMake(limit, btn_Y, btnWidthSingle, btnHeight)];
            [locationBtn setTitle:@"定位" forState:UIControlStateNormal];
            
            [locationBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [locationBtn setBackgroundColor:[UIColor mainColor]];
            [locationBtn addTarget:self action:@selector(location:) forControlEvents:UIControlEventTouchUpInside];
//            [self.view addSubview:locationBtn];
            if (isNeedAddButton) {
                
                [addBtn setFrame:CGRectMake(limit, btn_Y, btnWidthDouble, btnHeight)];
                
                [locationBtn setFrame:CGRectMake(limit * 2 + btnWidthDouble,
                                                 btn_Y,
                                                 btnWidthDouble,
                                                 btnHeight)];
                
                addBtn.titleLabel.font = Font_Yuan(14);
                locationBtn.titleLabel.font = Font_Yuan(14);
            }
            
            [_resourceTableView setFrame:CGRectMake(10, nowHight, ScreenWidth-20, ScreenHeight - nowHight-10-50)];
        }
    }
    
    // 袁全 新增 *** 对于管孔的权限判断
    else if ([self.fileName isEqualToString:@"tube"]) {
        
        BOOL isNeedAddButton = true;
        
        if (([[UserModel.powersTYKDic[@"poleLineSegment"] substringToIndex:1] integerValue] == 0)) {
            isNeedAddButton = false;
        }
        
        CusButton * addBtn = [[CusButton alloc]initWithFrame:CGRectMake(limit, btn_Y, btnWidthSingle, btnHeight)];
        
        [addBtn setTitle:@"添加管孔" forState:UIControlStateNormal];
        
        [addBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [addBtn setBackgroundColor:[UIColor mainColor]];
        [addBtn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:addBtn];
        addBtn.titleLabel.font = Font_Yuan(14);
        if (addBtn.hidden == false) {
            [_resourceTableView setFrame:CGRectMake(10, nowHight, ScreenWidth-20, ScreenHeight - nowHight-10-50)];
        }
        
    }
    
    else{
        BOOL isNeedAddButton = true;
        if (([[UserModel.powersTYKDic[self.fileName] substringToIndex:1] integerValue] == 0)&&
            ([self.fileName isEqualToString:@"poleLineSegment"]||
             [self.fileName isEqualToString:@"pole"]||
             [self.fileName isEqualToString:@"pipeSegment"]||
             [self.fileName isEqualToString:@"well"] ||
             [self.fileName isEqualToString:@"cnctShelf"])) {
            isNeedAddButton = false;
        }
        CusButton *addBtn;
        if (isNeedAddButton) {
            addBtn = [[CusButton alloc]initWithFrame:CGRectMake(limit, btn_Y, btnWidthSingle, btnHeight)];
            [addBtn setTitle:[NSString stringWithFormat:@"添加%@",_model.name] forState:UIControlStateNormal];
            
            [addBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [addBtn setBackgroundColor:[UIColor mainColor]];
            [addBtn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:addBtn];
            addBtn.titleLabel.font = Font_Yuan(14);
            [_resourceTableView setFrame:CGRectMake(10, nowHight, ScreenWidth-20, ScreenHeight - nowHight-10-50)];
        }
        if ([self.fileName isEqualToString:@"stationBase"]||
            [self.fileName isEqualToString:@"generator"]||
            [self.fileName isEqualToString:@"EquipmentPoint"]||
            [self.fileName isEqualToString:@"OCC_Equt"]||
            [self.fileName isEqualToString:@"ODB_Equt"]||
            [self.fileName isEqualToString:@"joint"]) {
            
            CusButton *locationBtn = [[CusButton alloc]initWithFrame:CGRectMake(limit, btn_Y, btnWidthSingle, btnHeight)];
            [locationBtn setTitle:@"定位" forState:UIControlStateNormal];
            
            [locationBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
            [locationBtn setBackgroundColor:[UIColor mainColor]];
            [locationBtn addTarget:self action:@selector(location:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:locationBtn];
            if (isNeedAddButton) {
                
                [addBtn setFrame:CGRectMake(limit, btn_Y, btnWidthDouble, btnHeight)];
                
                [locationBtn setFrame:CGRectMake(limit * 2 + btnWidthDouble,
                                                 btn_Y,
                                                 btnWidthDouble,
                                                 btnHeight)];
                
                addBtn.titleLabel.font = Font_Yuan(14);
                locationBtn.titleLabel.font = Font_Yuan(14);
            }
            
            [_resourceTableView setFrame:CGRectMake(10, nowHight, ScreenWidth-20, ScreenHeight - nowHight-10-50)];
        }
    }
    
    
}



-(NSDictionary *)makeParam:(NSString *)resourceName{
    NSDictionary *param;
    if (self.dicIn!=nil) {
        if ([self.fileName isEqualToString:@"route"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@name:%@,GID:%@}",(long)start,(long)limit,self.fileName,self.fileName,resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"rfidInfo"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"GIDandRFIDrelation\",GID:%@,\"resTypeId\":\"701\",\"addr\":%@,GID:%@}",(long)start,(long)limit,self.dicIn[@"GID"],resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"shelf"]||[self.fileName isEqualToString:@"card"]||[self.fileName isEqualToString:@"port"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",GID:%@,\"jkName\":%@,GID:%@}",(long)start,(long)limit,self.fileName,self.dicIn[@"GID"],resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"ODF_Equt"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@Name:%@,GID:%@}",(long)start,(long)limit,self.fileName,@"rack",resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
            
        }else if ([self.fileName isEqualToString:@"cnctShelf"]) {
//            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@Name:%@,GID:%@}",(long)start,(long)limit,self.fileName,@"shelf",resourceName,self.dicIn[@"GID"]]};
//            NSLog(@"param %@",param);
            
            
            NSString * eqpId_Type = @"1";
            
            NSString * dict_In_ResLogicName = self.dicIn[@"resLogicName"];
            if ([dict_In_ResLogicName isEqualToString:@"OCC_Equt"]) {
                eqpId_Type = @"2";
            }
            
            else if ([dict_In_ResLogicName isEqualToString:@"ODB_Equt"]) {
                eqpId_Type = @"3";
            }
            else if ([dict_In_ResLogicName isEqualToString:@"OBD_Equt"]) {
                eqpId_Type = @"4";
            }
            
            NSDictionary * jsonRequest = @{
                
                @"limit" : [Yuan_Foundation fromInteger:limit],
                @"start" : [Yuan_Foundation fromInteger:start],
                @"resLogicName" : _fileName,
                @"eqpId_Id" : self.dicIn[@"GID"],
                @"eqpId_Type" : eqpId_Type
            };
            
            param = @{@"UID":UserModel.uid,@"jsonRequest":jsonRequest.json};
            
            NSLog(@"param %@",param);

            
        }else if ([self.fileName isEqualToString:@"opticTerm"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"moduleName_Id\":\"%@\"}",(long)start,(long)limit,self.fileName,self.dicIn[@"GID"]]};

            NSLog(@"param %@",param);
            
        }else if ([self.fileName isEqualToString:@"OCC_Equt"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@Name:%@,GID:%@}",(long)start,(long)limit,self.fileName,@"occ",resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
            
        }else if ([self.fileName isEqualToString:@"ODB_Equt"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@Name:%@,GID:%@}",(long)start,(long)limit,self.fileName,@"odb",resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
            
        }else if ([self.fileName isEqualToString:@"poleline"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"poleLineName\":%@,GID:%@}",(long)start,(long)limit,self.fileName,resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"poleLineSegment"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"poleLineSegmentName\":%@,poleLine_Id:%@}",(long)start,(long)limit,self.fileName,resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"pole"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"poleSubName\":%@,poleLine_Id:%@}",(long)start,(long)limit,self.fileName,resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }else if([self.fileName isEqualToString:@"pipeSegment"]){
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"pipeSegName\":%@,pipe_Id:%@}",(long)start,(long)limit,self.fileName,resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }else if([self.fileName isEqualToString:@"well"]){
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"wellSubName\":%@,pipe_Id:%@}",(long)start,(long)limit,self.fileName,resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"supportingPoints"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"supportPSubName\":%@,poleLine_Id:%@}",(long)start,(long)limit,self.fileName,resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }
        // 如果是管孔 ***  yuan 2020.09.02
        else if ([self.fileName isEqualToString:@"tube"]) {
            
            NSMutableDictionary * jsReqDict = NSMutableDictionary.dictionary;
            jsReqDict[@"start"] = [Yuan_Foundation fromInteger:start];
            jsReqDict[@"limit"] = [Yuan_Foundation fromInteger:limit];
            jsReqDict[@"resLogicName"] = self.fileName;
            jsReqDict[@"pipeSegment_Id"] = self.dicIn[@"GID"];
            
            if (_isNeed_isFather) {   //如果是子孔
                jsReqDict[@"isFather"] = @"2";
                jsReqDict[@"fatherPore_Id"] = _fatherPore_Id;
            }
            
            param = @{@"UID":UserModel.uid,@"jsonRequest":jsReqDict.json};
        }
        
        else if ([self.fileName isEqualToString:@"ledUp"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"ledupName\":%@,GID:%@}",(long)start,(long)limit,self.fileName,resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"markStoneSegment"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"markStoneSgName\":%@,GID:%@}",(long)start,(long)limit,self.fileName,resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"markStone"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"markName\":%@,GID:%@}",(long)start,(long)limit,self.fileName,resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"markStonePath"]){
            
            IWPPropertiesReadDirectoryRef dire = IWPPropertiesReadDirectoryDocuments;
            
            IWPPropertiesSourceModel * model = [IWPPropertiesReader propertiesReaderWithFileName:@"markStonePath" withFileDirectoryType:dire].mainModel;
            
            
            NSDictionary * dict = @{@"start":[NSNumber numberWithInteger:start], @"limit":[NSNumber numberWithInteger:limit], kResLogicName:self.fileName, @"markStonePath_Id":self.dicIn[@"GID"], model.list_sreach_name:resourceName};
            
            param = @{@"UID":UserModel.uid, @"jsonRequest":DictToString(dict)};
            
            
        }
        
        
        else{
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@:%@,GID:%@}",(long)start,(long)limit,self.fileName,_model.list_sreach_name,resourceName,self.dicIn[@"GID"]]};
            NSLog(@"param %@",param);
        }

    }else{
        if ([self.fileName isEqualToString:@"route"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@name:%@}",(long)start,(long)limit,self.fileName,self.fileName,resourceName]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"rfidInfo"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"GIDandRFIDrelation\",GID:%@,\"resTypeId\":\"701\",\"addr\":%@}",(long)start,(long)limit,self.dicIn[@"GID"],resourceName]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"shelf"]||[self.fileName isEqualToString:@"card"]||[self.fileName isEqualToString:@"port"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",GID:%@,\"jkName\":%@}",(long)start,(long)limit,self.fileName,self.dicIn[@"GID"],resourceName]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"ODF_Equt"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@Name:%@}",(long)start,(long)limit,self.fileName,@"rack",resourceName]};
            NSLog(@"param %@",param);
            
        }else if ([self.fileName isEqualToString:@"cnctShelf"]) {
//            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@Name:%@}",(long)start,(long)limit,self.fileName,@"shelf",resourceName]};
//            NSLog(@"param %@",param);
            
            
            NSString * eqpId_Type = @"1";
            
            NSString * dict_In_ResLogicName = self.dicIn[@"resLogicName"];
            if ([dict_In_ResLogicName isEqualToString:@"OCC_Equt"]) {
                eqpId_Type = @"2";
            }
            
            else if ([dict_In_ResLogicName isEqualToString:@"ODB_Equt"]) {
                eqpId_Type = @"3";
            }
            else if ([dict_In_ResLogicName isEqualToString:@"OBD_Equt"]) {
                eqpId_Type = @"4";
            }
            
            NSDictionary * jsonRequest = @{
                
                @"limit" : [Yuan_Foundation fromInteger:limit],
                @"start" : [Yuan_Foundation fromInteger:start],
                @"resLogicName" : _fileName,
                @"eqpId_Id" : self.dicIn[@"GID"],
                @"eqpId_Type" : eqpId_Type
            };
            
            param = @{@"UID":UserModel.uid,@"jsonRequest":jsonRequest.json};
            
            NSLog(@"param %@",param);
            
            
        }else if ([self.fileName isEqualToString:@"opticTerm"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@Name:%@}",(long)start,(long)limit,self.fileName,@"term",resourceName]};
            NSLog(@"param %@",param);
            
        }else if ([self.fileName isEqualToString:@"OCC_Equt"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@Name:%@}",(long)start,(long)limit,self.fileName,@"occ",resourceName]};
            NSLog(@"param %@",param);
            
        }else if ([self.fileName isEqualToString:@"ODB_Equt"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@Name:%@}",(long)start,(long)limit,self.fileName,@"odb",resourceName]};
            NSLog(@"param %@",param);
            
        }else if ([self.fileName isEqualToString:@"poleline"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"poleLineName\":%@}",(long)start,(long)limit,self.fileName,resourceName]};
            NSLog(@"param %@",param);
            
        }else if ([self.fileName isEqualToString:@"poleLineSegment"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"poleLineSegmentName\":%@}",(long)start,(long)limit,self.fileName,resourceName]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"pole"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"poleSubName\":%@}",(long)start,(long)limit,self.fileName,resourceName]};
            NSLog(@"param %@",param);
        }else if([self.fileName isEqualToString:@"pipeSegment"]){
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"pipeSegName\":%@}",(long)start,(long)limit,self.fileName,resourceName]};
            NSLog(@"param %@",param);
        }else if([self.fileName isEqualToString:@"well"]){
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"wellSubName\":%@}",(long)start,(long)limit,self.fileName,resourceName]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"supportingPoints"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"supportPSubName\":%@}",(long)start,(long)limit,self.fileName,resourceName]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"ledUp"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"ledupName\":%@}",(long)start,(long)limit,self.fileName,resourceName]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"tube"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"tubeName\":%@}",(long)start,(long)limit,self.fileName,resourceName]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"markStoneSegment"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"markStoneSgName\":%@}",(long)start,(long)limit,self.fileName,resourceName]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"markStone"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"markName\":%@}",(long)start,(long)limit,self.fileName,resourceName]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"stationBase"]) {
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",\"stationName\":%@}",(long)start,(long)limit,self.fileName,resourceName]};
            NSLog(@"param %@",param);
        }else if ([self.fileName isEqualToString:@"markStonePath"]){
            
            IWPPropertiesReadDirectoryRef dire = IWPPropertiesReadDirectoryDocuments;
            
            IWPPropertiesSourceModel * model = [IWPPropertiesReader propertiesReaderWithFileName:@"markStonePath" withFileDirectoryType:dire].mainModel;
            
            
            NSDictionary * dict = @{@"start":[NSNumber numberWithInteger:start], @"limit":[NSNumber numberWithInteger:limit], kResLogicName:self.fileName, model.list_sreach_name:_searchNameTextField.text.length > 0 ? _searchNameTextField.text : @""};
            
            param = @{@"UID":UserModel.uid, @"jsonRequest":DictToString(dict)};
            
            
        }
        
        else if ([self.fileName isEqualToString:@"transmissionEqu"]) {
            
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",equipmentName:%@}",(long)start,(long)limit,self.fileName,resourceName]};
            
        }
        else{
            param = @{@"UID":UserModel.uid,@"jsonRequest":[NSString stringWithFormat:@"{\"start\":\"%ld\",\"limit\":\"%ld\",\"resLogicName\":\"%@\",%@:%@}",(long)start,(long)limit,self.fileName,_model.list_sreach_name,resourceName]};
            NSLog(@"param %@",param);
        }
    }
    
    NSLog(@"%@", param);
    
        return param;
}

// zzc  2021-05-11  新增编码搜素入参
-(NSDictionary *)ZZC_MakeParam:(NSString *)resourceName {
    NSDictionary *param;
    if ([self.fileName isEqualToString:@"ODB_Equt"]) {
        param = @{
            @"start":[NSString stringWithFormat:@"%ld",(long)start],
            @"limit":[NSString stringWithFormat:@"%ld",(long)limit],
            @"resLogicName":self.fileName,
            @"jntBoxNo":resourceName
        };
    }else if ([self.fileName isEqualToString:@"OCC_Equt"]) {
        param = @{
            @"start":[NSString stringWithFormat:@"%ld",(long)start],
            @"limit":[NSString stringWithFormat:@"%ld",(long)limit],
            @"resLogicName":self.fileName,
            @"occCode":resourceName
        };
    }else if ([self.fileName isEqualToString:@"ODF_Equt"]) {
        param = @{
            @"start":[NSString stringWithFormat:@"%ld",(long)start],
            @"limit":[NSString stringWithFormat:@"%ld",(long)limit],
            @"resLogicName":self.fileName,
            @"rackNo":resourceName
        };
    }
    
    return param;
}

//zzc 2021-05-11  查询接口请求
-  (void)ZZC_InterfaceRequest:(NSString *)resourceName {
    
    if ([self.fileName isEqualToString:@"ODB_Equt"] || [self.fileName isEqualToString:@"OCC_Equt"] || [self.fileName isEqualToString:@"ODF_Equt"]) {
        
        if ([_leftDropBtn.titleLabel.text isEqualToString:@"设备编码"]) {
            //查询接口 设备编码
            [self ZZC_GetResourceData:[self ZZC_MakeParam:resourceName]];
        }else{
            //查询接口 设备名称
            [self getResourceData:[self makeParam:resourceName]];
        }
    }else{
        //调用查询接口
        [self getResourceData:[self makeParam:resourceName]];
    }
}


-(void)header{
    
    
    start = 1;
    NSString *resourceName = [_searchNameTextField.text isEqualToString:@""] ? @"\"\"":[NSString stringWithFormat:@"\"%@\"",_searchNameTextField.text];
    //调用查询接口
    [self ZZC_InterfaceRequest:resourceName];
}

-(void)footer{
    
    start = _resourceArray.count+1;
    NSString *resourceName = [_searchNameTextField.text isEqualToString:@""] ? @"\"\"":[NSString stringWithFormat:@"\"%@\"",_searchNameTextField.text];
    //调用查询接口
    [self ZZC_InterfaceRequest:resourceName];
}
//定位按钮点击触发事件
-(IBAction)location:(id)sender{
    NSMutableArray *locationArr = [[NSMutableArray alloc] init];
    for (NSDictionary * res in _resourceArray) {
        if ([res[@"lat"] length] > 0) {
            [locationArr addObject:res];
        }
    }
    if(locationArr.count == 0){
    
        [YuanHUD HUDFullText:@"当前无可定位资源"];
        
        return;
    }
    
    ResourceLocationTYKViewController *resourceLocationVC = [[ResourceLocationTYKViewController alloc]init];
    resourceLocationVC.resourceArray = locationArr;
    resourceLocationVC.latIn = [locationArr[0] objectForKey:@"lat"];
    resourceLocationVC.lonIn = [locationArr[0] objectForKey:@"lon"];
    resourceLocationVC.nameArray = [[NSMutableArray alloc]init];
    if ([self.fileName isEqualToString:@"stationBase"]) {
        resourceLocationVC.labelText = @"局站定位";
        resourceLocationVC.imageName = @"icon_gcoding_station_tyk";
        resourceLocationVC.type = @"station";
        for (NSDictionary *dic in locationArr) {
            [resourceLocationVC.nameArray addObject:[dic objectForKey:@"stationName"]==nil?@"":[dic objectForKey:@"stationName"]];
        }
    }else if([self.fileName isEqualToString:@"generator"]){
        resourceLocationVC.labelText = @"机房定位";
        resourceLocationVC.imageName = @"icon_gcoding_generator_tyk";
        resourceLocationVC.type = @"generator";
        for (NSDictionary *dic in locationArr) {
            [resourceLocationVC.nameArray addObject:[dic objectForKey:@"generatorName"]==nil?@"":[dic objectForKey:@"generatorName"]];
        }
    }else if ([self.fileName isEqualToString:@"EquipmentPoint"]) {
        resourceLocationVC.labelText = @"放置点定位";
        resourceLocationVC.imageName = @"icon_gcoding_equpoint_tyk";
        resourceLocationVC.type = @"EquipmentPoint";
        for (NSDictionary *dic in locationArr) {
            [resourceLocationVC.nameArray addObject:[dic objectForKey:@"EquipmentPointName"]==nil?@"":[dic objectForKey:@"EquipmentPointName"]];
        }
    }else if ([self.fileName isEqualToString:@"markStone"]) {
        resourceLocationVC.labelText = @"标石定位";
        resourceLocationVC.imageName = @"icon_gcoding_biaoshi_tyk";
        resourceLocationVC.type = @"markStone";
        for (NSDictionary *dic in locationArr) {
            [resourceLocationVC.nameArray addObject:[dic objectForKey:@"markName"]==nil?@"":[dic objectForKey:@"markName"]];
        }
    }else if ([self.fileName isEqualToString:@"OCC_Equt"]) {
        resourceLocationVC.labelText = @"光交接箱定位";
        resourceLocationVC.imageName = @"icon_gcoding_occ_tyk";
        resourceLocationVC.type = @"occ";
        for (NSDictionary *dic in locationArr) {
            [resourceLocationVC.nameArray addObject:[dic objectForKey:@"occName"]==nil?@"":[dic objectForKey:@"occName"]];
        }
    }else if ([self.fileName isEqualToString:@"ODB_Equt"]) {
        resourceLocationVC.labelText = @"光分纤箱和光终端盒定位";
        resourceLocationVC.imageName = @"icon_gcoding_odb_tyk";
        resourceLocationVC.type = @"odb";
        for (NSDictionary *dic in locationArr) {
            [resourceLocationVC.nameArray addObject:[dic objectForKey:@"odbName"]==nil?@"":[dic objectForKey:@"odbName"]];
        }
    }else if ([self.fileName isEqualToString:@"joint"]) {
        resourceLocationVC.labelText = @"光缆接头定位";
        resourceLocationVC.imageName = @"icon_gcoding_joint_tyk";
        resourceLocationVC.type = @"joint";
        for (NSDictionary *dic in locationArr) {
            [resourceLocationVC.nameArray addObject:[dic objectForKey:@"jointName"]==nil?@"":[dic objectForKey:@"jointName"]];
        }
    }
    [self.navigationController pushViewController:resourceLocationVC animated:YES];
}
//添加按钮点击触发事件
-(IBAction)add:(id)sender{
    if ([self.fileName isEqualToString:@"rfidInfo"]) {
        NSMutableDictionary * rfid = [[NSMutableDictionary alloc] init];
        NSLog(@"self.dicIn:%@",self.dicIn);
        if (self.dicIn[@"cableId"]!=nil) {
             [rfid setObject:self.dicIn[@"cableId"] forKey:@"resId"];
        }
        if (self.dicIn[@"GID"]!=nil) {
            [rfid setValue:self.dicIn[@"GID"] forKey:@"GID"];
        }
        
        RFIDTYKViewController *rfidInfo = [RFIDTYKViewController deviceInfomationWithControlMode:TYKDeviceListInsert withMainModel:_model withViewModel:nil withDataDict:rfid withFileName:_fileName];
        rfidInfo.delegate = self;
        [self.navigationController pushViewController:rfidInfo animated:YES];
    }else if ([self.fileName isEqualToString:@"poleline"]){
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        PoleLineTYKViewController *device = [PoleLineTYKViewController
                                                         deviceInfomationWithControlMode:TYKDeviceListInsert
                                                         withMainModel:_model
                                                         withViewModel:nil
                                                         withDataDict:dict
                                                         withFileName:_fileName];
        device.delegate = self;
        [self.navigationController pushViewController:device animated:YES];
    }else if ([self.fileName isEqualToString:@"pipe"]){
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        PipeTYKViewController *device = [PipeTYKViewController
                                             deviceInfomationWithControlMode:TYKDeviceListInsert
                                             withMainModel:_model
                                             withViewModel:nil
                                             withDataDict:dict
                                             withFileName:_fileName];
        device.delegate = self;
        [self.navigationController pushViewController:device animated:YES];
    }else if ([self.fileName isEqualToString:@"ledUp"]||[self.fileName isEqualToString:@"markStoneSegment"]||[self.fileName isEqualToString:@"markStone"]||[self.fileName isEqualToString:@"well"]||[self.fileName isEqualToString:@"pipeSegment"]||[self.fileName isEqualToString:@"poleLineSegment"]||[self.fileName isEqualToString:@"stationBase"]||[self.fileName isEqualToString:@"EquipmentPoint"]||[self.fileName isEqualToString:@"route"]||[self.fileName isEqualToString:@"cable"]||[self.fileName isEqualToString:@"tube"] || [self.fileName isEqualToString:@"markStonePath"]){
        
        

//        pipeSegName pipeSegmentId
        // 上级传下来的map
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        
        if ([_fileName isEqualToString:@"tube"]) {
            
            dict[@"pipeSegment"] = self.dicIn[@"pipeSegName"] ?: @"";
            dict[@"pipeSegment_Id"] = self.dicIn[@"pipeSegmentId"] ?: @"";
        }
        
        TYKDeviceInfoMationViewController *device = [TYKDeviceInfoMationViewController
                                                     deviceInfomationWithControlMode:TYKDeviceListInsert
                                                     withMainModel:_model
                                                     withViewModel:nil
                                                     withDataDict:dict
                                                     withFileName:_fileName];
        device.delegate = self;
        // 袁全添加 ***  查看子孔时 是yes , 需要isFather字段
        if ([_fileName isEqualToString:@"tube"]) {
            device.isNeed_isFather = _isNeed_isFather;
        }
        
        [self.navigationController pushViewController:device animated:YES];
    }else{
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        TYKDeviceInfoMationViewController *device = [TYKDeviceInfoMationViewController
                                             deviceInfomationWithControlMode:TYKDeviceListInsertRfid
                                             withMainModel:_model
                                             withViewModel:nil
                                             withDataDict:dict
                                             withFileName:_fileName];
        device.delegate = self;
        
        [self.navigationController pushViewController:device animated:YES];
    }
}
//查询
-(IBAction)search:(UIButton *)sender
{
    [self yuan_searchClick];
}

- (void) yuan_searchClick {
    
       [_searchNameTextField resignFirstResponder];
        start = 1;
    //    NSString *resourceName = [_searchNameTextField.text isEqualToString:@""] ? @"\"\"":[NSString stringWithFormat:@"\"%@\"",_searchNameTextField.text];
        
        NSString * resourceName = @"";
        
        if (![self.fileName isEqualToString:@"markStonePath"]) {
            
            if (_searchNameTextField.text.length > 0) {
                resourceName = [NSString stringWithFormat:@"\"%@\"", _searchNameTextField.text];
            }else{
                resourceName = @"\"\"";
            }
            
        }else{
            
            if (_searchNameTextField.text.length > 0) {
                resourceName = _searchNameTextField.text;
            }
        }
    //调用查询
    [self ZZC_InterfaceRequest:resourceName];
}

//zzc 2021-05-11 新增编码查询  获取资源信息
- (void)ZZC_GetResourceData:(NSDictionary *) param{
    
    [Yuan_FL_HttpModel HTTP_FL_GetResWithDict:param
                                      success:^(id  _Nonnull result) {
        if (result) {
            NSArray *arr = result;
            if (_resourceArray == nil) {
                _resourceArray = [[NSMutableArray alloc] init];
            }
            
            if (start != 1 ) {
                [_resourceArray addObjectsFromArray:arr];
            }else{
                _resourceArray = [[NSMutableArray alloc] initWithArray:arr];
            }
        }
        [_resourceTableView.mj_header endRefreshing];
        [_resourceTableView.mj_footer endRefreshing];


        [_resourceTableView reloadData];
    }];
    
}

//获取资源信息
-(void)getResourceData:(NSDictionary *) param{
    //弹出进度框
    [[Yuan_HUD shareInstance] HUDStartText:@"请稍候……"];

    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
    
    
    NSString *postStr;
    if ([self.fileName isEqualToString:@"rfidInfo"]) {
        postStr = [NSString stringWithFormat:@"%@rm!getRfidAndGidRelation.interface",baseURL];
    }else if ([self.fileName isEqualToString:@"shelf"]) {
        postStr = [NSString stringWithFormat:@"%@rm!getShelfInfoByEqp.interface",baseURL];
    }else if ([self.fileName isEqualToString:@"card"]) {
        postStr = [NSString stringWithFormat:@"%@rm!getCardInfoByEqp.interface",baseURL];
    }else if ([self.fileName isEqualToString:@"port"]) {
        postStr = [NSString stringWithFormat:@"%@rm!getPortInfoByCard.interface",baseURL];
    }else if ([self.fileName isEqualToString:@"generator"]){
//        postStr = [NSString stringWithFormat:@"%@rm!get%@Data.interface",baseURL,[NSString stringWithFormat:@"%@%@",str1,str2]];
        ///MARK: 袁全更换 2020年5月27号 "一楼动力室机房"
        postStr = [NSString stringWithFormat:@"%@rm!getCommonData.interface",baseURL];
    }else if ([self.fileName isEqualToString:@"well"] && self.dicIn != nil/*2018年03月14日 添加条件判断，原因：要求通过管道进入井列表时调用此接口，通过井直接进入时走commonData*/){
        postStr = [NSString stringWithFormat:@"%@rm!getWellInPipe.interface",baseURL];
    }else{
        postStr = [NSString stringWithFormat:@"%@rm!getCommonData.interface",baseURL];
    }
    NSLog(@"postStr:%@",postStr);
    NSLog(@"%@", param);
    [Http.shareInstance POST:postStr parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {


        NSDictionary *dic = responseObject;
        
        if ([dic objectForKey:@"info"] == [NSNull null]) {
            
            [YuanHUD HUDFullText:@"数据异常"];
            return ;
        }
        
        if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {

            
            NSLog(@"--- %@",dic[@"info"]);
            
            
            NSString * info_Json = [dic objectForKey:@"info"];
            
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            
            
            // 去除空格 回车等
            NSData *tempData=[REPLACE_HHF(info_Json) dataUsingEncoding:NSUTF8StringEncoding];
            
            NSError * error ;  // TODO: 准备处理json解析失败的情况 
            
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:&error];
            
//            if (error) {
//                [[Yuan_HUD shareInstance] HUDFullText:@"json解析失败"];
//            }
            
            
            if (arr.count == 0) {
          
                [YuanHUD HUDFullText:@"未查询到相关信息"];
                
                [_resourceTableView.mj_header endRefreshing];
                [_resourceTableView.mj_footer endRefreshing];

                return;
            }
            if ([arr[0][@"MESS"] isEqualToString:@"统一库接口未开放或网络延迟问题"]) {
                [YuanHUD HUDFullText:@"统一库接口未开放或网络延迟问题"];

                return;
            }
            
            if (_resourceArray == nil) {
                
                _resourceArray = [[NSMutableArray alloc] init];
            
            }
            
            if (start != 1 ) {
                
                for (NSDictionary * dict in arr) {
                    
                    [_resourceArray addObject:dict];
                    
                }
                
            }else{
                _resourceArray = [[NSMutableArray alloc] initWithArray:arr];
            }
            
        }else{
        
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",REPLACE_HHF([dic objectForKey:@"info"])]];
            
            
        }
        
        //        NSLog(@"%@",_array.count);
        [_resourceTableView.mj_header endRefreshing];
        [_resourceTableView.mj_footer endRefreshing];

        [_resourceTableView reloadData];
      
        [[Yuan_HUD shareInstance] HUDHide];

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{

            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
    }];
}
#pragma mark tableviewdatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.resourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BOOL isHaveHandle = NO;
    
    if ([self.fileName isEqualToString:@"route"]||
        [self.fileName isEqualToString:@"poleline"]||
        [self.fileName isEqualToString:@"pipe"] ||
        [self.fileName isEqualToString:@"markStonePath"] ||
        [self.fileName isEqualToString:@"pipeSegment"]) {
        
        isHaveHandle = YES;
    }
    
    
    NSString *identifier = [NSString stringWithFormat:@"identifier%li%li",(long)indexPath.section,(long)indexPath.row];
    ResourceTYKTableViewCell *cell=[_resourceTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=
        [[ResourceTYKTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                        reuseIdentifier:identifier
                                        isHaveHandleBtn:isHaveHandle];
    }
    
    NSDictionary *dic = _resourceArray[indexPath.row];
    
    
    
    
    cell.dict = dic;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 右侧箭头
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    tableCellHeight = cell.backView.frame.size.height;
    
    // 非特殊不显示下部控制台按钮
    cell.handleView.hidden = YES;
    
    
    // 旧版 当这几个模块时 , 有侧滑
    /*
    if ([self.fileName isEqualToString:@"route"]||
        [self.fileName isEqualToString:@"poleline"]||
        [self.fileName isEqualToString:@"pipe"] ||
        [self.fileName isEqualToString:@"markStonePath"]) {
        
        UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [accessoryView setImage:[UIImage imageNamed:@"infoIcon"]];
        cell.accessoryView = accessoryView;
    }
    */
    
    // 新版 , 动态调整cell的高度
    
    
    if ([self.fileName isEqualToString:@"route"]||
        [self.fileName isEqualToString:@"poleline"]||
        [self.fileName isEqualToString:@"pipe"] ||
        [self.fileName isEqualToString:@"markStonePath"] ||
        [self.fileName isEqualToString:@"pipeSegment"]) {
        
        cell.handleView.hidden = NO;
        tableCellHeight = cell.backView.frame.size.height + Vertical(50);
        // 根据 resLogicName 配置按钮个数
        [cell configBtns:_fileName];
    }
    
    // 配置控制台按钮的点击事件
    cell.ResourceTYK_HandleBlock = ^(ResourceTYKCellEnum_ enumType) {
        [self Yuan_CellHandleBtnClick:enumType indexPath:indexPath];
    };
    
    
    return cell;
}

//点击跳转到详细信息
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.facilitiesBlock) {
        Pop(self);
        self.facilitiesBlock(_resourceArray[indexPath.row]);
        return;
    }
    
    if ([self.fileName isEqualToString:@"generator"]) {
        GeneratorTYKViewController * device = [GeneratorTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_model withViewModel:_viewModel withDataDict:_resourceArray[indexPath.row] withFileName:self.fileName];
        device.delegate = self;
        
        [self.navigationController pushViewController:device animated:YES];
    }else if ([self.fileName isEqualToString:@"route"]){
        RouteTYKViewController * device = [RouteTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_model withViewModel:_viewModel withDataDict:_resourceArray[indexPath.row] withFileName:self.fileName];
        device.delegate = self;
        
        [self.navigationController pushViewController:device animated:YES];

    }else if ([self.fileName isEqualToString:@"cable"]){
        
        //MARK: 袁全 -- -- 当filename 为光缆段时 有一个判断 , 区分智能判障 和 普通的
        
        
        if (_YuanBlock && [_isLiteSmart isEqualToString:@"isLiteSmart"]) {
            
            [UIAlert alertSmallTitle:@"是否选择此光缆段" agreeBtnBlock:^(UIAlertAction *action) {
                NSDictionary * dic = _resourceArray[indexPath.row];
                //证明 是智能判障进来的 , 不是正常列表进来的
                self->_YuanBlock(dic);  // ID 和 title;
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            
        }else {
            
            [YuanHUD HUDFullText:@"到这了CableTYKViewController "];
//            CableTYKViewController * device = [CableTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_model withViewModel:_viewModel withDataDict:_resourceArray[indexPath.row] withFileName:self.fileName];
//            device.delegate = self;
//
//
//
//            [self.navigationController pushViewController:device animated:YES];
            
        }
        
    }else if ([self.fileName isEqualToString:@"rfidInfo"]) {
        RFIDTYKViewController *rfidInfo = [RFIDTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_model withViewModel:nil withDataDict:_resourceArray[indexPath.row] withFileName:_fileName];
        rfidInfo.delegate = self;
        rfidInfo.isUpdate = YES;
        [self.navigationController pushViewController:rfidInfo animated:YES];
    }else if ([self.fileName isEqualToString:@"card"]) {
        
        [YuanHUD HUDFullText:@"到这了CardTYKViewController a"];
        
//        CardTYKViewController *device = [CardTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_model withViewModel:nil withDataDict:_resourceArray[indexPath.row] withFileName:_fileName];
//        device.delegate = self;
//
//        [self.navigationController pushViewController:device animated:YES];
    }else if ([self.fileName isEqualToString:@"poleline"]){
        PoleLineTYKViewController *device = [PoleLineTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_model withViewModel:_viewModel withDataDict:_resourceArray[indexPath.row] withFileName:self.fileName];
        device.delegate = self;
        [self.navigationController pushViewController:device animated:YES];
    }else if ([self.fileName isEqualToString:@"pipe"]){
        PipeTYKViewController *device = [PipeTYKViewController deviceInfomationWithControlMode:TYKDeviceListUpdate withMainModel:_model withViewModel:_viewModel withDataDict:_resourceArray[indexPath.row] withFileName:self.fileName];
        device.delegate = self;
        [self.navigationController pushViewController:device animated:YES];
    }else if ([self.fileName isEqualToString:@"ledUp"]||
              [self.fileName isEqualToString:@"markStoneSegment"]||
              [self.fileName isEqualToString:@"markStone"]||
              [self.fileName isEqualToString:@"well"]||
              [self.fileName isEqualToString:@"pipeSegment"]||
              [self.fileName isEqualToString:@"poleLineSegment"]||
              [self.fileName isEqualToString:@"stationBase"]||
              [self.fileName isEqualToString:@"EquipmentPoint"]||
              [self.fileName isEqualToString:@"tube"] ||
              [self.fileName isEqualToString:@"markStonePath"]){
        
        TYKDeviceListControlTypeRef mode = TYKDeviceListUpdate;
        
        if ([self.fileName isEqualToString:@"well"] ||
            [self.fileName isEqualToString:@"markStone"]) {
            mode = TYKDeviceListUpdateRfid;
        }
        
        TYKDeviceInfoMationViewController *device = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:mode withMainModel:_model withViewModel:_viewModel withDataDict:_resourceArray[indexPath.row] withFileName:self.fileName];
        device.delegate = self;
        
        // yuan ****
        if ([_fileName isEqualToString:@"tube"]) {
            device.isNeed_isFather = _isNeed_isFather;
        }
        
        [self.navigationController pushViewController:device animated:YES];
    }
    
    else{
        
        // 袁全添加 扫楼关联设备时使用 , 借用了自动判障时写的block
        if ([self.fileName isEqualToString:@"ODB_Equt"] && _YuanBlock) {
            
            NSDictionary * dic = _resourceArray[indexPath.row];
            _YuanBlock(dic);
            [self dismissViewControllerAnimated:YES completion:nil];
            
            return;
        }
        
        
        TYKDeviceInfoMationViewController *device = [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid withMainModel:_model withViewModel:_viewModel withDataDict:_resourceArray[indexPath.row] withFileName:self.fileName];
        device.delegate = self;
        device.sourceFileName = self.sourceFileName;
        [self.navigationController pushViewController:device animated:YES];
    }
}


- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath{

    
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
    
}



- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 新版 只保留删除侧滑 , 其余的都移入按钮中处理事件
   
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self deleteDeviceWithDict:self.resourceArray[indexPath.row] withViewControllerClass:[self class]];
        
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    
    if ([[[UserModel.powersTYKDic[self.fileName] substringFromIndex:1] substringToIndex:1] integerValue]==1) {
        return @[deleteAction];
    }
    else {
        return @[];
    }
  
    
    /// ***** 旧版 侧滑业务 **** **** 
    
    if ([self.fileName isEqualToString:@"route"]) {
        UITableViewRowAction *cableAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"光缆段"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
            resourceTYKListVC.dicIn = _resourceArray[indexPath.row];
            resourceTYKListVC.fileName = @"cable";
            resourceTYKListVC.showName = @"光缆段";
            [self.navigationController pushViewController:resourceTYKListVC animated:YES];
            
        }];
        cableAction.backgroundColor = [UIColor colorWithHexString:@"#ff5809"];
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [self deleteDeviceWithDict:self.resourceArray[indexPath.row] withViewControllerClass:[self class]];
        }];
        deleteAction.backgroundColor = [UIColor redColor];
        if ([[[UserModel.powersTYKDic[self.fileName] substringFromIndex:1] substringToIndex:1] integerValue]==1) {
            return @[deleteAction,cableAction];
        }
        return @[cableAction];
    }
    if ([self.fileName isEqualToString:@"poleline"]) {
        UITableViewRowAction *polelineSegAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"杆路段"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
            resourceTYKListVC.dicIn = _resourceArray[indexPath.row];
            resourceTYKListVC.fileName = @"poleLineSegment";
            resourceTYKListVC.showName = @"杆路段";
            [self.navigationController pushViewController:resourceTYKListVC animated:YES];
        }];
        polelineSegAction.backgroundColor = [UIColor colorWithHexString:@"#ff5809"];
        
        UITableViewRowAction *poleAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"电杆"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
            resourceTYKListVC.dicIn = _resourceArray[indexPath.row];
            resourceTYKListVC.fileName = @"pole";
            resourceTYKListVC.showName = @"电杆";
            [self.navigationController pushViewController:resourceTYKListVC animated:YES];
        }];
        poleAction.backgroundColor = [UIColor colorWithHexString:@"#06c"];
        
        UITableViewRowAction *poleLocationAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"定位"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            PoleLineMapMainTYKViewController * poleMGD = [[PoleLineMapMainTYKViewController alloc] init];
            poleMGD.delegate = self;
            poleMGD.poleLine = [_resourceArray[indexPath.row] mutableCopy];
           
            [self.navigationController pushViewController:poleMGD animated:YES];
        }];
        poleLocationAction.backgroundColor = [UIColor colorWithHexString:@"#eac100"];
        
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [self deleteDeviceWithDict:self.resourceArray[indexPath.row] withViewControllerClass:[self class]];
        }];
        deleteAction.backgroundColor = [UIColor redColor];
        if ([[[UserModel.powersTYKDic[self.fileName] substringFromIndex:1] substringToIndex:1] integerValue]==1) {
            return @[deleteAction,poleLocationAction,poleAction,polelineSegAction];
        }
        return @[poleLocationAction,poleAction,polelineSegAction];
    }
    if ([self.fileName isEqualToString:@"pipe"]) {
        UITableViewRowAction *polelineSegAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"管道段"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
            resourceTYKListVC.dicIn = _resourceArray[indexPath.row];
            resourceTYKListVC.fileName = @"pipeSegment";
            resourceTYKListVC.showName = @"管道段";
            [self.navigationController pushViewController:resourceTYKListVC animated:YES];
        }];
        polelineSegAction.backgroundColor = [UIColor colorWithHexString:@"#ff5809"];
        
        UITableViewRowAction *poleAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"井"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
            resourceTYKListVC.dicIn = _resourceArray[indexPath.row];
            resourceTYKListVC.fileName = @"well";
            resourceTYKListVC.showName = @"井";
            [self.navigationController pushViewController:resourceTYKListVC animated:YES];
        }]; 
        poleAction.backgroundColor = [UIColor colorWithHexString:@"#06c"];
        
        UITableViewRowAction *poleLocationAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"定位"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            PipeMapMainTYKViewController * pipeMGD = [[PipeMapMainTYKViewController alloc] init];
            pipeMGD.delegate = self;
            pipeMGD.pipe = [_resourceArray[indexPath.row] mutableCopy];
            
            [self.navigationController pushViewController:pipeMGD animated:YES];
        }];
        poleLocationAction.backgroundColor = [UIColor colorWithHexString:@"#eac100"];
        
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [self deleteDeviceWithDict:self.resourceArray[indexPath.row] withViewControllerClass:[self class]];
        }];
        deleteAction.backgroundColor = [UIColor redColor];
        
        if ([[[UserModel.powersTYKDic[self.fileName] substringFromIndex:1] substringToIndex:1] integerValue]==1) {
            return @[deleteAction,poleLocationAction,poleAction,polelineSegAction];
        }
        return @[poleLocationAction,poleAction,polelineSegAction];
    }

    if ([self.fileName isEqualToString:@"pipeSegment"]) {
        UITableViewRowAction *markStoneSegmentLocationAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"管孔"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            
            ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
            resourceTYKListVC.dicIn = _resourceArray[indexPath.row];
            resourceTYKListVC.fileName = @"tube";
            resourceTYKListVC.showName = @"管孔";
            [self.navigationController pushViewController:resourceTYKListVC animated:YES];
        }];
        markStoneSegmentLocationAction.backgroundColor = [UIColor colorWithHexString:@"#ff5809"];
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [self deleteDeviceWithDict:self.resourceArray[indexPath.row] withViewControllerClass:[self class]];
        }];
        deleteAction.backgroundColor = [UIColor redColor];
        if ([[[UserModel.powersTYKDic[self.fileName] substringFromIndex:1] substringToIndex:1] integerValue]==1) {
            return @[deleteAction,markStoneSegmentLocationAction];
        }
        return @[markStoneSegmentLocationAction];
    }
    
    
    if ([self.fileName isEqualToString:@"markStonePath"]) {
        
        UITableViewRowAction *markStoneSegementAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"标石段"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
            resourceTYKListVC.dicIn = _resourceArray[indexPath.row];
            resourceTYKListVC.fileName = @"markStoneSegment";
            resourceTYKListVC.showName = @"标石段";
            [self.navigationController pushViewController:resourceTYKListVC animated:YES];
        }];
        markStoneSegementAction.backgroundColor = [UIColor colorWithHexString:@"#ff5809"];
        
        UITableViewRowAction *markStoneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"标石"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
            resourceTYKListVC.dicIn = _resourceArray[indexPath.row];
            resourceTYKListVC.fileName = @"markStone";
            resourceTYKListVC.showName = @"标石";
            [self.navigationController pushViewController:resourceTYKListVC animated:YES];
        }];
        markStoneAction.backgroundColor = [UIColor colorWithHexString:@"#06c"];
        
        UITableViewRowAction *locationAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"定位"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            IWPULMarkStonePathLocationViewController * poleMGD = [[IWPULMarkStonePathLocationViewController alloc] init];
            
            NSLog(@"%@", _resourceArray[indexPath.row]);
            
            poleMGD.delegate = self;
            poleMGD.markStonePath = [_resourceArray[indexPath.row] mutableCopy];
            
            [self.navigationController pushViewController:poleMGD animated:YES];
        }];
        locationAction.backgroundColor = [UIColor colorWithHexString:@"#eac100"];
        
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [self deleteDeviceWithDict:self.resourceArray[indexPath.row] withViewControllerClass:[self class]];
        }];
        deleteAction.backgroundColor = [UIColor redColor];
        if ([[[UserModel.powersTYKDic[self.fileName] substringFromIndex:1] substringToIndex:1] integerValue]==1) {
            return @[deleteAction,locationAction,markStoneAction,markStoneSegementAction];
        }
        return @[locationAction,markStoneAction,markStoneSegementAction];
        
        
    }
    
    return @[];
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.fileName isEqualToString:@"route"]||[self.fileName isEqualToString:@"rfidInfo"]||[self.fileName isEqualToString:@"poleline"]||[self.fileName isEqualToString:@"pipe"]||[self.fileName isEqualToString:@"markStonePath"]||[self.fileName isEqualToString:@"pipeSegment"]) {
        return YES;
    }else if ([self.fileName isEqualToString:@"pole"]||[self.fileName isEqualToString:@"poleLineSegment"]||[self.fileName isEqualToString:@"well"]||[self.fileName isEqualToString:@"markStonePath"]||[self.fileName isEqualToString:@"ledUp"]||[self.fileName isEqualToString:@"supportingPoints"]) {
        if ([[[UserModel.powersTYKDic[self.fileName] substringFromIndex:1] substringToIndex:1] integerValue]==1) {
            return YES;
        }
        return NO;
    }else{
        if ([[[UserModel.powersTYKDic[self.fileName] substringFromIndex:1] substringToIndex:1] integerValue]==1) {
            return YES;
        }
        return NO;
    }
    return NO;
}
#pragma mark tableviewdelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableCellHeight;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //当捕捉到触摸事件时，取消UITextField的第一响应
    if ([(UITextField *)[self.view viewWithTag:200] isFirstResponder]) {
        [(UITextField *)[self.view viewWithTag:200] resignFirstResponder];
    }
}



-(void)newDeciceWithDict:(NSDictionary<NSString *,NSString *> *)dict{
    NSLog(@"--dict:%@",dict);
    NSString * key = @"GID";
    
    if ([self.fileName isEqualToString:@"markStonePath"]) {
        key = @"markStonePathId";
    }
    
    if (dict[@"onlyUpdateRfid"]!=nil &&([dict[@"onlyUpdateRfid"] intValue]==1)) {
        //仅修改二维码
        for (int i = 0; i<self.resourceArray.count; i++) {
            if ([dict[key] isEqualToString:self.resourceArray[i][key]]) {
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:self.resourceArray[i]];
               
                if (dict[@"rfid"] != nil) {
                     [tempDic setObject:dict[@"rfid"] forKey:@"rfid"];
                }
                
                self.resourceArray[i] = tempDic;
                [_resourceTableView reloadData];
                break;
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([self.fileName isEqualToString:@"rfidInfo"]) {
        BOOL isHave = NO;
        for (int i = 0; i<self.resourceArray.count; i++) {
            if ([dict[@"rfid"] isEqualToString:self.resourceArray[i][@"rfid"]]) {
                self.resourceArray[i] = dict;
                isHave = YES;
                break;
            }
        }
        if (!isHave) {
            [self.resourceArray addObject:dict];
        }
        [_resourceTableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
//    if ([self.fileName isEqualToString:@"poleline"]||[self.fileName isEqualToString:@"pipe"]||[self.fileName isEqualToString:@"supportingPoints"]||[self.fileName isEqualToString:@"ledUp"]||[self.fileName isEqualToString:@"markStoneSegment"]||[self.fileName isEqualToString:@"markStone"]) {
    
    
    
    
        BOOL isHave = NO;
        for (int i = 0; i<self.resourceArray.count; i++) {
            if ([dict[key] isEqualToString:self.resourceArray[i][key]]) {
                self.resourceArray[i] = dict;
                isHave = YES;
                break;
            }
        }
        if (!isHave) {
            if (self.resourceArray == nil) {
                self.resourceArray = [[NSMutableArray alloc] init];
            }
            [self.resourceArray addObject:dict];
        }
        [_resourceTableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
//        return;
//    }
//    for (int i = 0; i<self.resourceArray.count; i++) {
//        if ([dict[@"GID"] isEqualToString:self.resourceArray[i][@"GID"]]) {
//            self.resourceArray[i] = dict;
//            [_resourceTableView reloadData];
//            break;
//        }
//    }
//    [self.navigationController popViewControllerAnimated:YES];
}
-(void)deleteDeviceWithDict:(NSDictionary *)dict withViewControllerClass:(Class)vcClass{
    
    if ([self.fileName isEqualToString:@"rfidInfo"]) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"确定要删除该%@?",_model.name] preferredStyle:UIAlertControllerStyleAlert];
        
        __weak typeof(self) wself = self;
        UIAlertAction * actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[Yuan_HUD shareInstance] HUDStartText:@"正在删除，请稍候……"];

            
#ifdef BaseURL
            NSString * baseURL = BaseURL;
#else
            NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
            
            NSString * requestURL = [NSString stringWithFormat:@"%@%@", baseURL, @"rm!deleteCommonData.interface"];
            NSLog(@"%@",requestURL);
            
            NSMutableDictionary * param = [NSMutableDictionary dictionary];
            [param setValue:UserModel.uid forKey:@"UID"];
            
            [param setValue:DictToString(dict) forKey:@"jsonRequest"];
            
            [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

                        
                NSDictionary *dic = responseObject;
                
                if ([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
                    
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除成功" preferredStyle: UIAlertControllerStyleAlert];
                    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        if (vcClass == wself.class) { // 判断控制器类型
                            for (NSDictionary *dic in self.resourceArray) {
                                if ([dic[@"GIDandRFIDrelationId"] isEqualToString:dict[@"GIDandRFIDrelationId"]]) {
                                    [self.resourceArray removeObject:dic];
                                    break;
                                }
                            }
                            [_resourceTableView reloadData];
                            return;
                        }else{
                            for (NSDictionary *dic in self.resourceArray) {
                                if ([dic[@"GIDandRFIDrelationId"] isEqualToString:dict[@"GIDandRFIDrelationId"]]) {
                                    [self.resourceArray removeObject:dic];
                                    break;
                                }
                            }
                            [_resourceTableView reloadData];
                            [wself.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                    
                    [alert addAction:action];
                    Present(self.navigationController, alert);
                    
                } else {
                    [YuanHUD HUDFullText:@"删除失败"];

                }
                
                [[Yuan_HUD shareInstance] HUDHide];

                
            }  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                
                [[Yuan_HUD shareInstance] HUDHide];

                dispatch_async(dispatch_get_main_queue(), ^{

                    [YuanHUD HUDFullText:@"亲，网络请求出错了"];
                });
            }];
            
            
        }];
        UIAlertAction * actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
        
        [alert addAction:actionYES];
        [alert addAction:actionNO];
        Present(self, alert);
    }
    
    
    // 普通的资源删除
    else{
        
        
        // 普通删除时
        
        [UIAlert alertSmallTitle:[NSString stringWithFormat:@"确定要删除该%@?",_model.name] agreeBtnBlock:^(UIAlertAction *action) {
            [self normal_Delete:dict withViewControllerClass:vcClass];
        }];
        
    }
}



- (void) normal_Delete:(NSDictionary *)dict withViewControllerClass:(Class)vcClass{
    
    __typeof(self)wself = self;
    //弹出进度框

    [[Yuan_HUD shareInstance] HUDStartText:@"正在删除，请稍候……"];

    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setValue:UserModel.uid forKey:@"UID"];
    
    [param setValue:DictToString(dict) forKey:@"jsonRequest"];
    
    
#ifdef BaseURL
    NSString * baseURL = BaseURL;
#else
    NSString * baseURL = BaseURL_Auto(([IWPServerService sharedService].link));
#endif
    
    
    NSString * api = @"rm!deleteCommonData.interface";
    
    if ([self.fileName isEqualToString:@"markStonePath"]) {
        
        api = @"rm!deleteCommonData.interface";
        
    }else if ([self.fileName isEqualToString:@"markStone"]){
        
        api = @"rm!deleteCommonData.interface";
        
    }else if ([self.fileName isEqualToString:@"markStoneSegment"]){
        
        api = @"rm!deleteMarkStoneSeg.interface";
    
    }
    
    [Http.shareInstance POST:[NSString stringWithFormat:@"%@%@",baseURL, api] parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        

        NSDictionary *dic = responseObject;
        if([[dic objectForKey:@"result"] isEqualToNumber:[NSNumber numberWithInt:0]]) {

            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除成功" preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (vcClass == wself.class) { // 判断控制器类型
                    
                    NSString * idKey = @"GID";
                    
                    if ([self.fileName isEqualToString:@"markStonePath"]) {
                        idKey = [self.fileName makeDeviceId];
                    }
                    
                    for (NSDictionary *dic in self.resourceArray) {
                        if ([dic[idKey] isEqualToString:dict[idKey]]) {
                            [self.resourceArray removeObject:dic];
                            break;
                        }
                    }
                    [_resourceTableView reloadData];
                    return;
                }else{
                    NSString * idKey = @"GID";
                    
                    if ([self.fileName isEqualToString:@"markStonePath"]) {
                        idKey = [self.fileName makeDeviceId];
                    }
                    
                    
                    for (NSDictionary *dic in self.resourceArray) {
                        if ([dic[idKey] isEqualToString:dict[idKey]]) {
                            [self.resourceArray removeObject:dic];
                            break;
                        }
                    }
                    [_resourceTableView reloadData];
                    [wself.navigationController popViewControllerAnimated:YES];
                }
            }];
            
            [alert addAction:action];
            Present(self.navigationController, alert);
            
        }else{
          
            
            if (dic==nil ||([dic objectForKey:@"info"]==nil)) {

                [YuanHUD HUDFullText:@"操作失败，数据为空"];
            }else{
                
                NSString * info = dic[@"info"];
                
                if ([_fileName isEqualToAnyString:@"ODF_Equt",
                                                 @"ODB_Equt",
                                                 @"OCC_Equt",
                                                 @"poleline",
                                                 @"pipe",
                                                 @"markStonePath",
                                                 @"cable",
                                                 nil]) {
                    
                    // 级联删除呀 !!!
                    [self moreLevelDelete:dic resDict:dict];
                    
                }
                else {
                    [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@",info]];

                }
                
            }
          
        }
        
        [[Yuan_HUD shareInstance] HUDHide];

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{

            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
        
    }];
    
}


#pragma mark - 级联删除 ---
- (void) moreLevelDelete:(NSDictionary *) errorDict resDict:(NSDictionary * )resDict{
    
    Yuan_MoreLevelDeleteVC * vc = [[Yuan_MoreLevelDeleteVC alloc] initWithRequestDict:errorDict];
    
    self.definesPresentationContext = true;
    
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.resourceDict = resDict;
    vc.resName = _model.list_sreach_name;
    
    
    [self presentViewController:vc
                       animated:NO
                     completion:^{
        
        // 只让 view半透明 , 但其上方的其他view不受影响
        vc.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }];
    
}


-(void)reloadTableViewWithDict:(NSDictionary *)dict{
    for (NSDictionary *dic in self.resourceArray) {
        if ([dic[@"GID"] isEqualToString:dict[@"GID"]]) {
            [self.resourceArray removeObject:dic];
            break;
        }
    }
    [_resourceTableView reloadData];
}
-(void)deleteMarkStoneWithDict:(NSDictionary *)dict withClass:(Class)class{
    
//    [self deleteDeviceWithDict:dict withViewControllerClass:class];
    [self deleteMapDevice:dict withClass:class];
    
}

-(void)deleteMapDevice:(NSDictionary *)dict withClass:(Class)class{
    // 删除事件
    
    [[Yuan_HUD shareInstance] HUDStartText:@"正在删除，请稍候……"];

    
#ifdef BaseURL
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL, _model.delete_name];
#else
    NSString * requestURL = [NSString stringWithFormat:@"%@%@", BaseURL_Auto(([IWPServerService sharedService].link)), _model.delete_name];
#endif
    
    
    NSLog(@"%@",requestURL);
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setValue:UserModel.uid forKey:@"UID"];
    
    [param setValue:DictToString(dict) forKey:@"jsonRequest"];
    __weak typeof(self) wself = self;
    
    [Http.shareInstance POST:requestURL parameters:param success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {

        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除成功" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [wself.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert addAction:action];
        Present(self.navigationController, alert);
        [[Yuan_HUD shareInstance] HUDHide];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
        [[Yuan_HUD shareInstance] HUDHide];

        dispatch_async(dispatch_get_main_queue(), ^{

            [YuanHUD HUDFullText:@"亲，网络请求出错了"];
        });
    }];

}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    _searchNameTextField.hidden = NO;
}



- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    _searchNameTextField.hidden = YES;
}


- (void)dealloc {
    
    [_searchNameTextField removeFromSuperview];
    _searchNameTextField = nil;
}


- (void) naviBarSet {
    //
    
    self.title = @"";
    
    _searchNameTextField = [UIView textFieldFrame:CGRectMake(0, 20, ScreenWidth/4 * 3, 35)];
    _searchNameTextField.backgroundColor = UIColor.whiteColor;
    [_searchNameTextField cornerRadius:5
                           borderWidth:0
                           borderColor:UIColor.whiteColor];
    
    UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TYKList_Search_New"]];
    img.contentMode =UIViewContentModeScaleAspectFit;
    
    _searchNameTextField.leftView = img;
    
    _searchNameTextField.leftViewMode = UITextFieldViewModeAlways;
    _searchNameTextField.placeholder = @"";
    
    _searchNameTextField.delegate = self;
    
    // 搜索
    _searchNameTextField.returnKeyType= UIReturnKeySearch;
    
    [self.navigationController.navigationBar addSubview:_searchNameTextField];
    
    [_searchNameTextField YuanAttributeVerticalToView:self.navigationController.navigationBar];
    [_searchNameTextField YuanAttributeHorizontalToView:self.navigationController.navigationBar];
    [_searchNameTextField autoSetDimensionsToSize:CGSizeMake(ScreenWidth/3 * 2, 35)];
    
    
    NSString * showName ;
    
    if ([self.showName containsString:@"光分纤"]) {
        showName = @"光分纤箱";
    }
    else {
        showName = self.showName;
    }
    
    NSString * placeholder_Txt = [NSString stringWithFormat:@"请输入%@名称进行搜索",showName ?: @"设备"];
    
    _placeHolder = [UIView labelWithTitle:placeholder_Txt
                                             frame:CGRectNull];
    
    _placeHolder.font = [UIFont systemFontOfSize:13];
    _placeHolder.textColor = ColorValue_RGB(0x666666);
    [_searchNameTextField addSubview:_placeHolder];
    
    [_placeHolder YuanAttributeHorizontalToView:_searchNameTextField];
    [_placeHolder YuanAttributeVerticalToView:_searchNameTextField];
    
    
    if (_searchMsg && _searchMsg.length > 0) {
        _placeHolder.hidden = YES;
        _searchNameTextField.text = _searchMsg;
    }
    
    
    UIBarButtonItem * searchBtn = [UIView getBarButtonItemWithTitleStr:@"搜索" Sel:@selector(naviSearchClick) VC:self];
    
    self.navigationItem.rightBarButtonItems = @[searchBtn];
    
}

//zzc 2021-05-11 新增编码查询使用搜索框
- (void) ZZC_NaviBarSet {
    
    self.title = @"";
    
    
    UIBarButtonItem * searchBtn = [UIView getBarButtonItemWithTitleStr:@"搜索" Sel:@selector(naviSearchClick) VC:self];
    self.navigationItem.rightBarButtonItems = @[searchBtn];
    
}

//zzc 2021-05-11 新增编码查询下拉按钮
-(UIView *)ZZC_SearchLeftView {
    
    UIView *leftView = [[UIView alloc]init];
    _leftDropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftDropBtn setTitle:@"设备名称" forState:UIControlStateNormal];
    _leftDropBtn.titleLabel.font = Font(13);
    CGFloat width = [_leftDropBtn.titleLabel.text boundingRectWithSize:CGSizeMake(80, 35)
                                                     options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:Font(13)}
                                                context:nil].size.width;
    
    [_leftDropBtn setFrame:CGRectMake(0, 0, width+7, 35)];
    [_leftDropBtn setTitleColor:HexColor(@"#505050") forState:UIControlStateNormal];
    [_leftDropBtn addTarget:self
            action:@selector(showMenu:)
         forControlEvents:UIControlEventTouchUpInside];
    
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(_leftDropBtn.width, 15, 5, 5)];
    img.image = [UIImage imageNamed:@"XJ_icon_xiala"];
    
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(img.width + img.origin.x + 7, 12, 1, 11)];
    lineLabel.backgroundColor = ColorValue_RGB(0x666666);
    
    [leftView addSubviews:@[_leftDropBtn,img,lineLabel]];
    
    leftView.frame = CGRectMake(0, 0, lineLabel.origin.x + 8, 35);
    
    return leftView;
}

- (void)showMenu:(UIButton *)btn{
    
    if (self.menuView.isFocused){
        
        [self.menuView hidMenuExitAnimation:MLAnimationStyleRight];
        
    }else{
        [self.menuView showMenuEnterAnimation:MLAnimationStyleRight];
    }
    
}


// 搜索
- (void) naviSearchClick {
    
    [self.view endEditing:YES];
    [self yuan_searchClick];
}



// 执行搜索
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    [self yuan_searchClick];
    
    return YES;
}





- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    _placeHolder.hidden = YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (_searchNameTextField.text.length == 0) {
        _placeHolder.hidden = NO;
        return;
    }
    
    _placeHolder.hidden = YES;
}




- (void) Yuan_CellHandleBtnClick:(ResourceTYKCellEnum_) enumType
                       indexPath:(NSIndexPath *)indexPath{
    
    NSString * resLogicName = self.fileName;
    
    
    // 一级资源
    if (enumType == ResourceTYKCellEnum_Section) {
        
        NSString * myResLogicName = @"";
        NSString * myShowName = @"";
        
        if ([resLogicName isEqualToString:@"route"]) {
            myResLogicName = @"cable";
            myShowName = @"光缆段";
        }
        
        else if ([resLogicName isEqualToString:@"poleline"]) {
            
            myResLogicName = @"poleLineSegment";
            myShowName = @"杆路段";
        }
        
        else if ([resLogicName isEqualToString:@"pipe"]) {
            myResLogicName = @"pipeSegment";
            myShowName = @"管道段";
        }
        
        else if ([resLogicName isEqualToString:@"pipeSegment"]) {
            myResLogicName = @"tube";
            myShowName = @"管孔";
        }
        
        else if ([resLogicName isEqualToString:@"markStonePath"]) {
            myResLogicName = @"markStoneSegment";
            myShowName = @"标石段";
        }
        
        else {
            [[Yuan_HUD shareInstance] HUDFullText:@"未录入的ResLogicName"];
            return;
        }
        
        
        [self pushList:myResLogicName
              showName:myShowName
             indexPath:indexPath];
    }
    
    
    // 二级资源
    if (enumType == ResourceTYKCellEnum_SubRes) {
        
        NSString * myResLogicName = @"";
        NSString * myShowName = @"";
        
        // 杆路
        if ([resLogicName isEqualToString:@"poleline"]) {
            
            myResLogicName = @"pole";
            myShowName = @"电杆";
        }
        
        else if ([resLogicName isEqualToString:@"pipe"]) {
            
            myResLogicName = @"well";
            myShowName = @"井";
        }
        
        else if ([resLogicName isEqualToString:@"markStonePath"]) {
            
            myResLogicName = @"markStone";
            myShowName = @"标石";
        }
        
        else {
            
            [[Yuan_HUD shareInstance] HUDFullText:@"未录入的ResLogicName"];
            return;
        }
        
        [self pushList:myResLogicName
              showName:myShowName
             indexPath:indexPath];
        
        
    }
    
    
    // 定位
    if (enumType == ResourceTYKCellEnum_Location) {
        
        // 杆路 定位
        if ([resLogicName isEqualToString:@"poleline"]) {
            
            Inc_PoleNewConfigVC * poleMGD_New = [[Inc_PoleNewConfigVC alloc] initWithDict:_resourceArray[indexPath.row]];

            Push(self, poleMGD_New);

            return;
            
            // 旧版 电杆定位   *** 已经废弃了
            PoleLineMapMainTYKViewController * poleMGD = [[PoleLineMapMainTYKViewController alloc] init];
            poleMGD.delegate = self;
            poleMGD.poleLine = [_resourceArray[indexPath.row] mutableCopy];
            
            [self.navigationController pushViewController:poleMGD animated:YES];
        }
        
        else if ([resLogicName isEqualToString:@"pipe"]) {
            
            PipeMapMainTYKViewController * pipeMGD = [[PipeMapMainTYKViewController alloc] init];
            pipeMGD.delegate = self;
            pipeMGD.pipe = [_resourceArray[indexPath.row] mutableCopy];
            
            [self.navigationController pushViewController:pipeMGD animated:YES];
            
        }
        
        else if ([resLogicName isEqualToString:@"markStonePath"]) {
            
            IWPULMarkStonePathLocationViewController * poleMGD = [[IWPULMarkStonePathLocationViewController alloc] init];
            
            NSLog(@"%@", _resourceArray[indexPath.row]);
            
            poleMGD.delegate = self;
            poleMGD.markStonePath = [_resourceArray[indexPath.row] mutableCopy];
            
            [self.navigationController pushViewController:poleMGD animated:YES];
            
        }
        
    }
    
    
}


- (void) pushList:(NSString *)resLogicName
         showName:(NSString *)showName
        indexPath:(NSIndexPath *)indexPath{
    
    ResourceTYKListViewController *resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
    resourceTYKListVC.dicIn = _resourceArray[indexPath.row];
    resourceTYKListVC.fileName = resLogicName;
    resourceTYKListVC.showName = showName;
    [self.navigationController pushViewController:resourceTYKListVC animated:YES];
    
}

#pragma mark - 懒加载  菜单

//zzc 2021-05-11 搜索框下拉菜单view
-(MLMenuView *)menuView{
    
    if (_menuView == nil) {
        
        NSArray * items = [self createItems];

        NSMutableArray * titles = [NSMutableArray array];
        NSMutableArray * images = [NSMutableArray array];
        
        for (IWPPopverViewItem * dict in items) {
            
            if (dict.title) {
                [titles addObject:dict.title];
            }
            
        }

        MLMenuView * menuView = [[MLMenuView alloc] initWithFrame:CGRectMake(Horizontal(10), 0, Horizontal(120), 0) WithTitles:titles WithImageNames:images.count > 0 ? images : nil WithMenuViewOffsetTop:NaviBarHeight WithTriangleOffsetLeft:Horizontal(94) triangleColor:[UIColor.groupTableViewBackgroundColor colorWithAlphaComponent:1]];
        
        _menuView = menuView;
        [self.view addSubview:menuView];
        
        menuView.separatorOffSet = Horizontal(5);
        menuView.separatorColor = UIColor.systemGrayColor;
        [menuView brightColor:UIColor.whiteColor radius:10 offset:CGSizeMake(2, 2) opacity:1.f];
        [menuView setMenuViewBackgroundColor:[UIColor.groupTableViewBackgroundColor colorWithAlphaComponent:1]];
        menuView.titleColor = UIColor.blackColor;
        menuView.font = [UIFont systemFontOfSize:12];
        
        [menuView setCoverViewBackgroundColor:UIColor.clearColor];
        menuView.delegate = self;
               
    }
    
    return _menuView;
    
}

//zzc 2021-05-11 新增编码查询下拉菜单view
- (NSArray *)createItems{

    NSMutableArray * itemsModel = NSMutableArray.array;
    
    [itemsModel addObject:@{kTitle:@"设备名称",
                            kImageName:@"",
                            kHandler:@"ZZC_EquipmentName:",
                            kEnabled:[NSNumber numberWithBool:true]}];
    
    [itemsModel addObject:@{kTitle:@"设备编码",
                            kImageName:@"",
                            kHandler:@"ZZC_EquipmentCode:",
                            kEnabled:[NSNumber numberWithBool:true]}];
    
    
    NSMutableArray * items = [NSMutableArray array];
    
    for (NSInteger i = 0; i < itemsModel.count; i++) {
        NSDictionary * dict = itemsModel[i];
        IWPPopverViewItem * item = [[IWPPopverViewItem alloc] init];
        item.title = dict[kTitle];
        item.imageName = dict[kImageName];
        item.action = dict[kHandler];
        item.selectedTitle = dict[kSelectedTitle] ? dict[kSelectedTitle] : dict[kTitle];
        
        __weak typeof(self) wself = self;
        
        __weak IWPPopverViewItem * wItem = item;
        item.handlerSelected = ^(NSInteger index, NSString *action) {
            
            if ([wself respondsToSelector:NSSelectorFromString(action)]) {
                [wself performSelector:NSSelectorFromString(action) withObject:wItem afterDelay:0];
            }
        };
        
        item.handler = ^(NSInteger index, NSString * action) {
                        
            if ([wself respondsToSelector:NSSelectorFromString(action)]) {
                [wself performSelector:NSSelectorFromString(action) withObject:[NSNumber numberWithInteger:index] afterDelay:0];
            }
        };
        
        [items addObject:item];
    }
    return items;
}

//zzc 2021-05-11 下拉菜单代理
-(void)menuView:(MLMenuView *)menu didselectItemIndex:(NSInteger)index{
    
    NSArray * items = [self createItems];
    IWPPopverViewItem * item = items[index];
    item.handlerSelected(index, item.action);
}

//zzc 2021-05-11 下拉菜单名称点击方法
- (void)ZZC_EquipmentName:(id)obj {
    _placeHolder.text = [NSString stringWithFormat:@"请输入%@进行搜索",@"设备名称"];
    [_leftDropBtn setTitle:@"设备名称" forState:UIControlStateNormal];

}

//zzc 2021-05-11 下拉菜单编码点击方法
- (void)ZZC_EquipmentCode:(id)obj {
    _placeHolder.text = [NSString stringWithFormat:@"请输入%@进行搜索",@"设备编码"];
    [_leftDropBtn setTitle:@"设备编码" forState:UIControlStateNormal];

}


@end
