//
//  Inc_headCell.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_headCell : UITableViewCell

//端子信息
@property (nonatomic, strong) NSDictionary *dic;

//端子、纤芯
@property (nonatomic, strong) NSString *typeName;


@end

NS_ASSUME_NONNULL_END
