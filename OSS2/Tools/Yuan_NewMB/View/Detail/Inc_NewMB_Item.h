//
//  Inc_NewMB_Item.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

// 这两个 是写在同一类中的
@class Inc_NewMB_Model;
@class Yuan_NewMB_ModelItem;
@class Inc_NewMB_Item;

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger , Yuan_NewMB_ItemEnum_) {
    Yuan_NewMB_ItemEnum_Title,      //标题
};



@protocol Yuan_NewMB_ItemDelegate <NSObject>

// 外部dict 需要拿出 newDict里的参数 逐一赋值替换
- (void) Yuan_NewMB_Item:(Inc_NewMB_Item *) item
                 newDict:(NSDictionary *) newDict;


// 补充了新Dict后 需要根据新的大Map 重新刷新一遍界面
- (void) Yuan_NewMB_Item:(Inc_NewMB_Item *) item
                 newDict:(NSDictionary *) newDict
                isReload:(BOOL) isReload;



// 重置所有的Item
- (void) Yuan_NewMB_ReLoadAllItems;


@end


@interface Inc_NewMB_Item : UIView



/** <#注释#> */
@property (nonatomic , weak) id <Yuan_NewMB_ItemDelegate> delegate;

/** 我的数据 */
@property (nonatomic , copy , readonly) Yuan_NewMB_ModelItem * myModel;

/** json的 fileName */
@property (nonatomic , copy) NSString * fileName;

- (instancetype)initItemWithModel:(Yuan_NewMB_ModelItem *)model
                               vc:(UIViewController *)vc
                           mbDict:(NSDictionary *)mbDict;


- (float) getHeight;


// 重新加载数据   在reload之前 , 需要替换 _mbDict 里的数据源
- (void) reloadWithDict:(NSDictionary *) reloadDict;

- (void) changeTitleColor:(BOOL) isMainColor;

@end

NS_ASSUME_NONNULL_END
