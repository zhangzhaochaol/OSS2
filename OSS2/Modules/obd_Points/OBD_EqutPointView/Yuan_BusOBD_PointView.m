//
//  Yuan_BusOBD_PointView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_BusOBD_PointView.h"

#import "Inc_Push_MB.h"

#import "Yuan_BlockLabelView.h"
#import "Yuan_BusOBD_PointItem.h"

#import "Inc_NewMB_HttpModel.h"


@interface Yuan_BusOBD_PointView ()

<
    UICollectionViewDelegate ,
    UICollectionViewDataSource
>

@end

@implementation Yuan_BusOBD_PointView

{
    
    Yuan_BlockLabelView * _blockView;
    
    UILabel * _input;
    UILabel * _outPut;

    
    UIView * _inputBackView;
    UIView * _outPutBackView;
    
    // 输入是1一个
    UIButton * _inputBtn;
    UIImageView * _inputSympol;
    // 输出是一堆
    UICollectionView * _collection;
    
    
    // 输入输出数据源 -- 通常来讲 是输入为1 , 输出为 8 的倍数
    NSMutableArray * _outPut_DataSource;
    NSDictionary * _inPut_DataSource;
    
    
    float _item_Width;
    
    
    // 上级OBD的resId
    NSString * _OBD_Id;
    
    NSMutableSet * _itemsArr;
    
    // 当前选中的是哪个 , 为了重新定位
    NSIndexPath * _nowSelectIndex;
    
}


#pragma mark - 初始化构造方法

- (instancetype)initWithSuperResId:(NSString *) superResId {
    
    if (self = [super init]) {
        
        _OBD_Id = superResId;
        
        float limit = Horizontal(10);
        _item_Width = (ScreenWidth - limit * 5 - Horizontal(50)) / 8;
        
        _OBD_ItemsArr = NSMutableArray.array;
        
        [self UI_Init];
        
        [self Http_SelectPorts];
        
        _itemsArr = NSMutableSet.set;
        
        _nowSelectIndex = nil;
    }
    return self;
}





#pragma mark - Http ---

- (void) Http_SelectPorts {
    
    
    if (!_OBD_Id) {
        [YuanHUD HUDFullText:@"缺少 obd_id"];
        return;
    }
    
    
    _outPut_DataSource = NSMutableArray.array;
    
    
    Inc_NewMB_HttpPort * port =  [Inc_NewMB_HttpPort ModelEnum:Yuan_NewMB_ModelEnum_obdPort];
    
    NSDictionary * dict = @{@"id" : _OBD_Id , @"type" : @"port"};
    
    [Inc_NewMB_HttpModel HTTP_NewMB_SelectDetailsFromOBD_PortWithURL:port.SelectFrom_IdType
                                                                Dict:dict
                                                             success:^(id  _Nonnull result) {
                
        
        // 输入是310 输出是2532  resTypeId
        
        NSArray * res_Arr = result;
        
        if (res_Arr.count == 0) {
            
            
            [UIAlert alertSingle_SmallTitle:@"初始化端子"
                              agreeBtnBlock:^(UIAlertAction *action) {
               
                if (_uninitialized_PointBlock) {
                    _uninitialized_PointBlock();
                }
            }];
            
            return;
        }
        
        
        for (NSDictionary * port_Dict in res_Arr) {
            
            NSString * resTypeId = port_Dict[@"resTypeId"];
            
            // 输入
            if ([resTypeId isEqualToString:@"310"]) {
                _inPut_DataSource = port_Dict;
            }
            
            // 输出
            else {
                
                [_outPut_DataSource addObject:port_Dict];
            }

        }
        
        [self reload_UIs];
        
    }];
    
}



