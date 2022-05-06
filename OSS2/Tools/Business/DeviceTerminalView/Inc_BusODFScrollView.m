//
//  Inc_BusODFScrollView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BusODFScrollView.h"
#import "Yuan_ScrollCollectionVM.h"         // 用来判断 行优列优等排序方式的算法

#import "Inc_BusScrollVerticalCell.h"
#import "Inc_BusScrollHorizontalCell.h"

#import "Yuan_CF_HttpModel.h"               // 网络请求工具类
#import "Yuan_CFConfigVM.h"                 // viewModel



//固定不动的边距  如果是行优 就是 height  , 如果列优 就是width
#define KItemFixed Horizontal(40)

@interface Inc_BusODFScrollView ()

<
    // collectionView 代理
    UICollectionViewDelegate ,
    UICollectionViewDataSource ,
    UICollectionViewDelegateFlowLayout,

    // 端子盘上 端子按钮点击事件的代理 , 传了 按钮对象
    ScrollHorizontalDeletate ,
    ScrollVerticalDeletate


 >

@end

@implementation Inc_BusODFScrollView
{
    
    int _lineCount;   // 理解为 多少条记录
    int _rowCount;    // 理解为 每条记录 有多少字段(列)
    int _inlineNums;  // 理解为 每个列里 , 又有多少个子元素
    
    ///  _inlineNums = _moduleRows * _moduleColunm;
    ///
    int _moduleRows;  // 端子盘内端子行数 -- 理解为 交叉轴上的端子个数
    int _moduleColunm;// 端子盘内端子列数 -- 理解为 主轴上的端子个数
    
    
    Important_ _import;  // 行优 列优?  影响collection 横着还是 竖着
    Direction_ _dire;    // 排序方式 --- 最复杂的判断
    
    NSArray * _dataSource;   //数据
    
    NSDictionary * _pieDict;  //会在请求 初始化模块端子时使用
    
    Yuan_ScrollCollectionVM * _old_VM;  // 用来判断 行优列优等排序方式的算法
    
    //用于初始化端子信息时使用  这个map 相当于某一个有值的模块全部信息
    NSDictionary * _dataSource_Dict;
    
    
    UIViewController * _VC;  //如果判断端子信息有误 则返回上一界面
    
    Yuan_CFConfigVM * _viewModel; // viewModel
 
    
    
    //里面全是行优 / 列优的collectionview里的item   , 用于长按的时候 , 确定赋值顺序 , 也就是按绑卡的顺序把item中的按钮添加到数组中
    NSMutableArray * _allCollectionItemArray;
    

    NSInteger _now_row ;

    
    // 存放所有端子的Array
    NSMutableArray < Inc_BusScrollItem *> * _btnsArray;
    // 存放所有数据的数组
    NSMutableArray * _dictsArr;
}


#pragma mark - 初始化构造方法


/// 初始化
/// @param lineCount 行数   一行是一条记录
/// @param rowCount 列数    一个行内 有几个字段
/// @param inLineNums    行内个数
/// @param import    行优 还是 列优?
/// @param dire     排序方式
/// @param dataSource 网络请求回来的 模块信息 [{}] 格式
/// @param PieDict 端子盘信息 , 也包括 设备id 设备类型等
- (instancetype) initWithLineCount:(int)lineCount
                          rowCount:(int)rowCount
                         Important:(Important_)import
                         Direction:(Direction_)dire
                        dataSource:(NSArray *)dataSource
                           PieDict:(NSDictionary *)pieDict
                                VC:(UIViewController *)VC{
    
    if (self = [super init]) {
        
        _VC = VC;
        
        _viewModel = [Yuan_CFConfigVM shareInstance];
        
        _now_row = 0;
        
        // 初始化行优列优数组
        _allCollectionItemArray = [NSMutableArray array];
        
         // key 为 position  value 为 各个有效模块的map @{position : @{}}
        _dataSource = dataSource;
        
        _pieDict = pieDict;         // 设备id等信息
         
        _lineCount = lineCount;     // 行数
        _rowCount = rowCount;       // 列数
        
        // 提前处理 行内个数
        _inlineNums = [self inLineNumsConfig:dataSource];
        
        
        
        _import = import;    //行优 列优 ?  端子 竖着还是横着  line行优 row列优
        _dire = dire;               //排序方式
        
        _old_VM = [[Yuan_ScrollCollectionVM alloc] init];
    
        
        [self collectionInit];      //初始化 collectionViews 很多行
        
        self.backgroundColor = UIColor.yellowColor;
    }
    return self;
}


