//
//  Increase_ScanVC.m
//  科信光缆
//
//  Created by zzc on 2021/3/29.
//


#import <UIKit/UIKit.h>

@interface Increase_ScanVC : UIViewController

//二维码返回字符串
@property (copy, nonatomic) void(^showCodeBlock)(NSString * codeStr);


@end
