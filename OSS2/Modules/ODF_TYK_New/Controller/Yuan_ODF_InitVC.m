//
//  Yuan_ODF_InitVC.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/28.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_ODF_InitVC.h"
#import "Yuan_ODF_ChooseCell.h"    //cell
#import "Yuan_ODFInit_ShowCell.h"  //cell

#import "Yuan_ODFViewModel.h"      //viewModel
#import "Yuan_PickerView.h"        // pickerView


@interface Yuan_ODF_InitVC ()

< UITableViewDelegate , UITableViewDataSource >

/** tableView */
@property (nonatomic,strong) UITableView *tableView;

/** 背景 */
@property (nonatomic,strong) UIView *backGround_View;

/** 方块 */
@property (nonatomic,strong) UIView *blockView;

/** 标题 */
@property (nonatomic,strong) UILabel *baseTitle;

/** 关闭按钮 */
@property (nonatomic,strong) UIButton *guanbiBtn;

/** 保存 初始化 */
@property (nonatomic,strong) UIButton *save;

//144按钮
@property (nonatomic,strong) UIButton *btn144;
//288按钮
@property (nonatomic,strong) UIButton *btn288;


@end

@implementation Yuan_ODF_InitVC


{
    
    NSArray * _sectionOneTitleArr;
    
    NSArray * _sectionOneValueArr;
    
    NSArray * _sectionTwoTitleArr;
    
    NSArray * _sectionThreeTitleArr;
    
    
    
    NSArray * _terminalCount;    //端子数量   1 - 24
    
    NSArray * _VHCount;          //行列数量   1 - 16
    
    NSArray * _moduleArrange;    //模块排列  行优 , 列优
    
    NSString * _name;            //设备名
    
    
    int  _state; //0：正常  1：144  2:288
    
    //点击144或288按钮后 需要的行数、列数和排列方式
    NSArray * _modArray;
    
    
    //缓存table数据
    NSMutableDictionary *_dataDic;
}

#pragma mark - 初始化构造方法

- (instancetype) initWithNum:(NSInteger)num
                 faceInverse:(BOOL)isFaceInverse
                        name:(nonnull NSString *)name{
    
    if (self = [super init]) {
        
        _name = name;
        
        NSString * faceInverse = isFaceInverse ? @"正面" : @"反面";
        
        NSString * nname = [NSString stringWithFormat:@"%@f%ld",name,num];
        
        _sectionOneTitleArr = @[@"列框名称",@"位置序号",@"正/反面"];
        _sectionOneValueArr = @[nname,[Yuan_Foundation fromInteger:num],faceInverse];
        
        _sectionTwoTitleArr = @[@"模块行数",@"模块列数",@"模块排列"];
        _sectionThreeTitleArr =@[@"模块内端子列数",@"模块内端子行数"] ;
        
        
        // 初始化 下拉框数据源
        _terminalCount = [Yuan_ODFViewModel terminalCountArr];
        _VHCount = [Yuan_ODFViewModel VHCountArr];
        _moduleArrange = [Yuan_ODFViewModel moduleArrangeArr];
        
        _dataDic = [NSMutableDictionary dictionary];
        
        
    }
    return self;
}


/*
    模块 行列 1 - 16   端子数量 1 - 24
 */

- (void)viewDidLoad {
    [super viewDidLoad];

    _state = 0;
    
    [self.view addSubview:self.backGround_View];
    
    [_backGround_View addSubview:self.tableView];
    [_backGround_View addSubview:self.blockView];
    [_backGround_View addSubview:self.baseTitle];
    [_backGround_View addSubview:self.guanbiBtn];
    [_backGround_View addSubview:self.save];
    
    _btn144 = [UIView buttonWithTitle:@"144" responder:self SEL:@selector(save144Or288:) frame:CGRectNull];
    _btn144.titleLabel.font = Font_Yuan(16);
    [_btn144 setTitleColor:UIColor.lightGrayColor forState:UIControlStateNormal];
    [_btn144 setCornerRadius:5 borderColor:_btn144.titleLabel.textColor borderWidth:1];
    
    
    _btn288 = [UIView buttonWithTitle:@"288" responder:self SEL:@selector(save144Or288:) frame:CGRectNull];
    _btn288.titleLabel.font = Font_Yuan(16);
    [_btn288 setTitleColor:UIColor.lightGrayColor forState:UIControlStateNormal];
    [_btn288 setCornerRadius:5 borderColor:_btn288.titleLabel.textColor borderWidth:1];
    
    
    [_backGround_View addSubview:self.btn144];
    [_backGround_View addSubview:self.btn288];

    
    [self layoutAllSubViews];
    
    
    //  选择端子信息个数后的回调
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noti_DataPickerCommit)
                                                 name:Noti_DataPickerCommit
                                               object:nil];
    
}



