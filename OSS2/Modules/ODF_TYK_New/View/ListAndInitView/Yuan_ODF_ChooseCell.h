//
//  Yuan_ODF_ChooseCell.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/28.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_ODF_ChooseCell : UITableViewCell

- (void) setTxt_Title:(NSString *)txt ;


/// 获取textfield的文字的值
- (NSString *) getTextFieldTxt;

/** <#注释#> */
@property (nonatomic,strong) NSArray *dataSource;


/** 框 */
@property (nonatomic,strong) UITextField *printView;

@end

NS_ASSUME_NONNULL_END
