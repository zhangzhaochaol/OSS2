//
//  Inc_CableMergeVC.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/14.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CableMergeVC.h"
//光缆段内容
#import "Inc_CableHeadView.h"
//光缆段列表 cell
#import "Inc_CableListCell.h"

//纵向合并提示view
#import "Inc_PortraitMergeTipView.h"
//横向合并提示view
#import "Inc_TransverseMergeTipView.h"


//http
#import "Inc_Cable_HttpModel.h"
#import "Yuan_CF_HttpModel.h"


@interface Inc_CableMergeVC ()<UITableViewDelegate,UITableViewDataSource>
{
    
    //纵向btn
    UIButton *_portraitBtn;
    //横向btn
    UIButton *_transverseBtn;
    
    //列表数据
    NSMutableArray *_sourceArray;
        
    //是否纵向
    BOOL _isPortrait;
    
    //实际纤芯数量
    int _pairCount;

    
}

//headview 光缆段内容
@property (nonatomic, strong) Inc_CableHeadView *cableHeadView;

//光缆段列表
@property (nonatomic, strong) UITableView *tableView;
//纵向合并提示view
@property (nonatomic, strong) Inc_PortraitMergeTipView *portraitMergeTipView;
//横向合并提示view
@property (nonatomic, strong) Inc_TransverseMergeTipView *transverseMergeTipView;

@end

@implementation Inc_CableMergeVC

-(Inc_CableHeadView *)cableHeadView {
    if (!_cableHeadView) {
        WEAK_SELF;
        _cableHeadView = [[Inc_CableHeadView alloc]initWithFrame:CGRectMake(0, NaviBarHeight, ScreenWidth, 150)];
        _cableHeadView.heightBlok = ^(CGFloat height) {
            
            wself.cableHeadView.frame = CGRectMake(0, NaviBarHeight, ScreenWidth, height);
            
            [wself updateFrame];
        };
                
    }
    return _cableHeadView;
}

-(Inc_PortraitMergeTipView *)portraitMergeTipView {
    
    if (!_portraitMergeTipView) {
        WEAK_SELF;
        _portraitMergeTipView = [[Inc_PortraitMergeTipView alloc]initWithFrame:CGRectNull];
        _portraitMergeTipView.btnClick = ^(UIButton * _Nonnull btn, NSDictionary * _Nonnull postDic) {

            if ([btn.titleLabel.text isEqualToString:@"确定"]) {
                
                [wself Http_UpdateOptSectMergeVer:postDic];
                
            }else{
                [wself hiddenWindow];
            }
        };
        

    }
    
    return _portraitMergeTipView;
}


-(Inc_TransverseMergeTipView *)transverseMergeTipView {
    
    if (!_transverseMergeTipView) {
        WEAK_SELF;
        _transverseMergeTipView = [[Inc_TransverseMergeTipView alloc]initWithFrame:CGRectNull];
        _transverseMergeTipView.btnClick = ^(UIButton * _Nonnull btn, NSDictionary * _Nonnull postDic) {

            if ([btn.titleLabel.text isEqualToString:@"确定"]) {
                
                [wself Http_UpdateOptSectMergeTra:postDic];

            }else{
                [wself hiddenWindow];
            }
        };

    }
    
    return _transverseMergeTipView;
}



#pragma mark -life

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isPortrait = YES;
    
    _sourceArray = NSMutableArray.array;
        
    self.view.backgroundColor = HexColor(@"#F3F3F3");
    
    [self.view addSubview:self.cableHeadView];
    
    [self createBtn];
    
    [self.view addSubview:self.tableView];
    _tableView.hidden = YES;
        

    [self.view addSubview:self.portraitMergeTipView];
    _portraitMergeTipView.hidden = YES;

    [self.view addSubview:self.transverseMergeTipView];
    _transverseMergeTipView.hidden = YES;
    
    
    [self Http_SelectPairBySectId:@{@"id":_mb_Dict[@"GID"]}];
    [self Http_lookPairBySectId:_mb_Dict[@"GID"] capacity:[_mb_Dict[@"capacity"] integerValue] isFirst:YES];
    [self autolayout];
}


-(UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, _portraitBtn.height + _portraitBtn.y + 10, ScreenWidth, ScreenHeight - _portraitBtn.y - _portraitBtn.height - 10)];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _tableView;
    
}

