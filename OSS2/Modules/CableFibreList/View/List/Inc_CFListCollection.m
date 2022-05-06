//
//  Inc_CFListCollection.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CFListCollection.h"
#import "Inc_CFListCollectionItem.h"

#import "Yuan_CFConfigVM.h"

@interface Inc_CFListCollection ()

<
    UICollectionViewDelegate ,
    UICollectionViewDataSource ,
    UICollectionViewDelegateFlowLayout
>


/** collection */
@property (nonatomic,strong) UICollectionView *collection;

@end

@implementation Inc_CFListCollection

{
    
    CF_EnterType_ _enterType;
    
    NSMutableArray * _dataSource;
    
    NSArray * _noSuperResIdArray;
    
    Yuan_CFConfigVM * _viewModel;
    
    // 我手动点击的选中index  只有一个是红色的
    NSIndexPath * _MySelectIndex;
    
    BOOL _autoSelect_Over;
}




#pragma mark - 初始化构造方法

- (instancetype) initWithEnter:(CF_EnterType_)enterType {
    
    if (self = [super init]) {
        
        _autoSelect_Over = NO; // 自动选中已结束的判断
        
        _enterType = enterType;
        _dataSource = [NSMutableArray array];
        
        _viewModel = [Yuan_CFConfigVM shareInstance];
        
        float limit = Horizontal(13);        // 间距
        float sideLength = Horizontal(40);   // 边距
        
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
        //设置布局方向为垂直流布局
        layout.scrollDirection =UICollectionViewScrollDirectionVertical;
        //设置每个item的大小为100*100
        layout.itemSize =CGSizeMake(sideLength,sideLength);
        layout.minimumLineSpacing = limit;
        layout.minimumInteritemSpacing = limit;
        
        _collection = [UIView collectionDatasource:self
                                     registerClass:[Inc_CFListCollectionItem class]
                               CellReuseIdentifier:@"Yuan_CFListCollectionItem"
                                        flowLayout:layout];
        
        [self addSubview:_collection];
        
        [self layoutAllSubViews];
        
        
        __typeof(self)wself = self;
        if (enterType == CF_EnterType_Config) {
            
            ///MARK: 关联之后的回调 -- 刷新 并且让选中的按钮后移一位
            // 只有在详情进入 collection 才有响应刷新的事件
            _viewModel.viewModel_Block_ReloadConfigListCollection = ^{
                
                // 刷新光缆段
//                [[Yuan_HUD shareInstance] HUDFullText:@"刷新"];
                [wself.collection reloadData];
                
                // 调用 选中后移事件
                [wself changeAnotherIndexOfSelectItemWhenBlock];
            };
        }
        
    }
    return self;
}


