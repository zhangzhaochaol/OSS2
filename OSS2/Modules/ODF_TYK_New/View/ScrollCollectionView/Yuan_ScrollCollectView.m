//
//  Yuan_ScrollCollectView.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/3.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//


#import "Yuan_ScrollCollectView.h"
#import "Yuan_ScrollCollectionVM.h"





#import "Yuan_ODF_HttpModel.h"    //网络请求业务类
#import "Inc_NewFL_HttpModel1.h"


#import "TYKDeviceInfoMationViewController.h"  //点击按钮跳转到这里



#import "IWPPropertiesReader.h"
#import "Yuan_PhotoCheckVM.h"
#import "Yuan_ImageCheckChooseVC.h"         // 校验图片



//固定不动的边距  如果是行优 就是 height  , 如果列优 就是width
#define KItemFixed Horizontal(40)


@interface Yuan_ScrollCollectView ()

<
    // collectionView 代理
    UICollectionViewDelegate ,
    UICollectionViewDataSource ,
    UICollectionViewDelegateFlowLayout,
    
    // 端子盘上 端子按钮点击事件的代理 , 传了 按钮对象
    ScrollHorizontalDeletate ,
    ScrollVerticalDeletate,


    // 不知道这个代理要实现什么 , 但之前的类声明了他 我这里也就跟着声明了一下
    TYKDeviceInfomationDelegate
>

@end


@implementation Yuan_ScrollCollectView

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
    
    Yuan_ScrollCollectionVM * _viewModel;
    
    //用于初始化端子信息时使用  这个map 相当于某一个有值的模块全部信息
    NSDictionary * _dataSource_Dict;
    
    
    IWPPropertiesReader * _reader;
    IWPPropertiesSourceModel * _model;
    NSArray <IWPViewModel *>* _viewModel_muban;
    
    UIViewController * _VC;  //用于按钮点击完 跳转时的 VC
    
    
    //里面全是行优 / 列优的collectionview里的item   , 用于长按的时候 , 确定赋值顺序 , 也就是按绑卡的顺序把item中的按钮添加到数组中
    NSMutableArray * _allCollectionItemArray;
    
    
    // 联通图片识别状态
    BOOL _isUnionPhotoState;
    
    // 结束图片识别
    UIButton * _endUnionPhotoBtn;
    
    // 再来一遍
    UIButton * _reStartUnionPhotoBtn;
    
    // 存放所有端子的Array
    NSMutableArray < Yuan_terminalBtn *> * _btnsArray;
    
    // 所有端子数据的集合
    NSMutableArray * _dictsArr;
    
    Yuan_PhotoCheckVM * _PhotoVM;
    
    // 图片识别回来的数据 Array 和 图片本身
    NSArray * _photoCheckArray;
    UIImage * _photoCheckImage;
    NSArray * _photoChekc_MATRIX;
    NSString * _photoCheckBase64Img;
    
    
    
    
    // *** *** *** 批量修改 端子状态
    NSMutableArray * _BatchHoldArray;
    //存放选择后的端子
    NSMutableArray * _batchHoldArrayZZC;

    BOOL _BatchStart;
    
    
    
    //选中的所有端子中，存在光路关系的端子集合
    NSMutableArray *_selectTermSArray;
    
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
        
        _isUnionPhotoState = NO;
        
        
         // key 为 position  value 为 各个有效模块的map @{position : @{}}
        _dataSource = dataSource;
        
        _pieDict = pieDict;         // 设备id等信息
         
        _lineCount = lineCount;     // 行数
        _rowCount = rowCount;       // 列数
        
        // 提前处理 行内个数
        _inlineNums = [self inLineNumsConfig:dataSource];
        
        
        
        _import = import;    //行优 列优 ?  端子 竖着还是横着  line行优 row列优
        _dire = dire;               //排序方式
        
        _viewModel = [[Yuan_ScrollCollectionVM alloc] init];
    
        _VC = VC;   
        
        [self collectionInit];      //初始化 collectionViews 很多行
        
        
        _allCollectionItemArray = NSMutableArray.array;
        
        _PhotoVM = Yuan_PhotoCheckVM.shareInstance;
        
        _BatchHoldArray = NSMutableArray.array;
        _batchHoldArrayZZC = NSMutableArray.array;

        
    }
    
    
    return self;
}