#pragma mark - tableViewDeleGate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _sourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"Inc_CableListCell";
    
    Inc_CableListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[Inc_CableListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.dic = _sourceArray[indexPath.row];
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return MAX(100, cell.frame.size.height);
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = _sourceArray[indexPath.row];
    
    _portraitMergeTipView.secendDic = dic;
    _transverseMergeTipView.secendDic = dic;

    if (!_isPortrait) {
        if (_pairCount != [dic[@"capacity"] intValue]) {
            [UIAlert alertSmallTitle:@"光缆段纤芯数量不匹配"];
               
            return;

        }
        
        if (_pairCount == 0 || [dic[@"capacity"] intValue] == 0) {
            
            [YuanHUD HUDFullText:@"纤芯未初始化，合并后实际纤芯数量为0"];
        }
    }
    
    [self Http_lookPairBySectId:dic[@"resId"] capacity:[_mb_Dict[@"capacity"] integerValue] isFirst:NO];

    
    [self showWindow];
}








#pragma mark - createBtn


//创建纵向/横向按钮
-(void)createBtn {
    
    NSString *leftTitle;
    NSString *rightTitle;
    
    NSString *leftName;
    NSString *rightname;
    
    leftTitle = @"纵向合并";
    rightTitle = @"横向合并";
    leftName = @"zzc_cable_prtait_merge_norml";
    rightname = @"zzc_cable_transverse_merge_norml";
    
    
    _portraitBtn = [UIView buttonWithTitle:leftTitle responder:self SEL:@selector(btnClick:) frame:CGRectMake(0, _cableHeadView.height + _cableHeadView.y + 10, ScreenWidth/2, Vertical(45))];
    [_portraitBtn setImage:[UIImage Inc_imageNamed:leftName] forState:UIControlStateNormal];
    [_portraitBtn setCornerRadius:0 borderColor:UIColor.clearColor borderWidth:1];
    [_portraitBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _portraitBtn.backgroundColor = UIColor.whiteColor;
    _portraitBtn.tag = 100100;
    
    _transverseBtn = [UIView buttonWithTitle:rightTitle responder:self SEL:@selector(btnClick:) frame:CGRectMake(ScreenWidth/2 + 1, _portraitBtn.y, _portraitBtn.width - 1, _portraitBtn.height)];
    [_transverseBtn setImage:[UIImage Inc_imageNamed:rightname] forState:UIControlStateNormal];
    
    [_transverseBtn setCornerRadius:0 borderColor:UIColor.clearColor borderWidth:1];
    [_transverseBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _transverseBtn.backgroundColor = UIColor.whiteColor;
    _transverseBtn.tag = 100101;
    
    
    [self.view addSubviews:@[_portraitBtn,_transverseBtn]];
    
}

-(void)updateFrame {
    
    _portraitBtn.frame = CGRectMake(0, _cableHeadView.height + _cableHeadView.y + 10, ScreenWidth/2, Vertical(45));
    _transverseBtn.frame = CGRectMake(ScreenWidth/2 + 1, _portraitBtn.y, _portraitBtn.width - 1, _portraitBtn.height);

    self.tableView.frame = CGRectMake (0, _portraitBtn.height + _portraitBtn.y + 10, ScreenWidth, ScreenHeight - _portraitBtn.y - _portraitBtn.height - 10);
    
}



#pragma mark -btnClick

- (void)btnClick:(UIButton *)btn {
    
    if (btn.tag == 100100) {
        
        _isPortrait = YES;
        
        
        [_portraitBtn setTitleColor:HexColor(@"#FF8080") forState:UIControlStateNormal];
        [_portraitBtn setCornerRadius:0 borderColor:HexColor(@"#FF8080") borderWidth:1];
        [_portraitBtn setImage:[UIImage Inc_imageNamed:@"zzc_cable_prtait_merge_select"] forState:UIControlStateNormal];
        
        [_transverseBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_transverseBtn setCornerRadius:0 borderColor:UIColor.clearColor borderWidth:1];
        [_transverseBtn setImage:[UIImage Inc_imageNamed:@"zzc_cable_transverse_merge_norml"] forState:UIControlStateNormal];
        
        
        [self Http_FindOptSectByBeginAndEnd:@{
            @"beginId":_mb_Dict[@"cableStart_Id"]?:@"",
            @"endId":_mb_Dict[@"cableEnd_Id"]?:@"",
            @"sectIdOld":_mb_Dict[@"GID"]?:@""
        }];
    }else if (btn.tag == 100101){
        
        _isPortrait = NO;
        
        [_transverseBtn setTitleColor:HexColor(@"#FF8080") forState:UIControlStateNormal];
        [_transverseBtn setCornerRadius:0 borderColor:HexColor(@"#FF8080") borderWidth:1];
        [_transverseBtn setImage:[UIImage Inc_imageNamed:@"zzc_cable_transverse_merge_select"] forState:UIControlStateNormal];
        
        [_portraitBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_portraitBtn setCornerRadius:0 borderColor:UIColor.clearColor borderWidth:1];
        [_portraitBtn setImage:[UIImage Inc_imageNamed:@"zzc_cable_prtait_merge_norml"] forState:UIControlStateNormal];
        
        [self Http_FindOptSectByBeginAndEndDif:@{
            @"beginId":_mb_Dict[@"cableStart_Id"]?:@"",
            @"endId":_mb_Dict[@"cableEnd_Id"]?:@""
        }];
        
    }
    
    _tableView.hidden = NO;

    
}


//隐藏
-(void)hiddenWindow {

       
    _portraitMergeTipView.hidden = YES;
    _transverseMergeTipView.hidden = YES;
    
}

//显示
-(void)showWindow {
    
    if (_isPortrait) {
        _portraitMergeTipView.hidden = NO;
        _transverseMergeTipView.hidden = YES;

    }else{
        _portraitMergeTipView.hidden = YES;
        _transverseMergeTipView.hidden = NO;
    }
    
}


-(void)autolayout {
    
    
    [_portraitMergeTipView YuanToSuper_Top:0];
    [_portraitMergeTipView YuanToSuper_Left:0];
    [_portraitMergeTipView YuanToSuper_Bottom:0];
    [_portraitMergeTipView YuanToSuper_Right:0];
    
    
    [_transverseMergeTipView YuanToSuper_Top:0];
    [_transverseMergeTipView YuanToSuper_Left:0];
    [_transverseMergeTipView YuanToSuper_Bottom:0];
    [_transverseMergeTipView YuanToSuper_Right:0];
    
    
}



#pragma mark -http

//光缆段下属纤芯 数量对比使用
- (void) Http_SelectPairBySectId:(NSDictionary *) param {
    
    [Inc_Cable_HttpModel Http_SelectPairBySectId:param success:^(id  _Nonnull result) {
        
        if (result) {
       
            NSArray *array = result;
            
            _pairCount = (int)array.count;
                        
            //查询纤芯真实数量 重新赋值使用
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_mb_Dict];
            [dict setValue:[NSString stringWithFormat:@"%d",_pairCount] forKey:@"capacity"];

            _cableHeadView.mb_Dict = dict;
            _portraitMergeTipView.firstDic = dict;
            _transverseMergeTipView.firstDic = dict;

        }
        
    }];
    
}

//纵向查询
- (void) Http_FindOptSectByBeginAndEnd:(NSDictionary *) param {
    
    [Inc_Cable_HttpModel Http_FindOptSectByBeginAndEnd:param success:^(id  _Nonnull result) {
        
        if (result) {
       
            NSLog(@"%@",result);
            
            NSArray *arr = result;
            
            [_sourceArray removeAllObjects];

            [_sourceArray addObjectsFromArray:arr];
            
            [self.tableView reloadData];
        }
        
    }];
    
}


//横向查询
- (void) Http_FindOptSectByBeginAndEndDif:(NSDictionary *) param {
    
    [Inc_Cable_HttpModel Http_FindOptSectByBeginAndEndDif:param success:^(id  _Nonnull result) {
        
        if (result) {
       
            NSLog(@"%@",result);
            
            NSArray *arr = result;
            
            [_sourceArray removeAllObjects];

            [_sourceArray addObjectsFromArray:arr];
            
            [self.tableView reloadData];
        }
        
    }];
    
}

//纵向合并接口
- (void) Http_UpdateOptSectMergeVer:(NSDictionary *) param {
    
    [Inc_Cable_HttpModel Http_UpdateOptSectMergeVer:param success:^(id  _Nonnull result) {
        
        if (result) {
            
            [self dismissVC];
        }
        
    }];
    
}

//横向合并接口
- (void) Http_UpdateOptSectMergeTra:(NSDictionary *) param {
   
    [Inc_Cable_HttpModel Http_UpdateOptSectMergeTra:param success:^(id  _Nonnull result) {
        
        if (result) {
            
            [self dismissVC];
        }
        
    }];
    
}

//光缆段下属纤芯序号 查看是否为1-count
- (void) Http_lookPairBySectId:(NSString *) cableId capacity:(NSInteger)capacity  isFirst:(BOOL)isFirst{
    
    [Yuan_CF_HttpModel Http_CableFilberListRequestWithCableId:cableId
                                                      Success:^(NSArray * _Nonnull data) {
        
        NSArray * dataArr = data;
        
        
        if (dataArr.count == 0) {
            return;
        }else {
            BOOL isOrder = YES;

            NSDictionary *dict = dataArr.lastObject;
            
            if (capacity != [dict[@"pairNo"] integerValue]) {
                isOrder = NO;
            }
            
            if (isFirst) {
                _portraitMergeTipView.isLeftOrder = isOrder;
                
            }else{
                _portraitMergeTipView.isRightOrder = isOrder;
            }
        }
    }];
    
    
}


//返回上上级 通知刷新
-(void)dismissVC {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cableSuccessful" object:nil];

    NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-2]animated:YES];
    
}
@end
