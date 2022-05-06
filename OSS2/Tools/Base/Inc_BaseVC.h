//
//  Inc_BaseVC.h
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_BaseVC : UIViewController


//h5 按钮更多回调
@property (nonatomic,copy) void(^moreBtnBlock)(UIButton *btn);

//h5 按钮关闭回调
//@property (nonatomic,copy) void(^closeBtnBlock)(void);




@end

NS_ASSUME_NONNULL_END
