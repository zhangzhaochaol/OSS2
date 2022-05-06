//
//  YKLListViewCell.h
//  YKLListViewDemo
//
//  Created by 擎杉 on 2017/1/17.
//  Copyright © 2017年 艾玩世纪互动娱乐. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YKLListViewCellDelegate <NSObject>
-(void)didSwitchSwitcher:(BOOL)isOn indexPath:(NSIndexPath *)indexPath isPlus:(BOOL)isPlus;
@end

@interface YKLListViewCell : UITableViewCell

@property (nonatomic, readwrite, weak) UISwitch * switcher;
@property (nonatomic, weak) id <YKLListViewCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, assign) BOOL isPlus;
@end