- (void) reload_UIs {

    
    NSString * oprStateId = _inPut_DataSource[@"oprStateId"];
    NSString * portName = _inPut_DataSource[@"name"];
    NSString * OBDName = _inPut_DataSource[@"superResName"];
    
    NSString * position = [portName stringByReplacingOccurrencesOfString:OBDName withString:@""];
    
    if ([position containsString:@"/"]) {
        position = [position stringByReplacingOccurrencesOfString:@"/" withString:@""];
    }
    
    position = [NSString stringWithFormat:@"%d",position.intValue];
    
    
    
    [_inputBtn setTitle:position forState:UIControlStateNormal];
    
    switch (oprStateId.intValue) {
        case 170002:     //预占
        case 170005:     //预释放
        case 170007:     //预留
        case 170014:     //预选
        case 170015:     //备用
        case 170046:    //测试
        case 170187:    //临时占用
            
            _inputBtn.backgroundColor = ColorR_G_B(252, 160, 0);
            [_inputBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            break;
        
        case 170003:     //占用
        
            
            _inputBtn.backgroundColor = ColorR_G_B(147, 222, 113);
            [_inputBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            break;
        
        case 160014:     //停用
        case 170147:    //损坏
            
            _inputBtn.backgroundColor = ColorR_G_B(255, 0, 44);
            [_inputBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];

            break;
            
        default:    //1.空闲 9.闲置
            
            _inputBtn.backgroundColor = ColorR_G_B(232, 232, 232);
            [_inputBtn setTitleColor:ColorValue_RGB(0x929292) forState:UIControlStateNormal];
            break;
    }
    
    
    // 外部会用
    _outPutDatas = _outPut_DataSource;
    _inPutDatas = _inPut_DataSource;
    
    [_collection reloadData];
    
}



#pragma mark - Click ---

// 输入按钮 点击
- (void) inputBtnClick {
        
    if (_pointEnum == BusOBD_PointView_Select) {
        
        Inc_NewMB_DetailVC * new_MB =
        [[Inc_NewMB_DetailVC alloc] initWithDict:_inPut_DataSource
                            Yuan_NewMB_ModelEnum:Yuan_NewMB_ModelEnum_rmePort];
        Push(_vc, new_MB);
        
        
        // 保存后的刷新界面
        new_MB.saveBlock = ^(NSDictionary * _Nonnull saveDict) {
          
            _inPut_DataSource = saveDict;
            [self reload_UIs];
        };
    }
    
    else {
        
        if (self.delegate != NULL &&
            [self.delegate respondsToSelector:@selector(Yuan_BusOBDSelect_inputItem_DataSource:btn:)]) {
            
            [self.delegate Yuan_BusOBDSelect_inputItem_DataSource:_inPut_DataSource
                                                              btn:_inputBtn];
        }
    }
}


// item 点击
- (void)    collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSDictionary * item_Dict = _outPut_DataSource[indexPath.row];
    
    
    // 绑定
    if (_pointEnum == BusOBD_PointView_Bind) {
        
        _nowSelectIndex = indexPath;
        
        Yuan_BusOBD_PointItem * item =
        (Yuan_BusOBD_PointItem *)[collectionView cellForItemAtIndexPath:indexPath];
        
        if (self.delegate != NULL &&
            [self.delegate respondsToSelector:@selector(Yuan_BusOBDSelect_outPut_nowSelectItem:
                                                        index:
                                                        datas:)]) {
            
            [self.delegate Yuan_BusOBDSelect_outPut_nowSelectItem:item
                                                            index:indexPath
                                                            datas:_outPut_DataSource];
            
        }
    }
    
    // 端子查看
    else {
        
        Inc_NewMB_DetailVC * new_MB =
        [[Inc_NewMB_DetailVC alloc] initWithDict:item_Dict
                            Yuan_NewMB_ModelEnum:Yuan_NewMB_ModelEnum_obdPort];
        
        Push(_vc, new_MB);
        
        
        // 保存后的刷新界面
        new_MB.saveBlock = ^(NSDictionary * _Nonnull saveDict) {
          
            [_outPut_DataSource replaceObjectAtIndex:indexPath.row withObject:saveDict];
            [_collection reloadData];
        };
    }
}




// 输出长按解绑
- (void) outPutItems_LongPress:(NSDictionary *) outPutDict {
    
    // 绑定
    if (_pointEnum == BusOBD_PointView_Bind) {
     
        [UIAlert alertSmallTitle:@"是否解绑?"
                   agreeBtnBlock:^(UIAlertAction *action) {
                   
            if (_disConnect_ShipBlock) {
                _disConnect_ShipBlock(outPutDict);
            }
        }];
    }
}


// 输入长按解绑
- (void) inputLongPress:(UILongPressGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        // 绑定
        if (_pointEnum == BusOBD_PointView_Bind) {
         
            [UIAlert alertSmallTitle:@"是否解绑?"
                       agreeBtnBlock:^(UIAlertAction *action) {
                       
                if (_disConnect_ShipBlock) {
                    _disConnect_ShipBlock(_inPut_DataSource);
                }
            }];
        }
    }
}


#pragma mark - method  ---


// 输入端子 选中状态 , 其他端子为未选中状态
- (void) BusOBD_InputBtn_Select {
    
    [_inputBtn cornerRadius:0 borderWidth:1 borderColor:UIColor.mainColor];
    
    _nowSelectIndex = nil;
    
    for (Yuan_BusOBD_PointItem * item in _OBD_ItemsArr) {
        [item.contentView cornerRadius:0 borderWidth:0 borderColor:nil];
    }
    
    [_collection reloadData];
}


