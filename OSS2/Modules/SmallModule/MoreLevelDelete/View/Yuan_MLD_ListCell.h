//
//  Yuan_MLD_ListCell.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/27.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface Yuan_MLD_ListCell : UITableViewCell


- (void) reloadDict:(NSDictionary *) dict;

- (void) btnHidden:(BOOL) needHidden;


/** <#注释#>  block */
@property (nonatomic , copy) void (^reloadSelectBlock) (void);



@end

NS_ASSUME_NONNULL_END
