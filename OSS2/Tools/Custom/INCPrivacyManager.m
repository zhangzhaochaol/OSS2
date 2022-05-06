//
//  INCPrivacyManager.m
//  ChinaUnicom_Liaoning
//
//  Created by 王旭焜 on 2018/4/3.
//  Copyright © 2018年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "INCPrivacyManager.h"
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>
#import <CoreTelephony/CTCellularData.h>
#import <EventKit/EventKit.h>

#import <Contacts/Contacts.h>

//@interface INCAlertView : UIAlertView
//
//@end
//@implementation INCAlertView : UIAlertView
//@end

static INCPrivacyManager * _privacyManager = nil;

@interface INCPrivacyManager () <UIAlertViewDelegate>
@property (nonatomic, strong) CLLocationManager * manager;

@property (nonatomic, weak) UIAlertController * lastAlert;
@end

@implementation INCPrivacyManager

- (CLLocationManager *)manager{
    if (_manager == nil) {
        _manager = [[CLLocationManager alloc] init];
    }
    
    return _manager;
}

-(INCPrivacyManagerPrivacyState)isHavePrivacyForType:(INCPrivacyManagerPrivacyType)type{
    
    switch (type) {
        case INCPrivacyManagerPrivacyTypeLocation_WhenInUse:
            return [self location_IsWhenInUse];
            break;
        case INCPrivacyManagerPrivacyTypeLocation_Always:
            return [self location_Always];
            break;
        case INCPrivacyManagerPrivacyTypeCamera:
            return [self camera];
            break;
        case INCPrivacyManagerPrivacyTypeNet:
            // TODO: 验证网络权限
            return [self netRequest];
            break;
        case INCPrivacyManagerPrivacyTypeCalendar:
            // TODO: 验证日历/行事历权限
            return [self calendar];
            break;
        case INCPrivacyManagerPrivacyTypeContacts:
            // TODO: 验证联络人权限
            return [self contacts];
            break;
        case INCPrivacyManagerPrivacyTypeReminder:
            // TODO: 验证提醒事件权限
            return [self reminder];
            break;
        case INCPrivacyManagerPrivacyTypeMicrophone:
            // TODO: 验证话筒权限
            return [self microphone];
            break;
        case INCPrivacyManagerPrivacyTypeNotification:
            // TODO: 验证推送权限
            return [self notification];
            break;
        case INCPrivacyManagerPrivacyTypePhotoLibrary:
            // TODO: 验证相册权限
            return [self photoLibrary];
            break;
        default:
            return INCPrivacyManagerPrivacyStateNotDetermined;
            break;
    }
    
//    if (type == INCPrivacyManagerPrivacyTypeLocation_WhenInUse) {
//        return [self location_IsWhenInUse];
//    }
//
//    if (type == INCPrivacyManagerPrivacyTypeLocation_Always) {
//        return [self location_Always];
//    }
//
//    if (type == INCPrivacyManagerPrivacyTypeCamera) {
//        return [self camera];
//    }
    
    return INCPrivacyManagerPrivacyStateNotDetermined;
}

- (void)requestPrivacyForType:(INCPrivacyManagerPrivacyType)type{
    
    if (type == INCPrivacyManagerPrivacyTypeLocation_WhenInUse) {
        [self requestLocation_WhenInUse];
    }
    
    if (type == INCPrivacyManagerPrivacyTypeLocation_Always) {
        [self requestLocation_Always];
    }
    
    if (type == INCPrivacyManagerPrivacyTypeCamera) {
        [self requestCamera];
    }
    
    
}

