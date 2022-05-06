//
//  Inc_NewMB_ListVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/10.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//


#import "Inc_NewMB_ListVC.h"
#import "Inc_NewMB_DetailVC.h"

// 机房等定位界面
#import "Inc_NewMB_AssistLocationVC.h"


// View ***
#import "Inc_NewMB_ListCell.h"
#import "Inc_ConditionSearchView.h"


// 业务 ***
#import "MJRefresh.h"
#import "Inc_NewMB_HttpModel.h"

@interface Inc_NewMB_ListVC ()
<
    UITextFieldDelegate ,
    UITableViewDelegate ,
    UITableViewDataSource ,
    Yuan_NewMB_DetailDelegate       //刷新
>

/** tableView */
@property (nonatomic , strong) UITableView * tableView;

/** 新增按钮 */
@property (nonatomic , strong) UIButton * addNewResourceBtn;

/** 条件搜索 */
@property (nonatomic , strong) Inc_ConditionSearchView * conditionSearchView;

@end

@implementation Inc_NewMB_ListVC

{
    
    Inc_NewMB_VM * _VM;
    Yuan_NewMB_ModelEnum_ _modelEnum;
    Inc_NewMB_HttpPort * _httpPortModel;
    
    UITextField * _searchNameTextField;
    UILabel * _placeHolder;
    
    
    // 汉字标题
    NSString * _showName;
    
    
    // 搜索框内的文字
    NSString * _searchMsg;
    // 分页
    NSInteger _page ;
    
    // 是否是上拉加载更多
    BOOL _isLoadMore;
    
    // 数据源
    NSArray * _dataSource;

    
    // 是否是条件搜索模式
    BOOL _isConditionSearchMode;
    
    // 条件搜索的resLogicName
    NSString * _conditionResLogicName;
    
    NSMutableArray <UIButton *> * _bottomBtnsArr;
}



#pragma mark - 初始化构造方法

- (instancetype)initWithModelEnum:(Yuan_NewMB_ModelEnum_) modelEnum {
    
    if (self = [super init]) {
        
        _modelEnum = modelEnum;
        _VM = Inc_NewMB_VM.viewModel;
        _httpPortModel = [Inc_NewMB_HttpPort ModelEnum:modelEnum];
        _bottomBtnsArr = NSMutableArray.array;
        
        _searchMsg = @"";
        _page = 1;
    }
    return self;
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self UI_Init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(table_HeaderClick) name:@"copyComBoxSuccessful" object:nil];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 配置 条件搜索
    [self conditionView_UI];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}



- (void) UI_Init {
    
    self.title = @"资源列表";
    
    _searchNameTextField = [UIView textFieldFrame:CGRectNull];
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
    

    [_searchNameTextField YuanToSuper_Top:NaviBarHeight + 5];
    [_searchNameTextField YuanToSuper_Left:Horizontal(15)];
    [_searchNameTextField YuanToSuper_Right:Horizontal(15)];
    [_searchNameTextField Yuan_EdgeHeight:Vertical(40)];
    
        
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

    
    _addNewResourceBtn = [UIView button_V2_Title:@"新 增"
                                       responder:self
                                             SEL:@selector(addClick)
                                           frame:CGRectNull];
    
    // 将新增按钮也加入进去
    [_bottomBtnsArr addObject:_addNewResourceBtn];
    
    // 页面底部的按钮 根据类型不同 进行配置
    [self BottomButtonsConfig];
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[Inc_NewMB_ListCell class]
                       CellReuseIdentifier:@"Yuan_NewMB_ListCell"];
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self table_HeaderClick];
    }];
    
    _tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        [self table_FooterClick];
    }];
    
    [self.view addSubviews:@[_tableView]];
    
    float limit = Horizontal(15);
    
    [_tableView YuanMyEdge:Top ToViewEdge:Bottom ToView:_searchNameTextField inset:5];
    [_tableView YuanToSuper_Left:0];
    [_tableView YuanToSuper_Right:0];
    [_tableView YuanToSuper_Bottom:Bottom + Vertical(60)];
    
    
    
    // 证明他没有新增权限时
    if (![self powerCheck]) {
        [_bottomBtnsArr removeObject:_addNewResourceBtn];
    }
    
    
    for (int i = 0; i < _bottomBtnsArr.count; i++) {
        
        UIButton * btn = _bottomBtnsArr[i];
        
        [self.view addSubview:btn];
        
        // 按钮宽度 + 右侧间隔距离
        float btnWidth = (ScreenWidth - limit) / _bottomBtnsArr.count;
        
        [btn YuanToSuper_Left:limit + btnWidth * i];
        [btn YuanToSuper_Bottom:BottomZero + 5];
        [btn autoSetDimension:ALDimensionHeight toSize:Vertical(45)];
        [btn Yuan_EdgeSize:CGSizeMake(btnWidth - limit, Vertical(45))];
    }
    
    
