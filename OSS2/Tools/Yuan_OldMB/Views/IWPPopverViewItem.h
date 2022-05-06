//
//  IWPPopverViewItem.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2017/10/9.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPDeviceLocationItem.h"


@interface IWPPopverViewItem : NSObject
@property (nonatomic, copy) DeviceLocationItemDidSelected handler;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * selectedTitle;
@property (nonatomic, copy) NSString * imageName;
@property (nonatomic, copy) NSString * action;
@property (nonatomic, copy) NSString * actionSelected;
@property (nonatomic, copy) DeviceLocationItemDidSelected handlerSelected;
@property (nonatomic, assign) BOOL selected;

- (NSDictionary *)makeDictionary;
- (NSString *)makeJSON;
@end
