//
//  EquModelTYKCell.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/8/31.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "EquModelTYKCell.h"
#import "PanCollectionViewCell.h"


#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT self.contentView.frame.size.height

@implementation EquModelTYKCell
{
    UILabel *titleLabel;
    UICollectionView *panCollectionView;//盘
    NSArray *cardsArr;//实际插入的板卡数量
    long slotCount;//插槽数量
    NSMutableArray *totalCardsArr;//总共的插槽数量
}
@synthesize backView;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self createUI];
    }
    return self;
}
- (void)createUI
{
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH-10, 100)];
    backView.layer.cornerRadius = 5;
    backView.layer.borderWidth = 1;
    backView.layer.borderColor = [UIColor colorWithHexString:@"#AA0000"].CGColor;
    [self.contentView addSubview:backView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, backView.frame.size.width, 25)];
    [titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [titleLabel setTextColor:[UIColor blackColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:titleLabel];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    panCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(2, 25, backView.frame.size.width-4, backView.frame.size.height-26)collectionViewLayout:flowLayout];
    panCollectionView.showsHorizontalScrollIndicator = YES;
    panCollectionView.dataSource = self;
    panCollectionView.delegate = self;
    panCollectionView.backgroundColor = [UIColor whiteColor];
    [panCollectionView registerClass:[PanCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [panCollectionView setScrollEnabled:YES];
    panCollectionView.showsVerticalScrollIndicator = false;
    panCollectionView.showsHorizontalScrollIndicator = false;
    [self.contentView addSubview:panCollectionView];
}
- (void)setDict:(NSDictionary *)dict{
    titleLabel.text = dict[@"jkName"];
    cardsArr = dict[@"cards"];NSLog(@"cardsArr:%@",cardsArr);
    slotCount = [dict[@"slotCount"] integerValue];
    totalCardsArr = [[NSMutableArray alloc] init];
    for (int i = 0; i<slotCount; i++) {
        [totalCardsArr addObject:[NSMutableDictionary new]];
    }
    //把cardsArr数据放在totalCardsArr对应Indexl里
    for (int i = 0; i<cardsArr.count; i++) {
        int index = [cardsArr[i][@"positionCode"] intValue];
        totalCardsArr[index] = cardsArr[i];
    }
    CGSize titleTextSize = [titleLabel.text boundingRectWithSize:CGSizeMake(titleLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0]} context:nil].size;
    CGRect titleFrame = titleLabel.frame;
    if (titleTextSize.height>40) {
        titleFrame.size.height = titleTextSize.height;
        titleLabel.frame = titleFrame;
        
        CGRect backViewFrame = backView.frame;
        backViewFrame.size.height = backViewFrame.size.height + (titleTextSize.height-40);
        backView.frame = backViewFrame;
    }
    [panCollectionView reloadData];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(float)getBackGroundHeignt{
    return backView.frame.size.height;
}
#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return totalCardsArr.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    PanCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (totalCardsArr!=nil) {
         cell.textLabel.text = totalCardsArr[indexPath.row][@"positionCode"];
    }
    return cell;
}
#pragma mark UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(panCollectionView.frame.size.width/slotCount, panCollectionView.frame.size.height-10);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
#pragma mark UIColletionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (totalCardsArr[indexPath.row][@"positionCode"]!=nil) {
        if ([self.delegate respondsToSelector:@selector(doSomeThingo:)] == YES) {
            NSDictionary *dic = @{@"doType":@"clickPan",@"panInfo":totalCardsArr[indexPath.row]};
            [self.delegate doSomeThingo:dic];
        }
    }
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
/// 重写指示视图setter
/// 适配iOS13
/// @param accessoryType 指示视图类型
-(void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType{
    
    if (accessoryType == UITableViewCellAccessoryDisclosureIndicator){
        // 该类型存在显示错误的问题，采用指定图片的方式适配
        
        UIImageView * accessoryView = [UIImageView.alloc initWithImage:[UIImage Inc_imageNamed:@"icon_defaultAccessoryView"]];
        accessoryView.frame = CGRectMake(0, 0, 15, 15);
        
        self.accessoryView = accessoryView;
        
        
    }else{
        [super setAccessoryType:accessoryType];
    }
    
    
}
@end
