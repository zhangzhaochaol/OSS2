//
//  IWPGISSiftViewController.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2018/11/15.
//  Copyright © 2018 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPGISSiftViewController.h"
#import "IWPYJCService.h"
#import "MBProgressHUD.h"
#import "IWPGISSiftCollectionViewCell.h"
#import "INCTextField.h"
#define kContentViewWidth 328
#define kContentViewHeight 449
#define kDefaultTextFieldEdges {10,10,-10,-10}

@interface IWPGISSiftViewController () <UITableViewDelegate, UITableViewDataSource, AMapSearchDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

{
    
    BOOL nowIsAllSelect;
    
    // 用来参考全选的数组 , 在viewdidload里初始化
    NSArray * yuan_SelectReferArr;
    
}


@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, weak) UIView * contentView;
@property (nonatomic, weak) UICollectionView * collectionView;
@property (nonatomic, strong) AMapSearchAPI * search;
@property (nonatomic, strong) NSArray <NSDictionary *> * dataSource;
@property (nonatomic, strong) NSArray <NSDictionary *> * collectionViewDataSource;
@property (nonatomic, strong) NSMutableArray <NSDictionary *> * selectedTypes; //选了哪些
@property (nonatomic, copy) NSString * currentCity;
@property (nonatomic, weak) INCTextField * textField;
@property (nonatomic, assign) BOOL isNewUI;
@property (nonatomic, weak) UILabel * nameLabel;
@property (nonatomic, strong) NSDictionary * currentPointInfo;
@end

