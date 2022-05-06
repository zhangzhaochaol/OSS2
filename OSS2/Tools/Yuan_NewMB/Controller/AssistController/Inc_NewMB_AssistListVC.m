//
//  Inc_NewMB_AssistListVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/13.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewMB_AssistListVC.h"

#import "MJRefresh.h"
#import "Inc_NewMB_HttpModel.h"

@interface Inc_NewMB_AssistListVC ()

<
    UITextFieldDelegate ,
    UITableViewDelegate ,
    UITableViewDataSource
>

/** tableView */
@property (nonatomic , strong) UITableView * tableView;

@end

@implementation Inc_NewMB_AssistListVC

{
    
    UITextField * _searchNameTextField;
    UIButton * _selectBtn;
    
    NSArray * _dataSource;
    NSArray * _dataSourceCopy;
    
    BOOL _isHaveSearchBar;
    NSInteger _page;
    NSString * _searchName;
    
    Assist_HttpPort_ _selectHttpPort;
    NSDictionary * _postDict;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithAssistPort:(Assist_HttpPort_) HttpPort
                          postDict:(NSDictionary *) postDict
                   isHaveSearchBar:(BOOL) isHaveSearchBar {
    
    if (self = [super init]) {
        _selectHttpPort = HttpPort;
        _postDict = postDict;
        _isHaveSearchBar = isHaveSearchBar;
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"查询";
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    _page = 1;
    
    [self UI_Init];
    
    // 没有搜索 , 自动去搜
    
    [self Http_Select];
    
    
}



- (void) UI_Init {
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[UITableViewCell class]
                       CellReuseIdentifier:@"UITableViewCell"];
    
    
    
    
    if (_selectHttpPort != Assist_HttpPort_OLTPort) {
        
        _tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
            [self table_FooterClick];
        }];
        
    }
    
    
    
    _searchNameTextField = [UIView textFieldFrame:CGRectNull];
    [_searchNameTextField cornerRadius:5 borderWidth:1 borderColor:UIColor.blackColor];
    
    
    
    _selectBtn = [UIView buttonWithImage:@"search"
                               responder:self
                               SEL_Click:@selector(selectClick)
                                   frame:CGRectNull];
    
    
    [self.view addSubviews:@[_tableView,_searchNameTextField,_selectBtn]];
    
    
    if (!_isHaveSearchBar) {
        _searchNameTextField.hidden = YES;
        _selectBtn.hidden = YES;
        
        [_tableView YuanToSuper_Top:NaviBarHeight];
        [_tableView YuanToSuper_Left:0];
        [_tableView YuanToSuper_Right:0];
        [_tableView YuanToSuper_Bottom:BottomZero];
        
    }
    
    else {
        
        [_searchNameTextField YuanToSuper_Top:NaviBarHeight + Vertical(15)];
        [_searchNameTextField YuanToSuper_Left:Horizontal(15)];
        [_searchNameTextField YuanToSuper_Right:Horizontal(70)];
        [_searchNameTextField autoSetDimension:ALDimensionHeight toSize:Vertical(35)];
        
        
        [_selectBtn YuanAttributeHorizontalToView:_searchNameTextField];
        [_selectBtn YuanToSuper_Right:Horizontal(15)];
        [_selectBtn autoSetDimensionsToSize:CGSizeMake(Horizontal(35), Horizontal(35))];
        
        
        [_tableView YuanMyEdge:Top ToViewEdge:Bottom ToView:_searchNameTextField inset:0];
        [_tableView YuanToSuper_Left:0];
        [_tableView YuanToSuper_Right:0];
        [_tableView YuanToSuper_Bottom:BottomZero];
    }
    
    
    
    
}


#pragma mark - Http ---

- (void) Http_Select {
    
    switch (_selectHttpPort) {
        
            
        case Assist_HttpPort_OLTPort:           //下属OLT 端子查询
            [self HTTP_OLT_ID_Select_OLTPort];
            break;
            
        case Assist_HttpPort_Region:            //所属区域
            [self HTTP_RegionList];
            break;
         
        case Assist_HttpPort_Manufacturer:      //生产厂家
            [self HTTP_Manufacturer];
            break;
        
        case Assist_HttpPort_MaintainUnit:      //维护单位
            
            [self Http_MaintainUnit];
            break;
            
        default:
            
            [YuanHUD HUDFullText:@"请配置对应的枚举值"];
            return;
            
            break;
    }
}


