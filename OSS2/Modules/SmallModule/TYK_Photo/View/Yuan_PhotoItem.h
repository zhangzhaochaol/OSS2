//
//  Yuan_PhotoItem.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/8/24.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_PhotoItem : UICollectionViewCell


/** 调起摄像头 */
@property (nonatomic,strong) UIButton * takePhotoBtn;

/** 图片 */
@property (nonatomic,strong) UIImageView * photoImg;


/** filePath */
@property (nonatomic ,copy)  NSString *filePath;


/** index */
@property (nonatomic,strong) NSIndexPath *index;


/** 声明 <#关于#> 的block */
@property (nonatomic ,copy) void(^itemLongPressBlock)(NSIndexPath * index);



- (void) showBtn;

- (void) hideBtn;

- (void) downLoadImg;

@end

NS_ASSUME_NONNULL_END
