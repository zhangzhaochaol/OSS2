//
//  Yuan_RCListHistory_NavBtn.h
//  INCP&EManager
//
//  Created by 袁全 on 2020/6/17.
//  Copyright © 2020 Unigame.space. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RC_ListHistoryBtn_SelectType) {
    RC_ListHistoryBtn_SelectType_Normal = 0,
    RC_ListHistoryBtn_SelectType_Select = 1,
};

@interface Yuan_RCListHistory_NavBtn : UIButton


- (instancetype)initWithTitle:(NSString * )title
    NavBtnChangeImageWithType:(RC_ListHistoryBtn_SelectType)type;


- (void) NavBtnChangeImageWithType:(RC_ListHistoryBtn_SelectType)type;

@end

NS_ASSUME_NONNULL_END