//    [_addNewResourceBtn YuanToSuper_Left:limit];
//    [_addNewResourceBtn YuanToSuper_Right:limit];
//    [_addNewResourceBtn YuanToSuper_Bottom:BottomZero + 5];
//    [_addNewResourceBtn autoSetDimension:ALDimensionHeight toSize:Vertical(45)];
    
}

- (void) conditionView_UI {
    
    // 配置 条件搜索的View
    NSArray * conditionSearch_Json = LoadJSONFile(@"ConditionSearch2");
    
    if (conditionSearch_Json.count > 0) {
        
        for (NSDictionary * singleMap in conditionSearch_Json) {
            
            NSString * resLogicName = singleMap[@"resLogicName"];
            
            if ([_httpPortModel.type isEqualToString:resLogicName]) {
                
                _searchNameTextField.hidden = YES;
                [self naviBar_Condition];
                
                // 进入条件搜索模式
                _isConditionSearchMode = YES;
                
                NSString * resChineseName = singleMap[@"resChineseName"];
                self.title = resChineseName;
                
                _conditionResLogicName = resLogicName;
                
                break;
            }
            
        }
        
    }
    
}



- (void) BottomButtonsConfig {
    
    // 如果是机房
    if (_modelEnum == Yuan_NewMB_ModelEnum_room) {
        
        UIButton * locationBtn = [UIView button_V2_Title:@"定位"
                                               responder:self
                                                     SEL:@selector(locationClick)
                                                   frame:CGRectNull];
        
        [_bottomBtnsArr addObject:locationBtn];
    }
    
}



#pragma mark - http  ---

/// 搜索  , 允许附带搜索条件
- (void) http_Select: (NSDictionary *) conditionMap {
    
    _searchMsg = _searchNameTextField.text;
    
    NSMutableDictionary * postDic;
    
    NSDictionary * selectParam = @{
        
        @"pageSize" : @"100",
        @"pageNum" : [Yuan_Foundation fromInteger:_page],
        @"resName" : _searchMsg,
        @"name" : _searchMsg
    };
    
    postDic = [NSMutableDictionary dictionaryWithDictionary:selectParam];
    
    if (_belongDeviceId && _belongResTypeId) {
        postDic[@"positId"] = _belongDeviceId;
        postDic[@"positTypeId"] = _belongResTypeId;
    }
    
    
    
    // 通用资源 type 和 code  , (分光器与端子 没有!)
    if (_httpPortModel.type) {
        postDic[@"type"] = _httpPortModel.type;
    }
    
    if (_httpPortModel.code) {
        postDic[@"code"] = _httpPortModel.code;
    }
    
    
    // 如果有需要注入的字段 则加入到请求中
    if (_selectDict) {
        [postDic setValuesForKeysWithDictionary:_selectDict];
    }
    
    // 如果有其他附加条件 则加入到请求中
    if (conditionMap) {
        [postDic setValuesForKeysWithDictionary:conditionMap];
    }
    
    
    
    [Inc_NewMB_HttpModel HTTP_NewMB_SelectWithURL:_httpPortModel.Select
                                              Dict:postDic
                                           success:^(id  _Nonnull result) {
            
        [self.view endEditing:YES];
        NSArray * resultArr = result;
        
        if (resultArr && ![resultArr obj_IsNull]) {
            
            if (resultArr.count == 0) {
                [YuanHUD HUDFullText:@"暂无数据"];
            }
            
            if (_isLoadMore) {
                NSMutableArray * array = [NSMutableArray array];
                [array addObjectsFromArray:_dataSource];
                [array addObjectsFromArray:resultArr];
                
                _dataSource = array;
                
                _isLoadMore = NO;
            }
            else {
                _dataSource = resultArr;
            }
            
            [_tableView reloadData];
            
            
        }
        
        
        // 上拉加载结束
        [_tableView.mj_footer endRefreshingWithNoMoreData];

    }];
    
}