// 刷新
- (void) reloadLineCount:(int)lineCount
                rowCount:(int)rowCount
               Important:(Important_)import
               Direction:(Direction_)dire
              dataSource:(NSArray *)dataSource
                 PieDict:(NSDictionary *)pieDict
                      VC:(UIViewController *)VC {
    
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _isUnionPhotoState = NO;
    
    
     // key 为 position  value 为 各个有效模块的map @{position : @{}}
    _dataSource = dataSource;
    
    _pieDict = pieDict;         // 设备id等信息
     
    _lineCount = lineCount;     // 行数
    _rowCount = rowCount;       // 列数
    
    // 提前处理 行内个数
    _inlineNums = [self inLineNumsConfig:dataSource];
    
    
    
    _import = import;    //行优 列优 ?  端子 竖着还是横着  line行优 row列优
    _dire = dire;               //排序方式
    
    _viewModel = [[Yuan_ScrollCollectionVM alloc] init];

    _VC = VC;
    
    [self collectionInit];      //初始化 collectionViews 很多行
    
    
    _allCollectionItemArray = NSMutableArray.array;
    
    _PhotoVM = Yuan_PhotoCheckVM.shareInstance;
    
    _BatchHoldArray = NSMutableArray.array;
    _batchHoldArrayZZC = NSMutableArray.array;

    
}


/// 有的时候 行内个数 , 由于pie.dict里没有那个字段 , 所以就需要在请求信息中重新复制一遍
/// @param dataSource 请求回来的数据源 [position:dict]
/// @param inLineNums 当前的行内个数
- (int) inLineNumsConfig:(NSArray *)dataSource{
    
    
    NSDictionary * dict = [dataSource firstObject];
    NSDictionary * value = [dict.allValues firstObject];
    
    //如果当前行内个数 为0,那么需要检测一下 是否是没有这个字段导致的
    
    _moduleColunm = [[value objectForKey:@"moduleTubeColumn"] intValue];
    _moduleRows = [[value objectForKey:@"moduleTubeRow"] intValue];
    
    // TODO: 行内端子个数 x 端子行数  如果和 opticTermsArray 不等 ,则必须提示错误端子盘 , 并且返回
    
    return _moduleRows * _moduleColunm;
    
}




#pragma mark - 代理 *** ***  ScrollHorizontalDeletate 和 ScrollVerticalDeletate



// 行优状态下 模块中 端子按钮的点击事件
- (void)horizontal_TerminalBtn:(Yuan_terminalBtn *)sender {
    [self push:sender];
}

// 列优状态下 , 模块中 端子按钮的点击事件
- (void)vertical_TerminalBtn:(Yuan_terminalBtn *)sender {
    [self push:sender];
}