#pragma mark -  reload Data  ---



- (void) reloadViewWithLineCount:(int)lineCount
                        rowCount:(int)rowCount
                       Important:(Important_)import
                       Direction:(Direction_)dire
                      dataSource:(NSArray *)dataSource
                         PieDict:(NSDictionary *)pieDict {
    
    
    // 把值 重新赋值一遍
    
    // key 为 position  value 为 各个有效模块的map @{position : @{}}
    _dataSource = dataSource;
    
    _pieDict = pieDict;         // 设备id等信息
     
    _lineCount = lineCount;     // 行数
    _rowCount = rowCount;       // 列数
    
    // 提前处理 行内个数
    _inlineNums = [self inLineNumsConfig:dataSource];
    
    
    
    _import = import;    //行优 列优 ?  端子 竖着还是横着  line行优 row列优
    _dire = dire;        //排序方式
    
    for (__strong UICollectionView * view in _collectionArray) {
        [view removeFromSuperview];
        view = nil;
    }
    
    // 再重新初始化
    [self collectionInit];      //初始化 collectionViews 很多行
    
}




// *********** *********** *********** *********** ***********

/// 有的时候 行内个数 , 由于pie.dict里没有那个字段 , 所以就需要在请求信息中重新复制一遍
/// @param dataSource 请求回来的数据源 [position:dict]
/// @param inLineNums 当前的行内个数
- (int) inLineNumsConfig:(NSArray *)dataSource{
    
    
    NSDictionary * dict = [dataSource firstObject];
    NSDictionary * value = [dict.allValues firstObject];
    
    //如果当前行内个数 为0,那么需要检测一下 是否是没有这个字段导致的
//    moduleTubeColumn  moduleTubeRow
    
    int moduleTubeColumn = [[value objectForKey:@"moduleTubeColumn"] intValue];
    int moduleTubeRow = [[value objectForKey:@"moduleTubeRow"] intValue];
    
    
    // 证明是新接口
    if (moduleTubeColumn == 0 && moduleTubeRow == 0) {
        
        NSNumber * totalRow = value[@"totalRow"];
        NSNumber * totalCol = value[@"totalCol"];
        
        moduleTubeRow = totalRow.intValue;
        moduleTubeColumn = totalCol.intValue;
    }
    
    // TODO: 行内端子个数 x 端子行数  如果和 opticTermsArray 不等 ,则必须提示错误端子盘 , 并且返回
    
    
    //如果当前行内个数 为0,那么需要检测一下 是否是没有这个字段导致的
    
    _moduleColunm = moduleTubeColumn;
    _moduleRows = moduleTubeRow;
    
    return _moduleRows * _moduleColunm;
    
}




#pragma mark - 代理 *** ***  ScrollHorizontalDeletate 和 ScrollVerticalDeletate



// 行优状态下 模块中 端子按钮的点击事件
- (void)horizontal_TerminalBtn:(Inc_BusScrollItem *)sender {
    [self ItemClick:sender];
}

// 列优状态下 , 模块中 端子按钮的点击事件
- (void)vertical_TerminalBtn:(Inc_BusScrollItem *)sender {
    [self ItemClick:sender];
}




- (void) ItemClick: (Inc_BusScrollItem *) sender {
    
    
    if (!sender.canSelect) {
        [YuanHUD HUDFullText:@"该端子不可选取"];
        return;
    }
    
    
    // 点击事件 回调给代理
    
    if (_itemSelectBlock) {
        _itemSelectBlock(sender);
    }
    
    
    
    // 端子的点击事件  以通知的形式 广播出去
    
    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:sender.dict];
    
    // 拼接 绑卡位置和端子位置
    mt_Dict[@"index"] = [Yuan_Foundation fromInt:sender.index];
    mt_Dict[@"position"] = [Yuan_Foundation fromInteger:sender.position];
    
    NSNotification * notification =
    [[NSNotification alloc] initWithName:BusDeviceSubTerminalClickNotification
                                  object:nil
                                userInfo:mt_Dict];
    
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    

    
}




