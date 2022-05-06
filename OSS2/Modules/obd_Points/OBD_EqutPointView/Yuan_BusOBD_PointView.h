//
//  Yuan_BusOBD_PointView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Yuan_BusOBD_PointItem.h"
NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger , BusOBD_PointView_) {
    BusOBD_PointView_Select,    // 简单查询和保存端子
    BusOBD_PointView_Bind,      // 绑定
};


@protocol Yuan_BusOBD_ItemDelegate <NSObject>

@required

/// item的点击事件 输出部分
- (void) Yuan_BusOBDSelect_outPut_nowSelectItem:(Yuan_BusOBD_PointItem *) item
                                          index:(NSIndexPath *)index
                                          datas:(NSArray *)datas;


/// item的点击事件 输入按钮
- (void) Yuan_BusOBDSelect_inputItem_DataSource:(NSDictionary *)dict
                                            btn:(UIButton *)inputBtn;


@end

@interface Yuan_BusOBD_PointView : UIView

- (instancetype)initWithSuperResId:(NSString *) superResId;

/** BusOBD_PointView_ */
@property (nonatomic , assign) BusOBD_PointView_ pointEnum;

/** 上层的vc */
@property (nonatomic , weak) UIViewController * vc;


/** 存放所有 '输出端'  -- OBD Item端子的数组 */
@property (nonatomic , strong) NSMutableArray  <Yuan_BusOBD_PointItem *> * OBD_ItemsArr;


/** 查看 输出端的数据 */
@property (nonatomic , copy , readonly) NSArray * outPutDatas;


/** 查看 输入端的数据 */
@property (nonatomic , copy , readonly) NSDictionary * inPutDatas;


/** <#注释#> */
@property (nonatomic , weak) id <Yuan_BusOBD_ItemDelegate> delegate;


/** 未初始化端子  block */
@property (nonatomic , copy) void (^uninitialized_PointBlock) (void);

/** 解绑  block */
@property (nonatomic , copy) void (^disConnect_ShipBlock) (NSDictionary * dict);


// 输入端子 选中状态 , 其他端子为未选中状态
- (void) BusOBD_InputBtn_Select;


// 输出端子 选中状态 , 其他端子 包括输入端子 为未选中状态
- (void) BusOBD_OutPutItem_Select:(Yuan_BusOBD_PointItem *) item;


// 不选择任何端子
- (void) BusOBD_SelectNothing;


/// 选中下一个
- (void) BusOBD_OutPutItem_SelectNext:(NSIndexPath *) nowIndex;



- (void) reloadConnectSympolArray:(NSArray *) pointIdsArr;

@end

NS_ASSUME_NONNULL_END