/// 封装的方法 去跳转 
- (void) push:(Yuan_terminalBtn *)sender {
    
    // 批量端子状态修改 **
    if (_BatchStart) {
        
        
        NSDictionary * dict = sender.dict;
        
        NSString * GID = dict[@"GID"];
        
        if (![_BatchHoldArray containsObject:GID]) {
            [_BatchHoldArray addObject:GID];
            [_batchHoldArrayZZC addObject:sender];
            [sender redBorder:YES];
        }
        else {
            [_BatchHoldArray removeObject:GID];
            [_batchHoldArrayZZC removeObject:sender];
            [sender redBorder:NO];
        }
        
        return;
    }
    
    // 图片识别状态
    if (_isUnionPhotoState) {
        
        // 选择我想要的校验端子
        if (_PhotoVM.isChooseTerminalMode) {
            if (_terminalBtnClick_Block) {
                _terminalBtnClick_Block(sender.index,sender.position);
            }
        }
        // 修改端子业务状态
        else {
            if ([sender isNeedChangeState]) {
                [self http_ChangeTerminalState:sender];
            }
        }
        
        return;
    }
    
    
    
    
    
    _reader = [IWPPropertiesReader propertiesReaderWithFileName:@"opticTerm"
                                          withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
    _model = [IWPPropertiesSourceModel modelWithDict:_reader.result];
    
    // 创建viewModel
    NSMutableArray * arrr = [NSMutableArray array];
    for (NSDictionary * dict in _model.view) {
        IWPViewModel * viewModel = [IWPViewModel modelWithDict:dict];
        [arrr addObject:viewModel];
    }
    _viewModel_muban = arrr;
    
    
     // TODO 智网通模板跳转
    TYKDeviceInfoMationViewController *device =
    [TYKDeviceInfoMationViewController deviceInfomationWithControlMode:TYKDeviceListUpdateRfid
                                                         withMainModel:_model
                                                         withViewModel:_viewModel_muban
                                                          withDataDict:sender.dict
                                                          withFileName:@"opticTerm"];
    
    device.delegate = self;
    
    
    
    NSString * type = _pieDict[@"eqpId_Type"];
    BOOL is_Odf = [type isEqualToString:@"1"];  //1是 odf  2是occ
    
    //ODF_Equt
    device.sourceFileName = is_Odf ?@"ODF_Equt" :@"OCC_Equt";  //设备类型
    device.equType = is_Odf ?@"ODF_Equt" :@"OCC_Equt";      //设备类型
    [_VC.navigationController pushViewController:device
                                        animated:YES];
    
    
    //MARK: 点击保存按钮后的回调 , 用于在请求成功后 , 给sender 改变状态
    device.Yuan_ODFOCC_Block = ^(NSDictionary *changeDict) {
        
        
        [[Yuan_HUD shareInstance] HUDFullText:@"修改成功"];
        
//        if (_BatchHold_SaveBlock) {
//            _BatchHold_SaveBlock(_batchHoldArrayZZC);
//        }
        
        
    };
    
}







- (void) getBtns {
    
    _btnsArray = NSMutableArray.array;
    _dictsArr = NSMutableArray.array;

    // 行优 Hor
    if (_import == Important_Line) {
        for (Yuan_ScrollHorizontalCell * cell in _allCollectionItemArray) {
            NSArray * subBtnsArr = [cell btnsArr];
            [_btnsArray addObjectsFromArray:subBtnsArr];
            
            for (Yuan_terminalBtn * btn in subBtnsArr) {
                NSDictionary * dict = btn.dict;
                if (dict) {
                    [_dictsArr addObject:dict];
                }
            }
            
        }
    }

    // 列优 Ver
    else {
        for (Yuan_ScrollVerticalCell * cell in _allCollectionItemArray) {
            NSArray * subBtnsArr = [cell btnsArr];
            [_btnsArray addObjectsFromArray:subBtnsArr];
            
            for (Yuan_terminalBtn * btn in subBtnsArr) {
                NSDictionary * dict = btn.dict;
                if (dict) {
                    [_dictsArr addObject:dict];
                }
            }
        }
    }
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
- (Yuan_ScrollHorizontalCell *)horizontalCellWithCollectionView:(UICollectionView *)collectionView
                                         cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    __weak Yuan_ScrollHorizontalCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Yuan_ScrollHorizontalCell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[Yuan_ScrollHorizontalCell alloc] init];
    }
    
    cell.delegate = self;
    
    NSInteger position =  [_viewModel viewModelCollectionViewTag:collectionView.tag
                                                         viewRow:indexPath.row + 1
                                                       hangCount:_lineCount
                                                        lieCount:_rowCount
                                                            Dire:_dire];
    
    // 配置模块内 position
    [cell CellPosition:position];
    
    // 配置模块内 端子排列 与 端子个数
    [cell CellTerminal:_inlineNums
            moduleRows:_moduleRows
          moduleColumn:_moduleColunm];
    
    // 传值 , 该模块对应的map
    for (NSDictionary * dict in _dataSource) {
        if ([[dict.allKeys firstObject] isEqualToString:[Yuan_Foundation fromInteger:position]]) {
            [cell CellBtnMap_Dict:[dict.allValues firstObject]];
            _dataSource_Dict = [dict.allValues firstObject];
            
            // 验证端子信息 是否有误
            [self alertMessageError:[dict.allValues firstObject]];
        }
    }
    
    
    // 把cell 放入数组中
    [_allCollectionItemArray addObject:cell];
    

    cell.remarkBlock = ^(NSString * _Nonnull num) {
      
        NSDictionary *dictPosition;
        for (NSDictionary * dict in _dataSource) {
            if ([[dict.allKeys firstObject] isEqualToString:num]) {

                dictPosition = [dict.allValues firstObject];
            
            }
        }
        
        if (self.remarkBlock) {
            self.remarkBlock(num,dictPosition);
        }
        
    };
    
    return cell;
    
}