- (void)showDeniedHint:(INCPrivacyManagerPrivacyType)type{
    
    switch (type) {
        case INCPrivacyManagerPrivacyTypeLocation_WhenInUse:
            [self showWhenInUseHint];
            break;
        case INCPrivacyManagerPrivacyTypeLocation_Always:
            [self showAlwaysHint];
            break;
        case INCPrivacyManagerPrivacyTypeCamera:
            [self showCameraHint];
            break;
        case INCPrivacyManagerPrivacyTypeNet:
            // TODO: 提示网络权限
            break;
        case INCPrivacyManagerPrivacyTypeCalendar:
            // TODO: 提示日历/行事历权限
            break;
        case INCPrivacyManagerPrivacyTypeContacts:
            // TODO: 提示通讯录权限
            break;
        case INCPrivacyManagerPrivacyTypeReminder:
            // TODO: 提示提醒事件权限
            break;
        case INCPrivacyManagerPrivacyTypeMicrophone:
            // TODO: 提示麦克风权限
            break;
        case INCPrivacyManagerPrivacyTypeNotification:
            // TODO: 提示推送权限
            break;
        case INCPrivacyManagerPrivacyTypePhotoLibrary:
            // TODO: 提示相册权限
            break;
        default:
            break;
    }

    
}




+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_privacyManager == nil) {
            _privacyManager = [super allocWithZone:zone];
        }
    });
    return _privacyManager;
}

+(instancetype)privacyManager{
    
    
    INCPrivacyManager * manager = [[self alloc] init];
    
    return manager;
}
-(id)copyWithZone:(NSZone *)zone{
    return _privacyManager;
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return _privacyManager;
}
/*
 kCLAuthorizationStatusNotDetermined = 0,
 kCLAuthorizationStatusRestricted,
 kCLAuthorizationStatusDenied,
 kCLAuthorizationStatusAuthorizedAlways NS_ENUM_AVAILABLE(10_12, 8_0),
 kCLAuthorizationStatusAuthorizedWhenInUse NS_ENUM_AVAILABLE(NA, 8_0),
 kCLAuthorizationStatusAuthorized
 */
#pragma mark - 权限验证
#pragma mark 定位权限 - When In Use
- (INCPrivacyManagerPrivacyState)location_IsWhenInUse{
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return INCPrivacyManagerPrivacyStateDenied;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        return INCPrivacyManagerPrivacyStateWhenInUse;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return INCPrivacyManagerPrivacyStateAlways;
    }
    
    return INCPrivacyManagerPrivacyStateNotDetermined;
}
#pragma mark 定位权限 - Always
- (INCPrivacyManagerPrivacyState)location_Always{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        return INCPrivacyManagerPrivacyStateDenied;
    }
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        return INCPrivacyManagerPrivacyStateWhenInUse;
    }
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return INCPrivacyManagerPrivacyStateAlways;
    }
    
    return INCPrivacyManagerPrivacyStateNotDetermined;
}
#pragma mark 相机权限

- (INCPrivacyManagerPrivacyState)camera{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied) {
        return INCPrivacyManagerPrivacyStateDenied;
    }
    
    if (status == AVAuthorizationStatusAuthorized) {
        return INCPrivacyManagerPrivacyStateAlow;
    }
    
    return INCPrivacyManagerPrivacyStateNotDetermined;
}

#pragma mark 网络访问权限
- (INCPrivacyManagerPrivacyState)netRequest{
    
    CTCellularData *cellularData = [[CTCellularData alloc]init];
    CTCellularDataRestrictedState state = cellularData.restrictedState;
    
    if (state == kCTCellularDataNotRestricted) {
        
        return INCPrivacyManagerPrivacyStateAlow;
    }else{
        // 不是行动 + wifi，就是拒绝访问
        return INCPrivacyManagerPrivacyStateDenied;
    }
    
}
#pragma mark 日历/行事历
- (INCPrivacyManagerPrivacyState)calendar{
    
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    if (status == EKAuthorizationStatusDenied) {
        return INCPrivacyManagerPrivacyStateDenied;
    }
    
    if (status == EKAuthorizationStatusAuthorized) {
        return INCPrivacyManagerPrivacyStateAlow;
    }
    
    return INCPrivacyManagerPrivacyStateNotDetermined;
    
}