@implementation IWPGISSiftViewController
-(CGFloat)contentHeight{
    return IphoneSize_Height(45) * self.dataSource.count;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor.blackColor setAlpha:.7];
    //[NSArray arrayWithArray:[@"井,杆,标石,ODF,OCC,局站,机房,引上点,ODB,撑点,光缆接头,设备放置点" componentsSeparatedByString:@","]];
    
    // 当前是非全选状态
    nowIsAllSelect = NO;
    _selectedTypes = [NSMutableArray array];
    
    if(self.isUnionLibrary){
        self.collectionViewDataSource = @[
                            @{@"fileName":@"NONE", @"title":@"全部"},
                            @{@"fileName":@"well", @"title":@"井"},
                            @{@"fileName":@"pole", @"title":@"电杆"},
                            @{@"fileName":@"markStone", @"title":@"标石"},
                            @{@"fileName":@"OCC_Equt", @"title":@"光交接箱"},
                            @{@"fileName":@"stationBase", @"title":@"局站"},
                            @{@"fileName":@"generator", @"title":@"机房"},
                            @{@"fileName":@"ledUp", @"title":@"引上点"},
                            @{@"fileName":@"ODB_Equt", @"title":@"ODB"},
                            @{@"fileName":@"supportingPoints", @"title":@"撑点"},
//                            @{@"fileName":@"joint", @"title":@"光缆接头"},
                            @{@"fileName":@"EquipmentPoint", @"title":@"设备放置点"},
                            ];
    }else{
        self.collectionViewDataSource = @[
                            @{@"fileName":@"NONE", @"title":@"全部"},
                            @{@"fileName":@"well", @"title":@"井"},
                            @{@"fileName":@"pole", @"title":@"电杆"},
                            @{@"fileName":@"markStone", @"title":@"标石"},
                            @{@"fileName":@"ODF_Equt", @"title":@"ODF"},
                            @{@"fileName":@"OCC_Equt", @"title":@"光交接箱"},
                            @{@"fileName":@"stationBase", @"title":@"局站"},
                            @{@"fileName":@"generator", @"title":@"机房"},
                            @{@"fileName":@"ledUp", @"title":@"引上点"},
                            @{@"fileName":@"ODB_Equt", @"title":@"ODB"},
                            @{@"fileName":@"supportingPoints", @"title":@"撑点"},
                            @{@"fileName":@"joint", @"title":@"光缆接头"},
                            @{@"fileName":@"EquipmentPoint", @"title":@"设备放置点"},
                            ];
    }
    
    
    NSMutableArray * array = [NSMutableArray array];
    
    for (int i = 0; i < self.collectionViewDataSource.count; i++) {
        
        if (i == 0)  continue;
        
        [array addObject:self.collectionViewDataSource[i]];
    }
    
    yuan_SelectReferArr = [NSArray arrayWithArray:array];
    
    [self configSubviewsNew];
    
    // Do any additional setup after loading the view.
}
-(void)setCoordinate:(CLLocationCoordinate2D)coordinate{
    _coordinate = coordinate;
    [self whereIAmI];
}
- (void)whereIAmI{
    
    AMapReGeocodeSearchRequest * request = [[AMapReGeocodeSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    
    [self.search AMapReGoecodeSearch:request];
    
    
}

- (void)configSubviewsNew{
    _isNewUI = true;
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    UIView * contentView = UIView.new;
    _contentView = contentView;
    contentView.clipsToBounds = true;
    contentView.layer.masksToBounds = true;
    contentView.layer.cornerRadius = IphoneSize_Height(5);
    contentView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.offset(IphoneSize_Height(kContentViewHeight));
        make.width.offset(IphoneSize_Width(kContentViewWidth));
        make.centerX.centerY.equalTo(self.view);
        
    }];
    
    
    
    INCTextField * textField = [[INCTextField alloc] init];
    _textField = textField;
    textField.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    textField.font = [UIFont systemFontOfSize:14];
    textField.textColor = [UIColor colorWithHexString:@"#333"];
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    
    UIImageView * searchIcon = UIImageView.new;
    searchIcon.image = [UIImage Inc_imageNamed:@"icon_sift_sousuo"];
    searchIcon.frame = CGRectMake(IphoneSize_Width(0), 0, IphoneSize_Width(26), IphoneSize_Height(13));
    searchIcon.contentMode = UIViewContentModeCenter;
    
    UIButton * listenButton = UIButton.new;
    
    
    listenButton.frame = CGRectMake(0, 0, IphoneSize_Width(36), IphoneSize_Height(18));
    [listenButton addTarget:self action:@selector(beginListen) forControlEvents:UIControlEventTouchUpInside];
    [listenButton setImage:[UIImage Inc_imageNamed:@"icon_sift_yuyin"] forState:UIControlStateNormal];
    [contentView addSubview:textField];
    
    textField.leftView = searchIcon;
    textField.rightView = listenButton;
    textField.leftViewMode =
    textField.rightViewMode = UITextFieldViewModeAlways;
    
    UIEdgeInsets textFieldEdge = kDefaultTextFieldEdges;
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(contentView).offset(IphoneSize_Width(textFieldEdge.left));
        make.right.equalTo(contentView).offset(IphoneSize_Width(textFieldEdge.right));
        make.top.equalTo(contentView).offset(IphoneSize_Height(textFieldEdge.top));
        make.height.offset(IphoneSize_Height(32));
        
        
    }];
    
    [textField addTarget:self action:@selector(textFieldDidEdited:) forControlEvents:UIControlEventEditingChanged];
    
    
    UILabel * nameLabel = UILabel.new;
    _nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:Horizontal(12)];
    [contentView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(contentView).offset(IphoneSize_Width(10));
        make.right.equalTo(contentView).offset(IphoneSize_Width(-10));
        make.top.equalTo(textField.mas_bottom).offset(IphoneSize_Height(10));
        make.height.offset(IphoneSize_Height(0));
        
    }];
    
    UIView * line = UIView.new;
    line.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    [contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(contentView);
        make.height.offset(IphoneSize_Height(1));
        make.top.equalTo(nameLabel.mas_bottom).offset(IphoneSize_Height(5));
        
    }];
    

    UITableView * tableView = TableView(self, UITableViewStylePlain);
    _tableView = tableView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.alpha = 0;
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.bottom.equalTo(contentView);
        make.top.equalTo(line.mas_bottom);

    }];
    
    
    UICollectionViewFlowLayout * layout = UICollectionViewFlowLayout.new;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) collectionViewLayout:layout];
    collectionView.backgroundColor = UIColor.whiteColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.allowsMultipleSelection = true;
    [collectionView registerClass:IWPGISSiftCollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
    
    [contentView addSubview:collectionView];
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(contentView);
        make.top.equalTo(line.mas_bottom);
        make.bottom.equalTo(contentView).offset(IphoneSize_Height(75));
        
    }];
    
    UIButton * checkButton = UIButton.new;
    checkButton.titleLabel.font = [UIFont systemFontOfSize:Horizontal(15)];
    checkButton.backgroundColor = UIColor.mainColor;
    [checkButton setTitle:@"查询" forState:UIControlStateNormal];
    [contentView addSubview:checkButton];
    [checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(contentView).offset(IphoneSize_Width(15));
        make.right.equalTo(contentView).offset(IphoneSize_Width(-15));
        make.bottom.equalTo(contentView).offset(IphoneSize_Height(-15));
        make.height.offset(IphoneSize_Height(45));
        
    }];
    
    [checkButton addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
    
    checkButton.layer.masksToBounds = true;
    checkButton.layer.cornerRadius = IphoneSize_Height(45 / 2);
   
    [self addCloseBtn];
    
}


