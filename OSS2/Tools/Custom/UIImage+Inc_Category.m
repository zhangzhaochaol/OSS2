//
//  UIImage+Inc_Category.m
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/4/21.
//

#import "UIImage+Inc_Category.h"

@implementation UIImage (Inc_Category)

+ (UIImage *) Inc_imageNamed:(NSString *) imageName {
    
    
    NSBundle * bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                  pathForResource:@"OSS2_SDKImage"
                                                  ofType:@"bundle"]];
    
    UIImage *image = [UIImage imageNamed:imageName
                                inBundle:bundle
           compatibleWithTraitCollection:nil];
    
    return image;
    
}

@end