#pragma mark - 通知  要小于 360  模块行 x 模块列 x模块内端子个数 < 360  (2021.7.5 修改过 之前是288)

- (void) noti_DataPickerCommit {
    
    
    // 根据 index  获取到 cell
    // 对应的是 模块行数 模块列数 模块排列 模块内端子数量
    NSArray * indexArray = @[[NSIndexPath indexPathForRow:0 inSection:1],
                             [NSIndexPath indexPathForRow:1 inSection:1],
                             [NSIndexPath indexPathForRow:0 inSection:2],
                             [NSIndexPath indexPathForRow:1 inSection:2]];
    
    
    /// key
    NSArray * postKeyArray = @[@"moduleRowQuantity",        //行
                               @"moduleColumnQuantity",     //列
                               @"moduleTubeColumn",        //模块内端子列数
                               @"moduleTubeRow"];          //模块内端子行数
    
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    int index = 0;
    Yuan_ODF_ChooseCell * cell;
    
    for (NSString * str in postKeyArray) {
        // 通过index 得到cell
        cell = [_tableView cellForRowAtIndexPath:indexArray[index]];
        
        dict[str] = cell.printView.text;
        //选择后赋值
        [_dataDic setValue:cell.printView.text forKey:[NSString stringWithFormat:@"%ld",(long)cell.printView.tag]];
        index++;
    }
    
    
    NSInteger num_sum = 1;
    
    for (NSString * num in dict.allValues) {
            
        NSUInteger now = [num integerValue];
        
        num_sum = num_sum * now;
    }
    
    
    if (num_sum > 360) {
        [[Yuan_HUD shareInstance] HUDFullText:@"模块行数 x 模块列数 x 端子列数 x 端子行数 \n 不能大于360"];
        _save.userInteractionEnabled = NO;
        _save.backgroundColor = [UIColor lightGrayColor];
    }else {
        _save.userInteractionEnabled = YES;
        _save.backgroundColor = ColorR_G_B(210, 0, 0);
    }
    
    
    //模块数据选择后  底部144、288按钮致灰
    [_btn144 setTitleColor:UIColor.lightGrayColor forState:UIControlStateNormal];
    [_btn144 setCornerRadius:5 borderColor:_btn144.titleLabel.textColor borderWidth:1];
    
    [_btn288 setTitleColor:UIColor.lightGrayColor forState:UIControlStateNormal];
    [_btn288 setCornerRadius:5 borderColor:_btn288.titleLabel.textColor borderWidth:1];
    
}

 


