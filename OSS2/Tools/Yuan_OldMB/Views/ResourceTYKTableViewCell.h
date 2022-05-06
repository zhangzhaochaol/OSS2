//
//  ResourceTYKTableViewCell.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/6/28.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, ResourceTYKCellEnum_) {
    ResourceTYKCellEnum_Section,    //一级资源
    ResourceTYKCellEnum_SubRes,     //二级资源
    ResourceTYKCellEnum_Location,   //定位
};

@interface ResourceTYKTableViewCell : UITableViewCell
@property (nonatomic,strong)NSDictionary *dict;
@property (nonatomic,strong)UIView *backView;//背景图片
/** 管道等类别时 , 下面的控制台 */
@property (nonatomic,strong) UIView *handleView;
@property (assign,nonatomic) BOOL isGeneratorSSSB;//是否是机房下属设备


- (instancetype) initWithStyle:(UITableViewCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier
               isHaveHandleBtn:(BOOL) isHaveHandle;


- (void) configBtns:(NSString *)resLogicName;

- (void) NoBtns;


/** 声明 点击后的回调 的block */
@property (nonatomic ,copy) void(^ResourceTYK_HandleBlock)(ResourceTYKCellEnum_ enumType);



@end
