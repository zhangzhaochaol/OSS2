//
//  Inc_CableSplitVC.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/14.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CableSplitVC.h"

#import "ResourceTYKListViewController.h"

//光缆段内容
#import "Inc_CableHeadView.h"

//纵向拆分cell
#import "Inc_PoryraitSplitCell.h"
//横向拆分cell
#import "Inc_TranscerseSplitCell.h"

//地图
#import "Inc_CableMapView.h"

//http
#import "Inc_Cable_HttpModel.h"


@interface Inc_CableSplitVC ()<UITableViewDelegate,UITableViewDataSource>
{
    
    //纵向btn
    UIButton *_portraitBtn;
    //横向btn
    UIButton *_transverseBtn;
    
    //纵向列表数据
    NSMutableArray *_sourcePoryraitArray;
       
    //横向列表数据
    NSMutableArray *_sourceTranscersArray;
    
    //是否纵向
    BOOL _isPortrait;
    
    //白色背景 存放table
    UIView *_whiteBgView;
    //提示 纤芯数量超出/少于原纤芯数，请进行调整后保存
    UILabel *_tipLabel;
    //地图
    Inc_CableMapView *_mapView;
    
    //设备坐标数组
    NSMutableArray *_pointArr;
    
    
    //选择的设备类型 ODF_Equt：302   OCC_Equt：703  ODB_Equt：704   joint:705
    NSString *_eqpType;
    //选择的设备数据字典
    NSDictionary *_otherDic;
    
    //实际纤芯数量
    int _pairCount;

 

}

//headview 光缆段内容
@property (nonatomic, strong) Inc_CableHeadView *cableHeadView;

//列表
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation Inc_CableSplitVC


-(Inc_CableHeadView *)cableHeadView {
    if (!_cableHeadView) {
        WEAK_SELF;
        _cableHeadView = [[Inc_CableHeadView alloc]initWithFrame:CGRectMake(0, NaviBarHeight, ScreenWidth, 150)];
        _cableHeadView.heightBlok = ^(CGFloat height) {
            
            wself.cableHeadView.frame = CGRectMake(0, NaviBarHeight, ScreenWidth, height);
            
            [wself createBtn];
            
            [wself createWhiteView];
        };
    
    }
    return _cableHeadView;
}


#pragma mark -life

- (void)viewDidLoad {
    [super viewDidLoad];
        
    _isPortrait = YES;

    _sourcePoryraitArray = NSMutableArray.array;
    _sourceTranscersArray = NSMutableArray.array;
    _pointArr = NSMutableArray.array;
    
    
    [self Http_SelectPairBySectId:@{@"id":_mb_Dict[@"GID"]}];
    

    self.view.backgroundColor = HexColor(@"#F3F3F3");
    
    [self.view addSubview:self.cableHeadView];
    

        

}


-(UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, _tipLabel.y - 5) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColor.clearColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _tableView;
    
}