#pragma mark 备忘录
- (INCPrivacyManagerPrivacyState)reminder{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    if (status == EKAuthorizationStatusDenied) {
        return INCPrivacyManagerPrivacyStateDenied;
    }
    
    if (status == EKAuthorizationStatusAuthorized) {
        return INCPrivacyManagerPrivacyStateAlow;
    }
    
    return INCPrivacyManagerPrivacyStateNotDetermined;
}

#pragma mark 通讯录
- (INCPrivacyManagerPrivacyState)contacts{
    
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    if (status == CNAuthorizationStatusDenied) {
        return INCPrivacyManagerPrivacyStateDenied;
    }
    
    if (status == CNAuthorizationStatusAuthorized) {
        return INCPrivacyManagerPrivacyStateAlow;
    }
    
    return INCPrivacyManagerPrivacyStateNotDetermined;
    
}
#pragma mark - 话筒
- (INCPrivacyManagerPrivacyState)microphone{
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (status == AVAuthorizationStatusDenied) {
        return INCPrivacyManagerPrivacyStateDenied;
    }
    
    if (status == AVAuthorizationStatusAuthorized) {
        return INCPrivacyManagerPrivacyStateAlow;
    }
    
    return INCPrivacyManagerPrivacyStateNotDetermined;
    
}
#pragma mark 推送
- (INCPrivacyManagerPrivacyState)notification{
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    switch (settings.types) {
        case UIUserNotificationTypeNone:
            return INCPrivacyManagerPrivacyStateDenied;
        default:
            return INCPrivacyManagerPrivacyStateAlow;
    }
           
}
#pragma mark 相册
- (INCPrivacyManagerPrivacyState)photoLibrary{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusDenied) {
        return INCPrivacyManagerPrivacyStateDenied;
    }
    
    if (status == PHAuthorizationStatusAuthorized) {
        return INCPrivacyManagerPrivacyStateAlow;
    }
    
    return INCPrivacyManagerPrivacyStateNotDetermined;
    
}

#pragma mark - 权限获取
#pragma mark 定位权限 When In Use
- (void)requestLocation_WhenInUse{
    
    [self.manager requestWhenInUseAuthorization];
    
}
#pragma mark 定位权限 Always
- (void)requestLocation_Always{
    
    [self.manager requestAlwaysAuthorization];
    
}
#pragma mark 相机权限
- (void)requestCamera{
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        
    }];

}


#pragma mark 权限提示
#pragma mark 定位权限 When In Use
- (void)showWhenInUseHint{
    
    [self showHintWithTitle:@"无法访问您的位置" message:@"请确认是否将定位功能开启或是否允许App访问您当前位置"];
    
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"无法访问您的位置" message:@"请确认是否将定位功能开启或是否允许App访问您当前位置" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
//
//        alert.tag = 0xA01;
//        [alert show];
//    });

}
#pragma mark 定位权限 Always
- (void)showAlwaysHint{
    [self showHintWithTitle:@"无法访问您的位置" message:@"请确认是否将定位功能开启或是否允许App持续访问您当前位置"];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"无法访问您的位置" message:@"请确认是否将定位功能开启或是否允许App持续访问您当前位置" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
//
//
//        alert.tag = 0xA02;
//        [alert show];
//    });attributedText    NSConcreteAttributedString *    @""    0x00000001c0235080

}
#pragma mark 相机权限
- (void)showCameraHint{
    [self showHintWithTitle:@"无法访问您的摄像头" message:@"请确认是否允许app访问您的摄像头"];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"无法访问您的摄像头" message:@"请确认是否允许app访问您的摄像头" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
//
//
//        alert.tag = 0xA03;
//        [alert show];
//    });
    
}

#pragma mark - 统一弹窗
- (void)showHintWithTitle:(NSString *)title message:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
    
    
}


//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    
//    if (buttonIndex == 1) {
//       
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//        
//    }
//    
//}
@end