#pragma mark - TableViewDelegate / TaleViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    switch (indexPath.section) {
        case 0:
                return 45;
            break;
        case 1:
                return 75;
            break;
        case 2:
                return 75;
            break;
            
        default:
            return 0;
            break;
    }
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return nil;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 5)] ;
    
    headerView.backgroundColor = ColorValue_RGB(0xf2f2f2);

    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 5;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
                return 3;
            break;
        case 1:
                return 3;
            break;
        case 2:
                return 2;
            break;
            
        default:
                return 0;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        Yuan_ODFInit_ShowCell * cell =
        [tableView dequeueReusableCellWithIdentifier:@"Yuan_ODFInit_ShowCell"];
        
        if (!cell) {
            cell = [[Yuan_ODFInit_ShowCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:@"Yuan_ODFInit_ShowCell"];
        }
        
        
        cell.key.text = _sectionOneTitleArr[indexPath.row];
        cell.value.text = _sectionOneValueArr[indexPath.row];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    if (indexPath.section == 1) {
        Yuan_ODF_ChooseCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_ODF_ChooseCell"];
        
        if (!cell) {
            cell =
            [[Yuan_ODF_ChooseCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"Yuan_ODF_ChooseCell"];
        }
        
        [cell setTxt_Title:_sectionTwoTitleArr[indexPath.row]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 2) {   //模块排列
            cell.dataSource = _moduleArrange;
        }else {
            cell.dataSource = _VHCount;
        }
        
        cell.printView.tag = 10000 + indexPath.row;
        if (indexPath.row == 0 || indexPath.row == 1) {
            cell.printView.text = _dataDic[[NSString stringWithFormat:@"%ld",(long)cell.printView.tag]]?:@"1";
        }else{
            cell.printView.text = _dataDic[[NSString stringWithFormat:@"%ld",(long)cell.printView.tag]]?:@"行优、上左";
        }
        if (_state == 1 || _state == 2) {
            cell.printView.text = _modArray[indexPath.row];
        }
        return cell;
        
    }
    
    
    if (indexPath.section == 2) {
        
        Yuan_ODF_ChooseCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_ODF_ChooseCell"];
        
        if (!cell) {
            cell =
            [[Yuan_ODF_ChooseCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"Yuan_ODF_ChooseCell"];
        }
        
        [cell setTxt_Title:_sectionThreeTitleArr[indexPath.row]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.dataSource = _terminalCount;
        
        cell.printView.tag = 10000 + 4 + indexPath.row;
        cell.printView.text = _dataDic[[NSString stringWithFormat:@"%ld",(long)cell.printView.tag]]?:@"1";

        if (_state == 1 || _state == 2) {
            if (indexPath.row == 0) {
                cell.printView.text = @"12";
            }else{
                cell.printView.text = @"1";
            }
        }
        return cell;
    }
    
    
    return nil;
}






#pragma mark - 懒加载 ***** ****** ****** *****


- (UIView *)backGround_View {
    
    if (!_backGround_View) {
        
        _backGround_View = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Horizontal(330), Vertical(580))];
        
        _backGround_View.layer.cornerRadius = 15;
        _backGround_View.layer.masksToBounds = YES;
        
        _backGround_View.backgroundColor = [UIColor whiteColor];
        
        _backGround_View.center = self.view.center;
        
    }
    return _backGround_View;
}


- (UIView *)blockView {
    
    if (!_blockView) {
        _blockView = [UIView viewWithColor:ColorR_G_B(210, 0, 0)];
    }
    return _blockView;
}

- (UILabel *)baseTitle {
    
    if (!_baseTitle) {
        
        _baseTitle = [UIView labelWithTitle:@"初始化列框信息" frame:CGRectNull];
        [_baseTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
        _baseTitle.textColor = ColorValue_RGB(0x000000);
    }
    return _baseTitle;
}


- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectNull style:UITableViewStyleGrouped];
           
        _tableView.delegate = self;
        _tableView.dataSource = self;
            
        _tableView = [UIView tableViewDelegate:self registerClass:[Yuan_ODF_ChooseCell class] CellReuseIdentifier:@"Yuan_ODF_ChooseCell"];
        
        [_tableView registerClass:[Yuan_ODFInit_ShowCell class] forCellReuseIdentifier:@"Yuan_ODFInit_ShowCell"];
        
//        [_tableView setScrollEnabled:NO];
        
    }
    return _tableView;
}



- (UIButton *)guanbiBtn {
    
    if (!_guanbiBtn) {
        _guanbiBtn = [UIView buttonWithImage:@"icon_guanbi" responder:self SEL_Click:@selector(closeClick) frame:CGRectNull];
    }
    return _guanbiBtn;
}


/// 关闭按钮点击事件
- (void) closeClick {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (UIButton *)save {
    
    if (!_save) {
        _save = [UIView buttonWithTitle:@"保 存" responder:self SEL:@selector(saveClick) frame:CGRectNull];
        _save.backgroundColor = ColorR_G_B(210, 0, 0);
        _save.titleLabel.font = [UIFont systemFontOfSize:16];
        [_save setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _save.layer.cornerRadius = 5;
        _save.layer.masksToBounds = YES;
    }
    return _save;
}




/// 初始化 保存按钮点击事件
- (void) saveClick {
    
    // 根据 index  获取到 cell
    // 对应的是 模块行数 模块列数 模块排列 模块内端子数量
    NSArray * indexArray = @[[NSIndexPath indexPathForRow:0 inSection:1],
                             [NSIndexPath indexPathForRow:1 inSection:1],
                             [NSIndexPath indexPathForRow:2 inSection:1],
                             [NSIndexPath indexPathForRow:0 inSection:2],
                             [NSIndexPath indexPathForRow:1 inSection:2]];
    
    
    /// key
    NSArray * postKeyArray = @[@"moduleRowQuantity",        //行
                               @"moduleColumnQuantity",     //列
                               @"Rule_Dire",                //排列
                               @"moduleTubeColumn",         //模块内端子数量列
                               @"moduleTubeRow"];           //模块内端子数量行
    
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    int index = 0;
    Yuan_ODF_ChooseCell * cell;
    
    for (NSString * str in postKeyArray) {
        // 通过index 得到cell
        cell = [_tableView cellForRowAtIndexPath:indexArray[index]];
        
        NSString * value = cell.printView.text;
        // 如果没有value  默认1
        dict[str] = value ?: @"1";
        
        index++;
    }
    
    // 设备名称
    dict[@"equName"] = _name;
    
    // 序号
    dict[@"position"] = _sectionOneValueArr[1];
    
    // 正反面
    NSString * faceInverse = [_sectionOneValueArr[2] isEqualToString:@"正面"] ? @"3050001" : @"3050002";

    dict[@"faceInverse"] = faceInverse;
    
    NSLog(@"%@",dict);
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (_saveBtnBlock) {
            _saveBtnBlock(dict);
        }
    }];
    
   

}


