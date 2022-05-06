//
//  EquModelTYKCell.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/8/31.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EquModelTYKCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong)NSDictionary *dict;
@property (nonatomic,strong)UIView *backView;//背景图片
@property (nonatomic, weak) id<ptotocolDelegate> delegate;
@end