// 根据OLT 搜索OLT下属的端口
- (void) HTTP_OLT_ID_Select_OLTPort {
    
    [Inc_NewMB_HttpModel HTTP_NewMB_SelectOLTPort_OLTId:_postDict[@"id"]
                                                 success:^(id  _Nonnull result) {
            
        _dataSource = result;
        _dataSourceCopy = _dataSource;
        [_tableView.mj_footer endRefreshingWithNoMoreData];
        
        if (_dataSource.count == 0) {
            [YuanHUD HUDFullText:@"未搜索到相关数据"];
            [_tableView reloadData];
            return;
        }
        
        [_tableView reloadData];
    }];
    
}


- (void) HTTP_RegionList {
    
    [Inc_NewMB_HttpModel HTTP_NewMB_RegionListSuccess:^(id  _Nonnull result) {
            
        _dataSource = result;
        [_tableView.mj_footer endRefreshingWithNoMoreData];
        
        if (_dataSource.count == 0) {
            [YuanHUD HUDFullText:@"未搜索到相关数据"];
            [_tableView reloadData];
            return;
        }
        
        [_tableView reloadData];
        
    }];
}



- (void) HTTP_Manufacturer {
    
    [Inc_NewMB_HttpModel HTTP_NewMB_ManufacturerList_Success:^(id  _Nonnull result) {
            
        _dataSource = result;
        [_tableView.mj_footer endRefreshingWithNoMoreData];
        
        if (_dataSource.count == 0) {
            [YuanHUD HUDFullText:@"未搜索到相关数据"];
            [_tableView reloadData];
            return;
        }
        
        [_tableView reloadData];
    }];
}


// 维护单位
- (void) Http_MaintainUnit {
    
    
    [Inc_NewMB_HttpModel HTTP_NewMB_MaintainUnitList_Success:^(id  _Nonnull result) {
       
        NSMutableArray * resultArr = NSMutableArray.array;
        
        NSArray * res = result;
        
        if (res.count == 0) {
            [YuanHUD HUDFullText:@"暂无数据"];
            [_tableView reloadData];
            return;
        }
        
        for (NSDictionary * dict in res) {
            
            NSString * Id = dict[@"unitId"] ?: @"";
            NSString * name = dict[@"unitName"] ?: @"";
            
            [resultArr addObject:@{@"id":Id , @"name":name}];
        }
        
        _dataSource = resultArr;
        [_tableView.mj_footer endRefreshingWithNoMoreData];
        [_tableView reloadData];
        
    }];
    
}



#pragma mark - 事件 ---

- (void) table_FooterClick {
    
    
    
    _page++;
    [self Http_Select];
}


- (void) selectClick {
    
    _searchName = _searchNameTextField.text;
    _page = 1;
    
    if (_selectHttpPort == Assist_HttpPort_OLTPort) {
        
        if (_searchName.length == 0) {
            _dataSource = _dataSourceCopy;
        }
        
        else {
            
            NSMutableArray * newArr = NSMutableArray.array;
            
            for (NSDictionary * dict in _dataSourceCopy) {
                NSString * resName = dict[@"resName"];
                
                if ([resName containsString:_searchName]) {
                    [newArr addObject:dict];
                }
                
            }
            
            _dataSource = newArr;
            [_tableView reloadData];
        }
        
        return;
    }
    
    

    
    [self Http_Select];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (dict && _selectBlock) {
        
        NSString * msg;
        
        if (_selectHttpPort == Assist_HttpPort_Region) {
            msg = @"是否选择该区域";
        }
        
        else if (_selectHttpPort == Assist_HttpPort_Manufacturer) {
            msg = @"是否选择该厂家";
        }
        
        else {
            msg = @"是否选择该资源?";
        }
        
        [UIAlert alertSmallTitle:msg agreeBtnBlock:^(UIAlertAction *action) {
            _selectBlock(dict);
            Pop(self);
        }];
    }
    
    
}



#pragma mark - delegate ---


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.textLabel.numberOfLines = 0;//根据最大行数需求来设置
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.textLabel.font = Font_Yuan(13);
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    
    NSString * titleKey = @"";
    
    switch (_selectHttpPort) {
            
        case Assist_HttpPort_OLTPort:
            titleKey = @"resName";
            break;
            
        case Assist_HttpPort_Region:
            titleKey = @"regionName";
            break;
            
        case Assist_HttpPort_Manufacturer:
        case Assist_HttpPort_MaintainUnit:
            titleKey = @"name";
            break;
        default:
            break;
    }
    
    cell.textLabel.text = dict[titleKey];
    
    return cell;
}


@end