#pragma mark - tableViewDeleGate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isPortrait) {
        return _sourcePoryraitArray.count;

    }else{
        return _sourceTranscersArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isPortrait) {
        static NSString *cellIdentifier = @"Inc_PoryraitSplitCell";

        Inc_PoryraitSplitCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        if (cell == nil) {
            cell = [[Inc_PoryraitSplitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell setDataSource:_sourcePoryraitArray[indexPath.row] indexPath:indexPath.row];
        WEAK_SELF;
        cell.textFeildBlock = ^(NSString * _Nonnull text) {
            [wself sourceArrayUpdate:indexPath.row text:text];
        };
        cell.textViewBlock = ^(NSString * _Nonnull text) {
            [wself sourceArrayUpdateName:indexPath.row text:text];
        };
        
        return cell;
    }else{
        static NSString *cellIdentifier = @"Inc_TranscerseSplitCell";

        Inc_TranscerseSplitCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        if (cell == nil) {
            cell = [[Inc_TranscerseSplitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell setDataSource:_sourceTranscersArray[indexPath.row] indexPath:indexPath.row];
        WEAK_SELF;
        cell.textViewBlock = ^(NSString * _Nonnull text) {
            [wself sourceArrayUpdateName:indexPath.row text:text];
        };
        
        return cell;
        
    }
    
   
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (_isPortrait) {
        return 50;
    }
    
    return Vertical(140);
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [UIView viewWithColor:UIColor.whiteColor];
    
    if (_isPortrait) {
        footerView.frame = CGRectMake(0, 0, tableView.width, 50);
        
        UIButton *addBtn = [UIView buttonWithTitle:@"+ 添加光缆段" responder:self SEL:@selector(addCable) frame:CGRectMake(0, 0, footerView.width, footerView.height)];
        [addBtn setTitleColor:HexColor(@"#DD4B4A") forState:UIControlStateNormal];
        
        [footerView addSubview:addBtn];
    }else{
        footerView.frame = CGRectMake(0, 0, tableView.width, Vertical(140));
        WEAK_SELF;
        if (!_mapView) {
            _mapView = [[Inc_CableMapView alloc]initWithFrame:CGRectMake(10, 10, footerView.width - 20, footerView.height - 10)];
        }
        _mapView.btnBlock = ^{
            
            [wself showAlertAction];
            
        };
        _mapView.pointArr = _pointArr;
        
        [footerView addSubview:_mapView];
    }
   
    
    return footerView;
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_sourcePoryraitArray.count > 2 && _isPortrait) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [UIAlert alertSmallTitle:@"确认删除吗？" agreeBtnBlock:^(UIAlertAction *action) {
            [_sourcePoryraitArray removeObjectAtIndex:indexPath.row];
            [self isHiddenTipLabel];
            [_tableView reloadData];
        }];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isPortrait) {
        return UITableViewAutomaticDimension;
    }
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return MAX(100, cell.frame.size.height);
}

//底部view
-(void)createWhiteView {
    
    _whiteBgView = [UIView viewWithColor:UIColor.whiteColor];
    
    _whiteBgView.frame = CGRectMake(0, _portraitBtn.height + _portraitBtn.y + 10, ScreenWidth, ScreenHeight - _portraitBtn.y - _portraitBtn.height - 10);
    
    [self.view addSubview:_whiteBgView];
    

    
    UIButton *sureBtn = [UIView buttonWithTitle:@"确定" responder:self SEL:@selector(btnSaveClick:) frame:CGRectMake(15, _whiteBgView.height - 40 - 10, (_whiteBgView.width - 40)/2, 40)];
    [sureBtn setCornerRadius:4 borderColor:UIColor.clearColor borderWidth:1];
    [sureBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [sureBtn setBackgroundColor:HexColor(@"#DD4B4A")];
    
    UIButton *cancelBtn = [UIView buttonWithTitle:@"取消" responder:self SEL:@selector(btnSaveClick:) frame:CGRectMake(sureBtn.width +sureBtn.x + 10,sureBtn.y, sureBtn.width, sureBtn.height)];
    [cancelBtn setCornerRadius:4 borderColor:UIColor.clearColor borderWidth:1];
    [cancelBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:HexColor(@"#C3C3C3")];
    
    _tipLabel = [UIView labelWithTitle:@"纤芯数量超出/少于原纤芯数，请进行调整后保存" isZheH:YES];
    _tipLabel.frame = CGRectMake(0, sureBtn.y - 20, _whiteBgView.width, 20);
    _tipLabel.font = Font(11);
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.backgroundColor = UIColor.clearColor;
    _tipLabel.textColor = HexColor(@"#B2B1B1");
    _tipLabel.hidden = YES;

    
    [_whiteBgView addSubviews:@[sureBtn,cancelBtn,_tipLabel,self.tableView]];
    _whiteBgView.hidden = YES;
//    _tableView.hidden = YES;
    
}


#pragma mark - createBtn
//创建纵向/横向按钮
-(void)createBtn {
    
    NSString *leftTitle;
    NSString *rightTitle;
    NSString *leftName;
    NSString *rightname;
    

    leftTitle = @"纵向拆分";
    rightTitle = @"横向拆分";
    leftName = @"zzc_cable_prtait_split_norml";
    rightname = @"zzc_cable_transverse_split_norml";
    
    
    _portraitBtn = [UIView buttonWithTitle:leftTitle responder:self SEL:@selector(btnClick:) frame:CGRectMake(0, _cableHeadView.height + _cableHeadView.y + 10, ScreenWidth/2, Vertical(45))];
    [_portraitBtn setImage:[UIImage Inc_imageNamed:leftName] forState:UIControlStateNormal];
    [_portraitBtn setCornerRadius:0 borderColor:UIColor.clearColor borderWidth:1];
    [_portraitBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _portraitBtn.backgroundColor = UIColor.whiteColor;
    _portraitBtn.tag = 100100;
    _portraitBtn.adjustsImageWhenHighlighted = NO;
    
    _transverseBtn = [UIView buttonWithTitle:rightTitle responder:self SEL:@selector(btnClick:) frame:CGRectMake(ScreenWidth/2 + 1, _portraitBtn.y, _portraitBtn.width - 1, _portraitBtn.height)];
    [_transverseBtn setImage:[UIImage Inc_imageNamed:rightname] forState:UIControlStateNormal];
    
    [_transverseBtn setCornerRadius:0 borderColor:UIColor.clearColor borderWidth:1];
    [_transverseBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _transverseBtn.backgroundColor = UIColor.whiteColor;
    _transverseBtn.tag = 100101;
    _transverseBtn.adjustsImageWhenHighlighted = NO;

    
    [self.view addSubviews:@[_portraitBtn,_transverseBtn]];
    
}


#pragma mark -btnClick

- (void)btnClick:(UIButton *)btn {
        
    if (btn.tag == 100100) {
        
        if (_pairCount < 2) {
            
            [YuanHUD HUDFullText:@"纤芯数量过低，不可纵向拆分"];
            return;
        }
        
        if ([_mb_Dict[@"capacity"] integerValue] != _pairCount) {
            
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"请去光缆段详情修改纤芯总数为%d/重新初始化纤芯",_pairCount]];
            return;
        }
        
        
        _isPortrait = YES;

        [_portraitBtn setTitleColor:HexColor(@"#FF8080") forState:UIControlStateNormal];
        [_portraitBtn setCornerRadius:0 borderColor:HexColor(@"#FF8080") borderWidth:1];
        [_portraitBtn setImage:[UIImage Inc_imageNamed:@"zzc_cable_prtait_merge_select"] forState:UIControlStateNormal];
        
        [_transverseBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_transverseBtn setCornerRadius:0 borderColor:UIColor.clearColor borderWidth:1];
        [_transverseBtn setImage:[UIImage Inc_imageNamed:@"zzc_cable_transverse_merge_norml"] forState:UIControlStateNormal];
        
        [self isHiddenTipLabel];

        
    }else if (btn.tag == 100101){
        
        //防止连续点击刷新地图
        if (!_isPortrait) {
            return;
        }
        
        if (_pointArr.count < 2 || [_mb_Dict[@"cableStart"] isEmptyString] || [_mb_Dict[@"cableEnd"] isEmptyString]) {
            [YuanHUD HUDFullText:@"缺少起始/终止设施，不可横向拆分"];
            return;
        }
                
        _isPortrait = NO;
        _tipLabel.hidden = YES;
        
        [_transverseBtn setTitleColor:HexColor(@"#FF8080") forState:UIControlStateNormal];
        [_transverseBtn setCornerRadius:0 borderColor:HexColor(@"#FF8080") borderWidth:1];
        [_transverseBtn setImage:[UIImage Inc_imageNamed:@"zzc_cable_transverse_merge_select"] forState:UIControlStateNormal];

        [_portraitBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_portraitBtn setCornerRadius:0 borderColor:UIColor.clearColor borderWidth:1];
        [_portraitBtn setImage:[UIImage Inc_imageNamed:@"zzc_cable_prtait_merge_norml"] forState:UIControlStateNormal];
        
    }
    _whiteBgView.hidden = NO;

    [_tableView reloadData];

}

-(void)canCelDiss {
    
    _isPortrait = YES;

    //清除数据
    [_sourcePoryraitArray removeAllObjects];
    [_sourceTranscersArray removeAllObjects];
    [_pointArr removeAllObjects];
    
    [self setUpDataSource];
    
    _tipLabel.hidden = YES;
    _whiteBgView.hidden = YES;

    [_portraitBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [_portraitBtn setCornerRadius:0 borderColor:UIColor.clearColor borderWidth:1];
    [_portraitBtn setImage:[UIImage Inc_imageNamed:@"zzc_cable_prtait_merge_norml"] forState:UIControlStateNormal];
    
    [_transverseBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [_transverseBtn setCornerRadius:0 borderColor:UIColor.clearColor borderWidth:1];
    [_transverseBtn setImage:[UIImage Inc_imageNamed:@"zzc_cable_transverse_merge_norml"] forState:UIControlStateNormal];
}


//确定保存/取消
-(void)btnSaveClick:(UIButton *)btn {
    
    if ([btn.titleLabel.text isEqualToString:@"取消"]) {
        [self canCelDiss];
    }else{
        if (_isPortrait) {
            [self verticalSplit];
        }else{
            [self horizontalSplit];
        }
    }
    
}

//纵向拆分接口数据
-(void)verticalSplit {
    
    NSMutableArray *list = [NSMutableArray array];
    NSMutableArray *nameArr = [NSMutableArray array];

    for (NSDictionary *dic in _sourcePoryraitArray) {
        
        if ([dic[@"cableName"] isEmptyString]) {
            [YuanHUD HUDFullText:@"光缆段名称不能为空"];
            return;
        }

        NSDictionary *dict = @{
            @"sectName":dic[@"cableName"],
            @"capacity":dic[@"capacity"]
        };
        [nameArr addObject:dic[@"cableName"]];
        [list addObject:dict];
        
    }
    
    NSSet *set = [NSSet setWithArray:nameArr];
    NSLog(@"[dic allValues] %@",[set allObjects]);

    if (set.count != _sourcePoryraitArray.count) {
        
        [YuanHUD HUDFullText:@"光缆段名称不可重复"];
        return;
    }
    
    if (!_tipLabel.hidden) {
        
        [YuanHUD HUDFullText:@"纤芯数量不等于原纤芯数，调整后保存"];
        return;
    }
    
    [self Http_UpdateOptSectSplitVer:@{
        @"sectId":_mb_Dict[@"GID"],
        @"capacity":[NSString stringWithFormat:@"%d",_pairCount],
        @"list":list
    }];
    
}
//横向拆分接口数据
-(void)horizontalSplit{
    
    NSMutableArray *list = [NSMutableArray array];
    NSMutableArray *nameArr = [NSMutableArray array];

    for (NSDictionary *dic in _sourceTranscersArray) {
        
        if ([dic[@"cableSectionLength"] isEmptyString] || [dic[@"cableStart"] isEmptyString] || [dic[@"cableEnd"] isEmptyString]) {
            [YuanHUD HUDFullText:@"请选择设备"];
            return;
        }
        
        if ([dic[@"cableName"] isEmptyString]) {
            [YuanHUD HUDFullText:@"光缆段名称不能为空"];
            return;
        }

        //cableStart_Id   cableEnd_Id
        NSDictionary *dict = @{
            @"sectName":dic[@"cableName"],
            @"beginId":dic[@"cableStart_Id"],
            @"endId":dic[@"cableEnd_Id"],
            @"length":dic[@"cableSectionLength"]
        };
        [nameArr addObject:dic[@"cableName"]];
        [list addObject:dict];
        
    }
    
    NSSet *set = [NSSet setWithArray:nameArr];
    NSLog(@"[dic allValues] %@",[set allObjects]);

    if (set.count != _sourceTranscersArray.count) {
        
        [YuanHUD HUDFullText:@"光缆段名称不可重复"];
        return;
    }
    
    NSDictionary *dicA = _sourceTranscersArray.firstObject;
    NSDictionary *dicB = _sourceTranscersArray.lastObject;

    [self Http_UpdateOptSectSplitTra:@{
        @"sectId":_mb_Dict[@"GID"],
        @"type":[self getType:_eqpType],
        @"midLon":_otherDic[@"lon"],
        @"midLat":_otherDic[@"lat"],

        @"sectNameA":dicA[@"cableName"],
        @"lengthA":[NSString stringWithFormat:@"%.2f",[dicA[@"cableSectionLength"] floatValue] * 1000],
        @"beginIdA":dicA[@"cableStart_Id"],
        @"endIdA":dicA[@"cableEnd_Id"],
        @"sectNameB":dicB[@"cableName"],
        @"lengthB":[NSString stringWithFormat:@"%.2f",[dicB[@"cableSectionLength"] floatValue] * 1000],
        @"beginIdB":dicB[@"cableStart_Id"],
        @"endIdB":dicB[@"cableEnd_Id"]

    }];
    
    
}



//纤芯回调数据处理
-(void)sourceArrayUpdate:(NSInteger)index text:(NSString *)text{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:_sourcePoryraitArray[index]];
    
    [dic setObject:text forKey:@"capacity"];
    
    [_sourcePoryraitArray replaceObjectAtIndex:index withObject:dic];
    
    
    [self isHiddenTipLabel];
    
}

//根据原光缆段，拆分所需要数据
-(void)setUpDataSource {
    
    [_sourcePoryraitArray addObjectsFromArray:@[

        @{@"cableName":_mb_Dict[@"cableName"],@"capacity":[NSString stringWithFormat:@"%d",[_mb_Dict[@"capacity"] intValue]/2]},
        @{@"cableName":_mb_Dict[@"cableName"],@"capacity":[NSString stringWithFormat:@"%d",[_mb_Dict[@"capacity"] intValue] - [_mb_Dict[@"capacity"] intValue]/2]}

    ]];

    [_sourceTranscersArray addObjectsFromArray:@[

        @{@"cableName":_mb_Dict[@"cableName"],@"cableStart":_mb_Dict[@"cableStart"]?:@"",@"cableEnd":@"",@"cableSectionLength":@"",@"cableStart_Id":_mb_Dict[@"cableStart_Id"]?:@"",@"cableEnd_Id":@""},
        @{@"cableName":_mb_Dict[@"cableName"],@"cableStart":@"",@"cableEnd":_mb_Dict[@"cableEnd"]?:@"",@"cableSectionLength":@"",@"cableStart_Id":@"",@"cableEnd_Id":_mb_Dict[@"cableEnd_Id"]?:@""}

    ]];
    
//    //获取起始设施位置
//    [self getCableStartDic];
//    //获取终止设施位置
//    [self getCableEndDic];
    
    
    //根据光缆段id或者对应起始、终止设施位置信息
    [self Http_getOptSectLonLatInfo:@{@"id":_mb_Dict[@"GID"]}];

    
}

//名称回调数据处理
-(void)sourceArrayUpdateName:(NSInteger)index text:(NSString *)text{
    
    if (_isPortrait) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:_sourcePoryraitArray[index]];
        
        [dic setObject:text forKey:@"cableName"];
        
        [_sourcePoryraitArray replaceObjectAtIndex:index withObject:dic];
        
        
        [self isHiddenTipLabel];
    }else{
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:_sourceTranscersArray[index]];
        
        [dic setObject:text forKey:@"cableName"];
        
        [_sourceTranscersArray replaceObjectAtIndex:index withObject:dic];
        
    }
  
    
}


