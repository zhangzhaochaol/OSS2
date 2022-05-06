//
//  Yuan_New_ODFModelVC.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/28.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_New_ODFModelVC.h"


#import "Yuan_ScrollVC.h"               ///详情 只有彩色盘才能点击进去
#import "Yuan_ODF_InitVC.h"             ///初始化

#import "Yuan_EditNavBtn.h"             /// 编辑按钮
#import "Yuan_Pie.h"                    /// 端子盘样式

#import "Yuan_DoublePieCell.h"          /// 双盘cell
#import "Yuan_SinglePieCell.h"          /// 单盘cell

#import "Yuan_ODFViewModel.h"
#import "Yuan_ODF_HttpModel.h"          /// 专门用于网络请求的类

//查看全部端子
#import "Inc_AllTermVC.h"





typedef NS_ENUM(NSUInteger, EditState) {
    EditState_True = 0,
    EditState_False = 1,
};





@interface Yuan_New_ODFModelVC ()

<UITableViewDelegate , UITableViewDataSource>

/** 背景 */
@property (nonatomic,strong) UIImageView *backGround_img;

/** tableView */
@property (nonatomic,strong) UITableView *tableView;

//zzc 2021-6-16 端子面板添加查看全部端子
@property (nonatomic,strong) UIButton *alltermBtn;


@end

@implementation Yuan_New_ODFModelVC

{
    Yuan_EditNavBtn * _editBtn;
    
    NSString * _name;
    
    NSString * _id;                 // gid
    
    Yuan_Pie * _pie;
    
    EditState _editState;           // 当前是否是编辑状态
    
    NSMutableArray * _dataSource;   //数据源
    
    NSMutableArray * _allData;      // 上限为 16个的数组 , 用来区分正反面两套的array 来自 _requestDataSource
    
    NSMutableArray * _requestDataSource;    // 网络请求回来的数据源 , 个数不定 0-32个之间
 
    
    NSMutableSet <Yuan_Pie *> * _allPiesSet;  // 所有盘的 set , 为了去重 不用array
    
    // ODF 是 "1"  OCC 是 "2"
    //根据构造方法入口不同 , type也不同
    NSString * _postType;
    
    // cell的状态 , 当前显示单盘还是双盘 .
    ODF_TableView_Cell _cellState;
    
    ODF_TableView_Cell _cellStateFaker;  //上一次操作时 , 是单cell 还是双cell
    
    
    BOOL _isFaceInverse ;  // 当前是否是正面  正面 1  反面 0   无也默认为正面 2020.08.28
    
    
    
//    UIBarButtonItem *_fanMian;  // 导航栏右侧按钮 正面反面
    
}


#pragma mark - 初始化构造方法  *** *** *** ***

- (instancetype) initWithType:(InitType)enterType
                          Gid:(NSString *)gid
                         name:(NSString *)name{
    
    if (self = [super init]) {
        
        _id = gid;
        
        _name = name;
        
        _editState = EditState_False ; // 默认是非编辑状态
        
        _allData = [NSMutableArray array];  // 必须 是16个!!! , 用于编辑时切换数据源
        
        _dataSource = [NSMutableArray array]; // 网络请求下来的 有可能是空的哦
        
        _requestDataSource = [NSMutableArray array];
        
        _allPiesSet = [NSMutableSet set];
        
        if (enterType == InitType_ODF) {
            _postType = @"1";
        }else if(enterType == InitType_OCC){
            _postType = @"2";
        }else if (enterType == InitType_ODB) {
            _postType = @"3";
        }
        else if (enterType == InitType_OBD) {
            _postType = @"4";
        }

        [self reloadAllData];
        
        _cellStateFaker = _cellState = ODF_TableView_Cell_None;
        
        _isFaceInverse = YES;  //初始化 正面
        
        // 监听 当端子列表请求 返回info @"统一库没有该资源!" 时的业务处理
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(Http_InfoNotification:)
                                                     name:HttpSuccess_Error_Info_Notification
                                                   object:nil];
        
        // 端子盘信息错误
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(Noti_DuanZiPan_Error)
                                                     name:Noti_DuanZiPan_msg_Error
                                                   object:nil];
        
    }
    return self;
}


