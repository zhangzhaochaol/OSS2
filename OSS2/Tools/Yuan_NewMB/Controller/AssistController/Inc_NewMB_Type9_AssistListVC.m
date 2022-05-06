//
//  Inc_NewMB_Type9_AssistListVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/30.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewMB_Type9_AssistListVC.h"
#import "MJRefresh.h"


static NSString * Url = @"unionSearch/unionSearchPubResource";

@interface Inc_NewMB_Type9_AssistListVC ()

<
    UITableViewDelegate ,
    UITableViewDataSource,
    UITextFieldDelegate
>

/** table */
@property (nonatomic , strong) UITableView * tableView;

/** 搜索框 */
@property (nonatomic , strong) UITextField * textField;

@end

@implementation Inc_NewMB_Type9_AssistListVC
{
    
    // 模糊搜索
    NSString * _selectName;
    // 地址
    NSString * _url;
    // res
    NSString * _resLogicName;
    
    
    NSDictionary * _postDict;
    
    // 所有的原始数据
    NSMutableArray * _dataSource;
    
    NSInteger _pageNum;
    
}

#pragma mark - 初始化构造方法

- (instancetype)initWithPostDict:(NSDictionary *)postDict{
    
    if (self = [super init]) {
        
        _pageNum = 1;
        _postDict = postDict;

        _selectName = @"";
        _dataSource = NSMutableArray.array;
        
        #if DEBUG
            _url = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,Url];
        #else
            _url = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,Url];
        #endif
        
    }
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"资源查询";

    [self UI_Init];
    [self http_Select];
}


// 配置标题
- (void) configTitle:(NSString *) title {
    
    if (title) {
        self.title = [NSString stringWithFormat:@"查询%@",title];
    }
}



#pragma mark - http ---


- (void) http_Select {
    
    NSMutableDictionary * myPostDict = [NSMutableDictionary dictionaryWithDictionary:_postDict];
    
    myPostDict[@"reqDb"] = Yuan_WebService.webServiceGetDomainCode;
    myPostDict[@"pageSize"] = @"100";
    myPostDict[@"pageNum"] = [Yuan_Foundation fromInteger:_pageNum];
    
    if (_selectName.length > 0) {
        myPostDict[@"name"] = _selectName;
    }
    
    [Http.shareInstance DavidJsonPostURL:_url
                                   Parma:myPostDict
                                 success:^(id result) {
            
        NSArray * datas = result[@"content"];
        
        if (datas.count == 0) {
            [YuanHUD HUDFullText:@"暂无数据"];
            [_tableView reloadData];
            return;
        }
        
        [_dataSource addObjectsFromArray:datas];
        
        [_tableView reloadData];
        [_tableView.mj_footer endRefreshingWithNoMoreData];
        
    }];
    
}


- (void) table_FooterClick {
    
    _pageNum++;
    
    [self http_Select];
    
}


#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = Font_Yuan(14);
    cell.textLabel.numberOfLines = 0;//根据最大行数需求来设置
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    NSString * name = dict[@"name"];
    
    if (name) {
        cell.textLabel.text = name;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    [UIAlert alertSmallTitle:@"是否选择该资源?"
               agreeBtnBlock:^(UIAlertAction *action) {
            
        if (_Type9_Choose_ResBlock) {
            
            _Type9_Choose_ResBlock(dict);
            Pop(self);
        }
    }];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Vertical(60);
}


#pragma mark - textFieldDelegate ---

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    _selectName = textField.text;
    
    _pageNum = 1;
    [_dataSource removeAllObjects];
    
    [self http_Select];
    
    return YES;
    
}


#pragma mark - UI ---

- (void) UI_Init {
    
    _textField = [UIView textFieldFrame:CGRectNull];
    [_textField cornerRadius:5 borderWidth:1 borderColor:UIColor.lightGrayColor];
    _textField.delegate = self;
    
    _tableView = [UIView tableViewDelegate:self registerClass:[UITableViewCell class] CellReuseIdentifier:@"UITableViewCell"];
    
    
    _tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        [self table_FooterClick];
    }];
    
    [self.view addSubviews:@[_textField,_tableView]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_textField YuanToSuper_Top:NaviBarHeight + limit];
    [_textField YuanToSuper_Left:limit];
    [_textField YuanToSuper_Right:limit];
    [_textField Yuan_EdgeHeight:Vertical(40)];
    
    [_tableView YuanToSuper_Left:0];
    [_tableView YuanToSuper_Right:0];
    [_tableView YuanToSuper_Bottom:BottomZero];
    [_tableView YuanMyEdge:Top ToViewEdge:Bottom ToView:_textField inset:limit];
    
}

@end