#pragma mark -  ************* ************* 以下内容不会修改了 ********** **************



#pragma mark - CollectionViewDelegate


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section{
    return _rowCount;  // 不用再变了
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;   // 不用再变了
}




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_import == Important_Line) {
        // 行优
        return [self horizontalCellWithCollectionView:collectionView
                               cellForItemAtIndexPath:indexPath];
    }
    
    if (_import == Important_row) {
        // 列优
        return [self verticalCellWithCollectionView:collectionView
                            cellForItemAtIndexPath:indexPath];
    }
    
    return nil;
    
}




#pragma mark - 行优 列优 cell

/// 行优
- (Inc_BusScrollHorizontalCell *)horizontalCellWithCollectionView:(UICollectionView *)collectionView
                                         cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Inc_BusScrollHorizontalCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Inc_BusScrollHorizontalCell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[Inc_BusScrollHorizontalCell alloc] init];
    }
    
    NSInteger position =  [_old_VM viewModelCollectionViewTag:collectionView.tag
                                                         viewRow:indexPath.row + 1
                                                       hangCount:_lineCount
                                                        lieCount:_rowCount
                                                            Dire:_dire];
    
    cell.delegate = self;
    // 配置模块内 position
    [cell CellPosition:position];
    // 配置模块内 端子排列 与 端子个数
    [cell CellTerminal:_inlineNums moduleRows:_moduleRows moduleColumn:_moduleColunm];
    // 传值 , 该模块对应的map
    for (NSDictionary * dict in _dataSource) {
        if ([[Yuan_Foundation fromObject:[dict.allKeys firstObject]] isEqualToString:[Yuan_Foundation fromInteger:position]]) {
            [cell CellBtnMap_Dict:[dict.allValues firstObject]];
            _dataSource_Dict = [dict.allValues firstObject];
            
            // 验证端子信息 是否有误
            [self alertMessageError:_dataSource_Dict];
        }
    }
    
    // 把cell 放入数组中
    [_allCollectionItemArray addObject:cell];
    
    _now_row++;
    NSLog(@"---- %ld",_now_row);
    // 当全部加载完成时
    if (_now_row == _lineCount * _rowCount) {
        [self btnToVMArray];
    }
    
    return cell;
    
}





/// 列优
- (Inc_BusScrollVerticalCell *)verticalCellWithCollectionView:(UICollectionView *)collectionView
                                            cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Inc_BusScrollVerticalCell * cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"Inc_BusScrollVerticalCell"
                                              forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[Inc_BusScrollVerticalCell alloc] init];
    }
    
    // 得到绑卡的数字编号
    NSInteger position =  [_old_VM viewModelCollectionViewTag:collectionView.tag
                                                         viewRow:indexPath.row + 1
                                                       hangCount:_lineCount
                                                        lieCount:_rowCount
                                                            Dire:_dire];
    
    cell.delegate = self;
    
    // 配置模块内 position
    [cell CellPosition:position];
    // 配置模块内 端子排列 与 端子个数
    [cell CellTerminal:_inlineNums moduleRows:_moduleRows moduleColumn:_moduleColunm];
    // 传值 , 该模块对应的map
    for (NSDictionary * dict in _dataSource) {
        // 根据绑卡编号 , 到数据源中 取出对应的map
        if ([[Yuan_Foundation fromObject:[dict.allKeys firstObject]] isEqualToString:[Yuan_Foundation fromInteger:position]]) {
            [cell CellBtnMap_Dict:[dict.allValues firstObject]];
            // 验证端子信息 是否有误
            [self alertMessageError:[dict.allValues firstObject]];
        }
    }
    
    // 把cell 放入数组中
    [_allCollectionItemArray addObject:cell];
    
    _now_row++;
    
    if (_now_row == _lineCount * _rowCount) {
        [self btnToVMArray];
    }
    
    return cell;
    
}


#pragma mark - 判断列框信息错误 , 需要提示后 直接返回

- (void) alertMessageError:(NSDictionary *)moduleDict {
    
    NSArray * opticTermsArr = moduleDict[@"opticTerms"];
    
    if (opticTermsArr.count != _inlineNums) {
        
        NSString * msg = [NSString stringWithFormat:@"%@号模块端子信息有误",moduleDict[@"position"]];
        
        [[Yuan_HUD shareInstance] HUDFullText:msg];
        
        [_VC.navigationController popViewControllerAnimated:YES];
        
    }
    
}