/// 重置数据源
- (void) reloadAllData {
        
    [_allData removeAllObjects];

    // 初始化数据源 , 等网络请求后 替换
    for (int i = 0; i < 16; i++) {
        NSDictionary * dict = @{@"position" : [NSString stringWithFormat:@"%d",i+1]};
        
        [_allData addObject:dict];
    }
    
    [_dataSource removeAllObjects];
    
    // 初始化数据源 , 等网络请求后 替换
    for (int i = 0; i < 8; i++) {
        NSDictionary * dict = @{@"position" : [NSString stringWithFormat:@"%d",i+1]};
        
        [_dataSource addObject:dict];
    }
    
}







#pragma mark - viewDidLoad  *** *** *** ***

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = ColorValue_RGB(0xf2f2f2);
    
    [self.view addSubview:self.backGround_img];
    
    [_backGround_img addSubview:self.tableView];
    
    //查看全部端子
    [self.view addSubview:self.alltermBtn];

    
    [self layoutAllSubViews];
    
    self.title = @"正面";
    
    [self naviSet];
    
    [self http_post];
    
    [_tableView reloadData];
    
    
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // 资源操作
    Http.shareInstance.statisticEnum = HttpStatistic_Resource;
}

#pragma mark - HTTP *** *** ***



/// 英子新的模块创建接口  2022-4-18

- (void) http_NewInitPieDict:(NSDictionary *) dictionary
                      sender:(Yuan_Pie *) sender {
    
    
    [Yuan_ODF_HttpModel ODF_HttpNewInitModuleWithDict:dictionary
                                              success:^(id result) {
        
        _editState = EditState_False;
        [_editBtn setTxt:@"编辑"];
        [self quitEdit];
        
        [self http_post];
    }];
    
    
}




/// 龙哥老的模块创建接口
- (void) http_InitPieDict:(NSDictionary *) dictionary
                   sender:(Yuan_Pie *)sender{
    
    ///MARK:  初始化端子盘的  网络请求 --- --- --- --- ---
    
    [Yuan_ODF_HttpModel ODF_HttpInitDict:dictionary
                            successBlock:^(id  _Nonnull requestData) {
       
        // 成功后 返回一个 dictionary
        
        // 遍历 _requestDataSource 这个数组 , 他是网络请求列表返回的数组
        
        // 替换 那个 position 相同  并且faceInverse 相同的值
        
        NSDictionary * req = [requestData firstObject];
        
        [_requestDataSource addObject:req];  // 把这个新的 拼接到 已有的全部请求数据中
        
        // 替换 alldata 里的position 相同的dict
        [_allData enumerateObjectsUsingBlock:^(id  _Nonnull obj,
                                                         NSUInteger idx,
                                                         BOOL * _Nonnull stop) {

            // obj 都是 map
            NSDictionary * dict = obj;

            BOOL isPosition = [dict[@"position"] isEqualToString:req[@"position"]];
            
            
            if (isPosition) {
                // 证明该map 需要被替换
                [_allData replaceObjectAtIndex:idx withObject:req];
                sender.dict = req;  //给 按钮的 dict 重新赋值  很重要
            }

        }];

        
        // 重置UI
        [sender changePieState:PieState_Colorful];
        [sender changeEditState:YES isFaceInverse:_isFaceInverse];

        [[Yuan_HUD shareInstance] HUDFullText:@"保存成功"];
        
        
    }];
    
}


/// MARK: 列表的请求 --- --- --- --- ---
- (void) http_post {
    
    
    [Yuan_ODF_HttpModel ODF_HttpGetLimitDataWithID:_id
                                          InitType:_postType
                                      successBlock:^(id  _Nonnull requestData) {
        
        NSArray * resultArray = requestData;
        
        _requestDataSource = [NSMutableArray arrayWithArray:resultArray];
        
        if (resultArray.count == 0) {
            [[Yuan_HUD shareInstance] HUDFullText:@"暂无数据"];
            return ;
        }
        
        [self allDataConfig:resultArray];
        [self dataSourceConfig];
        
        [_tableView reloadData];
        
    }];
    
}



