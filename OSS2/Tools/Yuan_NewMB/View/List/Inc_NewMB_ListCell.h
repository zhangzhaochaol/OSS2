//
//  Inc_NewMB_ListCell.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inc_NewMB_VM.h"
NS_ASSUME_NONNULL_BEGIN

@interface Inc_NewMB_ListCell : UITableViewCell

- (void) cellImgWithResEnum:(Yuan_NewMB_ModelEnum_)modelEnum
                  cellTitle:(NSString *)title;


/** myDict */
@property (nonatomic , copy) NSDictionary * myDict;


@end

NS_ASSUME_NONNULL_END
