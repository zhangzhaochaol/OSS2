//
//  IWPGISSiftViewController.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2018/11/15.
//  Copyright © 2018 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

typedef void(^DidSelectedAnInfo)(NSDictionary * info);
typedef void(^NewDidSelectedInformation)(NSString * types, CLLocationCoordinate2D coordinate);
@interface IWPGISSiftViewController : Inc_BaseVC

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NewDidSelectedInformation selectedNew;
@property (nonatomic, copy) DidSelectedAnInfo selected;
@property (nonatomic, assign, readonly) CGFloat contentHeight;

/// 是否在统一库中使用
@property (nonatomic, assign) BOOL isUnionLibrary;
@end
