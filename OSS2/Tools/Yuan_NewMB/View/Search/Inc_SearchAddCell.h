//
//  Inc_SearchAddCell.h
//  科信光缆
//
//  Created by zzc on 2021/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_SearchAddCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;//cell titleLabel名称

/** 详细内容 应使用label 因后期可能当前页编辑 方便 */
@property (nonatomic, strong) UITextField *textView;//cell 输入TextView

@property (nonatomic, strong) NSString *titleString;

@end

NS_ASSUME_NONNULL_END
