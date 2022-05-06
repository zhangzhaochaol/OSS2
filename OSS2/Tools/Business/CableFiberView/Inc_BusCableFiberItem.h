//
//  Inc_BusCableFiberItem.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_BusCableFiberItem : UICollectionViewCell


/** 存放 对应的数据源 */
@property (nonatomic,strong) NSDictionary *myDict;


// 配置左上角 图片
- (void) imgConfigUpImage:(CF_HeaderCellType_)upType;

// 配置右下角 图片
- (void) imgConfigDownImg:(CF_HeaderCellType_)downType;




- (void) configNum:(NSString *)index;


- (void) configBindNum : (NSString *)pairNo from:(configBindingNumFrom_)type;



- (void) configBuliding_Color ;

@end

NS_ASSUME_NONNULL_END