#pragma mark - collection Init

// 根据行数 初始化 多少个collection "记录"
- (void) collectionInit {
    
    if (_import == Important_Line) {
        // 如果是行优
        
        // 单个 模块的宽度
        float horTermolFixed = KItemFixed * (_moduleColunm + 2);
        
        // 根据行数 初始化 collectionView ,每个collection 都是一行
        //scrollview里需要多少个collection
        for (int i = 0; i < _lineCount ; i++) {
            UICollectionView * collection = [self collection:i];
            [self addSubview:collection];
            [_collectionArray addObject:collection];
            collection.scrollEnabled = NO;
        }

        self.contentSize = CGSizeMake((horTermolFixed + 2) * _rowCount + 30,
                                      _lineCount * (_moduleRows * KItemFixed + 2) + 30);
    }
    
    
    
    
    
    
    if (_import == Important_row) {
        // 如果是列优
    
        // 单个 模块的高度 !!!  列优是高度
        float verTermolFixed = KItemFixed * (_moduleColunm + 2);
        
        // 根据行数 初始化 collectionView ,每个collection 都是一行
        //scrollview里需要多少个collection
        for (int i = 0; i < _lineCount ; i++) {
            UICollectionView * collection = [self collection:i];
            [self addSubview:collection];
            [_collectionArray addObject:collection];
            collection.scrollEnabled = NO;


        }

        self.contentSize = CGSizeMake(_rowCount * _moduleRows *(KItemFixed + 2) + 30,
                                      _lineCount * (verTermolFixed + 2) + 30);
        
    }
    
}



/// 循环创建collectionView , 平铺在 scrollView上
/// @param i 循环的次数
- (UICollectionView *) collection :(int) i {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    
    // 设置item的间距
    flowLayout.minimumLineSpacing      = 1;
    flowLayout.minimumInteritemSpacing = 1;
    
    
    
    // 设置宽度 , 此处一定是根据 上一个界面传过来的 行内个数 * 行内端子数量之后算出来的
    // 行内端子数量 需要增加两个边 , 再去for循环 生成 cell
    
    
    
    UICollectionView * collection;
    
    if (_import == Important_Line) {                // 行优 **** **** ****
        
        // 注意此处一定是横向移动
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        // 横向 长边长度 horTermolFixed , (正方形边长 * (模块内端子个数 + 两个边))
        float  horTermolFixed = KItemFixed * (_moduleColunm + 2);
        
        flowLayout.itemSize = CGSizeMake(horTermolFixed, KItemFixed * _moduleRows);
        
        /*
           frame: 设置的是一条collectioncell的frame  是横向排布的
        */
        
        CGRect frame = CGRectMake(5,
                                  1 + (KItemFixed + 1) * i * _moduleRows,
                                  (horTermolFixed + 2) * _rowCount + 40,
                                  KItemFixed * _moduleRows);
        
        
        collection = [[UICollectionView alloc] initWithFrame:frame
                                        collectionViewLayout:flowLayout];
        
    }
    
    
    if (_import == Important_row) {                // 列优 **** **** ****
        // 此处一定是 纵向移动
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        // 纵向 长边长度 horTermolFixed , (正方形边长 * (模块内端子个数 + 两个边))
        float verTermolFixed = KItemFixed * (_moduleColunm + 2);
        
        flowLayout.itemSize = CGSizeMake(KItemFixed  * _moduleRows,verTermolFixed);
        
        
        /*
            frame: 设置的是一条collectioncell的frame  是横向排布的
         所以 当纵向移动时  collection 的 frame.size.height = verTermolFixed ,
         verTermolFixed 是所有行数 + 绑卡数的总和高度
         */
        
        CGRect frame = CGRectMake(5,
                                  1 + (verTermolFixed + 1) * i,
                                  _moduleRows * KItemFixed * _rowCount + 40,
                                  verTermolFixed);

        collection = [[UICollectionView alloc] initWithFrame:frame
                                        collectionViewLayout:flowLayout];
    }
    
    
    
    collection.backgroundColor = [UIColor whiteColor];
    
    if (@available(iOS 11.0, *)) {
        collection.contentInsetAdjustmentBehavior = NO;
    } else {
        // Fallback on earlier versions
    }
    
    collection.showsHorizontalScrollIndicator = NO;
    collection.delegate = self;
    collection.dataSource = self;
    
    [collection registerClass:[UICollectionViewCell class]
   forCellWithReuseIdentifier:@"collection"];
    
    [collection registerClass:[Inc_BusScrollHorizontalCell class]
   forCellWithReuseIdentifier:@"Inc_BusScrollHorizontalCell"];
    
    [collection registerClass:[Inc_BusScrollVerticalCell class]
   forCellWithReuseIdentifier:@"Inc_BusScrollVerticalCell"];
    
    collection.bounces = NO;
    collection.tag = i + 1;     //tag 从1开始
    
    // 设置item的间距
    flowLayout.minimumLineSpacing      = 1;
    flowLayout.minimumInteritemSpacing = 1;
    
    return collection;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesEnded:touches withEvent:event];
}