- (void)dataSource:(NSMutableArray *)dataSource {
    
    if (!dataSource) return;
    
    _dataSource = dataSource;
    [_collection reloadData];
    
    
    // MARK: 默认帮collection选中第一个  , 在详情页调用的时候  -- CF_EnterType_Config
    
    if (_enterType == CF_EnterType_Config) {
    
        // 默认选中第一个
        _MySelectIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [_collection selectItemAtIndexPath:_MySelectIndex animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        
        [self selectItemWithIndex:_MySelectIndex];
    }
    
    
}



// 哪些纤芯成端的端子 缺少superResId , 就把它变黄色
- (void) noSuperResIdSource:(NSArray *) noSuperResIdArray {
    
    _noSuperResIdArray = noSuperResIdArray;
    
    [_collection reloadData];
}


#pragma mark -  UICollectionViewDataSource  ---



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    return _dataSource.count ;
}




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    __weak Inc_CFListCollectionItem * item =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"Yuan_CFListCollectionItem"
                                              forIndexPath:indexPath];
    
    if (!item) {
        item = Inc_CFListCollectionItem.alloc.init;
    }
    
    // 配置边框颜色
    [item configBorderColor:CollectionListItemState_None];
    
    
    
    // 得到item 对应的数据源
    NSDictionary * dict = _dataSource[indexPath.row];
    
    NSString * pairId = dict[@"pairId"];
    // 文字内容 赋值
    [item configNum:dict[@"pairNo"] ?: @""];
    // 背景色  -- 占用 故障 空闲
    [item configColor:dict[@"oprStateId"]];
    
    
    
    // MARK: 2020年11月9日 新增 --- 纤芯关联的成端端子缺少superResId 则变黄色
    if (_enterType == CF_EnterType_List) {
        
        if ([_noSuperResIdArray containsObject:pairId]) {
            item.contentView.layer.borderWidth = 1;
            item.contentView.layer.borderColor = UIColor.yellowColor.CGColor;
        }
    }
    
    
    
    
    // MARK: 对当前应该是 已绑定的绿色 或未绑定的红色的判断  仅'CF_EnterType_Config'
    // 只有详情页的 item 才会有边框
    if (_enterType == CF_EnterType_Config) {
        
        for (NSDictionary * joinPostDict in _viewModel.linkSaveHttpArray) {
        
            // 如果 我当前item的 纤芯 GID 在 待保存数组当中 , 则他已经关联 成绿色
            NSString * already_combinationGID = joinPostDict[@"GID"];
            if ([already_combinationGID isEqualToString:pairId]) {
                // 证明这个item对应的数据 已经加入到 待上传列表的组合中 , 应该是绿色的边框
                // 置为已绑定的绿色边框
                [item configBorderColor:CollectionListItemState_Connect];
            }
        }
    }
    
     
    // 如果当前的index 和我选中的index相同的话 那么是红色选中框状态
    // 选中的优先级比绑定的高
    if (indexPath == _MySelectIndex && !_autoSelect_Over ) {
        // 选中的
        [item configBorderColor:CollectionListItemState_SelectingNow];
    }
    
    
    
    
    //MARK: 对上下图片显示进行判断  -- -- -- -- -- -- 通用
    
    // 默认是两端都不显示图片的 在下面的代码中再次配置图片
    [item imgConfigUpImage:CF_HeaderCellType_None];
    [item imgConfigDownImg:CF_HeaderCellType_None];
    
    
    // 获取到 判断纤芯的小map , 用来判断成端还是熔接 , 显示在左上角还是右下角
    NSArray * connectList = dict[@"connectList"];
    
    if (!connectList ||
        connectList.count == 0 ||
        [connectList isEqual:[NSNull null]]) {

        return item;
    }
    
    // *** *** ***  判断成端 熔接 左上 右下
    
    NSString * type;
    NSString * location;
    
    // 循环遍历 connectList
    
    for (NSDictionary * fiberDict in connectList) {
        
        NSDictionary * vm_Dict = [_viewModel viewModelFiberTypeAndLocationFromDict:fiberDict
                                                                            pairId:pairId];
        
        // 成端还是熔接
        type = vm_Dict[@"type"];
        // 左上还是右下
        location = vm_Dict[@"location"];
        
        // 如果 location == 1 左上角
        if ([location isEqualToString:@"1"]) {
            
            // type == 1 成端
            if ([type isEqualToString:@"2"]) {
                [item imgConfigUpImage:CF_HeaderCellType_ChengDuan];
            }
            // type == 2 熔接
            else {
                [item imgConfigUpImage:CF_HeaderCellType_RongJie];
            }
        }
        
        // 如果 location == 2 右下角
        else if([location isEqualToString:@"2"]){
            
            // type == 1 成端
            if ([type isEqualToString:@"2"]) {
                [item imgConfigDownImg:CF_HeaderCellType_ChengDuan];
            }
            // type == 2 熔接
            else {
                [item imgConfigDownImg:CF_HeaderCellType_RongJie];
            }
            
        }else {
            // 什么都不做 , 因为之前已经清空了  unKnow
        }
    }
    
    
    
    
    
    
    
    
    return item;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    /// MARK: 1.如果当前是列表的collection  那么点击事件执行的是跳转模板
    if (_enterType == CF_EnterType_List) {
        
        NSDictionary * dict = _dataSource[indexPath.row];
        
        // 点击回调 跳转模板
        if (_collection_SelectItemBlock) {
            _collection_SelectItemBlock(dict ?: @{});
        }
        
        return;
    }
    
    
    
    if (_viewModel.handleConfig_State == CF_ConfigHandle_Setting) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"您当前正在手动配置纤芯,请配置完成后再进行切换"];
        
        return;
    }
    
    
    
    /// MARK: 2.如果当前是配置界面的collection  那么点击事件执行的是边框颜色的变化
    
    _autoSelect_Over = NO;
    
    _MySelectIndex = indexPath;
    // 如果长按的话 剩余的循环次数
    _viewModel.for_Circle_Count = _dataSource.count - indexPath.row;
    
    // 在修改单个item的选中 之前 , 要取消掉其他所有的选中状态
    [_collection reloadData];
    
    // 给选中的数据赋值
    [self selectItemWithIndex:indexPath];
}

// 给选中的数据赋值
- (void) selectItemWithIndex:(NSIndexPath *)indexPath {
    
    NSDictionary * selectDict = _dataSource[indexPath.row];
    
    // 给viewModel的参数赋值
    _viewModel.baseLinkDict = selectDict;  //为了获取 pairNo等信息
    _viewModel.baseLink_FiberId = selectDict[@"GID"];  // 为了获取Gid
    
}


/// 每次 viewModel_Block_ReloadConfigListCollection 回调后 , 让选中的按钮 自动后移一位 , 知道结束
- (void) changeAnotherIndexOfSelectItemWhenBlock {
    
    // -1 因为 count是个数 不是索引
    if (_MySelectIndex.row < _dataSource.count - 1) {
        // 证明后面还有可选项
        _MySelectIndex = [NSIndexPath indexPathForRow:_MySelectIndex.row + 1 inSection:0];
        
        _autoSelect_Over = NO;
        
        [_collection selectItemAtIndexPath:_MySelectIndex animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        
        [self selectItemWithIndex:_MySelectIndex];
        
    } else if (_MySelectIndex.row == _dataSource.count - 1) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"结束"];
        
        _autoSelect_Over = YES;
        
        Inc_CFListCollectionItem * item = (Inc_CFListCollectionItem*)[_collection cellForItemAtIndexPath:_MySelectIndex];
        
        [item configBorderColor:CollectionListItemState_Connect];
    }
    
    
    
    
    
    
}



#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    [_collection autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
}


@end