- (void)save144Or288:(UIButton *)btn {
    
    if (btn == _btn144) {
        
        [_btn144 setTitleColor:ColorR_G_B(210, 0, 0) forState:UIControlStateNormal];
        [_btn144 setCornerRadius:5 borderColor:_btn144.titleLabel.textColor borderWidth:1];
        
        [_btn288 setTitleColor:UIColor.lightGrayColor forState:UIControlStateNormal];
        [_btn288 setCornerRadius:5 borderColor:_btn288.titleLabel.textColor borderWidth:1];
        
        _state = 1;
        
        _modArray = @[
            @"12",
            @"1",
            @"行优、上左"
        ];
    }else{
        
        [_btn288 setTitleColor:ColorR_G_B(210, 0, 0) forState:UIControlStateNormal];
        [_btn288 setCornerRadius:5 borderColor:_btn288.titleLabel.textColor borderWidth:1];
        
        [_btn144 setTitleColor:UIColor.lightGrayColor forState:UIControlStateNormal];
        [_btn144 setCornerRadius:5 borderColor:_btn144.titleLabel.textColor borderWidth:1];
      
        _state = 2;
        _modArray = @[
            @"24",
            @"1",
            @"行优、上左"
        ];
    }
        
    //切换144/288按钮后保存按钮改变为可点状态 防止选择完端子数量后按钮变灰，在选择快捷按钮后不可点击问题
    _save.userInteractionEnabled = YES;
    _save.backgroundColor = ColorR_G_B(210, 0, 0);
    
    [self.tableView reloadData];
    
    return;


    
    
}

- (NSDictionary *)quickGenerationDic:(NSString *)moduleRowQuantity {
    
    NSDictionary *dic = @{@"moduleRowQuantity":moduleRowQuantity,
                          @"position":_sectionOneValueArr[1],
                          @"Rule_Dire":@"行优、上左",
                          @"faceInverse":[_sectionOneValueArr[2] isEqualToString:@"正面"] ? @"1" : @"2",
                          @"moduleTubeColumn":@"12",
                          @"moduleTubeRow":@"1",
                          @"equName":_name,
                          @"moduleColumnQuantity":@"1"};
    
    return dic;
    
}

#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    float limit = 15;
    
    // 方块
    [_blockView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(limit)];
    [_blockView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:Vertical(limit)];
    [_blockView autoSetDimensionsToSize:CGSizeMake(Horizontal(3), Vertical(15))];
    
    // 标题
    
    [_baseTitle autoConstrainAttribute:ALAttributeHorizontal
                           toAttribute:ALAttributeHorizontal
                                ofView:_blockView
                        withMultiplier:1.0];
    
    [_baseTitle autoPinEdge:ALEdgeLeft
                     toEdge:ALEdgeRight
                     ofView:_blockView
                 withOffset:Horizontal(3)];
    
    // 关闭按钮
    [_guanbiBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(limit)];
    [_guanbiBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:Vertical(limit)];
    
    [_guanbiBtn autoConstrainAttribute:ALAttributeHorizontal
                           toAttribute:ALAttributeHorizontal
                                ofView:_blockView
                        withMultiplier:1.0];
    [_guanbiBtn autoSetDimensionsToSize:CGSizeMake(12, 12)];
    
    
    // tableview
    [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_blockView withOffset:limit];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:Vertical(70)];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    
    // 144
    [_btn144 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tableView withOffset:Vertical(limit)];
    [_btn144 autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(limit)];
    [_btn144 autoSetDimensionsToSize:CGSizeMake(Vertical(40), Vertical(40))];
    
    // 288
    [_btn288 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tableView withOffset:Vertical(limit)];
    [_btn288 autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_btn144 withOffset:Horizontal(10)];
    [_btn288 autoSetDimensionsToSize:CGSizeMake(Vertical(40), Vertical(40))];
    
    
    
    // 保存
    [_save autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:Vertical(limit)];
    [_save autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_btn288 withOffset:Horizontal(10)];
    [_save autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(limit)];
    
    [_save autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tableView withOffset:Vertical(limit)];
    
   
    
    
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