//添加一条数据
- (void)addCable {
    
    [_sourcePoryraitArray addObject:@{@"cableName":_mb_Dict[@"cableName"],@"capacity":[NSString stringWithFormat:@"%d",[_mb_Dict[@"capacity"] intValue]/2]}];

    [self isHiddenTipLabel];

    [_tableView reloadData];
}


//遍历判断是否显示提示
-(void)isHiddenTipLabel {
    
    int pairNum = 0;

    for (NSDictionary *dict in _sourcePoryraitArray) {

        pairNum += [dict[@"capacity"] intValue];

    }

    //判断修改后的纤芯总数是否和原纤芯数量相等 不想等提示显示
    if (pairNum != [_mb_Dict[@"capacity"] intValue]) {
        _tipLabel.hidden = NO;
    }else{
        _tipLabel.hidden = YES;
    }
}




///地图选择按钮点击弹窗
-(void)showAlertAction {
    
    UIAlertController *alertController = [[UIAlertController alloc]init];
    // Create the actions.
    UIAlertAction *odfAction = [UIAlertAction actionWithTitle:@"ODF"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
        
        [self pushResourceTYKListViewController:@"ODF_Equt" showName:@"ODF"];
    }];
    
    
    UIAlertAction *occAction = [UIAlertAction actionWithTitle:@"光交接箱"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
        [self pushResourceTYKListViewController:@"OCC_Equt" showName:@"光交接箱"];

    }];
    
    UIAlertAction *jointAction = [UIAlertAction actionWithTitle:@"光缆接头"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
        [self pushResourceTYKListViewController:@"joint" showName:@"光缆接头"];

    }];
    
    UIAlertAction *odbAction = [UIAlertAction actionWithTitle:@"光分纤箱和光终端盒"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
        [self pushResourceTYKListViewController:@"ODB_Equt" showName:@"光分纤盒和光终端盒"];

    }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //什么也不做
    }];
    
    
    // Add the actions.
    [alertController addAction:odfAction];
    [alertController addAction:occAction];
    [alertController addAction:jointAction];
    [alertController addAction:odbAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


//设备列表
-(void)pushResourceTYKListViewController:(NSString *)fileName  showName:(NSString *)showName{
    
    
     
    ResourceTYKListViewController * resourceTYKListVC = [[ResourceTYKListViewController alloc] init];
    resourceTYKListVC.fileName = fileName;
    resourceTYKListVC.showName = showName;
    resourceTYKListVC.facilitiesBlock = ^(NSDictionary *dic) {
        NSLog(@"%@",dic.json);
        
        NSString *equtName;
        NSString *equtId = dic[@"GID"];
        
        _eqpType = dic[@"resLogicName"];
        
        if ([fileName isEqualToString:@"ODF_Equt"]) {
            equtName = dic[@"rackName"];
//            equtId = dic[@"ODF_EqutId"];
            
        }else if ([fileName isEqualToString:@"OCC_Equt"]){
            equtName = dic[@"occName"];
//            equtId = dic[@"OCC_EqutId"];
            
        }else if ([fileName isEqualToString:@"joint"]){
            equtName = dic[@"jointName"];
//            equtId = dic[@"jointId"];
            
        }else if ([fileName isEqualToString:@"ODB_Equt"]){
            equtName = dic[@"odbName"];
//            equtId = dic[@"ODB_EqutId"];
            
        }
        //将获取的设备给分开的两天光缆段设定为第一条的终止设施和第二条的起始设施
        for (int i = 0; i<_sourceTranscersArray.count; i++) {
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:_sourceTranscersArray[i]];
            
            if (i == 0) {
                [dic setObject:equtName forKey:@"cableEnd"];
                [dic setObject:equtId forKey:@"cableEnd_Id"];
                [_sourceTranscersArray replaceObjectAtIndex:i withObject:dic];
            }else{
                [dic setObject:equtName forKey:@"cableStart"];
                [dic setObject:equtId forKey:@"cableStart_Id"];
                [_sourceTranscersArray replaceObjectAtIndex:i withObject:dic];
            }
            
        }
        
        //odf 通过设备放置点获取坐标
        if ([fileName isEqualToString:@"ODF_Equt"]) {
            
            NSString *type;
            if ([dic[@"posit_Type"] intValue] == 1) {
                type = @"6";
            }else if([dic[@"posit_Type"] intValue] == 2){
                type = @"8";
            }
                        
            [self GetDetailWithGID:dic[@"posit_Id"]?:@"" resLogicName:[self getReslogName:type] block:^(NSDictionary *dict) {
                if ([dict[@"lon"] floatValue] == 0 && [dict[@"lat"] floatValue] == 0) {
                    [UIAlert alertSmallTitle:@"请完善选择设备的经纬度信息"];
                    return;
                }
                
                NSMutableDictionary *dicf = [[NSMutableDictionary alloc]initWithDictionary:dict];
                [dicf setObject:@"other" forKey:@"facilitiesState"];
                
                BOOL isOther = false;
                
                for (NSDictionary *dic in _pointArr) {
                    
                    if ([dic[@"facilitiesState"] isEqualToString:@"other"]) {
                        isOther = YES;
                    }
                    
                }
                
                if (isOther) {
                    [_pointArr replaceObjectAtIndex:_pointArr.count -1 withObject:dicf];
                    
                }else{
                    [_pointArr addObject:dicf];
                }
                [self updateDataSource];
                [_tableView reloadData];
            }];
        }else{
            if ([dic[@"lon"] floatValue] == 0 && [dic[@"lat"] floatValue] == 0) {
                [UIAlert alertSmallTitle:@"请完善选择设备的经纬度信息"];
                return;
            }else{
                
                NSMutableDictionary *dicf = [[NSMutableDictionary alloc]initWithDictionary:dic];
                [dicf setObject:@"other" forKey:@"facilitiesState"];
                
                BOOL isOther = false;
                
                for (NSDictionary *dic in _pointArr) {
                    
                    if ([dic[@"facilitiesState"] isEqualToString:@"other"]) {
                        isOther = YES;
                    }
                    
                }
                
                if (isOther) {
                    [_pointArr replaceObjectAtIndex:_pointArr.count -1 withObject:dicf];
                }else{
                    [_pointArr addObject:dicf];
                }
                
            }
            [self updateDataSource];

            [_tableView reloadData];
        }
        
    };
    [self.navigationController pushViewController:resourceTYKListVC animated:YES];
    
}