#pragma mark - 上下拉 ---
// 刷新
- (void) table_HeaderClick {
    
    _page = 1;
    [self http_Select: nil];
}


// 加载更多
- (void) table_FooterClick {

    _page ++;
    _isLoadMore = YES;
    [self http_Select: nil];
}



#pragma mark - 点击事件 ---

- (void) addClick {
    
    
    
    
    NSMutableDictionary * addDict = NSMutableDictionary.dictionary;

    Inc_NewMB_DetailVC * detail = [[Inc_NewMB_DetailVC alloc] initWithDict:addDict
                                                        Yuan_NewMB_ModelEnum:_modelEnum];
    
    detail.delegate = self;
    
    if (_insertDict) {
        detail.insertDict = _insertDict;
    }
    
    Push(self, detail);
    
}


// 机房等 定位按钮
- (void) locationClick {
    
    if (_dataSource.count == 0) {
        
        [YuanHUD HUDFullText:@"暂无可定位的资源"];
        return;
    }
    
    
    Inc_NewMB_AssistLocationVC * locationVC =
    [[Inc_NewMB_AssistLocationVC alloc] initWithLocationRes:_dataSource
                                                  modelEnum:Yuan_NewMB_ModelEnum_room];
    
    Push(self, locationVC);
}

#pragma mark - tableView ---

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * cellDict = _dataSource[indexPath.row];
    
    if (!cellDict || [cellDict obj_IsNull]) {
        [YuanHUD HUDFullText:@"数据错误"];
        return;
    }
    
    
    // 新接口
    if ([cellDict.allKeys containsObject:@"gid"] &&
        [cellDict.allKeys containsObject:@"name"]) {
        
        
        NSString * Id = cellDict[@"gid"];
        NSString * type = _httpPortModel.type;
        
        NSDictionary * postDict = @{
            @"id" : Id,
            @"type" : type
        };
        
        [Inc_NewMB_HttpModel HTTP_NewMB_SelectDetailsFromIdWithURL:_httpPortModel.SelectFrom_IdType
                                                               Dict:postDict
                                                            success:^(id  _Nonnull result) {
                    
            NSArray * resultArr = result;
            NSDictionary * dic = resultArr.firstObject;
            
            if (!dic) {
                [YuanHUD HUDFullText:@"未查询到该数据"];
                return;
            }
            
            NSMutableDictionary * Dict = [NSMutableDictionary dictionaryWithDictionary:dic];
          
            
            Inc_NewMB_DetailVC * detail = [[Inc_NewMB_DetailVC alloc] initWithDict:Dict
                                                                Yuan_NewMB_ModelEnum:_modelEnum];
            
            if ([type isEqualToString:@"lightning_protect_equip"] || [type isEqualToString:@"voltage_changer"]) {
                
                detail.modifyDict = @{@"code":@"pwr"};
            }
            
            Push(self, detail);
            
            if (_deleteDict) {
                detail.deleteDict = _deleteDict;
            }
            
            if (_modifyDict) {
                detail.modifyDict = _modifyDict;
            }
            
            
            detail.delegate = self;
            
            detail.listSearchName = _searchMsg;
            
        }];
        
        
    }
    
    
    // 分光器
    else {
        
        Inc_NewMB_DetailVC * detail = [[Inc_NewMB_DetailVC alloc] initWithDict:cellDict
                                                            Yuan_NewMB_ModelEnum:_modelEnum];
        Push(self, detail);
        
        detail.delegate = self;
        
        detail.listSearchName = _searchMsg;
    }
    
    
    
    

}


