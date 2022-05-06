//
//  Increase_CaremaVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/22.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Increase_CaremaVC.h"

#import <Photos/Photos.h>

@interface Increase_CaremaVC ()

<
    UIImagePickerControllerDelegate ,
    UINavigationControllerDelegate
>

@end

@implementation Increase_CaremaVC

{
    UIViewController <UIImagePickerControllerDelegate , UINavigationControllerDelegate> *  _myVc;
    
    
    void (^_myBlock) (UIImage * image);
    
}


#pragma mark - 初始化构造方法

- (instancetype)initWithVC:(UIViewController <UIImagePickerControllerDelegate ,
                            UINavigationControllerDelegate> *) vc {
    
    if (self = [super init]) {
        _myVc = vc;
    }
    return self;
}


#pragma mark - method ---

- (void) openLibrary {
    
    [self openCaremaEnum:PhotoEnum_Library delegate:_myVc];
}

- (void) openCarema {

    [self openCaremaEnum:PhotoEnum_Carema delegate:_myVc];
}



#pragma mark - delegate ---

- (void) openCaremaEnum:(PhotoEnum_)enumType
               delegate:(UIViewController  <UIImagePickerControllerDelegate ,
                         UINavigationControllerDelegate> *)wself{
    

    //打开相机
    if (enumType == PhotoEnum_Carema) {
        // 判断状态
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
           
            // 创建工具
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = wself;
           // 设置来源
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
           
           if (@available(iOS 13, *)){
           
               picker.modalPresentationStyle = UIModalPresentationPageSheet;
            }
            picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
           
            [wself presentViewController:picker animated:YES completion:nil];
           
//            picker.allowsEditing = YES;
        }else{
            NSLog(@"模拟其中无法打开照相机,请在真机中使用");
        }
        return;
    }
    
    
    // 打开相册
    if (enumType == PhotoEnum_Library) {
        
        // 判断状态
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
           
            // 创建工具
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = wself;
           // 设置来源
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
           
           if (@available(iOS 13, *)){
           
               picker.modalPresentationStyle = UIModalPresentationPageSheet;
            }
           
//            picker.allowsEditing = YES;
            
            picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [wself presentViewController:picker animated:YES completion:nil];
            
            
            
           
        }else{
            NSLog(@"模拟其中无法打开照相机,请在真机中使用");
        }
        
        return;
    }
    
    
}




#pragma mark - ImagePicker Delegate

// 此处代理仅作为参考 还是需要到 vc中实现代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
                
}


@end
