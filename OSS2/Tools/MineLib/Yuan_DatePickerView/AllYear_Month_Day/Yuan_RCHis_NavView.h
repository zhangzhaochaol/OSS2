//
//  Yuan_RCHis_NavView.h
//  INCP&EManager
//
//  Created by 袁全 on 2020/6/17.
//  Copyright © 2020 Unigame.space. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol RCHis_NavViewDelegate  <NSObject>

- (void)RC_His_NavViewDict:(NSMutableDictionary *)delegateDict;

@end

@interface Yuan_RCHis_NavView : UIView

/** 代理 */
@property (nonatomic,weak) id <RCHis_NavViewDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