// 输出端子 选中状态 , 其他端子 包括输入端子 为未选中状态
- (void) BusOBD_OutPutItem_Select:(Yuan_BusOBD_PointItem *) item {
    
    [_inputBtn cornerRadius:0 borderWidth:0 borderColor:nil];
    
    for (Yuan_BusOBD_PointItem * item in _OBD_ItemsArr) {
        [item.contentView cornerRadius:0 borderWidth:0 borderColor:nil];
    }
    
    [item.contentView cornerRadius:0 borderWidth:1 borderColor:UIColor.mainColor];
    
    [_collection reloadData];
}



// 不选择任何端子
- (void) BusOBD_SelectNothing {
    
    [_inputBtn cornerRadius:0 borderWidth:0 borderColor:nil];
    
    for (Yuan_BusOBD_PointItem * item in _OBD_ItemsArr) {
        [item.contentView cornerRadius:0 borderWidth:0 borderColor:nil];
    }
}




/// 选中下一个
- (void) BusOBD_OutPutItem_SelectNext:(NSIndexPath *) nowIndex {
    
    
    if (nowIndex.row  >= _outPut_DataSource.count - 1) {
        _nowSelectIndex = nil;
        [YuanHUD HUDFullText:@"结束"];
        [_collection reloadData];
        return;
    }
    
    NSIndexPath * nextIndex = [NSIndexPath indexPathForRow:nowIndex.row + 1 inSection:0];
    
    [self collectionView:_collection didSelectItemAtIndexPath:nextIndex];
    
    [_collection scrollToItemAtIndexPath:nextIndex
                        atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                animated:YES];
    
}



// 刷新有绑定关联关系的的数据  -- pointIdsArr 关联关系数据
- (void) reloadConnectSympolArray:(NSArray *) pointIdsArr {
    
    
    // pointId terminalId
    
    NSMutableArray * new_Arr = NSMutableArray.array;
    
    for (NSDictionary * dict in _outPut_DataSource) {
        
        NSMutableDictionary * new_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
        // 先移除老的关联关系 , 以请求回来的新关系为主
        [new_Dict removeObjectForKey:@"zid"];
        
        for (NSDictionary * connectDict in pointIdsArr) {
            
            if ([connectDict[@"pointId"] isEqualToString:dict[@"resId"]?:dict[@"gid"]]) {
                new_Dict[@"zid"] = connectDict[@"terminalId"] ?: @"";
                break;
            }
            
        }
        
        [new_Arr addObject:new_Dict];
        
    }
    
    _outPut_DataSource = new_Arr;
    [_collection reloadData];
    
    
    // 输入端业务处理
    
    _inputSympol.hidden = YES;
    
    for (NSDictionary * dict in pointIdsArr) {
        
        NSString * inputResId = _inPut_DataSource[@"resId"]?:_inPut_DataSource[@"gid"];
        
        NSString * pointId = dict[@"pointId"];
        
        if ([inputResId isEqualToString:pointId]) {
            _inputSympol.hidden = NO;
            break;
        }
        
    }
}


#pragma mark - UI_Init ---



