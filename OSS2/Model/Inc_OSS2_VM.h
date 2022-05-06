//
//  Inc_OSS2_VM.h
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/4/21.
//

#import <Foundation/Foundation.h>

#import "Inc_WKWebViewJavascriptBridge.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , JoinModule_) {
    JoinModule_GIS = 1001,
};


@interface Inc_OSS2_VM : NSObject


/** homeVC */
@property (nonatomic , weak) UIViewController * homeVC;

/** bridge映射 */
@property (nonatomic , weak) Inc_WKWebViewJavascriptBridge * webViewBridge;


+ (Inc_OSS2_VM *) shareInstance;

// 跳转至哪一个模块
- (void) viewModel_JoinModule:(JoinModule_ )joinModule;


// 跳转模块的json
- (void) viewModel_JoinModuleDict:(NSDictionary *) jumpDict;

// 跳转至模板
- (void) JumpToMB:(NSDictionary *) jumpDict;


@end

NS_ASSUME_NONNULL_END