//起始设施详细 使用定位
-(void)getCableStartDic {
    
    [self GetDetailWithGID:_mb_Dict[@"cableStart_Id"]?:@"" resLogicName:[self getReslogName:_mb_Dict[@"cableStart_Type"]?:@""] block:^(NSDictionary *dict) {
        
        //odf需通过放置点获取位置
        if ([dict[@"resLogicName"] isEqualToString:@"ODF_Equt"]) {
            
            if ([dict[@"posit"] isEmptyString]) {
                [UIAlert alertSmallTitle:@"起始设施ODF没有填写放置点"];
                return;
            }
            NSString *type;
            if ([dict[@"posit_Type"] intValue] == 1) {
                type = @"6";
            }else if([dict[@"posit_Type"] intValue] == 2){
                type = @"8";
            }
            
            [self GetDetailWithGID:dict[@"posit_Id"]?:@"" resLogicName:[self getReslogName:type] block:^(NSDictionary *dict) {
                
                NSMutableDictionary *dicf = [[NSMutableDictionary alloc]initWithDictionary:dict];
                [dicf setObject:@"start" forKey:@"facilitiesState"];
                
                [_pointArr addObject:dicf];
                
            }];
            //光缆接头需通过支撑设施获取位置
        }else if ([dict[@"resLogicName"] isEqualToString:@"joint"]){
            
            if ([dict[@"jointName"] isEmptyString]) {
                [UIAlert alertSmallTitle:@"终止设施光缆接头没有填写支撑设施"];
                return;
            }
            
            [self GetDetailWithGID:dict[@"jointId"]?:@"" resLogicName:@"joint" block:^(NSDictionary *dict) {
                
                NSMutableDictionary *dicf = [[NSMutableDictionary alloc]initWithDictionary:dict];
                [dicf setObject:@"start" forKey:@"facilitiesState"];
                
                [_pointArr addObject:dicf];
                
            }];
            
            //其它设施
        }else{
            
            NSMutableDictionary *dicf = [[NSMutableDictionary alloc]initWithDictionary:dict];
            [dicf setObject:@"start" forKey:@"facilitiesState"];
            
            [_pointArr addObject:dicf];
            
        }
        
    }];
    
}
//终止设施详细 使用定位
-(void)getCableEndDic {
    
    [self GetDetailWithGID:_mb_Dict[@"cableEnd_Id"]?:@"" resLogicName:[self getReslogName:_mb_Dict[@"cableEnd_Type"]?:@""] block:^(NSDictionary *dict) {
       
        //odf需通过放置点获取位置
        if ([dict[@"resLogicName"] isEqualToString:@"ODF_Equt"]) {
            
            if ([dict[@"posit"] isEmptyString]) {
                [UIAlert alertSmallTitle:@"终止设施ODF没有填写放置点"];
                return;
            }
            
            NSString *type;
            if ([dict[@"posit_Type"] intValue] == 1) {
                type = @"6";
            }else if([dict[@"posit_Type"] intValue] == 2){
                type = @"8";
            }
            
            [self GetDetailWithGID:dict[@"posit_Id"]?:@"" resLogicName:[self getReslogName:type] block:^(NSDictionary *dict) {
                
                
                NSMutableDictionary *dicf = [[NSMutableDictionary alloc]initWithDictionary:dict];
                [dicf setObject:@"end" forKey:@"facilitiesState"];
                
                [_pointArr addObject:dicf];
                
            }];
            //光缆接头需通过支撑设施获取位置
        }else if ([dict[@"resLogicName"] isEqualToString:@"joint"]){
            
            if ([dict[@"jointSupport"] isEmptyString]) {
                [UIAlert alertSmallTitle:@"终止设施光缆接头没有填写支撑设施"];
                return;
            }
            
            [self GetDetailWithGID:dict[@"jointId"]?:@"" resLogicName:dict[@"resLogicName"] block:^(NSDictionary *dict) {
                
                NSMutableDictionary *dicf = [[NSMutableDictionary alloc]initWithDictionary:dict];
                [dicf setObject:@"end" forKey:@"facilitiesState"];
                
                [_pointArr addObject:dicf];
                
            }];
            
            //其它设施
        }else{
            
            NSMutableDictionary *dicf = [[NSMutableDictionary alloc]initWithDictionary:dict];
            [dicf setObject:@"end" forKey:@"facilitiesState"];
            
            [_pointArr addObject:dicf];

        }
    }];

}

