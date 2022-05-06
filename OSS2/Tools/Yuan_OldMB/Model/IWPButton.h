//
//  IWPButton.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/6/6.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, IWPButtonType){
    IWPButtonTypeNormal,
    IWPButtonTypeSpecial,
};

typedef NS_ENUM(NSUInteger, IWPPECCornerStatus) {
    IWPPECCornerStatusHave,
    IWPPECCornerStatusNone,
};

@interface IWPButton : UIButton
@property (nonatomic, assign) IWPPECCornerStatus cornerStatus;

@property (nonatomic, assign) NSUInteger hiddenTag;
@property (nonatomic, copy) NSString * fileName;
@property (nonatomic, copy) NSString * key;
@property (nonatomic, copy) NSString * idKey;
@property (nonatomic, copy) NSString * name2;
@property (nonatomic, copy) NSString * type;
@property (nonatomic, assign) NSUInteger t11Tag;
@property (nonatomic, assign) NSInteger type11Tag;
@property (nonatomic, assign) IWPButtonType buttontype;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, copy) NSString * na;
@property (nonatomic, copy) NSString * value;

@property (nonatomic, assign) BOOL canSelect;
@end
