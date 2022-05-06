//
//  PointTYKTableViewCell.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/9/26.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointTYKTableViewCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(assign,nonatomic)NSInteger tableViewIndex;//当前table的行数
@property (nonatomic,strong)NSDictionary *dict;//传过来的盘信息
@property (nonatomic,strong)NSMutableDictionary *fjListDic;//传过来的每盘端子信息
@property (nonatomic,strong)NSMutableArray *modelGIDArr;//每个盘的GID总数组
@property (nonatomic,weak)UICollectionView *panCollectionView;//盘
@property (nonatomic, weak) id<ptotocolDelegate> delegate;
@end