#pragma mark -http
// 根据 Gid 和 reslogicName 获取 详细信息
- (void) GetDetailWithGID:(NSString *)GID  resLogicName:(NSString *)resLogicName
                    block:(void(^)(NSDictionary * dict))block{
    
    if ([GID isEmptyString]) {
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少必要的GID"];
        return;
    }
    
    NSDictionary * dict = @{
        @"resLogicName" : resLogicName,
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


//光缆段起始终止设施 type转 resLogicName
-(NSString *)getReslogName:(NSString *)type {
    
    NSString * resLogicName;
    
    switch ([type intValue]) {
        case 1:
            resLogicName = @"ODF_Equt";
            break;
        case 2:
            resLogicName = @"joint";
            break;
        case 3:
            resLogicName = @"OCC_Equt";
            break;
        case 4:
            resLogicName = @"ODB_Equt";
            break;
        case 6:
            resLogicName = @"generator";
            break;
        case 8:
            resLogicName = @"EquipmentPoint";
            break;
            
        default:
            resLogicName = @"";
            break;
    }
    
    return resLogicName;
    
}

//计算新的光缆段长度
-(void)updateDataSource {
    
    NSDictionary *startDic;
    NSDictionary *endDic;

    for (NSDictionary *dic in _pointArr) {
        
        if ([dic[@"facilitiesState"] isEqualToString:@"start"]) {
            startDic = dic;
        }else if ([dic[@"facilitiesState"] isEqualToString:@"end"]){
            endDic = dic;
        }else if ([dic[@"facilitiesState"] isEqualToString:@"other"]){
            _otherDic = dic;
        }
    }
    
    //起始和选择的设备为第一条光缆
    if ([startDic[@"lat"] doubleValue] > 0) {
        
        CGFloat firstLenth = [self calculateDistanceStart:[[CLLocation alloc] initWithLatitude:[startDic[@"lat"] doubleValue] longitude:[startDic[@"lon"] doubleValue]] end:[[CLLocation alloc] initWithLatitude:[_otherDic[@"lat"] doubleValue] longitude:[_otherDic[@"lon"] doubleValue]]];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:_sourceTranscersArray[0]];
        
        [dic setObject:[NSString stringWithFormat:@"%.2f",firstLenth/1000] forKey:@"cableSectionLength"];

        [_sourceTranscersArray replaceObjectAtIndex:0 withObject:dic];
    }

    //选择的设备和终止设备为第二条光缆
    if ([endDic[@"lat"] doubleValue] > 0) {
        
        CGFloat secendLenth = [self calculateDistanceStart:[[CLLocation alloc] initWithLatitude:[_otherDic[@"lat"] doubleValue] longitude:[_otherDic[@"lon"] doubleValue]] end:[[CLLocation alloc] initWithLatitude:[endDic[@"lat"] doubleValue] longitude:[endDic[@"lon"] doubleValue]]];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:_sourceTranscersArray[1]];
        
        [dic setObject:[NSString stringWithFormat:@"%.2f",secendLenth/1000] forKey:@"cableSectionLength"];
        
        [_sourceTranscersArray replaceObjectAtIndex:1 withObject:dic];

    }

    
    

}

