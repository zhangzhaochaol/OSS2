//
//  Yuan_NewFL_SearchListVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_SearchListVC.h"
#import "Yuan_NewFL_SearchListCell.h"

#import "Yuan_NewFL_SearchHeaderView.h"     //搜索头视图
#import "Inc_NewFL_SearchHeadView.h"  //新版 只经过设备查询

// Http请求
#import "Yuan_NewFL_HttpModel.h"
#import "Inc_Push_MB.h"

#import "Yuan_NewFL_VM.h"

typedef NS_ENUM(NSUInteger , SearchList_) {
    
    SearchList_Detail,      //光路和局向的入口列表
    SearchList_Add,         //光链路新增时
};

@interface Yuan_NewFL_SearchListVC () <UITableViewDelegate , UITableViewDataSource>

/** <#注释#> */
@property (nonatomic , strong) UITableView * tableView;

/** <#注释#> */
@property (nonatomic , strong) Yuan_NewFL_SearchHeaderView * header;

/** 注释 */
@property (nonatomic , strong) Inc_NewFL_SearchHeadView * headerNew;

/** 搜索 */
@property (nonatomic , strong) UIButton * addBtn;

@end

@implementation Yuan_NewFL_SearchListVC

{
    NSLayoutConstraint * _headerConstraint;
    //更新高度
    NSLayoutConstraint * _headerConstraintNew;

    
    NewFL_EnterType_ _enterType;
    
    // 当前显示的是A还是Z
    BOOL _nowSelect_AOrZ;
    
    NSDictionary * _dictA;
    NSDictionary * _dictZ;

    //经过设备dic
    NSDictionary * _dictP;

    
    NSArray * _dataSource;
    NSString * _resLogicName;
    
    NSDictionary * _rulerDict;
    
    /** 点击回调的block  block */
    void (^_myBlock) (id data);
    
    // 用来添加局向光纤的数组
    NSMutableArray * _addArray;
    
    // 是外部列表 还是内部新增搜索时使用
    SearchList_ _searchListEnum;
    
    
    Yuan_NewFL_VM * _VM;
    
}


#pragma mark - 初始化构造方法

// 有搜索框 跳转模板
- (instancetype)initWithEnterType:(NewFL_EnterType_)enterType {
    
    if (self = [super init]) {
        _enterType = enterType;
        _searchListEnum = SearchList_Detail;
    }
    return self;
}



// 有搜索框 回调  当链路里没有任何数据的时候 走这个方法
- (instancetype)initWithEnterType:(NewFL_EnterType_)enterType
                      selectBlock:(void(^)(id data))block {
    if (self = [super init]) {
        
        _enterType = enterType;
        _myBlock = block;
        _searchListEnum = SearchList_Add;
        
        _VM = Yuan_NewFL_VM.shareInstance;
    }
    return self;
}



// 无搜索框 回调 当链路里有数据时 , 走这个方法
- (instancetype)initWithEnterType:(NewFL_EnterType_)enterType
                             dict:(NSDictionary *)rulerDict
                      selectBlock:(void(^)(id data))block{
    
    
    if (self = [super init]) {
        
        _enterType = enterType;
        _rulerDict = rulerDict;
        _myBlock = block;
        _searchListEnum = SearchList_Add;
        _VM = Yuan_NewFL_VM.shareInstance;
    }
    return self;
}





- (void)viewDidLoad {
    [super viewDidLoad];

    if (_enterType == NewFL_EnterType_Link) {
        self.title = @"光路列表";
        _resLogicName = @"opticalPath";
    }
    else {
        self.title = @"局向光纤列表";
        _resLogicName = @"optLogicPair";
    }
    
    
    [self UI_Init];
    
    
    // 只有光路有新增按钮
    if (!_myBlock && _enterType == NewFL_EnterType_Link) {
        [self block_InitNew];
    }else{
        [self block_Init];

    }

    
    if (_rulerDict) {
        
        NSDictionary * dict = @{@"GID":_rulerDict[@"beginResId"]};
        
        // beginResId endResId name
        [self httpPort_SelectName:nil
                     deviceA_Dict:dict
                     deviceZ_Dict:nil];
    }
    
}



