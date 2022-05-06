//
//  IWPTableViewRowAction.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/6/6.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IWPTableViewRowAction : UITableViewRowAction
@property (nonatomic, assign) NSUInteger tag;
@property (nonatomic, copy) NSString * bean_name;
@property (nonatomic, copy) NSString * key;
@property (nonatomic, copy) NSString * imageName;
@end