/// 列优
- (Yuan_ScrollVerticalCell *)verticalCellWithCollectionView:(UICollectionView *)collectionView
                                            cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    __weak Yuan_ScrollVerticalCell * cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"Yuan_ScrollVerticalCell"
                                              forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[Yuan_ScrollVerticalCell alloc] init];
    }
    
    cell.delegate = self;
    
    // 得到绑卡的数字编号
    NSInteger position =  [_viewModel viewModelCollectionViewTag:collectionView.tag
                                                         viewRow:indexPath.row + 1
                                                       hangCount:_lineCount
                                                        lieCount:_rowCount
                                                            Dire:_dire];
    
    // 配置模块内 position
    [cell CellPosition:position];
    
    NSLog(@"--position: %ld -- row: %ld ",position , indexPath.row);
    
    // 配置模块内 端子排列 与 端子个数
    [cell CellTerminal:_inlineNums
            moduleRows:_moduleRows
          moduleColumn:_moduleColunm];
    
    // 传值 , 该模块对应的map
    for (NSDictionary * dict in _dataSource) {
        // 根据绑卡编号 , 到数据源中 取出对应的map
        if ([[dict.allKeys firstObject] isEqualToString:[Yuan_Foundation fromInteger:position]]) {
            [cell CellBtnMap_Dict:[dict.allValues firstObject]];
            if (position == 12) {
                NSLog(@"--- aaa %@",dict);
            }
            // 验证端子信息 是否有误
            [self alertMessageError:[dict.allValues firstObject]];
        }
    }
    
    
    // 把cell 放入数组中
    [_allCollectionItemArray addObject:cell];
    
    
    
    cell.remarkBlock = ^(NSString * _Nonnull num) {
      
        NSDictionary *dictPosition;
        for (NSDictionary * dict in _dataSource) {
            if ([[dict.allKeys firstObject] isEqualToString:num]) {

                dictPosition = [dict.allValues firstObject];
            
            }
        }
        
        if (self.remarkBlock) {
            self.remarkBlock(num,dictPosition);
        }
        
    };
    
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
    
    [collection registerClass:[Yuan_ScrollHorizontalCell class]
   forCellWithReuseIdentifier:@"Yuan_ScrollHorizontalCell"];
    
    [collection registerClass:[Yuan_ScrollVerticalCell class]
   forCellWithReuseIdentifier:@"Yuan_ScrollVerticalCell"];
    
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





#pragma mark - 2021.1.22 ---

- (void) btns_Union_PhotoArray:(NSArray *) unionArray
                         image:(UIImage *)image
                     base64Img:(NSString *)base64Img
                        matrix:(NSArray *)MATRIX {
    
    _photoCheckBase64Img = base64Img;
    _photoChekc_MATRIX = MATRIX;
    _photoCheckArray = unionArray;
    _photoCheckImage = image;
    
    
    // 进入图片识别状态
    _isUnionPhotoState = YES;
    
    // 配置UI
    [self union_UI];
    
    // _lineCount 行数
    // _inlineNums 行内个数
    
    // 图片整体的宽和高
    float img_Width = image.size.width;
    float img_Height = image.size.height;
    
    // 单个模块的 宽和高
    float single_Width = img_Width / _inlineNums;
    float single_Height = img_Height / _lineCount;
    
    
    
    NSMutableArray * newArr = NSMutableArray.array;
    
    for (NSDictionary * dict in unionArray) {
        
        NSNumber * top = dict[@"top"];
        NSNumber * left = dict[@"left"];
        
        NSNumber * right = dict[@"right"];
        NSNumber * bottom = dict[@"bottom"];
        
        if ([top obj_IsNull] ||
            [left obj_IsNull] ||
            [right obj_IsNull] ||
            [bottom obj_IsNull]) {
            
            continue;
        }
        
        float center_X = (right.floatValue - left.floatValue) / 2 + left.floatValue;
        float center_Y = (bottom.floatValue - top.floatValue) / 2 + top.floatValue;
        
        // 行
        int row = center_Y / single_Height;
        // 列
        int line = center_X / single_Width;
        
        NSMutableDictionary * new_dict = [NSMutableDictionary dictionaryWithDictionary:dict];
        new_dict[@"row"] = [NSNumber numberWithInt:row];
        new_dict[@"line"] = [NSNumber numberWithInt:line];
        
        [newArr addObject:new_dict];
    }
    
    [self getBtns];
    
    // row -- position
    // line -- index
    
    // 遍历 button
    for (Yuan_terminalBtn * btn in _btnsArray) {
        
        NSInteger btn_row = btn.position;
        NSInteger btn_line = btn.index;
        
        for (NSDictionary * dict in newArr) {
            
            NSNumber * dict_row = dict[@"row"];
            NSNumber * dict_line = dict[@"line"];
            
            NSInteger dict_Row_Int = dict_row.integerValue;
            NSInteger dict_Line_Int = dict_line.integerValue;
            
            // 为啥 + 1?  因为 计算 new_dict[@"row"] 时 会有 0.5的数 , int后为0
            if (btn_row == dict_Row_Int + 1 && btn_line == dict_Line_Int + 1) {
                
                // 给 btn赋值
                [btn showMyUnionPhotoState:dict];
            }
            
        }
        
    }
    
    
}