- (void) UI_Init {
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[Yuan_NewFL_SearchListCell class]
                       CellReuseIdentifier:@"Yuan_NewFL_SearchListCell"];

    _addBtn = [UIView button_V2_Title:@"新增"
                            responder:self
                                  SEL:@selector(addNew)
                                frame:CGRectNull];
    
    
    // 光路使用经过设备UI
    if (_enterType == NewFL_EnterType_Link) {
        
        _headerNew = Inc_NewFL_SearchHeadView.alloc.init;
        [_headerNew cornerRadius:5 borderWidth:1 borderColor:ColorValue_RGB(0xf2f2f2)];
        [_headerNew hide];
        
        [self.view addSubviews:@[_tableView,_headerNew,_addBtn]];
        [self yuan_LayoutSubViewsNew];
    }else {
        
        
        _header = Yuan_NewFL_SearchHeaderView.alloc.init;
        [_header cornerRadius:5 borderWidth:1 borderColor:ColorValue_RGB(0xf2f2f2)];
        [_header hide];

        
        [self.view addSubviews:@[_tableView,_header,_addBtn]];
        [self yuan_LayoutSubViews];
    }
    
   
    
    if (([[UserModel.powersTYKDic[_resLogicName] substringToIndex:1] integerValue] == 0)) {
        
        _addBtn.hidden = YES;
    }
    
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_header YuanToSuper_Top:NaviBarHeight + limit];
    [_header YuanToSuper_Left:limit];
    [_header YuanToSuper_Right:limit];
    
    if (!_rulerDict) {
        _headerConstraint = [_header autoSetDimension:ALDimensionHeight toSize:Vertical(50)];
    }
    else {
        _headerConstraint = [_header autoSetDimension:ALDimensionHeight toSize:Vertical(0)];
    }
    
    
    
    [_tableView YuanMyEdge:Top ToViewEdge:Bottom ToView:_header inset:limit];
    [_tableView YuanToSuper_Left:0];
    [_tableView YuanToSuper_Right:0];
    [_tableView YuanToSuper_Bottom:Vertical(70)];
    
    [_addBtn YuanToSuper_Left:limit];
    [_addBtn YuanToSuper_Right:limit];
    [_addBtn YuanToSuper_Bottom:BottomZero + 5];
    [_addBtn Yuan_EdgeHeight:Vertical(40)];
    
}



- (void) yuan_LayoutSubViewsNew {
    
    float limit = Horizontal(15);
    
    [_headerNew YuanToSuper_Top:NaviBarHeight + limit];
    [_headerNew YuanToSuper_Left:limit];
    [_headerNew YuanToSuper_Right:limit];
    
    if (!_rulerDict) {
        _headerConstraintNew = [_headerNew autoSetDimension:ALDimensionHeight toSize:Vertical(50)];
    }
    else {
        _headerConstraintNew = [_headerNew autoSetDimension:ALDimensionHeight toSize:Vertical(0)];
    }
    
    
    
    [_tableView YuanMyEdge:Top ToViewEdge:Bottom ToView:_headerNew inset:limit];
    [_tableView YuanToSuper_Left:0];
    [_tableView YuanToSuper_Right:0];
    [_tableView YuanToSuper_Bottom:BottomZero];
}


- (void) block_Init {
    
    __typeof(self)weakSelf = self;
    
    _header.headerBlock = ^(HeaderBtnClick_ click) {
        
        
        switch (click) {
                // 显示与隐藏
            case HeaderBtnClick_Show:
                [weakSelf headerShow_Hide];
                break;
                
                // 名称 简单搜索
            case HeaderBtnClick_HeaderSearch:
                [weakSelf headerSearch];
                break;
            
                // 查A端
            case HeaderBtnClick_A:
                [weakSelf headerA_Z:HeaderBtnClick_A];
                break;
            
                // 查Z端
            case HeaderBtnClick_Z:
                [weakSelf headerA_Z:HeaderBtnClick_Z];
                break;
            
                // 多功能搜索
            case HeaderBtnClick_Search:
                [weakSelf headerSearchBtnClick];
                break;
             
                // 清空
            case HeaderBtnClick_Clear:
                [weakSelf headerClear];
                break;
            default:
                break;
        }
        
        
    };
    
}



- (void) block_InitNew {
    
    __typeof(self)weakSelf = self;
    
    _headerNew.headerBlock = ^(HeaderBtnClickNew_ click) {
        
        
        switch (click) {
                // 显示与隐藏
            case HeaderBtnClickNew_Show:
                [weakSelf headerShow_HideNew];
                break;
                
                // 名称 简单搜索
            case HeaderBtnClickNew_HeaderSearch:
                [weakSelf headerSearchNew];
                break;
                
                // 经过设备获取
            case HeaderBtnClickNew_P:
                [weakSelf headerP:HeaderBtnClickNew_P];
                break;
                
                // 多功能搜索
            case HeaderBtnClickNew_Search:
                [weakSelf headerSearchBtnClickNew];
                break;
                
                // 清空
            case HeaderBtnClickNew_Clear:
                [weakSelf headerClearNew];
                break;
            default:
                break;
        }
        
        
    };
    
}



