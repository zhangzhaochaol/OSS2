//
//  Yuan_PhotoService.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/8/25.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_PhotoService.h"

#import <Photos/Photos.h>


@implementation Yuan_PhotoService
{
    AMapLocationManager * _manager;
    
}

#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
        
        _manager = AMapLocationManager.alloc.init;
        // 带逆地理信息的一次定位（返回坐标和地址信息）
        [_manager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        //   定位超时时间，最低2s，此处设置为2s
        _manager.locationTimeout =2;
        //   逆地理请求超时时间，最低2s，此处设置为2s
        _manager.reGeocodeTimeout = 2;
        
    }
    return self;
}


- (void) startLocation {
    
    
    // 带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [_manager requestLocationWithReGeocode:NO
                           completionBlock:^(CLLocation *location,
                                             AMapLocationReGeocode *regeocode,
                                             NSError *error) {
        
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
    
        CLLocationCoordinate2D coor = location.coordinate;
        
        _lat = coor.latitude;
        _lon = coor.longitude;
    
        NSLog(@"location:%@", location);
        
        if (regeocode)
        {
            NSLog(@"reGeocode:%@", regeocode);
        }
    }];
    
    
}


#pragma mark -  调起相机或相册  ---



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
           
            [wself presentViewController:picker animated:YES completion:nil];
           
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
           
            [wself presentViewController:picker animated:YES completion:nil];
           
        }else{
            NSLog(@"模拟其中无法打开照相机,请在真机中使用");
        }
        
        return;
    }
    
    
}





NSString * ImgName (NSString * resLogicName , NSString * gid) {
    
    NSString * nowTime = [Yuan_Foundation currentSecond];
    
    // 移除 空格 : -
    NSString * nowTime_a =  [nowTime stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSString * nowTime_b =  [nowTime_a stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString * nowTime_c =  [nowTime_b stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString * result = [NSString stringWithFormat:@"%@-%@-%@.png",resLogicName,gid,nowTime_c];
    
    return result;
    
    
}




@end
