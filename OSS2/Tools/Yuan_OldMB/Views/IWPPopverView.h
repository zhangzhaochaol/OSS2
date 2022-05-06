//
//  IWPPopverView.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2017/10/9.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWPPopverViewItem.h"

typedef NS_ENUM(NSUInteger, IWPPopverViewShowingMode) {
    IWPPopverViewShowingModeTopLeft,
    IWPPopverViewShowingModeTopRight,
    IWPPopverViewShowingModeBottomLeft,
    IWPPopverViewShowingModeBottomRight,
    IWPPopverViewShowingModeFree,
    IWPPopverViewShowingModeZz
};

@interface IWPPopverView : UIView
@property (nonatomic, strong) NSArray <__kindof IWPPopverViewItem *> * items;
@property (nonatomic, assign) IWPPopverViewShowingMode mode;
@property (nonatomic, assign, readonly) BOOL isShowing;
- (void)show;
- (void)hide;

- (IWPPopverViewItem *)itemWithTitle:(NSString *)title;
- (void)selectItem:(IWPPopverViewItem *)item;
- (void)deSelectItem:(IWPPopverViewItem *)item;
- (void)removeItem:(IWPPopverViewItem *)item;

- (void)setItemEnableState:(BOOL)state withTitle:(NSString *)title;



- (instancetype)initWithFrame:(CGRect)frame items:(NSArray <__kindof IWPPopverViewItem *> *)items mode:(IWPPopverViewShowingMode)mode;
+ (instancetype)popverViewWithItems:(NSArray <__kindof IWPPopverViewItem *> *)items mode:(IWPPopverViewShowingMode)mode;
@end