// 收起 展开
- (void) headerShow_Hide {
    
    // 当前是展开的 , 那么去隐藏
    if (_header.nowIsShow) {
        [_header hide];
        _headerConstraint.active = NO;
        _headerConstraint = [_header autoSetDimension:ALDimensionHeight toSize:Vertical(50)];
    }
    else {
        [_header show];
        _headerConstraint.active = NO;
        _headerConstraint = [_header autoSetDimension:ALDimensionHeight toSize:Vertical(250)];
    }

}

// 头部上方 放大镜按钮 点击事件
- (void) headerSearch {
    
    [self httpPort_SelectName:[_header searchName] deviceA_Dict:nil deviceZ_Dict:nil];
}

// A端Z端搜索按钮
- (void) headerA_Z : (HeaderBtnClick_) clickType {
    
    if (clickType == HeaderBtnClick_A) {
        _nowSelect_AOrZ = YES;
    }
    
    if (clickType == HeaderBtnClick_Z) {
        _nowSelect_AOrZ = NO;
    }
    
    [self NewFL_DeviceChooseAlert];
}



// 头部 搜索按钮点击
- (void) headerSearchBtnClick {
    
    [self httpPort_SelectName:[_header searchName] deviceA_Dict:_dictA deviceZ_Dict:_dictZ];
}


// 收起 展开
- (void) headerShow_HideNew {
    
    // 当前是展开的 , 那么去隐藏
    if (_headerNew.nowIsShow) {
        [_headerNew hide];
        _headerConstraintNew.active = NO;
        _headerConstraintNew = [_headerNew autoSetDimension:ALDimensionHeight toSize:Vertical(50)];
    }
    else {
        [_headerNew show];
        _headerConstraintNew.active = NO;
        _headerConstraintNew = [_headerNew autoSetDimension:ALDimensionHeight toSize:Vertical(180)];
    }

}

// 头部上方 放大镜按钮 点击事件
- (void) headerSearchNew {
    
    [self httpPort_SelectName:[_headerNew searchName] device_Dict:nil];
}


// 经过设备搜索按钮
- (void) headerP : (HeaderBtnClickNew_) clickType {

    [self NewFL_DeviceChooseAlert];
}


// 头部 搜索按钮点击
- (void) headerSearchBtnClickNew {
    
    [self httpPort_SelectName:[_headerNew searchName] device_Dict:_dictP];

}



// 清空
- (void) headerClear {
    
    [_header clear];
}

// 清空
- (void) headerClearNew {
    
    [_headerNew clear];
    _dictP = @{};

}

#pragma mark - httpPort ---

//经过设备查询使用
- (void) httpPort_SelectName:(NSString * _Nullable)name
                device_Dict:(NSDictionary * _Nullable)dict{
    

    _dataSource = nil;
    [_tableView reloadData];
    
    
    NSMutableDictionary * param = NSMutableDictionary.dictionary;
    
    if (name) {
        param[@"resName"] = name;
    }
    
    if (dict) {
        param[@"passResId"] = dict[@"GID"];
    }

    
    [self.view endEditing:YES];
    
       
    [self http_LinkPort:param];
    
}


//原光路和光纤使用  A和Z端查询
- (void) httpPort_SelectName:(NSString * _Nullable)name
                deviceA_Dict:(NSDictionary * _Nullable)dictA
                deviceZ_Dict:(NSDictionary * _Nullable)dictZ {
    

    _dataSource = nil;
    [_tableView reloadData];
    
    
    NSMutableDictionary * param = NSMutableDictionary.dictionary;
    
    if (name) {
        param[@"resName"] = name;
    }
    
    if (dictA) {
        param[@"beginResId"] = dictA[@"GID"];
    }
    
    if (dictZ) {
        param[@"endResId"] = dictZ[@"GID"];
    }
    
    [self.view endEditing:YES];
    
    if (_enterType == NewFL_EnterType_Link) {
        [self http_LinkPort:param];
    }
    else {
        [self http_RoutePort:param];
    }
    
    
    
}


- (void) http_LinkPort:(NSDictionary *) param {
    
    [Yuan_NewFL_HttpModel Http_SelectLinkList:param
                                      success:^(id  _Nonnull result) {
            
        NSDictionary * dict = result;
        
        NSArray * content = dict[@"content"];
        
        if (content.count == 0) {
            [YuanHUD HUDFullText:@"暂无数据"];
            return;
        }
        
        _dataSource = content;
        [_tableView reloadData];
    }];
}


