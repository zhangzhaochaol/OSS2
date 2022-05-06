//
//  RegionSelectViewController.h
//  OSS2.0-ios-v1
//
//  Created by 孟诗萌 on 16/4/28.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//



#import "ptotocolDelegate.h"

@interface RegionSelectViewController : Inc_BaseVC  <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>


@property (copy, nonatomic) NSString * backStr;//返回的信息
@property (nonatomic, weak) id<ptotocolDelegate> delegate;


/** 选中一条后的回调  block */
@property (nonatomic , copy) void (^regionSelectBlock) (NSDictionary * dict);


@end
