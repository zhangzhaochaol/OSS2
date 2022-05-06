//
//  IWPPopverOperationTableViewCell.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2017/10/9.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IWPPopverViewItem;

@interface IWPPopverOperationTableViewCell : UITableViewCell
@property (nonatomic, strong) IWPPopverViewItem * item;

+ (instancetype)operationCellInTableView:(UITableView *)tableView item:(IWPPopverViewItem *)item indexPath:(NSIndexPath *)indexPath;
@end