- (void) http_RoutePort:(NSDictionary *) param {
    
    [Yuan_NewFL_HttpModel Http_SelectRouteList:param
                                       success:^(id  _Nonnull result) {
            
        NSDictionary * dict = result;
        
        NSArray * content = dict[@"content"];
        
        NSMutableArray * mt_Arr = NSMutableArray.array;
        
        if (content.count == 0) {
            [YuanHUD HUDFullText:@"暂无数据"];
            return;
        }
        
        // 如果是新增时 , 要判断当前路由是否拥有此局向光纤 , 进行去重
        if (_searchListEnum == SearchList_Add) {
            
            
            
            for (NSDictionary * content_Dict in content) {
                
                
                for (NSDictionary * now_Dict in _VM.nowLinkRouters) {
                    
                    NSString * eptId = now_Dict[@"eptId"];
                    
                    if ([content_Dict[@"pairId"] isEqualToString:eptId]) {
                        continue;
                    }
                    
                    [mt_Arr addObject:content_Dict];
                }
                
            }

        }
        
        else {
            mt_Arr = [NSMutableArray arrayWithArray:content];
        }
        
        if (_addArray.count > 0) {
            [YuanHUD HUDFullText:@"请选择链路2的数据"];
        }
        
        _dataSource = mt_Arr;
        [_tableView reloadData];
    }];
}