- (void)addCloseBtn{
    
    UIView * lineView = UIView.new;
    [self.view addSubview:lineView];
    lineView.backgroundColor = UIColor.whiteColor;
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView.mas_right).offset(IphoneSize_Width(-1));
        make.width.offset(IphoneSize_Width(1));
        make.height.offset(IphoneSize_Height(35));
        make.bottom.equalTo(self.contentView.mas_top).offset(IphoneSize_Height(10));
        
    }];
    
    UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:closeButton];
    
    [closeButton setImage:[UIImage Inc_imageNamed:@"icon_close_new"] forState:UIControlStateNormal];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.offset(IphoneSize_Height(22));
        make.width.offset(IphoneSize_Width(22));
        make.bottom.equalTo(lineView.mas_top);
        make.centerX.equalTo(lineView);
        
    }];
    
    [closeButton addTarget:self action:@selector(closeMySelf) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)textFieldDidEdited:(INCTextField *)textFiled{
    
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = textFiled.text;
    tips.city = self.currentCity;
    tips.cityLimit = true;
    tips.location = [NSString stringWithFormat:@"%@,%@", @(self.coordinate.longitude), @(self.coordinate.latitude)];
    [self.search AMapInputTipsSearch:tips];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.text.length == 0) {
        CGFloat alpha = 0;
        [self showOrHideTableView:&alpha];
        self.dataSource = nil;
        [self.tableView reloadData];
        
        
    }
}

/*
 
 
 AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
 tips.keywords = @"天安门";
 tips.city = self.currentCity;
 [self.search AMapInputTipsSearch:tips];
 */


- (void)configSubViews{
    _isNewUI = false;
    UITableView * tableView = TableView(self, UITableViewStylePlain);
    _tableView = tableView;
    
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(self.view).multipliedBy(.3);
        make.height.offset(self.contentHeight);
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(HeigtOfTop / 2.f);
        
        
    }];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * kCellId = @"cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellId];
        
        if (_isNewUI == false) {
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }else{
            UIView * line = UIView.new;
            [cell.contentView addSubview:line];
            line.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.right.equalTo(cell.contentView);
                make.height.offset(IphoneSize_Height(1));
                make.bottom.equalTo(cell.contentView);
                
            }];
            cell.imageView.image = [UIImage Inc_imageNamed:@"icon_sift_dingwei"];
            
        }
        cell.textLabel.font = [UIFont systemFontOfSize:Horizontal(14)];
        cell.textLabel.numberOfLines = 0;
        
    }
    if (_isNewUI) {
        cell.textLabel.text = self.dataSource[indexPath.row][@"title"];
//        CLLocationCoordinate2D coordinate = CoordinateFromNSString(self.dataSource[indexPath.row][@"coordinate"]);
//
//        MAMapPoint point1 = MAMapPointForCoordinate(coordinate);
//
//        MAMapPoint point2 = MAMapPointForCoordinate(self.coordinate);
//        CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
//
        
    }else{
        cell.textLabel.text = self.dataSource[indexPath.row][@"title"];
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (_isNewUI) {
        
        
        CGFloat alpha = 0;
        [self showOrHideTableView:&alpha];
        
        
        self.currentPointInfo = self.dataSource[indexPath.row];
        self.nameLabel.text = self.currentPointInfo[@"title"];
        self.textField.text = @"";
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
           
            make.height.offset(IphoneSize_Height(20));
            
        }];
        
    }else{
        self.selected(self.dataSource[indexPath.row]);
    }
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return _isNewUI ? 0 : IphoneSize_Height(45);
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_isNewUI == false) {
        [UIView animateWithDuration:.3f animations:^{
            self.view.alpha = 0;
        }];
    }
}


- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response{
    //解析response获取提示词，具体解析见 Demo
    NSMutableArray * arr = NSMutableArray.new;
    for (AMapTip * tip in response.tips) {
        
        
        NSMutableDictionary * dict = NSMutableDictionary.dictionary;
        
        dict[@"title"] = tip.name;
        
        dict[@"coordinate"] = NSStringFromCoordinate(CLLocationCoordinate2DMake(tip.location.latitude, tip.location.longitude));
        
        [arr addObject:dict];
        
    }
    
    self.dataSource = arr;
    [self.tableView reloadData];
    [self showOrHideTableView:NULL];

}

- (void)showOrHideTableView:(CGFloat *)setAlphaTo{
    
    CGFloat alpha = 0;
    if (setAlphaTo == NULL) {
        alpha = self.dataSource.count > 0 ? 1 : 0;
    }else{
        alpha = *setAlphaTo;
    }
    
    
    [UIView animateWithDuration:.3 animations:^{
       
        self.tableView.alpha = alpha;
        
    }];
    
}

-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    
    self.currentCity = response.regeocode.addressComponent.city;
    
}

- (void)beginListen{

    
    
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collectionViewDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    IWPGISSiftCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.title = self.collectionViewDataSource[indexPath.row][@"title"];
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    if (indexPath.row == 0) {
        // 全选
        for (NSInteger i = 1; i < self.collectionViewDataSource.count; i++) {
            NSIndexPath * indexPathTemp = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            
            [collectionView selectItemAtIndexPath:indexPathTemp animated:false scrollPosition:UICollectionViewScrollPositionNone];
        }
        NSDictionary * item = self.collectionViewDataSource[indexPath.row];

        // 把 全部 加入数组中
        [self exchangeSelectedItemsIsRemove:false
                                   withItem:item
                                isAllSelect:YES
                                  IndexPath:indexPath
                             collectionView:collectionView];
    }else{
        
        NSDictionary * item = self.collectionViewDataSource[indexPath.row];
        [self exchangeSelectedItemsIsRemove:false
                                   withItem:item
                                  IndexPath:indexPath
                             collectionView:collectionView];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        // 取消全选
        for (NSInteger i = 1; i < self.collectionViewDataSource.count; i++) {
            NSIndexPath * indexPathTemp = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            
            [collectionView deselectItemAtIndexPath:indexPathTemp animated:false];
 
        }
        
        // 清空数组喽
        [self exchangeSelectedItemsIsRemove:true
                                   withItem:nil
                                isAllSelect:YES
                                  IndexPath:indexPath
                             collectionView:collectionView];
          
    }else{
        
        // 不仅本item 需要点掉 , 全部按钮的item也需要点掉
        [collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:true];
        // 移除全部
        [self exchangeSelectedItemsIsRemove:true
                                   withItem:self.collectionViewDataSource[0]
                                  IndexPath:indexPath
                                  collectionView:collectionView];
        
        NSDictionary * item = self.collectionViewDataSource[indexPath.row];
        //移除 当前
        [self exchangeSelectedItemsIsRemove:true
                                   withItem:item
                                  IndexPath:indexPath
                                  collectionView:collectionView];
    }
    
}