/// 正反面切换时 同时切换数据源
- (void) reChangeUIDataSource {
    
    [self reloadAllData];   //初始化 _allData 和 _dataSource
    
    [self allDataConfig:_requestDataSource];
    
    [self dataSourceConfig];
    
    [_tableView reloadData];
}







#pragma mark - 请求回调 业务处理 **** **** **** ****

// _allData
- (void) allDataConfig:(NSArray *)resultArray {
    
    for (NSDictionary * dict in resultArray) {
        
        if (dict && dict.allKeys.count > 0) {
             
            
            int position = [dict[@"position"] intValue];
            
            if (position > 16 || position == 0) {
                continue;
            }
            
            if (_isFaceInverse) {
                // 当前是正面 那么 allData 只需要正面
                if ([dict[@"faceInverse"] isEqualToString:@"1"] ||
                    [dict[@"faceInverse"] isEqualToString:@"3"]) {
                    
                    // 2020.08.28 更新 -- 出现了三种情况 正面/反面/无
                    // 无默认为正面

                    
                    // 因为position 是从1 开始的 ,数组是从0开始的 所以 position - 1
                    [_allData replaceObjectAtIndex:position - 1 withObject:dict];
                }
            }else {
                // 当前是反面
                if ([dict[@"faceInverse"] isEqualToString:@"2"]) {
                    // 因为position 是从1 开始的 ,数组是从0开始的 所以 position - 1
                    [_allData replaceObjectAtIndex:position - 1 withObject:dict];
                }
            }
        }
    }
}


// _dataSource
- (void) dataSourceConfig {
    
    // 判断当前应该显示 单盘cell 还是双盘cell
    _cellStateFaker = _cellState =  [Yuan_ODFViewModel viewModelCellStateWithDataSource:_allData];
    
    if (_cellState == ODF_TableView_Cell_Dan_Before) {
        
        // 单时  获取cell的数据源 取前半段
        _dataSource = [[_allData subarrayWithRange:NSMakeRange(0, 8)] mutableCopy];
    }
    
    if (_cellState == ODF_TableView_Cell_Dan_After) {
        // 单时  获取cell的数据源 取后半段
        _dataSource = [[_allData subarrayWithRange:NSMakeRange(8, 8)] mutableCopy];
    }
    
}






#pragma mark - UITableViewDataSource **** **** ***** ****


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return Vertical(65);
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    
    // 不需要做任何判断 都固定显示8行cell
    return 8;
}