#pragma mark -  把btn加入viewModel的数组中  ---


- (void) btnToVMArray {
    
    // 因为 绑卡数字是从1 开始的
    NSInteger position = 1;
    
   
    
    
/// MARK: 接下来的代码的唯一目的就是跳转 按钮添加进数组的顺序 , 因为在之前的逻辑中 , 一行collectionViewCell里有多个item , 也就是端子盘里的模块 (包含两个绑卡之间的端子总称) , 模块生成的顺序不是 1,2,3 这样的顺序生成 , 而是跳跃生成的 . 但此处的业务 , 需要将这些按钮 , 按绑卡顺序注入到数组当中 .  接下来 按 绑卡顺序 把按钮 按顺序 添加到 terminalBtnArray 数组中
    
    // 行优
    if (_import == Important_Line) {
        
        while (position <= _lineCount * _rowCount) {
            for (Inc_BusScrollHorizontalCell * item in _allCollectionItemArray) {
                if ([item.position_btnArray_Dict.allKeys.firstObject integerValue] == position) {
                    [_viewModel.terminalBtnArray addObjectsFromArray:item.position_btnArray_Dict.allValues.firstObject];
                    
                    position++;
                    
                }
            }
        }
        
    }
    
    
    // 列优
    if (_import == Important_row) {
        
        while (position < _lineCount * _rowCount) {
            for (Inc_BusScrollVerticalCell * item in _allCollectionItemArray) {
                if ([item.position_btnArray_Dict.allKeys.firstObject integerValue] == position) {
                    [_viewModel.terminalBtnArray addObjectsFromArray:item.position_btnArray_Dict.allValues.firstObject];
                    
                    position++;
                    
                }
            }
        }
    }
}



- (NSArray <Inc_BusScrollItem *> * ) getBtns {
    
    [self getBtns_Arr];
    
    return _btnsArray;
}


- (NSArray <Inc_BusScrollItem *> * ) getArrangementBtn {
    
    return _viewModel.terminalBtnArray;
}


- (NSArray *) getAllTerminalIds  {
    
    [self getBtns_Arr];
    
    NSMutableArray * IdsArr = NSMutableArray.array;
    
    for (NSDictionary * terminalDict in _dictsArr) {
        [IdsArr addObject:terminalDict[@"GID"]];
    }
    
    return IdsArr;
}


- (void) getBtns_Arr {
    
    _btnsArray = NSMutableArray.array;
    _dictsArr = NSMutableArray.array;
    // 行优 Hor
    if (_import == Important_Line) {
        for (Inc_BusScrollHorizontalCell * cell in _allCollectionItemArray) {
            NSArray * subBtnsArr = [cell btnsArr];
            [_btnsArray addObjectsFromArray:subBtnsArr];
            
            for (Inc_BusScrollItem * btn in subBtnsArr) {
                NSDictionary * dict = btn.dict;
                if (dict) {
                    [_dictsArr addObject:dict];
                }
            }
            
        }
    }

    // 列优 Ver
    else {
        for (Inc_BusScrollVerticalCell * cell in _allCollectionItemArray) {
            NSArray * subBtnsArr = [cell btnsArr];
            [_btnsArray addObjectsFromArray:subBtnsArr];
            
            for (Inc_BusScrollItem * btn in subBtnsArr) {
                NSDictionary * dict = btn.dict;
                if (dict) {
                    [_dictsArr addObject:dict];
                }
            }
        }
    }
    
}


@end