// 只有全选才会走这个方法
- (void) exchangeSelectedItemsIsRemove:(BOOL)isRemove
                              withItem:(NSDictionary *)item
                           isAllSelect:(BOOL)isAllSelect
                             IndexPath:(NSIndexPath *)indexPath
                        collectionView:(UICollectionView *)collectionView{
    
    
    if (isRemove) {
        //移除  此时 是非全选状态
        nowIsAllSelect = NO;
        // 点击了全选按钮 , 把所有的选项都灭了
        [_selectedTypes removeAllObjects];
    }else {
        // 全部选中
        nowIsAllSelect = YES;
        //把数组清空
        // _selectedTypes里只有 @{@"fileName":@"NONE", @"title":@"全部"} 一个dict
        _selectedTypes = [NSMutableArray arrayWithArray:@[item]];
    }
    NSLog(@"有几个？  %@ \n %@", @(_selectedTypes.count),_selectedTypes);
    
}




- (void)exchangeSelectedItemsIsRemove:(BOOL)isRemove
                             withItem:(NSDictionary *)item
                            IndexPath:(NSIndexPath *)indexPath
                       collectionView:(UICollectionView *)collectionView{
    
    
    if (isRemove) {
        // 移除
        // 1. 如果是从全选状态下移除的普通item
        if (nowIsAllSelect == YES) {
            // 当前状态是全选了 , _selectedTypes里只有 @"fileName":@"NONE", @"title":@"全部"
            // 这么一个字段
            
            nowIsAllSelect = NO;
            [_selectedTypes removeAllObjects];
            // 既然是非全选了 , 就要重新赋值 , 由于全选的时候只留了一个dict , 要充满
            _selectedTypes = [NSMutableArray arrayWithArray:_collectionViewDataSource];
            // 把当前要移除的item删掉
            [_selectedTypes removeObject:item];
            // 还要删掉 @{@"fileName":@"NONE", @"title":@"全部"}
            [_selectedTypes removeObjectAtIndex:0];
        } else {
            // 正常移除就行
            [_selectedTypes removeObject:item];
        }
    }else {
        
        // 如果是添加
        
        [_selectedTypes addObject:item];
        
        
        NSSet * setSelect = [NSSet setWithArray:_selectedTypes];
        NSSet * setYuanRefer = [NSSet setWithArray:yuan_SelectReferArr];
        
        
        if ([setSelect isEqual:setYuanRefer]) {
            
            [collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section] animated:false scrollPosition:UICollectionViewScrollPositionNone];
            
            [self exchangeSelectedItemsIsRemove:false
                                       withItem:self.collectionViewDataSource[0]
                                    isAllSelect:YES
                                      IndexPath:indexPath
                                 collectionView:collectionView];
            
        }
        
    }
    
    NSLog(@"有几个？  %@ \n %@", @(_selectedTypes.count),_selectedTypes);
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(IphoneSize_Width(kContentViewWidth / 3), IphoneSize_Height(45));
    // 249 335
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
    
}

- (void)didCheck:(UIButton *)sender{
    
    if (self.selectedTypes.count == 0) {
        AlertShow(self.view, @"请至少选择一种资源类型进行查询", 2.f, @"");
        return;
    }
    
    
    NSString * string = @"";
    for (NSDictionary * dict in self.selectedTypes) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%@,", dict[@"fileName"]]];
    }
    
    if ([string rangeOfString:@"NONE"].length > 0) {
        
        string = @"NONE";
        
    }
    
    NSLog(@"%@", string);
    
    self.selectedNew(string, CoordinateFromNSString(self.currentPointInfo[@"coordinate"]));

    [self closeMySelf];
}
- (void)closeMySelf{
    
    [self dismissViewControllerAnimated:true completion:nil];
    
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