// 单列 数据源 使用 datasource 双列数据源 使用 alldatas
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    /// 单盘 cell
    if (_cellState == ODF_TableView_Cell_Dan_Before ||
        _cellState == ODF_TableView_Cell_Dan_After ) {
        
        // 单 列
        Yuan_SinglePieCell * cell =
        [tableView dequeueReusableCellWithIdentifier:@"Yuan_SinglePieCell"];
        
        if (!cell) {
            cell = [[Yuan_SinglePieCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:@"Yuan_SinglePieCell"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self pieClicks_Config:cell.Pie_A];
        [_allPiesSet addObject:cell.Pie_A];
        
        // 此时 datasource 已经是处理过的数据了
        [cell A_Dict:[_dataSource objectAtIndex:indexPath.row] isFaceInverse:_isFaceInverse];
        
        
        return cell;
    }
    
    
    /// 双盘 cell
    if (_cellState == ODF_TableView_Cell_Shuang ) {
        
        // 双列 cell
        Yuan_DoublePieCell * cell =
        [tableView dequeueReusableCellWithIdentifier:@"Yuan_DoublePieCell"];
        
        if (!cell) {
            cell = [[Yuan_DoublePieCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:@"Yuan_DoublePieCell"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self pieClicks_Config:cell.Pie_A];
        [_allPiesSet addObject:cell.Pie_A];
        
        [self pieClicks_Config:cell.Pie_B];
        [_allPiesSet addObject:cell.Pie_B];
        
        
        // 双盘状态 直接用 _allData 而不是使用 _dataSource
        [cell A_Dict:[_allData objectAtIndex:indexPath.row]
       isFaceInverse:_isFaceInverse];
        
        [cell B_Dict:[_allData objectAtIndex:indexPath.row + 8]
       isFaceInverse:_isFaceInverse];
        
        return cell;
    }
    
    
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    return cell;
}




#pragma mark - 盘的点击事件 *** *** ***

- (void) pieClicks_Config:(Yuan_Pie *)pie {
    
    [pie addTarget:self
            action:@selector(PieClick:)
  forControlEvents:UIControlEventTouchUpInside];
    

    [pie.guanBi_Btn addTarget:self
                       action:@selector(pie_GuanBiClick:)
             forControlEvents:UIControlEventTouchUpInside];
    
}



/// MARK: 跳转 --- --- --- ---
/// 端子盘 盘面 点击事件
- (void)PieClick:(Yuan_Pie *)sender {
    
    PieState state = [sender getNowPieState];
    
    if (state == PieState_Colorful) {   //已初始化的端子盘 跳转
        
        // 点击后进入 另一个界面
        
        if (_editState == EditState_False) {
            
            Yuan_ScrollVC * scroll = [[Yuan_ScrollVC alloc] initWithDict:sender.dict];
            Push(self, scroll);
            scroll.mb_Dict = _mb_Dict;
        }else {
            [[Yuan_HUD shareInstance] HUDFullText:@"结束编辑后可查看端子详情"];
        }
        
        
    }else {  //未初始化的端子盘 去初始化
        
        // 如果是暗色的 调取初始化界面  估计要传 index 看后台情况
        Yuan_ODF_InitVC * init_ODF =
        [[Yuan_ODF_InitVC alloc] initWithNum:sender.index
                                 faceInverse:_isFaceInverse
                                        name:_name];
        
        init_ODF.modalPresentationStyle = UIModalPresentationPopover;
        init_ODF.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        init_ODF.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
        [self presentViewController:init_ODF animated:NO completion:^{
        // 根据 colorWithAlphaComponent:设置透明度，如果直接使用alpha属性设置，会出现Vc里面的子视图也透明.
            init_ODF.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

        }];
        
        /// 初始化按钮的点击事件
        init_ODF.saveBtnBlock = ^(NSDictionary * _Nonnull dict) {
            
            // 获得了 dict 回调 , 去上传
            
            NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
            dictionary[@"eqpId_Type"] = _postType;
            dictionary[@"eqpId_Id"] = _id;
        
    
            // 初始化端子盘的网络请求
//            [self http_InitPieDict:dictionary sender:sender];
            [self http_NewInitPieDict:dictionary sender:sender];
    
        };
        
    }
    
}


/// 端子盘 侧面关闭按钮的点击事件
- (void)pie_GuanBiClick:(UIButton *)sender {
    
    
    [UIAlert alertSmallTitle:@"是否删除该端子盘?" agreeBtnBlock:^(UIAlertAction *action) {
            
        [self delete_pie:sender];
    }];
    
}

/// 执行删除操作
- (void) delete_pie:(UIButton *)sender {
    
    Yuan_Pie * sender_pie = (Yuan_Pie *)sender.superview;
    
    NSString * position = [Yuan_Foundation fromInteger:sender_pie.index];
    
    NSDictionary * dict = sender_pie.dict;
    
    // 如果删除时 没有替换之前的map 会崩溃的
    NSDictionary * postDict = @{@"GID":dict[@"GID"],
                                @"resLogicName":dict[@"resLogicName"]};
    /// MARK: 删除端子盘的请求 --- --- --- --- ---
    [Yuan_ODF_HttpModel ODF_HttpDeleteDict:postDict
                              successBlock:^(id  _Nonnull requestData) {
       
        
        
        // 移除 _requestDataSource 里的 相同数据
        
        [_allData enumerateObjectsUsingBlock:^(id  _Nonnull obj,
                                                         NSUInteger idx,
                                                         BOOL * _Nonnull stop) {

            // obj 都是 map
            NSDictionary * dict = obj;

            BOOL isPosition = [dict[@"position"] isEqualToString:position];
            
            
            if (isPosition) {
                // 证明该map 需要被替换
                [_allData replaceObjectAtIndex:idx
                                    withObject:@{@"position":position}];
                
                
            }

        }];
        
        
        // 倒序 遍历删除 否则 重复字段删不干净  比如 position == 1 时
        [_requestDataSource enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // obj 都是 map
            NSDictionary * dict = obj;

            BOOL isPosition = [dict[@"position"] isEqualToString:position];
            //faceInverse 1正 2 反   _isFaceInverse yes 正 No 反
            if (isPosition) {
                
                // 这个判断 是用来确认删除端子时 ,当前是正面还是反面 .
                // 以防止误删除另一面的 相同端子信息
                if ((_isFaceInverse && [dict[@"faceInverse"] isEqualToString:@"1"]) ||
                    (!_isFaceInverse && [dict[@"faceInverse"] isEqualToString:@"2"])) {
                    // 证明该map 需要被替换
                    [_requestDataSource removeObject:obj];
                }
                
            }
            
        }];
        
        
        // 切换 按钮状态
        [sender_pie changePieState:PieState_Normal_Gray];
        [sender_pie changeEditState:YES isFaceInverse:_isFaceInverse];
        [[Yuan_HUD shareInstance] HUDFullText:@"成功删除端子盘"];
    }];
    
}



#pragma mark - Http_InfoNotification 通知监听
/// TODO: 询问龙哥 , '统一库没有该资源'时 是否直接返回 , 因为在此状态下 创建的端子模块 , 进入后没有保存按钮.

- (void) Http_InfoNotification:(NSNotification *) noti_Dict {
    
    NSDictionary * dict = noti_Dict.userInfo;
    
    if ([dict[@"info"] isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString * info = dict[@"info"];
    
    if (info && [info rangeOfString:@"统一库没有该资源"].location != NSNotFound) {
        // 当有info 并且info包含子字符串 '统一库没有该资源' 时
        
        // 如果 统一库没有该资源 , 则 强行初始化
        
        [self allDataConfig:@[]];
        [self dataSourceConfig];
        
        [_tableView reloadData];
        
    }
    
    
}



/// 如果端子盘信息错误 , 回退到上一界面
- (void) Noti_DuanZiPan_Error {
    
    [self.navigationController popViewControllerAnimated:YES];
}











#pragma mark - 懒加载 *** *** *** ***

- (UIImageView *)backGround_img {
    
    if (!_backGround_img) {
        _backGround_img = [[UIImageView alloc] initWithFrame:CGRectMake(0, NaviBarHeight, ScreenWidth, ScreenHeight - NaviBarHeight)];
        _backGround_img.image = [UIImage Inc_imageNamed:@"equ_model_bg"];
        _backGround_img.userInteractionEnabled = YES;
    }
    return _backGround_img;
}

- (UIButton *)alltermBtn {
    if (!_alltermBtn) {
        _alltermBtn = [UIView buttonWithImage:@"zzc_allTerm" responder:self SEL_Click:@selector(alltermClick) frame:CGRectNull];
        [_alltermBtn setAdjustsImageWhenDisabled:NO];
    }
    return _alltermBtn;
}


- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [UIView tableViewDelegate:self
                                 registerClass:[UITableViewCell class]
                           CellReuseIdentifier:@"ID"];
        
        [_tableView registerClass:[Yuan_DoublePieCell class] forCellReuseIdentifier:@"Yuan_DoublePieCell"];
        
        [_tableView registerClass:[Yuan_SinglePieCell class] forCellReuseIdentifier:@"Yuan_SinglePieCell"];
        
        _tableView.scrollEnabled = NO;
        
        _tableView.userInteractionEnabled = YES;
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.backgroundColor = [UIColor clearColor];
        
    }
    return _tableView;
}


#pragma mark - 导航栏配置

/// 导航栏设置
- (void) naviSet {
    
    
    UIBarButtonItem * fanMian = [UIView getBarButtonItemWithTitleStr:@"反面" Sel:@selector(fanMianClick:) VC:self];
    self.navigationItem.rightBarButtonItems = @[fanMian];
    
    
    UIBarButtonItem * back =
    [UIView getBarButtonItemWithImageName:@"icon_fanhui"
                                      Sel:@selector(backClick) VC:self];
    
    _editBtn = [[Yuan_EditNavBtn alloc] initWithFrame:CGRectMake(0, 0, Horizontal(60), Vertical(35))];

    // 编辑按钮 点击事件
    UIBarButtonItem * edit =
    [UIView getBarButtonItemWithView:_editBtn
                                 Sel:@selector(editClick:) VC:self];
    
    
    self.navigationItem.leftBarButtonItems = @[back,edit];
    
    
    
}



#pragma mark - 导航栏上按钮的点击事件 **** **** **** ****


- (void) fanMianClick:(UIButton *)sender {

    
    if (_editState == EditState_True) {
        // 如果当前就是编辑状态 , 禁止他切换正反面
        [[Yuan_HUD shareInstance] HUDFullText:@"请不要在编辑状态切换正反面"];
        
        return;
    }
    
    _isFaceInverse = !_isFaceInverse;
    
    // 修改导航栏文字 以及 导航栏按钮文字
    if ([sender.titleLabel.text isEqualToString:@"反面"]) {
        [sender setTitle:@"正面" forState:UIControlStateNormal];
        self.title = @"反面";
    }else {
        [sender setTitle:@"反面" forState:UIControlStateNormal];
        self.title = @"正面";
    }
    
    // 正反面
    [self reChangeUIDataSource];
    
}



///编辑
- (void) editClick:(Yuan_EditNavBtn *)sender {
    
    
    if (_editState == EditState_False) {         // 点击后 进入编辑状态
        
        _editState = EditState_True;
        [sender setTxt:@"结束编辑"];
        // 进入编辑模式的逻辑判断 , 包括单组 转双组的判断
        [self enterEdit];
        
        
        
    }else {                                    // 点击后 退出编辑状态
        
        _editState = EditState_False;
        
        [sender setTxt:@"编辑"];
        
        // 退出编辑模式的判断 , 包括 双组转会单组
        [self quitEdit];
        
        [self reChangeUIDataSource];  //结束编辑时  重新初始化数据源
        
    }
    
    
    
}




// 单转双 或 双转双   进入编辑模式 ***
- (void) enterEdit {
    
    if (_cellState == ODF_TableView_Cell_Dan_Before ||
        _cellState == ODF_TableView_Cell_Dan_After) {
        // 当这两个状态下 进入编辑模式
        // 需要由单变双
        
        _cellState = ODF_TableView_Cell_Shuang;
        [_tableView reloadData];
        
        [[Yuan_HUD shareInstance] HUDStartText:@""];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (Yuan_Pie *pie in _allPiesSet) {
                [pie changeEditState:YES isFaceInverse:_isFaceInverse];
            }
            [[Yuan_HUD shareInstance] HUDHide];
        });
        
    }else {
        
        for (Yuan_Pie *pie in _allPiesSet) {
            [pie changeEditState:YES isFaceInverse:_isFaceInverse];
        }
        
    }
    
    
    
}