// 其他代理  ***

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Inc_NewMB_ListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_NewMB_ListCell"];
    
    if (!cell) {
        cell = [[Inc_NewMB_ListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"Yuan_NewMB_ListCell"];
    }
    
    NSDictionary * cellDict = _dataSource[indexPath.row];
    
    cell.myDict = cellDict;
    
    
    NSString * resName ;
    
    if ([cellDict.allKeys containsObject:@"resName"]) {
        resName = cellDict[@"resName"];
    }
    
    else if ([cellDict.allKeys containsObject:@"name"]) {
        
        resName = cellDict[@"name"];
    }
    
    else {
        resName = @"";
    }
    
    
    
    [cell cellImgWithResEnum:_modelEnum cellTitle:resName];
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * cellDict = _dataSource[indexPath.row];

    NSString * resName ;
    
    if ([cellDict.allKeys containsObject:@"resName"]) {
        resName = cellDict[@"resName"];
    }
    
    else if ([cellDict.allKeys containsObject:@"name"]) {
        
        resName = cellDict[@"name"];
    }
    
    else {
        resName = @"";
    }
    
    if (resName.length > 30) {
        return Vertical(75);
    }
    
    if (resName.length > 50) {
        Vertical(100);
    }
    
    
    return Vertical(50);
}




#pragma mark - 搜索事件 ---
// 普通搜索模式
- (void) naviSearchClick {
    
    _page = 1;
    [self http_Select: nil];
    
    [self.view endEditing:YES];
}



/// 条件搜索模式
- (void) naviConditionSearchClick {
    
    if (_conditionSearchView != nil) {
        
        [_conditionSearchView removeFromSuperview];
        _conditionSearchView = nil;
        return;
    }
    
    
    
    _conditionSearchView = [[Inc_ConditionSearchView alloc] initWithFrame:CGRectMake(0, NaviBarHeight, ScreenWidth, ScreenHeight - NaviBarHeight)];
    
    _conditionSearchView.resLogicName = _conditionResLogicName;
    
    [self.view addSubview:_conditionSearchView];
    
    /// 搜索的点击事件
    __typeof(self)weakSelf = self;
    weakSelf->_conditionSearchView.btnBlock = ^(NSDictionary * _Nonnull dic) {
        
        if (dic) {
            
            NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dic];
            mt_Dict[@"resName"] = dic[@"name"];
            
            _page = 1;
            [self http_Select: mt_Dict];
            [self.view endEditing:YES];
            
            [_conditionSearchView removeFromSuperview];
            _conditionSearchView = nil;
        }
    };
    
}



// 执行搜索
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    // 条件搜索模式 不执行普通搜索操作
    if (_isConditionSearchMode) {
        return YES;
    }
    
    _page = 1;
    [self http_Select: nil];
    
    return YES;
}





- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    _placeHolder.hidden = YES;
}


- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    if (_searchNameTextField.text.length == 0) {
        _placeHolder.hidden = NO;
        return;
    }
    
    _placeHolder.hidden = YES;
}



/// 条件搜索naviBar
- (void) naviBar_Condition {
    
    UIBarButtonItem * searchBtn = [UIView getBarButtonItemWithImageName:@"icon_search"
                                                                    Sel:@selector(naviConditionSearchClick)
                                                                     VC:self];
    
    self.navigationItem.rightBarButtonItems = @[searchBtn];
    
}


#pragma mark - Yuan_NewMB_DetailDelegate ---



// 根据模板详情页 , 不同的操作
- (void)reloadSearchName:(NSString *)searchName EnumType:(Yuan_NewMB_Enum_)enumType {
    
    _searchNameTextField.text = _searchMsg = searchName;
    
    _placeHolder.hidden = YES;
    
    [self http_Select: nil];
    
}



#pragma mark - 权限判断 ---

- (BOOL) powerCheck {
    
    // 机房 没有新增
    if (_modelEnum == Yuan_NewMB_ModelEnum_room) {
        return NO;
    }
    
    // 列框 没有新增
    if (_modelEnum == Yuan_NewMB_ModelEnum_shelf) {
        return NO;
    }
    
    // 模块 没有新增
    if (_modelEnum == Yuan_NewMB_ModelEnum_module) {
        return NO;
    }
    
    // 其他资源
    if ([_VM getOldResLogicNameFromEnum:_modelEnum].length > 0) {
        
        if (!Authority_Add([_VM getOldResLogicNameFromEnum:_modelEnum])) {
            return NO;
        }
    }
    
    return YES;
    
}

@end