- (void) UI_Init {
    
    
    _blockView = [[Yuan_BlockLabelView alloc] initWithBlockColor:UIColor.mainColor
                                                           title:@"设备名称"];
    
    _input = [UIView labelWithTitle:@"输入" frame:CGRectNull];
    [_input cornerRadius:0 borderWidth:1 borderColor:ColorValue_RGB(0xe2e2e2)];
    _input.textAlignment = NSTextAlignmentCenter;
    
    
    _inputBackView = [UIView viewWithColor:UIColor.whiteColor];
    [_inputBackView cornerRadius:0 borderWidth:1 borderColor:ColorValue_RGB(0xe2e2e2)];
    
    
    _inputBtn = [UIView buttonWithTitle:@"1"
                              responder:self
                                    SEL:@selector(inputBtnClick)
                                  frame:CGRectNull];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]init];
    [_inputBtn addGestureRecognizer:gesture];
    [gesture setMinimumPressDuration:0.3];  //长按1秒后执行事件
    [gesture addTarget:self action:@selector(inputLongPress:)];
    
    [_inputBtn cornerRadius:0 borderWidth:1 borderColor:ColorValue_RGB(0xe2e2e2)];
    
    _inputSympol = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"cf_OBD_Connect"]
                                      frame:CGRectNull];
    
    _inputSympol.hidden = YES;
    
    
    _outPut = [UIView labelWithTitle:@"输出" frame:CGRectNull];
    [_outPut cornerRadius:0 borderWidth:1 borderColor:ColorValue_RGB(0xe2e2e2)];
    _outPut.textAlignment = NSTextAlignmentCenter;
    
    
    _outPutBackView = [UIView viewWithColor:UIColor.whiteColor];
    [_outPutBackView cornerRadius:0 borderWidth:1 borderColor:ColorValue_RGB(0xe2e2e2)];
    
    
    
    
    
    
    
    UICollectionViewFlowLayout * flowLayout = UICollectionViewFlowLayout.alloc.init;
    
    flowLayout.minimumLineSpacing = 1;
    flowLayout.minimumInteritemSpacing = 1;
    flowLayout.itemSize = CGSizeMake(_item_Width, _item_Width);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    
    _collection = [UIView collectionDatasource:self
                                 registerClass:[Yuan_BusOBD_PointItem class]
                           CellReuseIdentifier:@"Yuan_BusOBD_PointItem"
                                    flowLayout:flowLayout];
    
    
    [self addSubviews:@[_blockView,
                        _input,_inputBackView,
                        _outPut,_outPutBackView]];
    
    [_inputBackView addSubviews:@[_inputBtn]];
    [_inputBtn addSubview:_inputSympol];
    
    [_outPutBackView addSubview:_collection];
    
    [self yuan_LayoutSubViews];
    
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(10);
    
    
    
    [_blockView YuanToSuper_Top:limit/2];
    [_blockView YuanToSuper_Left:limit];
    [_blockView YuanToSuper_Right:limit];
    [_blockView autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
    
    
    // 输入
    
    [_input YuanToSuper_Left:limit];
    [_input YuanMyEdge:Top ToViewEdge:Bottom ToView:_blockView inset:limit/2];
    [_input autoSetDimensionsToSize:CGSizeMake(Horizontal(50), Horizontal(50))];
    
    [_inputBackView YuanMyEdge:Left ToViewEdge:Right ToView:_input inset:0];
    [_inputBackView YuanAttributeHorizontalToView:_input];
    [_inputBackView YuanToSuper_Right:limit];
    [_inputBackView autoSetDimension:ALDimensionHeight toSize:Horizontal(50)];
    
    
    [_inputBtn YuanToSuper_Left:limit];
    [_inputBtn YuanAttributeHorizontalToView:_inputBackView];
    [_inputBtn autoSetDimensionsToSize:CGSizeMake(_item_Width, _item_Width)];
    
    
    [_inputSympol YuanToSuper_Right:0];
    [_inputSympol YuanToSuper_Top:0];
    
    
    
    // 输出
    [_outPut YuanToSuper_Left:limit];
    [_outPut YuanToSuper_Bottom:0];
    [_outPut YuanMyEdge:Top ToViewEdge:Bottom ToView:_input inset:limit/2];
    [_outPut autoSetDimension:ALDimensionWidth toSize:Horizontal(50)];
    
    [_outPutBackView YuanMyEdge:Left ToViewEdge:Right ToView:_outPut inset:0];
    [_outPutBackView YuanAttributeHorizontalToView:_outPut];
    [_outPutBackView YuanToSuper_Right:limit];
    [_outPutBackView YuanToSuper_Bottom:0];
    
    [_collection autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(limit, limit, limit, limit)];
    
}




#pragma mark - CollectionDelegate ---

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    
    return _outPut_DataSource.count;
}



- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    Yuan_BusOBD_PointItem * item =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"Yuan_BusOBD_PointItem"
                                              forIndexPath:indexPath];
    
    if (!item) {
        item = [[Yuan_BusOBD_PointItem alloc] init];
    }
    
    
    if (_nowSelectIndex.row == indexPath.row && _nowSelectIndex) {
        [item.contentView cornerRadius:0 borderWidth:1 borderColor:UIColor.mainColor];
    }
    else {
        [item.contentView cornerRadius:0 borderWidth:0 borderColor:nil];
    }
    
    NSDictionary * port_Dict = _outPut_DataSource[indexPath.row];
    
    [item reloadWithDict:port_Dict];
    
//    [item connectSympol:NO];
//
//    if ([port_Dict.allKeys containsObject:@"sympol"] &&
//        [port_Dict[@"sympol"] isEqualToString:@"1"]) {
//
//        [item connectSympol:YES];
//    }
    
    
    [_OBD_ItemsArr addObject:item];
    
    
    // 长按的事件回调
    item.BusOBD_LongPressBlock = ^(NSDictionary * _Nonnull myDict) {
        [self outPutItems_LongPress:myDict];
    };
    
    return item;
}


@end