//计算两点距离
-(CGFloat)calculateDistanceStart:(CLLocation *)start end:(CLLocation*)end {

    // 计算距离

    CLLocationDistance meters=[start distanceFromLocation:end];
 
    return meters;
}



#pragma mark -http

///根据光缆段id获取光缆段信息和起始终止设施经纬度
- (void) Http_getOptSectLonLatInfo:(NSDictionary *) param {
    
    [Inc_Cable_HttpModel Http_getOptSectLonLatInfo:param success:^(id  _Nonnull result) {
        
        if (result) {
       
            NSDictionary *dict = result;
            
            NSLog(@"%@",dict.json);
            
            
            if ([dict[@"beginLat"] floatValue] > 0 && [dict[@"beginLon"] floatValue] > 0) {
                
                NSDictionary *dicStart = @{
                    @"facilitiesState":@"start",
                    @"lat":dict[@"beginLat"],
                    @"lon":dict[@"beginLon"]
                };
                
                [_pointArr addObject:dicStart];
            }
            
            
            if ([dict[@"endLat"] floatValue] > 0 && [dict[@"endLon"] floatValue] > 0) {
                NSDictionary *dicEnd = @{
                    @"facilitiesState":@"end",
                    @"lat":dict[@"endLat"],
                    @"lon":dict[@"endLon"]
                };

                [_pointArr addObject:dicEnd];

            }
            
            
            
        }
        
    }];
    
}