// 双转单 或 双转双   解除编辑模式 ***
- (void) quitEdit {
    
    
    
    if (_cellStateFaker == ODF_TableView_Cell_Dan_Before ||
    _cellStateFaker == ODF_TableView_Cell_Dan_After) {
        
        // 由双 变回单
        _cellState = _cellStateFaker;
        [_tableView reloadData];  //这个 reloadData是必须的 , 并不是要刷新数据 , 而是要刷新UI
        
        [[Yuan_HUD shareInstance] HUDStartText:@""];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (Yuan_Pie *pie in _allPiesSet) {
                [pie changeEditState:NO isFaceInverse:_isFaceInverse];
            }
            [[Yuan_HUD shareInstance] HUDHide];
        });
    } else {
        
        for (Yuan_Pie *pie in _allPiesSet) {
            [pie changeEditState:NO isFaceInverse:_isFaceInverse];
        }
    }
    
}



///返回
- (void) backClick {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

//查看全部端子
- (void)alltermClick {
    NSLog(@"");
    if (_requestDataSource.count == 0) {
        [YuanHUD HUDFullText:@"没有可查看端子"];
        return;
    }
    Inc_AllTermVC *vc = [Inc_AllTermVC new];
    vc.type = _postType;
    vc.deviceId = _id;
    vc.requestDataSource = _requestDataSource;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:Vertical(22 + 10)];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(46)];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(46)];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:Vertical(22 + 10)];
        

    
    [_alltermBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:Vertical(42)];
    [_alltermBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];

    
}


- (void)dealloc {
    
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
