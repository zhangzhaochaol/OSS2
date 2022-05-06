//
//  Inc_TE_ExLinkType_NameView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

// ****
#import "Inc_TE_ViewModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface Inc_TE_ExLinkType_NameView : UIView

- (void) reloadWithResType:(NSString *) resTypeName
                   resName:(NSString *) resName;

@end

NS_ASSUME_NONNULL_END
