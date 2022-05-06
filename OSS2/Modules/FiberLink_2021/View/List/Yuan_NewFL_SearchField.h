//
//  Yuan_NewFL_SearchField.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , NewFL_Click_) {
    NewFL_Click_Show,
    NewFL_Click_Search,
};

@interface Yuan_NewFL_SearchField : UIView

- (NSString *) searchName;
- (void) clear;



/** <#注释#>  block */
@property (nonatomic , copy) void (^NewFL_ClickBlock) (NewFL_Click_ click);

@end

NS_ASSUME_NONNULL_END