//光缆段下属纤芯 数量对比使用
- (void) Http_SelectPairBySectId:(NSDictionary *) param {
    
    [Inc_Cable_HttpModel Http_SelectPairBySectId:param success:^(id  _Nonnull result) {
        
        if (result) {
       
            NSArray *array = result;
            
            _pairCount = (int)array.count;
            

            //查询纤芯真实数量 重新赋值
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_mb_Dict];
            [dict setValue:[NSString stringWithFormat:@"%d",_pairCount] forKey:@"capacity"];

            _mb_Dict = dict;
            
            _cableHeadView.mb_Dict = _mb_Dict;

            [self setUpDataSource];

        }
        
    }];
    
}


//纵向
- (void) Http_UpdateOptSectSplitVer:(NSDictionary *) param {
    
    [Inc_Cable_HttpModel Http_UpdateOptSectSplitVer:param success:^(id  _Nonnull result) {
        
        if (result) {
       
            [self canCelDiss];
            [self dismissVC];
        }
        
    }];
}


//横向
- (void) Http_UpdateOptSectSplitTra:(NSDictionary *) param {
    
    [Inc_Cable_HttpModel Http_UpdateOptSectSplitTra:param success:^(id  _Nonnull result) {
        
        if (result) {
       
            [self canCelDiss];
            [self dismissVC];
        }
        
    }];
}


//转换类型
-(NSString *)getType:(NSString *)relogName {
    
    NSString *type;
    if ([relogName isEqualToString:@"ODF_Equt"]) {
        type = @"302";
    }else if ([relogName isEqualToString:@"OCC_Equt"]) {
        type = @"703";
    }else if ([relogName isEqualToString:@"ODB_Equt"]) {
        type = @"704";
    }else if ([relogName isEqualToString:@"joint"]){
        type = @"705";
    }
    
    return type;
}


//返回上上级 通知刷新
-(void)dismissVC {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cableSuccessful" object:nil];

    NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-2]animated:YES];
    
}
    
@end