#pragma mark -  delegate ---

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Yuan_NewFL_SearchListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_NewFL_SearchListCell"];
    
    if (!cell) {
        cell = [[Yuan_NewFL_SearchListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Yuan_NewFL_SearchListCell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary * cell_Dict = _dataSource[indexPath.row];
    
    NSString * nameKey;
    NSString * IdKey;
    
    
    // 光路
    if (_enterType == NewFL_EnterType_Link) {
        nameKey = @"optRoadName";
        IdKey = @"roadId";
    }
    // 局向光纤
    else {
        
        nameKey = @"pairNoDesc";
        IdKey = @"pairId";
    }
    
    
    [cell deviceName:cell_Dict[nameKey]];
    cell.Id = cell_Dict[IdKey];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Vertical(50);
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    
    Yuan_NewFL_SearchListCell * cell = (Yuan_NewFL_SearchListCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    
    
    // 跳转模板
    if (!_myBlock) {
        
        [self GetDetailWithGID:cell.Id block:^(NSDictionary *dict) {
            
            // 跳转模板
            [Inc_Push_MB pushFrom:self
                      resLogicName:[NSString stringWithFormat:@"%@",_resLogicName]
                              dict:dict
                              type:TYKDeviceListUpdate];
             
        }];
        
        return;
    }
    
    
    [self cellSelectDict:dict cellId:cell.Id];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * cell_Dict = _dataSource[indexPath.row];
    
    NSString * nameKey;
    NSString * IdKey;
    
    
    // 光路
    if (_enterType == NewFL_EnterType_Link) {
        nameKey = @"optRoadName";
        IdKey = @"roadId";
    }
    // 局向光纤
    else {
        
        nameKey = @"pairNoDesc";
        IdKey = @"pairId";
    }
    
    
    NSString * name = cell_Dict[nameKey];
    
    NSInteger length = name.length;
    
    if (length <= 40) {
        return Vertical(50);
    }
    
    else if (length > 40  && length <= 70 ) {
        
        return Vertical(70);
    }
    
    else {
        return Vertical(90);
    }
    
    
    return Vertical(50);
}

   
    

// 根据 Gid 和 reslogicName 获取 详细信息
- (void) GetDetailWithGID:(NSString *)GID
                    block:(void(^)(NSDictionary * dict))block{
    
    NSDictionary * dict = @{
        @"resLogicName" : _resLogicName,
        @"GID":GID
    };
    
    [Http.shareInstance V2_POST:HTTP_TYK_Normal_Get
                           dict:dict
                        succeed:^(id data) {
            
        NSArray * arr = data;
        
        if (arr.count > 0) {
            block(arr.firstObject);
        }
        
    }];
    
}
    


- (void) cellSelectDict:(NSDictionary *)indexPath_Dict
                 cellId:(NSString *)GID{
    
    
    if (_numberOfLinks == 1) {
    
        [UIAlert alertSmallTitle:@"是否选择该资源?"
                   agreeBtnBlock:^(UIAlertAction *action) {
            
            // 回调回去 , 这个  pairId 和 pairName 两个字段
            _myBlock(@[indexPath_Dict]);
            Pop(self);
        }];
        
    }
    
    else if (_numberOfLinks == 2) {
        
        // 第一次点击时
        if (!_addArray || _addArray.count == 0) {
            _addArray = NSMutableArray.array;
            
            [_addArray addObject:indexPath_Dict];
                
            [self GetDetailWithGID:GID block:^(NSDictionary *dict) {
                        
                // 根据返回回来的数据 , 再次请求列表数据
                
                if (![dict.allKeys containsObject:@"logicPairStartDevice_Id"] ||
                    ![dict.allKeys containsObject:@"logicPairEndDevice_Id"]) {
                    
                    [YuanHUD HUDFullText:@"局向光纤 缺少起始终止设备Id"];
                    [_addArray removeObject:indexPath_Dict];
                    return;
                }
                
                
                
                NSDictionary * dictA = @{@"GID" : dict[@"logicPairStartDevice_Id"]};
                NSDictionary * dictZ = @{@"GID" : dict[@"logicPairEndDevice_Id"]};
                
                [self httpPort_SelectName:nil deviceA_Dict:dictA deviceZ_Dict:dictZ];
                
            }];
        }
        
        // 第二次点击
        else {
            
            if (_addArray.count == 2) {
                _addArray[1] = indexPath_Dict;
     
            }
            else {
                [_addArray addObject:indexPath_Dict];
            }
            
            NSDictionary * dict_1 = _addArray.firstObject;
            NSDictionary * dict_2 = _addArray.lastObject;
            
            NSString * pairId_1 = dict_1[@"pairId"];
            NSString * pairId_2 = dict_2[@"pairId"];
            
            if ([pairId_1 isEqualToString:pairId_2]) {
                
                [_addArray removeLastObject];
                [YuanHUD HUDFullText:@"您两次选择的是同一个局向光纤 , 请重新选择链路2"];
                return;
            }
            
            [UIAlert alertSmallTitle:@"是否为链路添加局向光纤?"
                       agreeBtnBlock:^(UIAlertAction *action) {
                // 回调回去 , 这个  pairId 和 pairName 两个字段
                _myBlock(_addArray);
                Pop(self);
            }];
            
            
            
            
        }
        
        
    }
    
    else {
        return;
    }
    
    
}





    
#pragma mark - 设备类型选择 ---
    
    
- (void) NewFL_DeviceChooseAlert {
    
    [self.view endEditing:YES];
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"选择设备类型"
                                        message:@""
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Create the actions.
    UIAlertAction *ODF = [UIAlertAction actionWithTitle:@"ODF"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
        [self pushToResLogicName:@"ODF_Equt"];
    }];
    
    
    UIAlertAction *OCC = [UIAlertAction actionWithTitle:@"光交接箱"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
        [self pushToResLogicName:@"OCC_Equt"];
    }];
    
    UIAlertAction *ODB = [UIAlertAction actionWithTitle:@"光分纤箱"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
        [self pushToResLogicName:@"ODB_Equt"];
    }];
    
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //什么也不做
    }];
    
    
    // Add the actions.
    [alertController addAction:ODF];
    [alertController addAction:OCC];
    [alertController addAction:ODB];
    [alertController addAction:cancelAction];
    
    // vc 为模态视图控制器
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

// 跳转 并获取数据
- (void) pushToResLogicName:(NSString *)resLogicName {
    
    [Inc_Push_MB chooseResource_PushFrom:self
                             resLogicName:resLogicName
                                    Block:^(NSDictionary * _Nonnull dict) {
        
        if (_enterType == NewFL_EnterType_Link) {
            _dictP = dict;
            [_headerNew reloadDeviceName:dict[@"deviceName"] Type:HeaderBtnClickNew_P];
            
        }else{
            if (_nowSelect_AOrZ) {
                _dictA = dict;
                [_header reloadDeviceName:dict[@"deviceName"] Type:HeaderBtnClick_A];
            }
            else {
                _dictZ = dict;
                [_header reloadDeviceName:dict[@"deviceName"] Type:HeaderBtnClick_Z];
            }
        }
        
       
    }];
}




- (void) addNew {
 
    NSString * resLogicName ;
    
    if (_enterType == NewFL_EnterType_Link) {
        resLogicName = @"opticalPath";
    }
    else {
        resLogicName = @"optLogicPair";
    }
    
    // TODO 智网通跳转
    [Inc_Push_MB pushFrom:self resLogicName:resLogicName dict:@{} type:TYKDeviceListInsert];
    
}



@end