- (void) union_UI {
    
    
    _reStartUnionPhotoBtn = [UIView buttonWithTitle:@"位置校验"
                                          responder:self
                                                SEL:@selector(reConfigClick)
                                              frame:CGRectNull];
    
    
    [_reStartUnionPhotoBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    _reStartUnionPhotoBtn.backgroundColor = ColorValue_RGB(0xf2f2f2);
    [_reStartUnionPhotoBtn setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
    
    
    _endUnionPhotoBtn = [UIView buttonWithTitle:@"结束编辑"
                                      responder:self
                                            SEL:@selector(endUnionClick)
                                          frame:CGRectNull];
    
    [_endUnionPhotoBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    _endUnionPhotoBtn.backgroundColor = UIColor.mainColor;
    [_endUnionPhotoBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    [_VC.view addSubviews:@[_endUnionPhotoBtn,_reStartUnionPhotoBtn]];
    [_VC.view bringSubviewToFront:_endUnionPhotoBtn];
    [_VC.view bringSubviewToFront:_reStartUnionPhotoBtn];
    
    [_reStartUnionPhotoBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(15)];
    [_reStartUnionPhotoBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:Horizontal(15) + BottomZero];
    [_reStartUnionPhotoBtn autoSetDimension:ALDimensionWidth toSize:Horizontal(100)];
    [_reStartUnionPhotoBtn autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    
    [_endUnionPhotoBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(15)];
    [_endUnionPhotoBtn YuanAttributeHorizontalToView:_reStartUnionPhotoBtn];
    [_endUnionPhotoBtn YuanMyEdge:Left ToViewEdge:Right ToView:_reStartUnionPhotoBtn inset:Horizontal(15)];
    [_endUnionPhotoBtn autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    
    
    
}


#pragma mark - btnClick ---

- (void) reConfigClick {
    
    if (_reConfigClickBlock) {
        _reConfigClickBlock(@{
            @"inlineNums" : [NSNumber numberWithInteger:_inlineNums],
            @"lineCount" : [NSNumber numberWithInteger:_lineCount]});
    }
    
}

- (void) endUnionClick {
    
    NSMutableArray * mt_Arr = NSMutableArray.array;
    
    for (int i = 1; i <= _dataSource.count; i++) {
        
        NSString * position = [Yuan_Foundation fromInt:i];
        
        for (NSDictionary * dict in _dataSource) {
            
            NSString * myPosition = dict.allKeys.firstObject;
            
            if ([myPosition isEqualToString:position]) {
                
                NSDictionary * dzp_Dict = dict[myPosition];
                NSArray * opticTerms = dzp_Dict[@"opticTerms"];
                
                
                NSMutableArray * sub_Mt_Arr = NSMutableArray.array;
                
                for (NSDictionary * dz_Dict in opticTerms) {
                        
                    NSString * type = @"u";
                    
                    if ([dz_Dict[@"oprStateId"] isEqualToString:@"3"]) {
                        type = @"p";
                    }
                    
                    [sub_Mt_Arr addObject:type];
                }
                
                [mt_Arr addObject:sub_Mt_Arr];
                break;
            }
            continue;
        }
    }
    
    [Yuan_ODF_HttpModel ODF_HttpImageToUnionBatchHold_TxtCoordinated:_photoCheckArray
                                                             base64Img:_photoCheckBase64Img
                                                                matrix:_photoChekc_MATRIX
                                                        matrixModified:mt_Arr
                                                          successBlock:^(id  _Nonnull requestData) {
        NSLog(@"图片识别回调成功");
        
    }];
    
    
    
    _isUnionPhotoState = NO;
    
    // 退回
    Pop(_VC);

}


- (void) http_ChangeTerminalState:(Yuan_terminalBtn *)btn {
    
    [UIAlert alertSmallTitle:@"是否修改端子状态"
               agreeBtnBlock:^(UIAlertAction *action) {
            
        [self http_terminal:btn];
    }];
    
}


- (void) http_terminal:(Yuan_terminalBtn *) btn {
    
    NSDictionary * btnDict = btn.dict;
    
    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:btnDict];
    
    if ([mt_Dict[@"oprStateId"] isEqualToString:@"1"]) {
        mt_Dict[@"oprStateId"] = @"3";
    }
    
    else {
        mt_Dict[@"oprStateId"] = @"1";
    }
    
    
    [Yuan_ODF_HttpModel ODF_HttpChangeTerminalState:mt_Dict
                                       successBlock:^(id  _Nonnull requestData) {
       
        // 只清空边框 , 不删除端子识别回来的状态
        [btn hideMyUnionPhotoState:NO];
        
        NSArray * arr = requestData;
        
        if (arr) {
            NSDictionary * btnDict = arr.firstObject;
            btn.dict = btnDict;
        }
        
    }];
}




#pragma mark - 校验结束 ---

- (void) PhotoCheckEnd:(NSArray *) array {
    
    
    if (!_photoCheckImage || !_photoCheckArray) {
        [YuanHUD HUDFullText:@"为获取到图片和数据"];
        return;
    }
    
    
    for (Yuan_terminalBtn * btn in _btnsArray) {
        [btn hideMyUnionPhotoState:YES];
    }
    
    
    // 再去重新为端子赋值
    NSInteger start = _PhotoVM.position_Start;
    NSInteger end = _PhotoVM.position_End;
    
    // 正序是yes 倒序是NO
    BOOL flow ;
    
    if (start < end) {
        flow = YES;
    }
    else {
        flow = NO;
    }
    
    // 图片整体的宽和高
    float img_Width = _photoCheckImage.size.width;
    float img_Height = _photoCheckImage.size.height;
    
    // 单个模块的 宽和高
    float single_Width = img_Width / _inlineNums;
    float single_Height = img_Height / _lineCount;
    
    NSMutableArray * newArr = NSMutableArray.array;
    
    for (NSDictionary * dict in _photoCheckArray) {
        
        NSNumber * top = dict[@"top"];
        NSNumber * left = dict[@"left"];
        
        NSNumber * right = dict[@"right"];
        NSNumber * bottom = dict[@"bottom"];
        
        if ([top obj_IsNull] || [left obj_IsNull] ||
            [right obj_IsNull] || [bottom obj_IsNull]) {
            continue;
        }
        
        float center_X = (right.floatValue - left.floatValue) / 2 + left.floatValue;
        float center_Y = (bottom.floatValue - top.floatValue) / 2 + top.floatValue;
        
        // 行
        int row = center_Y / single_Height;
        
        // 列
        int line = center_X / single_Width;
        
        NSMutableDictionary * new_dict = [NSMutableDictionary dictionaryWithDictionary:dict];
        
        // 正序
        if (flow == true) {
            
            if (row + start - 1 >= end) {
                continue;
            }
            
            new_dict[@"row"] = [NSNumber numberWithInteger:row + start - 1];
            new_dict[@"line"] = [NSNumber numberWithInt:line];
        }
        else {
            
            if (start - row <= end - 1) {
                continue;
            }
            
            new_dict[@"row"] = [NSNumber numberWithInteger:start - row];
            new_dict[@"line"] = [NSNumber numberWithInt:line];
        }
        
        
        [newArr addObject:new_dict];
    }
    
    
    // 正序 以 startPosition 开头  以end结尾 如果大于end 砍掉
    // 倒叙 以 endPosition开头 如果 以end结尾 如果小于 start 砍掉
    
    
    
    // 遍历 button
    for (Yuan_terminalBtn * btn in _btnsArray) {
        
        NSInteger btn_row = btn.position;
        NSInteger btn_line = btn.index;
        
        for (NSDictionary * dict in newArr) {
            
            // 不存在 行和列的话 , 直接跳过
            if (![dict.allKeys containsObject:@"row"] || ![dict.allKeys containsObject:@"line"]) {
                continue;
            }
            
            NSNumber * dict_row = dict[@"row"];
            NSNumber * dict_line = dict[@"line"];
            
            NSInteger dict_Row_Int = dict_row.integerValue;
            NSInteger dict_Line_Int = dict_line.integerValue;
            
            if (flow) {
               
                // 为啥 + 1?  因为 计算 new_dict[@"row"] 时 会有 0.5的数 , int后为0
                if (btn_row == dict_Row_Int + 1 && btn_line == dict_Line_Int + 1) {
                    
                    // 给 btn赋值
                    [btn showMyUnionPhotoState:dict];
                }
            }
            else {
                
                // 为啥 + 1?  因为 计算 new_dict[@"row"] 时 会有 0.5的数 , int后为0
                if (btn_row == dict_Row_Int  && btn_line == dict_Line_Int + 1) {
                    
                    // 给 btn赋值
                    [btn showMyUnionPhotoState:dict];
                }
                
            }
            
            
        }
        
    }
}





- (void) BatchHold_Start:(BOOL)isStart {
    _BatchStart = isStart;
    if (isStart) {
        [self getBtns];
    }
    
}

- (void) BatchHold_Save {
    
    if (_BatchHoldArray.count == 0) {
        [YuanHUD HUDFullText:@"未选中端子"];
        return;
    }
    
    // 弹出提示框
    if (_BatchHold_SaveClick_TipsShow) {
        _BatchHold_SaveClick_TipsShow();
    }
}


- (void) clear_BatchHold {
    
    [_BatchHoldArray removeAllObjects];
    [_batchHoldArrayZZC removeAllObjects];
    [self getBtns];
    
    
    for (Yuan_terminalBtn * btn in _btnsArray) {
        [btn redBorder:NO];
    }
}


- (void) http_BatchHold_Save {
    
    NSString * optStateId;
    
    
    NSArray * chooseArr = @[@"■ 空闲" ,
                            @"■ 预占",
                            @"■ 占用",
                            @"■ 预释放" ,
                            @"■ 预留",
                            @"■ 预选",
                            @"■ 备用" ,
                            @"■ 停用",
                            @"■ 闲置",
                            @"■ 损坏" ,
                            @"■ 测试",
                            @"■ 临时占用"];
    
    
    NSInteger index = 0;
    
    if ([chooseArr containsObject:_PhotoVM.selectOprState]) {
        index = [chooseArr indexOfObject:_PhotoVM.selectOprState] + 1;
    }
    

    optStateId = [Yuan_Foundation fromInteger:index];
    
    
    NSString * realId;
    
    
    switch (index) {
        case 1:
            realId = @"170001";
            break;
        case 2:
            realId = @"170002";
            break;
        case 3:
            realId = @"170003";
            break;
        case 4:
            realId = @"170005";
            break;
        case 5:
            realId = @"170007";
            break;
        case 6:
            realId = @"170014";
            break;
        case 7:
            realId = @"170015";
            break;
        case 8:
            realId = @"160014";
            break;
        case 9:
            realId = @"160065";
            break;
        case 10:
            realId = @"170147";
            break;
        case 11:
            realId = @"170046";
            break;
        case 12:
            realId = @"170187";
            break;
            
        default:
            realId = @"-1";
            break;
    }
    
   
    
    NSMutableDictionary * postDict = NSMutableDictionary.dictionary;
    
    postDict[@"resType"] = @"optTerm";
    postDict[@"oprStateId"] = realId;
    postDict[@"gidList"] = _BatchHoldArray;
    
    [Yuan_ODF_HttpModel http_BatchSynchronizeTerminalStatus:postDict
                                               successBlock:^(id  _Nonnull requestData) {
            
        if (_BatchHold_SaveBlock) {
            _BatchHold_SaveBlock(_batchHoldArrayZZC);
        }
       
        [self clear_BatchHold];
        
    }];
    
    
}






#pragma mark - 2021.7.8 ---

// 获取所有端子的view 数组
- (NSArray *) getAllDatas {
    
    [self getBtns];
    return _dictsArr;
}

// 获取行内端子个数
- (NSInteger)getInlineNums {
    
    return _inlineNums;
}

- (NSArray *)getAllBtnS {
    [self getBtns];
    return _btnsArray;
}

@end
